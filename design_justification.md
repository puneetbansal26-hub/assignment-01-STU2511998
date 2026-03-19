## Storage Systems

The hospital's four goals require four distinct storage systems, each chosen to match the nature and access patterns of its data.

**Goal 1 — Readmission Prediction:** Historical patient treatment data lives in a **Data Lakehouse (Delta Lake on S3)**. Raw EHR exports, lab results, and prior hospitalization records are stored as Parquet files, versioned and queryable via Apache Spark. The ML model (XGBoost / LightGBM) is trained on this curated dataset in batch. The Lakehouse is chosen over a pure data warehouse because it stores raw, semi-structured EHR exports without forcing an upfront schema, while still supporting SQL-based feature engineering.

**Goal 2 — Plain-English Patient History Queries:** Structured patient records are stored in **PostgreSQL (OLTP)**, while their text representations (discharge summaries, doctor notes) are chunked, embedded using BioClinicalBERT, and stored in a **Vector Database (Pinecone or pgvector)**. When a doctor asks a question, the query is embedded and an ANN search retrieves the most relevant patient history chunks. A RAG pipeline then synthesizes a natural language answer with citations, referencing the original PostgreSQL record for full context.

**Goal 3 — Monthly Management Reports:** Cleaned, aggregated data is loaded into a **columnar Analytical Data Warehouse (Snowflake or Amazon Redshift)**. A dbt transformation layer standardizes billing records, bed occupancy logs, and department cost data from the Lakehouse into a star schema with `fact_encounters`, `dim_department`, `dim_date`, and `dim_bed` tables. Business Intelligence tools (Tableau, Metabase) connect directly to the DW for self-serve reporting.

**Goal 4 — Real-Time ICU Vitals Streaming:** ICU device data is ingested via **Apache Kafka** and processed in real time by **Apache Flink** (or Spark Structured Streaming). Anomalies (e.g., SpO2 < 90%) trigger immediate alerts to clinical staff. A 7-day Kafka retention window provides a rolling buffer; longer-term vitals are archived to the Lakehouse for retrospective analysis.

---

## OLTP vs OLAP Boundary

The **OLTP boundary** ends at the point where data is written by clinical or operational users in real time: patient admissions and updates in PostgreSQL, ICU vitals arriving over Kafka, and billing entries from admin systems. These systems prioritize **low-latency writes, row-level locking, and ACID compliance** — a doctor updating a prescription must be immediately consistent and durable.

The **OLAP boundary begins** at the ETL/transformation layer. A nightly (or hourly) dbt pipeline extracts records from PostgreSQL and the Lakehouse, applies aggregations, and loads them into Snowflake. Management reports never query the live PostgreSQL database — this separation prevents analytical queries from degrading clinical application performance. The Lakehouse acts as the staging zone between these two worlds: raw data lands there from ingestion, and the DW loads only from the Lakehouse's curated layer.

---

## Trade-offs

**Trade-off: Operational Complexity vs. Best-of-Breed Storage**

The architecture uses five distinct storage systems (PostgreSQL, Kafka, Delta Lake, Snowflake, Vector DB). Each is optimal for its use case, but this introduces significant **operational complexity**: five systems to monitor, back up, secure under HIPAA, and maintain SLAs for. A smaller team might struggle with this surface area.

**Mitigation strategy:** The most practical mitigation is to adopt a **unified data platform** that consolidates several of these layers. For example, Databricks (Delta Lake + Spark + MLflow + Vector Search) covers Goals 1, 2, and partial Goal 4 in a single managed service. Alternatively, Snowflake's Cortex AI feature set now supports vector search and streaming ingestion, reducing the number of independent systems to maintain. A phased rollout approach — starting with PostgreSQL + Snowflake for Goals 1 and 3, then layering in Kafka and Vector DB — allows the team to build operational maturity before adding complexity.

---
