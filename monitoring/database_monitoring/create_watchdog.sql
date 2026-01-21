DROP TABLE IF EXISTS components CASCADE;
DROP TABLE IF EXISTS heartbeats CASCADE;
DROP TABLE IF EXISTS metrics CASCADE;
DROP TABLE IF EXISTS events CASCADE;

CREATE TABLE components (
    component_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    instance_id TEXT,
    type TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE heartbeats (
    heartbeat_id SERIAL PRIMARY KEY,
    component_id INT REFERENCES components(component_id),
    timestamp TIMESTAMP DEFAULT NOW(),
    status TEXT,
    metadata JSONB
);

CREATE TABLE metrics (
    metric_id SERIAL PRIMARY KEY,
    component_id INT REFERENCES components(component_id),
    metric_name TEXT NOT NULL,
    value DOUBLE PRECISION,
    unit TEXT,
    timestamp TIMESTAMP DEFAULT NOW(),
    metadata JSONB
);

CREATE TABLE events (
    event_id SERIAL PRIMARY KEY,
    component_id INT REFERENCES components(component_id),
    event_type TEXT NOT NULL,
    severity TEXT,
    message TEXT,
    timestamp TIMESTAMP DEFAULT NOW(),
    metadata JSONB
);
