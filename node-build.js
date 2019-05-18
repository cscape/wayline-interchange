require('./lib/ic-precheck')()
const fs = require('fs')
const path = require('path')
const toml = require('toml')

const { doEverything } = require('./lib/agency.properties')

const tomlConfig = fs.readFileSync(path.resolve(__dirname, 'config.toml'), 'utf8')
const data = toml.parse(tomlConfig)

const files = data.agency.map(agency =>
  doEverything(agency.id, agency.realtimeUrl, agency.dbUser, agency.dbPassword, agency.dbHost)
).join('\n')

const agencies = data.agency.map(agency => {
  const content = `${agency.name}\n${agency.dbUser}\n${agency.dbPassword}\n${agency.dbHost}`
  fs.writeFileSync(path.resolve(__dirname, `./ic/agencies/${agency.id}`), content, 'utf8')
}).join('\n')

process.stdout.write(String(files))
