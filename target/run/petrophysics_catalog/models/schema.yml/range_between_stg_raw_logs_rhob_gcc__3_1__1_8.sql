
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

select *
from "reservoir"."main"."stg_raw_logs"
where rhob_gcc < 1.8
   or rhob_gcc > 3.1
   or rhob_gcc is null


  
  
      
    ) dbt_internal_test