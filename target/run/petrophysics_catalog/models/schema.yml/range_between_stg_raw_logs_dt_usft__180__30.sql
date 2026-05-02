
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

select *
from "reservoir"."main"."stg_raw_logs"
where dt_usft < 30
   or dt_usft > 180
   or dt_usft is null


  
  
      
    ) dbt_internal_test