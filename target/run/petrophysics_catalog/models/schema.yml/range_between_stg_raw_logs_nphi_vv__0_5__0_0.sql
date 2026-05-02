
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

select *
from "reservoir"."main"."stg_raw_logs"
where nphi_vv < 0.0
   or nphi_vv > 0.5
   or nphi_vv is null


  
  
      
    ) dbt_internal_test