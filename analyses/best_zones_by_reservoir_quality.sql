-- melhores zonas por qualidade de reservatório
select
    zone,
    samples,
    avg_phi,
    avg_sw,
    avg_so,
    avg_perm_md,
    avg_vsh,
    avg_young_gpa
from {{ portable_ref('mart_zone_quality') }}
order by avg_phi desc, avg_perm_md desc;
