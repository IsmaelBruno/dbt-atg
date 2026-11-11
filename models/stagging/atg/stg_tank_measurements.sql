select
    s.id,
    s.source_file,
    s.report_time,
    s.tank_scope,
    s.tank_id,
    s.product as source_product,
    p.raw_product as product,
    s.level_m as source_level_m,
    case
        when s.level_m is not null then s.level_m
        when trim(s.product) ~ '^[+-]?[0-9]+([.][0-9]+)?$'
            then trim(s.product)::double precision
    end as level_m,
    (
        s.level_m is null
        and trim(s.product) ~ '^[+-]?[0-9]+([.][0-9]+)?$'
    ) as level_recovered_from_product,
    s.average_temperature_c,
    s.temperature_1_c,
    s.net_standard_volume_m3,
    s.reference_density_kg_m3,
    s.depot_code,
    s.tank_id_raw,
    s.ullage_m,
    s.tov_m3,
    s.wia_ton,
    s.level_status,
    s.nsv_diff,
    s.quality_flags,
    case
        when s.depot_code is not null
            and trim(s.depot_code) <> ''
            and s.tank_id_raw is not null
            and trim(s.tank_id_raw) <> ''
        then concat(trim(s.depot_code), '-', trim(s.tank_id_raw))
    end as tank_reference,
    p.standard_product,
    (p.tank_id_raw is not null) as has_mapping,
    (
        p.tank_id_raw is not null
        and (
            s.product is null
            or trim(s.product) = ''
            or (
                lower(trim(s.product)) <> lower(trim(p.raw_product))
                and lower(trim(s.product)) <> lower(trim(p.standard_product))
            )
        )
    ) as product_recovered_from_reference
from {{ source('atg', 'tank_measurements') }} as s
left join {{ ref('ref_tank_products_simple') }} as p
    on lower(trim(s.depot_code)) = lower(trim(p.depot_code))
    and lower(trim(s.tank_id_raw)) = lower(trim(p.tank_id_raw))
