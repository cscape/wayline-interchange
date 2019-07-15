const globals = require('../lib/globals')
const path = require('path')
const fs = require('fs')
const FileHandlers = require('../lib/file-handlers')
const Crash = require('../lib/crasher')
const ConfigData = require('../lib/get-config')
const { doEverything, agencyIdFromNumber } = require('../lib/agency.properties')
const ChildProcess = require('child_process')
const Commands = require('../lib/commands')

// Check if the interchange/ic/ dir exists
const ICCacheDir = path.resolve(globals.InterchangeCache)
if (fs.existsSync(ICCacheDir)) {
  // does exist
  FileHandlers.deleteFolderRecursive(ICCacheDir)
}
require('../lib/ic-precheck')()

// Setting defaults,
// PLEASE explicitly pass the -user, -pass, and -host parameters when calling this script!
let dbUser = process.env.PGUSERNAME || null
let dbPass = process.env.PGPASSWORD || null
let dbHost = process.env.POSTGRES_PORT_5432_TCP_ADDR || null
let dbPort = process.env.POSTGRES_PORT_5432_TCP_PORT || 5432

process.argv.forEach(a => {
  if (a.indexOf('-') !== 0) return
  const key = String(a.split('=')[0].replace(/-/gm, '')).toLowerCase().trim()
  const val = String(a.split('=')[1]).trim()

  switch (key) {
    case 'user': dbUser = val; break
    case 'pass': dbPass = val; break
    case 'host': dbHost = val; break
  }
})

// Crash when not all variables set
;[dbUser, dbPass, dbHost].forEach(a => a == null ? Crash(
  new Error(`Please set all environment variables.` +
  `\nPGUSERNAME=${dbUser}\nPGPASSWORD=${dbPass}\nPOSTGRES_PORT_5432_TCP_ADDR=${dbHost}`)
) : 0)

// Generate an array of TransitClock agencies w/ relevant data
const TCPropertiesList = ConfigData.agency.map((agency, i) => {
  const fp = doEverything(i !== 0, agency.id, agency.realtimeUrl, dbUser, dbPass, dbHost)
  return {
    name: agency.name,
    id: String(agencyIdFromNumber(agency.id)),
    path: fp, // TC02.properties file path
    gtfs: agency.gtfsUrl,
    gtfsRT: agency.realtimeUrl
  }
})

let APIKeyForWEB = null

const BasicEnv = {
  PGUSERNAME: dbUser,
  POSTGRES_PORT_5432_TCP_ADDR: dbHost,
  POSTGRES_PORT_5432_TCP_PORT: dbPort,
  PGPASSWORD: dbPass
}

TCPropertiesList.forEach((agencyObj, i) => {
  const basicEnv = {
    PGUSERNAME: dbUser,
    POSTGRES_PORT_5432_TCP_ADDR: dbHost,
    POSTGRES_PORT_5432_TCP_PORT: dbPort,
    PGPASSWORD: dbPass,
    AGENCYID: agencyObj.id
  }
  // STEP 1: Create tables
  const Seq1 = Commands.CreateTablesForSingleAgency(agencyObj.id, dbUser, dbHost, dbPort)
  Seq1.forEach(cmd => {
    const rslt = ChildProcess.execSync(cmd, { env: basicEnv })
    console.log(rslt)
  })

  // STEP 2: Populate GTFS
  const Seq2 = Commands.ImportGTFSForSingleAgency(agencyObj.id, agencyObj.path, agencyObj.gtfs, dbUser, dbHost, dbPort)
  Seq2.forEach(cmd => {
    const rslt = ChildProcess.execSync(cmd, { env: basicEnv })
    console.log(rslt)
  })

  // STEP 3: Create Web Agency
  const Seq3 = Commands.CreateSingleWebAgency(agencyObj.id, dbUser, dbHost, dbPort, dbPass)
  ;(cmd => {
    const rslt = ChildProcess.execSync(cmd, { env: basicEnv })
    console.log(rslt)
  })(Seq3) // just a single command, not array

  ;(() => {
    // Generates API key
    if (i !== 0) return
    const rslt = ChildProcess.execSync(Commands.GetSingleAPIKey(agencyObj.id, dbUser, dbHost, dbPort), { env: basicEnv })
    const onlyApiKey = rslt.replace(/[^A-Za-z0-9]/gm, '')
    APIKeyForWEB = onlyApiKey
    doEverything(false, agencyObj.id, agencyObj.gtfsrt, dbUser, dbPass, dbHost, agencyObj.apikey)
  })()
})

const allConfigFiles = TCPropertiesList.reduce((prev, cur, i) => (i === 0 ? '' : prev + ';') + cur.path, '')

console.log(ChildProcess.execSync(Commands.InitRMI()))
console.log(ChildProcess.execSync(Commands.PutAPIKeyInEnv(APIKeyForWEB)))
console.log(ChildProcess.execSync(Commands.ExportAPIKey(APIKeyForWEB)))
console.log(ChildProcess.execSync(Commands.ExportConfigFiles(allConfigFiles)))

// START CORES
TCPropertiesList.forEach((agencyObj, i) => {
  // Generates API key
  const rslt = ChildProcess.execSync(Commands.StartCore(agencyObj.path, i !== 0), { env: BasicEnv })
  console.log(rslt)
})

console.log(ChildProcess.execSync(Commands.StartTomcat()))
console.log('Finished launching')
