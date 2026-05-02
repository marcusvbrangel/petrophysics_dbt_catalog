import subprocess
import sys
from pathlib import Path

import duckdb

project_root = Path(__file__).resolve().parents[1]
dbt = Path(sys.executable).with_name("dbt")
parquet_path = project_root / "data" / "parquet" / "petrophysics"

parquet_path.parent.mkdir(parents=True, exist_ok=True)

subprocess.run(
    [str(dbt), "run", "--select", "+int_petrophysics"],
    cwd=project_root,
    check=True,
)

con = duckdb.connect(str(project_root / "data" / "reservoir.duckdb"))

con.execute(f"""
COPY int_petrophysics
TO '{parquet_path.as_posix()}'
(
    FORMAT PARQUET,
    PARTITION_BY (well_id, zone),
    OVERWRITE_OR_IGNORE TRUE
);
""")

print('Parquet exportado em data/parquet/petrophysics')
