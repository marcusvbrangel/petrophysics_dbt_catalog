
    
    

select
    zone as unique_field,
    count(*) as n_records

from "reservoir"."main"."mart_zone_quality"
where zone is not null
group by zone
having count(*) > 1


