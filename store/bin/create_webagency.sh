#!/usr/bin/env bash
echo 'THETRANSITCLOCK DOCKER: Create WebAgency for agency $AGENCYID.'

# Requires AGENCYID, TRANSITCLOCK_ALLPROPERTIES, PGUSERNAME, PGPASSWORD

# No silent failure
set -u

java \
  -Dtransitclock.db.dbName="TC_AGENCY_${AGENCYID}" \
  -Dtransitclock.hibernate.configFile=/usr/local/transitclock/config/hibernate.cfg.xml \
  -Dtransitclock.db.dbHost="${POSTGRES_PORT_5432_TCP_ADDR}:${POSTGRES_PORT_5432_TCP_PORT}" \
  -Dtransitclock.db.dbUserName=$PGUSERNAME \
  -Dtransitclock.db.dbPassword=$PGPASSWORD \
  -Dtransitclock.db.dbType=postgresql \
  -Dhibernate.connection.username="${PGUSERNAME}" \
  -Dhibernate.connection.password="${PGPASSWORD}" \
  -cp /usr/local/transitclock/Core.jar org.transitclock.db.webstructs.WebAgency \
  "${AGENCYID}" \
  127.0.0.1 \
  "TC_AGENCY_${AGENCYID}" \
  postgresql \
  "${POSTGRES_PORT_5432_TCP_ADDR}" \
  "${PGUSERNAME}" \
  "${PGPASSWORD}"
