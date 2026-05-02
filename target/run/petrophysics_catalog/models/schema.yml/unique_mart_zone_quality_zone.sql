
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    zone as unique_field,
    count(*) as n_records

from "reservoir"."main"."mart_zone_quality"
where zone is not null
group by zone
having count(*) > 1



  
  
      
    ) dbt_internal_test