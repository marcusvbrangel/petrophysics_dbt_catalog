
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select zone
from "reservoir"."main"."stg_raw_logs"
where zone is null



  
  
      
    ) dbt_internal_test