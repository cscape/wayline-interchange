#!/usr/bin/env bash
echo 'THETRANSITCLOCK DOCKER: Create API key for $TRANSITCLOCK_AGENCY_PROPERTIES_FILE'

java -jar CreateAPIKey.jar \
  -config $TRANSITCLOCK_AGENCY_PROPERTIES_FILE \
  -description "Connector" \
  -email "alex@example.com" \
  -name "Application" \
  -phone "123456" \
  -url "https://wayline.co"
