with source as (
    select * from {{ source('raw_ecom', 'olist_order_reviews') }}
),

cleaned as (
    select
        review_id,
        order_id,
        cast(review_score as int64) as review_score,
        review_comment_title,
        review_comment_message,
        cast(review_creation_date as timestamp) as review_created_at
    from source
)

select * from cleaned
