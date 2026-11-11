select
    id,
    depot_code,
    tank_id_raw,
    source_product,
    source_level_m,
    product,
    level_m
from {{ ref('stg_tank_measurements') }}
where source_product ~ '^[+-]?[0-9]+([.][0-9]+)?$'
    and (
        product is null
        or not product_recovered_from_reference
        or (
            source_level_m is null
            and (
                level_m is null
                or not level_recovered_from_product
            )
        )
    )
