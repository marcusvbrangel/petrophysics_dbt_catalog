

select *
from "reservoir"."main"."int_petrophysics"
where phi < 0.01
   or phi > 0.35
   or phi is null

