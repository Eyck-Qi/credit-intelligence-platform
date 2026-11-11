from pathlib import Path

from sqlalchemy import text

from credit_intelligence.database import create_database_engine


def main() -> None:
    schema_path = Path(__file__).resolve().parents[1] / "sql" / "schema.sql"
    schema_sql = schema_path.read_text(encoding="utf-8")
    engine = create_database_engine()

    with engine.begin() as connection:
        connection.execute(text(schema_sql))

    print("Database schema initialized successfully.")


if __name__ == "__main__":
    main()
