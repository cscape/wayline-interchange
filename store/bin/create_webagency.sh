#!/usr/bin/env bash
echo 'THETRANSITCLOCK DOCKER: Create WebAgency for agency $AGENCYID.'

# Requires AGENCYID, TRANSITCLOCK_ALLPROPERTIES, PGUSERNAME, PGPASSWORD

# if mysql doesn't work, try putting postgresql
java \
  -Dtransitclock.configFiles=$TRANSITCLOCK_ALLPROPERTIES \
  -Dtransitclock.hibernate.configFile=/usr/local/transitclock/config/hibernate.cfg.xml \
  -jar CreateWebAgency.jar $AGENCYID localhost TC_AGENCY_$AGENCYID mysql $POSTGRES_PORT_5432_TCP_ADDR:$POSTGRES_PORT_5432_TCP_PORT $PGUSERNAME $PGPASSWORD
