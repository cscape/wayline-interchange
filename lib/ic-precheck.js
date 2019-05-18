const fs = require('fs')
const { join } = require('path')

// makes sure that /ic exists on the root folder
// or else bad things happen
module.exports = () => {
  const dir = join(process.cwd(), './ic')
  if (!fs.existsSync(dir)) fs.mkdirSync(dir)
}
