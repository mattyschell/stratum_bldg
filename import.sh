# POSTGIS_INIT_DATA is a variable override from krapshoot 
# eventually I'd like to ditch this but for now ¯\_(ツ)_/¯  override it if unset  
: ${POSTGIS_INIT_DATA:="$(dirname "$0")"}
cd $POSTGIS_INIT_DATA
if [[ -z "$1" ]]; then
   echo "missing input variable schema (bldg_blue or bldg_green)"
   exit 1
fi
blueorgreenschema=$1
gzip -d -k -q ../stratum_bldg/building.sql.gz
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
