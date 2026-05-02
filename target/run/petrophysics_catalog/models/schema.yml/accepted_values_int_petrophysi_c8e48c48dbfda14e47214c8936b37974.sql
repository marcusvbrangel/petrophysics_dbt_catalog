
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        zone as value_field,
        count(*) as n_records

    from "reservoir"."main"."int_petrophysics"
    group by zone

)

select *
from all_values
where value_field not in (
    'SEAL_TOP','RES_A','SEAL_MID','RES_B'
)



  
  
      
    ) dbt_internal_test