with source as (
    select * from `grounded-will-513816-q4.raw.olist_order_items `
),

cleaned as (
    select
        order_id,
        order_item_id,
        product_id,
        seller_id,
        cast(shipping_limit_date as timestamp) as shipping_limit_at,
        round(cast(price as numeric), 2) as item_price_brl,
        round(cast(freight_value as numeric), 2) as freight_value_brl
    from source
)

select * from cleaned
