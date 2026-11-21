select
    order_id,
    order_item_id,
    product_id,
    seller_id,
    order_date,
    item_price_brl,
    freight_value_brl,
    total_item_value_brl,
    total_item_value_usd
from {{ ref('int_order_items_enriched') }}
