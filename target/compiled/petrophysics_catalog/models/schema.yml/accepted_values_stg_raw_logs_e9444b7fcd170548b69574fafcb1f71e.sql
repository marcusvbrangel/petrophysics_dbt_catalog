
    
    

with all_values as (

    select
        zone as value_field,
        count(*) as n_records

    from "reservoir"."main"."stg_raw_logs"
    group by zone

)

select *
from all_values
where value_field not in (
    'SEAL_TOP','RES_A','SEAL_MID','RES_B'
)


