select
    *,
    concat_ws(
        ';',
        case
            when depot_code is null
                or trim(depot_code) = ''
                or tank_id_raw is null
                or trim(tank_id_raw) = ''
                or report_time is null
                then 'missing_business_key'
        end,
        case when not has_mapping then 'unmapped_tank_reference' end,
        case when product_recovered_from_reference then 'product_recovered_from_reference' end,
        case when level_recovered_from_product then 'level_recovered_from_product' end
    ) as audit_reason
from {{ ref('stg_tank_measurements') }}
where depot_code is null
    or trim(depot_code) = ''
    or tank_id_raw is null
    or trim(tank_id_raw) = ''
    or report_time is null
    or not has_mapping
    or product_recovered_from_reference
    or level_recovered_from_product
