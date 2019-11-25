# Stratum Building

Import NYC buildings spatial data into a [stratum](https://github.com/mattyschell/stratum)
deployment.

# Dependencies

1. Git Large File Storage https://git-lfs.github.com/
2. Terminal with zip and psql access  

# Import data

Externalize PostgreSQL connection details.

    $ export PGDATABASE=bse
    $ export PGUSER=stratum
    $ export PGPORT=5433
    $ export PGPASSWORD=BeMyDatabae!
    $ export PGHOST=aws.dollar.dollar.bill

Run the import script to populate either bldg_blue or bldg_green.

    $ ./import.sh bldg_blue