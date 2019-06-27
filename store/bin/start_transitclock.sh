#!/usr/bin/env bash
echo 'THETRANSITCLOCK DOCKER: Start TheTransitClock.'

echo "Initiating RMI Registry"
rmiregistry &

export CATALINA_OPTS="$CATALINA_OPTS -Dtransitclock.configFiles=$(node /usr/local/interchange/lib/GetPropertiesFile.js -interchangedir=/usr/local/interchange/ic/)"

echo "Starting Tomcat"
/usr/local/tomcat/bin/startup.sh

echo "Fetching agencies"
node /usr/local/interchange/node-build.js -user="${PGUSERNAME}" -pass="${PGPASSWORD}" -host="${POSTGRES_PORT_5432_TCP_ADDR}" -nobuild=true | while read agencyid
do
  echo "Starting TheTransitClock for Agency ${agencyid}"
  export APIKEY=$(AGENCYID="${agencyid}" . get_api_key.sh)
  AGENCYID=$agencyid APIKEY=$APIKEY nohup java \
    -Xss12m \
    -Dtransitclock.configFiles=$(node /usr/local/interchange/lib/GetPropertiesFile.js -id="${agencyid}" -interchangedir=/usr/local/interchange/ic/) \
    -Dtransitclock.apikey="${APIKEY}" \
    -Dtransitclock.apiKey="${APIKEY}" \
    -Dtransitclock.core.agencyId="${agencyid}" \
    -Duser.timezone=EST \
    -Dtransitclock.logging.dir=/usr/local/transitclock/logs/ \
    -jar /usr/local/transitclock/Core.jar -configRev 0 > "/usr/local/transitclock/logs/output_agency${agencyid}.txt" &

  echo "TheTransitClock has been launched for Agency ${agencyid}."
done

tail -f /dev/null
