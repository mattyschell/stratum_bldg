blueorgreenschema=$1
gzip -d -k -q building.sql.gz
sed "s/bldg_blue/$blueorgreenschema/g" building.sql > "$blueorgreenschema".sql
ECHO "deleting contents of $blueorgreenschema.building"
psql -c "delete from $blueorgreenschema.building;"
ECHO "importing $blueorgreenschema.building data from $blueorgreenschema.sql"
psql -f "$blueorgreenschema".sql
ECHO "clustering spatial index, data, and analyzing"
psql -c "cluster buildingshape on $blueorgreenschema.building;"
psql -c "cluster $blueorgreenschema.building;"
psql -c "VACUUM FULL ANALYZE $blueorgreenschema.building;"
ECHO "updating metadata in stratum_catalog.stratum_catalog"
psql -c "update stratum_catalog.st_catalog set dataset_updated = now(), spatial_reference = 2263 where dataset_name = 'building' and dataset_schema = '$blueorgreenschema';"
rm building.sql
rm "$blueorgreenschema".sql