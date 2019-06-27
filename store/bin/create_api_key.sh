#!/usr/bin/env bash
echo 'INTERCHANGE DOCKER: Creating API key'

# Supplying a config file is practically useless since
# it's only read into memory and then discarded by the Jar.

java \
  -cp /usr/local/transitclock/Core.jar \
  org.transitclock.applications.CreateAPIKey \
  -c "${TRANSITCLOCK_AGENCY_PROPERTIES_FILE}" \
  -d "Connector" \
  -e "alex@example.com" \
  -n "Application" \
  -p "123456" \
  -u "https://wayline.co"

echo "Appending API key to config for agency ${AGENCYID}"
node /usr/local/interchange/lib/AppendKeyToConfig.js -id="${AGENCYID}" -apikey=$(AGENCYID=$AGENCYID . get_api_key.sh)
