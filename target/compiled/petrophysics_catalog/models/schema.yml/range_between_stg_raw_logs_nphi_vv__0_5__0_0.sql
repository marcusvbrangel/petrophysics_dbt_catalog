

select *
from "reservoir"."main"."stg_raw_logs"
where nphi_vv < 0.0
   or nphi_vv > 0.5
   or nphi_vv is null

