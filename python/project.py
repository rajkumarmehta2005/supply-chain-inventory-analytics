from pathlib import Path
import pandas as pd


# ============================================================
# 1. PROJECT PATHS
# ============================================================

BASE_DIR = Path(__file__).resolve().parent

RAW_DIR = BASE_DIR / "raw_data"
CLEANED_DIR = BASE_DIR / "cleaned_data"
OUTPUT_DIR = BASE_DIR / "output"

# Create folders if they don't exist
CLEANED_DIR.mkdir(exist_ok=True)
OUTPUT_DIR.mkdir(exist_ok=True)


# ============================================================
# 2. LOAD RAW DATA
# ============================================================

products = pd.read_csv(RAW_DIR / "products.csv")
suppliers = pd.read_csv(RAW_DIR / "suppliers.csv")
inventory = pd.read_csv(RAW_DIR / "inventory.csv")
orders = pd.read_csv(RAW_DIR / "orders.csv")
procurement = pd.read_csv(RAW_DIR / "procurement.csv")


print("=" * 60)
print("RAW DATA LOADED")
print("=" * 60)

print("Products:", products.shape)
print("Suppliers:", suppliers.shape)
print("Inventory:", inventory.shape)
print("Orders:", orders.shape)
print("Procurement:", procurement.shape)


# ============================================================
# 3. BASIC INSPECTION
# ============================================================

datasets = {
    "Products": products,
    "Suppliers": suppliers,
    "Inventory": inventory,
    "Orders": orders,
    "Procurement": procurement
}

print("\n" + "=" * 60)
print("MISSING VALUES")
print("=" * 60)

for name, df in datasets.items():
    print(f"\n{name}")
    print(df.isnull().sum())


print("\n" + "=" * 60)
print("DUPLICATES")
print("=" * 60)

for name, df in datasets.items():
    print(f"{name}: {df.duplicated().sum()}")


# ============================================================
# 4. REMOVE DUPLICATES
# ============================================================

products = products.drop_duplicates()
suppliers = suppliers.drop_duplicates()
inventory = inventory.drop_duplicates()
orders = orders.drop_duplicates()
procurement = procurement.drop_duplicates()


# ============================================================
# 5. CLEAN COLUMN NAMES
# ============================================================

def clean_column_names(df):
    df.columns = (
        df.columns
        .str.strip()
        .str.lower()
        .str.replace(" ", "_")
        .str.replace("-", "_")
    )
    return df


products = clean_column_names(products)
suppliers = clean_column_names(suppliers)
inventory = clean_column_names(inventory)
orders = clean_column_names(orders)
procurement = clean_column_names(procurement)


# ============================================================
# 6. CONVERT DATE COLUMNS
# ============================================================

if "date" in inventory.columns:
    inventory["date"] = pd.to_datetime(
        inventory["date"],
        errors="coerce"
    )

if "order_date" in orders.columns:
    orders["order_date"] = pd.to_datetime(
        orders["order_date"],
        errors="coerce"
    )

if "procurement_date" in procurement.columns:
    procurement["procurement_date"] = pd.to_datetime(
        procurement["procurement_date"],
        errors="coerce"
    )


# ============================================================
# 7. CONVERT NUMERIC COLUMNS
# ============================================================

numeric_columns = {
    "products": [
        "unit_cost",
        "selling_price"
    ],

    "suppliers": [
        "lead_time_days",
        "supplier_rating"
    ],

    "inventory": [
        "opening_stock",
        "received_quantity",
        "demand_quantity",
        "closing_stock"
    ],

    "orders": [
        "order_quantity"
    ],

    "procurement": [
        "quantity",
        "unit_cost",
        "total_cost"
    ]
}


for column in numeric_columns["products"]:
    if column in products.columns:
        products[column] = pd.to_numeric(
            products[column],
            errors="coerce"
        )


for column in numeric_columns["suppliers"]:
    if column in suppliers.columns:
        suppliers[column] = pd.to_numeric(
            suppliers[column],
            errors="coerce"
        )


for column in numeric_columns["inventory"]:
    if column in inventory.columns:
        inventory[column] = pd.to_numeric(
            inventory[column],
            errors="coerce"
        )


for column in numeric_columns["orders"]:
    if column in orders.columns:
        orders[column] = pd.to_numeric(
            orders[column],
            errors="coerce"
        )


for column in numeric_columns["procurement"]:
    if column in procurement.columns:
        procurement[column] = pd.to_numeric(
            procurement[column],
            errors="coerce"
        )


# ============================================================
# 8. HANDLE MISSING VALUES
# ============================================================

# Numeric columns → median
# Text columns → "Unknown"

for df in [products, suppliers, inventory, orders, procurement]:

    for column in df.columns:

        if df[column].dtype in ["int64", "float64"]:

            df[column] = df[column].fillna(
                df[column].median()
            )

        else:

            df[column] = df[column].fillna("Unknown")


# ============================================================
# 9. FEATURE ENGINEERING — INVENTORY
# ============================================================

