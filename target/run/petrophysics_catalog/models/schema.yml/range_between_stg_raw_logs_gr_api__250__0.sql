
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

select *
from "reservoir"."main"."stg_raw_logs"
where gr_api < 0
   or gr_api > 250
   or gr_api is null


  
  
      
    ) dbt_internal_test