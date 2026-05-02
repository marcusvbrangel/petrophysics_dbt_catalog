
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select zone
from "reservoir"."main"."mart_zone_quality"
where zone is null



  
  
      
    ) dbt_internal_test