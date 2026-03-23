
from fastapi.testclient import TestClient

from app import app

# raise_server_exceptions=False ensures that the exception handler is called
# instead of the exception being raised directly to the test client.
client = TestClient(app, raise_server_exceptions=False)

def test_global_exception_handler(monkeypatch):
    monkeypatch.setenv("DEV_MODE", "true")
    # Dynamically add a route to the app for testing purposes
    # Note: In a real scenario, adding routes at runtime is discouraged,
    # but for this specific test of the exception handler, it's efficient.

    # We use a unique path to avoid conflicts
    @app.get("/test/error_simulation")
    def trigger_error():
        raise ValueError("Simulated Crash")

    response = client.get("/test/error_simulation")

    assert response.status_code == 500
    data = response.json()
    assert "detail" in data
    assert data["detail"] == "Global Processing Error"
    assert "message" in data
    assert "Simulated Crash" in data["message"]

if __name__ == "__main__":
    try:
        test_global_exception_handler()
        print("✅ Global Exception Handler Test Passed")
    except AssertionError as e:
        print(f"❌ Test Failed: {e}")
    except Exception as e:
        print(f"❌ Error: {e}")
