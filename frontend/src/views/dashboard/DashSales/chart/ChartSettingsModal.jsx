import React, { useState } from "react";

export default function ChartSettingsDialog({ allSensors, selectedSensors, setSelectedSensors, days, setDays }) {
  const [dialogOpen, setDialogOpen] = useState(false);
  const [tempDays, setTempDays] = useState(days);
  const [tempSelected, setTempSelected] = useState(selectedSensors);

  const toggleSensor = id => {
    setTempSelected(prev =>
      prev.includes(id) ? prev.filter(x => x !== id) : [...prev, id]
    );
  };

  const applySettings = () => {
    setSelectedSensors(tempSelected);
    setDays(tempDays);
    setDialogOpen(false);
  };

  return (
    <div>
      <button onClick={() => setDialogOpen(true)}>Settings</button>

      {dialogOpen && (
      <dialog open={dialogOpen} style={{ zIndex: 1000, padding: 20, width: 400 }}>
        <h3>Chart Settings</h3>

        <div>
          <label>
            Days back:
            <input
              type="number"
              min={1}
              max={365}
              value={tempDays}
              onChange={e => setTempDays(Number(e.target.value))}
            />
          </label>
        </div>

        <div style={{ maxHeight: 200, overflowY: "auto", border: "1px solid #ffffff", padding: 5, marginTop: 10 }}>
          {allSensors.map(s => (
            <label key={s.sensor_id} style={{ display: "block", marginBottom: 5 }}>
              <input
                type="checkbox"
                checked={tempSelected.includes(s.sensor_id)}
                onChange={() => toggleSensor(s.sensor_id)}
              />
              {s.sensor_label} ({s.sensor_id})
            </label>
          ))}
        </div>

        <div style={{ marginTop: 10 }}>
          <button onClick={applySettings}>Apply</button>
          <button onClick={() => setDialogOpen(false)} style={{ marginLeft: 10 }}>Cancel</button>
        </div>
      </dialog> )}
    </div>
  );
}