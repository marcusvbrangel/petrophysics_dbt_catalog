

select *
from "reservoir"."main"."stg_raw_logs"
where md_m < 2500.0
   or md_m > 3100.0
   or md_m is null

