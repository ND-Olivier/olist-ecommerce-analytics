import os
import requests
import pandas as pd
from google.cloud import bigquery
from dotenv import load_dotenv

# Load environment variables
load_dotenv()
PROJECT_ID = os.getenv("GCP_PROJECT_ID")

# Fetch historical exchange rates for Olist period (2016-2018)
print("Fetching exchange rates from Frankfurter API...")

url = "https://api.frankfurter.dev/v2/rates"
params = {
    "base": "BRL",
    "quotes": "USD,EUR",
    "from": "2016-09-01",
    "to": "2018-10-31"
}

response = requests.get(url, params=params, timeout=30)
response.raise_for_status()

data = response.json()

# Convert JSON into a DataFrame
df = pd.DataFrame(data)
print(f"Fetched {len(df)} rows.")

# Load data into BigQuery (overwrite the previous table)
client = bigquery.Client(project=PROJECT_ID)
client.create_dataset("raw", exists_ok=True)

table_id = f"{PROJECT_ID}.raw.frankfurter_fx"
job_config = bigquery.LoadJobConfig(write_disposition="WRITE_TRUNCATE")

job = client.load_table_from_dataframe(df, table_id, job_config=job_config)
job.result()

print(f"Success! Loaded data into {table_id}")
