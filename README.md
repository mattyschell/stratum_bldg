# Stratum Building

[![Build Status](https://travis-ci.org/mattyschell/stratum_bldg.svg?branch=master)](https://travis-ci.org/mattyschell/stratum_bldg)

Import NYC buildings spatial data into a [stratum](https://github.com/mattyschell/stratum)
deployment.

# Dependencies

1. Git [Large File Storage](https://git-lfs.github.com/)
2. PostgreSQL with PostGIS extension (Travis CI tests at PostgreSQL 10.7, PostGIS 2.5)
3. A [Stratum](https://github.com/mattyschell/stratum) deployment.

# Import data

Externalize PostgreSQL connection details for the stratum user.

```shell
$ export PGDATABASE=gis
$ export PGPORT=5432
$ export PGPASSWORD=BeMyDatabaePostGis!
$ export PGHOST=aws.dollar.dollar.bill
```

Run the import script to populate either bldg_blue or bldg_green.  This script
executes as the stratum user regardless of your PGUSER environmental. The target
tables enforce geometry validity which takes a little time, patience friend. 

```shell
$ ./import.sh bldg_blue
```

# Integration Tests

Tests that we loaded the data as expected on today's date and stratum_catalog 
metadata looks decent. 

Requires python 3+ in addition to psql.

Should succeed for a public user on the database but the stratum user is fine 
too. Externalize connection details.

```shell
$ export PGDATABASE=gis
$ export PGPASSWORD=BeMyDataBaePostGis!
$ ../stratum_bldg/src/test/run_all_tests.sh bldg_blue
```


# TMI: Where Did This Data Come From?

You shouldn't read this, it is radically transparent background describing how 
the vegan data sausage is made.  But you're still reading for some reason.

The New York City Department of Information Technology and Telecommunications
(DOITT) Geographic Information Systems (GIS) outfit maintains buildings 
footprints.  The [metadata is here](https://github.com/CityOfNewYork/nyc-geo-metadata/blob/master/Metadata/Metadata_BuildingFootprints.md).

This data is currently maintained in a versioned [ESRI](https://www.esri.com/en-us/home)
Geodatabase.  The spatial data is stored in ESRI's proprietary SDE.ST_GEOMETRY
format.  Data stored in this format is essentially ransomwared, so the procedure
outlined below is driven by our need to jailbreak the spatial data from the 
database where it is locked up.

Paths and file names below should be changed to protect the innocent.

1. Using ESRI ArcCatalog, export the buildings data to the dreaded, but 
interoperable, [shapefile](https://en.wikipedia.org/wiki/Shapefile) format.

2. Load the dreaded but interoperable shapefile into a scratch PostGIS database
using [shp2pgsql](https://postgis.net/docs/using_postgis_dbmanagement.html#shp2pgsql_usage)

```shell
$ shp2pgsql -s 2263 -g shape /d/temp/building.shp buildingtemp > /d/temp/buildingtemp.sql
```

3. Run the sql produced to create a new table named buildingtemp. Column names 
will be lopped off because of the dreaded but interoperable shapefile format. 
We could produce a mapping file to avoid the messy column names hitting the
database but we are lazy and the SQL below accomplishes the same.

```shell
$ psql -q -f /d/temp/buildingtemp.sql
```

4. Insert the scratch data into a more tidy form.  Eliminate buildings that
are under construction, aka "million bins." Remove meaningless vertices and snap
the results to a grid.  The exact parameters below are, and probably will be 
forever, in flux. 

```sql
insert into building (
    bin         
   ,base_bbl         
   ,construction_year  
   ,geom_source       
   ,last_status_type  
   ,doitt_id
   ,height_roof   
   ,feature_code   
   ,ground_elevation
   ,last_modified_date  
   ,mappluto_bbl   
   ,shape           
) select 
     bin
    ,base_bbl::numeric
    ,constructi
    ,geom_sourc
    ,last_statu
    ,doitt_id
    ,height_roo
    ,feature_co
    ,ground_ele
    ,last_edi_1
    ,mappluto_b::numeric
    ,ST_SnapToGrid(ST_SimplifyVW(shape,.1), 0,0, 1,1) 
from buildingtemp
where bin not in (1000000,2000000,3000000,4000000,5000000);
```

5. Verify that all shapes are valid. If not, deal with them as you do.

```sql
select 
    objectid
   ,ST_IsValidReason(shape) 
from 
    building 
where 
    st_isvalid(shape) <> true;
```

6. Dump it

```shell
pg_dump -a -f /d/temp/building.sql -n bldg_blue -O -S stratum -t bldg_blue.building -x
```

7. Zip it

Leaving the process this way because I want human-readable .sql.  Compression
levels above default 6 accomplish little.

```shell
gzip -k building.sql
```


