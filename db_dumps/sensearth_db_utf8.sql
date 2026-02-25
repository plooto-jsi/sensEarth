pg_dump: warning: there are circular foreign-key constraints on this table:
pg_dump:   hypertable
pg_dump: You might not be able to restore the dump without using --disable-triggers or temporarily dropping the constraints.
pg_dump: Consider using a full dump instead of a --data-only dump to avoid this problem.
pg_dump: warning: there are circular foreign-key constraints on this table:
pg_dump:   chunk
pg_dump: You might not be able to restore the dump without using --disable-triggers or temporarily dropping the constraints.
pg_dump: Consider using a full dump instead of a --data-only dump to avoid this problem.
pg_dump: warning: there are circular foreign-key constraints on this table:
pg_dump:   continuous_agg
pg_dump: You might not be able to restore the dump without using --disable-triggers or temporarily dropping the constraints.
pg_dump: Consider using a full dump instead of a --data-only dump to avoid this problem.
--
-- PostgreSQL database dump
--

-- Dumped from database version 14.7 (Ubuntu 14.7-1.pgdg22.04+1)
-- Dumped by pg_dump version 14.7 (Ubuntu 14.7-1.pgdg22.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: timescaledb; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS timescaledb WITH SCHEMA public;


--
-- Name: EXTENSION timescaledb; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION timescaledb IS 'Enables scalable inserts and complex queries for time-series data';


--
-- Name: timescaledb_toolkit; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS timescaledb_toolkit WITH SCHEMA public;


--
-- Name: EXTENSION timescaledb_toolkit; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION timescaledb_toolkit IS 'Library of analytical hyperfunctions, time-series pipelining, and other SQL utilities';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: sensor_measurement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sensor_measurement (
    sensor_id integer NOT NULL,
    timestamp_utc timestamp with time zone NOT NULL,
    value double precision NOT NULL
);


ALTER TABLE public.sensor_measurement OWNER TO postgres;

--
-- Name: _hyper_1_1_chunk; Type: TABLE; Schema: _timescaledb_internal; Owner: postgres
--

CREATE TABLE _timescaledb_internal._hyper_1_1_chunk (
    CONSTRAINT constraint_1 CHECK (((timestamp_utc >= '2026-02-25 00:00:00+00'::timestamp with time zone) AND (timestamp_utc < '2026-02-26 00:00:00+00'::timestamp with time zone)))
)
INHERITS (public.sensor_measurement);


ALTER TABLE _timescaledb_internal._hyper_1_1_chunk OWNER TO postgres;

--
-- Name: model; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.model (
    model_id integer NOT NULL,
    name character varying(64) NOT NULL,
    description text,
    model_type character varying(32) NOT NULL,
    parameters jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.model OWNER TO postgres;

--
-- Name: model_model_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.model_model_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.model_model_id_seq OWNER TO postgres;

--
-- Name: model_model_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.model_model_id_seq OWNED BY public.model.model_id;


--
-- Name: model_sensor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.model_sensor (
    model_id integer NOT NULL,
    sensor_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.model_sensor OWNER TO postgres;

--
-- Name: sensor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sensor (
    sensor_id integer NOT NULL,
    sensor_label character varying(64) NOT NULL,
    sensor_hash character varying(128) NOT NULL,
    node_id integer,
    sensor_type_id integer,
    description text,
    location public.geography(PointZ,4326),
    last_seen timestamp with time zone DEFAULT now(),
    status character varying(32) DEFAULT 'active'::character varying,
    metadata jsonb
);


ALTER TABLE public.sensor OWNER TO postgres;

--
-- Name: sensor_node; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sensor_node (
    node_id integer NOT NULL,
    node_label character varying(64) NOT NULL,
    node_hash character varying(128) NOT NULL,
    location public.geography(PointZ,4326),
    last_seen timestamp with time zone DEFAULT now(),
    status character varying(32) DEFAULT 'active'::character varying,
    description text
);


ALTER TABLE public.sensor_node OWNER TO postgres;

--
-- Name: sensor_node_node_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sensor_node_node_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sensor_node_node_id_seq OWNER TO postgres;

--
-- Name: sensor_node_node_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sensor_node_node_id_seq OWNED BY public.sensor_node.node_id;


--
-- Name: sensor_sensor_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sensor_sensor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sensor_sensor_id_seq OWNER TO postgres;

--
-- Name: sensor_sensor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sensor_sensor_id_seq OWNED BY public.sensor.sensor_id;


--
-- Name: sensor_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sensor_type (
    sensor_type_id integer NOT NULL,
    name character varying(64) NOT NULL,
    phenomenon character varying(128) NOT NULL,
    unit character varying(32) NOT NULL,
    value_min double precision,
    value_max double precision,
    description text
);


ALTER TABLE public.sensor_type OWNER TO postgres;

--
-- Name: sensor_type_sensor_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sensor_type_sensor_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sensor_type_sensor_type_id_seq OWNER TO postgres;

--
-- Name: sensor_type_sensor_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sensor_type_sensor_type_id_seq OWNED BY public.sensor_type.sensor_type_id;


--
-- Name: model model_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.model ALTER COLUMN model_id SET DEFAULT nextval('public.model_model_id_seq'::regclass);


--
-- Name: sensor sensor_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensor ALTER COLUMN sensor_id SET DEFAULT nextval('public.sensor_sensor_id_seq'::regclass);


--
-- Name: sensor_node node_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensor_node ALTER COLUMN node_id SET DEFAULT nextval('public.sensor_node_node_id_seq'::regclass);


--
-- Name: sensor_type sensor_type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensor_type ALTER COLUMN sensor_type_id SET DEFAULT nextval('public.sensor_type_sensor_type_id_seq'::regclass);


--
-- Data for Name: cache_inval_bgw_job; Type: TABLE DATA; Schema: _timescaledb_cache; Owner: postgres
--



--
-- Data for Name: cache_inval_extension; Type: TABLE DATA; Schema: _timescaledb_cache; Owner: postgres
--



--
-- Data for Name: cache_inval_hypertable; Type: TABLE DATA; Schema: _timescaledb_cache; Owner: postgres
--



--
-- Data for Name: hypertable; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

INSERT INTO _timescaledb_catalog.hypertable VALUES (1, 'public', 'sensor_measurement', '_timescaledb_internal', '_hyper_1', 1, '_timescaledb_internal', 'calculate_chunk_interval', 0, 0, NULL, NULL);


--
-- Data for Name: chunk; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

INSERT INTO _timescaledb_catalog.chunk VALUES (1, 1, '_timescaledb_internal', '_hyper_1_1_chunk', NULL, false, 0, false);


--
-- Data for Name: dimension; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

INSERT INTO _timescaledb_catalog.dimension VALUES (1, 1, 'timestamp_utc', 'timestamp with time zone', true, NULL, NULL, NULL, 86400000000, NULL, NULL, NULL);


--
-- Data for Name: dimension_slice; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

INSERT INTO _timescaledb_catalog.dimension_slice VALUES (1, 1, 1771977600000000, 1772064000000000);


--
-- Data for Name: chunk_constraint; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

INSERT INTO _timescaledb_catalog.chunk_constraint VALUES (1, 1, 'constraint_1', NULL);
INSERT INTO _timescaledb_catalog.chunk_constraint VALUES (1, NULL, '1_1_sensor_measurement_pkey', 'sensor_measurement_pkey');
INSERT INTO _timescaledb_catalog.chunk_constraint VALUES (1, NULL, '1_2_sensor_measurement_sensor_id_fkey', 'sensor_measurement_sensor_id_fkey');


--
-- Data for Name: chunk_data_node; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--



--
-- Data for Name: chunk_index; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

INSERT INTO _timescaledb_catalog.chunk_index VALUES (1, '1_1_sensor_measurement_pkey', 1, 'sensor_measurement_pkey');
INSERT INTO _timescaledb_catalog.chunk_index VALUES (1, '_hyper_1_1_chunk_sensor_measurement_timestamp_utc_idx', 1, 'sensor_measurement_timestamp_utc_idx');
INSERT INTO _timescaledb_catalog.chunk_index VALUES (1, '_hyper_1_1_chunk_sensor_measurement_timestamp_utc_idx_1', 1, 'sensor_measurement_timestamp_utc_idx');


--
-- Data for Name: compression_chunk_size; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--



--
-- Data for Name: continuous_agg; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--



--
-- Data for Name: continuous_agg_migrate_plan; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--



--
-- Data for Name: continuous_agg_migrate_plan_step; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--



--
-- Data for Name: continuous_aggs_bucket_function; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--



--
-- Data for Name: continuous_aggs_hypertable_invalidation_log; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--



--
-- Data for Name: continuous_aggs_invalidation_threshold; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--



--
-- Data for Name: continuous_aggs_materialization_invalidation_log; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--



--
-- Data for Name: dimension_partition; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--



--
-- Data for Name: hypertable_compression; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--



--
-- Data for Name: hypertable_data_node; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--



--
-- Data for Name: metadata; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--



--
-- Data for Name: remote_txn; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--



--
-- Data for Name: tablespace; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--



--
-- Data for Name: bgw_job; Type: TABLE DATA; Schema: _timescaledb_config; Owner: postgres
--



--
-- Data for Name: _hyper_1_1_chunk; Type: TABLE DATA; Schema: _timescaledb_internal; Owner: postgres
--

INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (62, '2026-02-25 13:30:00+00', 5);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (63, '2026-02-25 13:30:00+00', 285);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (64, '2026-02-25 13:30:00+00', 4.6);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (65, '2026-02-25 13:30:00+00', 213);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (66, '2026-02-25 13:30:00+00', 4.3);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (67, '2026-02-25 13:30:00+00', 136);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (68, '2026-02-25 13:30:00+00', 8.3);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (69, '2026-02-25 13:30:00+00', 80);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (70, '2026-02-25 13:30:00+00', 8.5);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (71, '2026-02-25 13:30:00+00', 60);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (72, '2026-02-25 13:30:00+00', 6.3);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (77, '2026-02-25 13:30:00+00', 111);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (78, '2026-02-25 13:30:00+00', 7.1);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (79, '2026-02-25 13:30:00+00', 111);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (80, '2026-02-25 13:30:00+00', 6.6);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (81, '2026-02-25 13:30:00+00', 79);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (82, '2026-02-25 13:30:00+00', 7.6);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (83, '2026-02-25 13:30:00+00', 44);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (84, '2026-02-25 13:30:00+00', 7.2);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (85, '2026-02-25 13:30:00+00', 19);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (86, '2026-02-25 13:30:00+00', 6.4);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (87, '2026-02-25 13:30:00+00', 118);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (88, '2026-02-25 13:30:00+00', 8.6);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (89, '2026-02-25 13:30:00+00', 47);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (90, '2026-02-25 13:30:00+00', 7.6);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (91, '2026-02-25 13:30:00+00', 46);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (92, '2026-02-25 13:30:00+00', 6.7);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (93, '2026-02-25 13:30:00+00', 16);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (95, '2026-02-25 13:30:00+00', 51);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (96, '2026-02-25 13:30:00+00', 6.3);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (97, '2026-02-25 13:30:00+00', 60);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (98, '2026-02-25 13:30:00+00', 7.6);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (99, '2026-02-25 13:30:00+00', 122);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (100, '2026-02-25 13:30:00+00', 8.4);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (103, '2026-02-25 13:30:00+00', 299);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (104, '2026-02-25 13:30:00+00', 8.2);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (105, '2026-02-25 13:30:00+00', 105);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (106, '2026-02-25 13:30:00+00', 8.9);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (107, '2026-02-25 13:30:00+00', 282);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (108, '2026-02-25 13:30:00+00', 8.4);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (109, '2026-02-25 13:30:00+00', 221);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (110, '2026-02-25 13:30:00+00', 9.1);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (111, '2026-02-25 13:30:00+00', 186);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (113, '2026-02-25 13:30:00+00', 116);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (114, '2026-02-25 13:30:00+00', 8.1);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (115, '2026-02-25 13:30:00+00', 73);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (116, '2026-02-25 13:30:00+00', 8);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (1, '2026-02-25 13:30:00+00', 133);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (2, '2026-02-25 13:30:00+00', 6.1);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (3, '2026-02-25 13:30:00+00', 188);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (4, '2026-02-25 13:30:00+00', 6.2);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (5, '2026-02-25 13:30:00+00', 125);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (6, '2026-02-25 13:30:00+00', 4.9);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (7, '2026-02-25 13:30:00+00', 122);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (8, '2026-02-25 13:30:00+00', 5.1);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (9, '2026-02-25 13:30:00+00', 72);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (10, '2026-02-25 13:30:00+00', 4.3);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (11, '2026-02-25 13:30:00+00', 95);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (12, '2026-02-25 13:30:00+00', 5.2);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (13, '2026-02-25 13:30:00+00', 141);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (14, '2026-02-25 13:30:00+00', 6.7);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (15, '2026-02-25 13:30:00+00', 60);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (16, '2026-02-25 13:30:00+00', 4.6);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (17, '2026-02-25 13:30:00+00', 88);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (18, '2026-02-25 13:30:00+00', 5.7);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (19, '2026-02-25 13:30:00+00', 32);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (20, '2026-02-25 13:30:00+00', 4.3);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (23, '2026-02-25 13:30:00+00', 567);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (24, '2026-02-25 13:30:00+00', 5.1);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (25, '2026-02-25 13:30:00+00', 495);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (26, '2026-02-25 13:30:00+00', 5.2);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (27, '2026-02-25 13:30:00+00', 99);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (28, '2026-02-25 13:30:00+00', 5.4);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (29, '2026-02-25 13:30:00+00', 80);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (30, '2026-02-25 13:30:00+00', 5.5);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (31, '2026-02-25 13:30:00+00', 66);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (32, '2026-02-25 13:30:00+00', 5.4);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (33, '2026-02-25 13:30:00+00', 90);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (34, '2026-02-25 13:30:00+00', 5.7);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (35, '2026-02-25 13:30:00+00', 44);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (36, '2026-02-25 13:30:00+00', 5.5);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (37, '2026-02-25 13:30:00+00', 120);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (38, '2026-02-25 13:30:00+00', 6.6);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (39, '2026-02-25 13:30:00+00', 42);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (40, '2026-02-25 13:30:00+00', 6.9);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (41, '2026-02-25 13:30:00+00', 44);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (42, '2026-02-25 13:30:00+00', 3.2);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (43, '2026-02-25 13:30:00+00', 124);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (44, '2026-02-25 13:30:00+00', 4.5);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (45, '2026-02-25 13:30:00+00', 87);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (46, '2026-02-25 13:30:00+00', 6.1);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (47, '2026-02-25 13:30:00+00', 158);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (48, '2026-02-25 13:30:00+00', 7.1);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (49, '2026-02-25 13:30:00+00', 73);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (50, '2026-02-25 13:30:00+00', 5.9);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (51, '2026-02-25 13:30:00+00', 179);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (52, '2026-02-25 13:30:00+00', 6);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (55, '2026-02-25 13:30:00+00', 105);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (56, '2026-02-25 13:30:00+00', 6.9);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (59, '2026-02-25 13:30:00+00', 135);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (60, '2026-02-25 13:30:00+00', 6.6);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (61, '2026-02-25 13:30:00+00', 119);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (170, '2026-02-25 13:30:00+00', 6.8);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (171, '2026-02-25 13:30:00+00', 93);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (172, '2026-02-25 13:30:00+00', 8.1);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (173, '2026-02-25 13:30:00+00', 101);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (174, '2026-02-25 13:30:00+00', 9.2);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (175, '2026-02-25 13:30:00+00', 89);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (176, '2026-02-25 13:30:00+00', 9.7);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (177, '2026-02-25 13:30:00+00', 94);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (178, '2026-02-25 13:30:00+00', 9);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (181, '2026-02-25 13:30:00+00', 126);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (182, '2026-02-25 13:30:00+00', 10.4);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (185, '2026-02-25 13:30:00+00', 147);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (186, '2026-02-25 13:30:00+00', 8.3);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (187, '2026-02-25 13:30:00+00', 106);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (188, '2026-02-25 13:30:00+00', 8.4);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (189, '2026-02-25 13:30:00+00', 112);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (190, '2026-02-25 13:30:00+00', 8.6);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (191, '2026-02-25 13:30:00+00', 194);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (192, '2026-02-25 13:30:00+00', 8.1);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (193, '2026-02-25 13:30:00+00', 140);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (194, '2026-02-25 13:30:00+00', 8.8);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (195, '2026-02-25 13:30:00+00', 61);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (196, '2026-02-25 13:30:00+00', 9.2);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (197, '2026-02-25 13:30:00+00', 172);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (198, '2026-02-25 13:30:00+00', 6.8);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (199, '2026-02-25 13:30:00+00', 204);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (200, '2026-02-25 13:30:00+00', 9.4);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (201, '2026-02-25 13:30:00+00', 67);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (202, '2026-02-25 13:30:00+00', 8.3);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (203, '2026-02-25 13:30:00+00', 98);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (204, '2026-02-25 13:30:00+00', 8.4);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (205, '2026-02-25 13:30:00+00', 48);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (206, '2026-02-25 13:30:00+00', 8.1);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (209, '2026-02-25 13:30:00+00', 174);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (210, '2026-02-25 13:30:00+00', 7.7);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (211, '2026-02-25 13:30:00+00', 337);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (212, '2026-02-25 13:30:00+00', 7.8);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (213, '2026-02-25 13:30:00+00', 199);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (214, '2026-02-25 13:30:00+00', 6.9);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (215, '2026-02-25 13:30:00+00', 174);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (216, '2026-02-25 13:30:00+00', 8.4);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (217, '2026-02-25 13:30:00+00', 148);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (119, '2026-02-25 13:30:00+00', 74);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (120, '2026-02-25 13:30:00+00', 7.7);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (121, '2026-02-25 13:30:00+00', 82);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (122, '2026-02-25 13:30:00+00', 7);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (123, '2026-02-25 13:30:00+00', 122);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (124, '2026-02-25 13:30:00+00', 7.9);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (127, '2026-02-25 13:30:00+00', 84);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (128, '2026-02-25 13:30:00+00', 8.4);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (129, '2026-02-25 13:30:00+00', 146);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (130, '2026-02-25 13:30:00+00', 8.3);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (131, '2026-02-25 13:30:00+00', 165);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (132, '2026-02-25 13:30:00+00', 6.7);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (133, '2026-02-25 13:30:00+00', 98);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (134, '2026-02-25 13:30:00+00', 7.9);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (137, '2026-02-25 13:30:00+00', 65);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (138, '2026-02-25 13:30:00+00', 9);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (139, '2026-02-25 13:30:00+00', 136);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (140, '2026-02-25 13:30:00+00', 8.8);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (141, '2026-02-25 13:30:00+00', 119);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (142, '2026-02-25 13:30:00+00', 8.9);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (143, '2026-02-25 13:30:00+00', 99);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (144, '2026-02-25 13:30:00+00', 7.6);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (145, '2026-02-25 13:30:00+00', 70);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (146, '2026-02-25 13:30:00+00', 8.4);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (147, '2026-02-25 13:30:00+00', 70);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (148, '2026-02-25 13:30:00+00', 8.4);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (149, '2026-02-25 13:30:00+00', 69);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (150, '2026-02-25 13:30:00+00', 8.2);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (151, '2026-02-25 13:30:00+00', 26);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (152, '2026-02-25 13:30:00+00', 9);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (153, '2026-02-25 13:30:00+00', 42);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (154, '2026-02-25 13:30:00+00', 9.5);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (155, '2026-02-25 13:30:00+00', 43);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (156, '2026-02-25 13:30:00+00', 8.1);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (157, '2026-02-25 13:30:00+00', 114);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (158, '2026-02-25 13:30:00+00', 7.9);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (159, '2026-02-25 13:30:00+00', 93);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (160, '2026-02-25 13:30:00+00', 7.4);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (161, '2026-02-25 13:30:00+00', 54);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (162, '2026-02-25 13:30:00+00', 6.5);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (163, '2026-02-25 13:30:00+00', 65);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (164, '2026-02-25 13:30:00+00', 5.8);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (165, '2026-02-25 13:30:00+00', 135);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (166, '2026-02-25 13:30:00+00', 6.2);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (167, '2026-02-25 13:30:00+00', 224);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (168, '2026-02-25 13:30:00+00', 6.6);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (169, '2026-02-25 13:30:00+00', 86);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (218, '2026-02-25 13:30:00+00', 8.1);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (219, '2026-02-25 13:30:00+00', 105);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (220, '2026-02-25 13:30:00+00', 6.8);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (221, '2026-02-25 13:30:00+00', 139);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (222, '2026-02-25 13:30:00+00', 7.7);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (223, '2026-02-25 13:30:00+00', 176);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (224, '2026-02-25 13:30:00+00', 7.2);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (225, '2026-02-25 13:30:00+00', 131);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (226, '2026-02-25 13:30:00+00', 8.4);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (227, '2026-02-25 13:30:00+00', 89);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (228, '2026-02-25 13:30:00+00', 6.4);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (229, '2026-02-25 13:30:00+00', 77);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (230, '2026-02-25 13:30:00+00', 8.2);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (231, '2026-02-25 13:30:00+00', 104);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (232, '2026-02-25 13:30:00+00', 7.9);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (233, '2026-02-25 13:30:00+00', 181);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (234, '2026-02-25 13:30:00+00', 8.6);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (235, '2026-02-25 13:30:00+00', 144);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (236, '2026-02-25 13:30:00+00', 8.3);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (239, '2026-02-25 13:30:00+00', 241);
INSERT INTO _timescaledb_internal._hyper_1_1_chunk VALUES (240, '2026-02-25 13:30:00+00', 7.2);


--
-- Data for Name: job_errors; Type: TABLE DATA; Schema: _timescaledb_internal; Owner: postgres
--



--
-- Data for Name: model; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: model_sensor; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: sensor; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sensor VALUES (1, 'water_level', 'fe4c476de5cdecb1dbc2783ae39c0c365fead27a929abac19ebf29a43b7d6101', 1, 1, 'Water level sensor data from ARSO', '01010000A0E6100000E86A2BF697FD2F40105D50DF3257474033333333334B6940', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (2, 'water_temperature', 'bd958607cef95fd0bf288eddd558b99608aa1a10161458bd43d13461afe00fcb', 1, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000E86A2BF697FD2F40105D50DF3257474033333333334B6940', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (3, 'water_level', '806b169291920c3e3297a9e5afaa4429086594a5168b0633da7fce969dab878d', 2, 1, 'Water level sensor data from ARSO', '01010000A0E61000003D49BA66F20D3040D7868A71FE524740CDCCCCCCCC346840', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (4, 'water_temperature', '2ea71095d623e018f45d6e0f6319f2e2488a687996c6c2b326230ade63234de0', 2, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000003D49BA66F20D3040D7868A71FE524740CDCCCCCCCC346840', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (5, 'water_level', '6981cd482be4a1c6a180049d97b4c70eb085c9b463d4ef4e6482cae5c89b6ce4', 3, 1, 'Water level sensor data from ARSO', '01010000A0E61000005ABBED4273053040F437A110015B47400000000000C06940', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (6, 'water_temperature', 'e05364b3987870ba93a1f9bf00bdbfd4e5f31e5311fdeef5665a216d9385efaf', 3, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000005ABBED4273053040F437A110015B47400000000000C06940', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (7, 'water_level', 'f043440994c6bdd3ee7e13cf0ec49f3c5085926a5f7942a5c33d30786e002c72', 4, 1, 'Water level sensor data from ARSO', '01010000A0E6100000B398D87C5C3B304026DF6C7363424740A4703D0AD72B6540', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (8, 'water_temperature', 'ebe535769da782383de30057fdb9b531b7713b887b59e618cf8b8adfd0db44d2', 4, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000B398D87C5C3B304026DF6C7363424740A4703D0AD72B6540', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (9, 'water_level', 'bd4934ae2afdc7d3a13d021d4b471aadbfaccdc296e36a6d7b1b09e760f62062', 5, 1, 'Water level sensor data from ARSO', '01010000A0E610000057957D570407304041BCAE5FB0674740AE47E17A14066D40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (10, 'water_temperature', '88852c26f4d8852a713cf48ac4ec8611ca269f4036224a458e6d12b60ccd3275', 5, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000057957D570407304041BCAE5FB0674740AE47E17A14066D40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (11, 'water_level', 'd6f03838208a3b7b66b253ccc2500132092b53b1cd548e09b68be6f92e5764a3', 6, 1, 'Water level sensor data from ARSO', '01010000A0E6100000EC4CA1F31A233040C286A757CA564740EC51B81E85EB6740', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (12, 'water_temperature', '7e1422b8d12de307ea5fdd9f0e1034065826b9f22ac2e693bc8d7b0efa3f9805', 6, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000EC4CA1F31A233040C286A757CA564740EC51B81E85EB6740', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (13, 'water_level', 'bc3cc285f02a1579c6a48c6b2a1beb72263d642e724cdf4df634a963fb8d0bd3', 7, 1, 'Water level sensor data from ARSO', '01010000A0E6100000C347C494487A30403FC6DCB58444474052B81E85EB496340', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (14, 'water_temperature', '94c08682a778bfc9e69cd43e3c423b9980f66b6b9a7420ad05bed74eec48307e', 7, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000C347C494487A30403FC6DCB58444474052B81E85EB496340', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (15, 'water_level', '2f2243be9edf904f9c8977075060b527fd7114042691d2b7c45a917679265a55', 8, 1, 'Water level sensor data from ARSO', '01010000A0E61000003A7AFCDEA62F30409626A5A0DB574740E17A14AE47D16740', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (16, 'water_temperature', '3164632f63edc2cf57dd311f86f1ba11c6457dbdf998bcace94cfd2f7c3d268f', 8, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000003A7AFCDEA62F30409626A5A0DB574740E17A14AE47D16740', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (17, 'water_level', 'bb44d52d7f618739d0178e73bb57502c612b877c73d05fbba5504ca10ecffcf6', 9, 1, 'Water level sensor data from ARSO', '01010000A0E6100000693524EEB164304072F90FE9B7574740B81E85EB51E06640', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (18, 'water_temperature', '0e413f62ef8e20a78e6f1262a17fd85a160a7b996649d36eea46c3d72f06d3b2', 9, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000693524EEB164304072F90FE9B7574740B81E85EB51E06640', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (19, 'water_level', '10ef56afc92bae4298c6a4b5bb2f93b915b441a28791b0c09578e37976145761', 10, 1, 'Water level sensor data from ARSO', '01010000A0E6100000D5CA845FEA4F3040349D9D0C8E624740D7A3703D0AAF6C40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (20, 'water_temperature', '3e972cc681eb7771d5c1d9c0811cb76b2672d1e972303f14bd6c6268a964f108', 10, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000D5CA845FEA4F3040349D9D0C8E624740D7A3703D0AAF6C40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (21, 'water_level', 'ec74271bc013bc6a1126f0c00b7db4ab57b223d3ebd2ffc326e61b704f9a4e87', 11, 1, 'Water level sensor data from ARSO', '01010000A0E61000006891ED7C3F55304031B1F9B83668474048E17A14AE0F6C40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (22, 'water_temperature', 'e65acf66be25926e52afc451a0d1c0d4c2f73ae3a5b1f8943f7cc28a04f521b8', 11, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000006891ED7C3F55304031B1F9B83668474048E17A14AE0F6C40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (23, 'water_level', '1c1dcd67bcb4d8d5ab6764eba62982ca4e402fb9d71edb5b3e2452057c6d0d7f', 12, 1, 'Water level sensor data from ARSO', '01010000A0E61000009D11A5BDC1F72D4014CB2DAD864C4740E17A14AE47D97440', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (24, 'water_temperature', 'd76c398e5c85e2b0460bd3897a37c488eb1fd1ffdd38687658b012e9d5b51012', 12, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000009D11A5BDC1F72D4014CB2DAD864C4740E17A14AE47D97440', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (25, 'water_level', '4bed0df8def8c3fdc78811a335669ac4a980861abd6d19e465c07b94859fc7f1', 13, 1, 'Water level sensor data from ARSO', '01010000A0E6100000079964E42CBC2F40C503CAA65C354740CDCCCCCCCCD46A40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (26, 'water_temperature', '4ac8d38d0b4978e6858e07110b7b7da08f8d0185f7f619700f6979429aa879f0', 13, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000079964E42CBC2F40C503CAA65C354740CDCCCCCCCCD46A40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (27, 'water_level', 'ff87a39ae3db7a1c8e49cb0201510650350927ec0ab59de89979623b4455c224', 14, 1, 'Water level sensor data from ARSO', '01010000A0E610000020D26F5F07FE2F4008E6E8F17B2F474085EB51B81E2D6940', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (28, 'water_temperature', 'e23a0b02a3ccca5f11e68464952342cf2911fa4da7bba6ed98a7eb94636ce9b8', 14, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000020D26F5F07FE2F4008E6E8F17B2F474085EB51B81E2D6940', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (29, 'water_level', '2a15629023dae28b2c1e8a6be789a1fd74844a40f33534c24f5708c7eb5ac2ee', 15, 1, 'Water level sensor data from ARSO', '01010000A0E61000000CCD751A69093040D95A5F24B4314740EC51B81E85BB6840', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (30, 'water_temperature', '6ad28b220f8ba0b4a708db7405b90a1d785cac287269c5bcb57ec5c00e63618d', 15, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000000CCD751A69093040D95A5F24B4314740EC51B81E85BB6840', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (31, 'water_level', '7fc9bdebd171591ea3333052b18245c173970285d99863d5ec527ed2ca4329a1', 16, 1, 'Water level sensor data from ARSO', '01010000A0E61000006E8B321B64B22D40EA043411363C47409A99999999EB8140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (32, 'water_temperature', '0308f25c8e8cc5d78fb1731fbeb4df8628a2e88ec566397362b0d2a613512edf', 16, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000006E8B321B64B22D40EA043411363C47409A99999999EB8140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (33, 'water_level', 'f1a21bff66d8797c618781fd1a52f58af2d057322ecd7eadb21f957111c9d422', 17, 1, 'Water level sensor data from ARSO', '01010000A0E610000077F86BB2460D2E40A7CB6262F34947400000000000E07440', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (34, 'water_temperature', '5a32a2615c00ecfabec4324041c26b585fa615c070d78fb7e36586861f95d67a', 17, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000077F86BB2460D2E40A7CB6262F34947400000000000E07440', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (35, 'water_level', '8d68d85b68badac30c02be3100b0bd1a0f55c2e62d099296b1408a8666cef862', 18, 1, 'Water level sensor data from ARSO', '01010000A0E6100000EC51B81E854B2E40AD2F12DA723A47403D0AD7A370B97F40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (36, 'water_temperature', '3652dbc8a2a66b69c539b79a9b1b252f87401131c856b4ab68222f46acc0be2f', 18, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000EC51B81E854B2E40AD2F12DA723A47403D0AD7A370B97F40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (37, 'water_level', 'bba420cefa61a28a2baa3d079189597d5e00dead183ea0e7d2bffc53ef576a9c', 19, 1, 'Water level sensor data from ARSO', '01010000A0E6100000A5A0DB4B1A132E40713D0AD7A348474000000000007C7540', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (38, 'water_temperature', 'f4b33e8e776c791e5dd01c28a0d2ea917cb43646dbe7904c8cc3cf39347a2b1f', 19, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000A5A0DB4B1A132E40713D0AD7A348474000000000007C7540', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (39, 'water_level', '69b8d3120e3d90a37432ac701fb94575b86ed112339ef175fa6f7f9eb3527f90', 20, 1, 'Water level sensor data from ARSO', '01010000A0E610000085EB51B81E252E40D4601A868F404740F6285C8FC24D7940', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (40, 'water_temperature', '0095087940e52530bc2bae34ae6f7b218f2129e232fb4e90650a53fd174af59a', 20, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000085EB51B81E252E40D4601A868F404740F6285C8FC24D7940', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (41, 'water_level', 'e17944f7f80428de2dd3409fcd58dde8bc3ac16d8f13cc025f391da8673576c6', 21, 1, 'Water level sensor data from ARSO', '01010000A0E610000087BF266BD4532E40D1CB28965B4E4740273108AC1C5C7440', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (42, 'water_temperature', 'b79712643a266b448ae153444717a229cea2ebcf5a0137b7a4fba4839e6ba4b8', 21, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000087BF266BD4532E40D1CB28965B4E4740273108AC1C5C7440', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (43, 'water_level', '64b0d6cc735b55f3750d2c5ae30c6fb3e9b3a76c53907e98cd88be776ed8591c', 22, 1, 'Water level sensor data from ARSO', '01010000A0E6100000624A24D1CBD82E40738577B9884747400000000000807240', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (44, 'water_temperature', '2c3104e7536d5790ac4341da14b07041b7307b56e7f0b6c33ae9a9f258d01fe4', 22, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000624A24D1CBD82E40738577B9884747400000000000807240', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (45, 'water_level', 'c62cd579ef4d5058a3bd94d60ebea4c2ccddbf1a3980e33e9827aba5af4be8cd', 23, 1, 'Water level sensor data from ARSO', '01010000A0E61000004E7FF62345C42E405BB1BFEC9E30474085EB51B81E517940', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (46, 'water_temperature', '5e3b0d259eefe09a40dd328857564ff0225556a579cbc8f187facb0a59240497', 23, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000004E7FF62345C42E405BB1BFEC9E30474085EB51B81E517940', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (47, 'water_level', 'b1cf75713210bd0416e50060448a0d0ffc48723598baca84a77db0203148e979', 24, 1, 'Water level sensor data from ARSO', '01010000A0E610000078B988EFC4FC2E40ED0DBE30992647401F85EB51B8B67040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (48, 'water_temperature', '58ff49958a145b1dbd99a6544f3e90664f368ef755b3df8426217517f0cfb3d8', 24, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000078B988EFC4FC2E40ED0DBE30992647401F85EB51B8B67040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (49, 'water_level', 'e0155f176b7bde5cf2f141655f52d6a05f5249704b3123866d9d0edbdb6f1833', 25, 1, 'Water level sensor data from ARSO', '01010000A0E610000048DC63E943572F404DF8A57EDE2847405C8FC2F5280C6E40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (50, 'water_temperature', '4599bb721831de2b56f2d8eadf03e92c1e6d61073b10bf633ffab9fdef05d05f', 25, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000048DC63E943572F404DF8A57EDE2847405C8FC2F5280C6E40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (51, 'water_level', '0fa481baab54f2bf8ebf85656eaf56504d6e5e28345ee5c34d62887579344784', 26, 1, 'Water level sensor data from ARSO', '01010000A0E610000058E2016553CE2F405E11FC6F252F474048E17A14AE276A40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (52, 'water_temperature', '09cd6a8941514869aa2965833ed3d88694ca66e189579048842dbf9aea7a5e77', 26, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000058E2016553CE2F405E11FC6F252F474048E17A14AE276A40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (53, 'water_level', '465ccaaadac1f2cd0404d143502e086237254dc3fcbaafcaec45f686297c08af', 27, 1, 'Water level sensor data from ARSO', '01010000A0E6100000618E1EBFB7F92E40569A94826E2B4740AE47E17A14B27140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (54, 'water_temperature', '233652316a94c6d1ef6bfb60d1f47ddbdc8565ffa3773f948d9c48fd19c41a5d', 27, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000618E1EBFB7F92E40569A94826E2B4740AE47E17A14B27140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (55, 'water_level', '68439aaf14a1d67a316c64cb9ee480a4e817c8a08f8d0b7a59186c217522fa92', 28, 1, 'Water level sensor data from ARSO', '01010000A0E610000077BE9F1A2F4D2F40176536C8242B4740A4703D0AD73B6E40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (56, 'water_temperature', '2daf3ee36cd61ef2a9e42467d1bee831cab4166bb98cbcd9c9b17e7074e0937b', 28, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000077BE9F1A2F4D2F40176536C8242B4740A4703D0AD73B6E40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (57, 'water_level', '9685db3debc66a42d76d72d56f0b06091ae670868459d068b1eebba297fef9d3', 29, 1, 'Water level sensor data from ARSO', '01010000A0E610000052448655BCC12F40EDF0D7648D2A474048E17A14AEE76B40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (58, 'water_temperature', '1c57d08929324d067e5a16e6982e94a6bdaacb372310e9455e458aec160f86bc', 29, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000052448655BCC12F40EDF0D7648D2A474048E17A14AEE76B40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (59, 'water_level', '80162d5ef44893c6a8858651029f7a11dde1ed2568f0cf6e03faf703c5a92a4b', 30, 1, 'Water level sensor data from ARSO', '01010000A0E6100000361FD7868AC12F40A64412BD8C2E47400AD7A3703DC26A40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (60, 'water_temperature', '256646aeaef7fa34a89d8cb4c9d3ea92b85598c9ad6f96f1773413aa1dc7699c', 30, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000361FD7868AC12F40A64412BD8C2E47400AD7A3703DC26A40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (61, 'water_level', '4c4370003a6984124e0b463b651ba1a721764152854306514d90f650de2a8eb6', 31, 1, 'Water level sensor data from ARSO', '01010000A0E6100000064CE0D6DD5C2F40467C2766BD4C4740713D0AD7A3486F40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (62, 'water_temperature', '549698791351564756a187ff55d952b6e771b8fe5152dfcd8d05b992db4b4449', 31, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000064CE0D6DD5C2F40467C2766BD4C4740713D0AD7A3486F40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (63, 'water_level', 'ad30b41f0d02497bb3aba02c2f0e2d6e8e26e469977a6ce350dbb125330bfc86', 32, 1, 'Water level sensor data from ARSO', '01010000A0E61000005B087250C2BC2F406CB2463D444747401F85EB51B82E6C40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (64, 'water_temperature', '9d275a8e206b28b38b643bd52c45bcfa9d70c116e3a9ee4ccd18306b16137094', 32, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000005B087250C2BC2F406CB2463D444747401F85EB51B82E6C40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (65, 'water_level', '3c2c7eaaf0d10ec6745df8b15d1c372b8b35b9015a1cdee7096cb8c125b5e1f3', 33, 1, 'Water level sensor data from ARSO', '01010000A0E6100000465F419AB108304070253B360235474033333333333B6940', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (66, 'water_temperature', '971bee1ef411a159394ec72d8fa284a29335d102e61fe944404d65e2c567c98c', 33, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000465F419AB108304070253B360235474033333333333B6940', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (67, 'water_level', 'ce13c4388a730cfac17b34f21c5a6454e304bd47a0fba23b7543808b310a099d', 34, 1, 'Water level sensor data from ARSO', '01010000A0E6100000A73FFB9122922B40FB743C66A03E4740CDCCCCCCCCD08840', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (68, 'water_temperature', '2c4ea34b8647d3e7dfacf92c95ae3975bd694359ed02576beceea44e52e29c3f', 34, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000A73FFB9122922B40FB743C66A03E4740CDCCCCCCCCD08840', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (69, 'water_level', 'a09b28603585cad67e966f3ae3c1a1d683e4dae750d59dd4deceb2d489ae1ec1', 35, 1, 'Water level sensor data from ARSO', '01010000A0E610000024624A24D11B2C404FAF94658837474014AE47E17AA68140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (70, 'water_temperature', '25c073ff25956bb8f5893a8f705f93d84b64eebc1e81bff5ab0642312dd6a654', 35, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000024624A24D11B2C404FAF94658837474014AE47E17AA68140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (71, 'water_level', '1627d4c6d84d71d91da9bf8aa766292f590cfe22620ef31723abd741bcb5c436', 36, 1, 'Water level sensor data from ARSO', '01010000A0E6100000F71E2E39EE442C4089D2DEE00B2F4740CDCCCCCCCCC07A40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (72, 'water_temperature', '2d715ab7a93d300cae1af8087093fb3cac8c7eac41eea65217903ff05440234e', 36, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000F71E2E39EE442C4089D2DEE00B2F4740CDCCCCCCCCC07A40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (73, 'water_level', '52aab7a335f4420f26be791e872874fddb574cf0d274570aaf05064b5db85f11', 37, 1, 'Water level sensor data from ARSO', '01010000A0E6100000B4E55C8AABFA2B40A7E8482EFF3947401F85EB51B8308340', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (74, 'water_temperature', 'a93f74669398d408c09d082a0b1e2aba2a2080f95e16e7bc921997198ba66b3b', 37, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000B4E55C8AABFA2B40A7E8482EFF3947401F85EB51B8308340', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (75, 'water_level', 'e1f4f8a2a693a8f0ce6e0ba575459e67238f5b77d523a213f2aa1d84737bd8a3', 38, 1, 'Water level sensor data from ARSO', '01010000A0E6100000FC00A43671622C404D672783A3344740D7A3703D0ABF8B40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (76, 'water_temperature', '4551cab6bf0014673c9faa9d221c309eb94ca366c8df92d3e3ad0ba262d82d7b', 38, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000FC00A43671622C404D672783A3344740D7A3703D0ABF8B40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (77, 'water_level', '87a9f3eea07d9c751f8551806efcd8034e41c7a90797b5a350baf69d1c357e1a', 39, 1, 'Water level sensor data from ARSO', '01010000A0E6100000799274CDE42B2C40EE7C3F355E3247409A99999999B18140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (78, 'water_temperature', '1242d45a883154045d47dccd7e8b8b6fe9ee736ef144165db06fe99b5c0aae0c', 39, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000799274CDE42B2C40EE7C3F355E3247409A99999999B18140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (79, 'water_level', '7b2ed974f79d20249ce0b791dfd80169ae19cfdda7e662ff12b25aa53d5d6430', 40, 1, 'Water level sensor data from ARSO', '01010000A0E6100000A089B0E1E9C52B40DD41EC4CA1234740B81E85EB51688040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (80, 'water_temperature', '9d569326a76eff67b8c9172764569dd04da318d5088e116a6238833e02956a46', 40, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000A089B0E1E9C52B40DD41EC4CA1234740B81E85EB51688040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (81, 'water_level', '08c0d993e88c3cc6899ab4b421a5bd450ef4ad2da389bd3f426225999d392a01', 41, 1, 'Water level sensor data from ARSO', '01010000A0E610000062F3716DA8482C404F401361C32B47400000000000E07940', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (82, 'water_temperature', '38f4f89654b66543474ba5a14f0854cb9e6b5ae588191983f78b9f457c95956d', 41, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000062F3716DA8482C404F401361C32B47400000000000E07940', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (83, 'water_level', 'cf167ff9cafd1b04da74cd8bb032f03e4fee6c8b6db0bf23c91a6844c55e68be', 42, 1, 'Water level sensor data from ARSO', '01010000A0E610000029CB10C7BAA82B401D9430D3F62347403D0AD7A3707B8040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (84, 'water_temperature', '1e21344c372ac001103858582bb788e838994a860455ec12fcc2f436a7fc8f35', 42, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000029CB10C7BAA82B401D9430D3F62347403D0AD7A3707B8040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (85, 'water_level', '18ec707d37b68f797f497cc7769a067d15f5429dbe675d9841970ea023097bdd', 43, 1, 'Water level sensor data from ARSO', '01010000A0E610000042959A3DD0BA2B40CF143AAFB12347400000000000708040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (86, 'water_temperature', '815c0fdcbd8575dac39e41d0fc6628f27a4625cd4d563d6d16612813110bb2ba', 43, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000042959A3DD0BA2B40CF143AAFB12347400000000000708040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (87, 'water_level', 'aa991e281556e381fe6e2432075a87a23ac3bf354aad1407e20b958015e9e046', 44, 1, 'Water level sensor data from ARSO', '01010000A0E61000002C4833164DC72B40F12900C6332447409A99999999798040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (88, 'water_temperature', '574b0413fd15208de91a9f005aa87a3f5b0c2eadf2c0b9037b823641bab7e2ba', 44, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000002C4833164DC72B40F12900C6332447409A99999999798040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (89, 'water_level', '32e18f530a4b9e6f5a1a4d4b4fdd1264d542ace0c24d6d30e80e03138c35d563', 45, 1, 'Water level sensor data from ARSO', '01010000A0E61000002D211FF46CE62B409E4143FF042347403333333333877F40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (90, 'water_temperature', '27a5672b9a2dec09dcfdec5a027ac2931e14f264fdcfd9620bf9e37a063878da', 45, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000002D211FF46CE62B409E4143FF042347403333333333877F40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (91, 'water_level', 'd295135e1ddc775834595c5671078f800798d48f48349c7def8926dcb7cf07c5', 46, 1, 'Water level sensor data from ARSO', '01010000A0E6100000179AEB34D2322C408B71FE26142E474014AE47E17AB87D40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (92, 'water_temperature', '3dca3cc925c2663f40318e99801219bda8deb182b4e350a58bd05126cdb9f2a0', 46, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000179AEB34D2322C408B71FE26142E474014AE47E17AB87D40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (93, 'water_level', 'e14c2ba696898c55e17096d96a45d7920fa1798d7a91fa6d8a92d71352b9d483', 47, 1, 'Water level sensor data from ARSO', '01010000A0E6100000A5BDC11726332C4099D36531B12D47403D0AD7A370417D40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (94, 'water_temperature', '0574518696407bb336c1b4cb1844a8f61dcf5b13af560191139bf566fc5f5912', 47, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000A5BDC11726332C4099D36531B12D47403D0AD7A370417D40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (95, 'water_level', 'be0bf5cb8503d6a4e355a0e87520ab495dfbc9e0aae23dc0e3c83132dcc3f74f', 48, 1, 'Water level sensor data from ARSO', '01010000A0E610000017821C9430332C40D235936FB62D474085EB51B81E397D40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (96, 'water_temperature', 'b569c3b60bdfea176b6d083c816afbff930f95aa14b7b2aaedff802e61e5d5eb', 48, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000017821C9430332C40D235936FB62D474085EB51B81E397D40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (97, 'water_level', '604fe557699bc002ac5afc5bed05beb922c8a94b206f4649fd1b3df9bc9408d0', 49, 1, 'Water level sensor data from ARSO', '01010000A0E610000086C954C1A8542C40F37684D3822B47407B14AE47E1827940', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (98, 'water_temperature', '33124c99fd1b8cb688338870ad9a9c70987f45e333e515bd34cedc916f7f052e', 49, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000086C954C1A8542C40F37684D3822B47407B14AE47E1827940', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (99, 'water_level', 'e849bd1aaace4cf9e2bf12dc00c5a76e9ddb4537b49961a0b623b4fcc57d620d', 50, 1, 'Water level sensor data from ARSO', '01010000A0E61000006B9A779CA2A32C40A9D903ADC020474033333333333F7640', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (100, 'water_temperature', '8b34ec7f777410c5ac03c22935d514f14da33c772bf3fb3087105d3915f79559', 50, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000006B9A779CA2A32C40A9D903ADC020474033333333333F7640', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (101, 'water_level', '4dcbfaae7f66a49d8a4c2fb8882cb95ec9055e37be6bb800763131546b66576d', 51, 1, 'Water level sensor data from ARSO', '01010000A0E6100000FDBCA94885E12C408F8D40BCAE0F4740713D0AD7A3C47240', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (102, 'water_temperature', 'c79bce93304071a4f1b9b00f53963c57bc2f10ec62488ce27429d86769413291', 51, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000FDBCA94885E12C408F8D40BCAE0F4740713D0AD7A3C47240', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (103, 'water_level', '62fd32f1490e9196250e679e8759a08c6116ca019114b5f9a8cca8457be3a68b', 52, 1, 'Water level sensor data from ARSO', '01010000A0E6100000982F2FC03E2A2D4009168733BF0A4740C3F5285C8FC27040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (104, 'water_temperature', '4808ec0bf13475cce95b208b58949eb33a7b60be5e22d5b7242a10576c30f2d6', 52, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000982F2FC03E2A2D4009168733BF0A4740C3F5285C8FC27040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (105, 'water_level', '758c13999cd2b6a00c74943cf373eaf2d3f276bba0c28c7425881d58dbbbdb98', 53, 1, 'Water level sensor data from ARSO', '01010000A0E6100000D5CF9B8A54A82D40658D7A884607474085EB51B81ED56C40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (106, 'water_temperature', '6ad4a5ed0eee9ad70b86f55ab93c403b1af74e8e6eddcbdda17085e0ac388351', 53, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000D5CF9B8A54A82D40658D7A884607474085EB51B81ED56C40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (107, 'water_level', '9682555a3cba1f7058f61e7d5b108862c93e7786e437d22bf948a7e596798467', 54, 1, 'Water level sensor data from ARSO', '01010000A0E6100000AE122C0E672E2E40B3295778970F4740AE47E17A143E6840', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (108, 'water_temperature', '0dba7ef9a967a266ff0c5cfd1a3dd2cc432572e7504437d00e36a2d5c4f99b8d', 54, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000AE122C0E672E2E40B3295778970F4740AE47E17A143E6840', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (109, 'water_level', '715ae68d05c59e1d221ba887be2336d30ce8ead0b86356d82274a13ccae531d2', 55, 1, 'Water level sensor data from ARSO', '01010000A0E6100000475A2A6F47382F40CA89761552F246400AD7A3703D2A6140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (110, 'water_temperature', '29675ac83a61cdd87b9d5bcce41600bdb95356e7cb2b51800d4f967adcc309ce', 55, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000475A2A6F47382F40CA89761552F246400AD7A3703D2A6140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (111, 'water_level', 'c4e7145c3dac36b2324c845cf7d67037713585cb64bada43f034fc68ab3d976e', 56, 1, 'Water level sensor data from ARSO', '01010000A0E61000006DFFCA4A93622F40FC3559A31EEE46408FC2F5285C2F6040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (112, 'water_temperature', '632d9349efd67afda0561bca58026c04e4562bc1906724a6130e997e2e648116', 56, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000006DFFCA4A93622F40FC3559A31EEE46408FC2F5285C2F6040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (113, 'water_level', '209a63c937621e9e1c5b419592519b611559334605b0578062f7ce0eb74e294f', 57, 1, 'Water level sensor data from ARSO', '01010000A0E610000031B1F9B836842C4070EB6E9EEA2447401F85EB51B8727740', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (114, 'water_temperature', 'f66fd0211662432ad5cb2d0b37c4def233391be010241be2a8aeae9be733e8a0', 57, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000031B1F9B836842C4070EB6E9EEA2447401F85EB51B8727740', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (115, 'water_level', '8866974083bd930b171eaaff6c8300e239e8c048f9df350bff06972075e742d5', 58, 1, 'Water level sensor data from ARSO', '01010000A0E61000009A25016A6A992C402041F163CC2D47405C8FC2F5288C7E40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (116, 'water_temperature', '65b975b35c30ed4396320b45f20c12cd0cf8d2f7fc7fbfa0c0059ca3a7bf1297', 58, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000009A25016A6A992C402041F163CC2D47405C8FC2F5288C7E40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (117, 'water_level', '84202e424051a6d8b0ecf960a11102b5acacc0d7864db94f08066b82a1e45e4b', 59, 1, 'Water level sensor data from ARSO', '01010000A0E610000098C0ADBB798A2C40C5FEB27BF2344740AE47E17A14448740', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (118, 'water_temperature', '812bddccd3b6a1803a44ccca51f48a9debc3b2d708229063e8ad4e978c0b0172', 59, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000098C0ADBB798A2C40C5FEB27BF2344740AE47E17A14448740', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (119, 'water_level', '780bcca3e4d5323c2318a6b261f47950abbc0ec57d6f79052d770c3ae98546d0', 60, 1, 'Water level sensor data from ARSO', '01010000A0E610000001A4367172FF2C40091B9E5E292747400000000000588040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (120, 'water_temperature', 'e11617ab4a654753b5e82dd167334aa2fe79f62a633e8c81094e6ba1b7f5b060', 60, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000001A4367172FF2C40091B9E5E292747400000000000588040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (121, 'water_level', '001665fce3faf85b31335256b6708721bb2699aedfe7fe781ab7d3df6fad12c9', 61, 1, 'Water level sensor data from ARSO', '01010000A0E61000000EA14ACD1EB82C406C5B94D9201F47400000000000507640', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (122, 'water_temperature', '6071b6e111a054052aed79be9e61cfc921364f431998f446e86e04d292e6616b', 61, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000000EA14ACD1EB82C406C5B94D9201F47400000000000507640', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (123, 'water_level', 'b3b1e6f9245a9508583f9f5dd3fa452a5937d0e3ec2bd6596bda946de31acfd0', 62, 1, 'Water level sensor data from ARSO', '01010000A0E6100000D769A4A5F2A62C4069520ABABD144740EC51B81E85977440', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (124, 'water_temperature', 'ccf4f572afd52b3172d18d99bdec2ea17f47d70b2f7776874b5a159de64b03ec', 62, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000D769A4A5F2A62C4069520ABABD144740EC51B81E85977440', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (125, 'water_level', 'c5c7b7b8deff618196c8ba2112f9785bd07bc25c1573a603490ce2e4d6251276', 63, 1, 'Water level sensor data from ARSO', '01010000A0E61000004FE960FD9FD32C40C425C79DD2114740D7A3703D0A2B7340', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (126, 'water_temperature', '78780f6a3efa532fd4c72c881eb3469194ab3a2ee954738ff799f9c9f150d2c1', 63, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000004FE960FD9FD32C40C425C79DD2114740D7A3703D0A2B7340', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (127, 'water_level', '8a888ed87d29baa6cb5d586fae72a4b338b43fdbfc6163580e42f0d975337cc2', 64, 1, 'Water level sensor data from ARSO', '01010000A0E61000009F76F86BB2362C401A8BA6B393054740B81E85EB51AC7D40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (128, 'water_temperature', '7863c6625c4b01154ea6a49ed35bec545b796184425f6085afc30ebe465337fe', 64, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000009F76F86BB2362C401A8BA6B393054740B81E85EB51AC7D40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (129, 'water_level', 'ad1d4cffff310ad31221a8b68cdbb89cb6d39af295930991c6f5f55ca18a965a', 65, 1, 'Water level sensor data from ARSO', '01010000A0E6100000BFF1B56796942C406B7D91D096134740E17A14AE47757540', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (130, 'water_temperature', '5993cc896a8fcb3a8be807043e689d5fa4121c3e7a6945c95836a865f5d091a6', 65, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000BFF1B56796942C406B7D91D096134740E17A14AE47757540', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (131, 'water_level', '1a9482afe25637ce5f785b401841f0674242100f4dae1f3481ab6ffa30e486bd', 66, 1, 'Water level sensor data from ARSO', '01010000A0E6100000A60F5D50DF522C40062AE3DF671C474052B81E85EBE57B40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (132, 'water_temperature', '43a2a8cfece86d4ac7f09e41073774dea768b8c88d4d7c003a4d5631a81bdf3a', 66, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000A60F5D50DF522C40062AE3DF671C474052B81E85EBE57B40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (133, 'water_level', '79fd2ae9add1b6eb40dcc1752925d1f3d1fded2a7c3fc8232507ea2120765452', 67, 1, 'Water level sensor data from ARSO', '01010000A0E6100000C4995FCD01922C4019ADA3AA091647405C8FC2F528647640', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (134, 'water_temperature', '42c0854a5e5185e053b737c578dc4af9039afe95708f0882e587e13846cd4479', 67, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000C4995FCD01922C4019ADA3AA091647405C8FC2F528647640', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (135, 'water_level', '8ceb075a4bc104fcf7e7140d58a04fd0d11c6bc71672131ef197d9113a799578', 68, 1, 'Water level sensor data from ARSO', '01010000A0E6100000AE81AD122C2E2D40923F1878EE2947409A99999999678240', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (136, 'water_temperature', '246f2add4fe4aff100a4a17487b12fddc8bde9f617869f32959bcc232dfb95f1', 68, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000AE81AD122C2E2D40923F1878EE2947409A99999999678240', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (137, 'water_level', '8fa5a9d624bebccd69bd0520c3faf953a39d5bb393b662ebd3e6335989e1b6a6', 69, 1, 'Water level sensor data from ARSO', '01010000A0E610000027BD6F7CED392D40787FBC57AD1C474066666666662A7740', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (138, 'water_temperature', 'c6655636ede159c20c44b934e273dde87408c8e6a0dc71cd282bfdeea3bd0c40', 69, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000027BD6F7CED392D40787FBC57AD1C474066666666662A7740', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (139, 'water_level', '71a0eddcadf04f619392ef80388df2197976649385ad060cf3910b1ccdebfb7b', 70, 1, 'Water level sensor data from ARSO', '01010000A0E6100000F6402B3064352D40FB22A12DE71247400000000000D47240', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (140, 'water_temperature', 'e48b93e45eb620ac4aa8a5788bd8b6118a1be363d137f94e12a2c5f4f1d464e8', 70, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000F6402B3064352D40FB22A12DE71247400000000000D47240', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (141, 'water_level', '1def40f64a89a70f0f3e2007ba980369cdea919cc9fa1ad7e3509edd7caa9679', 71, 1, 'Water level sensor data from ARSO', '01010000A0E6100000B37BF2B0503B2D40AF5A99F04B0D47406666666666267140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (142, 'water_temperature', 'e9b74d22427672fd6199946d68009294a6e4a5abf00c243ac4c6dd746c21015e', 71, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000B37BF2B0503B2D40AF5A99F04B0D47406666666666267140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (143, 'water_level', '0f2f727909ab7ca74a1157659f20110be3d4c4cf73f454b3af465dc6d3b7fa66', 72, 1, 'Water level sensor data from ARSO', '01010000A0E6100000390B7BDAE13F2D40F645425BCE1D47406666666666BE7740', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (144, 'water_temperature', 'ca2151804539d27094abf335b5b9a1ab451d4fb2fd4298fe3d52f533830f6024', 72, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000390B7BDAE13F2D40F645425BCE1D47406666666666BE7740', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (145, 'water_level', '6212a838cffe5ec8c74853511b892b45572dc67f1dccdff797098be3626ecd93', 73, 1, 'Water level sensor data from ARSO', '01010000A0E61000007901F6D1A93B2D40E674594C6C1247401F85EB51B8B27240', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (146, 'water_temperature', '08d6f826755dc4227079ff1adae03bdf4cd83f8968d3371a65546cc0b0b3ae33', 73, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000007901F6D1A93B2D40E674594C6C1247401F85EB51B8B27240', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (147, 'water_level', 'cfd4367bf4020a422501f324159eeef7c611fe9b9f0755b0a895614b4061ad2f', 74, 1, 'Water level sensor data from ARSO', '01010000A0E61000006440F67AF7372D40CA32C4B12E124740A4703D0AD7977240', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (148, 'water_temperature', '15d576cd8c1ae5e1217dbde9334428156e4f514e41988913cfd19700db7a0651', 74, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000006440F67AF7372D40CA32C4B12E124740A4703D0AD7977240', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (149, 'water_level', '49fff1b2b22b6b2190a6598536be0398a17ebae4fe3d20a5edf38dce4bbb9689', 75, 1, 'Water level sensor data from ARSO', '01010000A0E6100000397F130A11202D40C32ADEC83C164740B81E85EB51047440', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (150, 'water_temperature', '37f60a08a1a8d0f6055be9c31aac4ca7390a2c38ffbbf3fbf7fbd708c34830a9', 75, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000397F130A11202D40C32ADEC83C164740B81E85EB51047440', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (151, 'water_level', 'ac61ab9b1596c10ff918d3c7d575f9945362af1b207d801410fc6b8165d770b2', 76, 1, 'Water level sensor data from ARSO', '01010000A0E6100000C9E53FA4DF1E2D40A6D0798D5D1247407B14AE47E1D67240', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (152, 'water_temperature', '87213545fad77f097ec78afa3a12cfa1bc33f321ae9b2ee6df0f92b42ceaa1c2', 76, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000C9E53FA4DF1E2D40A6D0798D5D1247407B14AE47E1D67240', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (153, 'water_level', '2945a601cb1fc6a3cfd0b316d0902c207abc18ad4f23c3036055c79f21cbf599', 77, 1, 'Water level sensor data from ARSO', '01010000A0E6100000035B25581CFE2D40D5CF9B8A54104740D7A3703D0A076D40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (154, 'water_temperature', '50dfbf1a13383764ab4393d50362352bbc6cd5475f25f997efad5099749139c2', 77, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000035B25581CFE2D40D5CF9B8A54104740D7A3703D0A076D40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (155, 'water_level', '6c5fe784b3a8cbb20c3bb6872eea75625f5f3d4b2504be6e96e075f181a794a0', 78, 1, 'Water level sensor data from ARSO', '01010000A0E6100000A245B6F3FD442E4015A930B610084740713D0AD7A3087040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (156, 'water_temperature', 'deb930a6d1d3d962037c75693e4e2bc4c65ca1eba3d6e935a484d3e03243c712', 78, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000A245B6F3FD442E4015A930B610084740713D0AD7A3087040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (157, 'water_level', 'c4f3f85ef0d4454b27206c52fa62b9f2b400229b6a3fb8f28314ba59d9db989b', 79, 1, 'Water level sensor data from ARSO', '01010000A0E61000004A9869FB57462E40E6965643E2FA464052B81E85EB916C40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (158, 'water_temperature', 'fd29bf77ac3121062e05f25fa8a8105d4ccc852b5035807cbd5bd68365fdca18', 79, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000004A9869FB57462E40E6965643E2FA464052B81E85EB916C40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (159, 'water_level', '9b503e0e327cd0ae5ee9c705deaadf1e22eb31dd8540e3671617fad79c0658fb', 80, 1, 'Water level sensor data from ARSO', '01010000A0E610000012F758FAD0752E40B48EAA2688FE46407B14AE47E1126A40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (160, 'water_temperature', '18787a20d1a2be843acedae159510a5cf33d4165b19f869a28a941ae5956adc1', 80, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000012F758FAD0752E40B48EAA2688FE46407B14AE47E1126A40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (161, 'water_level', '5ceebfa8f76cd0fa78a6c5df80296e6d196c0af12da68b8b77e305f5059ce2f2', 81, 1, 'Water level sensor data from ARSO', '01010000A0E61000002AE3DF675C982E402C4833164D03474085EB51B81EFD6840', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (162, 'water_temperature', '01fe3f284174568d7ed48a1270e5c3ab26a58de365e3911cb60812c909de5200', 81, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000002AE3DF675C982E402C4833164D03474085EB51B81EFD6840', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (163, 'water_level', '683ca51bd8212c4f728f558dcc143cbdb1f7fc76cbfdf502cfce354b036234f8', 82, 1, 'Water level sensor data from ARSO', '01010000A0E6100000BC0512143F662F406ADE718A8E1C474014AE47E17A5C6B40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (164, 'water_temperature', '0068f904fe0a15dade9cd7e9eb5b831957014981d764be005d4258b8a6db3431', 82, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000BC0512143F662F406ADE718A8E1C474014AE47E17A5C6B40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (165, 'water_level', '9bc4b9bd77fc18c02b3e99e2741b76f96f4febd4592bea455fb88b47d1e001b0', 83, 1, 'Water level sensor data from ARSO', '01010000A0E61000000DC347C494682F409947FE60E0F54640713D0AD7A3806140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (166, 'water_temperature', 'aed482c771fb0ab92d5d63f9afc461a87eac7521e2a30c5875552665482ed96b', 83, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000000DC347C494682F409947FE60E0F54640713D0AD7A3806140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (167, 'water_level', '95c8ae1c272efa21a4710612d84d3de61c1ae4f8491f689d52b54ed1b8fb45a6', 84, 1, 'Water level sensor data from ARSO', '01010000A0E61000006B2BF697DD332F40F5108DEE2016474052B81E85EB116840', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (168, 'water_temperature', 'c3845c652c46d7af6eda97a12be28c962cfddcdc3f1be7b0e6a0097320443741', 84, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000006B2BF697DD332F40F5108DEE2016474052B81E85EB116840', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (169, 'water_level', '2fb744efd53fd2cce7d4698bab8ce40634d6b8974eac5016cb140197806d7116', 85, 1, 'Water level sensor data from ARSO', '01010000A0E61000003D44A33B884D2F4060B01BB62D064740295C8FC2F5C86740', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (170, 'water_temperature', '3c524dd27231bf4b2e1907034ec823028b3beb7b6c0d584b56df03ac1c1f0b0e', 85, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000003D44A33B884D2F4060B01BB62D064740295C8FC2F5C86740', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (171, 'water_level', 'ddc9de52f609b4132ef65a8724d748535c0ac4f6186101a52e09249652b8337e', 86, 1, 'Water level sensor data from ARSO', '01010000A0E61000004E0B5EF415B42D40A54E401361BB4640AE47E17A14666B40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (172, 'water_temperature', '84c19756cb60b17e9b14856c2a97c4309dd03dc179f0ef5350b6e884ce2b299e', 86, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000004E0B5EF415B42D40A54E401361BB4640AE47E17A14666B40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (173, 'water_level', 'e3880b4bb9b7b238e6cea770493ad3da30954ca710b1e49f5a72851c0e145b4d', 87, 1, 'Water level sensor data from ARSO', '01010000A0E6100000D8BB3FDEAB262E40832F4CA60ABE4640AE47E17A149E6640', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (174, 'water_temperature', '0d3ceeeebe4106a386157c08ca73595edac7d7ccfeafbe5dec5877a13e6a7a07', 87, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000D8BB3FDEAB262E40832F4CA60ABE4640AE47E17A149E6640', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (175, 'water_level', '2c179798faf62a357c925e00fd4b3b44b43995125391cba5ab06827b4c8c76b5', 88, 1, 'Water level sensor data from ARSO', '01010000A0E6100000A12DE7525CA52E4021E527D53ED14640713D0AD7A3C05F40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (176, 'water_temperature', 'f97b8ef853e7d7973b375d59506a98c27aacf510aadb05242ef2dbc3363ee3d7', 88, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000A12DE7525CA52E4021E527D53ED14640713D0AD7A3C05F40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (177, 'water_level', 'f465ddce579f548b9ea15d5cf798f90021641871a0c0b143163c60047e8b48f8', 89, 1, 'Water level sensor data from ARSO', '01010000A0E610000065C22FF5F3C62D408CDB68006FCD464048E17A14AE5B7C40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (178, 'water_temperature', '9d5968ac45133152a3a501bb233ba9c82564a37408f28e0903ea9be85bee9087', 89, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000065C22FF5F3C62D408CDB68006FCD464048E17A14AE5B7C40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (179, 'water_level', '6db4dfd92f048e00600f86a329cdb9e9a3ac6d2e2c1a51971ae15f78a684e0f6', 90, 1, 'Water level sensor data from ARSO', '01010000A0E61000003F00A94D9CEC2D407D0569C6A2C1464014AE47E17A746840', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (180, 'water_temperature', 'd3c17e893bd36ba11e1e131fc66fba8fbf25c74c4a3bcba2a4a78ee14aba29cc', 90, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000003F00A94D9CEC2D407D0569C6A2C1464014AE47E17A746840', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (181, 'water_level', 'f8a2d9e7301bf44e0dc2d418e34ed4a4bd0ea33909232a179c2c200d5b5991e1', 91, 1, 'Water level sensor data from ARSO', '01010000A0E61000005AF5B9DA8A7D2E406DE2E47E87CE464014AE47E17AB46040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (182, 'water_temperature', 'a22ade2eec518b9b88930cfd6d1fb6ddc029326cd905453938b9c25e63bc11b4', 91, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000005AF5B9DA8A7D2E406DE2E47E87CE464014AE47E17AB46040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (183, 'water_level', '4c515c0531dbec44f8c1c7d4522e0d7fa2c93c42d4ec899e69098638df819f4b', 92, 1, 'Water level sensor data from ARSO', '01010000A0E61000004F401361C3732E4054573ECBF3D04640A4703D0AD7CB6040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (184, 'water_temperature', '810d30f430de34d445b7e77efa530c41495d7e5f6258fcc9e1f7abf2af4512ec', 92, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000004F401361C3732E4054573ECBF3D04640A4703D0AD7CB6040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (185, 'water_level', '54326812b0d78fd9a26fffdffb4eae236b3c9cfb68e0ce6a1c0e674fd5171ea9', 93, 1, 'Water level sensor data from ARSO', '01010000A0E610000044C02154A9992C40B988EFC4ACFB46407B14AE47E1DE7140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (186, 'water_temperature', 'f7fea766b2be470a69c36bb913a312e303ccbb56d5cf297e3cfff7fa448d81b2', 93, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000044C02154A9992C40B988EFC4ACFB46407B14AE47E1DE7140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (187, 'water_level', '29f600fc513b731e4ad7afe32b99b4e845c35078d83a6aebdd20b8e439a6b068', 94, 1, 'Water level sensor data from ARSO', '01010000A0E61000008143A852B3B72C400820B58993FB4640713D0AD7A3D87140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (188, 'water_temperature', 'fe359c32e0935dfdc853f46f7154f21a990b16d9970fd113151c6325c17919a6', 94, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000008143A852B3B72C400820B58993FB4640713D0AD7A3D87140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (189, 'water_level', 'c9039da26a7553a33066a0cc668ee5e4408bef5ef0ba147ccb704feac35685e5', 95, 1, 'Water level sensor data from ARSO', '01010000A0E61000002DEC6987BF162D40ACC5A7001807474085EB51B81E957140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (190, 'water_temperature', 'fe153beed55dab1cfa0b00ab6c97dcd381c5c379e4593b4535a4fda3bedb4168', 95, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000002DEC6987BF162D40ACC5A7001807474085EB51B81E957140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (191, 'water_level', '7a4ebca1e8340569a8aec7b6f04de9b0aca9f6736a4a430bb9910421892357c0', 96, 1, 'Water level sensor data from ARSO', '01010000A0E6100000042159C0049E2C40D13FC1C58AFA4640AE47E17A14E67140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (192, 'water_temperature', '3bd517fc91c07ae9b3586da5e7d2f5d584acfd39aa955768308f495d1e82a1a4', 96, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000042159C0049E2C40D13FC1C58AFA4640AE47E17A14E67140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (193, 'water_level', '984e237074cfcd25301139b68b8771937da92f3b968ff62c78d4454bf52aeed2', 97, 1, 'Water level sensor data from ARSO', '01010000A0E6100000AF42CA4FAAAD2C40F6B4C35F93F946405C8FC2F528EC7140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (194, 'water_temperature', 'ed6a4a45f2b1d5175cd994a82b569bc3612f9079888063a32ba12c22df16b8cc', 97, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000AF42CA4FAAAD2C40F6B4C35F93F946405C8FC2F528EC7140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (195, 'water_level', '606565d945e3e163a971d71eab00eea3a7c7d99b2718836ae30b0d89f734bfe5', 98, 1, 'Water level sensor data from ARSO', '01010000A0E6100000CC0BB08F4EBD2C40B77F65A549F546401F85EB51B8767240', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (196, 'water_temperature', '3f50651b9ca9dd06b8740a5743b4ef0c8c19744345642fbfb3692ccd1297bab0', 98, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000CC0BB08F4EBD2C40B77F65A549F546401F85EB51B8767240', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (197, 'water_level', '29f2a0e2d3242a4fa64a4cb2061cc94b2841c377bae1d9586afa4cdbda1fc7ad', 99, 1, 'Water level sensor data from ARSO', '01010000A0E6100000D6C56D3480072D4032C9C859D8F746406666666666327440', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (198, 'water_temperature', '5fba4bceadcabcd8c29af04a003b97f22105ae867480d295954ccbbeb56d3287', 99, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000D6C56D3480072D4032C9C859D8F746406666666666327440', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (199, 'water_level', 'fed4de0261e227a71e30487f98d4c5975d100377dbd66db0a7d844bd15a63563', 100, 1, 'Water level sensor data from ARSO', '01010000A0E610000019E25817B7112D405F984C158CFA46408FC2F5285CFB7140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (200, 'water_temperature', '71239c087afb4f19f03cdeb6259b9fcf1be0740d92662e27d8060f0b0290209a', 100, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000019E25817B7112D405F984C158CFA46408FC2F5285CFB7140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (201, 'water_level', 'b76b3e68df5df8b5fac5772a87e05b94872e6624ceb4d89ecb8820b354272949', 101, 1, 'Water level sensor data from ARSO', '01010000A0E610000014E8137992E42C40E8DEC325C705474000000000008C7240', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (202, 'water_temperature', 'cae62424fbd18494d46c64d102debbfec603a971f7299b45f855e23c6cf4f8b3', 101, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000014E8137992E42C40E8DEC325C705474000000000008C7240', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (203, 'water_level', '742a371d69a56786e0cb5d33bf197e0dfafe222fb3e3c04df0240d642ccf5ff8', 102, 1, 'Water level sensor data from ARSO', '01010000A0E610000038BEF6CC92B02C406440F67AF7074740C3F5285C8F527540', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (204, 'water_temperature', '9b735d5f0e55f98bf87d6e9d3d55f3c8e5861f58e21943f5dd692ebb060cb093', 102, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000038BEF6CC92B02C406440F67AF7074740C3F5285C8F527540', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (205, 'water_level', '5241f93417e9ec23a2add02f2dd5ac9e2f343ca745c1d0da29c007eb7be3744b', 103, 1, 'Water level sensor data from ARSO', '01010000A0E61000008EAF3DB324E02C4099F56228270647403333333333A77240', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (206, 'water_temperature', '55794c5d4a0433c8aea648dbbecea3ef408145e0c27018f02113369bebe1aed3', 103, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000008EAF3DB324E02C4099F56228270647403333333333A77240', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (207, 'water_level', 'f1957e80cb3919b3a7c3d0c66ac8b76a5daf4e26fa5d174d671f9e827e14f6d1', 104, 1, 'Water level sensor data from ARSO', '01010000A0E6100000C2120F289B022D403CDA38622DDA46406ABC749318098240', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (208, 'water_temperature', '39daf01d9e47ae99e3a10dc1024802e21bc4c30cb03896e4f7bb979f96cccebe', 104, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000C2120F289B022D403CDA38622DDA46406ABC749318098240', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (209, 'water_level', '41d39a20449ddcb84890ac76ef2f7ef950462f3e898ae8f7d7bdc65727476c78', 105, 1, 'Water level sensor data from ARSO', '01010000A0E6100000C824236761CF2C40E882FA9639DD464000000000001A8140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (210, 'water_temperature', 'a87c9a150835112577234c1b94c7bb225bf02f144ff2d07ed4e3ecda2d1386ba', 105, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000C824236761CF2C40E882FA9639DD464000000000001A8140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (211, 'water_level', '68faebd5038e4ca824978c57f9d276ac79dd6f9add363cb296dffb79ca954cd0', 106, 1, 'Water level sensor data from ARSO', '01010000A0E61000009B20EA3E00B92C40F5B9DA8AFDE146409CC420B0720C8140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (212, 'water_temperature', '5a5225695a7e22990f41bc37e0e3f6be4eb1c1def2096c94b8653f26364168e5', 106, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000009B20EA3E00B92C40F5B9DA8AFDE146409CC420B0720C8140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (213, 'water_level', 'a4fb4510ee89970b0fe6066fb1a44d2f9b5675d5c8a4e44be6f879b790072f07', 107, 1, 'Water level sensor data from ARSO', '01010000A0E610000026C79DD2C1BA2C4068791EDC9DE546408B6CE7FBA97C8140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (214, 'water_temperature', '028d09b84c4d07b0248ef16434d5724f641b9e90c87bf3003e4c9037fe2ed3a4', 107, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000026C79DD2C1BA2C4068791EDC9DE546408B6CE7FBA97C8140', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (215, 'water_level', '5ecbce97d468c836140b043b5c52182d18975441ab26e4ade3661df67347f9b5', 108, 1, 'Water level sensor data from ARSO', '01010000A0E6100000E466B8019F5F2C40A1A17F828BDD4640C3F5285C8F3E8040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (216, 'water_temperature', '54e0ae72b5074855471614c2fa2d9b33a921531e8110c92e26a9a02a04d44ebd', 108, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000E466B8019F5F2C40A1A17F828BDD4640C3F5285C8F3E8040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (217, 'water_level', 'fc3a9b7165db4cc58979062e2295cca8540244d75d2bdb43764e836678a321db', 109, 1, 'Water level sensor data from ARSO', '01010000A0E61000000E677E3507682C40B9AAECBB22E446403D0AD7A370F17F40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (218, 'water_temperature', '0629eb2a2c7b2e227236cb5fe57d20c3da0644644ef550da0a73eda0f75a70bb', 109, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000000E677E3507682C40B9AAECBB22E446403D0AD7A370F17F40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (219, 'water_level', 'e2000edd47fd07ae95475cfb3bb7c30c617365babcdaefee8e6195abbfbabf0b', 110, 1, 'Water level sensor data from ARSO', '01010000A0E6100000B1169F02605C2C4080B74082E2E346408FC2F5285C218040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (220, 'water_temperature', '52574e73dc9961505e06b3516567125735acc84a9d7f2f4a5d3de2e88266bbe8', 110, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000B1169F02605C2C4080B74082E2E346408FC2F5285C218040', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (221, 'water_level', '26c1dbe82935e4af295746dc59de263595bf6c2f41213e58356ea0cea80bfd5a', 111, 1, 'Water level sensor data from ARSO', '01010000A0E6100000D7A3703D0A872C40271422E010EA46400000000000D07B40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (222, 'water_temperature', '4ec74ac7f9975bb967f43041416a9107f84ae9e83fc606aecb4e8b15b1a82582', 111, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000D7A3703D0A872C40271422E010EA46400000000000D07B40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (223, 'water_level', '1cfcb363b05ae784f5297fcbcf88848ad438f0f073707ad1b465e679f7e4bba8', 112, 1, 'Water level sensor data from ARSO', '01010000A0E6100000A661F88898822C4068CBB91457E94640EC51B81E85CF7B40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (224, 'water_temperature', '4a2d7b42cc0d5ab8c8dab79fe7fdf5f22cf75f796a3216289f11fdb6273cc0a4', 112, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000A661F88898822C4068CBB91457E94640EC51B81E85CF7B40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (225, 'water_level', '8d88905b91912628df9bd36f8f50012f0a768fa282e9b174605bc84443705aab', 113, 1, 'Water level sensor data from ARSO', '01010000A0E61000007FFB3A70CE682C407120240B98F446403D0AD7A370157E40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (226, 'water_temperature', 'ddd830dea5c360d9505911a44825643f573b5f9797bc9d414e94eff3f9b96d9d', 113, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000007FFB3A70CE682C407120240B98F446403D0AD7A370157E40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (227, 'water_level', '1998909c851ea6e2131fc970035d593e46403d50abc3d815249223bcce2409c3', 114, 1, 'Water level sensor data from ARSO', '01010000A0E6100000DE718A8EE4622D408B89CDC7B53547406666666666E08340', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (228, 'water_temperature', '0d93907892372bcde06fe9a4090603dcf318b630f933f69f119985db59a00957', 114, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000DE718A8EE4622D408B89CDC7B53547406666666666E08340', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (229, 'water_level', '939a400098f734b96cc4ab7177d0ea780b372e6c8f0b598e72b4d37945364dd4', 115, 1, 'Water level sensor data from ARSO', '01010000A0E61000000EF3E505D8E72D4045813E912729474014AE47E17A107540', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (230, 'water_temperature', 'e84a07dab361c9a3acff8fe0487ab5df0a400bce6a8d0a5bc609f45fc7d2bf00', 115, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000000EF3E505D8E72D4045813E912729474014AE47E17A107540', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (231, 'water_level', '8e314ed4dabce951160399463b55a4fc72b5ddb77b396fe36147c81d15ab06f3', 116, 1, 'Water level sensor data from ARSO', '01010000A0E610000051A04FE449022E407D5C1B2AC629474052B81E85EB997340', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (232, 'water_temperature', 'e15e6a31a8a7e318c503778384040759573e36d7f396264dae9bcad2ce6a488a', 116, 2, 'Water temperature sensor data from ARSO', '01010000A0E610000051A04FE449022E407D5C1B2AC629474052B81E85EB997340', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (233, 'water_level', '2f48249226620beb3baaa48ccc049cd8b4651c05e79b823c05a98b90605cf120', 117, 1, 'Water level sensor data from ARSO', '01010000A0E61000001BD82AC1E2702E4059C0046EDD1D4740CDCCCCCCCCC46D40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (234, 'water_temperature', '6ca363fbedd411285a49cb4d2847b12dcade164612ca66c97272b3394efeace6', 117, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000001BD82AC1E2702E4059C0046EDD1D4740CDCCCCCCCCC46D40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (235, 'water_level', '6673326d9d963df3d6ac99c9b5bdd5d7dfad80a8a5381cebf63016675584d003', 118, 1, 'Water level sensor data from ARSO', '01010000A0E61000002FC03E3A75852E40707CED99251D4740713D0AD7A3C86C40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (236, 'water_temperature', 'f140d12704beb1393041d7785d7534c239afd422067d5a2d75365d40414790da', 118, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000002FC03E3A75852E40707CED99251D4740713D0AD7A3C86C40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (237, 'water_level', 'f59cb5bc704729915c8e41328fceaf10479183e8eb16f5ea844582c2a0f6d941', 119, 1, 'Water level sensor data from ARSO', '01010000A0E6100000B988EFC4AC772E40A4198BA6B31347400AD7A3703DE26A40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (238, 'water_temperature', 'dd37cf6365af53fb2ae86daa91fc58de4e81a7397d61557854640b99628b91a7', 119, 2, 'Water temperature sensor data from ARSO', '01010000A0E6100000B988EFC4AC772E40A4198BA6B31347400AD7A3703DE26A40', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (239, 'water_level', '673005a947311f2a7f369b5cd3682e5a6170c5d5663d85491c117457041d8b92', 120, 1, 'Water level sensor data from ARSO', '01010000A0E61000005114E81379622E408FC70C54C60B4740295C8FC2F5B06740', '2026-02-25 13:09:56.509858+00', 'active', NULL);
INSERT INTO public.sensor VALUES (240, 'water_temperature', '06dde1461d003f73b3db3e5da8becf201ec6e34f6cf2705596850ee86009dde3', 120, 2, 'Water temperature sensor data from ARSO', '01010000A0E61000005114E81379622E408FC70C54C60B4740295C8FC2F5B06740', '2026-02-25 13:09:56.509858+00', 'active', NULL);


--
-- Data for Name: sensor_measurement; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: sensor_node; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sensor_node VALUES (1, 'ARSO_Hydro_Station', '959da3201390e1ae92eb24c2294d64c0318c4055f7c446c0233f58b0f71f196c', '01010000A0E6100000E86A2BF697FD2F40105D50DF3257474033333333334B6940', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (2, 'ARSO_Hydro_Station', 'e2defbddefde444a230393020346ca7167b9436cfc104c9b704910ab8f73a97d', '01010000A0E61000003D49BA66F20D3040D7868A71FE524740CDCCCCCCCC346840', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (3, 'ARSO_Hydro_Station', 'd5caf8bef871004918f7cefc77d8e7faa4802af67f8502041a81216c598bfda4', '01010000A0E61000005ABBED4273053040F437A110015B47400000000000C06940', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (4, 'ARSO_Hydro_Station', 'eeda5e23d9816d1ad8022b19cf38b05fe675726e3a7e74d7e4d3faf70a8c580b', '01010000A0E6100000B398D87C5C3B304026DF6C7363424740A4703D0AD72B6540', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (5, 'ARSO_Hydro_Station', 'd3f2efba6a78bdc71f46152a5b5a9caa44e3a05e63bd5681dac10bb42aa645a5', '01010000A0E610000057957D570407304041BCAE5FB0674740AE47E17A14066D40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (6, 'ARSO_Hydro_Station', 'd33571979d51a92d5596df4aac8b21df8ebb21c367421d22d93c2508abf6fdf2', '01010000A0E6100000EC4CA1F31A233040C286A757CA564740EC51B81E85EB6740', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (7, 'ARSO_Hydro_Station', 'f9eefe34ca90aa68d20b01b0efd6aa624811230c0a6d90b3afd0dcc64cd77a74', '01010000A0E6100000C347C494487A30403FC6DCB58444474052B81E85EB496340', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (8, 'ARSO_Hydro_Station', 'ab466e165b817e4191cd546a7dd783ec375f7eea17b3379a61c1fbda00542f8d', '01010000A0E61000003A7AFCDEA62F30409626A5A0DB574740E17A14AE47D16740', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (9, 'ARSO_Hydro_Station', '617e03e6a9b524e85d637004d1315b0e29bd5096a58f67dc1bb7d4e562392a49', '01010000A0E6100000693524EEB164304072F90FE9B7574740B81E85EB51E06640', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (10, 'ARSO_Hydro_Station', '9717f2191f5d61500307cf5eece902a186dfac06ac276963da5192fc0a550cf6', '01010000A0E6100000D5CA845FEA4F3040349D9D0C8E624740D7A3703D0AAF6C40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (11, 'ARSO_Hydro_Station', 'b7682f9bfb33e2a63c2c93a7cd5afc3b32ff0977c50cb80593288df7b383865f', '01010000A0E61000006891ED7C3F55304031B1F9B83668474048E17A14AE0F6C40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (12, 'ARSO_Hydro_Station', 'b0d1b28832816eeb03af3599e15e9de6fc8a59e441e2026ffb52ed758565e476', '01010000A0E61000009D11A5BDC1F72D4014CB2DAD864C4740E17A14AE47D97440', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (13, 'ARSO_Hydro_Station', 'b60c0b77e5819327c84320c08214c7a633add8df95164fdca2ee112f44b401ad', '01010000A0E6100000079964E42CBC2F40C503CAA65C354740CDCCCCCCCCD46A40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (14, 'ARSO_Hydro_Station', 'f51228a81dde679e00d44b2a1a9b28e4f85e09c131d3721a05b39f8d86628ee7', '01010000A0E610000020D26F5F07FE2F4008E6E8F17B2F474085EB51B81E2D6940', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (15, 'ARSO_Hydro_Station', 'd2822ea78f257833ebadb3367e6bb8cbfcc867e91b81e19b816455d8bccfa111', '01010000A0E61000000CCD751A69093040D95A5F24B4314740EC51B81E85BB6840', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (16, 'ARSO_Hydro_Station', 'f4a925656a29d29ca3db537e6a890e63b7a70ee3f5c61cf8c152764adca70ef1', '01010000A0E61000006E8B321B64B22D40EA043411363C47409A99999999EB8140', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (17, 'ARSO_Hydro_Station', 'f14f04767e514ee4abd499259203de497b66920519867c6c9d9cb5d7e4dc56f6', '01010000A0E610000077F86BB2460D2E40A7CB6262F34947400000000000E07440', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (18, 'ARSO_Hydro_Station', '38397b19fdc75579773c2050fa211625e67d25cd735eff7aecbc8750749b8dcb', '01010000A0E6100000EC51B81E854B2E40AD2F12DA723A47403D0AD7A370B97F40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (19, 'ARSO_Hydro_Station', '609adaab43ae960341c11f54d817c2fd07976e63dfc3a3cb1cda0558d20e6caa', '01010000A0E6100000A5A0DB4B1A132E40713D0AD7A348474000000000007C7540', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (20, 'ARSO_Hydro_Station', '10a221b7009d405928fa7c374dc1ee4a57ff2ba9c95f31aa08a67f1a3be515ce', '01010000A0E610000085EB51B81E252E40D4601A868F404740F6285C8FC24D7940', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (21, 'ARSO_Hydro_Station', 'aac6c4269102902abe89c4d40ffb80a2395044e3ecf0299f683bc253d868144b', '01010000A0E610000087BF266BD4532E40D1CB28965B4E4740273108AC1C5C7440', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (22, 'ARSO_Hydro_Station', '95e12d3246421e7a2ede2ffa7d01c0cc3b0d034b9c848a6028324abf2148236e', '01010000A0E6100000624A24D1CBD82E40738577B9884747400000000000807240', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (23, 'ARSO_Hydro_Station', '528f0dc8fc8daf26d61eae5254e4fc350de918a7fcc99f85d2d06e3c63af46b9', '01010000A0E61000004E7FF62345C42E405BB1BFEC9E30474085EB51B81E517940', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (24, 'ARSO_Hydro_Station', 'fe59b22184af5e793dd9125b40cdcb2e005dcbee8a2b59d7b241cd84ca4d0109', '01010000A0E610000078B988EFC4FC2E40ED0DBE30992647401F85EB51B8B67040', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (25, 'ARSO_Hydro_Station', '260cf984b10f93a39a25efcbc1a1724f06a2356444e7a075dd3a3f374c421afe', '01010000A0E610000048DC63E943572F404DF8A57EDE2847405C8FC2F5280C6E40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (26, 'ARSO_Hydro_Station', '2eb2c1e272d675c23b7cd08eaa88faaa41a3c51b663a36d3affbb69e93a32367', '01010000A0E610000058E2016553CE2F405E11FC6F252F474048E17A14AE276A40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (27, 'ARSO_Hydro_Station', '8dc0fde3d0bbe6e117c06a0c56ae31282db2ce44b125bece96b719de5d9a59c6', '01010000A0E6100000618E1EBFB7F92E40569A94826E2B4740AE47E17A14B27140', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (28, 'ARSO_Hydro_Station', 'd4475d80bcabe4e4568f150e2fe22f7168377468c857dd77104453e4045499af', '01010000A0E610000077BE9F1A2F4D2F40176536C8242B4740A4703D0AD73B6E40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (29, 'ARSO_Hydro_Station', '09d3d4247c6fb15a32a0c859196ff1efa862ce12c0721d77a33a272f392f5229', '01010000A0E610000052448655BCC12F40EDF0D7648D2A474048E17A14AEE76B40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (30, 'ARSO_Hydro_Station', '1c3f1e12ec48a1b1973d7cc22adf33799ade1e9adffdcf353542c03c93d4af9a', '01010000A0E6100000361FD7868AC12F40A64412BD8C2E47400AD7A3703DC26A40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (31, 'ARSO_Hydro_Station', '79d349d953f89edfcd2cc2bbf4cfeffcec65249cb4aabd58a42018ad60001c35', '01010000A0E6100000064CE0D6DD5C2F40467C2766BD4C4740713D0AD7A3486F40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (32, 'ARSO_Hydro_Station', '5c0386b78055375eaa8bf67a8212aa7a4063aeed28e73db30362aaf47863546e', '01010000A0E61000005B087250C2BC2F406CB2463D444747401F85EB51B82E6C40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (33, 'ARSO_Hydro_Station', '2107583b4b03f71e0484246a726f974d8f7708425d2ee216103b0c238f7c2360', '01010000A0E6100000465F419AB108304070253B360235474033333333333B6940', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (34, 'ARSO_Hydro_Station', 'b0849b05eb5e6c712afe738f722ab7b04728063e8c8946cdb312924da188b072', '01010000A0E6100000A73FFB9122922B40FB743C66A03E4740CDCCCCCCCCD08840', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (35, 'ARSO_Hydro_Station', 'e42087693079e81561d54c414a9319805631242d53a490df3db184af7c1b357d', '01010000A0E610000024624A24D11B2C404FAF94658837474014AE47E17AA68140', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (36, 'ARSO_Hydro_Station', 'dd9b8f0cc7fef62cb6301a199e9eb3bc2e3bcc0fb16d937a8f6401c0f97456dd', '01010000A0E6100000F71E2E39EE442C4089D2DEE00B2F4740CDCCCCCCCCC07A40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (37, 'ARSO_Hydro_Station', '894ef32f210683c7bc6fb4b6a2bea3889133e53e2522d5ca6dc832aad3f632d4', '01010000A0E6100000B4E55C8AABFA2B40A7E8482EFF3947401F85EB51B8308340', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (38, 'ARSO_Hydro_Station', '5dc652a4dda1ff4615071078c950bfde1a1bee4b2c873a8f5b7848230ab7f3e4', '01010000A0E6100000FC00A43671622C404D672783A3344740D7A3703D0ABF8B40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (39, 'ARSO_Hydro_Station', '5d1639e20ace292803a4ccdf92087c1fa900151f49e4c34b3ba565920fea7590', '01010000A0E6100000799274CDE42B2C40EE7C3F355E3247409A99999999B18140', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (40, 'ARSO_Hydro_Station', '1eb556f653f2cb6dbc614e156da838f4057962766c7260ce997ffbb169b45c4a', '01010000A0E6100000A089B0E1E9C52B40DD41EC4CA1234740B81E85EB51688040', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (41, 'ARSO_Hydro_Station', '1f7f50c8edbeaaf2c2e231aa67c0d36507a914144117b42c947b535f436b5fad', '01010000A0E610000062F3716DA8482C404F401361C32B47400000000000E07940', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (42, 'ARSO_Hydro_Station', '868458eda6e8f015c53e92e525de6fd026dd89cf78ce34698fb8f625290e69f2', '01010000A0E610000029CB10C7BAA82B401D9430D3F62347403D0AD7A3707B8040', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (43, 'ARSO_Hydro_Station', '57ce2f7cf59101388818aa7e62f1a695900803288024572393478251126c4959', '01010000A0E610000042959A3DD0BA2B40CF143AAFB12347400000000000708040', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (44, 'ARSO_Hydro_Station', '664580c3c4c48bc074dac7b4aca027eb6e2aeb67b7cc9c18cf2b8cc438ef8e3f', '01010000A0E61000002C4833164DC72B40F12900C6332447409A99999999798040', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (45, 'ARSO_Hydro_Station', '14c96d423ed3a97b42995b48fd9f7b99a613ed9a2e794d97ac6388f7aeae9891', '01010000A0E61000002D211FF46CE62B409E4143FF042347403333333333877F40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (46, 'ARSO_Hydro_Station', '553c86e9732f25a839c52afac41befde7098e117187d6430a7757baf5f730ba3', '01010000A0E6100000179AEB34D2322C408B71FE26142E474014AE47E17AB87D40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (47, 'ARSO_Hydro_Station', 'ffc211339393e38419b7c47878efa1632ed8c17c004a20be2632ffdf180726f9', '01010000A0E6100000A5BDC11726332C4099D36531B12D47403D0AD7A370417D40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (48, 'ARSO_Hydro_Station', '81679db354eb2827a35300b6433a75c0b3998c4aad4a5bc370b7cd7d34a12b7b', '01010000A0E610000017821C9430332C40D235936FB62D474085EB51B81E397D40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (49, 'ARSO_Hydro_Station', '3bae63f024640b6b4f6d8ad73dbd745adf1d109a9a01c8ff80f7f0843f2ed6c3', '01010000A0E610000086C954C1A8542C40F37684D3822B47407B14AE47E1827940', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (50, 'ARSO_Hydro_Station', '564c48fdf2b72082f116d55eec2faa67b218dc61ef1358d8c743023dda6ef6d2', '01010000A0E61000006B9A779CA2A32C40A9D903ADC020474033333333333F7640', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (51, 'ARSO_Hydro_Station', 'da5ae6153bc4eb332a8af811ef1bb45a1448b97b065fddb3fc538b801d9ea38d', '01010000A0E6100000FDBCA94885E12C408F8D40BCAE0F4740713D0AD7A3C47240', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (52, 'ARSO_Hydro_Station', '960f1099463cf21e7f6c008cbb571109c0f9db0d9c2552585f9fd65a9b703c30', '01010000A0E6100000982F2FC03E2A2D4009168733BF0A4740C3F5285C8FC27040', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (53, 'ARSO_Hydro_Station', '5f1ebd7811d3f01425ac9e0b2784a02ee96a19e1f18ea119e8dd91a0277041b6', '01010000A0E6100000D5CF9B8A54A82D40658D7A884607474085EB51B81ED56C40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (54, 'ARSO_Hydro_Station', 'c85d397de3bab93c1c6d4e6a97fc17c90af8040faa9fd3b7bda738798415ee07', '01010000A0E6100000AE122C0E672E2E40B3295778970F4740AE47E17A143E6840', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (55, 'ARSO_Hydro_Station', 'b9037274f20e968c488366412df9dc23121761f56078e74f8db2659a75217b27', '01010000A0E6100000475A2A6F47382F40CA89761552F246400AD7A3703D2A6140', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (56, 'ARSO_Hydro_Station', 'b7899a4980e75578bad65c4b79b3ceb794c4064badf0ae60c8bcca0c866e521d', '01010000A0E61000006DFFCA4A93622F40FC3559A31EEE46408FC2F5285C2F6040', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (57, 'ARSO_Hydro_Station', '86f5a6675796ae20b6d5eeb4aed4fb731ab2ac94124898be145f2d5187953161', '01010000A0E610000031B1F9B836842C4070EB6E9EEA2447401F85EB51B8727740', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (58, 'ARSO_Hydro_Station', '2998239a8798d8a952cf11d1028ce3fc14f031944f5183b9506d377d8dfeaf78', '01010000A0E61000009A25016A6A992C402041F163CC2D47405C8FC2F5288C7E40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (59, 'ARSO_Hydro_Station', 'c965503c280dc55d5a5122af0eee832aef5f4c941a2a0a2956cee95c163fac64', '01010000A0E610000098C0ADBB798A2C40C5FEB27BF2344740AE47E17A14448740', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (60, 'ARSO_Hydro_Station', 'afe3a467ed725e06b3f9f42709139e78006aa3eea4ed7dcae70be75b2f069f10', '01010000A0E610000001A4367172FF2C40091B9E5E292747400000000000588040', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (61, 'ARSO_Hydro_Station', 'd4097154b03ee097dea43f4ff4f7ff81841958fcacedabe06ae7f666583932f5', '01010000A0E61000000EA14ACD1EB82C406C5B94D9201F47400000000000507640', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (62, 'ARSO_Hydro_Station', 'dbc1b9007db5777a8ac1ff6c2d21122dc81714b552bc6d4de8ab1ec64a571c8f', '01010000A0E6100000D769A4A5F2A62C4069520ABABD144740EC51B81E85977440', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (63, 'ARSO_Hydro_Station', '0a56534e91de31a07d94ea1b79e2300cf804d627fc3aef8188a453f3d4647c9d', '01010000A0E61000004FE960FD9FD32C40C425C79DD2114740D7A3703D0A2B7340', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (64, 'ARSO_Hydro_Station', '81f709724f812285eaade4b9f6f4a1a0cb7326516f3bcbad6d4f27768cb2c0fa', '01010000A0E61000009F76F86BB2362C401A8BA6B393054740B81E85EB51AC7D40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (65, 'ARSO_Hydro_Station', '2f3a35d3f301532bbf68739253d9df38d19fc30a21f04c8e034e23fefebe6947', '01010000A0E6100000BFF1B56796942C406B7D91D096134740E17A14AE47757540', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (66, 'ARSO_Hydro_Station', '3cf54375cd9956adfeeb1775aa7a1600baff8e906fe07cdfbae1e5db573a8fab', '01010000A0E6100000A60F5D50DF522C40062AE3DF671C474052B81E85EBE57B40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (67, 'ARSO_Hydro_Station', 'bb42039e4bac9fd5aebba0b8f088b1a322b8eb0ad9261512b006e03f5b19425e', '01010000A0E6100000C4995FCD01922C4019ADA3AA091647405C8FC2F528647640', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (68, 'ARSO_Hydro_Station', '1eae81b1d5fb38236147175732c51b6a072c2e6000c6bdcbbca269e408a7fb3d', '01010000A0E6100000AE81AD122C2E2D40923F1878EE2947409A99999999678240', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (69, 'ARSO_Hydro_Station', 'a30dfbcf81b1478891865ead3a53e156ada429f0d6b54f82eb6896e2a1e10d2a', '01010000A0E610000027BD6F7CED392D40787FBC57AD1C474066666666662A7740', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (70, 'ARSO_Hydro_Station', 'd5cbe172fc206e6889405e7148db0e2e6cf412537f8667d01e46daf7d35ac952', '01010000A0E6100000F6402B3064352D40FB22A12DE71247400000000000D47240', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (71, 'ARSO_Hydro_Station', '3dc4a7b02dbeecf6c2c54aece9272106d94e0057424b211d8b06d4a36c266832', '01010000A0E6100000B37BF2B0503B2D40AF5A99F04B0D47406666666666267140', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (72, 'ARSO_Hydro_Station', '4353444b11d86801426b587bd08b51268a58ff98600083f1baf04eb6debd1e52', '01010000A0E6100000390B7BDAE13F2D40F645425BCE1D47406666666666BE7740', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (73, 'ARSO_Hydro_Station', 'e78b32d1c78ffb4f21a5722e3f13a9c6c38ade3a4257c1a06464c25a4f2a1567', '01010000A0E61000007901F6D1A93B2D40E674594C6C1247401F85EB51B8B27240', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (74, 'ARSO_Hydro_Station', 'fb66aaad6663c0c049f399a91ff93135f30900750f973af1b94e286a60a0f5d9', '01010000A0E61000006440F67AF7372D40CA32C4B12E124740A4703D0AD7977240', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (75, 'ARSO_Hydro_Station', 'ce4242f7deac71b957a6cab703fe2d2d2b746a8f41f3f0c6a27a6902b693f288', '01010000A0E6100000397F130A11202D40C32ADEC83C164740B81E85EB51047440', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (76, 'ARSO_Hydro_Station', '8cafc692b3f09180086c7775cc10b50a6d404537543d6846f9c220e6586bf40c', '01010000A0E6100000C9E53FA4DF1E2D40A6D0798D5D1247407B14AE47E1D67240', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (77, 'ARSO_Hydro_Station', 'dfe36a791474f1fa1ccbfe5eb5048b68be877ffef76a2ef140058137b5617061', '01010000A0E6100000035B25581CFE2D40D5CF9B8A54104740D7A3703D0A076D40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (78, 'ARSO_Hydro_Station', '18606b61b58c676c6f738540eda952bfa3170e9493a80462c979e26cdca37d2e', '01010000A0E6100000A245B6F3FD442E4015A930B610084740713D0AD7A3087040', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (79, 'ARSO_Hydro_Station', '1f2e053cd0f209ff7ebdaeeaf736e48cd74c4d607bbabe4c5a661c8d0257daa0', '01010000A0E61000004A9869FB57462E40E6965643E2FA464052B81E85EB916C40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (80, 'ARSO_Hydro_Station', 'e294e07b6dbcbda9d1585e9f387e743a9e47ba7c62adc8d68c8d7f74ab778a6e', '01010000A0E610000012F758FAD0752E40B48EAA2688FE46407B14AE47E1126A40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (81, 'ARSO_Hydro_Station', '1b6de0b377247afde5419a602d5480e8450205e26a93f94781a2b1e39cddebed', '01010000A0E61000002AE3DF675C982E402C4833164D03474085EB51B81EFD6840', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (82, 'ARSO_Hydro_Station', '13db7998c159ffabac2f1729c76266751c6cf998f3a7902eb049d21500d03fc0', '01010000A0E6100000BC0512143F662F406ADE718A8E1C474014AE47E17A5C6B40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (83, 'ARSO_Hydro_Station', 'ee848457a13e22b76aefe76962126ae7da793e9565ac2018403974c7f4545e18', '01010000A0E61000000DC347C494682F409947FE60E0F54640713D0AD7A3806140', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (84, 'ARSO_Hydro_Station', 'dd5ddb1e6256b8c53aaff2e20636c6a7ca296c00819324e184230a24ed270ff7', '01010000A0E61000006B2BF697DD332F40F5108DEE2016474052B81E85EB116840', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (85, 'ARSO_Hydro_Station', '74309435c9f9a99956e92024db8da2345c6163994a4d519858c4adb13c4e87fe', '01010000A0E61000003D44A33B884D2F4060B01BB62D064740295C8FC2F5C86740', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (86, 'ARSO_Hydro_Station', '432fe07612bb1b6a426d92a6a3bd21d33be7525aba030dd3eabcd69216f6ba29', '01010000A0E61000004E0B5EF415B42D40A54E401361BB4640AE47E17A14666B40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (87, 'ARSO_Hydro_Station', '8954124360b31992597cea7a39591c34b707f5bddfaf94a78469e8eee6e6c67f', '01010000A0E6100000D8BB3FDEAB262E40832F4CA60ABE4640AE47E17A149E6640', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (88, 'ARSO_Hydro_Station', 'c19bff686fa1269bbeb194c24226adfa4b133f536a148958099cf63499ae93a9', '01010000A0E6100000A12DE7525CA52E4021E527D53ED14640713D0AD7A3C05F40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (89, 'ARSO_Hydro_Station', '587f8be4fc11d03bfdaa874edc78c7c79ac46a3f08c594ac891fe6e9044e57e5', '01010000A0E610000065C22FF5F3C62D408CDB68006FCD464048E17A14AE5B7C40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (90, 'ARSO_Hydro_Station', 'a412755bf6ce2f8a2fcd5f8cbf50e3b12b0d09abf36a594b1b65a7e6a0862b56', '01010000A0E61000003F00A94D9CEC2D407D0569C6A2C1464014AE47E17A746840', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (91, 'ARSO_Hydro_Station', '027c32c18572805bd5d97828bf2398b76a2f8864bd06aa2db027fec2b1d9b93c', '01010000A0E61000005AF5B9DA8A7D2E406DE2E47E87CE464014AE47E17AB46040', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (92, 'ARSO_Hydro_Station', '065c686a3c8a6af2422f89d477e894591728ef21a387cdd1973ef6c22516a356', '01010000A0E61000004F401361C3732E4054573ECBF3D04640A4703D0AD7CB6040', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (93, 'ARSO_Hydro_Station', 'ba82516346f3f849d7d3ed016f756a3ad3c277659b265855d66559ed77ce2bd6', '01010000A0E610000044C02154A9992C40B988EFC4ACFB46407B14AE47E1DE7140', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (94, 'ARSO_Hydro_Station', '6d46819e53d03bbdc06ef91e4f900cc30e6c4186b9eeb5ac52cc9084dd672afe', '01010000A0E61000008143A852B3B72C400820B58993FB4640713D0AD7A3D87140', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (95, 'ARSO_Hydro_Station', '985556634f4e7992e8f64b9e7919fac2086daf2ec320087fa3bd772915db0403', '01010000A0E61000002DEC6987BF162D40ACC5A7001807474085EB51B81E957140', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (96, 'ARSO_Hydro_Station', '4019e3234cee85a2b77579ee9e164cc5a88ae3a61f3a46218bf77d1a999396b3', '01010000A0E6100000042159C0049E2C40D13FC1C58AFA4640AE47E17A14E67140', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (97, 'ARSO_Hydro_Station', 'e1aa8cbedafc321ea9da5f95bcf9376c1fc6ffb65001dc28ec5735b701b49b88', '01010000A0E6100000AF42CA4FAAAD2C40F6B4C35F93F946405C8FC2F528EC7140', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (98, 'ARSO_Hydro_Station', '97cea3f210d62b14db0a0b9256751a17a61101ffd53deddf7778decff18bdca1', '01010000A0E6100000CC0BB08F4EBD2C40B77F65A549F546401F85EB51B8767240', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (99, 'ARSO_Hydro_Station', 'bbcd1e946014064d9c344da578678ded945d6fea1176fd51492393457995eaaf', '01010000A0E6100000D6C56D3480072D4032C9C859D8F746406666666666327440', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (100, 'ARSO_Hydro_Station', 'fe11e4a9d94c787d6b0594b26a2c8ee3396ab9bc673e47840e064497d1509b31', '01010000A0E610000019E25817B7112D405F984C158CFA46408FC2F5285CFB7140', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (101, 'ARSO_Hydro_Station', '72843846df0f268df8e0d374e73460842241f02eafa3ff0d80ec7c64082a8987', '01010000A0E610000014E8137992E42C40E8DEC325C705474000000000008C7240', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (102, 'ARSO_Hydro_Station', 'aa97e4e4691dc8a4cb7546ac76141330e55101c9a5222720e467494e9f531961', '01010000A0E610000038BEF6CC92B02C406440F67AF7074740C3F5285C8F527540', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (103, 'ARSO_Hydro_Station', '7433db75ce98c6a4a329f061f2406e29d9667ef380ee913de064bcf35074f104', '01010000A0E61000008EAF3DB324E02C4099F56228270647403333333333A77240', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (104, 'ARSO_Hydro_Station', '06cc45c87c29cec29508731cf99b14e1ad373c065b9740fa5e0741089bd5b38a', '01010000A0E6100000C2120F289B022D403CDA38622DDA46406ABC749318098240', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (105, 'ARSO_Hydro_Station', '9af131a2278bc8c0b66df6d5e3d895e3d6ca43309cef491d3578a13053de11d0', '01010000A0E6100000C824236761CF2C40E882FA9639DD464000000000001A8140', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (106, 'ARSO_Hydro_Station', '2af2058a776b122b4de17ba3ae1ff0e72e133fe27f356ad6896812acedb97e67', '01010000A0E61000009B20EA3E00B92C40F5B9DA8AFDE146409CC420B0720C8140', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (107, 'ARSO_Hydro_Station', '35bda395ad3ccb853eebfc4f3eaf7453ac48e3e62f38b319472a54ba7851730b', '01010000A0E610000026C79DD2C1BA2C4068791EDC9DE546408B6CE7FBA97C8140', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (108, 'ARSO_Hydro_Station', 'b620b1076623dd45a03762de25eebb42e89f76a6de6dbce92c059977120647d4', '01010000A0E6100000E466B8019F5F2C40A1A17F828BDD4640C3F5285C8F3E8040', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (109, 'ARSO_Hydro_Station', '260c1d640840649cd387a58ee20f9260aab72d63af0358d791b34602379c5d89', '01010000A0E61000000E677E3507682C40B9AAECBB22E446403D0AD7A370F17F40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (110, 'ARSO_Hydro_Station', '99ae0edc7190d7cb286fe4a9dc93639d51ac8d915f27ec09be8b2e14cc41bfd8', '01010000A0E6100000B1169F02605C2C4080B74082E2E346408FC2F5285C218040', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (111, 'ARSO_Hydro_Station', '86bb897449a95c56843fb0646d45b191c2e669f3d7d580d785d97c6bae4d5027', '01010000A0E6100000D7A3703D0A872C40271422E010EA46400000000000D07B40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (112, 'ARSO_Hydro_Station', '0b63fadf0af290c36f2b41378a040fc9b94e1ac51395829fedd6c0ac89f09772', '01010000A0E6100000A661F88898822C4068CBB91457E94640EC51B81E85CF7B40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (113, 'ARSO_Hydro_Station', '601290d21bcdfa406b2b0d9988d60e14f80ba8231b7f69a7839fce26bd8b5636', '01010000A0E61000007FFB3A70CE682C407120240B98F446403D0AD7A370157E40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (114, 'ARSO_Hydro_Station', '8c699a262643b3cd1c6b47eed2ba13fa710e9cde6f5f7fca8ecd607e725b8c5a', '01010000A0E6100000DE718A8EE4622D408B89CDC7B53547406666666666E08340', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (115, 'ARSO_Hydro_Station', '3002dd289a582f0869571bbb0779e782bc1a3b1664436aa339e83daf66daa710', '01010000A0E61000000EF3E505D8E72D4045813E912729474014AE47E17A107540', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (116, 'ARSO_Hydro_Station', 'd38465e7bccfa2a20bb0a51c2fc4afa7bd1595bb45644a8404b75c89f922906a', '01010000A0E610000051A04FE449022E407D5C1B2AC629474052B81E85EB997340', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (117, 'ARSO_Hydro_Station', '17a68d6449ff219ba049d7820f5b3aed2f63277c0a1204dd50a0d786d901ef53', '01010000A0E61000001BD82AC1E2702E4059C0046EDD1D4740CDCCCCCCCCC46D40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (118, 'ARSO_Hydro_Station', 'f80567f1133f90bda2e6956fcb0b66b4297a3f67ca92e61969a1a0b55f4089a2', '01010000A0E61000002FC03E3A75852E40707CED99251D4740713D0AD7A3C86C40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (119, 'ARSO_Hydro_Station', 'bb81801c48a9c25c7b98bbd15746cc1082bcb55478b3ecaff9da9caddde1c9d5', '01010000A0E6100000B988EFC4AC772E40A4198BA6B31347400AD7A3703DE26A40', '2026-02-25 13:09:56.509858+00', 'active', '');
INSERT INTO public.sensor_node VALUES (120, 'ARSO_Hydro_Station', '0264cf5f7a1a0fdbab5bc7007074bcc605c114c89785a7a880df270f2c69e6a1', '01010000A0E61000005114E81379622E408FC70C54C60B4740295C8FC2F5B06740', '2026-02-25 13:09:56.509858+00', 'active', '');


--
-- Data for Name: sensor_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sensor_type VALUES (1, 'water_level', 'Water Level', 'm', 0, 1000, NULL);
INSERT INTO public.sensor_type VALUES (2, 'water_temperature', 'Water Temperature', '┬░C', 0, 100, NULL);


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Name: chunk_constraint_name; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.chunk_constraint_name', 2, true);


--
-- Name: chunk_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.chunk_id_seq', 1, true);


--
-- Name: continuous_agg_migrate_plan_step_step_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.continuous_agg_migrate_plan_step_step_id_seq', 1, false);


--
-- Name: dimension_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.dimension_id_seq', 1, true);


--
-- Name: dimension_slice_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.dimension_slice_id_seq', 1, true);


--
-- Name: hypertable_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.hypertable_id_seq', 1, true);


--
-- Name: bgw_job_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_config; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_config.bgw_job_id_seq', 1000, false);


--
-- Name: model_model_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.model_model_id_seq', 1, false);


--
-- Name: sensor_node_node_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sensor_node_node_id_seq', 120, true);


--
-- Name: sensor_sensor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sensor_sensor_id_seq', 240, true);


--
-- Name: sensor_type_sensor_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sensor_type_sensor_type_id_seq', 240, true);


--
-- Name: model model_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.model
    ADD CONSTRAINT model_name_key UNIQUE (name);


--
-- Name: model model_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.model
    ADD CONSTRAINT model_pkey PRIMARY KEY (model_id);


--
-- Name: model_sensor model_sensor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.model_sensor
    ADD CONSTRAINT model_sensor_pkey PRIMARY KEY (model_id, sensor_id);


--
-- Name: sensor sensor_node_id_sensor_label_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensor
    ADD CONSTRAINT sensor_node_id_sensor_label_key UNIQUE (node_id, sensor_label);


--
-- Name: sensor_node sensor_node_node_hash_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensor_node
    ADD CONSTRAINT sensor_node_node_hash_key UNIQUE (node_hash);


--
-- Name: sensor_node sensor_node_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensor_node
    ADD CONSTRAINT sensor_node_pkey PRIMARY KEY (node_id);


--
-- Name: sensor sensor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensor
    ADD CONSTRAINT sensor_pkey PRIMARY KEY (sensor_id);


--
-- Name: sensor sensor_sensor_hash_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensor
    ADD CONSTRAINT sensor_sensor_hash_key UNIQUE (sensor_hash);


--
-- Name: sensor_type sensor_type_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensor_type
    ADD CONSTRAINT sensor_type_name_key UNIQUE (name);


--
-- Name: sensor_type sensor_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensor_type
    ADD CONSTRAINT sensor_type_pkey PRIMARY KEY (sensor_type_id);


--
-- Name: _hyper_1_1_chunk_sensor_measurement_timestamp_utc_idx; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _hyper_1_1_chunk_sensor_measurement_timestamp_utc_idx ON _timescaledb_internal._hyper_1_1_chunk USING btree (timestamp_utc DESC);


--
-- Name: _hyper_1_1_chunk_sensor_measurement_timestamp_utc_idx_1; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _hyper_1_1_chunk_sensor_measurement_timestamp_utc_idx_1 ON _timescaledb_internal._hyper_1_1_chunk USING btree (timestamp_utc DESC);


--
-- Name: sensor_measurement_timestamp_utc_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sensor_measurement_timestamp_utc_idx ON public.sensor_measurement USING btree (timestamp_utc DESC);


--
-- Name: _hyper_1_1_chunk ts_insert_blocker; Type: TRIGGER; Schema: _timescaledb_internal; Owner: postgres
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON _timescaledb_internal._hyper_1_1_chunk FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: sensor_measurement ts_insert_blocker; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ts_insert_blocker BEFORE INSERT ON public.sensor_measurement FOR EACH ROW EXECUTE FUNCTION _timescaledb_internal.insert_blocker();


--
-- Name: model_sensor model_sensor_model_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.model_sensor
    ADD CONSTRAINT model_sensor_model_id_fkey FOREIGN KEY (model_id) REFERENCES public.model(model_id) ON DELETE CASCADE;


--
-- Name: model_sensor model_sensor_sensor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.model_sensor
    ADD CONSTRAINT model_sensor_sensor_id_fkey FOREIGN KEY (sensor_id) REFERENCES public.sensor(sensor_id) ON DELETE CASCADE;


--
-- Name: sensor sensor_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensor
    ADD CONSTRAINT sensor_node_id_fkey FOREIGN KEY (node_id) REFERENCES public.sensor_node(node_id) ON DELETE SET NULL;


--
-- Name: sensor sensor_sensor_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensor
    ADD CONSTRAINT sensor_sensor_type_id_fkey FOREIGN KEY (sensor_type_id) REFERENCES public.sensor_type(sensor_type_id);


--
-- PostgreSQL database dump complete
--

