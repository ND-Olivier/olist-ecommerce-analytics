import os
import requests
import pandas as pd
from google.cloud import bigquery
from dotenv import load_dotenv

# Load environment variables
load_dotenv()
PROJECT_ID = os.getenv("GCP_PROJECT_ID")

# Brazilian e-commerce cities
cities = [
    {"city": "sao paulo", "state": "SP", "lat": -23.5505, "lon": -46.6333},
    {"city": "rio de janeiro", "state": "RJ", "lat": -22.9068, "lon": -43.1729},
    {"city": "belo horizonte", "state": "MG", "lat": -19.9167, "lon": -43.9345},
    {"city": "curitiba", "state": "PR", "lat": -25.4284, "lon": -49.2733},
    {"city": "porto alegre", "state": "RS", "lat": -30.0346, "lon": -51.2177}
]

# Historical Weather API endpoint
url = "https://archive-api.open-meteo.com/v1/archive"

all_weather = []

print("Fetching historical weather data from Open-Meteo API...")

# Fetch weather for each city
for item in cities:
    params = {
        "latitude": item["lat"],
        "longitude": item["lon"],
        "start_date": "2016-09-01",
        "end_date": "2018-10-31",
        "daily": [
            "temperature_2m_mean",
            "precipitation_sum",
            "rain_sum"
        ],
        "timezone": "America/Sao_Paulo"
    }

    response = requests.get(url, params=params, timeout=30)
    response.raise_for_status()

    data = response.json()

    # Convert daily data into a DataFrame
    city_df = pd.DataFrame(data["daily"])
    city_df["city"] = item["city"]
    city_df["state"] = item["state"]

    all_weather.append(city_df)

    print(f"Fetched {len(city_df)} days for {item['city']}.")

# Combine all cities
df = pd.concat(all_weather, ignore_index=True)

print(f"Total weather rows: {len(df)}")

# Load data into BigQuery
client = bigquery.Client(project=PROJECT_ID)

client.create_dataset("raw", exists_ok=True)

table_id = f"{PROJECT_ID}.raw.open_meteo_weather"

job_config = bigquery.LoadJobConfig(
    write_disposition="WRITE_TRUNCATE"
)

job = client.load_table_from_dataframe(
    df,
    table_id,
    job_config=job_config
)

job.result()

print(f"Success! Loaded data into {table_id}")
