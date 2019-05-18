require('./lib/ic-precheck')()
const fs = require('fs')
const path = require('path')
const toml = require('toml')

const { doEverything, agencyIdFromNumber } = require('./lib/agency.properties')

let dbUser = 'TCUser'
let dbPass = 'sample_interchangePassword145'
let dbHost = '127.0.0.1'

process.argv.forEach(a => {
  if (a.indexOf('-') !== 0) return
  const key = String(a.split('=')[0].replace(/-/gm, '')).toLowerCase().trim()
  const val = String(a.split('=')[1]).trim()
  switch (key) {
    case 'user': dbUser = val; break;
    case 'pass': dbPass = val; break;
    case 'host': dbHost = val; break;
  }
})

const tomlConfig = fs.readFileSync(path.resolve(__dirname, 'config.toml'), 'utf8')
const data = toml.parse(tomlConfig)

const files = data.agency.map((agency, i) =>
  doEverything(i !== 0, agency.id, agency.realtimeUrl, dbUser, dbPass, dbHost)
).join('\n')

const agencies = data.agency.map(agency => {
  const content = `${agency.name}\n${dbUser}\n${dbPass}\n${dbHost}`
  fs.writeFileSync(path.resolve(__dirname, `./ic/agencies/${agency.id}`), content, 'utf8')
  return agencyIdFromNumber(agency.id)
}).join('\n')

console.log(String(agencies))
