#!/usr/bin/env bash
echo 'THETRANSITCLOCK DOCKER: Create WebAgency for agency $AGENCYID.'

# Requires AGENCYID, TRANSITCLOCK_ALLPROPERTIES, PGUSERNAME, PGPASSWORD

# No silent failure
set -u

java \
  -Dhibernate.connection.url="jdbc:postgresql://${POSTGRES_PORT_5432_TCP_ADDR}:${POSTGRES_PORT_5432_TCP_PORT}/TC_AGENCY_${AGENCYID}" \
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
