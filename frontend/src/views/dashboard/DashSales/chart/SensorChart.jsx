import React, { useMemo } from "react";
import ReactECharts from "echarts-for-react";

export default function SensorChart({ measurements }) {
  // Build series grouped by sensor_label
  const series = useMemo(() => {
    const sensors = {};
    measurements.forEach(m => {
      const sensor_id = m.sensor_id;
      if (!sensors[sensor_id]) sensors[sensor_id] = [];
      sensors[sensor_id].push([new Date(m.timestamp_utc), m.value]);
    });

    return Object.keys(sensors).map(sensor_id => ({
      name: sensor_id,
      type: "line",
      showSymbol: false,
      areaStyle: {opacity: 0.1},
      data: sensors[sensor_id].sort((a, b) => a[0] - b[0])
    }));
  }, [measurements]);

  // Find min/max for y-axis scaling
  const { min, max } = useMemo(() => {
    if (!measurements.length) return { min: 0, max: 1 };
    const values = measurements.map(m => m.value);
    return { min: Math.min(...values), max: Math.max(...values) };
  }, [measurements]);

  const option = {
    tooltip: { trigger: "axis" },
    legend: { type: "scroll" },
    xAxis: { type: "time", },
    yAxis: { type: "value", min, max  },
    dataZoom: [{ type: "inside" }, { type: "slider" }],
    series
  };

  return <ReactECharts option={option} style={{ height: 400 }} />;
}