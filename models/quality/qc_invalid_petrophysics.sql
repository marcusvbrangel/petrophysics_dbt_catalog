select
    well_id,
    md_m,
    zone,
    gr_api,
    rhob_gcc,
    nphi_vv,
    dt_usft,
    dts_usft,
    rt_ohmm,
    phi,
    vsh,
    sw,
    so,
    perm_md,
    poisson_ratio,
    biot_alpha,
    case
        when phi < 0.01 or phi > 0.35 then 'PHI_OUT_OF_RANGE'
        when vsh < 0.0 or vsh > 1.0 then 'VSH_OUT_OF_RANGE'
        when sw < 0.0 or sw > 1.0 then 'SW_OUT_OF_RANGE'
        when so < 0.0 or so > 1.0 then 'SO_OUT_OF_RANGE'
        when perm_md <= 0 then 'PERM_NOT_POSITIVE'
        when poisson_ratio < 0.0 or poisson_ratio > 0.5 then 'POISSON_OUT_OF_RANGE'
        when biot_alpha < 0.2 or biot_alpha > 1.0 then 'BIOT_OUT_OF_RANGE'
        when dt_usft <= 0 or dts_usft <= 0 then 'SONIC_INVALID'
        when rhob_gcc < 1.8 or rhob_gcc > 3.1 then 'RHOB_OUT_OF_RANGE'
        when gr_api < 0 or gr_api > 250 then 'GR_OUT_OF_RANGE'
        else 'OK'
    end as quality_issue
from {{ ref('int_petrophysics') }}
where
    phi < 0.01 or phi > 0.35
    or vsh < 0.0 or vsh > 1.0
    or sw < 0.0 or sw > 1.0
    or so < 0.0 or so > 1.0
    or perm_md <= 0
    or poisson_ratio < 0.0 or poisson_ratio > 0.5
    or biot_alpha < 0.2 or biot_alpha > 1.0
    or dt_usft <= 0 or dts_usft <= 0
    or rhob_gcc < 1.8 or rhob_gcc > 3.1
    or gr_api < 0 or gr_api > 250
