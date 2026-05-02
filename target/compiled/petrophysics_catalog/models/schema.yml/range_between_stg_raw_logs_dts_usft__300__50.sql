

select *
from "reservoir"."main"."stg_raw_logs"
where dts_usft < 50
   or dts_usft > 300
   or dts_usft is null

