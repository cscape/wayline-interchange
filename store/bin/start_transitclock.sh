#!/usr/bin/env bash
echo 'THETRANSITCLOCK DOCKER: Start TheTransitClock.'

# Crash on undefined variables
set -u

#export TRANSITCLOCK_ALLPROPERTIES="$(node /usr/local/interchange/lib/GetConfigs.js -interchangedir=/usr/local/interchange/ic/)"
#echo "TheTransitClock configFiles set to ${TRANSITCLOCK_ALLPROPERTIES}"
#sleep 2
echo "Initiating RMI Registry"
rmiregistry &

#sleep 2
#echo "Loading API Key into environment"
#set the API as an environment variable so we can set in JSP of template/includes.jsp in the transitime webapp
#export APIKEY="$(get_api_key.sh)"
#echo "API Key loaded into environment as ${APIKEY}"

#sleep 2
#echo "Settings Java environment options"
# make it so we can also access as a system property in the JSP
#export JAVA_OPTS="-Dtransitclock.apikey=${APIKEY} -Dtransitclock.configFiles=$TRANSITCLOCK_ALLPROPERTIES"
#echo "Java environment options set as: ${JAVA_OPTS}"

echo "Fetching agencies"
node /usr/local/interchange/node-build.js -user="${PGUSERNAME}" -pass="${PGPASSWORD}" -host="${POSTGRES_PORT_5432_TCP_ADDR}:${POSTGRES_PORT_5432_TCP_PORT}" -nobuild=true | while read agencyid
do
  echo "Starting TheTransitClock for Agency ${agencyid}"
  export APIKEY=$(AGENCYID="${agencyid}" . get_api_key.sh)
  export JAVA_OPTS="-Dtransitclock.apiKey=${APIKEY} -Dtransitclock.configFiles=$(node /usr/local/interchange/lib/GetPropertiesFile.js -id="${agencyid}" -interchangedir=/usr/local/interchange/ic/)"
  AGENCYID=$agencyid APIKEY=$APIKEY JAVA_OPTS="${JAVA_OPTS}" nohup java \
    -Xss12m \
    -Dtransitclock.apiKey=$APIKEY \
    -Dtransitclock.core.agencyId=$agencyid \
    -Duser.timezone=EST \
    -Dtransitclock.logging.dir=/usr/local/transitclock/logs/ \
    -jar /usr/local/transitclock/Core.jar -configRev 0 > "/usr/local/transitclock/logs/output_agency${agencyid}.txt" &

  echo "TheTransitClock has been launched for Agency ${agencyid}."
done

/usr/local/tomcat/bin/startup.sh
tail -f /dev/null
