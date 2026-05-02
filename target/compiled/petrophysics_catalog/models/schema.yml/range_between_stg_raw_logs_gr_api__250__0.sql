

select *
from "reservoir"."main"."stg_raw_logs"
where gr_api < 0
   or gr_api > 250
   or gr_api is null

