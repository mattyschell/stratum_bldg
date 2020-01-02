select a.dataset from (
    select dataset_name as dataset
    from 
        stratum_catalog.stratum_catalog
    where 
        dataset_name = 'building' 
    and dataset_schema = 'bldg_blue'
    and cast(dataset_updated as date) = current_date
    union all
    select dataset_schema || '.' || dataset_name as dataset
    from 
        stratum_catalog.stratum_catalog
    where 
        dataset_name = 'building' 
    and dataset_schema = 'bldg_read'
    and dataset_database = current_catalog
    and storage_name = 'building'
    and storage_schema = 'bldg_blue'
) a order by 1;