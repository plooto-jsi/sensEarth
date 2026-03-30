import React, { useEffect, useMemo, useState } from "react";
import { Card, Spinner } from "react-bootstrap";
import monitoring_api from "../../../monitoring_api"; 

function formatBytes(bytes) {
  if (bytes == null || Number.isNaN(bytes)) return "—";
  const abs = Math.abs(bytes);
  if (abs < 1024) return `${bytes} B`;
  const units = ["KB", "MB", "GB", "TB", "PB"];
  let u = -1;
  let v = abs;
  while (v >= 1024 && u < units.length - 1) {
    v /= 1024;
    u += 1;
  }
  const sign = bytes < 0 ? "-" : "";
  return `${sign}${v.toFixed(v >= 10 ? 1 : 2)} ${units[u]}`;
}

function parsePromMetricsValueLines(text, metricName) {
  // Prometheus exposition format: metric_name{labels} 123.45
  // Sum all samples for the metric (handles multiple disks/nodes).
  const re = new RegExp(
    `^${metricName}(?:\\{[^}]*\\})?\\s+([0-9]+(?:\\.[0-9]+)?)\\s*$`,
    "m"
  );

  let sum = 0;
  let found = false;
  const lines = text.split(/\r?\n/);
  for (const line of lines) {
    if (line.startsWith("#")) continue;
    const m = line.match(re);
    if (!m) continue;
    found = true;
    sum += Number(m[1]);
  }
  return found ? sum : null;
}

export default function DataOverview({ refreshKey }) {
  const [loadingRaw, setLoadingRaw] = useState(true);
  const [rawFreeBytes, setRawFreeBytes] = useState(null);
  const [rawTotalBytes, setRawTotalBytes] = useState(null);

  const [loadingStructured, setLoadingStructured] = useState(true);
  const [lastInsertCount, setLastInsertCount] = useState(null);
  const [lastInsertTimestamp, setLastInsertTimestamp] = useState(null);

  const rawUsedBytes = useMemo(() => {
    if (rawFreeBytes == null || rawTotalBytes == null) return null;
    return Math.max(0, rawTotalBytes - rawFreeBytes);
  }, [rawFreeBytes, rawTotalBytes]);

  const fetchRawStorage = async () => {
    // MinIO prometheus metrics (no auth).
    // Default URL; can be overridden via VITE_MINIO_METRICS_URL at build time.
    const url =
      import.meta?.env?.VITE_MINIO_METRICS_URL ||
      "http://localhost:9000/minio/v2/metrics/cluster";

    try {
      const res = await fetch(url);
      if (!res.ok) throw new Error(`metrics http ${res.status}`);
      const text = await res.text();

      const free = parsePromMetricsValueLines(text, "minio_disk_storage_free_bytes");
      const total = parsePromMetricsValueLines(
        text,
        "minio_disk_storage_total_bytes"
      );

      setRawFreeBytes(free);
      setRawTotalBytes(total);
    } catch (e) {
      console.error("Failed to fetch MinIO metrics:", e);
      setRawFreeBytes(null);
      setRawTotalBytes(null);
    }
    setLoadingRaw(false);
  };

  const fetchStructuredStorage = async () => {
    try {
      const res = await monitoring_api.get("/events");
      const list = Array.isArray(res.data) ? res.data : [];

      const latest = list
        .filter(
          (e) =>
            e.component_name === "middleware" &&
            e.event_type === "data_ingest_completed" &&
            typeof e.message === "string"
        )
        .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp))[0];

      if (!latest) {
        setLastInsertCount(null);
        setLastInsertTimestamp(null);
      } else {
        const m = latest.message.match(/Inserted\s+(\d+)\s+measurements/i);
        setLastInsertCount(m ? Number(m[1]) : null);
        setLastInsertTimestamp(latest.timestamp || null);
      }
    } catch (e) {
      console.error("Failed to fetch structured ingestion event:", e);
      setLastInsertCount(null);
      setLastInsertTimestamp(null);
    }
    setLoadingStructured(false);
  };

  useEffect(() => {
    setLoadingRaw(true);
    setLoadingStructured(true);
    fetchRawStorage();
    fetchStructuredStorage();
  }, [refreshKey]);

  return (
    <Card style={{ width: "100%", height: "100%" }}>
      <Card.Body>
        <div className="border-bottom d-flex justify-content-between align-items-center mb-2">
          <h3 className="mb-0" style={{ fontSize: "1.1rem" }}>
            Data overview
          </h3>
        </div>

        <div className="mt-2">
          <div className="fw-semibold">Raw data storage (MinIO)</div>
          {loadingRaw ? (
            <div className="text-muted small mt-1">
              <Spinner animation="border" size="sm" className="me-2" />
              Loading…
            </div>
          ) : (
            <div className="small mt-1">
              <div>
                <span className="text-muted">Available:</span>{" "}
                <span className="fw-semibold">{formatBytes(rawFreeBytes)}</span>
              </div>
              <div>
                <span className="text-muted">Used:</span>{" "}
                <span className="fw-semibold">{formatBytes(rawUsedBytes)}</span>{" "}
                <span className="text-muted">
                  / {formatBytes(rawTotalBytes)}
                </span>
              </div>
            </div>
          )}
        </div>

        <div className="mt-3">
          <div className="fw-semibold">Structured data storage (DB)</div>
          {loadingStructured ? (
            <div className="text-muted small mt-1">
              <Spinner animation="border" size="sm" className="me-2" />
              Loading…
            </div>
          ) : (
            <div className="small mt-1">
              <div>
                <span className="text-muted">Last insertion:</span>{" "}
                <span className="fw-semibold">
                  {lastInsertCount == null ? "—" : `${lastInsertCount} records`}
                </span>
              </div>
              <div className="text-muted">
                {lastInsertTimestamp
                  ? new Date(lastInsertTimestamp).toLocaleString()
                  : "No recent ingestion event found"}
              </div>
            </div>
          )}
        </div>
      </Card.Body>
    </Card>
  );
}