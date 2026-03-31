import React, { useEffect, useMemo, useState } from "react";
import { Card, Spinner, Table } from "react-bootstrap";
import api from "../../../api";
import monitoring_api from "../../../monitoring_api";

function ModelRun({ completed, ongoing }) {
  return (
    <div className="mt-1">
      <div className="fw-bold text-primary" style={{ fontSize: "2rem" }}>
        {completed} / {completed + ongoing}
      </div>
      <div className="text-muted small">
        Completed / total runs{" "}
        <span className="ms-2">Ongoing: {ongoing}</span>
      </div>
    </div>
  );
}

export default function ModelsOverview({ refreshKey }) {
  const [models, setModels] = useState([]);
  const [modelRuns, setModelRuns] = useState([]);
  const [events, setEvents] = useState([]);

  const [loadingModels, setLoadingModels] = useState(true);
  const [loadingRuns, setLoadingRuns] = useState(true);
  const [loadingEvents, setLoadingEvents] = useState(true);

  const fetchModels = async () => {
    try {
      const res = await api.get("/models");
      setModels(Array.isArray(res.data) ? res.data : []);
    } catch (e) {
      console.error("Failed to fetch models:", e);
      setModels([]);
    }
    setLoadingModels(false);
  };

  const fetchModelRuns = async () => {
    try {
      const res = await api.get("/modelRuns");
      setModelRuns(Array.isArray(res.data) ? res.data : []);
    } catch (e) {
      console.error("Failed to fetch model runs:", e);
      setModelRuns([]);
    }
    setLoadingRuns(false);
  };

  const fetchEvents = async () => {
    try {
      const res = await monitoring_api.get("/events");
      setEvents(Array.isArray(res.data) ? res.data : []);
    } catch (e) {
      console.error("Failed to fetch monitoring events:", e);
      setEvents([]);
    }
    setLoadingEvents(false);
  };

  useEffect(() => {
    setLoadingModels(true);
    setLoadingRuns(true);
    setLoadingEvents(true);
    fetchModels();
    fetchModelRuns();
    fetchEvents();
  }, [refreshKey]);

  const { completedRuns, ongoingRuns } = useMemo(() => {
    const completed = modelRuns.filter(
      (r) =>
        r.status === "completed" ||
        (r.finished_at != null && String(r.finished_at).length > 0)
    ).length;
    const ongoing = Math.max(0, modelRuns.length - completed);
    return { completedRuns: completed, ongoingRuns: ongoing };
  }, [modelRuns]);

  const configCount = models.length;

  const modelIssues = useMemo(() => {
    const errEvents = events.filter(
      (e) => e.severity === "ERROR" || e.severity === "CRITICAL"
    );

    const counts = new Map();
    for (const m of models) {
      counts.set(m.name, 0);
    }

    for (const e of errEvents) {
      const metaModelName =
        e?.metadata && typeof e.metadata === "object" ? e.metadata.model_name : null;
      if (metaModelName && counts.has(metaModelName)) {
        counts.set(metaModelName, (counts.get(metaModelName) || 0) + 1);
        continue;
      }

      const msg = typeof e?.message === "string" ? e.message : "";
      for (const name of counts.keys()) {
        if (name && msg.includes(name)) {
          counts.set(name, (counts.get(name) || 0) + 1);
        }
      }
    }

    return Array.from(counts.entries())
      .map(([modelName, issues]) => ({ modelName, issues }))
      .sort((a, b) => b.issues - a.issues);
  }, [events, models]);

  const anyIssues = modelIssues.some((x) => x.issues > 0);

  return (
    <Card className="flat-card">
      <Card.Body>
        <div className="border-bottom d-flex justify-content-between align-items-center mb-2">
          <h3 className="mb-0" style={{ fontSize: "1.1rem" }}>
            Model runs
          </h3>
        </div>

        <div className="d-flex flex-wrap gap-3">

          {/* Model Runs */}
          <div className="flex-fill" style={{ minWidth: "120px" }}>
            <div className="fw-semibold small">Runs</div>
            {loadingRuns ? (
              <div className="text-muted small mt-1">
                <Spinner animation="border" size="sm" className="me-2" />
                Loading…
              </div>
            ) : (
              <ModelRun completed={completedRuns} ongoing={ongoingRuns} />
            )}
          </div>

          {/* Configs */}
          <div className="flex-fill" style={{ minWidth: "100px" }}>
            <div className="fw-semibold small">Configs</div>
            {loadingModels ? (
              <div className="text-muted small mt-1">
                <Spinner animation="border" size="sm" className="me-2" />
                Loading…
              </div>
            ) : (
              <div className="mt-1">
                <div className="fw-bold" style={{ fontSize: "1.4rem" }}>
                  {configCount}
                </div>
                <div className="text-muted small">Models</div>
              </div>
            )}
          </div>

          {/* Issues */}
          <div className="flex-fill" style={{ minWidth: "160px" }}>
            <div className="fw-semibold small">
              Issues{" "}
              {!loadingEvents && (
                <span className="text-muted">
                  ({modelIssues.filter((x) => x.issues > 0).length})
                </span>
              )}
            </div>

            {loadingEvents || loadingModels ? (
              <div className="text-muted small mt-1">
                <Spinner animation="border" size="sm" className="me-2" />
                Loading…
              </div>
            ) : !anyIssues ? (
              <div className="text-muted small mt-1">None</div>
            ) : (
              <div className="mt-1" style={{ maxHeight: "120px", overflow: "auto" }}>
                <Table striped bordered hover responsive size="sm" className="mb-0">
                  <tbody>
                    {modelIssues
                      .filter((x) => x.issues > 0)
                      .slice(0, 3)
                      .map((x) => (
                        <tr key={x.modelName}>
                          <td className="small">{x.modelName}</td>
                          <td>
                            <span className="badge bg-danger">{x.issues}</span>
                          </td>
                        </tr>
                      ))}
                  </tbody>
                </Table>
              </div>
            )}
          </div>

        </div>
      </Card.Body>
    </Card>
  );
}