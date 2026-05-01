import duckdb
from pathlib import Path

Path('data/parquet').mkdir(parents=True, exist_ok=True)
con = duckdb.connect('data/reservoir.duckdb')

con.execute("""
CREATE OR REPLACE TABLE raw_logs AS
SELECT *
FROM read_csv_auto('data/raw/synthetic_logs_28_wells.csv');
""")

print(con.execute('SELECT COUNT(*) AS rows FROM raw_logs').df())
print(con.execute('DESCRIBE raw_logs').df())
