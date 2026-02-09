# Web scrapers
## Example

Each config file should look like this:
```json
{
  "scraper_config" :{
    "name": "ARSO_HydroStation_Scraper",
    "description": "Scraper for water level data from ARSO",
    "target_url": "https://www.arso.gov.si/xml/vode/hidro_podatki_zadnji.xml",
    "fetch_interval": 50,
    "selector": "None",
    "limit_results": 100,
    "format": "xml",
    "root_tag": "postaja" # XML root, used to separate nodes (or sensors if there are no nodes)

  },

  # Structured as database_key : scraped_document_key, used to map keys in database to document
  "mapping_config": {
    "node": {
      "node_label": "ARSO_Hydro_Station",
      "node_serial": "sifra",
      "longitude": "wgs84_dolzina",
      "latitude": "wgs84_sirina",
      "altitude": "kota_0"
    },

    # For each sensor inside node (sensors can be standaloen), define values you want to exctract in measurements and its type
    "sensors": [
      {
        "sensor_label": "water_level",
        "sensor_name": "ARSO Water Level Sensor",
        "longitude": "wgs84_dolzina",
        "latitude": "wgs84_sirina",
        "altitude": "kota_0",
        "sensor_description": "Water level sensor data from ARSO",
        "measurements": [
          {"value": "vodostaj", "timestamp_utc": "datum"}
        ],
        "sensor_type": {
          "name": "water_level",
          "phenomenon": "Water Level",
          "unit": "m",
          "value_min": 0,
          "value_max": 1000
        }
      },
      {
        "sensor_label": "water_temperature",
        "sensor_name": "ARSO Water Temperature Sensor",
        "longitude": "wgs84_dolzina",
        "latitude": "wgs84_sirina",
        "altitude": "kota_0",
        "sensor_description": "Water temperature sensor data from ARSO",
        "measurements": [
          {"value": "temp_vode", "timestamp_utc": "datum"}
        ],
        "sensor_type": {
          "name": "water_temperature",
          "phenomenon": "Water Temperature",
          "unit": "°C",
          "value_min": 0,
          "value_max": 100
        }
      }
    ]
}
}
```

Move to `cd web_scraper`

## Run Minio 

To run minio use `docker compose up -d`

Go to http://localhost:9000

## Run scrapers

To activate environment use `conda activate web_scraper_env`

All commands are run from the project root: `python web_scraper.scraper.py [OPTIONS]`

Run every scraper from configs `python scraper.py --config`

Run only specific configs `python scraper.py --config conf1 conf2`

cd web_scraper
conda activate web_scraper_env
python scraper.py --config

## Directory structure
```
web_scraper/
|
|- configs/            # JSON scraper configurations
|- extractors/         # Format-specific data extractors (XML, JSON, CSV, HTML)
|- fetcher.py          # Fetches raw data from URLs
|- mapper.py           # Maps extracted data to nodes and sensors
|- scraper.py          # Main scraper script
|- state/              # Persistent state files (auto-generated)
|- README.md
```

