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
import monitoring_api from "../../../monitoring_api";

export default function ModelsDashboard( {setModelsUpdated} ) {

  const [models, setModels] = useState([]);
  const [loading, setLoading] = useState(true);
  const [logs, setLogs] = useState([]);

  const [openDialog, setOpenDialog] = useState(false);

  const [modelName, setModelName] = useState("");
  const [description, setDescription] = useState("");
  const [modelType, setModelType] = useState("anomaly_detection_model");
  const [sensorIds, setSensorIds] = useState("1,2,3");
  const [results, setResults] = useState()
  const [modelResults, setModelResults] = useState(null);
  const [jsonConfig, setJsonConfig] = useState(`{
  "anomaly_detection_alg": ["BorderCheck()"],
  "anomaly_detection_conf": [
    {
      "input_vector_size": 1,
      "warning_stages": [90, 5],
      "UL": 100,
      "LL": 0,
      "output": ["TerminalOutput()"],
      "output_conf": [{}]
    }
  ]
}`);

  const transformResults = (results) => {
    return Object.entries(results).map(([sensorId, entries]) => {
      return {
        sensorId,
        rows: entries.map(([measurement, result]) => ({
          timestamp: measurement[0],
          value: measurement[1],
          message: result[0],
          code: result[1]
        }))
      };
    });
  };

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
      model_description: description || null,
      model_type: modelType || "anomaly_detection_model",
      sensor_id_list: sensorIds.split(",").map(id => parseInt(id.trim())),
      model_parameters: parsedJson
    };

    try {
      console.log("Registering model with payload:", payload);
      await api.post("/registerModel", payload);
      setOpenDialog(false);

      setModelsUpdated(v => v + 1);

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
    <>
      <Card className="flat-card dashboard-component ">
        <Card.Body>
          <Card> 
            <Card.Body>
            <div className="border-bottom d-flex justify-content-between align-items-center mb-3" >
              <h3>Models</h3>
              <div className="d-flex align-items-center">
                <IconButton
                  className='btn-icon-small'
                  color="primary"
                  onClick={() => setOpenDialog(true)}
                >
                  <AddIcon />
                </IconButton>

                <Button
                  startIcon={<DeleteIcon />}
                  color="error"
                  className='btn-icon-small'
                  onClick={async () => {
                    try {
                      if (confirm('Are you sure you want to delete all models?')) {
                        await api.delete('/models');
                        // Delete all model components in monitoring system
                        await Promise.all(
                          models.map(model =>
                            monitoring_api.delete(
                              `/component?name=${encodeURIComponent(model.model_type)}&instance_id=${encodeURIComponent(model.name)}`
                            )
                          )
                        );
                        setModelsUpdated(v => v + 1);
                        fetchModels();
                      }
                    } catch (error) {
                      console.error(error);
                    }
                  }}
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
                    <th>Actions</th>
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
                        </td>
                        <td>{model.model_type || "N/A"}</td>
                        <td><div style={{ display: "flex", gap: "8px" }}>
                          {/* Run Button */}
                          <IconButton
                            color="primary"
                            className='btn-icon-small'
                            onClick={async () => {
                              try {
                                if (confirm('Are you sure you want to run this model?')) {
                                  const payload = {
                                    model_name: model.name,
                                    // Optional fields:
                                    // sensor_id: 1, 2, 3, ....
                                    // parameters: {...}
                                  };

                                  const res = await api.post(`/runModel`, payload);

                                  setModelResults(res.data);
                                  setLogs(prev => [
                                    ...prev,
                                    `> Running ${model.name}...`,
                                    `✔ Model finished`
                                  ]);

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
                            className='btn-icon-small'
                            onClick={async () => {
                              try {
                                if (confirm('Are you sure you want to delete this model?')) {
                                  await api.delete(`/models/${encodeURIComponent(model.name)}`);
                                  await monitoring_api.delete(
                                    `/component?name=${encodeURIComponent(model.model_type)}&instance_id=${encodeURIComponent(model.name)}` // name of compoent is model_type and instance_id is model name
                                  );
                                  setModelsUpdated(v => v + 1);
                                  fetchModels();
                                }
                              } catch (error) {
                                console.error(error);
                              }
                            }}
                            style={{ textTransform: "none" }}
                          >
                          </Button>
                        </div></td>
                      </tr>
                    ))
                  )}
                </tbody>
              </Table>
            )}
          </Card.Body>
          </Card>

          <Card className="flat-card scroll-area">
            <Card.Body>
              <h5>Model results</h5>

              {modelResults && (
                <Card className="mt-3">
                  <Card.Body>
                    <div className="model-results-container">
                        {transformResults(modelResults.results).map(sensor => {
                          const errors = sensor.rows.filter(r => r.code === -1).length;
                          return (
                            <div key={sensor.sensorId} className="sensor-block">

                              {/* Header */}
                              <div className="sensor-header">
                                Sensor {sensor.sensorId} | {errors}/{sensor.rows.length} errors
                              </div>

                              {/* Table */}
                              <div className="sensor-table">
                                {sensor.rows.slice(0, 15).map((row, i) => (
                                  <div key={i} className="sensor-row">
                                    <span className="sensor-cell">
                                      {row.timestamp.toFixed(2)}
                                    </span>
                                    <span className="sensor-cell">
                                      {row.value}
                                    </span>
                                    {row.message === "OK" ? (
                                      <span className="sensor-cell sensor-success">
                                        {row.message}
                                      </span>
                                    ) : row.message.includes("Warning") ? (
                                      <span className="sensor-cell sensor-warning">
                                        {row.message}
                                      </span>
                                    ) : (
                                      <span className="sensor-cell sensor-error">
                                        {row.message}
                                      </span>
                                    )}
                                  </div>
                                ))}
                              </div>
                            </div>
                          );
                        })}
                      </div>
                  </Card.Body>
                </Card>
              )}
            </Card.Body>
          </Card>

        </Card.Body>
      </Card>




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
    </>
  );
}