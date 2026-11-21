with payments as (
    select
        order_id,
        sum(payment_value_brl) as total_paid_brl,
        max(payment_installments) as max_installments,
        string_agg(distinct payment_type, ', ') as payment_methods
    from {{ ref('stg_order_payments') }}
    group by 1
),

reviews as (
    select
        order_id,
        round(avg(review_score), 1) as avg_review_score
    from {{ ref('stg_order_reviews') }}
    group by 1
),

orders as (
    select order_id from {{ ref('stg_orders') }}
)

select
    o.order_id,
    coalesce(p.total_paid_brl, 0) as total_paid_brl,
    coalesce(p.max_installments, 1) as max_installments,
    coalesce(p.payment_methods, 'unknown') as payment_methods,
    r.avg_review_score
from orders o
left join payments p on o.order_id = p.order_id
left join reviews r on o.order_id = r.order_id
