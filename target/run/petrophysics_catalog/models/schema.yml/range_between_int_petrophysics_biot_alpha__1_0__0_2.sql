
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

select *
from "reservoir"."main"."int_petrophysics"
where biot_alpha < 0.2
   or biot_alpha > 1.0
   or biot_alpha is null


  
  
      
    ) dbt_internal_test