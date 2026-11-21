with items as (
    select * from {{ ref('stg_order_items') }}
),

orders as (
    select order_id, order_date, order_status from {{ ref('stg_orders') }}
),

products as (
    select product_id, category_name from {{ ref('stg_products') }}
),

fx as (
    select rate_date, brl_to_usd, brl_to_eur from {{ ref('stg_fx_rates') }}
),

joined as (
    select
        i.order_id,
        i.order_item_id,
        i.product_id,
        p.category_name,
        i.seller_id,
        o.order_date,
        o.order_status,
        i.item_price_brl,
        i.freight_value_brl,
        (i.item_price_brl + i.freight_value_brl) as total_item_value_brl,
        coalesce(f.brl_to_usd, 0.27) as brl_to_usd_rate,
        round((i.item_price_brl + i.freight_value_brl) * coalesce(f.brl_to_usd, 0.27), 2) as total_item_value_usd
    from items i
    left join orders o on i.order_id = o.order_id
    left join products p on i.product_id = p.product_id
    left join fx f on o.order_date = f.rate_date
)

select * from joined
