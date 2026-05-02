
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select md_m
from "reservoir"."main"."int_petrophysics"
where md_m is null



  
  
      
    ) dbt_internal_test