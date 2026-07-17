import requests

BASE_URL = "http://localhost:8000"

def test_migration():
    # 1. Login to get token
    login_data = {
        "username": "superadmin",
        "password": "Supplier_Secure_Pwd_2026"
    }
    response = requests.post(f"{BASE_URL}/api/v1/login/token", data=login_data)
    if response.status_code != 200:
        print(f"Login failed: {response.text}")
        return

    token = response.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 2. Upload ZIP for migration
    with open("legacy_test.zip", "rb") as f:
        files = {"file": ("legacy_test.zip", f, "application/zip")}
        response = requests.post(
            f"{BASE_URL}/api/v1/maintenance/migrate-from-legacy-zip",
            headers=headers,
            files=files
        )

    print(f"Migration Response: {response.status_code}")
    print(response.json())

if __name__ == "__main__":
    test_migration()
