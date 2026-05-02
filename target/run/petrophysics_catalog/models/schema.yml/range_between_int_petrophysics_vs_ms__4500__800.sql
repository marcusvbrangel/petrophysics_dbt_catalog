
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

select *
from "reservoir"."main"."int_petrophysics"
where vs_ms < 800
   or vs_ms > 4500
   or vs_ms is null


  
  
      
    ) dbt_internal_test