select
    well_id,
    zone,
    count(*) as samples,
    min(md_m) as top_md_m,
    max(md_m) as base_md_m,
    avg(phi) as avg_phi,
    avg(sw) as avg_sw,
    avg(so) as avg_so,
    avg(perm_md) as avg_perm_md,
    avg(vsh) as avg_vsh,
    avg(young_modulus_pa) / 1e9 as avg_young_gpa,
    avg(vpvs_ratio) as avg_vpvs_ratio,
    avg(acoustic_impedance) as avg_acoustic_impedance,
    avg(shear_impedance) as avg_shear_impedance
from "reservoir"."main"."int_petrophysics"
group by well_id, zone
order by well_id, zone