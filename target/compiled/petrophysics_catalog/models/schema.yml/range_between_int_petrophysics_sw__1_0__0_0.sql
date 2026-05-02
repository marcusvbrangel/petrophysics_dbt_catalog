

select *
from "reservoir"."main"."int_petrophysics"
where sw < 0.0
   or sw > 1.0
   or sw is null

