

select *
from "reservoir"."main"."int_petrophysics"
where vsh < 0.0
   or vsh > 1.0
   or vsh is null

