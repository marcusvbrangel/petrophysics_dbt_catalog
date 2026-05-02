
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

select *
from "reservoir"."main"."int_petrophysics"
where vsh < 0.0
   or vsh > 1.0
   or vsh is null


  
  
      
    ) dbt_internal_test