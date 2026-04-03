import React, { useState, useEffect } from "react";
import { Card, Spinner } from "react-bootstrap";
import monitoring_api from "../../../monitoring_api"; 

export default function IngestionStatus({ modelsUpdated }) {
  const [activeScraperCount, setActiveScraperCount] = useState(0);
  const [totalScraperCount, setTotalScraperCount] = useState(0);
  const [scraperErrorEvents, setScraperErrorEvents] = useState([]);
  const [loadingComponents, setLoadingComponents] = useState(true);
  const [loadingEvents, setLoadingEvents] = useState(true);

  const fetchScraperCounts = async () => {
    try {
      const res = await monitoring_api.get("/components");
      const list = Array.isArray(res.data) ? res.data : [];
      const scrapers = list.filter((c) => c.type === "scraper");
      setTotalScraperCount(scrapers.length);
      setActiveScraperCount(
        scrapers.filter((c) => c.status === "active").length
      );
    } catch (error) {
      console.error("Failed to fetch components:", error);
      setActiveScraperCount(0);
      setTotalScraperCount(0);
    }
    setLoadingComponents(false);
  };

  const fetchScraperErrorEvents = async () => {
    try {
      const res = await monitoring_api.get("/events");
      const list = Array.isArray(res.data) ? res.data : [];
      const errs = list
        .filter(
          (e) =>
            e.component_name === "scraper" &&
            (e.severity === "ERROR" || e.severity === "CRITICAL")
        )
        .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
      setScraperErrorEvents(errs);
    } catch (error) {
      console.error("Failed to fetch events:", error);
      setScraperErrorEvents([]);
    }
    setLoadingEvents(false);
  };

  useEffect(() => {
    setLoadingComponents(true);
    setLoadingEvents(true);
    fetchScraperCounts();
    fetchScraperErrorEvents();
  }, [modelsUpdated]);

  return (
    <div style={{ width: "100%", height: "100%" }}>
      <Card className="flat-card" >
        <Card.Body>
          <div className="border-bottom d-flex justify-content-between align-items-center mb-2">
            <h3 className="mb-0" style={{ fontSize: "1.1rem" }}>
              Ingestion status
            </h3>
          </div>
          {loadingComponents ? (
            <div className="text-center py-2">
              <Spinner animation="border" size="sm" />
            </div>
          ) : (
            <>
              <div
                className="fw-bold text-primary"
                style={{ fontSize: "2rem", lineHeight: 1.2 }}
              >
                {activeScraperCount} / {totalScraperCount}
              </div>
              <p className="text-muted small mb-0 mt-1">
                Active scrapers
              </p>
            </>
          )}

          <div className="mt-3">
            <div className="fw-semibold" style={{ fontSize: "0.9rem" }}>
              Scraper errors{" "}
              {!loadingEvents ? (
                <span className="text-muted">
                  ({scraperErrorEvents.length})
                </span>
              ) : null}
            </div>
            {loadingEvents ? (
              <div className="text-muted small mt-1">Loading…</div>
            ) : scraperErrorEvents.length === 0 ? (
              <div className="text-muted small mt-1">No scraper errors</div>
            ) : (
              <ul className="small mt-2 mb-0 ps-3">
                {scraperErrorEvents.slice(0, 3).map((e) => (
                  <li key={e.event_id}>
                    <span className="fw-semibold">{e.severity}</span>{" "}
                    {e.component_instance_id ? `(${e.component_instance_id}) ` : ""}
                    {e.message}
                  </li>
                ))}
              </ul>
            )}
          </div>
        </Card.Body>
      </Card>
    </div>
  );
}
