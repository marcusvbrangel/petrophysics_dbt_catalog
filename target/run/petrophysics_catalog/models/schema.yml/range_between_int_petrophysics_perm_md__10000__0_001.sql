
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

select *
from "reservoir"."main"."int_petrophysics"
where perm_md < 0.001
   or perm_md > 10000
   or perm_md is null


  
  
      
    ) dbt_internal_test