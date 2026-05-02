select
    cast(well_id as varchar) as well_id,
    cast(md_m as double) as md_m,
    cast(zone as varchar) as zone,
    cast(gr_api as double) as gr_api,
    cast(rhob_gcc as double) as rhob_gcc,
    cast(nphi_vv as double) as nphi_vv,
    cast(dt_usft as double) as dt_usft,
    cast(dts_usft as double) as dts_usft,
    cast(rt_ohmm as double) as rt_ohmm
from raw_logs