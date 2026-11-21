with source as (
    select * from {{ source('raw_ecom', 'frankfurter_fx') }}
),

pivoted as (
    select
        cast(date as date) as rate_date,
        base as base_currency,
        max(case when quote = 'USD' then rate end) as brl_to_usd,
        max(case when quote = 'EUR' then rate end) as brl_to_eur
    from source
    group by 1, 2
)

select * from pivoted
