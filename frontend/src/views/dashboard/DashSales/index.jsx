import React, { useState, useEffect } from 'react';
import { Row, Col, Card, Table, Spinner } from "react-bootstrap";
import IconButton from '@mui/material/IconButton';
import DeleteIcon from '@mui/icons-material/Delete';
import Button from '@mui/material/Button';
import AddIcon from '@mui/icons-material/Add';
import Dialog from '@mui/material/Dialog';
import DialogTitle from '@mui/material/DialogTitle';
import DialogContent from '@mui/material/DialogContent';
import DialogActions from '@mui/material/DialogActions';
import TextField from '@mui/material/TextField';
import api from '../../../api';
import DialogContentText from '@mui/material/DialogContentText';
import MonitoringDashboard from './monitoring';
import ModelsDashboard from './models';
import EventsDashboard from './events';

//-----------------------|| DASHBOARD SENSEARTH ||-----------------------//
export default function DashboardSales() {
  const [sensors, setSensors] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchSensors = async () => {
    try {
      const res = await api.get("/latestMeasurements?limit=10");
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
  <Row>
    <Col md={12}>
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

                      <td>{sensor.sensor_location || "-"}</td>

                      <td>{sensor.value}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </Table>
          )}
        </Card.Body>
      </Card>
    <div className="container mt-4">
      <MonitoringDashboard />
    </div>
    <div className="container mt-4">
      <ModelsDashboard />
    </div>
    <div className="container mt-4">
      <EventsDashboard   />
    </div>
    </Col>
  </Row>
);
}