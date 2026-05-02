
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

select *
from "reservoir"."main"."int_petrophysics"
where vpvs_ratio < 1.2
   or vpvs_ratio > 4.0
   or vpvs_ratio is null


  
  
      
    ) dbt_internal_test