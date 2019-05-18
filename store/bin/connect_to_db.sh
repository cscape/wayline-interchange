#!/usr/bin/env bash

# Remember to set PGPASSWORD!
# AGENCYID *must* be set like "01" for this to connect to the TC_AGENCY_01 database

echo 'THETRANSITCLOCK DOCKER: Connecting to database for $AGENCYID.'
psql \
  -h "$POSTGRES_PORT_5432_TCP_ADDR" \
  -p "$POSTGRES_POST_5432_TCP_PORT" \
  -U $PGUSERNAME \
  -d TC_AGENCY_$AGENCYID
