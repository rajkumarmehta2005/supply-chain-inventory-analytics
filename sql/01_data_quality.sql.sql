USE supply_chain;

-- Row counts
SELECT 'suppliers' AS table_name, COUNT(*) AS row_count FROM suppliers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'inventory', COUNT(*) FROM inventory
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'procurement', COUNT(*) FROM procurement;


-- Duplicate checks

SELECT supplier_id, COUNT(*) AS duplicate_count
FROM suppliers
GROUP BY supplier_id
HAVING COUNT(*) > 1;

SELECT product_id, COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT inventory_id, COUNT(*) AS duplicate_count
FROM inventory
GROUP BY inventory_id
HAVING COUNT(*) > 1;

SELECT order_id, COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT procurement_id, COUNT(*) AS duplicate_count
FROM procurement
GROUP BY procurement_id
HAVING COUNT(*) > 1;


-- Relationship checks

SELECT COUNT(*) AS unmatched_products
FROM products p
LEFT JOIN suppliers s
    ON p.supplier_id = s.supplier_id
WHERE s.supplier_id IS NULL;

SELECT COUNT(*) AS unmatched_inventory
FROM inventory i
LEFT JOIN products p
    ON i.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT COUNT(*) AS unmatched_orders
FROM orders o
LEFT JOIN products p
    ON o.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT COUNT(*) AS unmatched_procurement_suppliers
FROM procurement pr
LEFT JOIN suppliers s
    ON pr.supplier_id = s.supplier_id
WHERE s.supplier_id IS NULL;

SELECT COUNT(*) AS unmatched_procurement_products
FROM procurement pr
LEFT JOIN products p
    ON pr.product_id = p.product_id
WHERE p.product_id IS NULL;