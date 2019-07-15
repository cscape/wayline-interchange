require('./ic-precheck')()
const fs = require('fs')
const path = require('path')
const toml = require('./toml/index')

const getConfigs = () => {
  const tomlConfig = fs.readFileSync(path.resolve(__dirname, 'config.toml'), 'utf8')
  const data = toml.parse(tomlConfig)
  return data
}

module.exports = getConfigs()
