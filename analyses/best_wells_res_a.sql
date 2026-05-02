-- ranking dos melhores poços na zona RES_A
select
    well_id,
    avg_phi,
    avg_so,
    avg_perm_md,
    avg_vsh,
    avg_young_gpa,
    avg_vpvs_ratio
from {{ portable_ref('mart_well_zone_quality') }}
where zone = 'RES_A'
order by avg_phi desc, avg_perm_md desc, avg_so desc;
