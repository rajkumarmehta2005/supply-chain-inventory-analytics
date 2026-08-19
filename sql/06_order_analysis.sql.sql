USE supply_chain;

-- Overall order KPIs

SELECT
    COUNT(*) AS total_orders,
    SUM(quantity) AS total_units_sold,
    ROUND(SUM(sales), 2) AS total_sales,
    SUM(fulfilled_flag) AS fulfilled_orders,
    ROUND(
        100 * SUM(fulfilled_flag) /
        NULLIF(COUNT(*), 0),
        2
    ) AS fulfillment_rate
FROM orders;


-- Order status

SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(
        100 * COUNT(*) /
        NULLIF((SELECT COUNT(*) FROM orders), 0),
        2
    ) AS percentage_of_orders
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- Fulfillment by warehouse

SELECT
    warehouse,
    COUNT(*) AS total_orders,
    SUM(fulfilled_flag) AS fulfilled_orders,
    ROUND(
        100 * SUM(fulfilled_flag) /
        NULLIF(COUNT(*), 0),
        2
    ) AS fulfillment_rate
FROM orders
GROUP BY warehouse
ORDER BY fulfillment_rate DESC;


-- Average delivery time

SELECT
    ROUND(
        AVG(
            DATEDIFF(delivery_date, order_date)
        ),
        2
    ) AS average_delivery_days
FROM orders
WHERE delivery_date IS NOT NULL;


-- Delivery time by warehouse

SELECT
    warehouse,
    COUNT(*) AS delivered_orders,
    ROUND(
        AVG(
            DATEDIFF(delivery_date, order_date)
        ),
        2
    ) AS average_delivery_days
FROM orders
WHERE delivery_date IS NOT NULL
GROUP BY warehouse
ORDER BY average_delivery_days;


-- Monthly sales trend

SELECT
    order_year,
    order_month,
    order_month_name,
    COUNT(*) AS orders,
    SUM(quantity) AS units_sold,
    ROUND(SUM(sales), 2) AS total_sales
FROM orders
GROUP BY
    order_year,
    order_month,
    order_month_name
ORDER BY
    order_year,
    order_month;


-- Yearly sales trend

SELECT
    order_year,
    COUNT(*) AS orders,
    SUM(quantity) AS units_sold,
    ROUND(SUM(sales), 2) AS total_sales
FROM orders
GROUP BY order_year
ORDER BY order_year;


-- Warehouse sales performance

SELECT
    warehouse,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS units_sold,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(
        100 * SUM(fulfilled_flag) /
        NULLIF(COUNT(*), 0),
        2
    ) AS fulfillment_rate
FROM orders
GROUP BY warehouse
ORDER BY total_sales DESC;