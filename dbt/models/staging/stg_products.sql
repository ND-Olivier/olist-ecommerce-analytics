with products as (
    select * from {{ source('raw_ecom', 'olist_products') }}
),

translations as (
    select
        string_field_0 as category_pt,
        string_field_1 as category_en
    from {{ source('raw_ecom', 'product_category_name_translation') }}
    where string_field_0 != 'product_category_name'
),

joined as (
    select
        p.product_id,
        coalesce(t.category_en, p.product_category_name, 'unknown') as category_name,
        p.product_weight_g,
        p.product_length_cm,
        p.product_height_cm,
        p.product_width_cm
    from products p
    left join translations t
        on p.product_category_name = t.category_pt
)

select * from joined
