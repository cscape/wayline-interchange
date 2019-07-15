const padLeft = require('./pad-left')
const path = require('path')
const { writeFileSync } = require('fs')

const struct = {
  'transitclock': {
    'core.agencyId': null, // UNIQUE PER AGENCY
    'avl.url': null, // GTFS Realtime vehicles feed
    'avl.gtfsRealtimeFeedURI': null,
    'avl.feedPollingRateSecs': 15,
    'db.dbUserName': null,
    'db.dbPassword': null,
    'db.dbName': null, // UNIQUE PER AGENCY
    'db.dbHost': null, // IP address or hostname

    'web.mapTileUrl': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    'web.mapTileCopyright': 'OpenStreetMap',
    'modules.optionalModulesList': 'org.transitclock.avl.GtfsRealtimeModule',
    'autoBlockAssigner.ignoreAvlAssignments': false,
    'autoBlockAssigner.autoAssignerEnabled': true,
    'autoBlockAssigner.allowableEarlySeconds': 1200, // 20 minutes early or late
    'autoBlockAssigner.allowableLateSeconds': 1200,
    'db.dbType': 'postgresql',
    'hibernate.configFile': '/usr/local/transitclock/config/hibernate.cfg.xml'
  }
}

const generateProperties = ({ transitclock }, isSecondary = true) => {
  const agencyId = transitclock['core.agencyId']
  const content = []
  for (let i in transitclock) {
    // Example: transitclock.core.agencyId=01
    if (transitclock[i] == null) continue // null property value
    const val = String(transitclock[i]).trim()
    content.push(`transitclock.${i}=${val}`)
  }
  let final = content.join('\n')
  if (isSecondary === true) final += `\ntransitclock.rmi.secondaryRmiPort=0`
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
const generateStruct = (aId, realtimeUrl, dbUser, dbPass, dbHost) => {
  let { transitclock } = JSON.parse(JSON.stringify(struct))
  const agencyId = agencyIdFromNumber(aId)
  transitclock['core.agencyId'] = agencyId
  transitclock['avl.url'] = realtimeUrl
  transitclock['avl.gtfsRealtimeFeedURI'] = realtimeUrl
  transitclock['db.dbName'] = dbNameFromId(agencyId)
  transitclock['db.dbUserName'] = dbUser
  transitclock['db.dbPassword'] = dbPass
  transitclock['db.dbHost'] = dbHost
  transitclock['hibernate.connection.url'] = `jdbc:postgresql://${dbHost}/${dbNameFromId(agencyId)}`
  return { transitclock }
}

const storeProperties = (content, agencyId) => {
  const fileName = `TC${agencyId}.properties`
  const filePath = path.resolve('/usr/local/interchange/ic/', fileName)
  writeFileSync(filePath, content, 'utf8')
  return filePath
}

const WrapAroundForAPIKey = (content, agencyId, apikey) => {
  if (apikey == null) return [content, agencyId]
  content += `\ntransitclock.apikey=${apikey}`
  return [content, agencyId]
}

const doEverything = (isSecondary = false, aId, realtimeUrl, dbUser, dbPass, dbHost, apiKey = null) => storeProperties(
  ...WrapAroundForAPIKey(
    ...generateProperties(
      generateStruct(aId, realtimeUrl, dbUser, dbPass, dbHost),
      isSecondary
    ),
    apiKey
  )
)

module.exports = { doEverything, generateStruct, generateProperties, agencyIdFromNumber }
