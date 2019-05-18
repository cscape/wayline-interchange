const fs = require('fs')
const path = require('path')

const { agencyIdFromNumber } = require('./lib/agency.properties')

const throwerr = d => {
  console.error('ERROR: ' + d)
  process.exit(Math.round(Math.random * 100) + 1)
}

let agencyId = ''
let icdir = './ic/'

process.argv.forEach(a => {
  if (a.indexOf('-') !== 0) return
  const key = String(a.split('=')[0].replace(/-/gm, '')).toLowerCase().trim()
  const val = String(a.split('=')[1]).trim()
  switch (key) {
    case 'id': agencyId = agencyIdFromNumber(val); break;
    case 'interchangedir': icdir = val; break;
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

const printVal = getProperties(agencyId)

console.log(printVal)
process.exit(0)
