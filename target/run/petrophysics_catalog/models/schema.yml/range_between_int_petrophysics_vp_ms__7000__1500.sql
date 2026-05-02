
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

select *
from "reservoir"."main"."int_petrophysics"
where vp_ms < 1500
   or vp_ms > 7000
   or vp_ms is null


  
  
      
    ) dbt_internal_test