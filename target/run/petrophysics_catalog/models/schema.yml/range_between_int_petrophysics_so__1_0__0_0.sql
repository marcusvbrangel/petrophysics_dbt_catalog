
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

select *
from "reservoir"."main"."int_petrophysics"
where so < 0.0
   or so > 1.0
   or so is null


  
  
      
    ) dbt_internal_test