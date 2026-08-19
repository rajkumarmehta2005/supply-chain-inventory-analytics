USE supply_chain;

-- Overall inventory KPIs

SELECT
    SUM(opening_stock) AS total_opening_stock,
    SUM(units_received) AS total_units_received,
    SUM(units_sold) AS total_units_sold,
    SUM(closing_stock) AS total_closing_stock,
    SUM(damaged_units) AS total_damaged_units,
    ROUND(AVG(average_stock), 2) AS average_stock
FROM inventory;


-- Inventory by warehouse

SELECT
    warehouse,
    SUM(opening_stock) AS opening_stock,
    SUM(units_received) AS units_received,
    SUM(units_sold) AS units_sold,
    SUM(closing_stock) AS closing_stock,
    SUM(damaged_units) AS damaged_units
FROM inventory
GROUP BY warehouse
ORDER BY closing_stock DESC;


-- Stockout rate

SELECT
    COUNT(*) AS total_inventory_records,
    SUM(stockout_flag) AS stockout_records,
    ROUND(
        100 * SUM(stockout_flag) / NULLIF(COUNT(*), 0),
        2
    ) AS stockout_rate_percent
FROM inventory;


-- Stockout by warehouse

SELECT
    warehouse,
    COUNT(*) AS inventory_records,
    SUM(stockout_flag) AS stockout_records,
    ROUND(
        100 * SUM(stockout_flag) / NULLIF(COUNT(*), 0),
        2
    ) AS stockout_rate_percent
FROM inventory
GROUP BY warehouse
ORDER BY stockout_rate_percent DESC;


-- Stockout by product

SELECT
    i.product_id,
    p.product_name,
    p.category,
    SUM(i.stockout_flag) AS stockout_records,
    COUNT(*) AS inventory_records,
    ROUND(
        100 * SUM(i.stockout_flag) / NULLIF(COUNT(*), 0),
        2
    ) AS stockout_rate_percent
FROM inventory i
JOIN products p
    ON i.product_id = p.product_id
GROUP BY
    i.product_id,
    p.product_name,
    p.category
ORDER BY stockout_rate_percent DESC;


-- Inventory turnover

SELECT
    i.product_id,
    p.product_name,
    p.category,
    SUM(i.units_sold) AS units_sold,
    ROUND(AVG(i.average_stock), 2) AS average_stock,
    ROUND(
        SUM(i.units_sold) /
        NULLIF(AVG(i.average_stock), 0),
        2
    ) AS inventory_turnover
FROM inventory i
JOIN products p
    ON i.product_id = p.product_id
GROUP BY
    i.product_id,
    p.product_name,
    p.category
ORDER BY inventory_turnover DESC;


-- Damaged inventory by warehouse

SELECT
    warehouse,
    SUM(damaged_units) AS damaged_units,
    SUM(units_received) AS units_received,
    ROUND(
        100 * SUM(damaged_units) /
        NULLIF(SUM(units_received), 0),
        2
    ) AS damage_rate_percent
FROM inventory
GROUP BY warehouse
ORDER BY damage_rate_percent DESC;