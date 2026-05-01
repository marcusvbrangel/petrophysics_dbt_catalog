with
base as (
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

        304800.0 / nullif(dt_usft, 0) as vp_ms,
        304800.0 / nullif(dts_usft, 0) as vs_ms,
        rhob_gcc * 1000.0 as rho_kgm3,
        nphi_vv as phi_nphi,
        (gr_api - 30.0) / nullif((130.0 - 30.0), 0) as vsh_raw
    from {{ ref('stg_raw_logs') }}
),
clean as (
    select
        *,
        least(greatest(vsh_raw, 0.0), 1.0) as vsh,
        least(greatest(phi_nphi, 0.01), 0.35) as phi
    from base
),
elastic as (
    select
        *,
        rho_kgm3 * vs_ms * vs_ms as shear_modulus_pa,
        rho_kgm3 * (vp_ms * vp_ms - (4.0 / 3.0) * vs_ms * vs_ms) as bulk_modulus_pa,
        vp_ms / nullif(vs_ms, 0) as vpvs_ratio
    from clean
),
elastic2 as (
    select
        *,
        9.0 * bulk_modulus_pa * shear_modulus_pa
            / nullif(3.0 * bulk_modulus_pa + shear_modulus_pa, 0) as young_modulus_pa,
        (3.0 * bulk_modulus_pa - 2.0 * shear_modulus_pa)
            / nullif(2.0 * (3.0 * bulk_modulus_pa + shear_modulus_pa), 0) as poisson_ratio,
        1.0 / nullif(bulk_modulus_pa, 0) as rock_compressibility_1pa,
        rho_kgm3 * vp_ms as acoustic_impedance,
        rho_kgm3 * vs_ms as shear_impedance
    from elastic
),
fluid as (
    select
        *,
        sqrt(((1.0 / power(phi, 2.0)) * 0.08) / nullif(rt_ohmm, 0)) as sw_raw,
        1000.0 * power(phi, 4.0) / nullif(power(1.0 - phi, 2.0), 0) as perm_md_raw
    from elastic2
),
final as (
    select
        *,
        least(greatest(sw_raw, 0.0), 1.0) as sw,
        1.0 - least(greatest(sw_raw, 0.0), 1.0) as so,
        greatest(perm_md_raw, 0.001) as perm_md,
        greatest(perm_md_raw, 0.001) * 9.869233e-16 as perm_m2,
        1.0 - bulk_modulus_pa / 37.0e9 as biot_alpha_raw,
        perm_md_raw * 9.869233e-16 /
            nullif(phi * 0.001 * ((1.0 / nullif(bulk_modulus_pa, 0)) + 4.4e-10), 0)
            as hydraulic_diffusivity_m2s
    from fluid
)
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
    vp_ms,
    vs_ms,
    rho_kgm3,
    phi,
    vsh,
    sw,
    so,
    perm_md,
    perm_m2,
    shear_modulus_pa,
    bulk_modulus_pa,
    young_modulus_pa,
    poisson_ratio,
    rock_compressibility_1pa,
    acoustic_impedance,
    shear_impedance,
    vpvs_ratio,
    least(greatest(biot_alpha_raw, 0.2), 1.0) as biot_alpha,
    hydraulic_diffusivity_m2s
from final