if "opening_stock" in inventory.columns:

    inventory["average_stock"] = (
        inventory["opening_stock"] +
        inventory["closing_stock"]
    ) / 2


if (
    "demand_quantity" in inventory.columns
    and "opening_stock" in inventory.columns
):

    inventory["stockout_flag"] = (
        inventory["demand_quantity"]
        > inventory["opening_stock"]
    ).astype(int)


if "demand_quantity" in inventory.columns:

    inventory["demand_category"] = pd.cut(
        inventory["demand_quantity"],
        bins=[-1, 10, 50, 100, float("inf")],
        labels=[
            "Low",
            "Medium",
            "High",
            "Very High"
        ]
    )


# ============================================================
# 10. FEATURE ENGINEERING — ORDERS
# ============================================================

if "order_date" in orders.columns:

    orders["order_year"] = orders["order_date"].dt.year
    orders["order_month"] = orders["order_date"].dt.month
    orders["order_month_name"] = (
        orders["order_date"].dt.month_name()
    )


if "order_status" in orders.columns:

    orders["fulfilled_flag"] = (
        orders["order_status"]
        .astype(str)
        .str.lower()
        .eq("delivered")
        .astype(int)
    )


# ============================================================
# 11. FEATURE ENGINEERING — PROCUREMENT
# ============================================================

if (
    "quantity" in procurement.columns
    and "unit_cost" in procurement.columns
):

    procurement["calculated_total_cost"] = (
        procurement["quantity"]
        * procurement["unit_cost"]
    )


if "procurement_date" in procurement.columns:

    procurement["procurement_year"] = (
        procurement["procurement_date"].dt.year
    )

    procurement["procurement_month"] = (
        procurement["procurement_date"].dt.month
    )

    procurement["procurement_month_name"] = (
        procurement["procurement_date"].dt.month_name()
    )


# ============================================================
# 12. FEATURE ENGINEERING — PRODUCTS
# ============================================================

if (
    "selling_price" in products.columns
    and "unit_cost" in products.columns
):

    products["profit_per_unit"] = (
        products["selling_price"]
        - products["unit_cost"]
    )


if (
    "selling_price" in products.columns
    and "unit_cost" in products.columns
):

    products["profit_margin"] = (
        products["profit_per_unit"]
        / products["selling_price"]
    )


# ============================================================
# 13. SAVE CLEANED CSV FILES
# ============================================================

products.to_csv(
    CLEANED_DIR / "products_cleaned.csv",
    index=False
)

suppliers.to_csv(
    CLEANED_DIR / "suppliers_cleaned.csv",
    index=False
)

inventory.to_csv(
    CLEANED_DIR / "inventory_cleaned.csv",
    index=False
)

orders.to_csv(
    CLEANED_DIR / "orders_cleaned.csv",
    index=False
)

procurement.to_csv(
    CLEANED_DIR / "procurement_cleaned.csv",
    index=False
)


print("\n" + "=" * 60)
print("CLEANED CSV FILES SAVED")
print("=" * 60)

print(CLEANED_DIR / "products_cleaned.csv")
print(CLEANED_DIR / "suppliers_cleaned.csv")
print(CLEANED_DIR / "inventory_cleaned.csv")
print(CLEANED_DIR / "orders_cleaned.csv")
print(CLEANED_DIR / "procurement_cleaned.csv")


# ============================================================
# 14. CREATE EXCEL WORKBOOK
# ============================================================

excel_path = OUTPUT_DIR / "supply_chain_cleaned_data.xlsx"

with pd.ExcelWriter(excel_path, engine="openpyxl") as writer:

    products.to_excel(
        writer,
        sheet_name="Products",
        index=False
    )

    suppliers.to_excel(
        writer,
        sheet_name="Suppliers",
        index=False
    )

    inventory.to_excel(
        writer,
        sheet_name="Inventory",
        index=False
    )

    orders.to_excel(
        writer,
        sheet_name="Orders",
        index=False
    )

    procurement.to_excel(
        writer,
        sheet_name="Procurement",
        index=False
    )


print("\n" + "=" * 60)
print("EXCEL WORKBOOK CREATED")
print("=" * 60)

print(excel_path)


# ============================================================
# 15. FINAL DATASET SUMMARY
# ============================================================

print("\n" + "=" * 60)
print("FINAL DATASET SUMMARY")
print("=" * 60)

final_datasets = {
    "Products": products,
    "Suppliers": suppliers,
    "Inventory": inventory,
    "Orders": orders,
    "Procurement": procurement
}

for name, df in final_datasets.items():

    print(
        f"{name}: "
        f"{df.shape[0]} rows × "
        f"{df.shape[1]} columns"
    )


# ============================================================
# 16. FINAL CHECK
# ============================================================

print("\n" + "=" * 60)
print("PROJECT PYTHON STAGE COMPLETED")
print("=" * 60)

print("Cleaned data folder:")
print(CLEANED_DIR)

print("\nOutput folder:")
print(OUTPUT_DIR)

print("\nNext stage: MySQL / SQL Analysis")