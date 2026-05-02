

select *
from "reservoir"."main"."stg_raw_logs"
where rt_ohmm < 0.1
   or rt_ohmm > 1000
   or rt_ohmm is null

