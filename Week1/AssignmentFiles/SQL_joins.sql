USE coffeeshop_db;

-- =========================================================
-- JOINS & RELATIONSHIPS PRACTICE
-- =========================================================

-- Q1) Join products to categories: list product_name, category_name, price.

select products.name as product_name, categories.name as category_name, products.price from products
join categories on products.category_id = categories.category_id;

-- Q2) For each order item, show: order_id, order_datetime, store_name,
--     product_name, quantity, line_total (= quantity * products.price).
--     Sort by order_datetime, then order_id.
with cte as (
select order_items.order_id, orders.order_datetime, products.name as product_name, quantity, sum(quantity * products.price) as line_total, store_id
from order_items
join products on order_items.product_id = products.product_id
join orders on orders.order_id = order_items.order_id
group by orders.order_datetime, order_items.order_id, product_name, quantity
order by order_id
)

select * from cte
join stores on cte.store_id = stores.store_id
;


-- Q3) Customer order history (PAID only):
--     For each order, show customer_name, store_name, order_datetime,
--     order_total (= SUM(quantity * products.price) per order).

with cte_total as (
select order_id, products.name as product_name, sum(quantity * products.price) as order_total
from order_items
join products on order_items.product_id = products.product_id
group by order_id, product_name
), cte as (
select order_id, order_datetime, orders.store_id, stores.name as store_name, orders.customer_id, concat(customers.first_name, ' ', customers.last_name) as customer_name
from orders
join stores on orders.store_id = stores.store_id
join customers on orders.customer_id = customers.customer_id
)

select customer_name, store_name, order_datetime, order_total from cte
join cte_total on cte.order_id = cte_total.order_id
order by order_datetime;

-- Q4) Left join to find customers who have never placed an order.
--     Return first_name, last_name, city, state.
select first_name, last_name, city, state
from customers
left join orders on customers.customer_id = orders.customer_id
where orders.customer_id is null;


-- Q5) For each store, list the top-selling product by units (PAID only).
--     Return store_name, product_name, total_units.
--     Hint: Use a window function (ROW_NUMBER PARTITION BY store) or a correlated subquery.
select stores.name as store_name, products.name as product_name, row_number() over(partition by stores.name order by order_items.quantity) as total_units
from stores join orders on stores.store_id = orders.store_id
join order_items on orders.order_id = order_items.order_id
join products on order_items.product_id = products.product_id
where status = 'paid';

-- Q6) Inventory check: show rows where on_hand < 12 in any store.
--     Return store_name, product_name, on_hand.

select stores.name as store_name, products.name as product_name, on_hand
from inventory
join stores on inventory.store_id = stores.store_id
join products on inventory.product_id = products.product_id
where on_hand < 12;


-- Q7) Manager roster: list each store's manager_name and hire_date.
--     (Assume title = 'Manager').

select stores.name as store_name, concat(employees.first_name, ' ', employees.last_name) as manager_name, hire_date
from employees
join stores on emplyees.store_id = stores.store_id
where emplyees.title = 'Manager';

-- Q8) Using a subquery/CTE: list products whose total PAID revenue is above
--     the average PAID product revenue. Return product_name, total_revenue.

with cte_total as (
select products.name as product_name, sum(quantity * products.price) as total_revenue
from order_items
join products on order_items.product_id = products.product_id
join orders on order_items.order_id = orders.order_id
where orders.status = 'paid'
group by product_name
), cte as (
select products.name as product_name, avg(quantity * products.price) as avg_revenue
from order_items
join products on order_items.product_id = products.product_id
join orders on order_items.order_id = orders.order_id
where orders.status = 'paid'
group by product_name
)

select cte_total.product_name, cte_total.total_revenue
from cte_total
join cte on cte_total.product_name = cte.product_name
where total_revenue > avg_revenue;

-- Q9) Churn-ish check: list customers with their last PAID order date.
--     If they have no PAID orders, show NULL.
--     Hint: Put the status filter in the LEFT JOIN's ON clause to preserve non-buyer rows.
-- come back to this

select concat(customers.first_name, ' ', customers.last_name) as customer_name, orders.order_datetime
from customers
join orders on customer.customer_id = orders.order_id
where status = 'paid';

-- Q10) Product mix report (PAID only):
--     For each store and category, show total units and total revenue (= SUM(quantity * products.price)).

with cte as (
select order_items.product_id, stores.name as store, order_items.quantity
from stores
join orders on stores.store_id = orders.store_id
join order_items on orders.order_id = order_items.order_id
where status = 'paid'
), cte_units as (
select cte.store, sum(cte.quantity) as total_units, sum(cte.quantity * products.price) as total_revenue, products.category_id
from cte
join products on cte.product_id = products.product_id
group by store, products.category_id
)

select store, categories.name as category, total_units, total_revenue
from cte_units
join categories on cte_units.category_id = categories.category_id;