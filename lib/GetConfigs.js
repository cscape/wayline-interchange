const fs = require('fs')
const path = require('path')

let configUrl = '../ic/'

process.argv.forEach(a => {
  if (a.indexOf('-') !== 0) return
  const key = String(a.split('=')[0].replace(/-/gm, '')).toLowerCase().trim()
  const val = String(a.split('=')[1]).trim()
  switch (key) {
    case 'interchangedir': configUrl = val; break;
  }
})

const path2Search = path.resolve(__dirname, configUrl)

let printVal = fs
  .readdirSync(path2Search, 'utf8')
  .filter(f => f.indexOf('.properties') >= 1)
  .map(f => path.resolve(__dirname, configUrl, f))
  .join(';')

console.log(printVal)
process.exit(0)
