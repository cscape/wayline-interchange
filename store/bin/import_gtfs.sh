#!/usr/bin/env bash

# Need to have AGENCY_GTFS_URL, AGENCYID, PGUSERNAME, PGPASSWORD, TRANSITCLOCK_AGENCY_PROPERTIES_FILE set

echo 'THETRANSITCLOCK DOCKER: Import GTFS file.'

# No silent failure
set -u

java \
  -Dtransitclock.core.agencyId="${AGENCYID}" \
  -Dtransitclock.configFiles=$TRANSITCLOCK_AGENCY_PROPERTIES_FILE \
  -Dtransitclock.logging.dir=/usr/local/transitclock/logs/ \
  -Dtransitclock.db.dbName="TC_AGENCY_${AGENCYID}" \
  -Dtransitclock.hibernate.configFile=/usr/local/transitclock/config/hibernate.cfg.xml \
  -Dtransitclock.db.dbHost=$POSTGRES_PORT_5432_TCP_ADDR:$POSTGRES_PORT_5432_TCP_PORT \
  -Dtransitclock.db.dbUserName=$PGUSERNAME \
  -Dtransitclock.db.dbPassword=$PGPASSWORD \
  -Dtransitclock.db.dbType=postgresql \
  -Dhibernate.connection.username="${PGUSERNAME}" \
  -Dhibernate.connection.password="${PGPASSWORD}" \
  -cp /usr/local/transitclock/Core.jar \
  org.transitclock.applications.GtfsFileProcessor \
  -c "${TRANSITCLOCK_AGENCY_PROPERTIES_FILE}" \
  -storeNewRevs \
  -skipDeleteRevs \
  -gtfsUrl "${AGENCY_GTFS_URL}"

psql \
  -h "${POSTGRES_PORT_5432_TCP_ADDR}" \
  -p "${POSTGRES_PORT_5432_TCP_PORT}" \
  -U "${PGUSERNAME}" \
  -d "TC_AGENCY_${AGENCYID}" \
  -c "update activerevisions set configrev=0 where configrev = -1; update activerevisions set traveltimesrev=0 where traveltimesrev = -1;"
