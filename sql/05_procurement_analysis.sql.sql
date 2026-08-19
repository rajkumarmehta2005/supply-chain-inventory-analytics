USE supply_chain;

-- Overall procurement KPIs

SELECT
    COUNT(*) AS purchase_orders,
    SUM(quantity_ordered) AS quantity_ordered,
    SUM(quantity_received) AS quantity_received,
    ROUND(SUM(procurement_cost), 2) AS procurement_cost,
    ROUND(
        100 * SUM(quantity_received) /
        NULLIF(SUM(quantity_ordered), 0),
        2
    ) AS fulfillment_rate
FROM procurement;


-- Procurement by warehouse

SELECT
    warehouse,
    COUNT(*) AS purchase_orders,
    SUM(quantity_ordered) AS quantity_ordered,
    SUM(quantity_received) AS quantity_received,
    ROUND(SUM(procurement_cost), 2) AS procurement_cost
FROM procurement
GROUP BY warehouse
ORDER BY procurement_cost DESC;


-- Procurement by product

SELECT
    pr.product_id,
    p.product_name,
    p.category,
    SUM(pr.quantity_ordered) AS quantity_ordered,
    SUM(pr.quantity_received) AS quantity_received,
    ROUND(SUM(pr.procurement_cost), 2) AS procurement_cost
FROM procurement pr
JOIN products p
    ON pr.product_id = p.product_id
GROUP BY
    pr.product_id,
    p.product_name,
    p.category
ORDER BY procurement_cost DESC;


-- Average supplier lead time

SELECT
    s.supplier_id,
    s.supplier_name,
    ROUND(
        AVG(
            DATEDIFF(
                pr.actual_delivery_date,
                pr.po_date
            )
        ),
        2
    ) AS average_lead_time_days
FROM suppliers s
JOIN procurement pr
    ON s.supplier_id = pr.supplier_id
WHERE pr.actual_delivery_date IS NOT NULL
GROUP BY
    s.supplier_id,
    s.supplier_name
ORDER BY average_lead_time_days DESC;


-- Late delivery rate

SELECT
    COUNT(*) AS total_purchase_orders,
    SUM(
        CASE
            WHEN actual_delivery_date > expected_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS late_deliveries,
    ROUND(
        100 * SUM(
            CASE
                WHEN actual_delivery_date > expected_delivery_date
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS late_delivery_rate
FROM procurement
WHERE actual_delivery_date IS NOT NULL
AND expected_delivery_date IS NOT NULL;


-- Late deliveries by supplier

SELECT
    s.supplier_id,
    s.supplier_name,
    COUNT(*) AS purchase_orders,
    SUM(
        CASE
            WHEN pr.actual_delivery_date > pr.expected_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS late_deliveries,
    ROUND(
        100 * SUM(
            CASE
                WHEN pr.actual_delivery_date > pr.expected_delivery_date
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS late_delivery_rate
FROM suppliers s
JOIN procurement pr
    ON s.supplier_id = pr.supplier_id
WHERE pr.actual_delivery_date IS NOT NULL
AND pr.expected_delivery_date IS NOT NULL
GROUP BY
    s.supplier_id,
    s.supplier_name
ORDER BY late_delivery_rate DESC;