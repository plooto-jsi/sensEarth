from typing import Dict, Any, List, Optional
import hashlib
import os
import json
import asyncio
import argparse

import requests

from fetcher import Fetcher
from mapper import Mapper
from extractors.xml_extractor import XMLExtractor
# from extractors.json_extractor import JSONExtractor
# from extractors.csv_extractor import CSVExtractor
# from extractors.html_extractor import HTMLExtractor

EXTRACTOR_MAP = {
    "xml": XMLExtractor,
    # "json": JSONExtractor,
    # "csv": CSVExtractor,
    # "html": HTMLExtractor
}

API_URL = "http://127.0.0.1:8000"
STATE_DIR = "state"

os.makedirs(STATE_DIR, exist_ok=True)

class Scraper:
    def __init__(self, scraper_config: dict, mapping_config: dict):
        self.scraper_config = scraper_config
        self.mapping_config = mapping_config

        self.fetcher = Fetcher()
        self.mapper = Mapper(mapping_config)

        fmt = scraper_config.get("format")
        if fmt not in EXTRACTOR_MAP:
            raise ValueError(f"Unsupported format: {fmt}")
        if fmt == "html":
            self.extractor = EXTRACTOR_MAP[fmt](selector=scraper_config.get("selector"))
        else:
            self.extractor = EXTRACTOR_MAP[fmt]()

        self.fetch_interval = scraper_config.get("fetch_interval", 0)
        self.name = scraper_config.get("name", "Unnamed Scraper")
        self.limit_results = scraper_config.get("limit_results", None)

        # Load or initialize state
        self.state_file = os.path.join(STATE_DIR, f"{self.name}_state.json")
        if os.path.exists(self.state_file):
            with open(self.state_file, "r") as f:
                self.state = json.load(f)
        else:
            self.state = {"nodes": {}, "sensors": {}}

    def run_once(self):
        raw = self.fetcher.fetch(self.scraper_config["target_url"])
        extracted = self.extractor.extract(raw)
        mapped = self.mapper.map_records(extracted)
        return mapped

    def save_state(self):
        with open(self.state_file, "w") as f:
            json.dump(self.state, f, indent=2)

    def register(self, payload: Dict) -> Dict:
        response = requests.post(f"{API_URL}/register", json=payload)
        data = response.json()

        # Update local state with returned ids
        self.state["nodes"].update(data.get("nodes", {}))
        self.state["sensors"].update(data.get("sensors", {}))
        self.save_state()
        return data

    def send_measurements(self, payload: list[dict]):
        # replace sensor hash with sensor_id
        measurements = []
        for entry in payload:
            for sensor in entry.get("sensors", []):
                sensor_hash = sensor["sensor_hash"]
                sensor_id = self.state["sensors"].get(sensor_hash)
                if not sensor_id:
                    print(f"Skipping unknown sensor {sensor_hash}")
                    continue
                for m in sensor.get("measurements", []):
                    measurements.append({
                        "sensor_id": sensor_id,
                        "sensor_hash": sensor_hash,
                        "timestamp_utc": m["timestamp_utc"],
                        "value": m["value"]
                    })

        if measurements:
            response = requests.post(f"{API_URL}/dataIngest", json=measurements)
            return response.json()
        return {}
    
    def stable_hash(self, obj) -> str:
        """
        Create a stable hash based on sorted JSON representation.
        Ensures same structure gives same hash every run.
        """
        dumped = json.dumps(obj, sort_keys=True, separators=(",", ":"))
        return hashlib.sha256(dumped.encode()).hexdigest()
    
    def hash_records(self, records: list[dict]) -> list[dict]:
        """
        Checks which records have unregistered nodes/sensors.
        """

        hashed = []
        for record in records:
            identifying_fields = {}

            node_data = record.get("node")
            sensors = record.get("sensors", [])

            if "node_hash" not in record:
                node_data["node_hash"] = self.stable_hash(node_data)

            for sensor in sensors:
                if "sensor_hash" not in sensor:
                    if node_data: # sensor has a node
                        identifying_fields["node_hash"] = node_data["node_hash"]

                    identifying_fields = {
                        "node_hash": node_data.get("node_hash"),
                        "sensor_type": sensor.get("sensor_label"),
                        "longitude": sensor.get("longitude"),
                        "latitude": sensor.get("latitude"),
                        "altitude": sensor.get("altitude") if "altitude" in sensor else None,
                    }
                    sensor["sensor_hash"] = self.stable_hash(identifying_fields)
            hashed.append(record)
        return hashed
    
    def unregistered_records(self, records: list[dict]) -> list[dict]:
        """
        Identifies records with unregistered nodes/sensors.
        Returns a payload suitable for /register endpoint.
        """
        to_register = {"nodes": [], "sensors": []}
        for record in records:
            node = record.get("node")
            if node:
                node_hash = node["node_hash"]
                if node_hash not in self.state["nodes"]:
                    to_register["nodes"].append(node)

            for sensor in record.get("sensors", []):
                sensor_hash = sensor["sensor_hash"]
                if sensor_hash not in self.state["sensors"]:
                    sensor_entry = sensor.copy()
                    if node:
                        sensor_entry["node_hash"] = node["node_hash"]
                    to_register["sensors"].append(sensor_entry)

        return to_register



    async def run(self):
        while True:
            try:
                records = self.run_once()
                records = records[: self.limit_results] if self.limit_results else records

                records = self.hash_records(records)
                unregistered = self.unregistered_records(records)
                self.register(unregistered)

                print(f"\n[{self.name}] Mapped records:")
                for r in records:
                    print(r)

                # Then send measurements using registered IDs
                self.send_measurements(records)

                print(f"[{self.name}] Total records processed: {len(records)}\n")

            except Exception as e:
                print(f"[{self.name}] Error during scraping: {e}")

            if self.fetch_interval == 0:
                break
            await asyncio.sleep(self.fetch_interval)


def load_configs(folder="configs", selected=None):
    configs = []
    folder_path = os.path.join(os.path.dirname(__file__), folder)
    for file in os.listdir(folder_path):
        if not file.endswith(".json"):
            continue
        name = os.path.splitext(file)[0]
        if selected and name not in selected:
            continue
        with open(os.path.join(folder_path, file), "r") as f:
            data = json.load(f)
            configs.append((data["scraper_config"], data["mapping_config"]))
    return configs


async def main():
    parser = argparse.ArgumentParser(description="Anomaly Detector CLI")
    parser.add_argument("--config", nargs="*", help="Specify which config(s) to use (none = all)")
    args = parser.parse_args()
    configs = load_configs(selected=args.config)

    scrapers = [Scraper(scraper_conf, mapping_conf) for scraper_conf, mapping_conf in configs]
    await asyncio.gather(*(s.run() for s in scrapers))


if __name__ == "__main__":
    asyncio.run(main())
