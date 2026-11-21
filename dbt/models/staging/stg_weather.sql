with source as (
    select * from {{ source('raw_ecom', 'open_meteo_weather') }}
),

cleaned as (
    select
        cast(time as date) as weather_date,
        lower(trim(city)) as city,
        upper(trim(state)) as state,
        round(temperature_2m_mean, 1) as avg_temp_c,
        round(precipitation_sum, 2) as precipitation_mm,
        round(rain_sum, 2) as rain_mm,
        case 
            when rain_sum >= 10.0 then 'Heavy Rain'
            when rain_sum > 0.0 then 'Light Rain'
            else 'Dry'
        end as weather_condition
    from source
)

select * from cleaned
