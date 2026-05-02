

select *
from "reservoir"."main"."int_petrophysics"
where biot_alpha < 0.2
   or biot_alpha > 1.0
   or biot_alpha is null

