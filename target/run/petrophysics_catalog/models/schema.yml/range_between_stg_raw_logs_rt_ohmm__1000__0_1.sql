
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

select *
from "reservoir"."main"."stg_raw_logs"
where rt_ohmm < 0.1
   or rt_ohmm > 1000
   or rt_ohmm is null


  
  
      
    ) dbt_internal_test