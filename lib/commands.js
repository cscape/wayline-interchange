const StructsDB = `java -cp /usr/local/transitclock/Core.jar org.transitclock.applications.SchemaGenerator` +
  ` -p org.transitclock.db.structs` +
  ` -o /usr/local/transitclock/db`

const WebStructsDB = `java -cp /usr/local/transitclock/Core.jar org.transitclock.applications.SchemaGenerator` +
  ` -p org.transitclock.db.webstructs` +
  ` -o /usr/local/transitclock/db`

const CreateDB = (agencyId, pguser, pgaddr, pgport) => `createdb` +
` -h "${pgaddr}"` +
` -p "${pgport}"` +
` -U "${pguser}"` +
` "TC_AGENCY_${agencyId}"`

const PopulateStructsDB = (agencyId, pguser, pgaddr, pgport) => `psql` +
` -h "${pgaddr}"` +
` -p "${pgport}"` +
` -U "${pguser}"` +
` -d "TC_AGENCY_${agencyId}"` +
` -f /usr/local/transitclock/db/ddl_postgres_org_transitclock_db_structs.sql`

const PopulateWebStructsDB = (agencyId, pguser, pgaddr, pgport) => `psql` +
` -h "${pgaddr}"` +
` -p "${pgport}"` +
` -U "${pguser}"` +
` -d "TC_AGENCY_${agencyId}"` +
` -f /usr/local/transitclock/db/ddl_postgres_org_transitclock_db_webstructs.sql`

const CreateTablesForSingleAgency = (agencyId, pguser, pgaddr, pgport) => {
  return [
    StructsDB,
    WebStructsDB,
    CreateDB(agencyId, pguser, pgaddr, pgport),
    PopulateStructsDB(agencyId, pguser, pgaddr, pgport),
    PopulateWebStructsDB(agencyId, pguser, pgaddr, pgport)
  ]
}

const LoadGTFS = (propertiesFile, GtfsURL) => `java` +
` -Dtransitclock.logging.dir=/tmp` +
` -cp /usr/local/transitclock/Core.jar org.transitclock.applications.GtfsFileProcessor` +
` -c "${propertiesFile}"` +
` -storeNewRevs` +
` -skipDeleteRevs` +
` -gtfsUrl "${GtfsURL}"`

const PopulateGTFSDB = (agencyId, pguser, pgaddr, pgport) => `psql` +
` -h "${pgaddr}"` +
` -p "${pgport}"` +
` -U "${pguser}"` +
` -d "TC_AGENCY_${agencyId}"` +
` -c "update activerevisions set configrev=0 where configrev = -1; update activerevisions set traveltimesrev=0 where traveltimesrev = -1;"`

const ImportGTFSForSingleAgency = (agencyId, propertiesFile, GtfsURL, pguser, pgaddr, pgport) => {
  return [
    LoadGTFS(propertiesFile, GtfsURL),
    PopulateGTFSDB(agencyId, pguser, pgaddr, pgport)
  ]
}

const CreateSingleWebAgency = (agencyId, pguser, pgaddr, pgport, pgpass = process.env.PGPASSWORD) => `java` +
  ` -Dhibernate.connection.url="jdbc:postgresql://${pgaddr}:${pgport}/TC_AGENCY_${agencyId}"` +
  ` -Dhibernate.connection.username="${pguser}"` +
  ` -Dhibernate.connection.password="${pgpass}"` +
  ` -cp /usr/local/transitclock/Core.jar org.transitclock.db.webstructs.WebAgency` +
  ` ${agencyId}` +
  ` localhost` +
  ` TC_AGENCY_${agencyId}` +
  ` postgresql` +
  ` ${pgaddr}:${pgport}` +
  ` ${pguser}` +
  ` ${pgpass}`

const CreateSingleAPIKey = (propertiesFile, desc = 'Connector', email = 'alex@example.com', name = 'Application', phone = '123456', url = 'https://wayline.co') => `java` +
  ` -cp /usr/local/transitclock/Core.jar org.transitclock.applications.CreateAPIKey` +
  ` -c "${propertiesFile}"` +
  ` -d "${desc}"` +
  ` -e "${email}"` +
  ` -n "${name}"` +
  ` -p "${phone}"` +
  ` -u "${url}"`

const GetSingleAPIKey = (agencyId, pguser, pgaddr, pgport) => `psql` +
  ` -h "${pgaddr}"` +
  ` -p "${pgport}"` +
  ` -U "${pguser}"` +
  ` -d "TC_AGENCY_${agencyId}"` +
  ` -t` +
  ` -c "SELECT applicationkey from apikeys;" | xargs`

module.exports = {
  CreateTablesForSingleAgency,
  ImportGTFSForSingleAgency,
  CreateSingleWebAgency,
  CreateSingleAPIKey,
  GetSingleAPIKey
}
