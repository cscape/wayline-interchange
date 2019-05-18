# Ubuntu 16.04 base image
FROM phusion/baseimage:0.11
LABEL maintainer="Cyberscape <info@cyberscape.co>"

ARG AGENCYID="CANNOT BE BLANK"
ARG AGENCYNAME="CANNOT BE BLANK"
ARG GTFS_URL="http://gohart.org/google/google_transit.zip"
ARG GTFSRTVEHICLEPOSITIONS="http://realtime.prod.obahart.org:8088/vehicle-positions"
ARG TRANSITCLOCK_GITHUB="https://github.com/TheTransitClock/transitime.git"
ARG TRANSITCLOCK_BRANCH="develop"
#ARG TRANSITCLOCK_PROPERTIES="config/transitclockConfig.xml"

# Set up env variables
  ENV AGENCYID ${AGENCYID}
  ENV AGENCYNAME ${AGENCYNAME}
  ENV GTFS_URL ${GTFS_URL}
  ENV GTFSRTVEHICLEPOSITIONS ${GTFSRTVEHICLEPOSITIONS}
  ENV TRANSITCLOCK_GITHUB ${TRANSITCLOCK_GITHUB}
  ENV TRANSITCLOCK_BRANCH ${TRANSITCLOCK_BRANCH}
  #ENV TRANSITCLOCK_PROPERTIES ${TRANSITCLOCK_PROPERTIES}

# Install necessary software
  RUN apt-get update
  RUN apt-get install -y postgresql-client
  RUN apt-get install -y git-core
  RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
  RUN apt-get install -y nodejs
  RUN wget http://stedolan.github.io/jq/download/linux64/jq
  RUN chmod +x ./jq
  RUN cp jq /usr/bin/

# Fetch latest TransitClock release and store the jars
  RUN curl -s https://api.github.com/repos/TheTransitClock/transitime/releases/latest | jq -r ".assets[].browser_download_url" | grep 'Core.jar\|api.war\|web.war\|CreateAPIKey.jar\|GtfsFileProcessor.jar\|CreateWebAgency.jar' | xargs -L1 wget

