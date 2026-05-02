

select *
from "reservoir"."main"."int_petrophysics"
where rho_kgm3 < 1800
   or rho_kgm3 > 3100
   or rho_kgm3 is null

