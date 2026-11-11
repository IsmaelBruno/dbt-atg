{{ config(alias='tank_measurements') }}

with staging as (
    select *
    from {{ ref('stg_tank_measurements') }}
),
deduplicated as (
    select distinct on (
        depot_code,
        tank_id_raw,
        date_trunc(
            'hour',
            report_time at time zone '{{ var("atg_timezone") }}'
        )
    )
        *
    from staging
    order by
        depot_code,
        tank_id_raw,
        date_trunc(
            'hour',
            report_time at time zone '{{ var("atg_timezone") }}'
        ),
        report_time desc,
        id desc
),
with_differences as (
    select
        *,
        level_m - lag(level_m) over tank_history as niveau_diff,
        net_standard_volume_m3
            - lag(net_standard_volume_m3) over tank_history as volume_diff,
        average_temperature_c
            - lag(average_temperature_c) over tank_history as temp_diff
    from deduplicated
    window tank_history as (
        partition by depot_code, tank_id_raw
        order by report_time, id
    )
)
select
    id,
    source_file,
    report_time,
    (report_time at time zone '{{ var("atg_timezone") }}')::date as date,
    (report_time at time zone '{{ var("atg_timezone") }}')::time as heure,
    tank_scope,
    tank_id,
    source_product,
    product,
    product as produit,
    source_level_m,
    level_m,
    level_m as "Niveau",
    level_recovered_from_product,
    niveau_diff,
    niveau_diff * 1000 as niveau_diff_mm,
    average_temperature_c,
    average_temperature_c as "Température_moyen",
    temperature_1_c,
    temperature_1_c as "Température_1",
    net_standard_volume_m3,
    net_standard_volume_m3 as volume_standard_net,
    reference_density_kg_m3,
    depot_code,
    tank_id_raw,
    tank_id as "Bac_id",
    ullage_m,
    tov_m3,
    wia_ton,
    level_status,
    nsv_diff,
    case
        when nsv_diff > 0 then nsv_diff * 1000
    end as "Entrée_ATG",
    case
        when nsv_diff < 0 then nsv_diff * 1000
    end as "Sortie_ATG",
    volume_diff,
    temp_diff,
    quality_flags,
    tank_reference,
    standard_product,
    has_mapping,
    product_recovered_from_reference
from with_differences
where depot_code is not null
    and trim(depot_code) <> ''
    and tank_id_raw is not null
    and trim(tank_id_raw) <> ''
    and report_time is not null
    and has_mapping
