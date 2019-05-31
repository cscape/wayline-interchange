# Ubuntu 16.04 base image
FROM phusion/baseimage:0.11
LABEL description="Sets up a Wayline Interchange server using TheTransitClock"
LABEL maintainer="Cyberscape <info@cyberscape.co>"

ARG TRANSITCLOCK_GITHUB="https://github.com/TheTransitClock/transitime.git"
ARG TRANSITCLOCK_BRANCH="develop"

# Set up env variables
  ENV TRANSITCLOCK_GITHUB ${TRANSITCLOCK_GITHUB}
  ENV TRANSITCLOCK_BRANCH ${TRANSITCLOCK_BRANCH}

# Install necessary software
  RUN apt-get update
  RUN apt-get install -y postgresql-client
  RUN apt-get install -y wget
  RUN apt-get install -y openjdk-8-jdk
  RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
  RUN apt-get install -y nodejs
  RUN wget http://stedolan.github.io/jq/download/linux64/jq
  RUN chmod +x ./jq
  RUN cp jq /usr/bin/

# TOMCAT CONFIG
  ENV CATALINA_HOME /usr/local/tomcat
  ENV PATH $CATALINA_HOME/bin:$PATH
  RUN mkdir -p "$CATALINA_HOME"
  WORKDIR $CATALINA_HOME

  ENV TOMCAT_MAJOR 8
  ENV TOMCAT_VERSION 8.5.40
  ENV TOMCAT_TGZ_URL https://www-us.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

  RUN set -x \
    && curl -fsSL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz \
    && tar -xvf tomcat.tar.gz --strip-components=1 \
    && rm bin/*.bat \
    && rm tomcat.tar.gz*

# Make directories transitclock needs to run
  WORKDIR /
  RUN mkdir /usr/local/transitclock
  RUN mkdir /usr/local/transitclock/db
  RUN mkdir /usr/local/transitclock/config
  RUN mkdir /usr/local/transitclock/logs
  RUN mkdir /usr/local/transitclock/cache
  RUN mkdir /usr/local/transitclock/data

# Fetch latest TransitClock release and store the jars
  WORKDIR /usr/local/transitclock
#  RUN curl -s https://api.github.com/repos/TheTransitClock/transitime/releases/latest | jq -r ".assets[].browser_download_url" | grep 'Core.jar\|api.war\|web.war\|CreateAPIKey.jar\|GtfsFileProcessor.jar\|CreateWebAgency.jar' | xargs -L1 wget
  RUN wget http://192.168.29.200:5000/Core.jar
  RUN wget http://192.168.29.200:5000/api.war
  RUN wget http://192.168.29.200:5000/web.war
  RUN wget http://192.168.29.200:5000/CreateAPIKey.jar
  RUN wget http://192.168.29.200:5000/GtfsFileProcessor.jar
  RUN wget http://192.168.29.200:5000/CreateWebAgency.jar

# Move API + Web apps which talks to core
  RUN mv api.war  /usr/local/tomcat/webapps
  RUN mv web.war  /usr/local/tomcat/webapps

# Required to start TransitClock.
  ADD store/bin/check_db_up.sh /usr/local/transitclock/bin/check_db_up.sh
  ADD store/bin/generate_sql.sh /usr/local/transitclock/bin/generate_sql.sh
  ADD store/bin/create_tables.sh /usr/local/transitclock/bin/create_tables.sh
  ADD store/bin/create_api_key.sh /usr/local/transitclock/bin/create_api_key.sh
  ADD store/bin/create_webagency.sh /usr/local/transitclock/bin/create_webagency.sh
  ADD store/bin/import_gtfs.sh /usr/local/transitclock/bin/import_gtfs.sh
  ADD store/bin/start_transitclock.sh /usr/local/transitclock/bin/start_transitclock.sh
  ADD store/bin/get_api_key.sh /usr/local/transitclock/bin/get_api_key.sh
  ADD store/bin/update_traveltimes.sh /usr/local/transitclock/bin/update_traveltimes.sh
  ADD store/bin/internalsetup.sh /usr/local/transitclock/bin/internalsetup.sh
  ENV PATH="/usr/local/transitclock/bin:${PATH}"
  ADD store/hibernate.cfg.xml /usr/local/transitclock/config/hibernate.cfg.xml
  ADD store/named_queries.hbm.xml /usr/local/transitclock/config/named_queries.hbm.xml

# Add permissions to transitclock/bin scripts
  RUN sed -i 's/\r//' /usr/local/transitclock/bin/*.sh
  RUN chmod 777 /usr/local/transitclock/bin/*.sh

# Required for Wayline Interchange tools
  WORKDIR /
  RUN mkdir /usr/local/interchange
  ADD . /usr/local/interchange
  WORKDIR /usr/local/interchange
  RUN npm install
  RUN sed -i 's/\r//' /usr/local/interchange/*.sh
  RUN chmod 777 /usr/local/interchange/*.sh
  ENV PATH="${PATH}:/usr/local/interchange"
  WORKDIR /usr/local/transitclock

# Open port where the Tomcat server is hosted on
  EXPOSE 8080

# Since TheTransitClock shell scripts were all added to PATH, this can be called like so
  CMD ["/start_transitclock.sh"]
