require('../lib/ic-precheck')()
const { doEverything } = require('../lib/agency.properties')

doEverything(1, 'http://example.com/realtime', 'TCUser', '', '192.168.1.1')
doEverything(2, 'http://example.com/realtime', 'TCUser', '', '192.168.1.1')
doEverything(42, 'http://example.com/realtime', 'TCUser', '', '192.168.1.1')
