export PGPASSWORD=interchange_dbPassword12345
export PGUSERNAME=TransitClockUser

docker stop icdb && docker stop icserver
docker rm icdb && docker rm icserver

# Builds image from Dockerfile
docker build --no-cache -t transitclock-server .

# Initiates the database container
docker run \
  --name icdb \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD=$PGPASSWORD \
  -e POSTGRES_USER=$PGUSERNAME \
  -d postgres:9.6.12

# CONTAINER: 	icserver
# DESCRIPTION:	Check that the database is up
docker run \
  --name icserver \
  --rm \
  --link icdb:postgres \
  -e PGPASSWORD=$PGPASSWORD \
  -e PGUSERNAME=$PGUSERNAME
  transitclock-server \
  check_db_up.sh

# Internal (container-scope) setup
docker run \
  --name icserver \
  --rm \
  --link icdb:postgres \
  -e PGPASSWORD=$PGPASSWORD \
  -e PGUSERNAME=$PGUSERNAME \
  -e AGENCYID=$p \
  transitclock-server \
  internalsetup.sh

# CONTAINER: 	icserver
# DESCRIPTION:	Create the agency
docker run \
  --name icserver \
  --rm \
  --link icdb:postgres \
  -e PGPASSWORD=$PGPASSWORD \
  -e PGUSERNAME=$PGUSERNAME
  transitclock-server \
  create_webagency.sh

# CONTAINER: 	icserver
# DESCRIPTION:	Start the server
docker run \
  --name icserver \
  --rm \
  --link icdb:postgres \
  -e PGPASSWORD=$PGPASSWORD \
  -e PGUSERNAME=$PGUSERNAME
  -p 3020:8080 \
  transitclock-server \
  start_transitclock.sh
