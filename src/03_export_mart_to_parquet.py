import duckdb
from pathlib import Path

Path('data/parquet').mkdir(parents=True, exist_ok=True)
con = duckdb.connect('data/reservoir.duckdb')

con.execute("""
COPY int_petrophysics
TO 'data/parquet/petrophysics'
(
    FORMAT PARQUET,
    PARTITION_BY (well_id, zone),
    OVERWRITE_OR_IGNORE TRUE
);
""")

print('Parquet exportado em data/parquet/petrophysics')
