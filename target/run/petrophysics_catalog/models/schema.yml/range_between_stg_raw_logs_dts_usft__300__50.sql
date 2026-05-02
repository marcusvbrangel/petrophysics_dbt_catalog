
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

select *
from "reservoir"."main"."stg_raw_logs"
where dts_usft < 50
   or dts_usft > 300
   or dts_usft is null


  
  
      
    ) dbt_internal_test