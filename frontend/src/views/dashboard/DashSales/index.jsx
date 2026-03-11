import React, { useState, useEffect } from 'react';
import { Row, Col, Card, Table, Spinner } from "react-bootstrap";
import api from '../../../api';
import MonitoringDashboard from './monitoring';
import ModelsDashboard from './models';
import EventsDashboard from './events';
import SensorChart from "./chart/SensorChart";
import ChartSettingsModal from "./chart/ChartSettingsModal";
import LatestMeasurementsDashboard from './latest_measurements';
//-----------------------|| DASHBOARD SENSEARTH ||-----------------------//

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

    <LatestMeasurementsDashboard sensors={sensors} loading={loading} />

    <LatestMeasurementsDashboard sensors={sensors} loading={loading} />
    <MonitoringDashboard />
    <ModelsDashboard />
    <EventsDashboard />

  <Card className="card" style={{ gridColumn: "span 1" }}>
    <Card.Body>
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