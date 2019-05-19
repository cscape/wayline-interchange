#!/usr/bin/env bash
echo 'THETRANSITCLOCK DOCKER: Start TheTransitClock.'
export TRANSITCLOCK_ALLPROPERTIES=$(GetConfigs.sh -interchangedir=/usr/local/interchange/ic/)

rmiregistry &

#set the API as an environment variable so we can set in JSP of template/includes.jsp in the transitime webapp
export APIKEY=$(get_api_key.sh)

# make it so we can also access as a system property in the JSP
export JAVA_OPTS="$JAVA_OPTS -Dtransitclock.apikey=$(get_api_key.sh) -Dtransitclock.configFiles=$TRANSITCLOCK_ALLPROPERTIES"

nohup java \
  -server \
  -Duser.timezone=EST \
  -Dtransitclock.configFiles=$TRANSITCLOCK_ALLPROPERTIES \
  -Dtransitclock.logging.dir=/usr/local/transitclock/logs/ \
  -jar /usr/local/transitclock/Core.jar -configRev 0 > /usr/local/transitclock/logs/output.txt &

/usr/local/tomcat/bin/startup.sh
tail -f /dev/null
