USE supply_chain;

-- Supplier performance

SELECT
    s.supplier_id,
    s.supplier_name,
    s.supplier_city,
    s.supplier_state,
    s.supplier_rating,
    COUNT(pr.procurement_id) AS purchase_orders,
    SUM(pr.quantity_ordered) AS quantity_ordered,
    SUM(pr.quantity_received) AS quantity_received,
    ROUND(SUM(pr.procurement_cost), 2) AS procurement_cost
FROM suppliers s
LEFT JOIN procurement pr
    ON s.supplier_id = pr.supplier_id
GROUP BY
    s.supplier_id,
    s.supplier_name,
    s.supplier_city,
    s.supplier_state,
    s.supplier_rating
ORDER BY procurement_cost DESC;


-- Supplier fulfillment rate

SELECT
    s.supplier_id,
    s.supplier_name,
    SUM(pr.quantity_ordered) AS quantity_ordered,
    SUM(pr.quantity_received) AS quantity_received,
    ROUND(
        100 * SUM(pr.quantity_received) /
        NULLIF(SUM(pr.quantity_ordered), 0),
        2
    ) AS fulfillment_rate
FROM suppliers s
JOIN procurement pr
    ON s.supplier_id = pr.supplier_id
GROUP BY
    s.supplier_id,
    s.supplier_name
ORDER BY fulfillment_rate DESC;


-- Supplier rating vs procurement spend

SELECT
    s.supplier_id,
    s.supplier_name,
    s.supplier_rating,
    ROUND(SUM(pr.procurement_cost), 2) AS procurement_spend
FROM suppliers s
JOIN procurement pr
    ON s.supplier_id = pr.supplier_id
GROUP BY
    s.supplier_id,
    s.supplier_name,
    s.supplier_rating
ORDER BY procurement_spend DESC;


-- Top suppliers by spend

SELECT
    s.supplier_id,
    s.supplier_name,
    ROUND(SUM(pr.procurement_cost), 2) AS procurement_spend
FROM suppliers s
JOIN procurement pr
    ON s.supplier_id = pr.supplier_id
GROUP BY
    s.supplier_id,
    s.supplier_name
ORDER BY procurement_spend DESC
LIMIT 10;