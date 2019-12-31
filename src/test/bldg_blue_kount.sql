select case
    when ((select count(*) from bldg_blue.building) = 
          (select count(*) from bldg_read.building))
          and 
          (select count(*) from bldg_blue.building) > 0         
    then
        1
    else 
        0
end as recordkompare;