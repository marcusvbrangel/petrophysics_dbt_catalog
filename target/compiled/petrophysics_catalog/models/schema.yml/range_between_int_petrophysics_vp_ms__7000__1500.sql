

select *
from "reservoir"."main"."int_petrophysics"
where vp_ms < 1500
   or vp_ms > 7000
   or vp_ms is null

