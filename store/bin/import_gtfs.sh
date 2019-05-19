#!/usr/bin/env bash

# Need to have AGENCY_GTFS_URL, AGENCYID, PGUSERNAME, PGPASSWORD, TRANSITCLOCK_AGENCY_PROPERTIES_FILE set

echo 'THETRANSITCLOCK DOCKER: Import GTFS file.'

java -jar \
	GtfsFileProcessor.jar \
  -Dtransitclock.configFiles=$TRANSITCLOCK_ALLPROPERTIES \
	-Dtransitclock.logging.dir=/tmp \
	-c $TRANSITCLOCK_AGENCY_PROPERTIES_FILE \
	-storeNewRevs \
	-skipDeleteRevs \
	-gtfsUrl $AGENCY_GTFS_URL

psql \
	-h "$POSTGRES_PORT_5432_TCP_ADDR" \
	-p "$POSTGRES_PORT_5432_TCP_PORT" \
	-U $PGUSERNAME \
	-d TC_AGENCY_$AGENCYID \
	-c "update activerevisions set configrev=0 where configrev = -1; update activerevisions set traveltimesrev=0 where traveltimesrev = -1;"
