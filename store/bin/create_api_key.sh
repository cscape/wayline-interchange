#!/usr/bin/env bash
echo 'THETRANSITCLOCK DOCKER: Create API key for $TRANSITCLOCK_AGENCY_PROPERTIES_FILE'

# Finds and replaces POSTGRES_PORT_5432_TCP_PORT + POSTGRES_PORT_5432_TCP_ADDR in properties file
find $TRANSITCLOCK_AGENCY_PROPERTIES_FILE -type f -exec sed -i s#POSTGRES_PORT_5432_TCP_ADDR#$POSTGRES_PORT_5432_TCP_ADDR#g {} \;
find $TRANSITCLOCK_AGENCY_PROPERTIES_FILE -type f -exec sed -i s#POSTGRES_PORT_5432_TCP_PORT#$POSTGRES_PORT_5432_TCP_PORT#g {} \;

java -jar CreateAPIKey.jar \
  -c $TRANSITCLOCK_AGENCY_PROPERTIES_FILE \
  -d "Connector" \
  -e "alex@example.com" \
  -name "Application" \
  -p "123456" \
  -u "https://wayline.co"
