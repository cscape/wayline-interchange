const fs = require('fs')
const { join } = require('path')

// makes sure that /ic exists on the root folder
// or else bad things happen
module.exports = () => {
  ;[
    '/usr/local/interchange/ic'
  ].forEach(d => !fs.existsSync(d) ? fs.mkdirSync(d) : 0)
}
