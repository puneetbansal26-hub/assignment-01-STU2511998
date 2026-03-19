## ETL Decisions

### Decision 1 — Date Format Standardization

**Problem:**  
The `date` column in `retail_transactions.csv` contains dates in at least three different formats across rows: ISO format (`2023-08-22`), slash-delimited (`29/08/2023`, `12/05/2023`), and hyphen-delimited with DD-first ordering (`12-12-2023`, `20-02-2023`). All three formats appear in the same column. A direct load into a DATE field in any SQL database would fail or silently corrupt values — for example, `12-12-2023` could be misread as December 12 or as an invalid date depending on locale settings.

**Resolution:**  
During transformation, all date strings were parsed using a multi-format date parser (e.g., Python's `dateutil.parser.parse()` with `dayfirst=True` as the default for DD/MM/YYYY formats). Each value was normalized to the ISO 8601 standard format `YYYY-MM-DD` before insertion. Integer surrogate keys in the format `YYYYMMDD` (e.g., `20230822`) were then generated for `dim_date` to enable fast integer-based joins and range filtering in the warehouse.

---

### Decision 2 — Category Casing and Label Normalization

**Problem:**  
The `category` column contains the same logical category spelled in multiple inconsistent ways: `'electronics'` (all lowercase), `'Electronics'` (title case), `'Grocery'` (singular), and `'Groceries'` (plural) all appear in the dataset. Without normalization, GROUP BY queries on category would produce multiple rows for what should be a single group — for example, a revenue report would show separate rows for `Electronics` and `electronics`, splitting data that should be aggregated together.

**Resolution:**  
All category values were upper-cased, trimmed of whitespace, and mapped to a canonical set: `'Electronics'`, `'Clothing'`, and `'Grocery'`. The mapping `'Groceries' → 'Grocery'` was applied explicitly. This canonical list was loaded into `dim_product.category` as a controlled vocabulary. Any future raw data with non-canonical values would be flagged by a validation step before loading.

---

### Decision 3 — Surrogate Key Generation for Dimension Tables

**Problem:**  
The source file contains no primary keys for stores or products — only plain text names like `"Chennai Anna"` or `"Laptop"`. Using raw name strings as foreign keys in `fact_sales` would create wide, string-heavy fact rows that are slow to join and fragile to typos or name changes (e.g., if a store is renamed, all fact rows would require updates).

**Resolution:**  
Integer surrogate keys (`store_key`, `product_key`) were generated during the ETL load for `dim_store` and `dim_product`. The fact table references only these integer keys, keeping rows narrow and joins fast. The original business names are preserved only in the dimension tables, which are updated once. This also future-proofs the schema: if `"Chennai Anna"` is rebranded, only one row in `dim_store` changes — all `fact_sales` rows remain intact.

---
