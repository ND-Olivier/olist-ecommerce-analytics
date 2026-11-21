with customers as (
    select * from {{ ref('stg_customers') }}
),

customer_orders as (
    select
        dw.customer_unique_id,
        count(distinct fo.order_id) as total_orders,
        sum(fo.gross_order_value_usd) as lifetime_value_usd,
        round(avg(fo.avg_review_score), 2) as avg_customer_review_score
    from {{ ref('fct_orders') }} fo
    join {{ ref('int_orders_delivery_weather') }} dw on fo.order_id = dw.order_id
    where fo.order_status = 'delivered'
    group by 1
)

select
    c.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    case c.customer_state
        when 'AC' then 'Acre'
        when 'AL' then 'Alagoas'
        when 'AP' then 'Amapá'
        when 'AM' then 'Amazonas'
        when 'BA' then 'Bahia'
        when 'CE' then 'Ceará'
        when 'DF' then 'Distrito Federal'
        when 'ES' then 'Espírito Santo'
        when 'GO' then 'Goiás'
        when 'MA' then 'Maranhão'
        when 'MT' then 'Mato Grosso'
        when 'MS' then 'Mato Grosso do Sul'
        when 'MG' then 'Minas Gerais'
        when 'PA' then 'Pará'
        when 'PB' then 'Paraíba'
        when 'PR' then 'Paraná'
        when 'PE' then 'Pernambuco'
        when 'PI' then 'Piauí'
        when 'RJ' then 'Rio de Janeiro'
        when 'RN' then 'Rio Grande do Norte'
        when 'RS' then 'Rio Grande do Sul'
        when 'RO' then 'Rondônia'
        when 'RR' then 'Roraima'
        when 'SC' then 'Santa Catarina'
        when 'SP' then 'São Paulo'
        when 'SE' then 'Sergipe'
        when 'TO' then 'Tocantins'
        else c.customer_state
    end as customer_state_name,
    coalesce(co.total_orders, 0) as total_orders,
    coalesce(co.lifetime_value_usd, 0) as lifetime_value_usd,
    co.avg_customer_review_score
from customers c
left join customer_orders co on c.customer_unique_id = co.customer_unique_id
