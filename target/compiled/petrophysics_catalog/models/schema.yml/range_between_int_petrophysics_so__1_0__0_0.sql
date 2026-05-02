

select *
from "reservoir"."main"."int_petrophysics"
where so < 0.0
   or so > 1.0
   or so is null

