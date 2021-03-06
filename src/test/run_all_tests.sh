#!/bin/bash
export PGUSER='stratum'
if [[ -z "$1" ]]; then
   echo "missing input variable schema (usually bldg_blue or bldg_green)"
   exit 1
else
   blueorgreenschema=$1
fi
# todo: efficientize 
if [ "$blueorgreenschema" == "bldg_blue" ]; then
    (python ../stratum_bldg/src/test/run_test.py "../stratum_bldg/src/test/bldg_blue_kount.sql" "../stratum_bldg/src/test/bldg_kount_expected") || exit 1   
    (python ../stratum_bldg/src/test/run_test.py "../stratum_bldg/src/test/bldg_blue_catalog.sql" "../stratum_bldg/src/test/bldg_catalog_expected") || exit 1
elif [ "$blueorgreenschema" == "bldg_green" ]; then
    (python ../stratum_bldg/src/test/run_test.py "../stratum_bldg/src/test/bldg_green_kount.sql" "../stratum_bldg/src/test/bldg_kount_expected") || exit 1
    (python ../stratum_bldg/src/test/run_test.py "../stratum_bldg/src/test/bldg_green_catalog.sql" "../stratum_bldg/src/test/bldg_catalog_expected") || exit 1
else
    echo "I dont know how to check schema $blueorgreenschema"
    exit 1
fi
# enforcing this test via a check constraint for now
# (python ../stratum_bldg/src/test/run_test.py "../stratum_bldg/src/test/bldg_isvalid.sql" "../stratum_bldg/src/test/bldg_isvalid_expected") || exit 1

