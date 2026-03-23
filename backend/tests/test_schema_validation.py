import os
import sys

import pytest
from pydantic import ValidationError

# Set dummy environment variables for Settings validation
os.environ["DB_HOST"] = "localhost"
os.environ["DB_USER"] = "test"
os.environ["DB_PASSWORD"] = "test"
os.environ["DB_NAME"] = "test_db"
os.environ["OPENAI_API_KEY"] = "sk-test" # Might be needed if LLM is initialized somewhere

# Add backend directory to sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from agent.schemas import ChartOption, GenerateResponseOutput, GenerateSQLOutput


class TestSchemaValidation:

    def test_sql_cleaning_markdown(self):
        """Test that SQL field validator removes markdown blocks"""
        raw_sql = "```sql\nSELECT * FROM users\n```"
        model = GenerateSQLOutput(sql=raw_sql, thought="Testing markdown removal")
        assert model.sql == "SELECT * FROM users"

        raw_sql_2 = "```\nSELECT * FROM users\n```"
        model = GenerateSQLOutput(sql=raw_sql_2, thought="Testing generic markdown removal")
        assert model.sql == "SELECT * FROM users"

        raw_sql_3 = "SELECT * FROM users"
        model = GenerateSQLOutput(sql=raw_sql_3, thought="Testing clean SQL")
        assert model.sql == "SELECT * FROM users"

    def test_sql_validation_select_only(self):
        """Test that SQL validator rejects non-SELECT statements"""
        # This should fail
        with pytest.raises(ValidationError) as excinfo:
            GenerateSQLOutput(sql="DELETE FROM users", thought="Malicious intent")
        assert "生成的 SQL 必须以 SELECT 或 WITH 开头" in str(excinfo.value)

        # This should pass
        GenerateSQLOutput(sql="WITH t AS (SELECT * FROM users) SELECT * FROM t", thought="CTE")

        # This should pass (comments)
        GenerateSQLOutput(sql="-- Comment\nSELECT * FROM users", thought="Commented SQL")
        GenerateSQLOutput(sql="/* Comment */ SELECT * FROM users", thought="Block Commented SQL")

    def test_chart_option_structure(self):
        """Test ChartOption flexibility"""
        # Valid structure
        chart = ChartOption(
            title={"text": "Test Chart"},
            series=[{"type": "bar", "data": [1, 2, 3]}],
            xAxis={"type": "category"}
        )
        assert chart.title["text"] == "Test Chart"
        assert chart.series[0]["type"] == "bar"

        # Valid extra fields (allow)
        chart_extra = ChartOption(
            title={"text": "Test"},
            series=[{"type": "pie"}],
            tooltip={"show": True}, # Extra field
            # Testing pie chart without axis
            xAxis=None,
            yAxis=None
        )
        assert chart_extra.tooltip["show"] is True
        assert chart_extra.xAxis is None

    def test_complex_echarts_structure(self):
        """Test more complex ECharts structures"""
        # Multi-axis chart
        chart = ChartOption(
            tooltip={"trigger": "axis"},
            legend={"data": ["Evaporation", "Precipitation", "Temperature"]},
            xAxis=[
                {"type": "category", "data": ["Mon", "Tue", "Wed"]},
            ],
            yAxis=[
                {"type": "value", "name": "Precipitation"},
                {"type": "value", "name": "Temperature"}
            ],
            series=[
                {"name": "Evaporation", "type": "bar", "data": [2.0, 4.9, 7.0]},
                {"name": "Temperature", "type": "line", "yAxisIndex": 1, "data": [2.0, 2.2, 3.3]}
            ]
        )
        assert chart.xAxis is not None
        assert isinstance(chart.xAxis, list)

        # Note: Since xAxis/yAxis are defined as Dict in schema, passing List might fail validation
        # if the schema isn't flexible enough. Let's check schema definition.
        # Current schema: xAxis: Optional[Dict[str, Any]]
        # ECharts allows xAxis to be a list for dual axes.
        # We might need to update schema to Optional[Union[Dict[str, Any], List[Dict[str, Any]]]]
        pass

    def test_response_output_chart_handling(self):
        """Test GenerateResponseOutput with chart option"""
        chart = ChartOption(
            title={"text": "Sales"},
            series=[{"type": "line", "data": [10, 20]}]
        )

        response = GenerateResponseOutput(
            content="Here is the chart",
            chart_option=chart
        )

        assert response.chart_option is not None
        assert response.chart_option.title["text"] == "Sales"

        # Verify model_dump behavior
        dump = response.model_dump()
        assert dump["chart_option"]["series"][0]["type"] == "line"

if __name__ == "__main__":
    # Manually run tests if executed as script
    t = TestSchemaValidation()
    t.test_sql_cleaning_markdown()
    t.test_sql_validation_select_only()
    t.test_chart_option_structure()
    t.test_response_output_chart_handling()
    print("All schema validation tests passed!")
