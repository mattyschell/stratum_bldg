select case
    when ((select count(*) from bldg_green.building) = 
          (select count(*) from bldg_green.building))
          and 
          (select count(*) from bldg_green.building) > 0         
    then
        1
    else 
        0
end as recordkompare;