
  
    
    

    create  table
      "reservoir"."main"."mart_zone_quality__dbt_tmp"
  
    as (
      select
    zone,
    count(*) as samples,
    count(distinct well_id) as wells,
    avg(phi) as avg_phi,
    avg(sw) as avg_sw,
    avg(so) as avg_so,
    avg(perm_md) as avg_perm_md,
    avg(vsh) as avg_vsh,
    avg(vp_ms) as avg_vp_ms,
    avg(vs_ms) as avg_vs_ms,
    avg(young_modulus_pa) / 1e9 as avg_young_gpa,
    avg(biot_alpha) as avg_biot_alpha,
    avg(hydraulic_diffusivity_m2s) as avg_hydraulic_diffusivity_m2s
from "reservoir"."main"."int_petrophysics"
group by zone
order by avg_phi desc, avg_perm_md desc
    );
  
  