## Architecture Recommendation

For a fast-growing food delivery startup collecting GPS location logs, customer text reviews, payment transactions, and restaurant menu images, I would recommend a **Data Lakehouse** architecture.

**Reason 1 — Multi-modal, heterogeneous data cannot fit a single schema.**  
A traditional Data Warehouse requires all data to be structured and schema-defined upfront. GPS logs are high-frequency time-series records, text reviews are unstructured, menu images are binary blobs, and payment records are relational. A Data Warehouse built for payments cannot natively store images or free-text. A pure Data Lake could store all of these, but it offers no query optimization or ACID guarantees — making it unsuitable for analytical reporting or transactional reads. A Lakehouse (e.g., Delta Lake, Apache Iceberg on object storage) handles all formats natively in a single storage layer with table-level ACID transactions and schema enforcement where needed.

**Reason 2 — The startup needs both real-time ingestion and historical analytics simultaneously.**  
GPS pings arrive in milliseconds; payment records need immediate consistency; but the analytics team wants to run weekly cohort reports on customer behavior across months of data. A Data Warehouse handles batch analytics but struggles with continuous raw ingestion. A pure Data Lake ingests everything but cannot serve low-latency analytical queries efficiently. A Lakehouse supports streaming ingestion (via Apache Kafka + Spark Structured Streaming into Delta tables) while also serving BI tools like Metabase or Superset over the same storage.

**Reason 3 — The architecture must scale cost-effectively with startup growth.**  
Object storage (S3/GCS) underlying a Lakehouse costs a fraction of a managed Data Warehouse at scale. The startup can store raw GPS logs cheaply in Parquet or ORC format, apply compute-on-demand for analytics, and avoid paying for always-on warehouse compute. As data volumes grow from gigabytes to petabytes, the Lakehouse scales storage independently from compute — a critical cost advantage for a startup with unpredictable growth curves.

---
