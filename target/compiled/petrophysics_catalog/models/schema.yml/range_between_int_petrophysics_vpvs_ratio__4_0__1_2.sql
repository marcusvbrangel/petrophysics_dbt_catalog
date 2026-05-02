

select *
from "reservoir"."main"."int_petrophysics"
where vpvs_ratio < 1.2
   or vpvs_ratio > 4.0
   or vpvs_ratio is null

