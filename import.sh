cd $POSTGIS_INIT_DATA
blueorgreenschema=$1
gzip -d -k -q ../stratum_bldg/building.sql.gz
sed "s/bldg_blue/$blueorgreenschema/g" ../stratum_bldg/building.sql > "../stratum_bldg/$blueorgreenschema".sql
echo "deleting contents of $blueorgreenschema.building"
psql -c "delete from $blueorgreenschema.building;"
echo "importing $blueorgreenschema.building data from $blueorgreenschema.sql"
psql -f "../stratum_bldg/$blueorgreenschema".sql
echo "clustering spatial index, data, and analyzing"
psql -c "cluster buildingshape on $blueorgreenschema.building;"
psql -c "cluster $blueorgreenschema.building;"
psql -c "VACUUM FULL ANALYZE $blueorgreenschema.building;"
echo "updating metadata in stratum_catalog.stratum_catalog"
psql -c "update stratum_catalog.st_catalog set dataset_updated = now(), spatial_reference = 2263 where dataset_name = 'building' and dataset_schema = '$blueorgreenschema';"
rm ../stratum_bldg/building.sql
rm "../stratum_bldg/$blueorgreenschema".sql
