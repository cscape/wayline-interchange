// USAGE:
// node GetAgency.js [-options=value]
//
//    -id       the agency ID number (formatted as 01 or 1 works)
//    -get      property value in config.toml
//    -config   filepath to the config file (can be any name, just needs to be valid toml)
//
// EXAMPLE:
//  node GetAgency.js -id=1 -get=realtimeUrl -config=/home/cyberscape/Documents/wayline-interchange/config.toml
//  => http://127.0.0.1/realtime.vp

const fs = require('fs')
const path = require('path')
const toml = require('./toml/index')

const { agencyIdFromNumber } = require('./agency.properties')

const throwerr = d => {
  console.error('ERROR: ' + d)
  process.exit(Math.round(Math.random * 100) + 1)
}

let agencyId = ''
let getProp = ''
let configurl = '/usr/local/interchange/config.toml'

process.argv.forEach(a => {
  if (a.indexOf('-') !== 0) return
  const key = String(a.split('=')[0].replace(/-/gm, '')).toLowerCase().trim()
  const val = String(a.split('=')[1]).trim()
  switch (key) {
    case 'id': agencyId = agencyIdFromNumber(val); break;
    case 'get': getProp = val; break;
    case 'config': configurl = val; break;
  }
})

let printVal
let pathToConfig
let tomlConfig

try {
  pathToConfig = path.resolve(__dirname, configurl)
  tomlConfig = fs.readFileSync(pathToConfig, 'utf8')
} catch (err) {
  throwerr(`CONFIG PATH ${pathToConfig} IS NOT READABLE!!!`)
}


const data = toml.parse(tomlConfig)
const last = data.agency.map(a => ({...a, id: agencyIdFromNumber(a.id)})).filter(a => a.id === agencyId)[0]
if (last == null || last.length === 0) throwerr(`AGENCY ID ${agencyId} DOES NOT EXIST!!!`)
printVal = last[getProp]

if (printVal == null || printVal === '') throwerr(`PROPERTY VALUE ${getProp} IS INVALID!!!`)

console.log(printVal)
process.exit(0)
