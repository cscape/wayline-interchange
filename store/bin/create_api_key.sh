#!/usr/bin/env bash
echo 'THETRANSITCLOCK DOCKER: Create API key'

java \
  -jar CreateAPIKey.jar \
  -description "Connector" \
  -email "alex@example.com" \
  -name "Application" \
  -phone "123456" \
  -url "https://wayline.co"
