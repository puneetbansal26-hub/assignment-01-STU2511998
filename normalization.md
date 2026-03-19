## Anomaly Analysis

The source file `orders_flat.csv` is a fully denormalized flat file combining customer, product, sales representative, and order information in a single table. This structure introduces three classical data anomalies.

### Insert Anomaly

**Definition:** It is impossible to insert a new entity without also inserting an unrelated entity.

**Example from dataset:**  
Suppose the company hires a new sales representative **SR04 — Meena Pillai** (meena@corp.com) based in a new Kolkata office. To record this representative in the flat table, a dummy order row must be created — because `sales_rep_id`, `sales_rep_name`, `sales_rep_email`, and `office_address` are only stored as attributes of an order. There is no standalone "sales rep" table. Similarly, a new product like **P009 — Whiteboard (Stationery, ₹1,500)** cannot be inserted without fabricating an order. The flat schema forces every entity to exist only in the context of an order.

**Affected columns:** `sales_rep_id`, `sales_rep_name`, `sales_rep_email`, `office_address`, `product_id`, `product_name`, `category`, `unit_price`

---

### Update Anomaly

**Definition:** Updating a single logical fact requires modifying multiple rows, creating a risk of inconsistency.

**Example from dataset:**  
Sales representative **SR01 — Deepak Joshi** appears in dozens of rows. In rows `ORD1180`, `ORD1183`, `ORD1170`, `ORD1172`, and several others, the `office_address` for SR01 is stored as `"Mumbai HQ, Nariman Pt, Mumbai - 400021"` — an abbreviated version — while in the majority of rows it is `"Mumbai HQ, Nariman Point, Mumbai - 400021"` (full spelling). This inconsistency already exists in the raw data and demonstrates the classic update anomaly: if Deepak Joshi's office address changes, every row mentioning SR01 must be updated. Missed updates leave the data in an inconsistent state. The same pattern applies to any change in `customer_email` or `unit_price`.

**Affected rows/columns:** Rows containing `SR01` in `sales_rep_id`; column `office_address` shows `"Nariman Pt"` vs `"Nariman Point"` inconsistency.

---

### Delete Anomaly

**Definition:** Deleting one entity unintentionally destroys information about another unrelated entity.

**Example from dataset:**  
Customer ** Amit Verma ** (amit@gmail.com , Bangalore) placed order `ORD1185` for `P008 — Webcam`. If this single order row is deleted, the only record thast product **P008 (Webcam, Electronics	2100)** exists in the catalog may be lost because there is no independent `products` or `customers` table. More critically, any product with only one order would be entirely erased from the system upon cancellation or deletion of its sole order. Customer and product identity depends entirely on the existence of order rows.

**Affected rows/columns:** `ORD1185` — deleting it removes `C003` customer info and the only reference to that specific order's product entry context.


---

## Normalization Justification

A manager might argue that keeping everything in one flat table — as in `orders_flat.csv` — is simpler and easier to query. While this view has surface appeal, the dataset itself provides compelling evidence against it.

Consider `sales_rep_id = SR01` (Deepak Joshi). His name, email, and office address are repeated across over 40 rows in the flat file. The office address already appears in two slightly different forms — `"Nariman Point"` and `"Nariman Pt"` — in rows like `ORD1091` versus `ORD1180`. This is not hypothetical danger; it is a real inconsistency that already exists in the data, caused directly by the denormalized structure.

Similarly, `unit_price` for `P001 (Laptop)` is stored in every single order row that contains a laptop. If the company revises the laptop price from ₹55,000 to ₹58,000, the team must update every matching row. Miss even one, and the historical data becomes unreliable — a direct update anomaly.

Normalization resolves these problems by decomposing the flat file into four tables: `customers`, `products`, `sales_reps`, and `orders`. Each fact is stored exactly once. The customer's email lives in `customers`, not repeated per order. The product price lives in `products`, not duplicated across hundreds of rows. A sales rep's office address is stored once in `sales_reps`. Changes require a single UPDATE, not a multi-row sweep.

The cost of normalization — slightly more complex JOIN queries — is minimal compared to the risks of data corruption, wasted storage, and inconsistent reporting. A reporting tool, ORM, or view can always abstract the joins. But once dirty data enters a flat file at scale, cleaning it is expensive and error-prone. The dataset's own inconsistencies prove that normalization is not over-engineering — it is essential data hygiene.

---
