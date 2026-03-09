import React, { useState, useEffect } from 'react';
import { Row, Col, Card, Table, Spinner } from "react-bootstrap";
import Button from '@mui/material/Button';
import AddIcon from '@mui/icons-material/Add';
import Dialog from '@mui/material/Dialog';
import DialogTitle from '@mui/material/DialogTitle';
import DialogContent from '@mui/material/DialogContent';
import DialogActions from '@mui/material/DialogActions';
import TextField from '@mui/material/TextField';
import DialogContentText from '@mui/material/DialogContentText';
import IconButton from '@mui/material/IconButton';
import DeleteIcon from '@mui/icons-material/Delete';
import PlayArrowIcon from '@mui/icons-material/PlayArrow';
import api from '../../../api';

//-----------------------|| DASHBOARD SENSEARTH ||-----------------------//
export default function ModelsDashboard() {

  const [models, setModels] = useState([]);
  const [loading, setLoading] = useState(true);

  const [openDialog, setOpenDialog] = useState(false);

  const [modelName, setModelName] = useState("");
  const [description, setDescription] = useState("");
  const [modelType, setModelType] = useState("anomaly_detection_model");
  const [sensorIds, setSensorIds] = useState("1,2,3");
  const [jsonConfig, setJsonConfig] = useState(`{
  "anomaly_detection_alg": ["BorderCheck()"],
  "anomaly_detection_conf": [
    {
      "input_vector_size": 1,
      "warning_stages": [2.5, 0.0],
      "UL": 3.0,
      "LL": -0.4,
      "output": ["TerminalOutput()"],
      "output_conf": [{}]
    }
  ]
}`);

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

  const handleCreateModel = async () => {
    let parsedJson = {};

    try {
      parsedJson = JSON.parse(jsonConfig);
    } catch (err) {
      alert("Invalid JSON config");
      return;
    }

    const payload = {
      model_name: modelName,
      description: description || null,
      model_type: modelType || "anomaly_detection",
      sensor_id_list: sensorIds.split(",").map(id => parseInt(id.trim())),
      jsonconfig: parsedJson
    };

    try {
      await api.post("/registerModel", payload);
      setOpenDialog(false);

      setModelName("");
      setDescription("");
      setJsonConfig("{}");

      fetchModels();

    } catch (error) {
      console.error("Failed to create model:", error);
      alert("Failed to register model");
    }
  };

  return (
    <Row>
      <Col md={12}>
        <Card className="flat-card">
          <Card.Body>

            <div className="d-flex justify-content-between align-items-center mb-3">
            <h3 className="mb-0">Models</h3>
            <div className="d-flex align-items-center">
              
              <IconButton 
                color="primary" 
                onClick={() => setOpenDialog(true)}
              >
                <AddIcon />
              </IconButton>

              <Button
                startIcon={<DeleteIcon />}
                color="error"
                onClick={async () => {
                  try {
                    if (confirm('Are you sure you want to delete all models?')) {
                      await api.delete('/models');
                      fetchModels();
                    }
                  } catch (error) {
                    console.error(error);
                  }
                }}
                className="ms-2"
              >
              </Button>
            </div>
          </div>

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
                    models.map((model) => (
                      <tr key={model.models_id}>
                        
                        <td style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                        <span style={{ flexGrow: 1, textAlign: "center" }}>
                          {model.name}
                        </span>

                          <div style={{ display: "flex", gap: "8px" }}>
                            {/* Run Button */}
                            <IconButton
                              color="primary"
                              onClick={async () => {
                                try {
                                  if (confirm('Are you sure you want to run this model?')) {
                                    const payload = {
                                      model_name: model.name, 
                                      // Optional fields:
                                      // sensor_id: 1, 2, 3, ....
                                      // parameters: {...}
                                    };

                                    await api.post(`/runModel`, payload);
                                    fetchModels();
                                  }
                                } catch (error) {
                                  console.error(error);
                                }
                              }}
                            >
                              <PlayArrowIcon />
                            </IconButton>

                            {/* Delete Button */}
                            <Button
                              startIcon={<DeleteIcon />}
                              color="error"
                              onClick={async () => {
                                try {
                                  if (confirm('Are you sure you want to delete this model?')) {
                                    await api.delete(`/models/${encodeURIComponent(model.name)}`);
                                    fetchModels();
                                  }
                                } catch (error) {
                                  console.error(error);
                                }
                              }}
                              style={{ textTransform: "none" }}
                            >
                            </Button>
                          </div>
                        </td>
                        <td>{model.model_type || "N/A"}</td>
                      </tr>
                    ))
                  )}
                </tbody>
              </Table>
            )}
          </Card.Body>
        </Card>
      </Col>

      {/* Add Model Dialog */}
      <Dialog open={openDialog} onClose={() => setOpenDialog(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Register Model</DialogTitle>

        <DialogContent>

          <DialogContentText sx={{ mb: 2 }}>
            Register a new ML model and configure its sensors and parameters.
          </DialogContentText>

          <TextField
            label="Model Name"
            fullWidth
            margin="normal"
            value={modelName}
            onChange={(e) => setModelName(e.target.value)}
          />

          <TextField
            label="Description (optional)"
            fullWidth
            margin="normal"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
          />

          <TextField
            label="Model Type"
            fullWidth
            margin="normal"
            value={modelType}
            onChange={(e) => setModelType(e.target.value)}
          />

          <TextField
            label="Sensor ID List (comma separated)"
            fullWidth
            margin="normal"
            value={sensorIds}
            onChange={(e) => setSensorIds(e.target.value)}
          />

          <TextField
            label="JSON Config Parameters"
            fullWidth
            margin="normal"
            multiline
            minRows={5}
            value={jsonConfig}
            onChange={(e) => setJsonConfig(e.target.value)}
            placeholder={`{
            "anomaly_detection_alg": ["BorderCheck()"],
            "anomaly_detection_conf": [
              {
                "input_vector_size": 1,
                "warning_stages": [2.5, 0.0],
                "UL": 3.0,
                "LL": -0.4,
                "output": ["TerminalOutput()"],
                "output_conf": [{}]
              }
            ]
          }`}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenDialog(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleCreateModel}>
            Register
          </Button>
        </DialogActions>
      </Dialog>

    </Row>
  );
}