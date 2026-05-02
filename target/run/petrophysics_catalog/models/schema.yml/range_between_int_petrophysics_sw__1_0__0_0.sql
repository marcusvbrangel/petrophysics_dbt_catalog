
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

select *
from "reservoir"."main"."int_petrophysics"
where sw < 0.0
   or sw > 1.0
   or sw is null


  
  
      
    ) dbt_internal_test