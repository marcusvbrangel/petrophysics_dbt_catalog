

select *
from "reservoir"."main"."int_petrophysics"
where poisson_ratio < 0.0
   or poisson_ratio > 0.5
   or poisson_ratio is null

