
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

select *
from "reservoir"."main"."int_petrophysics"
where poisson_ratio < 0.0
   or poisson_ratio > 0.5
   or poisson_ratio is null


  
  
      
    ) dbt_internal_test