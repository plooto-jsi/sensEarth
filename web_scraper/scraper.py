from typing import Dict, Any, List
import hashlib
import os
import json
import asyncio
import argparse
import requests
import time

from logger import logger
from fetcher import Fetcher
from mapper import Mapper
from utils import retry_request, safe_emit, normalize_altitude
from extractors.xml_extractor import XMLExtractor
# from extractors.json_extractor import JSONExtractor
# from extractors.csv_extractor import CSVExtractor
# from extractors.html_extractor import HTMLExtractor

from monitoring.client import emit_component_registration, emit_event, emit_metric, emit_heartbeat

EXTRACTOR_MAP = {
    "xml": XMLExtractor,
    # "json": JSONExtractor,
    # "csv": CSVExtractor,
    # "html": HTMLExtractor
}

API_URL = "http://middleware-api:8000"
STATE_DIR = "state"

os.makedirs(STATE_DIR, exist_ok=True)

class Scraper:
    def __init__(self, scraper_config: dict, mapping_config: dict):
        """
        Fetcher is responsible for fetching raw data from target URL.
        Extractor is responsible for extracting records from raw data based on format.
        Mapper is responsible for mapping extracted data to the required format.
        State is used to track registered nodes/sensors in JSON file as hash->id mapping.
        """
        self.scraper_config = scraper_config
        self.mapping_config = mapping_config

        self.fetcher = Fetcher()
        self.mapper = Mapper(mapping_config)

        fmt = scraper_config.get("format")
        if fmt not in EXTRACTOR_MAP:
            raise ValueError(f"Unsupported format: {fmt}")
        else:
            self.extractor = EXTRACTOR_MAP[fmt]()

        self.fetch_interval = scraper_config.get("fetch_interval", 0)
        self.name = scraper_config.get("name", "Unnamed Scraper")
        self.limit_results = scraper_config.get("limit_results", None)

        # Load or initialize state
        self.state_file = os.path.join(STATE_DIR, f"{self.name}_state.json")
        self.state = self.load_state()

        safe_emit(emit_component_registration, name="scraper",instance_id=self.name, component_type="scraper")

    def save_state(self):
        with open(self.state_file, "w") as f:
            json.dump(self.state, f, indent=2)

    def load_state(self):
        try:
            if os.path.exists(self.state_file):
                with open(self.state_file, "r", encoding="utf-8") as f:
                    return json.load(f)
            return {"nodes": {}, "sensors": {}}
        except json.JSONDecodeError as e:
            logger.error(f"Error loading state for {self.name}: {e}")
            return {"nodes": {}, "sensors": {}}

    def register(self, payload: Dict) -> Dict:
        """
        Registers nodes and sensors from the payload using the /register endpoint.
        """
        safe_emit(emit_heartbeat, name="scraper", instance_id=self.name, status="OK")
        # Get payload infor and find kota_0 in altitude"
        normalize_altitude(payload)
                
        if not payload.get("nodes") and not payload.get("sensors"):
            return {}  # Nothing to register
        try:
            response = retry_request(
                requests.post,
                retries=5,
                delay=5,
                backoff=2,
                url=f"{API_URL}/register",
                json=payload
            )
            data = response.json()
            self.state["nodes"].update(data.get("nodes", {}))
            self.state["sensors"].update(data.get("sensors", {}))
            self.save_state()

            safe_emit(emit_event, name="scraper",instance_id=self.name,event_type="registration_success",severity="INFO",message=f"Registered {len(data.get('nodes', {}))} nodes and {len(data.get('sensors', {}))} sensors")

            return data
        except Exception as e:
            logger.error(f"Error during registration: {e}")
            safe_emit(emit_event, name="scraper",instance_id=self.name,event_type="registration_failure",severity="ERROR",message=f"Registration failed: {e}")
            return {}

    def send_measurements(self, payload: List[Dict]):
        safe_emit(emit_heartbeat, name="scraper", instance_id=self.name, status="OK")
        measurements = []
        for entry in payload:
            for sensor in entry.get("sensors", []):
                sensor_hash = sensor["sensor_hash"]
                sensor_id = self.state["sensors"].get(sensor_hash)
                if not sensor_id:
                    logger.warning(f"Skipping unknown sensor {sensor_hash}")
                    continue
                for m in sensor.get("measurements", []):
                    measurements.append({
                        "sensor_hash": sensor_hash,
                        "timestamp_utc": m["timestamp_utc"],
                        "value": m["value"]
                    })

        if measurements:
            try:
                response = retry_request(
                    requests.post,
                    retries=5,
                    delay=5,
                    backoff=2,
                    url=f"{API_URL}/dataIngest",
                    json=measurements
                )
                return response.json()

                safe_emit(emit_event, name="scraper",instance_id=self.name,event_type="data_ingest_success",severity="INFO",message=f"Sent measurements successfully")
                safe_emit(emit_metric, name="scraper", instance_id=self.name, metric_name="measurements_sent", value=len(measurements))
            except Exception as e:  
                logger.error(f"Error sending measurements: {e}")
                safe_emit(emit_event, name="scraper",instance_id=self.name,event_type="data_ingest_failure",severity="ERROR",message=f"Failed to send measurements: {e}")
        return {}
    
    def stable_hash(self, obj) -> str:
        """
        Create a stable hash based on sorted JSON representation.
        Ensures same structure gives same hash every run.
        """
        dumped = json.dumps(obj, sort_keys=True, separators=(",", ":"))
        return hashlib.sha256(dumped.encode()).hexdigest()

    def hash_records(self, records: List[Dict]) -> List[Dict]:
        """
        Hash nodes and sensors in records if not already present.
        """
        for record in records:
            node = record.get("node", {})
            node["node_hash"] = node.get("node_hash") or self.stable_hash(node)
            for sensor in record.get("sensors", []):
                if "sensor_hash" not in sensor:
                    st_name = sensor.get("sensor_type", {}).get("name")
                    sensor["sensor_hash"] = self.stable_hash({
                        "node_hash": node["node_hash"],
                        "sensor_type": st_name,
                        "longitude": sensor.get("longitude"),
                        "latitude": sensor.get("latitude"),
                        "altitude": sensor.get("altitude") # Fix if sensor.get("altitude") is not None 
                    })
        return records

    def unregistered_records(self, records: List[Dict]) -> List[Dict]:
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

    def run_once(self):
        loop_start = time.time()
        try: 
            safe_emit(emit_heartbeat, name="scraper", instance_id=self.name, status="OK")
            safe_emit(emit_event, name="scraper",instance_id=self.name,event_type="scrape_started",severity="INFO",message="Scraping cycle started")
            
            raw = self.fetcher.fetch(self.scraper_config["target_url"])
            safe_emit(emit_metric, name="scraper", instance_id=self.name, metric_name="fetch_raw_duration_seconds", value=time.time() - loop_start)

            extracted = self.extractor.extract(raw, self.scraper_config["root_tag"])
            mapped = self.mapper.map_records(extracted)

            safe_emit(emit_metric, name="scraper", instance_id=self.name, metric_name="scrape_duration_seconds", value=time.time() - loop_start)
            return mapped
        except Exception:
            logger.error(f"[{self.name}] Error during scraping run_once")
            safe_emit(emit_event, name="scraper",instance_id=self.name,event_type="scrape_failed",severity="ERROR",message=f"Scraping failed")
            safe_emit(emit_heartbeat, name="scraper", instance_id=self.name, status="FAIL")
            return []

    async def run(self):
        while True:
            try:
                #Scrape and map data
                records = self.run_once()
                records = records[: self.limit_results] if self.limit_results else records

                # Hash every record, register unregistered nodes/sensors and send all measurements
                records = self.hash_records(records)
                unregistered = self.unregistered_records(records)
                self.register(unregistered)
                self.send_measurements(records)

                logger.info(f"[{self.name}] Total records processed: {len(records)}")

            except Exception as e:
                logger.error(f"[{self.name}] Error during scraping: {e}")

            if self.fetch_interval <= 0:
                break
            await asyncio.sleep(self.fetch_interval)
        safe_emit(emit_heartbeat, name="scraper", instance_id=self.name, status="FAIL")

def load_configs(folder="configs", selected=None):
    """
    Loads every .json config pair from specified folder.
    """
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
