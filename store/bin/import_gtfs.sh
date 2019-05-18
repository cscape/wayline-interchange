#!/usr/bin/env bash

# Need to have AGENCY_GTFS_URL, AGENCYID, PGUSERNAME, PGPASSWORD, TRANSITCLOCK_AGENCY_PROPERTIES_FILE set

echo 'THETRANSITCLOCK DOCKER: Import GTFS file.'

# This is to substitute into config file the env values.
find /usr/local/transitclock/config/ -type f -exec sed -i s#"POSTGRES_PORT_5432_TCP_ADDR"#"$POSTGRES_PORT_5432_TCP_ADDR"#g {} \;
find /usr/local/transitclock/config/ -type f -exec sed -i s#"$POSTGRES_PORT_5432_TCP_PORT"#"$$POSTGRES_PORT_5432_TCP_PORT"#g {} \;
find /usr/local/transitclock/config/ -type f -exec sed -i s#"PGPASSWORD"#"$PGPASSWORD"#g {} \;

java -Xmx1024M -Dtransitclock.core.agencyId=$AGENCYID -Dtransitclock.configFiles=/usr/local/transitclock/config/transitclockConfig.xml -Dtransitclock.logging.dir=/usr/local/transitclock/logs/ -Dlogback.configurationFile=$TRANSITCLOCK_CORE/transitclock/src/main/resouces/logbackGtfs.xml -cp /usr/local/transitclock/Core.jar org.transitclock.applications.GtfsFileProcessor -gtfsZipFileName /usr/local/transitclock/data/gtfs.zip -gtfsUrl $GTFS_URL  -maxTravelTimeSegmentLength 400

java -jar \
	GtfsFileProcessor.jar
	-Dtransitclock.logging.dir=/tmp \
	-c $TRANSITCLOCK_AGENCY_PROPERTIES_FILE \
	-storeNewRevs \
	-skipDeleteRevs \
	-gtfsUrl $AGENCY_GTFS_URL

psql \
	-h "$POSTGRES_PORT_5432_TCP_ADDR" \
	-p "$$POSTGRES_PORT_5432_TCP_PORT" \
	-U $PGUSERNAME \
	-d TC_AGENCY_$AGENCYID \
	-c "update activerevisions set configrev=0 where configrev = -1; update activerevisions set traveltimesrev=0 where traveltimesrev = -1;"
