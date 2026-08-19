USE supply_chain;

-- Product performance

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.sub_category,
    SUM(o.quantity) AS units_sold,
    ROUND(SUM(o.sales), 2) AS total_sales,
    p.unit_cost,
    p.selling_price,
    p.profit_per_unit,
    p.profit_margin
FROM products p
LEFT JOIN orders o
    ON p.product_id = o.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category,
    p.sub_category,
    p.unit_cost,
    p.selling_price,
    p.profit_per_unit,
    p.profit_margin
ORDER BY total_sales DESC;


-- Top 10 products by sales

SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(o.quantity) AS units_sold,
    ROUND(SUM(o.sales), 2) AS total_sales
FROM orders o
JOIN products p
    ON o.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY total_sales DESC
LIMIT 10;


-- Top 10 products by units sold

SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(o.quantity) AS units_sold,
    ROUND(SUM(o.sales), 2) AS total_sales
FROM orders o
JOIN products p
    ON o.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY units_sold DESC
LIMIT 10;


-- Category performance

SELECT
    p.category,
    COUNT(DISTINCT p.product_id) AS total_products,
    SUM(o.quantity) AS units_sold,
    ROUND(SUM(o.sales), 2) AS total_sales,
    ROUND(AVG(p.profit_margin), 2) AS average_profit_margin
FROM products p
LEFT JOIN orders o
    ON p.product_id = o.product_id
GROUP BY p.category
ORDER BY total_sales DESC;