docker compose down


rm -rf ./postgres_data


docker compose up -d


uvicorn app.main:app --reload --host 0.0.0.0 --port 8000