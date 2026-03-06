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

//-----------------------|| DASHBOARD SENSEARTH ||-----------------------//
export default function ModelsDashboard() {
  const [models, setModels] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchModels = async () => {
    try {
      const res = await api.get("/models"); 
      setModels(res.data);
    } catch (error) {
      console.error("Failed to fetch models:", error);
      setModels([]);
    }
    setLoading(false);
  };

  useEffect(() => {
    fetchModels();
  }, []);

  return (
    <Row>
      <Col md={12}>
        <Card className="flat-card">
          <Card.Body>
            <h3 className="mb-3">Models</h3>

            {loading ? (
              <div className="text-center">
                <Spinner animation="border" />
              </div>
            ) : (
              <Table striped bordered hover responsive>
                <thead>
                  <tr>
                    <th>Name</th>
                    <th>Type</th>
                  </tr>
                </thead>
                <tbody>
                  {models.length === 0 ? (
                    <tr>
                      <td colSpan="4" className="text-center">
                        No models found
                      </td>
                    </tr>
                  ) : (
                    models.map((models) => (
                      <tr key={models.models_id}>
                        <td>{models.name} ({models.models_id})</td>
                        <td>{models.model_type || "N/A"}</td>
                        {/* <td>
                          <span
                            className={`badge ${
                              models.status === "active"
                                ? "bg-success"
                                : models.status === "error"
                                ? "bg-danger"
                                : "bg-secondary"
                            }`}
                          >
                            {models.status}
                          </span>
                        </td> */}
                      </tr>
                    ))
                  )}
                </tbody>
              </Table>
            )}
          </Card.Body>
        </Card>
      </Col>
    </Row>
  );
}