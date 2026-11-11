select distinct
    depot_code,
    tank_id_raw
from {{ ref('stg_tank_measurements') }}
where not has_mapping
