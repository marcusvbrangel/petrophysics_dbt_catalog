
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

select *
from "reservoir"."main"."stg_raw_logs"
where md_m < 2500.0
   or md_m > 3100.0
   or md_m is null


  
  
      
    ) dbt_internal_test