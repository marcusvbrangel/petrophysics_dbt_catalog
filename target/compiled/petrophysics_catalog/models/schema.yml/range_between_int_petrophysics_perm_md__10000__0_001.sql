

select *
from "reservoir"."main"."int_petrophysics"
where perm_md < 0.001
   or perm_md > 10000
   or perm_md is null

