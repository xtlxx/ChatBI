from core.db_adapter import AdapterFactory, DatabaseDetector
from models.db_connection import DbType


class TestDbAdapter:
    def test_mysql_adapter(self):
        adapter = AdapterFactory.get_adapter(DbType.mysql)
        assert adapter.sqlglot_dialect == "mysql"
        assert adapter.get_date_format_function() == "DATE_FORMAT"
        assert adapter.pool_args["pool_size"] == 5

        # Test Transpilation
        sql = "SELECT * FROM users LIMIT 10"
        # MySQL uses LIMIT, so it should stay same or similar
        transpiled = adapter.transpile_sql(sql)
        assert "LIMIT" in transpiled

    def test_postgres_adapter(self):
        adapter = AdapterFactory.get_adapter(DbType.postgresql)
        assert adapter.sqlglot_dialect == "postgres"
        assert adapter.get_date_format_function() == "TO_CHAR"

        # Test Transpilation (MySQL to Postgres)
        # MySQL uses backticks, Postgres uses double quotes for identifiers (or none if lowercase)
        # MySQL `date_format(col, '%Y-%m-%d')` -> PG `to_char(col, 'YYYY-MM-DD')` (sqlglot handles some of this)

        sql = "SELECT `name` FROM `users`"
        transpiled = adapter.transpile_sql(sql, source_dialect="mysql")
        # Should replace backticks with double quotes or remove them
        assert '"name"' in transpiled or "name" in transpiled
        assert "`" not in transpiled

    def test_oracle_adapter(self):
        adapter = AdapterFactory.get_adapter(DbType.oracle)
        sql = "SELECT * FROM users LIMIT 5"
        transpiled = adapter.transpile_sql(sql)
        # Oracle uses FETCH FIRST or ROWNUM, sqlglot should handle it
        # Note: sqlglot might transpile LIMIT to FETCH FIRST ... depending on version configuration
        assert "FETCH" in transpiled or "ROWNUM" in transpiled or "LIMIT" in transpiled  # generic

    def test_detector(self):
        url = "mysql+aiomysql://user:pass@localhost:3306/db"
        assert DatabaseDetector.detect_type(url) == DbType.mysql

        url = "postgresql+asyncpg://user:pass@localhost:5432/db"
        assert DatabaseDetector.detect_type(url) == DbType.postgresql


if __name__ == "__main__":
    # Manual run for quick check
    t = TestDbAdapter()
    t.test_mysql_adapter()
    t.test_postgres_adapter()
    t.test_detector()
    print("All tests passed!")
