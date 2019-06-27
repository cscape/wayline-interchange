const fs = require('fs')
const path = require('path')

const { agencyIdFromNumber } = require('./agency.properties')

const throwerr = d => {
  console.error('ERROR: ' + d)
  process.exit(Math.round(Math.random * 100) + 1)
}

let apikey = ''
let agencyId = ''
let icdir = '/usr/local/interchange/ic'

process.argv.forEach(a => {
  if (a.indexOf('-') !== 0) return
  const key = String(a.split('=')[0].replace(/-/gm, '')).toLowerCase().trim()
  const val = String(a.split('=')[1]).trim()
  switch (key) {
    case 'id': agencyId = agencyIdFromNumber(val); break;
    case 'interchangedir': icdir = val; break;
    case 'apikey': apikey = String(val); break;
  }
})

const getProperties = aid => {
  const fileName = `TC${aid}.properties`
  const filePath = path.resolve(__dirname, icdir, fileName)
  if (!fs.existsSync(filePath)) {
    throwerr(`AGENCY ID ${aid} DOES NOT HAVE A VALID FILE AT ${filePath}!!!`)
  }
  return filePath
}

const loc = getProperties(agencyId)

let propertyFileContents = fs.readFileSync(loc, 'utf8')
propertyFileContents += `\ntransitclock.apikey=${apikey}\ntransitclock.apiKey=${apikey}`
fs.writeFileSync(loc, propertyFileContents, 'utf8')

console.log(loc)
process.exit(0)
