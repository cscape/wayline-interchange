#!/usr/bin/env bash

# Remember to set the PGPASSWORD env variable for psql to connect
# correctly

echo 'THETRANSITCLOCK DOCKER: Check if database is runnng.'
RET=1
SUCCESS=0
until [ "$RET" -eq "$SUCCESS" ]; do

  psql \
    -h "$POSTGRES_PORT_5432_TCP_ADDR" \
    -p "$POSTGRES_PORT_5432_TCP_PORT" \
    -U $PGUSERNAME \
    -c "SELECT EXTRACT(DAY FROM TIMESTAMP '2001-02-16 20:38:40');"

  RET="$?"

  if [ "$RET" -ne "$SUCCESS" ]
    then
      echo "Database is not running. Trying again..."
      sleep 5
  fi
done
echo 'THETRANSITCLOCK DOCKER: Database is now running.'
