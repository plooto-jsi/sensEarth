import React, { useState, useEffect } from 'react';
import { Row, Col, Card, Table, Spinner } from "react-bootstrap";
import api from '../../../api';
import MonitoringDashboard from './monitoring';
import ModelsDashboard from './models';
import EventsDashboard from './events';
import SensorChart from "./chart/SensorChart";
import ChartSettingsModal from "./chart/ChartSettingsModal";
//-----------------------|| DASHBOARD SENSEARTH ||-----------------------//
function parseAndFormatLocation(locationStr) {
  if (!locationStr) return "-";

  try {
    const loc = JSON.parse(locationStr);
    if (!loc.coordinates || loc.coordinates.length < 2) return "-";
    const [lon, lat, alt] = loc.coordinates;
    return (
      <a
        href={`https://www.openstreetmap.org/?mlat=${lat}&mlon=${lon}`}
        target="_blank"
        rel="noopener noreferrer"
      >
        {lat.toFixed(5)}, {lon.toFixed(5)}
        {alt ? ` (${alt.toFixed(1)} m)` : ""}
      </a>
    );
  } catch (err) {
    return "-";
  }
}

async function fetchMeasurements(sensorIDs = [], days = 0) {
  try {
    const params = new URLSearchParams();
    sensorIDs.forEach(id => params.append("sensorIDs", id));
    if (days) params.append("days", days);

    console.log("Fetching measurements with params:", { params: params.toString() });

    const res = await api.get(`/measurements?${params.toString()}`);

    const measurements = res.data; 
    console.log("Fetched measurements:", measurements);

    return measurements;
  } catch (error) {
    console.error("Failed to fetch measurements:", error);
    return []; 
  }
}

export default function DashboardSales() {
  const [sensors, setSensors] = useState([]);
  const [loading, setLoading] = useState(true);
   const [allSensors, setAllSensors] = useState([]); // [{id, label}]
  const [selectedSensors, setSelectedSensors] = useState([]);
  const [days, setDays] = useState(7);
  const [measurements, setMeasurements] = useState([]);
  const [showSettings, setShowSettings] = useState(false);

  // Load all sensors once
  const fetchSensorsAll = async () => {
    try {
      const res = await api.get("/sensors");
      setAllSensors(res.data);
      console.log("Fetched all sensors:", res.data);
    } catch (error) {
      console.error("Failed to fetch sensors:", error);
      setAllSensors([]);
    }
    setLoading(false);
  };

  useEffect(() => {
    fetchSensorsAll();
  }, []);

  // Fetch measurements whenever selectedSensors or days change
  useEffect(() => {
    if (selectedSensors.length === 0) return;

    fetchMeasurements(selectedSensors, days)
      .then(data => setMeasurements(data))
      .catch(err => console.error(err));
  }, [selectedSensors, days]);

  const fetchSensors = async () => {
    try {
      const res = await api.get("/measurements?limit=10");
      setSensors(res.data);
    } catch (error) {
      console.error("Failed to fetch sensors:", error);
      setSensors([]);
    }
    setLoading(false);
  };

  useEffect(() => {
    fetchSensors();
  }, []);

return (
  <div className="dashboard-grid">
    

      <Card className="flat-card">
        <Card.Body>
          <h3 className="mb-3">Sensor Measurements</h3>

          {loading ? (
            <div className="text-center">
              <Spinner animation="border" />
            </div>
          ) : (
            <Table striped bordered hover responsive>
              <thead>
                <tr>
                  <th>Sensor</th>
                  <th>Timestamp</th>
                  <th>Location</th>
                  <th>Value</th>
                </tr>
              </thead>

              <tbody>
                {sensors.length === 0 ? (
                  <tr>
                    <td colSpan="4" className="text-center">
                      No measurements found
                    </td>
                  </tr>
                ) : (
                  sensors.map((sensor, index) => (
                    <tr key={`${sensor.sensor_id}-${sensor.timestamp_utc}-${index}`}>
                      <td>
                        {sensor.sensor_label} ({sensor.sensor_id})
                      </td>

                      <td>
                        {new Date(sensor.timestamp_utc).toLocaleString()}
                      </td>
                      <td>{parseAndFormatLocation(sensor.location)}</td>            
                  <td>{sensor.value}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </Table>
          )}
        </Card.Body>
      </Card>
  {/* Flexible dashboard components grid */}
    <MonitoringDashboard />
    <ModelsDashboard />
    <EventsDashboard />


  <Card className="card" style={{ gridColumn: "span 1" }}>
      <Card.Body>
        <h3 className="mb-3">Sensor Data Chart</h3>
        <ChartSettingsModal
          allSensors={allSensors}
          selectedSensors={selectedSensors}
          setSelectedSensors={setSelectedSensors}
          days={days}
          setDays={setDays}
          onClose={() => setShowSettings(false)}
        />
      
      <SensorChart measurements={measurements} />
      </Card.Body>
    </Card>
    </div>

);
}