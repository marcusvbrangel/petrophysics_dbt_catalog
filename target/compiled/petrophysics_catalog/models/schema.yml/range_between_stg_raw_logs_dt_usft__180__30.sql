

select *
from "reservoir"."main"."stg_raw_logs"
where dt_usft < 30
   or dt_usft > 180
   or dt_usft is null

