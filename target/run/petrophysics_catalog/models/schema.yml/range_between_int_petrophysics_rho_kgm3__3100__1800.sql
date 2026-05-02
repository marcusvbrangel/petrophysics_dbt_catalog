
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

select *
from "reservoir"."main"."int_petrophysics"
where rho_kgm3 < 1800
   or rho_kgm3 > 3100
   or rho_kgm3 is null


  
  
      
    ) dbt_internal_test