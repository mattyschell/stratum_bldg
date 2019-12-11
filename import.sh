# POSTGIS_INIT_DATA is a variable override from krapshoot land
# eventually I'd like to ditch this but for now ¯\_(ツ)_/¯  override it if unset  
: ${POSTGIS_INIT_DATA:="$(dirname "$0")"}
cd $POSTGIS_INIT_DATA
# verify we have a schema target
if [[ -z "$1" ]]; then
   echo "missing input variable schema (usually bldg_blue or bldg_green)"
   exit 1
else
   blueorgreenschema=$1
fi
# check that LFS worked or user manually dropped a big ol zip file here 
if [ $(wc -c < "../stratum_bldg/building.sql.gz") -lt 10000 ]; then
    echo "size of stratum_bldg/building.sql.gz is too small, check Git LFS or download"
    exit 1
fi
gzip -f -d -k -q ../stratum_bldg/building.sql.gz
# verify that gzip worked meaning directory is writeable before continuing
if [ ! -f ../stratum_bldg/building.sql ]; then
    echo "cant unzip to stratum_bldg/building.sql, is the directory writeable?"
    exit 1
fi
# verify that we can connect as stratum user
# caller gotsta change PGPASSWORD between stratum setup and this repo
kount=$(psql -U stratum -qtAX -c "select count(*) from information_schema.schemata where schema_owner = 'stratum';")
if [[ -z "$kount" ]]; then
    echo "cant connect as stratum to $PGDATABASE, check connection params"
    exit 1
elif [ "$kount" -eq "0" ]; then
    echo "cant connect stratum to $PGDATABASE and find schemas owned by stratum, check connection params"
    exit 1
fi    
sed "s/bldg_blue/$blueorgreenschema/g" ../stratum_bldg/building.sql > "../stratum_bldg/$blueorgreenschema".sql
echo "deleting contents of $blueorgreenschema.building"
psql -U stratum -c "delete from $blueorgreenschema.building;"
echo "importing $blueorgreenschema.building data from $blueorgreenschema.sql"
psql -U stratum -f "../stratum_bldg/$blueorgreenschema".sql
echo "clustering spatial index, data, and analyzing"
psql -U stratum -c "cluster buildingshape on $blueorgreenschema.building;"
psql -U stratum -c "cluster $blueorgreenschema.building;"
psql -U stratum -c "VACUUM FULL ANALYZE $blueorgreenschema.building;"
echo "updating metadata in stratum_catalog.stratum_catalog"
psql -U stratum -c "update stratum_catalog.st_catalog set dataset_updated = now(), spatial_reference = 2263 where dataset_name = 'building' and dataset_schema = '$blueorgreenschema';"
rm ../stratum_bldg/building.sql
rm "../stratum_bldg/$blueorgreenschema".sql