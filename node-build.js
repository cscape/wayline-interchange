require('./lib/ic-precheck')()
const fs = require('fs')
const path = require('path')
const toml = require('./lib/toml/index')

const { doEverything, agencyIdFromNumber } = require('./lib/agency.properties')

// Setting defaults,
// PLEASE explicitly pass the -user, -pass, and -host parameters when calling this script!
let dbUser = process.env.PGUSERNAME || 'ERROR_USERNAME_NOT_SET'
let dbPass = process.env.PGPASSWORD || 'ERROR_PASSWORD_NOT_SET'
let dbHost = process.env.POSTGRES_PORT_5432_TCP_ADDR || 'ERROR_HOST_NOT_SET'
let noBuild = false

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
process.exit(0)
