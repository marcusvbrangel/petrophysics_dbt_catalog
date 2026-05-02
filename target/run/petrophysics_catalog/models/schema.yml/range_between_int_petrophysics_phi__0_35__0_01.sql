
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

select *
from "reservoir"."main"."int_petrophysics"
where phi < 0.01
   or phi > 0.35
   or phi is null


  
  
      
    ) dbt_internal_test