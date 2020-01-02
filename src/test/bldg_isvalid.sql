select 
    ' objectid ' || objectid || ' is invalid because of ' || st_isvalidreason(shape) as isvalid 
from 
    bldg_read.building
where
   st_isvalid(shape) <> 'true';