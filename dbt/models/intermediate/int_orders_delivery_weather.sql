with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select customer_id, customer_unique_id, customer_city, customer_state from {{ ref('stg_customers') }}
),

seller_deadlines as (
    select
        order_id,
        max(shipping_limit_at) as max_shipping_limit_at
    from {{ ref('stg_order_items') }}
    group by 1
),

weather as (
    select * from {{ ref('stg_weather') }}
),

enriched as (
    select
        o.order_id,
        o.customer_id,
        c.customer_unique_id,
        c.customer_city,
        c.customer_state,
        o.order_status,
        o.ordered_at,
        o.order_date,
        o.shipped_at,
        sd.max_shipping_limit_at,
        o.delivered_at,
        date(o.delivered_at) as delivered_date,
        o.estimated_delivery_at,

        -- Delivery duration metrics
        timestamp_diff(o.delivered_at, o.ordered_at, day) as actual_delivery_days,
        timestamp_diff(o.estimated_delivery_at, o.ordered_at, day) as estimated_delivery_days,
        timestamp_diff(o.delivered_at, o.estimated_delivery_at, day) as delay_days,

        -- Root cause flags: Was it the seller or the carrier/weather?
        case
            when o.shipped_at is not null and o.shipped_at > sd.max_shipping_limit_at then true
            else false
        end as is_seller_late_dispatch,

        case
            when o.delivered_at is null then null
            when o.delivered_at > o.estimated_delivery_at then true
            else false
        end as is_late_delivery,

        -- Weather context on delivery date in customer's city
        coalesce(w.weather_condition, 'Not Monitored') as delivery_weather_condition,
        w.avg_temp_c as delivery_avg_temp_c,
        w.rain_mm as delivery_rain_mm

    from orders o
    left join customers c on o.customer_id = c.customer_id
    left join seller_deadlines sd on o.order_id = sd.order_id
    left join weather w 
        on date(o.delivered_at) = w.weather_date 
        and c.customer_city = w.city 
        and c.customer_state = w.state
)

select * from enriched
