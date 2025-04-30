-- Q:1 Find top 10 highest revenue generating product.
select product_id, sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc
limit 10;
-- Q:2 Find top 5 highest selling products in each region
with top_5_region as (
select region, product_id, sum(sale_price) as sales
from df_orders
group by region,product_id
order by region, sales desc)
select * from (
select *
, row_number() over (partition by region order by sales desc) as rnk
from top_5_region) as A
where rnk <=5;

-- Q:3 Find month over month growth comparison for 2022 and 2023 sales eg: Jan 2022 vs Jan 2023
with cte as (select year(order_date) as order_year, month(order_date) as order_month, sum(sale_price) as sales
from df_orders
group by year(order_date), month(order_date)
order by year(order_date), month(order_date) asc
)
select order_month
, sum(case when order_year = 2022 then sales else 0 end) as sales_2022
, sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month;

-- Q:4 For each category which month has highest sales
with cte as (
select category, date_format(order_date,'%y%m') as order_year_month
,sum(sale_price) as sales
from df_orders
group by category,date_format(order_date,'%y%m')
-- order by category,date_format(order_date,'%y%m')
)
select * from(
select *
, row_number() over(partition by category order by sales desc) as rn
from cte) a
where rn = 1;

-- Q:4 which sub category had highest growth by profit in 2023 compare to 2022
with cte as (
select sub_category,year(order_date) as order_year,
sum(sale_price) as sales
from df_orders
group by sub_category, year(order_date)
-- order by sub_category, year(order_date)
)
, cte2 as (
select sub_category
, sum(case when order_year = 2022 then sales else 0 end) as sales_2022
, sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by sub_category
)
select *
, (sales_2023-sales_2022)*100/sales_2022
from cte2
order by (sales_2023-sales_2022)*100/sales_2022 desc
limit 1;
