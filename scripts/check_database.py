from sqlalchemy import text

from credit_intelligence.database import create_database_engine


def main() -> None:
    engine = create_database_engine()
    with engine.connect() as connection:
        result = connection.execute(
            text("SELECT current_user, current_database(), version()")
        ).one()

    print(f"User: {result[0]}")
    print(f"Database: {result[1]}")
    print(f"Server: {result[2].split(',')[0]}")


if __name__ == "__main__":
    main()
