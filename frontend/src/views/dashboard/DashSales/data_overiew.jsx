import React, { useEffect, useState } from "react";
import { Card, Spinner, Row, Col } from "react-bootstrap";
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

function StatCard({ label, value, subtext }) {
  return (
    <div
      style={{
        background: "#f8f9fa",
        borderRadius: "10px",
        padding: "12px 14px",
        height: "100%",
      }}
    >
      <div className="text-muted" style={{ fontSize: "0.8rem" }}>
        {label}
      </div>
      <div className="fw-semibold" style={{ fontSize: "1.1rem" }}>
        {value}
      </div>
      {subtext && (
        <div className="text-muted" style={{ fontSize: "0.75rem" }}>
          {subtext}
        </div>
      )}
    </div>
  );
}

export default function DataOverview({ refreshKey }) {
  const [loading, setLoading] = useState(true);
  const [data, setData] = useState({});

  const fetchStructuredStorage = async () => {
    try {
      const res = await monitoring_api.get("/events");
      const list = Array.isArray(res.data) ? res.data : [];

      const filtered = list
        .filter(
          (e) =>
            e.component_name === "middleware" &&
            e.event_type === "data_ingest_completed" &&
            typeof e.message === "string"
        )
        .sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));

      const latest = filtered[filtered.length - 1];

      if (!latest) {
        setData({});
      } else {
        const counts = filtered.map((e) => {
          const m = e.message.match(/Inserted\s+(\d+)\s+measurements/i);
          return m ? Number(m[1]) : 0;
        });

        const total = counts.reduce((a, b) => a + b, 0);

        const latestMatch = latest.message.match(/Inserted\s+(\d+)\s+measurements/i);
        const latestCount = latestMatch ? Number(latestMatch[1]) : null;

        const firstTs = filtered[0]?.timestamp
          ? new Date(filtered[0].timestamp)
          : null;
        const lastTs = latest.timestamp ? new Date(latest.timestamp) : null;

        let ratePerDay = null;
        if (firstTs && lastTs && lastTs > firstTs) {
          const spanDays =
            (lastTs - firstTs) / (1000 * 60 * 60 * 24);
          if (spanDays > 0) ratePerDay = total / spanDays;
        }

        const BYTES_PER_RECORD_ESTIMATE = 500;
        const footprintBytes = total * BYTES_PER_RECORD_ESTIMATE;

        setData({
          total,
          latestCount,
          ratePerDay,
          footprintBytes,
          lastTimestamp: latest.timestamp,
        });
      }
    } catch (e) {
      console.error(e);
      setData({});
    }
    setLoading(false);
  };

  useEffect(() => {
    setLoading(true);
    fetchStructuredStorage();
  }, [refreshKey]);

  return (
    <Card style={{ width: "100%" }}>
      <Card.Body>
        <div className="border-bottom mb-3">
          <h3 style={{ fontSize: "1.1rem" }}>Data overview</h3>
        </div>

        {loading ? (
          <div className="text-muted small">
            <Spinner animation="border" size="sm" className="me-2" />
            Loading…
          </div>
        ) : (
          <>
            <Row className="g-3">
              <Col md={6} lg={3}>
                <StatCard
                  label="Total ingested"
                  value={
                    data.total == null
                      ? "—"
                      : `${data.total.toLocaleString()} records`
                  }
                />
              </Col>

              <Col md={6} lg={3}>
                <StatCard
                  label="Last batch"
                  value={
                    data.latestCount == null
                      ? "—"
                      : `${data.latestCount} records`
                  }
                />
              </Col>

              <Col md={6} lg={3}>
                <StatCard
                  label="Ingestion rate"
                  value={
                    data.ratePerDay == null
                      ? "—"
                      : `${data.ratePerDay.toLocaleString(undefined, {
                          maximumFractionDigits: 1,
                        })}/d`
                  }
                />
              </Col>

              <Col md={6} lg={3}>
                <StatCard
                  label="Estimated storage"
                  value={
                    data.footprintBytes == null
                      ? "—"
                      : formatBytes(data.footprintBytes)
                  }
                />
              </Col>
            </Row>

            <div className="mt-3 text-muted" style={{ fontSize: "0.8rem" }}>
              {data.lastTimestamp
                ? `Last ingestion: ${new Date(
                    data.lastTimestamp
                  ).toLocaleString()}`
                : "No recent ingestion event found"}
            </div>
          </>
        )}
      </Card.Body>
    </Card>
  );
}