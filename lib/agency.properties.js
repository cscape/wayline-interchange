const struct = {
  transitclock: {
    'core.agencyId': String, // UNIQUE PER AGENCY
    'avl.url': String, // GTFS Realtime vehicles feed
    'db.dbUserName': String,
    'db.dbPassword': String,
    'db.dbName': String, // UNIQUE PER AGENCY
    'db.dbHost': String, // IP address or hostname

    'core.configRevStr': 0,
    'web.mapTileUrl': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    'modules.optionalModulesList': 'org.transitclock.avl.GtfsRealtimeModule',
    'autoBlockAssigner.autoAssignerEnabled': true,
    'autoBlockAssigner.allowableEarlySeconds': 1200, // 20 minutes early or late
    'autoBlockAssigner.allowableLateSeconds': 1200,
    'db.dbType': 'mysql',
    'hibernate.configFile': 'hibernate.cfg.xml'
  }
}
