#!/usr/bin/env bash

node /usr/local/interchange/node-build.js -user=$PGUSERNAME -pass=$PGPASSWORD -host=$POSTGRES_PORT_5432_TCP_ADDR | while read p; do
  echo "Building for agency ID $p ("$(GetAgency.sh -id=$p -get=name)")"
  AGENCYID=$p . ./create_tables.sh
  AGENCYID=$p AGENCY_GTFS_URL=$(GetAgency.sh -id=$p -get=gtfsUrl) TRANSITCLOCK_AGENCY_PROPERTIES_FILE=$(GetPropertiesFile.sh -id=$p -interchangedir=/usr/local/interchange/ic/) . ./import_gtfs.sh
  AGENCYID=$p TRANSITCLOCK_AGENCY_PROPERTIES_FILE=$(GetPropertiesFile.sh -id=$p -interchangedir=/usr/local/interchange/ic/) . create_api_key.sh
done
