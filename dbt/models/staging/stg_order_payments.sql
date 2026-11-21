with source as (
    select * from {{ source('raw_ecom', 'olist_order_payments') }}
),

cleaned as (
    select
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        round(cast(payment_value as numeric), 2) as payment_value_brl
    from source
)

select * from cleaned
