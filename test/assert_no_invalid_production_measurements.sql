select
    id,
    depot_code,
    tank_id_raw,
    report_time,
    has_mapping,
    product,
    standard_product
from {{ ref('fct_tank_measurements') }}
where depot_code is null
   or trim(depot_code) = ''
   or tank_id_raw is null
   or trim(tank_id_raw) = ''
   or report_time is null
   or not has_mapping
   or product is null
   or standard_product is null
