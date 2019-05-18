const padLeft = require('./pad-left')
const path = require('path')
const { writeFileSync } = require('fs')

const struct = {
  'transitclock': {
    'core.agencyId': null, // UNIQUE PER AGENCY
    'avl.url': null, // GTFS Realtime vehicles feed
    'avl.gtfsRealtimeFeedURI': null,
    'db.dbUserName': null,
    'db.dbPassword': null,
    'db.dbName': null, // UNIQUE PER AGENCY
    'db.dbHost': null, // IP address or hostname

    'web.mapTileUrl': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    'modules.optionalModulesList': 'org.transitclock.avl.GtfsRealtimeModule',
    'autoBlockAssigner.autoAssignerEnabled': true,
    'autoBlockAssigner.allowableEarlySeconds': 1200, // 20 minutes early or late
    'autoBlockAssigner.allowableLateSeconds': 1200,
    'db.dbType': 'mysql',
    'hibernate.configFile': 'hibernate.cfg.xml'
  }
}

const generateProperties = ({ transitclock }) => {
  const agencyId = transitclock['core.agencyId']
  const content = []
  for (let i in transitclock) {
    // Example: transitclock.core.agencyId=01
    if (transitclock[i] == null) continue // null property value
    const val = String(transitclock[i]).trim()
    content.push(`transitclock.${i}=${val}`)
  }
  const final = content.join('\n')
  return [ final, agencyId ]
}

const agencyIdFromNumber = agencyId => padLeft(String(agencyId).replace(/[^0-9]/gm, ''), 2, '0')

const dbNameFromId = agencyId => `TC_AGENCY_${agencyId}`

/**
 * Generates a struct used for creating the properties file
 * @param {number} aId
 * @param {string} realtimeUrl
 * @param {string} dbUser
 * @param {string} dbPass
 * @param {string} dbHost
 */
const generateStruct = (aId, realtimeUrl, dbUser = 'TCUser', dbPass = '', dbHost = '127.0.0.1') => {
  const { transitclock } = struct
  const agencyId = agencyIdFromNumber(aId)
  transitclock['core.agencyId'] = agencyId
  transitclock['avl.url'] = transitclock['avl.gtfsRealtimeFeedURI'] = realtimeUrl
  transitclock['db.dbName'] = dbNameFromId(agencyId)
  transitclock['db.dbUserName'] = dbUser
  transitclock['db.dbPassword'] = dbPass
  transitclock['db.dbHost'] = dbHost
  return { transitclock }
}

const storeProperties = (content, agencyId) => {
  const fileName = `TC${agencyId}.properties`
  const filePath = path.resolve(__dirname, '../ic/', fileName)
  writeFileSync(filePath, content, 'utf8')
  return filePath
}

const doEverything = (...a) => storeProperties(...generateProperties(generateStruct(...a)))

module.exports = { doEverything, generateStruct, generateProperties }
