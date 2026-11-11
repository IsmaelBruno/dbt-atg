with duplicates as (
    select
        depot_code,
        tank_id_raw,
        count(*) as duplicate_count
    from {{ ref('ref_tank_products_simple') }}
    group by 1, 2
    having count(*) > 1
)
select *
from duplicates
