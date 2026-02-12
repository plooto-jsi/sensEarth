DROP TABLE IF EXISTS components CASCADE;
DROP TABLE IF EXISTS heartbeats CASCADE;
DROP TABLE IF EXISTS metrics CASCADE;
DROP TABLE IF EXISTS events CASCADE;

CREATE TYPE component_type AS ENUM ('scraper', 'model', 'database', 'middleware', 'minio', 'other');
CREATE TYPE component_status AS ENUM ('active', 'inactive', 'degraded');
CREATE TYPE heartbeat_status AS ENUM ('OK', 'WARN', 'FAIL');
CREATE TYPE event_severity AS ENUM ('INFO','WARN','ERROR','CRITICAL');

CREATE TABLE components (
    component_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    instance_id TEXT NOT NULL,
    type component_type NOT NULL,
    status component_status DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW(),
    CONSTRAINT unique_component UNIQUE (name, instance_id)
);

CREATE TABLE heartbeats (
    heartbeat_id SERIAL PRIMARY KEY,
    component_id INT REFERENCES components(component_id),
    timestamp TIMESTAMP DEFAULT NOW(),
    status heartbeat_status DEFAULT 'OK',
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
    severity event_severity,
    message TEXT,
    timestamp TIMESTAMP DEFAULT NOW(),
    metadata JSONB
);
