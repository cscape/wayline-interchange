require('./lib/ic-precheck')()
const fs = require('fs')
const path = require('path')
const toml = require('toml')

const { doEverything, agencyIdFromNumber } = require('./lib/agency.properties')

// Setting defaults,
// PLEASE explicitly pass the -user, -pass, and -host parameters when calling this script!
let dbUser = process.env.PGUSERNAME || 'TCUser'
let dbPass = process.env.PGPASSWORD || 'sample_interchangePassword145'
let dbHost = '127.0.0.1:5432'
let noBuild = false

if (process.env.POSTGRES_PORT_5432_TCP_ADDR != null && process.env.POSTGRES_PORT_5432_TCP_PORT != null) {
  dbHost = `${process.env.POSTGRES_PORT_5432_TCP_ADDR}:${process.env.POSTGRES_PORT_5432_TCP_PORT}`
}

process.argv.forEach(a => {
  if (a.indexOf('-') !== 0) return
  const key = String(a.split('=')[0].replace(/-/gm, '')).toLowerCase().trim()
  const val = String(a.split('=')[1]).trim()
  switch (key) {
    case 'user': dbUser = val; break;
    case 'pass': dbPass = val; break;
    case 'host': dbHost = val; break;
    case 'nobuild': noBuild = Boolean(val); break;
  }

  // Prevent silent failure
  if (['user', 'pass', 'host'].indexOf(key) === -1) {
    throw new Error('FATAL! You need to specify the DB Username, DB Password, and DB Host when calling this script.')
    process.exit(3)
  }
})

const tomlConfig = fs.readFileSync(path.resolve(__dirname, 'config.toml'), 'utf8')
const data = toml.parse(tomlConfig)

if (noBuild === false) {
  // Array of filepaths with the TCxx.properties per agency
  data.agency.map((agency, i) => {
    doEverything(i !== 0, agency.id, agency.realtimeUrl, dbUser, dbPass, dbHost)
  })
}

// Array of agency IDs
const agencies = data.agency.map(agency => {
  return agencyIdFromNumber(agency.id)
}).join('\n')

console.log(String(agencies))
