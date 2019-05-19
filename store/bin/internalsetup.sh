#!/usr/bin/env bash

echo "INTERCHANGE DOCKER: Starting internal setup"
export TRANSITCLOCK_ALLPROPERTIES=$(GetConfigs.sh -interchangedir=/usr/local/interchange/ic/)

node /usr/local/interchange/node-build.js -user=$PGUSERNAME -pass=$PGPASSWORD -host=$POSTGRES_PORT_5432_TCP_ADDR | while read p; do
  AGENCYID=$p
  AGENCYNAME=$(GetAgency.sh -id=$p -get=name)
  AGENCY_GTFS_URL=$(GetAgency.sh -id=$p -get=gtfsUrl)
  TRANSITCLOCK_AGENCY_PROPERTIES_FILE=$(GetPropertiesFile.sh -id=$p -interchangedir=/usr/local/interchange/ic/)
  FOR_TEXT="for agency ID $p ("$(GetAgency.sh -id=$p -get=name)")"

  echo "Building tables $FOR_TEXT"
  . ./create_tables.sh
  echo "Importing GTFS files $FOR_TEXT"
  . ./import_gtfs.sh
  echo "Creating Web Agency $FOR_TEXT"
  . ./create_webagency.sh
  echo "Finished building data $FOR_TEXT"
done

echo "Creating API key"
. ./create_api_key.sh
echo "Finished creating API key"

echo "Finished building for all agencies"
