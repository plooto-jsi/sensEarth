from __future__ import annotations

from typing import Any

class Enricher:
    """
    Post-process mapped records to ensure hash-stable coordinate fields.

    The Mapper falls back to the mapping token (e.g. "domain_lon") when the
    extracted record misses a key. That breaks stable hashes, so we clean
    those placeholders back to None and propagate coords between `node` and
    each element in `sensors`.
    """

    COORD_FIELDS = ("longitude", "latitude", "altitude")

    def __init__(self, mapping_config: dict[str, Any] | None):
        mapping_config = mapping_config or {}
        node_cfg = mapping_config.get("node") or {}

        # Collect record-key tokens used to populate lon/lat/alt.
        self._coord_tokens: set[str] = set()
        for coord_field in self.COORD_FIELDS:
            token = node_cfg.get(coord_field)
            if isinstance(token, str):
                self._coord_tokens.add(token)

        for sensor_cfg in mapping_config.get("sensors") or []:
            for coord_field in self.COORD_FIELDS:
                token = sensor_cfg.get(coord_field)
                if isinstance(token, str):
                    self._coord_tokens.add(token)

    def _clean_coord_value(self, value: Any) -> Any:
        if value is None:
            return None
        if isinstance(value, str):
            s = value.strip()
            if s == "":
                return None
            # If the Mapper couldn't find the key, it leaves the mapping token.
            if s in self._coord_tokens:
                return None
            return s
        return value

    def _node_key_from_record(self, record: dict[str, Any]) -> str | None:
        """
        Build the cache key `<domain_id>|<domain_shortTitle>` using mapped fields.

        In current mappings:
        - `domain_id` is mapped into `node.node_serial`
        - `domain_shortTitle` is mapped into `sensor.sensor_label`
        """
        node = record.get("node") or {}
        sensors = record.get("sensors") or []

        domain_id = node.get("node_serial")
        domain_short_title = sensors[0].get("sensor_label") if sensors else None

        if domain_id is None or domain_short_title is None:
            return None
        return f"{domain_id}|{domain_short_title}"

    def enrich_records(self, records: list[dict[str, Any]], node_meta: dict[str, dict[str, Any]] | None = None,) -> list[dict[str, Any]]:
        for record in records:
            node = record.get("node") or {}
            sensors = record.get("sensors") or []

            # Clean placeholders first.
            for coord_field in self.COORD_FIELDS:
                if coord_field in node:
                    node[coord_field] = self._clean_coord_value(node.get(coord_field))

            for sensor in sensors:
                for coord_field in self.COORD_FIELDS:
                    if coord_field in sensor:
                        sensor[coord_field] = self._clean_coord_value(sensor.get(coord_field))

            # Backfill missing node coords from local cache (state) if available.
            if node_meta:
                node_key = self._node_key_from_record(record)
                cached = node_meta.get(node_key) if node_key else None
                if isinstance(cached, dict):
                    for coord_field in self.COORD_FIELDS:
                        if node.get(coord_field) is None and cached.get(coord_field) is not None:
                            node[coord_field] = cached.get(coord_field)

            # If node is missing a coordinate, try to copy it from the first sensor that has it.
            sensor_first_with_value: dict[str, Any] = {k: None for k in self.COORD_FIELDS}
            for coord_field in self.COORD_FIELDS:
                for sensor in sensors:
                    val = sensor.get(coord_field)
                    if val is not None:
                        sensor_first_with_value[coord_field] = val
                        break

            for coord_field in self.COORD_FIELDS:
                if node.get(coord_field) is None and sensor_first_with_value[coord_field] is not None:
                    node[coord_field] = sensor_first_with_value[coord_field]

            # If sensors are missing coords but node has them, propagate node coords to all sensors.
            for sensor in sensors:
                for coord_field in self.COORD_FIELDS:
                    if sensor.get(coord_field) is None and node.get(coord_field) is not None:
                        sensor[coord_field] = node.get(coord_field)

            record["node"] = node
            record["sensors"] = sensors

        return records

