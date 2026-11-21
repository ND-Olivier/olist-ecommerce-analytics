with delivery_weather as (
    select * from {{ ref('int_orders_delivery_weather') }}
),

payments_reviews as (
    select * from {{ ref('int_order_payments_reviews') }}
),

order_totals as (
    select
        order_id,
        count(order_item_id) as total_items,
        sum(item_price_brl) as items_revenue_brl,
        sum(freight_value_brl) as total_freight_brl,
        sum(total_item_value_brl) as gross_order_value_brl,
        sum(total_item_value_usd) as gross_order_value_usd,
        avg(brl_to_usd_rate) as applied_brl_to_usd_rate
    from {{ ref('int_order_items_enriched') }}
    group by 1
),

final as (
    select
        -- Keys & Order Info
        dw.order_id,
        dw.customer_id,
        dw.order_status,
        dw.order_date,

        -- 1. Revenue & FX Volatility Metrics
        coalesce(ot.total_items, 0) as total_items,
        coalesce(ot.items_revenue_brl, 0) as items_revenue_brl,
        coalesce(ot.total_freight_brl, 0) as total_freight_brl,
        coalesce(ot.gross_order_value_brl, 0) as gross_order_value_brl,
        coalesce(ot.gross_order_value_usd, 0) as gross_order_value_usd,
        round(ot.applied_brl_to_usd_rate, 4) as applied_brl_to_usd_rate,
        pr.payment_methods,

        -- 2. Delivery Delays & Weather Root-Cause
        dw.actual_delivery_days,
        dw.delay_days,
        dw.delivery_weather_condition,
        dw.delivery_rain_mm,
        case
            when dw.is_late_delivery = false then 'On Time'
            when dw.is_late_delivery is null then 'In Transit / Not Delivered'
            when dw.is_seller_late_dispatch = true then 'Delayed - Seller Late Dispatch'
            when dw.delivery_weather_condition in ('Heavy Rain', 'Light Rain') then 'Delayed - Weather Impact'
            else 'Delayed - Carrier / Distance'
        end as delay_root_cause,

        -- 3. Customer Satisfaction
        pr.avg_review_score,
        case
            when pr.avg_review_score <= 2 then true
            else false
        end as is_bad_review

    from delivery_weather dw
    left join order_totals ot on dw.order_id = ot.order_id
    left join payments_reviews pr on dw.order_id = pr.order_id
)

select * from final
