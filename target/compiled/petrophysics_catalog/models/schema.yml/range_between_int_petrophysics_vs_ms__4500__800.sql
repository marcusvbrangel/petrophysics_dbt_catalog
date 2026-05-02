

select *
from "reservoir"."main"."int_petrophysics"
where vs_ms < 800
   or vs_ms > 4500
   or vs_ms is null

