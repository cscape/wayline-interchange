#!/usr/bin/env bash

echo "INTERCHANGE DOCKER: Starting internal setup"

# Undefined variables ***WILL*** throw noticeable errors
# to avoid silent failure (which is extremely problematic)
set -u

cd /usr/local/interchange
echo "Clearing node_modules"
rm -rf node_modules/
rm -rf ic/
echo "Installing fresh NPM dependencies"
npm install
echo "Building agencies using buildscript and database host" $POSTGRES_PORT_5432_TCP_ADDR
node /usr/local/interchange/node-build.js -user="${PGUSERNAME}" -pass="${PGPASSWORD}" -host="${POSTGRES_PORT_5432_TCP_ADDR}"
echo "Finished building agencies"
export TRANSITCLOCK_ALLPROPERTIES=$(node /usr/local/interchange/lib/GetConfigs.js -interchangedir=/usr/local/interchange/ic/)
echo "TransitClock configFiles set to" $TRANSITCLOCK_ALLPROPERTIES

echo "Now running generator for all agencies"
node /usr/local/interchange/node-build.js -user="${PGUSERNAME}" -pass="${PGPASSWORD}" -host="${POSTGRES_PORT_5432_TCP_ADDR}" -nobuild=true | while read p
do
  export AGENCYID="${p}"
  export AGENCYNAME=$(node /usr/local/interchange/lib/GetAgency.js -id="${p}" -get=name -config=/usr/local/interchange/config.toml)
  export AGENCY_GTFS_URL=$(node /usr/local/interchange/lib/GetAgency.js -id="${p}" -get=gtfsUrl -config=/usr/local/interchange/config.toml)
  export TRANSITCLOCK_AGENCY_PROPERTIES_FILE=$(node /usr/local/interchange/lib/GetPropertiesFile.js -id="${p}" -interchangedir=/usr/local/interchange/ic/)
  export FOR_TEXT="for agency ID ${AGENCYID} ($(node /usr/local/interchange/lib/GetAgency.js -id="${p}" -get=name -config=/usr/local/interchange/config.toml))"

  echo "Building tables $FOR_TEXT"
  AGENCYID="${p}" . create_tables.sh

  echo "Importing GTFS files $FOR_TEXT"
  AGENCYID="${p}" AGENCY_GTFS_URL="${AGENCY_GTFS_URL}" TRANSITCLOCK_AGENCY_PROPERTIES_FILE="${TRANSITCLOCK_AGENCY_PROPERTIES_FILE}" . import_gtfs.sh

  echo "Creating API key $FOR_TEXT"
  TRANSITCLOCK_AGENCY_PROPERTIES_FILE="${TRANSITCLOCK_AGENCY_PROPERTIES_FILE}" . create_api_key.sh

  echo "Creating Web Agency $FOR_TEXT"
  AGENCYID="${p}" . create_webagency.sh

  echo "Finished building $FOR_TEXT"
done

echo "Internal Setup: Finished building for all agencies"
