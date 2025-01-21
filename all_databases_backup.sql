--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Drop databases (except postgres and template1)
--

DROP DATABASE airflow;
DROP DATABASE job_postings;




--
-- Drop roles
--

DROP ROLE airflow;
DROP ROLE job_postings;
DROP ROLE postgres;


--
-- Roles
--

CREATE ROLE airflow;
ALTER ROLE airflow WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:2Cm2N4NbHD6mh+33Mu4VDQ==$MUz/scmfL28k+5rMr1lG6THdyEMRegLZlkBvMxJ0ZpY=:w3dcFM8/+JM2dZnWKjThldwscDGUV+GGJzOgHU4i1Jc=';
CREATE ROLE job_postings;
ALTER ROLE job_postings WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:5U3OwfBPSDd8B8Lmp/RF5Q==$wdNHAiU+UA3H64MgyOGEPDGMdBdsgBBjWsiPtq6sAVg=:WDSSJLlaa8f4t1I7DpZa3mxtOAHwE13MPv62cDkjMZU=';
CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:/ujOg7aZV1GQq8Ji3BlIxQ==$b0UgIvssT0nxx45l9J389LMbdiXlUMCRFbaG/AtrGWo=:FZlc/VtaZtQEFF8A+Qg/4eWgV1nnzsy+zdHmZ8ywUc4=';

--
-- User Configurations
--








--
-- Databases
--

--
-- Database "template1" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 15.10 (Debian 15.10-1.pgdg120+1)
-- Dumped by pg_dump version 15.10 (Debian 15.10-1.pgdg120+1)

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

UPDATE pg_catalog.pg_database SET datistemplate = false WHERE datname = 'template1';
DROP DATABASE template1;
--
-- Name: template1; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE template1 OWNER TO postgres;

\connect template1

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
-- Name: DATABASE template1; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE template1 IS 'default template for new databases';


--
-- Name: template1; Type: DATABASE PROPERTIES; Schema: -; Owner: postgres
--

ALTER DATABASE template1 IS_TEMPLATE = true;


\connect template1

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
-- Name: DATABASE template1; Type: ACL; Schema: -; Owner: postgres
--

REVOKE CONNECT,TEMPORARY ON DATABASE template1 FROM PUBLIC;
GRANT CONNECT ON DATABASE template1 TO PUBLIC;


--
-- PostgreSQL database dump complete
--

--
-- Database "airflow" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 15.10 (Debian 15.10-1.pgdg120+1)
-- Dumped by pg_dump version 15.10 (Debian 15.10-1.pgdg120+1)

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
-- Name: airflow; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE airflow WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE airflow OWNER TO postgres;

\connect airflow

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ab_permission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_permission (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.ab_permission OWNER TO postgres;

--
-- Name: ab_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ab_permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_permission_id_seq OWNER TO postgres;

--
-- Name: ab_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ab_permission_id_seq OWNED BY public.ab_permission.id;


--
-- Name: ab_permission_view; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_permission_view (
    id integer NOT NULL,
    permission_id integer,
    view_menu_id integer
);


ALTER TABLE public.ab_permission_view OWNER TO postgres;

--
-- Name: ab_permission_view_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ab_permission_view_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_permission_view_id_seq OWNER TO postgres;

--
-- Name: ab_permission_view_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ab_permission_view_id_seq OWNED BY public.ab_permission_view.id;


--
-- Name: ab_permission_view_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_permission_view_role (
    id integer NOT NULL,
    permission_view_id integer,
    role_id integer
);


ALTER TABLE public.ab_permission_view_role OWNER TO postgres;

--
-- Name: ab_permission_view_role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ab_permission_view_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_permission_view_role_id_seq OWNER TO postgres;

--
-- Name: ab_permission_view_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ab_permission_view_role_id_seq OWNED BY public.ab_permission_view_role.id;


--
-- Name: ab_register_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_register_user (
    id integer NOT NULL,
    first_name character varying(256) NOT NULL,
    last_name character varying(256) NOT NULL,
    username character varying(512) NOT NULL,
    password character varying(256),
    email character varying(512) NOT NULL,
    registration_date timestamp without time zone,
    registration_hash character varying(256)
);


ALTER TABLE public.ab_register_user OWNER TO postgres;

--
-- Name: ab_register_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ab_register_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_register_user_id_seq OWNER TO postgres;

--
-- Name: ab_register_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ab_register_user_id_seq OWNED BY public.ab_register_user.id;


--
-- Name: ab_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_role (
    id integer NOT NULL,
    name character varying(64) NOT NULL
);


ALTER TABLE public.ab_role OWNER TO postgres;

--
-- Name: ab_role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ab_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_role_id_seq OWNER TO postgres;

--
-- Name: ab_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ab_role_id_seq OWNED BY public.ab_role.id;


--
-- Name: ab_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_user (
    id integer NOT NULL,
    first_name character varying(256) NOT NULL,
    last_name character varying(256) NOT NULL,
    username character varying(512) NOT NULL,
    password character varying(256),
    active boolean,
    email character varying(512) NOT NULL,
    last_login timestamp without time zone,
    login_count integer,
    fail_login_count integer,
    created_on timestamp without time zone,
    changed_on timestamp without time zone,
    created_by_fk integer,
    changed_by_fk integer
);


ALTER TABLE public.ab_user OWNER TO postgres;

--
-- Name: ab_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ab_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_user_id_seq OWNER TO postgres;

--
-- Name: ab_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ab_user_id_seq OWNED BY public.ab_user.id;


--
-- Name: ab_user_role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_user_role (
    id integer NOT NULL,
    user_id integer,
    role_id integer
);


ALTER TABLE public.ab_user_role OWNER TO postgres;

--
-- Name: ab_user_role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ab_user_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_user_role_id_seq OWNER TO postgres;

--
-- Name: ab_user_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ab_user_role_id_seq OWNED BY public.ab_user_role.id;


--
-- Name: ab_view_menu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ab_view_menu (
    id integer NOT NULL,
    name character varying(250) NOT NULL
);


ALTER TABLE public.ab_view_menu OWNER TO postgres;

--
-- Name: ab_view_menu_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ab_view_menu_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_view_menu_id_seq OWNER TO postgres;

--
-- Name: ab_view_menu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ab_view_menu_id_seq OWNED BY public.ab_view_menu.id;


--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO postgres;

--
-- Name: callback_request; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.callback_request (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    priority_weight integer NOT NULL,
    callback_data json NOT NULL,
    callback_type character varying(20) NOT NULL,
    processor_subdir character varying(2000)
);


ALTER TABLE public.callback_request OWNER TO postgres;

--
-- Name: callback_request_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.callback_request_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.callback_request_id_seq OWNER TO postgres;

--
-- Name: callback_request_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.callback_request_id_seq OWNED BY public.callback_request.id;


--
-- Name: connection; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.connection (
    id integer NOT NULL,
    conn_id character varying(250) NOT NULL,
    conn_type character varying(500) NOT NULL,
    description text,
    host character varying(500),
    schema character varying(500),
    login character varying(500),
    password character varying(5000),
    port integer,
    is_encrypted boolean,
    is_extra_encrypted boolean,
    extra text
);


ALTER TABLE public.connection OWNER TO postgres;

--
-- Name: connection_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.connection_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.connection_id_seq OWNER TO postgres;

--
-- Name: connection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.connection_id_seq OWNED BY public.connection.id;


--
-- Name: dag; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dag (
    dag_id character varying(250) NOT NULL,
    root_dag_id character varying(250),
    is_paused boolean,
    is_subdag boolean,
    is_active boolean,
    last_parsed_time timestamp with time zone,
    last_pickled timestamp with time zone,
    last_expired timestamp with time zone,
    scheduler_lock boolean,
    pickle_id integer,
    fileloc character varying(2000),
    processor_subdir character varying(2000),
    owners character varying(2000),
    description text,
    default_view character varying(25),
    schedule_interval text,
    timetable_description character varying(1000),
    max_active_tasks integer NOT NULL,
    max_active_runs integer,
    has_task_concurrency_limits boolean NOT NULL,
    has_import_errors boolean DEFAULT false,
    next_dagrun timestamp with time zone,
    next_dagrun_data_interval_start timestamp with time zone,
    next_dagrun_data_interval_end timestamp with time zone,
    next_dagrun_create_after timestamp with time zone
);


ALTER TABLE public.dag OWNER TO postgres;

--
-- Name: dag_code; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dag_code (
    fileloc_hash bigint NOT NULL,
    fileloc character varying(2000) NOT NULL,
    last_updated timestamp with time zone NOT NULL,
    source_code text NOT NULL
);


ALTER TABLE public.dag_code OWNER TO postgres;

--
-- Name: dag_owner_attributes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dag_owner_attributes (
    dag_id character varying(250) NOT NULL,
    owner character varying(500) NOT NULL,
    link character varying(500) NOT NULL
);


ALTER TABLE public.dag_owner_attributes OWNER TO postgres;

--
-- Name: dag_pickle; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dag_pickle (
    id integer NOT NULL,
    pickle bytea,
    created_dttm timestamp with time zone,
    pickle_hash bigint
);


ALTER TABLE public.dag_pickle OWNER TO postgres;

--
-- Name: dag_pickle_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dag_pickle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dag_pickle_id_seq OWNER TO postgres;

--
-- Name: dag_pickle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dag_pickle_id_seq OWNED BY public.dag_pickle.id;


--
-- Name: dag_run; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dag_run (
    id integer NOT NULL,
    dag_id character varying(250) NOT NULL,
    queued_at timestamp with time zone,
    execution_date timestamp with time zone NOT NULL,
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    state character varying(50),
    run_id character varying(250) NOT NULL,
    creating_job_id integer,
    external_trigger boolean,
    run_type character varying(50) NOT NULL,
    conf bytea,
    data_interval_start timestamp with time zone,
    data_interval_end timestamp with time zone,
    last_scheduling_decision timestamp with time zone,
    dag_hash character varying(32),
    log_template_id integer,
    updated_at timestamp with time zone
);


ALTER TABLE public.dag_run OWNER TO postgres;

--
-- Name: dag_run_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dag_run_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dag_run_id_seq OWNER TO postgres;

--
-- Name: dag_run_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dag_run_id_seq OWNED BY public.dag_run.id;


--
-- Name: dag_run_note; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dag_run_note (
    user_id integer,
    dag_run_id integer NOT NULL,
    content character varying(1000),
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.dag_run_note OWNER TO postgres;

--
-- Name: dag_schedule_dataset_reference; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dag_schedule_dataset_reference (
    dataset_id integer NOT NULL,
    dag_id character varying(250) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.dag_schedule_dataset_reference OWNER TO postgres;

--
-- Name: dag_tag; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dag_tag (
    name character varying(100) NOT NULL,
    dag_id character varying(250) NOT NULL
);


ALTER TABLE public.dag_tag OWNER TO postgres;

--
-- Name: dag_warning; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dag_warning (
    dag_id character varying(250) NOT NULL,
    warning_type character varying(50) NOT NULL,
    message text NOT NULL,
    "timestamp" timestamp with time zone NOT NULL
);


ALTER TABLE public.dag_warning OWNER TO postgres;

--
-- Name: dagrun_dataset_event; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dagrun_dataset_event (
    dag_run_id integer NOT NULL,
    event_id integer NOT NULL
);


ALTER TABLE public.dagrun_dataset_event OWNER TO postgres;

--
-- Name: dataset; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dataset (
    id integer NOT NULL,
    uri character varying(3000) NOT NULL,
    extra json NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    is_orphaned boolean DEFAULT false NOT NULL
);


ALTER TABLE public.dataset OWNER TO postgres;

--
-- Name: dataset_dag_run_queue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dataset_dag_run_queue (
    dataset_id integer NOT NULL,
    target_dag_id character varying(250) NOT NULL,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.dataset_dag_run_queue OWNER TO postgres;

--
-- Name: dataset_event; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dataset_event (
    id integer NOT NULL,
    dataset_id integer NOT NULL,
    extra json NOT NULL,
    source_task_id character varying(250),
    source_dag_id character varying(250),
    source_run_id character varying(250),
    source_map_index integer DEFAULT '-1'::integer,
    "timestamp" timestamp with time zone NOT NULL
);


ALTER TABLE public.dataset_event OWNER TO postgres;

--
-- Name: dataset_event_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dataset_event_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dataset_event_id_seq OWNER TO postgres;

--
-- Name: dataset_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dataset_event_id_seq OWNED BY public.dataset_event.id;


--
-- Name: dataset_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dataset_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dataset_id_seq OWNER TO postgres;

--
-- Name: dataset_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dataset_id_seq OWNED BY public.dataset.id;


--
-- Name: import_error; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.import_error (
    id integer NOT NULL,
    "timestamp" timestamp with time zone,
    filename character varying(1024),
    stacktrace text
);


ALTER TABLE public.import_error OWNER TO postgres;

--
-- Name: import_error_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.import_error_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.import_error_id_seq OWNER TO postgres;

--
-- Name: import_error_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.import_error_id_seq OWNED BY public.import_error.id;


--
-- Name: job; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job (
    id integer NOT NULL,
    dag_id character varying(250),
    state character varying(20),
    job_type character varying(30),
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    latest_heartbeat timestamp with time zone,
    executor_class character varying(500),
    hostname character varying(500),
    unixname character varying(1000)
);


ALTER TABLE public.job OWNER TO postgres;

--
-- Name: job_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_id_seq OWNER TO postgres;

--
-- Name: job_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_id_seq OWNED BY public.job.id;


--
-- Name: log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.log (
    id integer NOT NULL,
    dttm timestamp with time zone,
    dag_id character varying(250),
    task_id character varying(250),
    map_index integer,
    event character varying(30),
    execution_date timestamp with time zone,
    owner character varying(500),
    extra text
);


ALTER TABLE public.log OWNER TO postgres;

--
-- Name: log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.log_id_seq OWNER TO postgres;

--
-- Name: log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.log_id_seq OWNED BY public.log.id;


--
-- Name: log_template; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.log_template (
    id integer NOT NULL,
    filename text NOT NULL,
    elasticsearch_id text NOT NULL,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.log_template OWNER TO postgres;

--
-- Name: log_template_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.log_template_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.log_template_id_seq OWNER TO postgres;

--
-- Name: log_template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.log_template_id_seq OWNED BY public.log_template.id;


--
-- Name: rendered_task_instance_fields; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rendered_task_instance_fields (
    dag_id character varying(250) NOT NULL,
    task_id character varying(250) NOT NULL,
    run_id character varying(250) NOT NULL,
    map_index integer DEFAULT '-1'::integer NOT NULL,
    rendered_fields json NOT NULL,
    k8s_pod_yaml json
);


ALTER TABLE public.rendered_task_instance_fields OWNER TO postgres;

--
-- Name: serialized_dag; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.serialized_dag (
    dag_id character varying(250) NOT NULL,
    fileloc character varying(2000) NOT NULL,
    fileloc_hash bigint NOT NULL,
    data json,
    data_compressed bytea,
    last_updated timestamp with time zone NOT NULL,
    dag_hash character varying(32) NOT NULL,
    processor_subdir character varying(2000)
);


ALTER TABLE public.serialized_dag OWNER TO postgres;

--
-- Name: session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session (
    id integer NOT NULL,
    session_id character varying(255),
    data bytea,
    expiry timestamp without time zone
);


ALTER TABLE public.session OWNER TO postgres;

--
-- Name: session_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.session_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.session_id_seq OWNER TO postgres;

--
-- Name: session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.session_id_seq OWNED BY public.session.id;


--
-- Name: sla_miss; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sla_miss (
    task_id character varying(250) NOT NULL,
    dag_id character varying(250) NOT NULL,
    execution_date timestamp with time zone NOT NULL,
    email_sent boolean,
    "timestamp" timestamp with time zone,
    description text,
    notification_sent boolean
);


ALTER TABLE public.sla_miss OWNER TO postgres;

--
-- Name: slot_pool; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.slot_pool (
    id integer NOT NULL,
    pool character varying(256),
    slots integer,
    description text,
    include_deferred boolean NOT NULL
);


ALTER TABLE public.slot_pool OWNER TO postgres;

--
-- Name: slot_pool_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.slot_pool_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.slot_pool_id_seq OWNER TO postgres;

--
-- Name: slot_pool_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.slot_pool_id_seq OWNED BY public.slot_pool.id;


--
-- Name: task_fail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_fail (
    id integer NOT NULL,
    task_id character varying(250) NOT NULL,
    dag_id character varying(250) NOT NULL,
    run_id character varying(250) NOT NULL,
    map_index integer DEFAULT '-1'::integer NOT NULL,
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    duration integer
);


ALTER TABLE public.task_fail OWNER TO postgres;

--
-- Name: task_fail_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.task_fail_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.task_fail_id_seq OWNER TO postgres;

--
-- Name: task_fail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.task_fail_id_seq OWNED BY public.task_fail.id;


--
-- Name: task_instance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_instance (
    task_id character varying(250) NOT NULL,
    dag_id character varying(250) NOT NULL,
    run_id character varying(250) NOT NULL,
    map_index integer DEFAULT '-1'::integer NOT NULL,
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    duration double precision,
    state character varying(20),
    try_number integer,
    max_tries integer DEFAULT '-1'::integer,
    hostname character varying(1000),
    unixname character varying(1000),
    job_id integer,
    pool character varying(256) NOT NULL,
    pool_slots integer NOT NULL,
    queue character varying(256),
    priority_weight integer,
    operator character varying(1000),
    custom_operator_name character varying(1000),
    queued_dttm timestamp with time zone,
    queued_by_job_id integer,
    pid integer,
    executor_config bytea,
    updated_at timestamp with time zone,
    external_executor_id character varying(250),
    trigger_id integer,
    trigger_timeout timestamp without time zone,
    next_method character varying(1000),
    next_kwargs json
);


ALTER TABLE public.task_instance OWNER TO postgres;

--
-- Name: task_instance_note; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_instance_note (
    user_id integer,
    task_id character varying(250) NOT NULL,
    dag_id character varying(250) NOT NULL,
    run_id character varying(250) NOT NULL,
    map_index integer NOT NULL,
    content character varying(1000),
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.task_instance_note OWNER TO postgres;

--
-- Name: task_map; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_map (
    dag_id character varying(250) NOT NULL,
    task_id character varying(250) NOT NULL,
    run_id character varying(250) NOT NULL,
    map_index integer NOT NULL,
    length integer NOT NULL,
    keys json,
    CONSTRAINT ck_task_map_task_map_length_not_negative CHECK ((length >= 0))
);


ALTER TABLE public.task_map OWNER TO postgres;

--
-- Name: task_outlet_dataset_reference; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_outlet_dataset_reference (
    dataset_id integer NOT NULL,
    dag_id character varying(250) NOT NULL,
    task_id character varying(250) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.task_outlet_dataset_reference OWNER TO postgres;

--
-- Name: task_reschedule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_reschedule (
    id integer NOT NULL,
    task_id character varying(250) NOT NULL,
    dag_id character varying(250) NOT NULL,
    run_id character varying(250) NOT NULL,
    map_index integer DEFAULT '-1'::integer NOT NULL,
    try_number integer NOT NULL,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone NOT NULL,
    duration integer NOT NULL,
    reschedule_date timestamp with time zone NOT NULL
);


ALTER TABLE public.task_reschedule OWNER TO postgres;

--
-- Name: task_reschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.task_reschedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.task_reschedule_id_seq OWNER TO postgres;

--
-- Name: task_reschedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.task_reschedule_id_seq OWNED BY public.task_reschedule.id;


--
-- Name: trigger; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trigger (
    id integer NOT NULL,
    classpath character varying(1000) NOT NULL,
    kwargs json NOT NULL,
    created_date timestamp with time zone NOT NULL,
    triggerer_id integer
);


ALTER TABLE public.trigger OWNER TO postgres;

--
-- Name: trigger_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.trigger_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trigger_id_seq OWNER TO postgres;

--
-- Name: trigger_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.trigger_id_seq OWNED BY public.trigger.id;


--
-- Name: variable; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.variable (
    id integer NOT NULL,
    key character varying(250),
    val text,
    description text,
    is_encrypted boolean
);


ALTER TABLE public.variable OWNER TO postgres;

--
-- Name: variable_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.variable_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.variable_id_seq OWNER TO postgres;

--
-- Name: variable_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.variable_id_seq OWNED BY public.variable.id;


--
-- Name: xcom; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.xcom (
    dag_run_id integer NOT NULL,
    task_id character varying(250) NOT NULL,
    map_index integer DEFAULT '-1'::integer NOT NULL,
    key character varying(512) NOT NULL,
    dag_id character varying(250) NOT NULL,
    run_id character varying(250) NOT NULL,
    value bytea,
    "timestamp" timestamp with time zone NOT NULL
);


ALTER TABLE public.xcom OWNER TO postgres;

--
-- Name: ab_permission id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission ALTER COLUMN id SET DEFAULT nextval('public.ab_permission_id_seq'::regclass);


--
-- Name: ab_permission_view id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view ALTER COLUMN id SET DEFAULT nextval('public.ab_permission_view_id_seq'::regclass);


--
-- Name: ab_permission_view_role id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view_role ALTER COLUMN id SET DEFAULT nextval('public.ab_permission_view_role_id_seq'::regclass);


--
-- Name: ab_register_user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_register_user ALTER COLUMN id SET DEFAULT nextval('public.ab_register_user_id_seq'::regclass);


--
-- Name: ab_role id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_role ALTER COLUMN id SET DEFAULT nextval('public.ab_role_id_seq'::regclass);


--
-- Name: ab_user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user ALTER COLUMN id SET DEFAULT nextval('public.ab_user_id_seq'::regclass);


--
-- Name: ab_user_role id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user_role ALTER COLUMN id SET DEFAULT nextval('public.ab_user_role_id_seq'::regclass);


--
-- Name: ab_view_menu id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_view_menu ALTER COLUMN id SET DEFAULT nextval('public.ab_view_menu_id_seq'::regclass);


--
-- Name: callback_request id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.callback_request ALTER COLUMN id SET DEFAULT nextval('public.callback_request_id_seq'::regclass);


--
-- Name: connection id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.connection ALTER COLUMN id SET DEFAULT nextval('public.connection_id_seq'::regclass);


--
-- Name: dag_pickle id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dag_pickle ALTER COLUMN id SET DEFAULT nextval('public.dag_pickle_id_seq'::regclass);


--
-- Name: dag_run id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dag_run ALTER COLUMN id SET DEFAULT nextval('public.dag_run_id_seq'::regclass);


--
-- Name: dataset id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dataset ALTER COLUMN id SET DEFAULT nextval('public.dataset_id_seq'::regclass);


--
-- Name: dataset_event id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dataset_event ALTER COLUMN id SET DEFAULT nextval('public.dataset_event_id_seq'::regclass);


--
-- Name: import_error id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.import_error ALTER COLUMN id SET DEFAULT nextval('public.import_error_id_seq'::regclass);


--
-- Name: job id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job ALTER COLUMN id SET DEFAULT nextval('public.job_id_seq'::regclass);


--
-- Name: log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log ALTER COLUMN id SET DEFAULT nextval('public.log_id_seq'::regclass);


--
-- Name: log_template id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_template ALTER COLUMN id SET DEFAULT nextval('public.log_template_id_seq'::regclass);


--
-- Name: session id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session ALTER COLUMN id SET DEFAULT nextval('public.session_id_seq'::regclass);


--
-- Name: slot_pool id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slot_pool ALTER COLUMN id SET DEFAULT nextval('public.slot_pool_id_seq'::regclass);


--
-- Name: task_fail id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_fail ALTER COLUMN id SET DEFAULT nextval('public.task_fail_id_seq'::regclass);


--
-- Name: task_reschedule id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_reschedule ALTER COLUMN id SET DEFAULT nextval('public.task_reschedule_id_seq'::regclass);


--
-- Name: trigger id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trigger ALTER COLUMN id SET DEFAULT nextval('public.trigger_id_seq'::regclass);


--
-- Name: variable id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.variable ALTER COLUMN id SET DEFAULT nextval('public.variable_id_seq'::regclass);


--
-- Data for Name: ab_permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ab_permission (id, name) FROM stdin;
1	can_edit
2	can_read
3	can_create
4	can_delete
5	menu_access
6	muldelete
7	mulemailsent
8	mulemailsentfalse
9	mulnotificationsent
10	mulnotificationsentfalse
\.


--
-- Data for Name: ab_permission_view; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ab_permission_view (id, permission_id, view_menu_id) FROM stdin;
1	1	4
2	2	4
3	1	5
5	2	5
7	1	6
9	2	6
11	3	8
13	2	8
15	1	8
17	4	8
19	5	10
21	5	11
23	3	12
25	2	12
27	1	12
29	4	12
31	5	14
33	2	16
35	5	18
37	2	20
39	5	22
41	2	23
43	5	24
45	2	26
46	5	27
47	3	30
48	2	30
49	1	30
50	4	30
51	5	30
52	5	31
53	2	32
54	2	33
55	5	32
56	1	33
57	4	33
58	2	34
59	2	35
60	1	34
61	4	34
62	5	35
63	2	36
64	1	36
65	4	36
66	3	37
67	2	38
68	2	37
69	1	38
70	4	38
71	1	37
72	2	39
73	4	37
74	1	39
75	4	39
76	5	37
77	2	40
78	1	40
79	5	41
80	4	40
81	2	42
82	1	42
83	4	42
84	3	43
85	2	43
86	1	43
87	4	43
88	5	43
89	2	44
90	5	44
91	2	45
92	2	46
93	5	45
94	1	46
95	4	46
96	2	47
97	5	47
98	3	48
99	2	48
100	1	48
101	4	48
102	5	48
103	2	49
104	5	49
105	6	49
106	7	49
107	8	49
108	9	49
109	10	49
110	2	50
111	5	50
112	2	51
113	5	51
114	3	52
115	2	52
116	1	52
117	4	52
118	5	52
119	3	53
120	2	53
121	4	53
122	5	53
123	5	55
124	5	57
125	5	58
126	5	59
127	5	60
128	5	61
129	2	57
130	1	57
131	4	57
132	2	59
133	2	62
134	2	63
135	2	64
136	2	55
137	2	58
138	2	65
139	2	66
\.


--
-- Data for Name: ab_permission_view_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ab_permission_view_role (id, permission_view_id, role_id) FROM stdin;
1	1	1
2	2	1
3	3	1
4	5	1
5	7	1
6	9	1
7	11	1
8	13	1
9	15	1
10	17	1
11	19	1
12	21	1
13	23	1
14	25	1
15	27	1
16	29	1
17	31	1
18	33	1
19	35	1
20	37	1
21	39	1
22	41	1
23	45	1
24	46	1
25	43	1
27	47	1
28	48	1
29	49	1
30	50	1
31	51	1
32	52	1
33	53	1
34	55	1
35	59	1
36	62	1
37	66	1
38	68	1
39	71	1
40	73	1
41	76	1
42	79	1
43	84	1
44	85	1
45	86	1
46	87	1
47	88	1
48	89	1
49	90	1
50	91	1
51	93	1
52	96	1
53	97	1
54	98	1
55	99	1
56	100	1
57	101	1
58	102	1
59	103	1
60	104	1
61	105	1
62	106	1
63	107	1
64	108	1
65	109	1
66	110	1
67	111	1
68	112	1
69	113	1
70	114	1
71	115	1
72	116	1
73	117	1
74	118	1
75	119	1
76	120	1
77	121	1
78	122	1
79	123	1
80	124	1
81	125	1
82	126	1
83	127	1
84	128	1
85	59	3
86	129	3
87	136	3
88	134	3
89	48	3
90	132	3
91	137	3
92	133	3
93	135	3
94	53	3
95	5	3
96	3	3
97	9	3
98	7	3
99	110	3
100	103	3
101	85	3
102	138	3
103	120	3
104	139	3
105	52	3
106	124	3
107	123	3
108	51	3
109	126	3
110	125	3
111	127	3
112	128	3
113	55	3
114	62	3
115	111	3
116	104	3
117	88	3
118	59	4
119	129	4
120	136	4
121	134	4
122	48	4
123	132	4
124	137	4
125	133	4
126	135	4
127	53	4
128	5	4
129	3	4
130	9	4
131	7	4
132	110	4
133	103	4
134	85	4
135	138	4
136	120	4
137	139	4
138	52	4
139	124	4
140	123	4
141	51	4
142	126	4
143	125	4
144	127	4
145	128	4
146	55	4
147	62	4
148	111	4
149	104	4
150	88	4
151	130	4
152	131	4
153	84	4
154	86	4
155	87	4
156	47	4
157	49	4
158	50	4
159	59	5
160	129	5
161	136	5
162	134	5
163	48	5
164	132	5
165	137	5
166	133	5
167	135	5
168	53	5
169	5	5
170	3	5
171	9	5
172	7	5
173	110	5
174	103	5
175	85	5
176	138	5
177	120	5
178	139	5
179	52	5
180	124	5
181	123	5
182	51	5
183	126	5
184	125	5
185	127	5
186	128	5
187	55	5
188	62	5
189	111	5
190	104	5
191	88	5
192	130	5
193	131	5
194	84	5
195	86	5
196	87	5
197	47	5
198	49	5
199	50	5
200	96	5
201	79	5
202	97	5
203	102	5
204	118	5
205	76	5
206	122	5
207	98	5
208	99	5
209	100	5
210	101	5
211	114	5
212	115	5
213	116	5
214	117	5
215	112	5
216	66	5
217	68	5
218	71	5
219	73	5
220	121	5
221	129	1
222	136	1
223	134	1
224	132	1
225	137	1
226	133	1
227	135	1
228	138	1
229	139	1
230	130	1
231	131	1
\.


--
-- Data for Name: ab_register_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ab_register_user (id, first_name, last_name, username, password, email, registration_date, registration_hash) FROM stdin;
\.


--
-- Data for Name: ab_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ab_role (id, name) FROM stdin;
1	Admin
2	Public
3	Viewer
4	User
5	Op
\.


--
-- Data for Name: ab_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ab_user (id, first_name, last_name, username, password, active, email, last_login, login_count, fail_login_count, created_on, changed_on, created_by_fk, changed_by_fk) FROM stdin;
1	Admin	User	admin	pbkdf2:sha256:260000$wsXbLkxazppfUUVr$a68663e4ea8861610fe3210e9b9c6c79dc3d4512d3d7939fb13046d43c1800f4	t	admin@example.co	2025-01-15 06:22:02.90932	3	0	2025-01-15 05:17:32.607884	2025-01-15 05:17:32.607888	\N	\N
\.


--
-- Data for Name: ab_user_role; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ab_user_role (id, user_id, role_id) FROM stdin;
1	1	1
\.


--
-- Data for Name: ab_view_menu; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ab_view_menu (id, name) FROM stdin;
1	IndexView
2	UtilView
3	LocaleView
4	Passwords
5	My Password
6	My Profile
7	AuthDBView
8	Users
10	List Users
11	Security
12	Roles
14	List Roles
16	User Stats Chart
18	User's Statistics
20	Permissions
22	Actions
23	View Menus
24	Resources
26	Permission Views
27	Permission Pairs
28	AutocompleteView
29	Airflow
30	DAG Runs
31	Browse
32	Jobs
33	DAG:job_scraper
34	DAG:indeed_data_engineer_scraper
35	Audit Logs
36	DAG:indeed_python_developer_scraper
37	Variables
38	DAG:indeed_data_scientist_scraper
39	DAG:linkedin_data_engineer_scraper
40	DAG:linkedin_python_developer_scraper
41	Admin
42	DAG:linkedin_data_scientist_scraper
43	Task Instances
44	Task Reschedules
45	Triggers
46	DAG:processing_raw_job_dag
47	Configurations
48	Connections
49	SLA Misses
50	Plugins
51	Providers
52	Pools
53	XComs
54	DagDependenciesView
55	DAG Dependencies
56	RedocView
57	DAGs
58	Cluster Activity
59	Datasets
60	Documentation
61	Docs
62	ImportError
63	DAG Code
64	DAG Warnings
65	Task Logs
66	Website
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alembic_version (version_num) FROM stdin;
405de8318b3a
\.


--
-- Data for Name: callback_request; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.callback_request (id, created_at, priority_weight, callback_data, callback_type, processor_subdir) FROM stdin;
\.


--
-- Data for Name: connection; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.connection (id, conn_id, conn_type, description, host, schema, login, password, port, is_encrypted, is_extra_encrypted, extra) FROM stdin;
\.


--
-- Data for Name: dag; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dag (dag_id, root_dag_id, is_paused, is_subdag, is_active, last_parsed_time, last_pickled, last_expired, scheduler_lock, pickle_id, fileloc, processor_subdir, owners, description, default_view, schedule_interval, timetable_description, max_active_tasks, max_active_runs, has_task_concurrency_limits, has_import_errors, next_dagrun, next_dagrun_data_interval_start, next_dagrun_data_interval_end, next_dagrun_create_after) FROM stdin;
linkedin_python_developer_scraper	\N	t	f	f	2025-01-15 05:24:29.824606+00	\N	\N	\N	\N	/opt/airflow/dags/scraper_dag.py	/opt/airflow/dags	airflow	Scrape LinkedIn Python Developer jobs	grid	"0 9,21 * * *"	At 09:00 and 21:00	16	1	f	t	2025-01-14 15:00:00+00	2025-01-14 15:00:00+00	2025-01-15 03:00:00+00	2025-01-15 03:00:00+00
indeed_data_engineer_scraper	\N	t	f	f	2025-01-15 05:24:29.81718+00	\N	\N	\N	\N	/opt/airflow/dags/scraper_dag.py	/opt/airflow/dags	airflow	Scrape Indeed Data Engineer jobs	grid	"0 9,21 * * *"	At 09:00 and 21:00	16	1	f	t	2025-01-14 15:00:00+00	2025-01-14 15:00:00+00	2025-01-15 03:00:00+00	2025-01-15 03:00:00+00
indeed_data_scientist_scraper	\N	t	f	f	2025-01-15 05:24:29.820173+00	\N	\N	\N	\N	/opt/airflow/dags/scraper_dag.py	/opt/airflow/dags	airflow	Scrape Indeed Data Scientist jobs	grid	"0 9,21 * * *"	At 09:00 and 21:00	16	1	f	t	2025-01-14 15:00:00+00	2025-01-14 15:00:00+00	2025-01-15 03:00:00+00	2025-01-15 03:00:00+00
processing_raw_job_dag	\N	t	f	t	2025-01-15 05:51:22.279237+00	\N	\N	\N	\N	/opt/airflow/dags/processing_raw_job_dag.py	/opt/airflow/dags	airflow	Processes raw job data after the scraper DAG finishes	grid	null	Never, external triggers only	16	16	f	f	\N	\N	\N	\N
indeed_python_developer_scraper	\N	f	f	f	2025-01-15 05:24:29.821656+00	\N	\N	\N	\N	/opt/airflow/dags/scraper_dag.py	/opt/airflow/dags	airflow	Scrape Indeed Python Developer jobs	grid	"0 9,21 * * *"	At 09:00 and 21:00	16	1	f	t	2025-01-14 15:00:00+00	2025-01-14 15:00:00+00	2025-01-15 03:00:00+00	\N
linkedin_data_engineer_scraper	\N	t	f	f	2025-01-15 05:24:29.822038+00	\N	\N	\N	\N	/opt/airflow/dags/scraper_dag.py	/opt/airflow/dags	airflow	Scrape LinkedIn Data Engineer jobs	grid	"0 9,21 * * *"	At 09:00 and 21:00	16	1	f	t	2025-01-14 15:00:00+00	2025-01-14 15:00:00+00	2025-01-15 03:00:00+00	2025-01-15 03:00:00+00
linkedin_data_scientist_scraper	\N	t	f	f	2025-01-15 05:24:29.823293+00	\N	\N	\N	\N	/opt/airflow/dags/scraper_dag.py	/opt/airflow/dags	airflow	Scrape LinkedIn Data Scientist jobs	grid	"0 9,21 * * *"	At 09:00 and 21:00	16	1	f	t	2025-01-14 15:00:00+00	2025-01-14 15:00:00+00	2025-01-15 03:00:00+00	2025-01-15 03:00:00+00
\.


--
-- Data for Name: dag_code; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dag_code (fileloc_hash, fileloc, last_updated, source_code) FROM stdin;
29932838124493518	/opt/airflow/dags/job_scraper_dag.py	2025-01-15 05:17:32.407069+00	import pendulum\nfrom datetime import timedelta\nfrom airflow import DAG\nfrom airflow.providers.docker.operators.docker import DockerOperator\nfrom docker.types import Mount\n\nlocal_tz = pendulum.timezone("America/Chicago")\n\ndefault_args = {\n    'owner': 'airflow',\n    'depends_on_past': False,\n    # Use a start_date with the Chicago timezone\n    'start_date': local_tz.datetime(2024, 1, 1),\n    'email': [],\n    'email_on_failure': False,\n    'email_on_retry': False,\n    'retries': 1,\n    'retry_delay': timedelta(minutes=5),\n}\n\nSCRAPER_CONFIGS = [\n    {"source": "indeed", "category": "data_engineer", "max_pages": 20},\n    {"source": "indeed", "category": "data_scientist", "max_pages": 20},\n    {"source": "indeed", "category": "python_developer", "max_pages": 20},\n    {"source": "linkedin", "category": "data_engineer", "max_pages": 20},\n    {"source": "linkedin", "category": "data_scientist", "max_pages": 20},\n    {"source": "linkedin", "category": "python_developer", "max_pages": 20},\n]\n\nwith DAG(\n    'job_scraper',\n    default_args=default_args,\n    description='Schedule job scraping tasks',\n    # 9 AM and 9 PM local time (Chicago) => "0 9,21 * * *"\n    schedule_interval='0 9,21 * * *',\n    catchup=False\n) as dag:\n    for config in SCRAPER_CONFIGS:\n        task = DockerOperator(\n            task_id=f'scrape_{config["source"]}_{config["category"]}',\n            image='job-search-scraper:latest',\n            command=(\n                f'python -m app.scrapers.scraper_main '\n                f'--source {config["source"]} '\n                f'--category {config["category"]} '\n                f'--max_pages {config["max_pages"]}'\n            ),\n            network_mode='job-search_scraper_network',\n            api_version='auto',\n            docker_url='unix://var/run/docker.sock',\n            auto_remove=True,\n            environment={\n                'DATABASE_HOSTNAME': 'db',\n                'DATABASE_PORT': '5432',\n                'DATABASE_USERNAME': '{{ var.value.DATABASE_USERNAME }}',\n                'DATABASE_PASSWORD': '{{ var.value.DATABASE_PASSWORD }}',\n                'DATABASE_NAME': 'job_postings',\n                'FLARESOLVERR_URL': 'http://flaresolverr:8191/v1',\n                'PYTHONUNBUFFERED': '1',\n                'LINKEDIN_EMAIL': '{{ var.value.LINKEDIN_EMAIL }}',\n                'LINKEDIN_PASSWORD': '{{ var.value.LINKEDIN_PASSWORD }}'\n            },\n            force_pull=False,\n            mounts=[\n                Mount(\n                    source='/var/run/docker.sock',\n                    target='/var/run/docker.sock',\n                    type='bind'\n                ),\n                Mount(\n                    source='scraper_logs',\n                    target='/app/logs',\n                    type='volume',\n                    driver_config={\n                        'type': 'volume',\n                        'driver': 'local',\n                        'o': 'bind'\n                    }\n                )\n            ],\n            mount_tmp_dir=False,\n            privileged=True,\n            working_dir='/app'\n        )
43824819243750008	/opt/airflow/dags/scraper_dag.py	2025-01-15 05:17:32.521632+00	import pendulum\nfrom datetime import timedelta\nfrom airflow import DAG\nfrom airflow.providers.docker.operators.docker import DockerOperator\nfrom docker.types import Mount\n\nlocal_tz = pendulum.timezone("America/Chicago")\n\n# Common configuration that will be shared across all DAGs\ndef get_default_args():\n    return {\n        'owner': 'airflow',\n        'depends_on_past': False,\n        'start_date': local_tz.datetime(2024, 1, 1),\n        'email': [],\n        'email_on_failure': False,\n        'email_on_retry': False,\n        'retries': 1,\n        'retry_delay': timedelta(minutes=5),\n    }\n\ndef create_docker_operator(source, category, max_pages):\n    """Creates a DockerOperator with the specified configuration."""\n    return DockerOperator(\n        task_id=f'scrape_{source}_{category}',\n        image='scraper:latest',\n        command=(\n            f'python -m app.scrapers.scraper_main '\n            f'--source {source} '\n            f'--category {category} '\n            f'--max_pages {max_pages}'\n        ),\n        network_mode='job-search_scraper_network',\n        api_version='auto',\n        docker_url='unix://var/run/docker.sock',\n        auto_remove=True,\n        environment={\n            'DATABASE_HOSTNAME': 'db',\n            'DATABASE_PORT': '5432',\n            'DATABASE_USERNAME': '{{ var.value.DATABASE_USERNAME }}',\n            'DATABASE_PASSWORD': '{{ var.value.DATABASE_PASSWORD }}',\n            'DATABASE_NAME': 'job_postings',\n            'FLARESOLVERR_URL': 'http://flaresolverr:8191/v1',\n            'PYTHONUNBUFFERED': '1',\n            'LINKEDIN_EMAIL': '{{ var.value.LINKEDIN_EMAIL }}',\n            'LINKEDIN_PASSWORD': '{{ var.value.LINKEDIN_PASSWORD }}'\n        },\n        force_pull=False,\n        mounts=[\n            Mount(\n                source='/var/run/docker.sock',\n                target='/var/run/docker.sock',\n                type='bind'\n            ),\n            Mount(\n                source='scraper_logs',\n                target='/app/logs',\n                type='volume',\n                driver_config={\n                    'type': 'volume',\n                    'driver': 'local',\n                    'o': 'bind'\n                }\n            )\n        ],\n        mount_tmp_dir=False,\n        privileged=True,\n        working_dir='/app'\n    )\n\n# Indeed Data Engineer DAG\nwith DAG(\n    'indeed_data_engineer_scraper',\n    default_args=get_default_args(),\n    description='Scrape Indeed Data Engineer jobs',\n    schedule_interval='0 9,21 * * *',\n    catchup=False,\n    max_active_runs=1,\n) as dag_indeed_de:\n    create_docker_operator('indeed', 'data_engineer', 20)\n\n# Indeed Data Scientist DAG\nwith DAG(\n    'indeed_data_scientist_scraper',\n    default_args=get_default_args(),\n    description='Scrape Indeed Data Scientist jobs',\n    schedule_interval='0 9,21 * * *',\n    catchup=False,\n    max_active_runs=1,\n) as dag_indeed_ds:\n    create_docker_operator('indeed', 'data_scientist', 20)\n\n# Indeed Python Developer DAG\nwith DAG(\n    'indeed_python_developer_scraper',\n    default_args=get_default_args(),\n    description='Scrape Indeed Python Developer jobs',\n    schedule_interval='0 9,21 * * *',\n    catchup=False,\n    max_active_runs=1,\n) as dag_indeed_py:\n    create_docker_operator('indeed', 'python_developer', 20)\n\n# LinkedIn Data Engineer DAG\nwith DAG(\n    'linkedin_data_engineer_scraper',\n    default_args=get_default_args(),\n    description='Scrape LinkedIn Data Engineer jobs',\n    schedule_interval='0 9,21 * * *',\n    catchup=False,\n    max_active_runs=1,\n) as dag_linkedin_de:\n    create_docker_operator('linkedin', 'data_engineer', 20)\n\n# LinkedIn Data Scientist DAG\nwith DAG(\n    'linkedin_data_scientist_scraper',\n    default_args=get_default_args(),\n    description='Scrape LinkedIn Data Scientist jobs',\n    schedule_interval='0 9,21 * * *',\n    catchup=False,\n    max_active_runs=1,\n) as dag_linkedin_ds:\n    create_docker_operator('linkedin', 'data_scientist', 20)\n\n# LinkedIn Python Developer DAG\nwith DAG(\n    'linkedin_python_developer_scraper',\n    default_args=get_default_args(),\n    description='Scrape LinkedIn Python Developer jobs',\n    schedule_interval='0 9,21 * * *',\n    catchup=False,\n    max_active_runs=1,\n) as dag_linkedin_py:\n    create_docker_operator('linkedin', 'python_developer', 20)
57921186484078647	/opt/airflow/dags/processing_raw_job_dag.py	2025-01-15 05:17:32.592297+00	import pendulum\nfrom datetime import datetime, timedelta\nfrom airflow import DAG\nfrom airflow.sensors.external_task import ExternalTaskSensor\nfrom airflow.providers.docker.operators.docker import DockerOperator\nfrom docker.types import Mount\n\nlocal_tz = pendulum.timezone("America/Chicago")\n\ndefault_args = {\n    'owner': 'airflow',\n    'depends_on_past': False,\n    'start_date': local_tz.datetime(2024, 1, 1),\n    'email': [],\n    'email_on_failure': False,\n    'email_on_retry': False,\n    'retries': 1,\n    'retry_delay': timedelta(minutes=5),\n}\n\nwith DAG(\n    dag_id="processing_raw_job_dag",\n    default_args=default_args,\n    description="Processes raw job data after the scraper DAG finishes",\n    schedule_interval=None,  # No cron schedule; we'll rely on waiting for the external DAG\n    catchup=False\n) as dag:\n\n    # 1) Wait for "job_scraper" DAG to complete\n    wait_for_scraper = ExternalTaskSensor(\n        task_id='wait_for_job_scraper',\n        external_dag_id='job_scraper',\n        external_task_id=None,   # Wait for the entire "job_scraper" DAG to finish\n        poke_interval=60,       # how often to check (seconds)\n        timeout=60 * 60,        # 1 hour max wait\n        mode='reschedule'\n        # If you only want to wait for a specific task in job_scraper, you can set 'external_task_id'\n    )\n\n    # 2) Run the process_jobs.py script inside a Docker container\n    process_jobs = DockerOperator(\n        task_id='process_raw_jobs',\n        image='job-search-scraper:latest',\n        command='python /app/scripts/process_jobs.py',\n        network_mode='job-search_scraper_network',    # Adjust if needed\n        api_version='auto',\n        docker_url='unix://var/run/docker.sock',\n        auto_remove=True,\n        environment={\n            'DATABASE_HOSTNAME': 'db',\n            'DATABASE_PORT': '5432',\n            'DATABASE_USERNAME': '{{ var.value.DATABASE_USERNAME }}',\n            'DATABASE_PASSWORD': '{{ var.value.DATABASE_PASSWORD }}',\n            'DATABASE_NAME': 'job_postings',\n            'PYTHONUNBUFFERED': '1'\n        },\n        mounts=[\n            Mount(\n                source='/var/run/docker.sock',\n                target='/var/run/docker.sock',\n                type='bind'\n            ),\n            Mount(\n                source='scraper_logs',\n                target='/app/logs',\n                type='volume',\n                driver_config={\n                    'type': 'volume',\n                    'driver': 'local',\n                    'o': 'bind'\n                }\n            )\n        ],\n        mount_tmp_dir=False,\n        privileged=True,\n        working_dir='/app'\n    )\n\n    # 3) Define the DAG’s flow\n    wait_for_scraper >> process_jobs\n
\.


--
-- Data for Name: dag_owner_attributes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dag_owner_attributes (dag_id, owner, link) FROM stdin;
\.


--
-- Data for Name: dag_pickle; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dag_pickle (id, pickle, created_dttm, pickle_hash) FROM stdin;
\.


--
-- Data for Name: dag_run; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dag_run (id, dag_id, queued_at, execution_date, start_date, end_date, state, run_id, creating_job_id, external_trigger, run_type, conf, data_interval_start, data_interval_end, last_scheduling_decision, dag_hash, log_template_id, updated_at) FROM stdin;
3	indeed_python_developer_scraper	2025-01-15 05:19:06.519896+00	2025-01-15 05:19:06.506037+00	2025-01-15 05:24:12.965556+00	\N	running	manual__2025-01-15T05:19:06.506037+00:00	\N	t	manual	\\x80057d942e	2025-01-14 15:00:00+00	2025-01-15 03:00:00+00	2025-01-15 05:26:26.166248+00	885a251309bb54f0dc2958a817a0a36e	2	2025-01-15 05:26:26.168341+00
4	indeed_python_developer_scraper	2025-01-15 05:19:06.834629+00	2025-01-14 15:00:00+00	2025-01-15 05:19:06.865885+00	2025-01-15 05:24:11.918498+00	failed	scheduled__2025-01-14T15:00:00+00:00	1	f	scheduled	\\x80057d942e	2025-01-14 15:00:00+00	2025-01-15 03:00:00+00	2025-01-15 05:24:11.917325+00	885a251309bb54f0dc2958a817a0a36e	2	2025-01-15 05:24:11.918987+00
\.


--
-- Data for Name: dag_run_note; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dag_run_note (user_id, dag_run_id, content, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: dag_schedule_dataset_reference; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dag_schedule_dataset_reference (dataset_id, dag_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: dag_tag; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dag_tag (name, dag_id) FROM stdin;
\.


--
-- Data for Name: dag_warning; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dag_warning (dag_id, warning_type, message, "timestamp") FROM stdin;
\.


--
-- Data for Name: dagrun_dataset_event; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dagrun_dataset_event (dag_run_id, event_id) FROM stdin;
\.


--
-- Data for Name: dataset; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dataset (id, uri, extra, created_at, updated_at, is_orphaned) FROM stdin;
\.


--
-- Data for Name: dataset_dag_run_queue; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dataset_dag_run_queue (dataset_id, target_dag_id, created_at) FROM stdin;
\.


--
-- Data for Name: dataset_event; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dataset_event (id, dataset_id, extra, source_task_id, source_dag_id, source_run_id, source_map_index, "timestamp") FROM stdin;
\.


--
-- Data for Name: import_error; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.import_error (id, "timestamp", filename, stacktrace) FROM stdin;
1	2025-01-15 05:51:22.163778+00	/opt/airflow/dags/scraper_dag.py	Traceback (most recent call last):\n  File "/home/airflow/.local/lib/python3.8/site-packages/airflow/models/baseoperator.py", line 437, in apply_defaults\n    result = func(self, **kwargs, default_args=default_args)\n  File "/home/airflow/.local/lib/python3.8/site-packages/airflow/models/baseoperator.py", line 794, in __init__\n    raise AirflowException(\nairflow.exceptions.AirflowException: Invalid arguments were passed to DockerOperator (task_id: scrape_indeed_data_engineer). Invalid arguments were:\n**kwargs: {'volumes': ['scraper_logs:/app/logs']}\n
\.


--
-- Data for Name: job; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job (id, dag_id, state, job_type, start_date, end_date, latest_heartbeat, executor_class, hostname, unixname) FROM stdin;
50	\N	success	SchedulerJob	2025-01-15 05:38:07.13347+00	2025-01-15 05:42:08.67052+00	2025-01-15 05:42:05.972712+00	\N	29bc09ffdecf	airflow
51	\N	success	SchedulerJob	2025-01-15 05:42:39.726955+00	2025-01-15 05:43:27.76038+00	2025-01-15 05:43:21.504002+00	\N	3aa6abadf48a	airflow
14	indeed_python_developer_scraper	success	LocalTaskJob	2025-01-15 05:19:08.677138+00	2025-01-15 05:19:09.096301+00	2025-01-15 05:19:08.657494+00	\N	494f1446d77e	airflow
49	\N	success	SchedulerJob	2025-01-15 05:34:20.334944+00	2025-01-15 05:37:37.870616+00	2025-01-15 05:37:33.20649+00	\N	507e4e0fd666	airflow
1	\N	failed	SchedulerJob	2025-01-15 05:17:31.472121+00	\N	2025-01-15 05:19:34.684263+00	\N	494f1446d77e	airflow
54	\N	success	SchedulerJob	2025-01-15 05:47:47.261109+00	2025-01-15 05:51:39.991921+00	2025-01-15 05:51:34.656395+00	\N	d9bc3a52c618	airflow
52	\N	success	SchedulerJob	2025-01-15 05:43:53.340419+00	2025-01-15 05:45:48.469341+00	2025-01-15 05:45:44.506976+00	\N	8824e9f193d6	airflow
34	\N	success	SchedulerJob	2025-01-15 05:20:23.336109+00	2025-01-15 05:33:54.262612+00	2025-01-15 05:33:52.547185+00	\N	494f1446d77e	airflow
53	\N	success	SchedulerJob	2025-01-15 05:46:15.786167+00	2025-01-15 05:47:20.580658+00	2025-01-15 05:47:16.643033+00	\N	3f204ad4f3eb	airflow
47	indeed_python_developer_scraper	success	LocalTaskJob	2025-01-15 05:24:11.347444+00	2025-01-15 05:24:11.655453+00	2025-01-15 05:24:11.32988+00	\N	494f1446d77e	airflow
48	indeed_python_developer_scraper	success	LocalTaskJob	2025-01-15 05:24:14.321772+00	2025-01-15 05:24:14.632574+00	2025-01-15 05:24:14.305596+00	\N	494f1446d77e	airflow
\.


--
-- Data for Name: log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.log (id, dttm, dag_id, task_id, map_index, event, execution_date, owner, extra) FROM stdin;
1	2025-01-15 05:17:29.543355+00	\N	\N	\N	cli_scheduler	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}
2	2025-01-15 05:17:30.293246+00	\N	\N	\N	cli_users_create	\N	airflow	{"host_name": "8323288550f7", "full_command": "['/home/airflow/.local/bin/airflow', 'users', 'create', '--username', 'admin', '--password', '********', '--firstname', 'Admin', '--lastname', 'User', '--role', 'Admin', '--email', 'admin@example.co']"}
3	2025-01-15 05:17:55.516182+00	job_scraper	\N	\N	grid	\N	Admin User	[('dag_id', 'job_scraper')]
4	2025-01-15 05:17:57.946653+00	job_scraper	\N	\N	trigger	\N	Admin User	[('origin', '/dags/job_scraper/grid'), ('dag_id', 'job_scraper')]
5	2025-01-15 05:17:58.019009+00	job_scraper	\N	\N	grid	\N	Admin User	[('dag_id', 'job_scraper')]
6	2025-01-15 05:18:00.585642+00	job_scraper	\N	\N	grid	\N	Admin User	[('dag_id', 'job_scraper')]
7	2025-01-15 05:18:00.822781+00	job_scraper	scrape_linkedin_python_developer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_python_developer', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
8	2025-01-15 05:18:02.683478+00	job_scraper	scrape_indeed_data_engineer	\N	confirm	\N	Admin User	[('dag_id', 'job_scraper'), ('dag_run_id', 'scheduled__2025-01-14T15:00:00+00:00'), ('past', 'false'), ('future', 'false'), ('upstream', 'false'), ('downstream', 'false'), ('state', 'success'), ('task_id', 'scrape_indeed_data_engineer')]
9	2025-01-15 05:18:02.723212+00	job_scraper	scrape_indeed_data_engineer	\N	clear	2025-01-14 15:00:00+00	Admin User	[('dag_id', 'job_scraper'), ('dag_run_id', 'scheduled__2025-01-14T15:00:00+00:00'), ('confirmed', 'false'), ('execution_date', '2025-01-14T15:00:00+00:00'), ('past', 'false'), ('future', 'false'), ('upstream', 'false'), ('downstream', 'true'), ('recursive', 'true'), ('only_failed', 'false'), ('task_id', 'scrape_indeed_data_engineer')]
10	2025-01-15 05:18:03.266402+00	job_scraper	scrape_linkedin_python_developer	-1	running	2025-01-14 15:00:00+00	airflow	\N
11	2025-01-15 05:18:03.285866+00	job_scraper	scrape_linkedin_python_developer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_python_developer', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
12	2025-01-15 05:18:03.46963+00	job_scraper	scrape_linkedin_python_developer	-1	failed	2025-01-14 15:00:00+00	airflow	\N
13	2025-01-15 05:18:05.280972+00	job_scraper	scrape_indeed_data_engineer	\N	grid	\N	Admin User	[('dag_run_id', 'scheduled__2025-01-14T15:00:00+00:00'), ('task_id', 'scrape_indeed_data_engineer'), ('tab', 'logs'), ('dag_id', 'job_scraper')]
14	2025-01-15 05:18:05.799258+00	job_scraper	scrape_indeed_data_engineer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_data_engineer', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
15	2025-01-15 05:18:05.966487+00	job_scraper	scrape_indeed_data_engineer	\N	clear	2025-01-14 15:00:00+00	Admin User	[('dag_id', 'job_scraper'), ('dag_run_id', 'scheduled__2025-01-14T15:00:00+00:00'), ('confirmed', 'false'), ('execution_date', '2025-01-14T15:00:00+00:00'), ('past', 'false'), ('future', 'false'), ('upstream', 'false'), ('downstream', 'true'), ('recursive', 'true'), ('only_failed', 'false'), ('task_id', 'scrape_indeed_data_engineer')]
16	2025-01-15 05:18:05.975491+00	job_scraper	scrape_indeed_data_engineer	\N	confirm	\N	Admin User	[('dag_id', 'job_scraper'), ('dag_run_id', 'scheduled__2025-01-14T15:00:00+00:00'), ('past', 'false'), ('future', 'false'), ('upstream', 'false'), ('downstream', 'false'), ('state', 'success'), ('task_id', 'scrape_indeed_data_engineer')]
17	2025-01-15 05:18:06.945141+00	job_scraper	scrape_linkedin_python_developer	\N	confirm	\N	Admin User	[('dag_id', 'job_scraper'), ('dag_run_id', 'scheduled__2025-01-14T15:00:00+00:00'), ('past', 'false'), ('future', 'false'), ('upstream', 'false'), ('downstream', 'false'), ('state', 'success'), ('task_id', 'scrape_linkedin_python_developer')]
18	2025-01-15 05:18:06.94763+00	job_scraper	scrape_linkedin_python_developer	\N	clear	2025-01-14 15:00:00+00	Admin User	[('dag_id', 'job_scraper'), ('dag_run_id', 'scheduled__2025-01-14T15:00:00+00:00'), ('confirmed', 'false'), ('execution_date', '2025-01-14T15:00:00+00:00'), ('past', 'false'), ('future', 'false'), ('upstream', 'false'), ('downstream', 'true'), ('recursive', 'true'), ('only_failed', 'false'), ('task_id', 'scrape_linkedin_python_developer')]
19	2025-01-15 05:18:07.16191+00	job_scraper	scrape_indeed_data_engineer	-1	running	2025-01-14 15:00:00+00	airflow	\N
20	2025-01-15 05:18:07.185027+00	job_scraper	scrape_indeed_data_engineer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_data_engineer', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
21	2025-01-15 05:18:07.390126+00	job_scraper	scrape_indeed_data_engineer	-1	failed	2025-01-14 15:00:00+00	airflow	\N
22	2025-01-15 05:18:09.025089+00	job_scraper	scrape_indeed_data_scientist	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_data_scientist', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
23	2025-01-15 05:18:09.653111+00	job_scraper	scrape_indeed_data_scientist	-1	running	2025-01-14 15:00:00+00	airflow	\N
24	2025-01-15 05:18:09.668108+00	job_scraper	scrape_indeed_data_scientist	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_data_scientist', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
25	2025-01-15 05:18:09.774945+00	job_scraper	scrape_indeed_data_scientist	-1	failed	2025-01-14 15:00:00+00	airflow	\N
26	2025-01-15 05:18:10.838226+00	job_scraper	scrape_indeed_python_developer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_python_developer', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
27	2025-01-15 05:18:11.396805+00	job_scraper	scrape_indeed_python_developer	-1	running	2025-01-14 15:00:00+00	airflow	\N
28	2025-01-15 05:18:11.412145+00	job_scraper	scrape_indeed_python_developer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_python_developer', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
29	2025-01-15 05:18:11.51687+00	job_scraper	scrape_indeed_python_developer	-1	failed	2025-01-14 15:00:00+00	airflow	\N
30	2025-01-15 05:18:12.550681+00	job_scraper	scrape_linkedin_data_engineer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_data_engineer', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
31	2025-01-15 05:18:13.09309+00	job_scraper	scrape_linkedin_data_engineer	-1	running	2025-01-14 15:00:00+00	airflow	\N
32	2025-01-15 05:18:13.10812+00	job_scraper	scrape_linkedin_data_engineer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_data_engineer', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
33	2025-01-15 05:18:13.223877+00	job_scraper	scrape_linkedin_data_engineer	-1	failed	2025-01-14 15:00:00+00	airflow	\N
34	2025-01-15 05:18:14.408438+00	job_scraper	scrape_linkedin_data_scientist	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_data_scientist', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
35	2025-01-15 05:18:15.445137+00	job_scraper	scrape_linkedin_data_scientist	-1	running	2025-01-14 15:00:00+00	airflow	\N
36	2025-01-15 05:18:15.465571+00	job_scraper	scrape_linkedin_data_scientist	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_data_scientist', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
37	2025-01-15 05:18:15.596303+00	job_scraper	scrape_linkedin_data_scientist	-1	failed	2025-01-14 15:00:00+00	airflow	\N
38	2025-01-15 05:18:16.119406+00	\N	\N	\N	variable.create	\N	Admin User	[]
39	2025-01-15 05:18:16.961953+00	job_scraper	scrape_indeed_data_engineer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_data_engineer', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
40	2025-01-15 05:18:17.599598+00	job_scraper	scrape_indeed_data_engineer	-1	running	2025-01-15 05:17:57.951787+00	airflow	\N
41	2025-01-15 05:18:17.615922+00	job_scraper	scrape_indeed_data_engineer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_data_engineer', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
42	2025-01-15 05:18:17.748938+00	job_scraper	scrape_indeed_data_engineer	-1	failed	2025-01-15 05:17:57.951787+00	airflow	\N
43	2025-01-15 05:18:19.044129+00	job_scraper	scrape_indeed_data_scientist	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_data_scientist', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
44	2025-01-15 05:18:19.61121+00	job_scraper	scrape_indeed_data_scientist	-1	running	2025-01-15 05:17:57.951787+00	airflow	\N
45	2025-01-15 05:18:19.627162+00	job_scraper	scrape_indeed_data_scientist	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_data_scientist', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
46	2025-01-15 05:18:19.733315+00	job_scraper	scrape_indeed_data_scientist	-1	failed	2025-01-15 05:17:57.951787+00	airflow	\N
47	2025-01-15 05:18:20.788541+00	job_scraper	scrape_indeed_python_developer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_python_developer', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
48	2025-01-15 05:18:21.344063+00	job_scraper	scrape_indeed_python_developer	-1	running	2025-01-15 05:17:57.951787+00	airflow	\N
49	2025-01-15 05:18:21.361043+00	job_scraper	scrape_indeed_python_developer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_python_developer', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
50	2025-01-15 05:18:21.46619+00	job_scraper	scrape_indeed_python_developer	-1	failed	2025-01-15 05:17:57.951787+00	airflow	\N
51	2025-01-15 05:18:22.544241+00	job_scraper	scrape_linkedin_data_engineer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_data_engineer', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
52	2025-01-15 05:18:23.083525+00	job_scraper	scrape_linkedin_data_engineer	-1	running	2025-01-15 05:17:57.951787+00	airflow	\N
53	2025-01-15 05:18:23.098423+00	job_scraper	scrape_linkedin_data_engineer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_data_engineer', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
54	2025-01-15 05:18:23.197028+00	job_scraper	scrape_linkedin_data_engineer	-1	failed	2025-01-15 05:17:57.951787+00	airflow	\N
55	2025-01-15 05:18:24.290753+00	job_scraper	scrape_linkedin_data_scientist	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_data_scientist', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
56	2025-01-15 05:18:24.846636+00	job_scraper	scrape_linkedin_data_scientist	-1	running	2025-01-15 05:17:57.951787+00	airflow	\N
57	2025-01-15 05:18:24.861445+00	job_scraper	scrape_linkedin_data_scientist	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_data_scientist', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
58	2025-01-15 05:18:24.971814+00	job_scraper	scrape_linkedin_data_scientist	-1	failed	2025-01-15 05:17:57.951787+00	airflow	\N
59	2025-01-15 05:18:26.078453+00	job_scraper	scrape_linkedin_python_developer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_python_developer', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
60	2025-01-15 05:18:26.668248+00	job_scraper	scrape_linkedin_python_developer	-1	running	2025-01-15 05:17:57.951787+00	airflow	\N
61	2025-01-15 05:18:26.687327+00	job_scraper	scrape_linkedin_python_developer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_python_developer', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
62	2025-01-15 05:18:26.82346+00	job_scraper	scrape_linkedin_python_developer	-1	failed	2025-01-15 05:17:57.951787+00	airflow	\N
64	2025-01-15 05:18:36.527978+00	\N	\N	\N	variable.create	\N	Admin User	[]
65	2025-01-15 05:18:41.55147+00	\N	\N	\N	variable.create	\N	Admin User	[('key', 'DATABASE_PASSWORD'), ('val', '***'), ('description', '')]
68	2025-01-15 05:18:54.784036+00	\N	\N	\N	variable.create	\N	Admin User	[]
63	2025-01-15 05:18:34.697231+00	\N	\N	\N	variable.create	\N	Admin User	[('key', 'DATABASE_USERNAME'), ('val', 'postgres'), ('description', '')]
69	2025-01-15 05:19:00.356672+00	\N	\N	\N	variable.create	\N	Admin User	[('key', 'LINKEDIN_PASSWORD'), ('val', '***'), ('description', '')]
66	2025-01-15 05:18:42.805722+00	\N	\N	\N	variable.create	\N	Admin User	[]
67	2025-01-15 05:18:53.10596+00	\N	\N	\N	variable.create	\N	Admin User	[('key', 'LINKEDIN_EMAIL'), ('val', 'woodenkim25@gmail.com'), ('description', '')]
70	2025-01-15 05:19:04.581777+00	indeed_python_developer_scraper	\N	\N	grid	\N	Admin User	[('dag_id', 'indeed_python_developer_scraper')]
71	2025-01-15 05:19:06.502838+00	indeed_python_developer_scraper	\N	\N	trigger	\N	Admin User	[('origin', '/dags/indeed_python_developer_scraper/grid'), ('dag_id', 'indeed_python_developer_scraper')]
72	2025-01-15 05:19:06.544344+00	indeed_python_developer_scraper	\N	\N	grid	\N	Admin User	[('dag_id', 'indeed_python_developer_scraper')]
73	2025-01-15 05:19:07.932318+00	indeed_python_developer_scraper	scrape_indeed_python_developer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'indeed_python_developer_scraper', 'scrape_indeed_python_developer', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/scraper_dag.py']"}
74	2025-01-15 05:19:08.737145+00	indeed_python_developer_scraper	scrape_indeed_python_developer	-1	running	2025-01-14 15:00:00+00	airflow	\N
75	2025-01-15 05:19:08.754495+00	indeed_python_developer_scraper	scrape_indeed_python_developer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'indeed_python_developer_scraper', 'scrape_indeed_python_developer', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/scraper_dag.py']"}
76	2025-01-15 05:19:08.90857+00	indeed_python_developer_scraper	\N	\N	grid	\N	Admin User	[('dag_id', 'indeed_python_developer_scraper')]
77	2025-01-15 05:19:08.995474+00	indeed_python_developer_scraper	scrape_indeed_python_developer	-1	failed	2025-01-14 15:00:00+00	airflow	\N
78	2025-01-15 05:19:10.477298+00	indeed_python_developer_scraper	scrape_indeed_python_developer	\N	clear	2025-01-14 15:00:00+00	Admin User	[('dag_id', 'indeed_python_developer_scraper'), ('dag_run_id', 'scheduled__2025-01-14T15:00:00+00:00'), ('confirmed', 'false'), ('execution_date', '2025-01-14T15:00:00+00:00'), ('past', 'false'), ('future', 'false'), ('upstream', 'false'), ('downstream', 'true'), ('recursive', 'true'), ('only_failed', 'false'), ('task_id', 'scrape_indeed_python_developer')]
79	2025-01-15 05:19:10.482955+00	indeed_python_developer_scraper	scrape_indeed_python_developer	\N	confirm	\N	Admin User	[('dag_id', 'indeed_python_developer_scraper'), ('dag_run_id', 'scheduled__2025-01-14T15:00:00+00:00'), ('past', 'false'), ('future', 'false'), ('upstream', 'false'), ('downstream', 'false'), ('state', 'success'), ('task_id', 'scrape_indeed_python_developer')]
100	2025-01-15 05:20:19.836828+00	\N	\N	\N	cli_migratedb	\N	airflow	{"host_name": "8323288550f7", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'upgrade']"}
101	2025-01-15 05:20:20.207854+00	\N	\N	\N	cli_check	\N	airflow	{"host_name": "d9c6b3395183", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
102	2025-01-15 05:20:20.207254+00	\N	\N	\N	cli_check	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
103	2025-01-15 05:20:21.282838+00	\N	\N	\N	cli_webserver	\N	airflow	{"host_name": "d9c6b3395183", "full_command": "['/home/airflow/.local/bin/airflow', 'webserver']"}
104	2025-01-15 05:20:22.037339+00	\N	\N	\N	cli_users_create	\N	airflow	{"host_name": "8323288550f7", "full_command": "['/home/airflow/.local/bin/airflow', 'users', 'create', '--username', 'admin', '--password', '********', '--firstname', 'Admin', '--lastname', 'User', '--role', 'Admin', '--email', 'admin@example.co']"}
105	2025-01-15 05:20:22.226889+00	\N	\N	\N	cli_scheduler	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}
106	2025-01-15 05:23:05.51434+00	job_scraper	scrape_linkedin_python_developer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_python_developer', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
107	2025-01-15 05:23:06.395732+00	job_scraper	scrape_linkedin_python_developer	-1	running	2025-01-14 15:00:00+00	airflow	\N
108	2025-01-15 05:23:06.416803+00	job_scraper	scrape_linkedin_python_developer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_python_developer', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
109	2025-01-15 05:23:06.637752+00	job_scraper	scrape_linkedin_python_developer	-1	failed	2025-01-14 15:00:00+00	airflow	\N
110	2025-01-15 05:23:08.821933+00	job_scraper	scrape_indeed_data_engineer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_data_engineer', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
111	2025-01-15 05:23:09.366892+00	job_scraper	scrape_indeed_data_engineer	-1	running	2025-01-14 15:00:00+00	airflow	\N
112	2025-01-15 05:23:09.381623+00	job_scraper	scrape_indeed_data_engineer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_data_engineer', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
113	2025-01-15 05:23:09.558234+00	job_scraper	scrape_indeed_data_engineer	-1	failed	2025-01-14 15:00:00+00	airflow	\N
114	2025-01-15 05:23:10.898891+00	job_scraper	scrape_indeed_data_scientist	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_data_scientist', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
115	2025-01-15 05:23:11.643015+00	job_scraper	scrape_indeed_data_scientist	-1	running	2025-01-14 15:00:00+00	airflow	\N
116	2025-01-15 05:23:11.675203+00	job_scraper	scrape_indeed_data_scientist	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_data_scientist', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
117	2025-01-15 05:23:11.935985+00	job_scraper	scrape_indeed_data_scientist	-1	failed	2025-01-14 15:00:00+00	airflow	\N
118	2025-01-15 05:23:13.398407+00	job_scraper	scrape_indeed_python_developer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_python_developer', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
119	2025-01-15 05:23:14.044568+00	job_scraper	scrape_indeed_python_developer	-1	running	2025-01-14 15:00:00+00	airflow	\N
120	2025-01-15 05:23:14.063404+00	job_scraper	scrape_indeed_python_developer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_python_developer', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
121	2025-01-15 05:23:14.266529+00	job_scraper	scrape_indeed_python_developer	-1	failed	2025-01-14 15:00:00+00	airflow	\N
122	2025-01-15 05:23:15.449842+00	job_scraper	scrape_linkedin_data_engineer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_data_engineer', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
123	2025-01-15 05:23:15.989385+00	job_scraper	scrape_linkedin_data_engineer	-1	running	2025-01-14 15:00:00+00	airflow	\N
124	2025-01-15 05:23:16.00443+00	job_scraper	scrape_linkedin_data_engineer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_data_engineer', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
125	2025-01-15 05:23:16.173396+00	job_scraper	scrape_linkedin_data_engineer	-1	failed	2025-01-14 15:00:00+00	airflow	\N
126	2025-01-15 05:23:17.319074+00	job_scraper	scrape_linkedin_data_scientist	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_data_scientist', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
127	2025-01-15 05:23:17.850388+00	job_scraper	scrape_linkedin_data_scientist	-1	running	2025-01-14 15:00:00+00	airflow	\N
128	2025-01-15 05:23:17.865739+00	job_scraper	scrape_linkedin_data_scientist	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_data_scientist', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
129	2025-01-15 05:23:18.026938+00	job_scraper	scrape_linkedin_data_scientist	-1	failed	2025-01-14 15:00:00+00	airflow	\N
130	2025-01-15 05:23:19.462097+00	job_scraper	scrape_indeed_data_engineer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_data_engineer', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
131	2025-01-15 05:23:20.015747+00	job_scraper	scrape_indeed_data_engineer	-1	running	2025-01-15 05:17:57.951787+00	airflow	\N
132	2025-01-15 05:23:20.031204+00	job_scraper	scrape_indeed_data_engineer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_data_engineer', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
133	2025-01-15 05:23:20.219121+00	job_scraper	scrape_indeed_data_engineer	-1	failed	2025-01-15 05:17:57.951787+00	airflow	\N
134	2025-01-15 05:23:21.381618+00	job_scraper	scrape_indeed_data_scientist	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_data_scientist', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
135	2025-01-15 05:23:21.993579+00	job_scraper	scrape_indeed_data_scientist	-1	running	2025-01-15 05:17:57.951787+00	airflow	\N
136	2025-01-15 05:23:22.010914+00	job_scraper	scrape_indeed_data_scientist	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_data_scientist', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
137	2025-01-15 05:23:22.207506+00	job_scraper	scrape_indeed_data_scientist	-1	failed	2025-01-15 05:17:57.951787+00	airflow	\N
138	2025-01-15 05:23:23.413205+00	job_scraper	scrape_indeed_python_developer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_python_developer', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
139	2025-01-15 05:23:24.057158+00	job_scraper	scrape_indeed_python_developer	-1	running	2025-01-15 05:17:57.951787+00	airflow	\N
140	2025-01-15 05:23:24.083807+00	job_scraper	scrape_indeed_python_developer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_indeed_python_developer', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
141	2025-01-15 05:23:24.304603+00	job_scraper	scrape_indeed_python_developer	-1	failed	2025-01-15 05:17:57.951787+00	airflow	\N
142	2025-01-15 05:23:25.577741+00	job_scraper	scrape_linkedin_data_engineer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_data_engineer', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
143	2025-01-15 05:23:26.169575+00	job_scraper	scrape_linkedin_data_engineer	-1	running	2025-01-15 05:17:57.951787+00	airflow	\N
144	2025-01-15 05:23:26.185279+00	job_scraper	scrape_linkedin_data_engineer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_data_engineer', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
145	2025-01-15 05:23:26.362624+00	job_scraper	scrape_linkedin_data_engineer	-1	failed	2025-01-15 05:17:57.951787+00	airflow	\N
146	2025-01-15 05:23:27.454514+00	job_scraper	scrape_linkedin_data_scientist	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_data_scientist', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
147	2025-01-15 05:23:27.990082+00	job_scraper	scrape_linkedin_data_scientist	-1	running	2025-01-15 05:17:57.951787+00	airflow	\N
148	2025-01-15 05:23:28.005454+00	job_scraper	scrape_linkedin_data_scientist	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_data_scientist', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
149	2025-01-15 05:23:28.174417+00	job_scraper	scrape_linkedin_data_scientist	-1	failed	2025-01-15 05:17:57.951787+00	airflow	\N
150	2025-01-15 05:23:29.358412+00	job_scraper	scrape_linkedin_python_developer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_python_developer', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
151	2025-01-15 05:23:29.916545+00	job_scraper	scrape_linkedin_python_developer	-1	running	2025-01-15 05:17:57.951787+00	airflow	\N
152	2025-01-15 05:23:29.934068+00	job_scraper	scrape_linkedin_python_developer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'job_scraper', 'scrape_linkedin_python_developer', 'manual__2025-01-15T05:17:57.951787+00:00', '--local', '--subdir', 'DAGS_FOLDER/job_scraper_dag.py']"}
153	2025-01-15 05:23:30.113166+00	job_scraper	scrape_linkedin_python_developer	-1	failed	2025-01-15 05:17:57.951787+00	airflow	\N
154	2025-01-15 05:24:10.692306+00	indeed_python_developer_scraper	scrape_indeed_python_developer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'indeed_python_developer_scraper', 'scrape_indeed_python_developer', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/scraper_dag.py']"}
155	2025-01-15 05:24:11.399869+00	indeed_python_developer_scraper	scrape_indeed_python_developer	-1	running	2025-01-14 15:00:00+00	airflow	\N
156	2025-01-15 05:24:11.415559+00	indeed_python_developer_scraper	scrape_indeed_python_developer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'indeed_python_developer_scraper', 'scrape_indeed_python_developer', 'scheduled__2025-01-14T15:00:00+00:00', '--local', '--subdir', 'DAGS_FOLDER/scraper_dag.py']"}
157	2025-01-15 05:24:11.604661+00	indeed_python_developer_scraper	scrape_indeed_python_developer	-1	failed	2025-01-14 15:00:00+00	airflow	\N
158	2025-01-15 05:24:13.770547+00	indeed_python_developer_scraper	scrape_indeed_python_developer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'indeed_python_developer_scraper', 'scrape_indeed_python_developer', 'manual__2025-01-15T05:19:06.506037+00:00', '--local', '--subdir', 'DAGS_FOLDER/scraper_dag.py']"}
159	2025-01-15 05:24:14.373348+00	indeed_python_developer_scraper	scrape_indeed_python_developer	-1	running	2025-01-15 05:19:06.506037+00	airflow	\N
160	2025-01-15 05:24:14.388119+00	indeed_python_developer_scraper	scrape_indeed_python_developer	\N	cli_task_run	\N	airflow	{"host_name": "494f1446d77e", "full_command": "['/home/airflow/.local/bin/airflow', 'tasks', 'run', 'indeed_python_developer_scraper', 'scrape_indeed_python_developer', 'manual__2025-01-15T05:19:06.506037+00:00', '--local', '--subdir', 'DAGS_FOLDER/scraper_dag.py']"}
161	2025-01-15 05:24:14.558675+00	indeed_python_developer_scraper	scrape_indeed_python_developer	-1	failed	2025-01-15 05:19:06.506037+00	airflow	\N
162	2025-01-15 05:34:14.683559+00	\N	\N	\N	cli_migratedb	\N	airflow	{"host_name": "8b0db0aebbbd", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'upgrade']"}
163	2025-01-15 05:34:14.834198+00	\N	\N	\N	cli_check	\N	airflow	{"host_name": "bb9aea28f9bf", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
164	2025-01-15 05:34:14.950723+00	\N	\N	\N	cli_check	\N	airflow	{"host_name": "507e4e0fd666", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
165	2025-01-15 05:34:16.061829+00	\N	\N	\N	cli_webserver	\N	airflow	{"host_name": "bb9aea28f9bf", "full_command": "['/home/airflow/.local/bin/airflow', 'webserver']"}
166	2025-01-15 05:34:18.095161+00	\N	\N	\N	cli_scheduler	\N	airflow	{"host_name": "507e4e0fd666", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}
167	2025-01-15 05:34:19.176691+00	\N	\N	\N	cli_users_create	\N	airflow	{"host_name": "8b0db0aebbbd", "full_command": "['/home/airflow/.local/bin/airflow', 'users', 'create', '--username', 'admin', '--password', '********', '--firstname', 'Admin', '--lastname', 'User', '--role', 'Admin', '--email', 'admin@example.co']"}
168	2025-01-15 05:38:01.866757+00	\N	\N	\N	cli_migratedb	\N	airflow	{"host_name": "ffcf98fd9df1", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'upgrade']"}
169	2025-01-15 05:38:02.053803+00	\N	\N	\N	cli_check	\N	airflow	{"host_name": "29bc09ffdecf", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
170	2025-01-15 05:38:02.110371+00	\N	\N	\N	cli_check	\N	airflow	{"host_name": "f2c152229b97", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
171	2025-01-15 05:38:02.889181+00	\N	\N	\N	cli_webserver	\N	airflow	{"host_name": "f2c152229b97", "full_command": "['/home/airflow/.local/bin/airflow', 'webserver']"}
172	2025-01-15 05:38:04.247457+00	\N	\N	\N	cli_scheduler	\N	airflow	{"host_name": "29bc09ffdecf", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}
173	2025-01-15 05:38:05.057061+00	\N	\N	\N	cli_users_create	\N	airflow	{"host_name": "ffcf98fd9df1", "full_command": "['/home/airflow/.local/bin/airflow', 'users', 'create', '--username', 'admin', '--password', '********', '--firstname', 'Admin', '--lastname', 'User', '--role', 'Admin', '--email', 'admin@example.co']"}
174	2025-01-15 05:42:33.769079+00	\N	\N	\N	cli_migratedb	\N	airflow	{"host_name": "453435eb1b01", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'upgrade']"}
175	2025-01-15 05:42:33.950502+00	\N	\N	\N	cli_check	\N	airflow	{"host_name": "65ccd2236338", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
176	2025-01-15 05:42:34.018358+00	\N	\N	\N	cli_check	\N	airflow	{"host_name": "3aa6abadf48a", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
177	2025-01-15 05:42:34.838252+00	\N	\N	\N	cli_webserver	\N	airflow	{"host_name": "65ccd2236338", "full_command": "['/home/airflow/.local/bin/airflow', 'webserver']"}
178	2025-01-15 05:42:36.917689+00	\N	\N	\N	cli_scheduler	\N	airflow	{"host_name": "3aa6abadf48a", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}
179	2025-01-15 05:42:37.961553+00	\N	\N	\N	cli_users_create	\N	airflow	{"host_name": "453435eb1b01", "full_command": "['/home/airflow/.local/bin/airflow', 'users', 'create', '--username', 'admin', '--password', '********', '--firstname', 'Admin', '--lastname', 'User', '--role', 'Admin', '--email', 'admin@example.co']"}
180	2025-01-15 05:43:49.477223+00	\N	\N	\N	cli_migratedb	\N	airflow	{"host_name": "8963cd1a67cd", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'upgrade']"}
181	2025-01-15 05:43:49.734835+00	\N	\N	\N	cli_check	\N	airflow	{"host_name": "8824e9f193d6", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
182	2025-01-15 05:43:49.77666+00	\N	\N	\N	cli_check	\N	airflow	{"host_name": "5caab0a6ff22", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
183	2025-01-15 05:43:50.578382+00	\N	\N	\N	cli_webserver	\N	airflow	{"host_name": "5caab0a6ff22", "full_command": "['/home/airflow/.local/bin/airflow', 'webserver']"}
184	2025-01-15 05:43:51.861561+00	\N	\N	\N	cli_scheduler	\N	airflow	{"host_name": "8824e9f193d6", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}
185	2025-01-15 05:43:52.393144+00	\N	\N	\N	cli_users_create	\N	airflow	{"host_name": "8963cd1a67cd", "full_command": "['/home/airflow/.local/bin/airflow', 'users', 'create', '--username', 'admin', '--password', '********', '--firstname', 'Admin', '--lastname', 'User', '--role', 'Admin', '--email', 'admin@example.co']"}
186	2025-01-15 05:46:10.589516+00	\N	\N	\N	cli_migratedb	\N	airflow	{"host_name": "8ec3cdd08285", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'upgrade']"}
187	2025-01-15 05:46:10.899553+00	\N	\N	\N	cli_check	\N	airflow	{"host_name": "b2d8f3cf37bb", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
188	2025-01-15 05:46:10.934056+00	\N	\N	\N	cli_check	\N	airflow	{"host_name": "3f204ad4f3eb", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
189	2025-01-15 05:46:11.726564+00	\N	\N	\N	cli_webserver	\N	airflow	{"host_name": "b2d8f3cf37bb", "full_command": "['/home/airflow/.local/bin/airflow', 'webserver']"}
190	2025-01-15 05:46:13.312845+00	\N	\N	\N	cli_scheduler	\N	airflow	{"host_name": "3f204ad4f3eb", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}
191	2025-01-15 05:46:13.892478+00	\N	\N	\N	cli_users_create	\N	airflow	{"host_name": "8ec3cdd08285", "full_command": "['/home/airflow/.local/bin/airflow', 'users', 'create', '--username', 'admin', '--password', '********', '--firstname', 'Admin', '--lastname', 'User', '--role', 'Admin', '--email', 'admin@example.co']"}
192	2025-01-15 05:47:42.695208+00	\N	\N	\N	cli_migratedb	\N	airflow	{"host_name": "eab0e56bdcb5", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'upgrade']"}
193	2025-01-15 05:47:42.91464+00	\N	\N	\N	cli_check	\N	airflow	{"host_name": "cd29ee83ed2e", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
194	2025-01-15 05:47:42.986317+00	\N	\N	\N	cli_check	\N	airflow	{"host_name": "d9bc3a52c618", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
195	2025-01-15 05:47:43.913308+00	\N	\N	\N	cli_webserver	\N	airflow	{"host_name": "cd29ee83ed2e", "full_command": "['/home/airflow/.local/bin/airflow', 'webserver']"}
196	2025-01-15 05:47:45.566405+00	\N	\N	\N	cli_scheduler	\N	airflow	{"host_name": "d9bc3a52c618", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}
197	2025-01-15 05:47:46.097339+00	\N	\N	\N	cli_users_create	\N	airflow	{"host_name": "eab0e56bdcb5", "full_command": "['/home/airflow/.local/bin/airflow', 'users', 'create', '--username', 'admin', '--password', '********', '--firstname', 'Admin', '--lastname', 'User', '--role', 'Admin', '--email', 'admin@example.co']"}
198	2025-01-15 05:52:01.712423+00	\N	\N	\N	cli_migratedb	\N	airflow	{"host_name": "fc4107f1308e", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'upgrade']"}
199	2025-01-15 05:52:04.929966+00	\N	\N	\N	cli_users_create	\N	airflow	{"host_name": "fc4107f1308e", "full_command": "['/home/airflow/.local/bin/airflow', 'users', 'create', '--username', 'admin', '--password', '********', '--firstname', 'Admin', '--lastname', 'User', '--role', 'Admin', '--email', 'admin@example.co']"}
200	2025-01-15 05:53:18.482474+00	\N	\N	\N	cli_migratedb	\N	airflow	{"host_name": "fe149e6d182e", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'upgrade']"}
201	2025-01-15 05:53:22.280288+00	\N	\N	\N	cli_users_create	\N	airflow	{"host_name": "fe149e6d182e", "full_command": "['/home/airflow/.local/bin/airflow', 'users', 'create', '--username', 'admin', '--password', '********', '--firstname', 'Admin', '--lastname', 'User', '--role', 'Admin', '--email', 'admin@example.co']"}
203	2025-01-15 05:58:12.482506+00	\N	\N	\N	cli_check	\N	root	{"host_name": "bc345d861b4b", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
202	2025-01-15 05:58:12.482183+00	\N	\N	\N	cli_check	\N	root	{"host_name": "d72ccb2b6125", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
204	2025-01-15 05:58:13.264257+00	\N	\N	\N	cli_webserver	\N	root	{"host_name": "bc345d861b4b", "full_command": "['/home/airflow/.local/bin/airflow', 'webserver']"}
205	2025-01-15 05:58:13.25444+00	\N	\N	\N	cli_webserver	\N	root	{"host_name": "d72ccb2b6125", "full_command": "['/home/airflow/.local/bin/airflow', 'webserver']"}
206	2025-01-15 06:04:45.598242+00	\N	\N	\N	cli_check	\N	root	{"host_name": "991554754f7b", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
207	2025-01-15 06:04:45.817317+00	\N	\N	\N	cli_check	\N	root	{"host_name": "7386904eb5a7", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
208	2025-01-15 06:04:46.341745+00	\N	\N	\N	cli_webserver	\N	root	{"host_name": "991554754f7b", "full_command": "['/home/airflow/.local/bin/airflow', 'webserver']"}
209	2025-01-15 06:04:46.455942+00	\N	\N	\N	cli_webserver	\N	root	{"host_name": "7386904eb5a7", "full_command": "['/home/airflow/.local/bin/airflow', 'webserver']"}
210	2025-01-15 06:07:05.663948+00	\N	\N	\N	cli_check	\N	root	{"host_name": "f9917102d816", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
211	2025-01-15 06:07:05.665339+00	\N	\N	\N	cli_check	\N	root	{"host_name": "acf43f70c8ad", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
212	2025-01-15 06:07:06.664341+00	\N	\N	\N	cli_webserver	\N	root	{"host_name": "acf43f70c8ad", "full_command": "['/home/airflow/.local/bin/airflow', 'webserver']"}
213	2025-01-15 06:07:06.682893+00	\N	\N	\N	cli_webserver	\N	root	{"host_name": "f9917102d816", "full_command": "['/home/airflow/.local/bin/airflow', 'webserver']"}
215	2025-01-15 06:10:21.71158+00	\N	\N	\N	cli_check	\N	root	{"host_name": "c1d6ff6ab334", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
214	2025-01-15 06:10:21.711659+00	\N	\N	\N	cli_check	\N	root	{"host_name": "a04c40c28b61", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
216	2025-01-15 06:10:22.231595+00	\N	\N	\N	cli_webserver	\N	root	{"host_name": "c1d6ff6ab334", "full_command": "['/home/airflow/.local/bin/airflow', 'webserver']"}
217	2025-01-15 06:10:22.232795+00	\N	\N	\N	cli_webserver	\N	root	{"host_name": "a04c40c28b61", "full_command": "['/home/airflow/.local/bin/airflow', 'webserver']"}
218	2025-01-15 06:17:16.215513+00	\N	\N	\N	cli_check	\N	root	{"host_name": "0c219738cd48", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
219	2025-01-15 06:17:16.224975+00	\N	\N	\N	cli_check	\N	root	{"host_name": "a14ef8e636fc", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
220	2025-01-15 06:17:16.885501+00	\N	\N	\N	cli_webserver	\N	root	{"host_name": "0c219738cd48", "full_command": "['/home/airflow/.local/bin/airflow', 'webserver']"}
221	2025-01-15 06:17:16.889085+00	\N	\N	\N	cli_webserver	\N	root	{"host_name": "a14ef8e636fc", "full_command": "['/home/airflow/.local/bin/airflow', 'webserver']"}
222	2025-01-15 06:21:01.97305+00	\N	\N	\N	cli_check	\N	root	{"host_name": "01ccf3929216", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
223	2025-01-15 06:21:02.015495+00	\N	\N	\N	cli_check	\N	root	{"host_name": "2357e8d14f84", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
224	2025-01-15 06:21:02.755373+00	\N	\N	\N	cli_webserver	\N	root	{"host_name": "01ccf3929216", "full_command": "['/home/airflow/.local/bin/airflow', 'webserver']"}
225	2025-01-15 06:21:02.776987+00	\N	\N	\N	cli_webserver	\N	root	{"host_name": "2357e8d14f84", "full_command": "['/home/airflow/.local/bin/airflow', 'webserver']"}
226	2025-01-15 06:21:48.742171+00	job_scraper	\N	\N	delete	\N	Admin User	[('dag_id', 'job_scraper'), ('redirect_url', '/home')]
\.


--
-- Data for Name: log_template; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.log_template (id, filename, elasticsearch_id, created_at) FROM stdin;
1	{{ ti.dag_id }}/{{ ti.task_id }}/{{ ts }}/{{ try_number }}.log	{dag_id}-{task_id}-{execution_date}-{try_number}	2025-01-15 05:17:29.412452+00
2	dag_id={{ ti.dag_id }}/run_id={{ ti.run_id }}/task_id={{ ti.task_id }}/{% if ti.map_index >= 0 %}map_index={{ ti.map_index }}/{% endif %}attempt={{ try_number }}.log	{dag_id}-{task_id}-{run_id}-{map_index}-{try_number}	2025-01-15 05:17:29.412463+00
\.


--
-- Data for Name: rendered_task_instance_fields; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rendered_task_instance_fields (dag_id, task_id, run_id, map_index, rendered_fields, k8s_pod_yaml) FROM stdin;
indeed_python_developer_scraper	scrape_indeed_python_developer	scheduled__2025-01-14T15:00:00+00:00	-1	{"image": "scraper:latest", "command": "python -m app.scrapers.scraper_main --source indeed --category python_developer --max_pages 20", "environment": {"DATABASE_HOSTNAME": "db", "DATABASE_PORT": "5432", "DATABASE_USERNAME": "postgres", "DATABASE_PASSWORD": "***", "DATABASE_NAME": "job_postings", "FLARESOLVERR_URL": "http://flaresolverr:8191/v1", "PYTHONUNBUFFERED": "1", "LINKEDIN_EMAIL": "woodenkim25@gmail.com", "LINKEDIN_PASSWORD": "***"}, "env_file": null, "container_name": null}	null
indeed_python_developer_scraper	scrape_indeed_python_developer	manual__2025-01-15T05:19:06.506037+00:00	-1	{"image": "scraper:latest", "command": "python -m app.scrapers.scraper_main --source indeed --category python_developer --max_pages 20", "environment": {"DATABASE_HOSTNAME": "db", "DATABASE_PORT": "5432", "DATABASE_USERNAME": "postgres", "DATABASE_PASSWORD": "***", "DATABASE_NAME": "job_postings", "FLARESOLVERR_URL": "http://flaresolverr:8191/v1", "PYTHONUNBUFFERED": "1", "LINKEDIN_EMAIL": "woodenkim25@gmail.com", "LINKEDIN_PASSWORD": "***"}, "env_file": null, "container_name": null}	null
\.


--
-- Data for Name: serialized_dag; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.serialized_dag (dag_id, fileloc, fileloc_hash, data, data_compressed, last_updated, dag_hash, processor_subdir) FROM stdin;
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session (id, session_id, data, expiry) FROM stdin;
1	9b3812a4-365e-4271-861f-61b59f9ebfe7	\\x80049563000000000000007d94288c0a5f7065726d616e656e7494888c065f667265736894898c0a637372665f746f6b656e948c2865656631623539643832356238393733653233653766336130613932653135383030383162643738948c066c6f63616c65948c02656e94752e	2025-02-14 05:17:46.641778
35	db5a698d-d47a-4a23-8d11-737a3b05aeb2	\\x80049505020000000000007d94288c0a5f7065726d616e656e7494888c0a637372665f746f6b656e948c2865656631623539643832356238393733653233653766336130613932653135383030383162643738948c066c6f63616c65948c02656e948c116461675f7374617475735f66696c746572948c03616c6c948c0c706167655f686973746f7279945d94288c24687474703a2f2f6c6f63616c686f73743a383038302f7661726961626c652f6c6973742f948cb5687474703a2f2f6c6f63616c686f73743a383038302f7461736b696e7374616e63652f6c6973742f3f5f666c745f335f6461675f69643d696e646565645f707974686f6e5f646576656c6f7065725f73637261706572265f666c745f335f7461736b5f69643d7363726170655f696e646565645f707974686f6e5f646576656c6f706572265f6f635f5461736b496e7374616e63654d6f64656c566965773d6461675f72756e2e657865637574696f6e5f6461746594658c065f667265736894888c085f757365725f6964944b018c035f6964948c80326261366634633731303731653765663966373835356438383334323237336162316438626430633464663564666238623230643938616434333736613730343939376330333834343331393465383261383032613063326262616533313633633934656666633135383337323638323136363966623863616664376433663294752e	2025-02-14 06:22:03.240902
2	07c97034-5436-44e2-bedd-cb08dc89d91f	\\x8004956f010000000000007d94288c0a5f7065726d616e656e7494888c0a637372665f746f6b656e948c2865656631623539643832356238393733653233653766336130613932653135383030383162643738948c066c6f63616c65948c02656e948c116461675f7374617475735f66696c746572948c03616c6c948c0c706167655f686973746f7279945d94288c24687474703a2f2f6c6f63616c686f73743a383038302f7661726961626c652f6c6973742f948cb5687474703a2f2f6c6f63616c686f73743a383038302f7461736b696e7374616e63652f6c6973742f3f5f666c745f335f6461675f69643d696e646565645f707974686f6e5f646576656c6f7065725f73637261706572265f666c745f335f7461736b5f69643d7363726170655f696e646565645f707974686f6e5f646576656c6f706572265f6f635f5461736b496e7374616e63654d6f64656c566965773d6461675f72756e2e657865637574696f6e5f6461746594658c065f66726573689489752e	2025-02-14 06:03:37.81664
34	a2291129-f92b-4183-b3ae-2c6faed6687d	\\x8004956f010000000000007d94288c0a5f7065726d616e656e7494888c0a637372665f746f6b656e948c2865656631623539643832356238393733653233653766336130613932653135383030383162643738948c066c6f63616c65948c02656e948c116461675f7374617475735f66696c746572948c03616c6c948c0c706167655f686973746f7279945d94288c24687474703a2f2f6c6f63616c686f73743a383038302f7661726961626c652f6c6973742f948cb5687474703a2f2f6c6f63616c686f73743a383038302f7461736b696e7374616e63652f6c6973742f3f5f666c745f335f6461675f69643d696e646565645f707974686f6e5f646576656c6f7065725f73637261706572265f666c745f335f7461736b5f69643d7363726170655f696e646565645f707974686f6e5f646576656c6f706572265f6f635f5461736b496e7374616e63654d6f64656c566965773d6461675f72756e2e657865637574696f6e5f6461746594658c065f66726573689489752e	2025-02-14 06:21:57.613554
\.


--
-- Data for Name: sla_miss; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sla_miss (task_id, dag_id, execution_date, email_sent, "timestamp", description, notification_sent) FROM stdin;
\.


--
-- Data for Name: slot_pool; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slot_pool (id, pool, slots, description, include_deferred) FROM stdin;
1	default_pool	128	Default pool	f
\.


--
-- Data for Name: task_fail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_fail (id, task_id, dag_id, run_id, map_index, start_date, end_date, duration) FROM stdin;
13	scrape_indeed_python_developer	indeed_python_developer_scraper	scheduled__2025-01-14T15:00:00+00:00	-1	2025-01-15 05:19:08.732705+00	2025-01-15 05:19:08.995295+00	0
46	scrape_indeed_python_developer	indeed_python_developer_scraper	scheduled__2025-01-14T15:00:00+00:00	-1	2025-01-15 05:24:11.395989+00	2025-01-15 05:24:11.604572+00	0
47	scrape_indeed_python_developer	indeed_python_developer_scraper	manual__2025-01-15T05:19:06.506037+00:00	-1	2025-01-15 05:24:14.369679+00	2025-01-15 05:24:14.558585+00	0
\.


--
-- Data for Name: task_instance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_instance (task_id, dag_id, run_id, map_index, start_date, end_date, duration, state, try_number, max_tries, hostname, unixname, job_id, pool, pool_slots, queue, priority_weight, operator, custom_operator_name, queued_dttm, queued_by_job_id, pid, executor_config, updated_at, external_executor_id, trigger_id, trigger_timeout, next_method, next_kwargs) FROM stdin;
scrape_indeed_python_developer	indeed_python_developer_scraper	scheduled__2025-01-14T15:00:00+00:00	-1	2025-01-15 05:24:11.395989+00	2025-01-15 05:24:11.604572+00	0.208583	failed	2	1	494f1446d77e	airflow	47	default_pool	1	default	1	DockerOperator	\N	2025-01-15 05:24:09.765548+00	34	125	\\x80057d942e	2025-01-15 05:24:11.405221+00	\N	\N	\N	\N	\N
scrape_indeed_python_developer	indeed_python_developer_scraper	manual__2025-01-15T05:19:06.506037+00:00	-1	2025-01-15 05:24:14.369679+00	2025-01-15 05:24:14.558585+00	0.188906	up_for_retry	1	1	494f1446d77e	airflow	48	default_pool	1	default	1	DockerOperator	\N	2025-01-15 05:24:12.982518+00	34	131	\\x80057d942e	2025-01-15 05:24:14.378384+00	\N	\N	\N	\N	\N
\.


--
-- Data for Name: task_instance_note; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_instance_note (user_id, task_id, dag_id, run_id, map_index, content, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: task_map; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_map (dag_id, task_id, run_id, map_index, length, keys) FROM stdin;
\.


--
-- Data for Name: task_outlet_dataset_reference; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_outlet_dataset_reference (dataset_id, dag_id, task_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: task_reschedule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_reschedule (id, task_id, dag_id, run_id, map_index, try_number, start_date, end_date, duration, reschedule_date) FROM stdin;
\.


--
-- Data for Name: trigger; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.trigger (id, classpath, kwargs, created_date, triggerer_id) FROM stdin;
\.


--
-- Data for Name: variable; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.variable (id, key, val, description, is_encrypted) FROM stdin;
1	DATABASE_USERNAME	postgres		f
2	DATABASE_PASSWORD	sozjavbxj		f
3	LINKEDIN_EMAIL	woodenkim25@gmail.com		f
4	LINKEDIN_PASSWORD	asdf1452		f
\.


--
-- Data for Name: xcom; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.xcom (dag_run_id, task_id, map_index, key, dag_id, run_id, value, "timestamp") FROM stdin;
\.


--
-- Name: ab_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_permission_id_seq', 33, true);


--
-- Name: ab_permission_view_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_permission_view_id_seq', 165, true);


--
-- Name: ab_permission_view_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_permission_view_role_id_seq', 231, true);


--
-- Name: ab_register_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_register_user_id_seq', 1, false);


--
-- Name: ab_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_role_id_seq', 33, true);


--
-- Name: ab_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_user_id_seq', 33, true);


--
-- Name: ab_user_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_user_role_id_seq', 33, true);


--
-- Name: ab_view_menu_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ab_view_menu_id_seq', 66, true);


--
-- Name: callback_request_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.callback_request_id_seq', 1, false);


--
-- Name: connection_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.connection_id_seq', 1, false);


--
-- Name: dag_pickle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dag_pickle_id_seq', 1, false);


--
-- Name: dag_run_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dag_run_id_seq', 33, true);


--
-- Name: dataset_event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dataset_event_id_seq', 1, false);


--
-- Name: dataset_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dataset_id_seq', 1, false);


--
-- Name: import_error_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.import_error_id_seq', 1, true);


--
-- Name: job_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_id_seq', 54, true);


--
-- Name: log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.log_id_seq', 226, true);


--
-- Name: log_template_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.log_template_id_seq', 33, true);


--
-- Name: session_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.session_id_seq', 35, true);


--
-- Name: slot_pool_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.slot_pool_id_seq', 33, true);


--
-- Name: task_fail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.task_fail_id_seq', 47, true);


--
-- Name: task_reschedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.task_reschedule_id_seq', 1, false);


--
-- Name: trigger_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.trigger_id_seq', 1, false);


--
-- Name: variable_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.variable_id_seq', 33, true);


--
-- Name: ab_permission ab_permission_name_uq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission
    ADD CONSTRAINT ab_permission_name_uq UNIQUE (name);


--
-- Name: ab_permission ab_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission
    ADD CONSTRAINT ab_permission_pkey PRIMARY KEY (id);


--
-- Name: ab_permission_view ab_permission_view_permission_id_view_menu_id_uq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_permission_id_view_menu_id_uq UNIQUE (permission_id, view_menu_id);


--
-- Name: ab_permission_view ab_permission_view_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_pkey PRIMARY KEY (id);


--
-- Name: ab_permission_view_role ab_permission_view_role_permission_view_id_role_id_uq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_permission_view_id_role_id_uq UNIQUE (permission_view_id, role_id);


--
-- Name: ab_permission_view_role ab_permission_view_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_pkey PRIMARY KEY (id);


--
-- Name: ab_register_user ab_register_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_register_user
    ADD CONSTRAINT ab_register_user_pkey PRIMARY KEY (id);


--
-- Name: ab_register_user ab_register_user_username_uq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_register_user
    ADD CONSTRAINT ab_register_user_username_uq UNIQUE (username);


--
-- Name: ab_role ab_role_name_uq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_role
    ADD CONSTRAINT ab_role_name_uq UNIQUE (name);


--
-- Name: ab_role ab_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_role
    ADD CONSTRAINT ab_role_pkey PRIMARY KEY (id);


--
-- Name: ab_user ab_user_email_uq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_email_uq UNIQUE (email);


--
-- Name: ab_user ab_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_pkey PRIMARY KEY (id);


--
-- Name: ab_user_role ab_user_role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_pkey PRIMARY KEY (id);


--
-- Name: ab_user_role ab_user_role_user_id_role_id_uq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_user_id_role_id_uq UNIQUE (user_id, role_id);


--
-- Name: ab_user ab_user_username_uq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_username_uq UNIQUE (username);


--
-- Name: ab_view_menu ab_view_menu_name_uq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_view_menu
    ADD CONSTRAINT ab_view_menu_name_uq UNIQUE (name);


--
-- Name: ab_view_menu ab_view_menu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_view_menu
    ADD CONSTRAINT ab_view_menu_pkey PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: callback_request callback_request_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.callback_request
    ADD CONSTRAINT callback_request_pkey PRIMARY KEY (id);


--
-- Name: connection connection_conn_id_uq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.connection
    ADD CONSTRAINT connection_conn_id_uq UNIQUE (conn_id);


--
-- Name: connection connection_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.connection
    ADD CONSTRAINT connection_pkey PRIMARY KEY (id);


--
-- Name: dag_code dag_code_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dag_code
    ADD CONSTRAINT dag_code_pkey PRIMARY KEY (fileloc_hash);


--
-- Name: dag_owner_attributes dag_owner_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dag_owner_attributes
    ADD CONSTRAINT dag_owner_attributes_pkey PRIMARY KEY (dag_id, owner);


--
-- Name: dag_pickle dag_pickle_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dag_pickle
    ADD CONSTRAINT dag_pickle_pkey PRIMARY KEY (id);


--
-- Name: dag dag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dag
    ADD CONSTRAINT dag_pkey PRIMARY KEY (dag_id);


--
-- Name: dag_run dag_run_dag_id_execution_date_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dag_run
    ADD CONSTRAINT dag_run_dag_id_execution_date_key UNIQUE (dag_id, execution_date);


--
-- Name: dag_run dag_run_dag_id_run_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dag_run
    ADD CONSTRAINT dag_run_dag_id_run_id_key UNIQUE (dag_id, run_id);


--
-- Name: dag_run_note dag_run_note_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dag_run_note
    ADD CONSTRAINT dag_run_note_pkey PRIMARY KEY (dag_run_id);


--
-- Name: dag_run dag_run_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dag_run
    ADD CONSTRAINT dag_run_pkey PRIMARY KEY (id);


--
-- Name: dag_tag dag_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dag_tag
    ADD CONSTRAINT dag_tag_pkey PRIMARY KEY (name, dag_id);


--
-- Name: dag_warning dag_warning_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dag_warning
    ADD CONSTRAINT dag_warning_pkey PRIMARY KEY (dag_id, warning_type);


--
-- Name: dagrun_dataset_event dagrun_dataset_event_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dagrun_dataset_event
    ADD CONSTRAINT dagrun_dataset_event_pkey PRIMARY KEY (dag_run_id, event_id);


--
-- Name: dataset_event dataset_event_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dataset_event
    ADD CONSTRAINT dataset_event_pkey PRIMARY KEY (id);


--
-- Name: dataset dataset_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT dataset_pkey PRIMARY KEY (id);


--
-- Name: dataset_dag_run_queue datasetdagrunqueue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dataset_dag_run_queue
    ADD CONSTRAINT datasetdagrunqueue_pkey PRIMARY KEY (dataset_id, target_dag_id);


--
-- Name: dag_schedule_dataset_reference dsdr_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dag_schedule_dataset_reference
    ADD CONSTRAINT dsdr_pkey PRIMARY KEY (dataset_id, dag_id);


--
-- Name: import_error import_error_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.import_error
    ADD CONSTRAINT import_error_pkey PRIMARY KEY (id);


--
-- Name: job job_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job
    ADD CONSTRAINT job_pkey PRIMARY KEY (id);


--
-- Name: log log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log
    ADD CONSTRAINT log_pkey PRIMARY KEY (id);


--
-- Name: log_template log_template_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_template
    ADD CONSTRAINT log_template_pkey PRIMARY KEY (id);


--
-- Name: rendered_task_instance_fields rendered_task_instance_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rendered_task_instance_fields
    ADD CONSTRAINT rendered_task_instance_fields_pkey PRIMARY KEY (dag_id, task_id, run_id, map_index);


--
-- Name: serialized_dag serialized_dag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serialized_dag
    ADD CONSTRAINT serialized_dag_pkey PRIMARY KEY (dag_id);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (id);


--
-- Name: session session_session_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_session_id_key UNIQUE (session_id);


--
-- Name: sla_miss sla_miss_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sla_miss
    ADD CONSTRAINT sla_miss_pkey PRIMARY KEY (task_id, dag_id, execution_date);


--
-- Name: slot_pool slot_pool_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slot_pool
    ADD CONSTRAINT slot_pool_pkey PRIMARY KEY (id);


--
-- Name: slot_pool slot_pool_pool_uq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slot_pool
    ADD CONSTRAINT slot_pool_pool_uq UNIQUE (pool);


--
-- Name: task_fail task_fail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_fail
    ADD CONSTRAINT task_fail_pkey PRIMARY KEY (id);


--
-- Name: task_instance_note task_instance_note_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_instance_note
    ADD CONSTRAINT task_instance_note_pkey PRIMARY KEY (task_id, dag_id, run_id, map_index);


--
-- Name: task_instance task_instance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_instance
    ADD CONSTRAINT task_instance_pkey PRIMARY KEY (dag_id, task_id, run_id, map_index);


--
-- Name: task_map task_map_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_map
    ADD CONSTRAINT task_map_pkey PRIMARY KEY (dag_id, task_id, run_id, map_index);


--
-- Name: task_reschedule task_reschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_reschedule
    ADD CONSTRAINT task_reschedule_pkey PRIMARY KEY (id);


--
-- Name: task_outlet_dataset_reference todr_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_outlet_dataset_reference
    ADD CONSTRAINT todr_pkey PRIMARY KEY (dataset_id, dag_id, task_id);


--
-- Name: trigger trigger_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trigger
    ADD CONSTRAINT trigger_pkey PRIMARY KEY (id);


--
-- Name: variable variable_key_uq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.variable
    ADD CONSTRAINT variable_key_uq UNIQUE (key);


--
-- Name: variable variable_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.variable
    ADD CONSTRAINT variable_pkey PRIMARY KEY (id);


--
-- Name: xcom xcom_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.xcom
    ADD CONSTRAINT xcom_pkey PRIMARY KEY (dag_run_id, task_id, map_index, key);


--
-- Name: dag_id_state; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dag_id_state ON public.dag_run USING btree (dag_id, state);


--
-- Name: idx_ab_register_user_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_ab_register_user_username ON public.ab_register_user USING btree (lower((username)::text));


--
-- Name: idx_ab_user_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_ab_user_username ON public.ab_user USING btree (lower((username)::text));


--
-- Name: idx_dag_run_dag_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dag_run_dag_id ON public.dag_run USING btree (dag_id);


--
-- Name: idx_dag_run_queued_dags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dag_run_queued_dags ON public.dag_run USING btree (state, dag_id) WHERE ((state)::text = 'queued'::text);


--
-- Name: idx_dag_run_running_dags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dag_run_running_dags ON public.dag_run USING btree (state, dag_id) WHERE ((state)::text = 'running'::text);


--
-- Name: idx_dagrun_dataset_events_dag_run_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dagrun_dataset_events_dag_run_id ON public.dagrun_dataset_event USING btree (dag_run_id);


--
-- Name: idx_dagrun_dataset_events_event_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dagrun_dataset_events_event_id ON public.dagrun_dataset_event USING btree (event_id);


--
-- Name: idx_dataset_id_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dataset_id_timestamp ON public.dataset_event USING btree (dataset_id, "timestamp");


--
-- Name: idx_fileloc_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_fileloc_hash ON public.serialized_dag USING btree (fileloc_hash);


--
-- Name: idx_job_dag_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_job_dag_id ON public.job USING btree (dag_id);


--
-- Name: idx_job_state_heartbeat; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_job_state_heartbeat ON public.job USING btree (state, latest_heartbeat);


--
-- Name: idx_last_scheduling_decision; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_last_scheduling_decision ON public.dag_run USING btree (last_scheduling_decision);


--
-- Name: idx_log_dag; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_log_dag ON public.log USING btree (dag_id);


--
-- Name: idx_log_dttm; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_log_dttm ON public.log USING btree (dttm);


--
-- Name: idx_log_event; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_log_event ON public.log USING btree (event);


--
-- Name: idx_next_dagrun_create_after; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_next_dagrun_create_after ON public.dag USING btree (next_dagrun_create_after);


--
-- Name: idx_root_dag_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_root_dag_id ON public.dag USING btree (root_dag_id);


--
-- Name: idx_task_fail_task_instance; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_fail_task_instance ON public.task_fail USING btree (dag_id, task_id, run_id, map_index);


--
-- Name: idx_task_reschedule_dag_run; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_reschedule_dag_run ON public.task_reschedule USING btree (dag_id, run_id);


--
-- Name: idx_task_reschedule_dag_task_run; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_task_reschedule_dag_task_run ON public.task_reschedule USING btree (dag_id, task_id, run_id, map_index);


--
-- Name: idx_uri_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_uri_unique ON public.dataset USING btree (uri);


--
-- Name: idx_xcom_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_xcom_key ON public.xcom USING btree (key);


--
-- Name: idx_xcom_task_instance; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_xcom_task_instance ON public.xcom USING btree (dag_id, task_id, run_id, map_index);


--
-- Name: job_type_heart; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX job_type_heart ON public.job USING btree (job_type, latest_heartbeat);


--
-- Name: sm_dag; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sm_dag ON public.sla_miss USING btree (dag_id);


--
-- Name: ti_dag_run; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ti_dag_run ON public.task_instance USING btree (dag_id, run_id);


--
-- Name: ti_dag_state; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ti_dag_state ON public.task_instance USING btree (dag_id, state);


--
-- Name: ti_job_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ti_job_id ON public.task_instance USING btree (job_id);


--
-- Name: ti_pool; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ti_pool ON public.task_instance USING btree (pool, state, priority_weight);


--
-- Name: ti_state; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ti_state ON public.task_instance USING btree (state);


--
-- Name: ti_state_incl_start_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ti_state_incl_start_date ON public.task_instance USING btree (dag_id, task_id, state) INCLUDE (start_date);


--
-- Name: ti_state_lkp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ti_state_lkp ON public.task_instance USING btree (dag_id, task_id, run_id, state);


--
-- Name: ti_trigger_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ti_trigger_id ON public.task_instance USING btree (trigger_id);


--
-- Name: ab_permission_view ab_permission_view_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.ab_permission(id);


--
-- Name: ab_permission_view_role ab_permission_view_role_permission_view_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_permission_view_id_fkey FOREIGN KEY (permission_view_id) REFERENCES public.ab_permission_view(id);


--
-- Name: ab_permission_view_role ab_permission_view_role_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.ab_role(id);


--
-- Name: ab_permission_view ab_permission_view_view_menu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_view_menu_id_fkey FOREIGN KEY (view_menu_id) REFERENCES public.ab_view_menu(id);


--
-- Name: ab_user ab_user_changed_by_fk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_changed_by_fk_fkey FOREIGN KEY (changed_by_fk) REFERENCES public.ab_user(id);


--
-- Name: ab_user ab_user_created_by_fk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_created_by_fk_fkey FOREIGN KEY (created_by_fk) REFERENCES public.ab_user(id);


--
-- Name: ab_user_role ab_user_role_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.ab_role(id);


--
-- Name: ab_user_role ab_user_role_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.ab_user(id);


--
-- Name: dag_owner_attributes dag.dag_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dag_owner_attributes
    ADD CONSTRAINT "dag.dag_id" FOREIGN KEY (dag_id) REFERENCES public.dag(dag_id) ON DELETE CASCADE;


--
-- Name: dag_run_note dag_run_note_dr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dag_run_note
    ADD CONSTRAINT dag_run_note_dr_fkey FOREIGN KEY (dag_run_id) REFERENCES public.dag_run(id) ON DELETE CASCADE;


--
-- Name: dag_run_note dag_run_note_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dag_run_note
    ADD CONSTRAINT dag_run_note_user_fkey FOREIGN KEY (user_id) REFERENCES public.ab_user(id);


--
-- Name: dag_tag dag_tag_dag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dag_tag
    ADD CONSTRAINT dag_tag_dag_id_fkey FOREIGN KEY (dag_id) REFERENCES public.dag(dag_id) ON DELETE CASCADE;


--
-- Name: dagrun_dataset_event dagrun_dataset_event_dag_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dagrun_dataset_event
    ADD CONSTRAINT dagrun_dataset_event_dag_run_id_fkey FOREIGN KEY (dag_run_id) REFERENCES public.dag_run(id) ON DELETE CASCADE;


--
-- Name: dagrun_dataset_event dagrun_dataset_event_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dagrun_dataset_event
    ADD CONSTRAINT dagrun_dataset_event_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.dataset_event(id) ON DELETE CASCADE;


--
-- Name: dag_warning dcw_dag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dag_warning
    ADD CONSTRAINT dcw_dag_id_fkey FOREIGN KEY (dag_id) REFERENCES public.dag(dag_id) ON DELETE CASCADE;


--
-- Name: dataset_dag_run_queue ddrq_dag_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dataset_dag_run_queue
    ADD CONSTRAINT ddrq_dag_fkey FOREIGN KEY (target_dag_id) REFERENCES public.dag(dag_id) ON DELETE CASCADE;


--
-- Name: dataset_dag_run_queue ddrq_dataset_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dataset_dag_run_queue
    ADD CONSTRAINT ddrq_dataset_fkey FOREIGN KEY (dataset_id) REFERENCES public.dataset(id) ON DELETE CASCADE;


--
-- Name: dag_schedule_dataset_reference dsdr_dag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dag_schedule_dataset_reference
    ADD CONSTRAINT dsdr_dag_id_fkey FOREIGN KEY (dag_id) REFERENCES public.dag(dag_id) ON DELETE CASCADE;


--
-- Name: dag_schedule_dataset_reference dsdr_dataset_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dag_schedule_dataset_reference
    ADD CONSTRAINT dsdr_dataset_fkey FOREIGN KEY (dataset_id) REFERENCES public.dataset(id) ON DELETE CASCADE;


--
-- Name: rendered_task_instance_fields rtif_ti_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rendered_task_instance_fields
    ADD CONSTRAINT rtif_ti_fkey FOREIGN KEY (dag_id, task_id, run_id, map_index) REFERENCES public.task_instance(dag_id, task_id, run_id, map_index) ON DELETE CASCADE;


--
-- Name: task_fail task_fail_ti_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_fail
    ADD CONSTRAINT task_fail_ti_fkey FOREIGN KEY (dag_id, task_id, run_id, map_index) REFERENCES public.task_instance(dag_id, task_id, run_id, map_index) ON DELETE CASCADE;


--
-- Name: task_instance task_instance_dag_run_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_instance
    ADD CONSTRAINT task_instance_dag_run_fkey FOREIGN KEY (dag_id, run_id) REFERENCES public.dag_run(dag_id, run_id) ON DELETE CASCADE;


--
-- Name: dag_run task_instance_log_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dag_run
    ADD CONSTRAINT task_instance_log_template_id_fkey FOREIGN KEY (log_template_id) REFERENCES public.log_template(id);


--
-- Name: task_instance_note task_instance_note_ti_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_instance_note
    ADD CONSTRAINT task_instance_note_ti_fkey FOREIGN KEY (dag_id, task_id, run_id, map_index) REFERENCES public.task_instance(dag_id, task_id, run_id, map_index) ON DELETE CASCADE;


--
-- Name: task_instance_note task_instance_note_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_instance_note
    ADD CONSTRAINT task_instance_note_user_fkey FOREIGN KEY (user_id) REFERENCES public.ab_user(id);


--
-- Name: task_instance task_instance_trigger_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_instance
    ADD CONSTRAINT task_instance_trigger_id_fkey FOREIGN KEY (trigger_id) REFERENCES public.trigger(id) ON DELETE CASCADE;


--
-- Name: task_map task_map_task_instance_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_map
    ADD CONSTRAINT task_map_task_instance_fkey FOREIGN KEY (dag_id, task_id, run_id, map_index) REFERENCES public.task_instance(dag_id, task_id, run_id, map_index) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: task_reschedule task_reschedule_dr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_reschedule
    ADD CONSTRAINT task_reschedule_dr_fkey FOREIGN KEY (dag_id, run_id) REFERENCES public.dag_run(dag_id, run_id) ON DELETE CASCADE;


--
-- Name: task_reschedule task_reschedule_ti_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_reschedule
    ADD CONSTRAINT task_reschedule_ti_fkey FOREIGN KEY (dag_id, task_id, run_id, map_index) REFERENCES public.task_instance(dag_id, task_id, run_id, map_index) ON DELETE CASCADE;


--
-- Name: task_outlet_dataset_reference todr_dag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_outlet_dataset_reference
    ADD CONSTRAINT todr_dag_id_fkey FOREIGN KEY (dag_id) REFERENCES public.dag(dag_id) ON DELETE CASCADE;


--
-- Name: task_outlet_dataset_reference todr_dataset_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_outlet_dataset_reference
    ADD CONSTRAINT todr_dataset_fkey FOREIGN KEY (dataset_id) REFERENCES public.dataset(id) ON DELETE CASCADE;


--
-- Name: xcom xcom_task_instance_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.xcom
    ADD CONSTRAINT xcom_task_instance_fkey FOREIGN KEY (dag_id, task_id, run_id, map_index) REFERENCES public.task_instance(dag_id, task_id, run_id, map_index) ON DELETE CASCADE;


--
-- Name: DATABASE airflow; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON DATABASE airflow TO airflow;


--
-- PostgreSQL database dump complete
--

--
-- Database "job_postings" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 15.10 (Debian 15.10-1.pgdg120+1)
-- Dumped by pg_dump version 15.10 (Debian 15.10-1.pgdg120+1)

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
-- Name: job_postings; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE job_postings WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE job_postings OWNER TO postgres;

\connect job_postings

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
-- Name: jobcategory; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.jobcategory AS ENUM (
    'DATA_ENGINEER',
    'DATA_SCIENTIST',
    'SOFTWARE_ENGINEER',
    'PYTHON_DEVELOPER',
    'MACHINE_LEARNING_ENGINEER',
    'DATA_ANALYST',
    'BUSINESS_INTELLIGENCE',
    'DATABASE_ADMINISTRATOR',
    'DEVOPS_ENGINEER',
    'OTHERS'
);


ALTER TYPE public.jobcategory OWNER TO postgres;

--
-- Name: jobsource; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.jobsource AS ENUM (
    'INDEED',
    'LINKEDIN',
    'GLASSDOOR',
    'BUILTINCHICAGO',
    'OTHERS'
);


ALTER TYPE public.jobsource OWNER TO postgres;

--
-- Name: jobstatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.jobstatus AS ENUM (
    'NEW',
    'APPLIED',
    'SKIPPED',
    'PHONE_SCREEN',
    'TECHNICAL',
    'ONSITE',
    'OFFER',
    'REJECTED'
);


ALTER TYPE public.jobstatus OWNER TO postgres;

--
-- Name: jobtype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.jobtype AS ENUM (
    'FULL_TIME',
    'PART_TIME',
    'CONTRACT',
    'TEMPORARY',
    'INTERNSHIP'
);


ALTER TYPE public.jobtype OWNER TO postgres;

--
-- Name: remotestatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.remotestatus AS ENUM (
    'REMOTE',
    'HYBRID',
    'ONSITE'
);


ALTER TYPE public.remotestatus OWNER TO postgres;

--
-- Name: salarytype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.salarytype AS ENUM (
    'HOURLY',
    'YEARLY',
    'MONTHLY',
    'DAILY',
    'WEEKLY',
    'CONTRACT'
);


ALTER TYPE public.salarytype OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: processed_jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.processed_jobs (
    id integer NOT NULL,
    raw_job_post_id integer,
    job_url character varying NOT NULL,
    title character varying NOT NULL,
    company character varying NOT NULL,
    description character varying NOT NULL,
    date_posted timestamp with time zone,
    location_raw character varying,
    latitude numeric(9,6),
    longitude numeric(9,6),
    salary_type public.salarytype,
    salary_min numeric(10,2),
    salary_max numeric(10,2),
    salary_currency character varying(3),
    requirements character varying,
    benefits character varying,
    job_type public.jobtype,
    experience_level character varying,
    remote_status public.remotestatus,
    status public.jobstatus NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('America/Chicago'::text, CURRENT_TIMESTAMP),
    updated_at timestamp with time zone
);


ALTER TABLE public.processed_jobs OWNER TO postgres;

--
-- Name: processed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.processed_jobs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.processed_jobs_id_seq OWNER TO postgres;

--
-- Name: processed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.processed_jobs_id_seq OWNED BY public.processed_jobs.id;


--
-- Name: raw_job_posts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.raw_job_posts (
    id integer NOT NULL,
    job_url character varying NOT NULL,
    raw_content character varying NOT NULL,
    source public.jobsource NOT NULL,
    job_category public.jobcategory,
    created_at timestamp with time zone DEFAULT timezone('America/Chicago'::text, CURRENT_TIMESTAMP),
    processed boolean,
    salary_text character varying,
    salary_from_api character varying
);


ALTER TABLE public.raw_job_posts OWNER TO postgres;

--
-- Name: raw_job_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.raw_job_posts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.raw_job_posts_id_seq OWNER TO postgres;

--
-- Name: raw_job_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.raw_job_posts_id_seq OWNED BY public.raw_job_posts.id;


--
-- Name: processed_jobs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.processed_jobs ALTER COLUMN id SET DEFAULT nextval('public.processed_jobs_id_seq'::regclass);


--
-- Name: raw_job_posts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.raw_job_posts ALTER COLUMN id SET DEFAULT nextval('public.raw_job_posts_id_seq'::regclass);


--
-- Data for Name: processed_jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.processed_jobs (id, raw_job_post_id, job_url, title, company, description, date_posted, location_raw, latitude, longitude, salary_type, salary_min, salary_max, salary_currency, requirements, benefits, job_type, experience_level, remote_status, status, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: raw_job_posts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.raw_job_posts (id, job_url, raw_content, source, job_category, created_at, processed, salary_text, salary_from_api) FROM stdin;
1	/rc/clk?jk=3581862403da61ad&bb=nVAi1dqOC2Ptfy5ocQiBhVtQlW-mMsvzbzxagkMtkZaTLifP6ZO1MFqefjsPdKXWWtu1Xf6NosYUiWB9DjJ9onH2r0tqBD9RQw_9lWmooHb0u7BXoVKe1DRXz2tx3UMx&xkcb=SoCG67M330bz7mSxXB0KbzkdCdPP&fccid=ddf865993c86c6dd&vjs=3	{"host_query_execution_result": {"data": {"jobData": {"__typename": "JobDataPayload", "results": [{"__typename": "JobDataResult", "trackingKey": "5-cmh1-3-1ihka0knng5gj801", "job": {"__typename": "Job", "key": "3581862403da61ad", "title": "Data Analytics Engineer I - IM Enterprise Data", "sourceEmployerName": "Christus Health", "datePublished": 1734674400000, "expired": false, "language": "en", "normalizedTitle": "data engineer", "refNum": "23200102", "expirationDate": null, "source": {"__typename": "JobSource", "key": "AAAAAYXD/qPUWC/CRY/izhXMYEUOW8l5EdcUf51amvvIhIOM6qJe5w==", "name": "CHRISTUS Health"}, "feed": {"__typename": "JobFeed", "key": "AAAAAQhkVgdtStIoApLvDL8XjcHGmsHYn8qbwuy0ZU57cr+2MPNthQ==", "isDradis": false, "feedSourceType": "EMPLOYER"}, "url": "https://careers.christushealth.org/opportunity/data-analytics-engineer-i-im-enterprise-data-232001?utm_campaign=Indeed", "dateOnIndeed": 1736910597000, "description": {"__typename": "JobDescription", "html": "<div><b>Description</b><p><b><br>\\nSummary:</b></p>\\n<p>The Data Analytics Engineer I is responsible for developing and maintaining data sets and visualizations. This role uses programming skills to build, customize, and manage integration tools, databases, and analytical systems. The Data Analytics Engineer I assists in designing and implementing solutions to integrate, process, and analyze large data sets, requiring knowledge of data and systems design, development, and analytics.</p>\\n<p><b>Responsibilities:</b></p><br>\\n<ul><li>Meets expectations of the applicable OneCHRISTUS Competencies: Leader of Self, Leader of Others, or Leader of Leaders.\\n</li><li>Assist in analyzing large data sets to identify trends and insights.\\n</li><li>Collaborate with other team members and engineers to design and implement data processing and integration solutions.\\n</li><li>Recommend data handling and processing improvements based on the latest technological advancements.\\n</li><li>Participate in projects that involve sorting, analyzing, processing, and integrating large amounts of data.\\n</li><li>Develop visualizations using various technologies to represent data findings effectively.\\n</li><li>Collaborate by developing software solutions in languages like Java, Python, C, HTML, and SQL.\\n</li><li>Participate in testing software solutions to ensure they meet functional requirements.\\n</li><li>Develop and maintain code bases across multiple programming languages, ensuring that programming tasks are completed effectively and efficiently.\\n</li><li>Responsible for documenting all development and data processing phases for future reference.\\n</li><li>Continuously learn and apply best practices in data analytics and software development.</li></ul>\\n<p><b>Job Requirements:</b></p><br>\\n<p><b>Education/Skills</b></p>\\n<ul><li><p>Bachelor&rsquo;s degree in computer science, engineering, math, or a related field is preferred.</p>\\n</li></ul><p><b>Experience</b></p>\\n<ul><li>0 - 1 years of analytics solutions or Healthcare IT experience preferred.\\n</li><li><p>\\nMicrosoft SQL Server environment experience is preferred.</p>\\n</li></ul><p><b>Licenses, Registrations, or Certifications</b></p>\\n<ul><li>Certifications in Hadoop or Java are preferred.</li></ul>\\n<p><b>Work Schedule:</b></p><br>\\n<p>TBD</p>\\n<p><b>Work Type:</b></p><br>\\n<p>Full Time</p><br>\\n<p></p>\\n<p><b>EEO is the law - click below for more information:</b></p>\\n<p>https://www.eeoc.gov/sites/default/files/2023-06/22-088_EEOC_KnowYourRights6.12ScreenRdr.pdf</p>\\n<p>We endeavor to make this site accessible to any and all users. If you would like to contact us regarding the accessibility of our website or need assistance completing the application process, please contact us at (844) 257-6925.</p></div>", "text": "Description\\n\\nSummary:\\n\\nThe Data Analytics Engineer I is responsible for developing and maintaining data sets and visualizations. This role uses programming skills to build, customize, and manage integration tools, databases, and analytical systems. The Data Analytics Engineer I assists in designing and implementing solutions to integrate, process, and analyze large data sets, requiring knowledge of data and systems design, development, and analytics.\\n\\nResponsibilities:\\n\\nMeets expectations of the applicable OneCHRISTUS Competencies: Leader of Self, Leader of Others, or Leader of Leaders.\\nAssist in analyzing large data sets to identify trends and insights.\\nCollaborate with other team members and engineers to design and implement data processing and integration solutions.\\nRecommend data handling and processing improvements based on the latest technological advancements.\\nParticipate in projects that involve sorting, analyzing, processing, and integrating large amounts of data.\\nDevelop visualizations using various technologies to represent data findings effectively.\\nCollaborate by developing software solutions in languages like Java, Python, C, HTML, and SQL.\\nParticipate in testing software solutions to ensure they meet functional requirements.\\nDevelop and maintain code bases across multiple programming languages, ensuring that programming tasks are completed effectively and efficiently.\\nResponsible for documenting all development and data processing phases for future reference.\\nContinuously learn and apply best practices in data analytics and software development.\\n\\nJob Requirements:\\n\\nEducation/Skills\\n\\nBachelor\\u2019s degree in computer science, engineering, math, or a related field is preferred.\\n\\nExperience\\n\\n0 - 1 years of analytics solutions or Healthcare IT experience preferred.\\n\\nMicrosoft SQL Server environment experience is preferred.\\n\\nLicenses, Registrations, or Certifications\\n\\nCertifications in Hadoop or Java are preferred.\\n\\nWork Schedule:\\n\\nTBD\\n\\nWork Type:\\n\\nFull Time\\n\\nEEO is the law - click below for more information:\\n\\nhttps://www.eeoc.gov/sites/default/files/2023-06/22-088_EEOC_KnowYourRights6.12ScreenRdr.pdf\\n\\nWe endeavor to make this site accessible to any and all users. If you would like to contact us regarding the accessibility of our website or need assistance completing the application process, please contact us at (844) 257-6925.", "semanticSegments": []}, "location": {"__typename": "JobLocation", "countryCode": "US", "admin1Code": "TX", "admin2Code": "113", "admin3Code": null, "admin4Code": null, "city": "Irving", "postalCode": "75039", "latitude": 32.86966, "longitude": -96.9422, "streetAddress": "5101 N O Connor Blvd", "formatted": {"__typename": "FormattedJobLocation", "long": "Irving, TX 75039", "short": "Irving, TX"}}, "occupations": [{"__typename": "JobOccupation", "key": "6D2D2", "label": "Data & Database Occupations"}, {"__typename": "JobOccupation", "key": "EHPW9", "label": "Technology Occupations"}, {"__typename": "JobOccupation", "key": "XXX29", "label": "Data Developers"}], "occupationMostLikelySuids": [{"__typename": "JobOccupation", "key": "XXX29"}], "benefits": [], "socialInsurance": [], "workingSystem": [], "requiredDocumentsCategorizedAttributes": [], "indeedApply": {"__typename": "JobIndeedApplyAttributes", "key": null, "scopes": []}, "attributes": [{"__typename": "JobAttribute", "key": "4E4WW", "label": "Computer science"}, {"__typename": "JobAttribute", "key": "6XNCP", "label": "Computer Science"}, {"__typename": "JobAttribute", "key": "C5C2F", "label": "System design"}, {"__typename": "JobAttribute", "key": "CCJPX", "label": "Microsoft SQL Server"}, {"__typename": "JobAttribute", "key": "CF3CP", "label": "Full-time"}, {"__typename": "JobAttribute", "key": "EVPJU", "label": "Java"}, {"__typename": "JobAttribute", "key": "FGY89", "label": "SQL"}, {"__typename": "JobAttribute", "key": "HEGCZ", "label": "C"}, {"__typename": "JobAttribute", "key": "HFDVW", "label": "Bachelor's degree"}, {"__typename": "JobAttribute", "key": "PAGS7", "label": "Software development"}, {"__typename": "JobAttribute", "key": "QJWAE", "label": "IT"}, {"__typename": "JobAttribute", "key": "VZQKQ", "label": "Healthcare IT"}, {"__typename": "JobAttribute", "key": "X62BT", "label": "Python"}, {"__typename": "JobAttribute", "key": "Y4JG9", "label": "Entry level"}, {"__typename": "JobAttribute", "key": "Y7U37", "label": "HTML"}, {"__typename": "JobAttribute", "key": "ZK3HH", "label": "Analytics"}, {"__typename": "JobAttribute", "key": "ZMMWJ", "label": "Hadoop"}], "employerProvidedAttributes": [{"__typename": "JobAttribute", "key": "CF3CP", "label": "Full-time"}], "employerProvidedOccupations": [], "hiringDemand": {"__typename": "HiringDemand", "isUrgentHire": false, "isHighVolumeHiring": true}, "thirdPartyTrackingUrls": [], "jobSearchMobileMigrationData": null, "jobStats": {"__typename": "JobStats", "organicApplyStarts": 5}, "isRepost": false, "isLatestPost": true, "isPlacement": null, "employer": {"__typename": "Employer", "key": "d87d2da983361996", "tier": "ENTERPRISE", "relativeCompanyPageUrl": "/cmp/Christus-Health", "dossier": {"__typename": "EmployerDossier", "images": {"__typename": "ImageBundle", "rectangularLogoUrl": null, "headerImageUrls": {"__typename": "HeaderImageUrlBundle", "url1960x400": "https://d2q79iu7y748jz.cloudfront.net/s/_headerimage/1960x400/2d3107dcde8edbd4e2aaf2d50c8b1914"}, "squareLogoUrls": {"__typename": "SquareLogoUrlBundle", "url256": "https://d2q79iu7y748jz.cloudfront.net/s/_squarelogo/256x256/f385040e696568d645ba70248d9eccb8"}}}, "ugcStats": {"__typename": "JobseekerUgcStats", "globalReviewCount": 2662, "ratings": {"__typename": "RatingBundle", "overallRating": {"__typename": "AverageRating", "count": 2662, "value": 3.7}}}, "subsidiaryOptOutStatusV2": false, "parentEmployer": null}, "jobTypes": [{"__typename": "JobAttribute", "key": "CF3CP", "label": "Full-time"}], "shiftAndSchedule": [], "compensation": {"__typename": "JobCompensation", "key": "CNa1kOEjHQCmpEcgqVQoqVQwuxU41VhCCGZ1bGx0aW1lSi5EYXRhIEFuYWx5dGljcyBFbmdpbmVlciBJIC0gSU0gRW50ZXJwcmlzZSBEYXRhUNSGzMoDag1kYXRhIGVuZ2luZWVycIjXwb/GMooBBVhYWDI5kgESCg4KCg03eZFHFa0zuEcQBXgBogFcCgNTRVMSCWVzdFNhbGFyeRoQCgNtaW4QBDkAAADgJi/yQBoQCgNtYXgQBDkAAACgdQb3QBoTCgdzYWxUeXBlEAIqBllFQVJMWRoRCghjdXJyZW5jeRACKgNVU0SqAQJVU7IBAlRYugEGSXJ2aW5n"}, "applicants": null}, "matchComparisonResult": {"__typename": "MatchComparisonEngineMatchResult", "attributeComparisons": [{"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Healthcare IT", "lastModified": 0, "suid": "VZQKQ", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Computer science", "lastModified": 0, "suid": "4E4WW", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "MUST_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Hadoop", "lastModified": 0, "suid": "ZMMWJ", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "SQL", "lastModified": 0, "suid": "FGY89", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Analytics", "lastModified": 0, "suid": "ZK3HH", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "HTML", "lastModified": 0, "suid": "Y7U37", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Software development", "lastModified": 0, "suid": "PAGS7", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "MUST_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Java", "lastModified": 0, "suid": "EVPJU", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "System design", "lastModified": 0, "suid": "C5C2F", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Microsoft SQL Server", "lastModified": 0, "suid": "CCJPX", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Python", "lastModified": 0, "suid": "X62BT", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "IT", "lastModified": 0, "suid": "QJWAE", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Bachelor's degree", "lastModified": 0, "suid": "HFDVW", "profileAttributeTypeSuid": "NP7FU"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Computer Science", "lastModified": 0, "suid": "6XNCP", "profileAttributeTypeSuid": ""}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "C", "lastModified": 0, "suid": "HEGCZ", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}], "encouragementToApply": {"__typename": "MatchComparisonEngineEncouragementToApply", "score": 0, "strategy": "", "trafficLight": "YELLOW"}, "matchOverlapMetric": {"__typename": "MatchComparisonEngineMatchOverlapMetric", "coverage": 0, "jobDetailScore": 0, "locationScore": 0, "matchOverlapScore": 0, "payScore": 0, "qualificationOverlapScore": 0, "version": 0}, "occupationComparisons": [{"__typename": "MatchComparisonEngineOccupationComparison", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY", "occupation": {"__typename": "MatchComparisonEngineOccupation", "label": "Data Developers", "suid": "XXX29"}}]}}]}}, "errors": [], "query": "query getViewJobJobData($jobKey: ID!, $jobKeyString: String!, $shouldQueryCogsEligibility: Boolean!, $shouldQuerySavedJob: Boolean!, $shouldQueryTitleNorm: Boolean!, $shouldQueryCompanyFields: Boolean!, $shouldQuerySalary: Boolean!, $shouldQueryIndeedApplyLink: Boolean!, $shouldQueryParentEmployer: Boolean!, $shouldQuerySentiment: Boolean!, $shouldIncludeFragmentZone: Boolean!, $shouldQueryMatchComparison: Boolean!, $shouldQueryApplicantInsights: Boolean!, $shouldQueryJobCampaignsConnection: Boolean!, $shouldQueryJobSeekerPreferences: Boolean!, $shouldQueryJobSeekerProfileQuestions: Boolean!, $mobvjtk: String!, $continueUrl: String!, $spn: Boolean!, $jobDataInput: JobDataInput!) {\\n  jobData(input: $jobDataInput) {\\n    __typename\\n    results {\\n      __typename\\n      trackingKey\\n      job {\\n        __typename\\n        key\\n        ...jobDataFields\\n        ...titleNormFields@include(if: $shouldQueryTitleNorm)\\n        ...companyFields@include(if: $shouldQueryCompanyFields)\\n        ...parentEmployerFields@include(if: $shouldQueryParentEmployer)\\n        jobSearchMobileMigrationData @include(if: $shouldQuerySentiment) {\\n          __typename\\n          knownUserSentimentIdMap {\\n            __typename\\n            id\\n            suid\\n          }\\n          userStringDislikedPreferences {\\n            __typename\\n            uid\\n          }\\n          userMinimumPayPreferences {\\n            __typename\\n            currency\\n            payAmount\\n            salaryType\\n          }\\n          preferencesFetchStatus\\n          paySentiment\\n        }\\n        jobTypes: attributes(customClass: \\"BM62A\\") {\\n          __typename\\n          key\\n          label\\n          sentiment @include(if: $shouldQuerySentiment)\\n        }\\n        shiftAndSchedule: attributes(customClass: \\"BTSWR\\") {\\n          __typename\\n          key\\n          label\\n          sentiment @include(if: $shouldQuerySentiment)\\n        }\\n        compensation @include(if: $shouldQuerySalary) {\\n          __typename\\n          key\\n        }\\n        indeedApply @include(if: $shouldQueryIndeedApplyLink) {\\n          __typename\\n          applyLink(property: INDEED, trackingKeys: {mobvjtk : $mobvjtk}, continueUrl: $continueUrl, spn: $spn) {\\n            __typename\\n            url\\n            iaUid\\n          }\\n        }\\n        ...ViewJobFragmentZone@include(if: $shouldIncludeFragmentZone)\\n        applicants @include(if: $shouldQueryApplicantInsights) {\\n          __typename\\n          hasInsights\\n          ...ApplicantDemographicsFields\\n        }\\n        jobCampaignsConnection(input: {spendingEligibilityTypes : [FUNDED_PERIOD_ELIGIBILITY]}) @include(if: $shouldQueryJobCampaignsConnection) {\\n          __typename\\n          campaignCount\\n        }\\n      }\\n      matchComparisonResult @include(if: $shouldQueryMatchComparison) {\\n        __typename\\n        attributeComparisons {\\n          __typename\\n          jobProvenance\\n          attribute {\\n            __typename\\n            interestedParty\\n            label\\n            lastModified\\n            suid\\n            profileAttributeTypeSuid\\n          }\\n          jobRequirementStrength\\n          jsProvenance\\n          matchType\\n        }\\n        encouragementToApply {\\n          __typename\\n          score\\n          strategy\\n          trafficLight\\n        }\\n        matchOverlapMetric {\\n          __typename\\n          coverage\\n          jobDetailScore\\n          locationScore\\n          matchOverlapScore\\n          payScore\\n          qualificationOverlapScore\\n          version\\n        }\\n        occupationComparisons {\\n          __typename\\n          jsProvenance\\n          matchType\\n          occupation {\\n            __typename\\n            label\\n            suid\\n          }\\n        }\\n      }\\n    }\\n  }\\n  savedJobsByKey(keys: [$jobKey]) @include(if: $shouldQuerySavedJob) {\\n    __typename\\n    state\\n    currentStateTime\\n  }\\n  cogsCheckEligibility(input: {jobKey : $jobKeyString}) @include(if: $shouldQueryCogsEligibility) {\\n    __typename\\n    error\\n    isEligible\\n  }\\n  jobSeekerProfile @include(if: $shouldQueryApplicantInsights) {\\n    __typename\\n    profile {\\n      __typename\\n      jobSeekerPro {\\n        __typename\\n        status\\n      }\\n    }\\n  }\\n  jobSeekerProfileStructuredData(input: {queryFilter : {dataCategory : CONFIRMED_BY_USER}}) @include(if: $shouldQueryJobSeekerPreferences) {\\n    __typename\\n    preferences {\\n      __typename\\n      jobTitles {\\n        __typename\\n        jobTitle\\n      }\\n      minimumPay {\\n        __typename\\n        amount\\n        salaryType\\n      }\\n    }\\n  }\\n  jobSeekerProfileQuestionFieldSet(input: {source : VJP_GATING}) @include(if: $shouldQueryJobSeekerProfileQuestions) {\\n    __typename\\n    questionFields {\\n      __typename\\n      name\\n    }\\n  }\\n}\\n\\nfragment jobDataFields on Job {\\n  __typename\\n  title\\n  sourceEmployerName\\n  datePublished\\n  expired\\n  language\\n  normalizedTitle\\n  refNum\\n  expirationDate\\n  source {\\n    __typename\\n    key\\n    name\\n  }\\n  feed {\\n    __typename\\n    key\\n    isDradis\\n    feedSourceType\\n  }\\n  url\\n  dateOnIndeed\\n  description {\\n    __typename\\n    html\\n    text\\n    semanticSegments {\\n      __typename\\n      content\\n      header\\n      label\\n    }\\n  }\\n  location {\\n    __typename\\n    countryCode\\n    admin1Code\\n    admin2Code\\n    admin3Code\\n    admin4Code\\n    city\\n    postalCode\\n    latitude\\n    longitude\\n    streetAddress\\n    formatted {\\n      __typename\\n      long\\n      short\\n    }\\n  }\\n  occupations {\\n    __typename\\n    key\\n    label\\n  }\\n  occupationMostLikelySuids: occupations(occupationOption: MOST_LIKELY) {\\n    __typename\\n    key\\n  }\\n  benefits: attributes(customClass: \\"SXMYH\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  socialInsurance: attributes(customClass: \\"KTQQ7\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  workingSystem: attributes(customClass: \\"TY4DY\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  requiredDocumentsCategorizedAttributes: attributes(customClass: \\"PQCTE\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  indeedApply {\\n    __typename\\n    key\\n    scopes\\n  }\\n  attributes {\\n    __typename\\n    key\\n    label\\n  }\\n  employerProvidedAttributes: attributes(sources: [EMPLOYER]) {\\n    __typename\\n    key\\n    label\\n  }\\n  employerProvidedOccupations: occupations(sources: [EMPLOYER], occupationOption: MOST_SPECIFIC) {\\n    __typename\\n    label\\n  }\\n  hiringDemand {\\n    __typename\\n    isUrgentHire\\n    isHighVolumeHiring\\n  }\\n  thirdPartyTrackingUrls\\n  jobSearchMobileMigrationData {\\n    __typename\\n    advertiserId\\n    jobTypeId\\n    applyEmail\\n    applyUrl\\n    contactEmail\\n    contactPhone\\n    isNoUniqueUrl\\n    urlRewriteRule\\n    mapDisplayType\\n    jobTags\\n    locCountry\\n    waldoVisibilityLevel\\n    isKnownSponsoredOnDesktop\\n    isKnownSponsoredOnMobile\\n    tpiaAdvNum\\n    tpiaApiToken\\n    tpiaCoverLetter\\n    tpiaEmail\\n    tpiaFinishAppUrl\\n    tpiaJobCompanyName\\n    tpiaJobId\\n    tpiaJobLocation\\n    tpiaJobMeta\\n    tpiaJobTitle\\n    tpiaLocale\\n    tpiaName\\n    tpiaPhone\\n    tpiaPostUrl\\n    tpiaPresent\\n    tpiaResume\\n    tpiaResumeFieldsOptional\\n    tpiaResumeFieldsRequired\\n    tpiaScreenerQuestions\\n    iaVisibility\\n    hasPreciseLocation\\n    algoKey\\n  }\\n  jobStats {\\n    __typename\\n    organicApplyStarts\\n  }\\n  isRepost\\n  isLatestPost\\n  isPlacement\\n}\\n\\nfragment titleNormFields on Job {\\n  __typename\\n  normalizedTitle\\n  displayTitle\\n}\\n\\nfragment companyFields on Job {\\n  __typename\\n  employer {\\n    __typename\\n    key\\n    tier\\n    relativeCompanyPageUrl\\n    dossier {\\n      __typename\\n      images {\\n        __typename\\n        rectangularLogoUrl\\n        headerImageUrls {\\n          __typename\\n          url1960x400\\n        }\\n        squareLogoUrls {\\n          __typename\\n          url256\\n        }\\n      }\\n    }\\n    ugcStats {\\n      __typename\\n      globalReviewCount\\n      ratings {\\n        __typename\\n        overallRating {\\n          __typename\\n          count\\n          value\\n        }\\n      }\\n    }\\n  }\\n}\\n\\nfragment parentEmployerFields on Job {\\n  __typename\\n  employer {\\n    __typename\\n    subsidiaryOptOutStatusV2\\n    parentEmployer {\\n      __typename\\n      name\\n      subsidiaryOptOutStatusV2\\n    }\\n  }\\n}\\n\\nfragment ViewJobFragmentZone on Job {\\n  key\\n  __typename\\n}\\n\\nfragment ApplicantDemographicsFields on Applicants {\\n  __typename\\n  count {\\n    __typename\\n    total\\n    last24h\\n  }\\n  workExperience {\\n    __typename\\n    title\\n    pct\\n  }\\n  education {\\n    __typename\\n    title\\n    pct\\n  }\\n  skills {\\n    __typename\\n    title\\n    pct\\n  }\\n  certificates {\\n    __typename\\n    title\\n    pct\\n  }\\n}\\n", "variables": {"jobKey": "3581862403da61ad", "jobKeyString": "3581862403da61ad", "shouldQueryCogsEligibility": false, "shouldQuerySavedJob": false, "shouldQueryTitleNorm": false, "shouldQueryCompanyFields": true, "shouldQuerySalary": true, "shouldQueryIndeedApplyLink": false, "shouldQueryParentEmployer": true, "shouldQuerySentiment": false, "shouldIncludeFragmentZone": false, "shouldQueryMatchComparison": true, "shouldQueryApplicantInsights": false, "shouldQueryJobCampaignsConnection": false, "shouldQueryJobSeekerPreferences": false, "shouldQueryJobSeekerProfileQuestions": false, "mobvjtk": "1ihka0knjg8io807", "continueUrl": "http://www.indeed.com/viewjob?jk=3581862403da61ad&from=serp&vjs=3&applied=1", "spn": false, "jobDataInput": {"jobKeys": ["3581862403da61ad"], "useSearchlessPrice": false}}}}	INDEED	DATA_ENGINEER	2025-01-15 00:22:40.394535+00	f	Full-time	\N
2	/rc/clk?jk=2adc3fd28e451945&bb=nVAi1dqOC2Ptfy5ocQiBhSwFePWezHiwRF_5W-3oUksO3UxHBxQgl-ZHuCIPXmQt0ue-9cKgj2Wi2n907217ZKAMRbWd3bZbNdXH3II6ylNtNp31d7PY_uYqkMKP6p6_&xkcb=SoAb67M330bz7mSxXB0JbzkdCdPP&fccid=dd616958bd9ddc12&vjs=3	{"host_query_execution_result": {"data": {"jobData": {"__typename": "JobDataPayload", "results": [{"__typename": "JobDataResult", "trackingKey": "5-cmh1-3-1ihka1q7qgbgg801", "job": {"__typename": "Job", "key": "2adc3fd28e451945", "title": "Data Engineer II", "sourceEmployerName": "Neon Redwood", "datePublished": 1735711200000, "expired": false, "language": "en", "normalizedTitle": "data engineer", "refNum": "ee7531989643", "expirationDate": null, "source": {"__typename": "JobSource", "key": "AAAAAXs+Iei8NEgcaLYBuPOCO9Ef0Ox4ndWcn+y66BsqrxY0WHZezA==", "name": "Neon Redwood"}, "feed": {"__typename": "JobFeed", "key": "AAAAAXK7o86FHVcjYv1MctlidI00WP32V9o931w7BSiWz3t7TCdvmg==", "isDradis": false, "feedSourceType": "EMPLOYER"}, "url": "https://neon-redwood.breezy.hr/p/ee7531989643-data-engineer-ii?source=indeed", "dateOnIndeed": 1736905293000, "description": {"__typename": "JobDescription", "html": "<div><p><b>The company</b></p>\\n<p>Neon Redwood is a data services consulting company, working on cutting-edge AI and data-driven solutions. We are a team of passionate engineers and data experts, and we are currently looking for a Senior Data Engineer to join our team and help us develop and expand our data infrastructure and analytics capabilities.</p>\\n<p></p><p><b>The Role</b></p>\\n<p>We are seeking an experienced Data Engineer II with a strong background in data engineering and a passion for working with large-scale data sets. Help us develop and expand our data infrastructure and analytics capabilities.</p>\\n<p></p><p>The ideal candidate will have at least 2 years of professional experience and a solid understanding of Python, BigQuery, and Google Cloud Platform (GCP) or similar technologies. This full-time role will involve working closely with our CTO and other team members to design, develop, and maintain data pipelines, ETL processes, and data warehousing solutions.</p>\\n<h2 class=\\"jobSectionHeader\\"><b>Responsibilities</b></h2>\\n<ul><li>Collaborate with the CTO and other team members to design, develop, and maintain data pipelines and ETL processes.</li><li>\\nWrite clean, efficient, and maintainable code in Python and other relevant technologies.</li><li>\\nImplement and optimize data storage and processing solutions using BigQuery and Google Cloud Platform (GCP).</li><li>\\nEnsure data quality and integrity through proper data validation and monitoring techniques.</li><li>\\nStay up-to-date with the latest industry trends and technologies to ensure our data infrastructure remains competitive.</li><li>\\nAssist in the development and launch of new data-driven tools and products.</li><li>\\nMentor and guide junior engineers, fostering a culture of continuous learning and improvement.</li></ul>\\n<h2 class=\\"jobSectionHeader\\"><b>Requirements</b></h2>\\n<ul><li>Bachelor's degree in Computer Science, Engineering, or a related field, or equivalent work experience.</li><li>\\n2+ years of professional data engineering experience.</li><li>\\nProficiency in Python, BigQuery, and Google Cloud Platform (GCP) or equivalent technologies.</li><li>\\nExperience with data pipeline and ETL process design and development.</li><li>\\nExcellent problem-solving skills and the ability to work independently or as part of a team.</li><li>\\nStrong communication, collaboration, and a passion to develop leadership skills.</li><li>\\nPassion for working with large-scale data sets and staying current with industry trends.</li></ul>\\n<h2 class=\\"jobSectionHeader\\"><b>Additional Skills (Nice to Have)</b></h2>\\n<ul><li>Experience with other data processing technologies and platforms (e.g., Apache Beam, Dataflow, Hadoop, Spark).</li><li>\\nExperience with data visualization tools and libraries (e.g., Looker, Sigma, D3.js).</li><li>\\nKnowledge of machine learning and AI concepts.</li><li>\\nExperience with real-time data processing and streaming technologies (e.g., Kafka, Pub/Sub).</li></ul>\\n<p><b>Benefits:</b></p>\\n<p>Fully remote team and intend to remain this way, a lot of flexibility and frequent get togethers<br>\\n<br>\\n<br>\\n</p><ul><li>Fully covered Health Insurance for employees and their eligible dependents</li></ul>\\n<ul><li>Fully covered Vision &amp; Dental for employees and their eligible dependents</li></ul>\\n<ul><li>Unlimited Time Off</li></ul>\\n<ul><li>Company 401k plan with employer contributions</li></ul>\\n<ul><li>Supplemental monthly health and wellness stipend</li></ul></div><p></p>", "text": "The company\\n\\nNeon Redwood is a data services consulting company, working on cutting-edge AI and data-driven solutions. We are a team of passionate engineers and data experts, and we are currently looking for a Senior Data Engineer to join our team and help us develop and expand our data infrastructure and analytics capabilities.\\n\\nThe Role\\n\\nWe are seeking an experienced Data Engineer II with a strong background in data engineering and a passion for working with large-scale data sets. Help us develop and expand our data infrastructure and analytics capabilities.\\n\\nThe ideal candidate will have at least 2 years of professional experience and a solid understanding of Python, BigQuery, and Google Cloud Platform (GCP) or similar technologies. This full-time role will involve working closely with our CTO and other team members to design, develop, and maintain data pipelines, ETL processes, and data warehousing solutions.\\n\\nResponsibilities\\nCollaborate with the CTO and other team members to design, develop, and maintain data pipelines and ETL processes.\\nWrite clean, efficient, and maintainable code in Python and other relevant technologies.\\nImplement and optimize data storage and processing solutions using BigQuery and Google Cloud Platform (GCP).\\nEnsure data quality and integrity through proper data validation and monitoring techniques.\\nStay up-to-date with the latest industry trends and technologies to ensure our data infrastructure remains competitive.\\nAssist in the development and launch of new data-driven tools and products.\\nMentor and guide junior engineers, fostering a culture of continuous learning and improvement.\\nRequirements\\nBachelor's degree in Computer Science, Engineering, or a related field, or equivalent work experience.\\n2+ years of professional data engineering experience.\\nProficiency in Python, BigQuery, and Google Cloud Platform (GCP) or equivalent technologies.\\nExperience with data pipeline and ETL process design and development.\\nExcellent problem-solving skills and the ability to work independently or as part of a team.\\nStrong communication, collaboration, and a passion to develop leadership skills.\\nPassion for working with large-scale data sets and staying current with industry trends.\\nAdditional Skills (Nice to Have)\\nExperience with other data processing technologies and platforms (e.g., Apache Beam, Dataflow, Hadoop, Spark).\\nExperience with data visualization tools and libraries (e.g., Looker, Sigma, D3.js).\\nKnowledge of machine learning and AI concepts.\\nExperience with real-time data processing and streaming technologies (e.g., Kafka, Pub/Sub).\\n\\nBenefits:\\n\\nFully remote team and intend to remain this way, a lot of flexibility and frequent get togethers\\n\\n* Fully covered Health Insurance for employees and their eligible dependents\\n\\n* Fully covered Vision & Dental for employees and their eligible dependents\\n\\n* Unlimited Time Off\\n\\n* Company 401k plan with employer contributions\\n\\n* Supplemental monthly health and wellness stipend", "semanticSegments": []}, "location": {"__typename": "JobLocation", "countryCode": "US", "admin1Code": "CA", "admin2Code": "075", "admin3Code": null, "admin4Code": null, "city": "San Francisco", "postalCode": null, "latitude": 37.77493, "longitude": -122.41942, "streetAddress": null, "formatted": {"__typename": "FormattedJobLocation", "long": "San Francisco, CA", "short": "San Francisco, CA"}}, "occupations": [{"__typename": "JobOccupation", "key": "6D2D2", "label": "Data & Database Occupations"}, {"__typename": "JobOccupation", "key": "EHPW9", "label": "Technology Occupations"}, {"__typename": "JobOccupation", "key": "XXX29", "label": "Data Developers"}], "occupationMostLikelySuids": [{"__typename": "JobOccupation", "key": "XXX29"}], "benefits": [{"__typename": "JobAttribute", "key": "EY33Q", "label": "Health insurance"}, {"__typename": "JobAttribute", "key": "FQJ2X", "label": "Dental insurance"}, {"__typename": "JobAttribute", "key": "FVKX2", "label": "401(k)"}, {"__typename": "JobAttribute", "key": "RZAT2", "label": "Vision insurance"}], "socialInsurance": [{"__typename": "JobAttribute", "key": "EY33Q", "label": "Health insurance"}], "workingSystem": [], "requiredDocumentsCategorizedAttributes": [], "indeedApply": {"__typename": "JobIndeedApplyAttributes", "key": "eyJqayI6IjJhZGMzZmQyOGU0NTE5NDUiLCJhcGlUb2tlbiI6ImE3MzcwMDc1ZTc4M2I2MmVhYmM4YjU1NGQzNjc0NzQyMjVhNWQyZTllNWFkNjZlNjIxMGNiODUwN2Q3NTk0NDgiLCJqb2JDb21wYW55TmFtZSI6Ik5lb24gUmVkd29vZCIsImpvYklkIjoiZWU3NTMxOTg5NjQzIiwiam9iTG9jYXRpb24iOiJTYW4gRnJhbmNpc2NvLCBDQSIsImpvYlRpdGxlIjoiRGF0YSBFbmdpbmVlciBJSSIsInBvc3RVcmwiOiJodHRwczovL2FwcC5icmVlenkuaHIvYXBpL2ludGVncmF0aW9uL2luZGVlZC9hcHBseSIsImlzTW9iaWxlIjp0cnVlfQ==", "scopes": ["DESKTOP", "MOBILE"]}, "attributes": [{"__typename": "JobAttribute", "key": "3CK2D", "label": "Looker"}, {"__typename": "JobAttribute", "key": "4E4WW", "label": "Computer science"}, {"__typename": "JobAttribute", "key": "6XNCP", "label": "Computer Science"}, {"__typename": "JobAttribute", "key": "8GVG5", "label": "D3.js"}, {"__typename": "JobAttribute", "key": "AWSY6", "label": "Spark"}, {"__typename": "JobAttribute", "key": "CF3CP", "label": "Full-time"}, {"__typename": "JobAttribute", "key": "DDKYP", "label": "Google Cloud Platform"}, {"__typename": "JobAttribute", "key": "DN563", "label": "Mid-level"}, {"__typename": "JobAttribute", "key": "DSQF7", "label": "Remote"}, {"__typename": "JobAttribute", "key": "EY33Q", "label": "Health insurance"}, {"__typename": "JobAttribute", "key": "FQJ2X", "label": "Dental insurance"}, {"__typename": "JobAttribute", "key": "FVKX2", "label": "401(k)"}, {"__typename": "JobAttribute", "key": "HFDVW", "label": "Bachelor's degree"}, {"__typename": "JobAttribute", "key": "HT6WW", "label": "Machine learning"}, {"__typename": "JobAttribute", "key": "JB2WC", "label": "JavaScript"}, {"__typename": "JobAttribute", "key": "NREM3", "label": "Data pipelines"}, {"__typename": "JobAttribute", "key": "PRGNY", "label": "ETL"}, {"__typename": "JobAttribute", "key": "QDUY5", "label": "Experience equivalent to degree accepted"}, {"__typename": "JobAttribute", "key": "RZAT2", "label": "Vision insurance"}, {"__typename": "JobAttribute", "key": "SJ2HN", "label": "Apache"}, {"__typename": "JobAttribute", "key": "SKFS2", "label": "Kafka"}, {"__typename": "JobAttribute", "key": "TKG4S", "label": "Data visualization"}, {"__typename": "JobAttribute", "key": "UJF52", "label": "AI"}, {"__typename": "JobAttribute", "key": "W3PMJ", "label": "Leadership"}, {"__typename": "JobAttribute", "key": "W6GUJ", "label": "2 years"}, {"__typename": "JobAttribute", "key": "WSBNK", "label": "Communication skills"}, {"__typename": "JobAttribute", "key": "X62BT", "label": "Python"}, {"__typename": "JobAttribute", "key": "ZMMWJ", "label": "Hadoop"}], "employerProvidedAttributes": [{"__typename": "JobAttribute", "key": "CF3CP", "label": "Full-time"}], "employerProvidedOccupations": [], "hiringDemand": {"__typename": "HiringDemand", "isUrgentHire": false, "isHighVolumeHiring": false}, "thirdPartyTrackingUrls": [], "jobSearchMobileMigrationData": null, "jobStats": {"__typename": "JobStats", "organicApplyStarts": 371}, "isRepost": true, "isLatestPost": true, "isPlacement": null, "employer": null, "jobTypes": [{"__typename": "JobAttribute", "key": "CF3CP", "label": "Full-time"}], "shiftAndSchedule": [], "compensation": {"__typename": "JobCompensation", "key": "CPmQiuEjHQDTKUgg////////////ASi6wck2MK3cqA04ouQHQghmdWxsdGltZUoQRGF0YSBFbmdpbmVlciBJSVCUkiBqDWRhdGEgZW5naW5lZXJwyPn9vMYyigEFWFhYMjmSARIKDgoKDSfiFUgVKck9SBAFeAGiAVwKA1NFUxIJZXN0U2FsYXJ5GhAKA21pbhAEOQAAAOBEvAJBGhAKA21heBAEOQAAACAluQdBGhMKB3NhbFR5cGUQAioGWUVBUkxZGhEKCGN1cnJlbmN5EAIqA1VTRKoBAlVTsgECQ0G6AQ1TYW4gRnJhbmNpc2Nv"}, "applicants": null}, "matchComparisonResult": {"__typename": "MatchComparisonEngineMatchResult", "attributeComparisons": [{"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "JavaScript", "lastModified": 0, "suid": "JB2WC", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Computer science", "lastModified": 0, "suid": "4E4WW", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Hadoop", "lastModified": 0, "suid": "ZMMWJ", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Leadership", "lastModified": 0, "suid": "W3PMJ", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Apache", "lastModified": 0, "suid": "SJ2HN", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Looker", "lastModified": 0, "suid": "3CK2D", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Kafka", "lastModified": 0, "suid": "SKFS2", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "AI", "lastModified": 0, "suid": "UJF52", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Python", "lastModified": 0, "suid": "X62BT", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Google Cloud Platform", "lastModified": 0, "suid": "DDKYP", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "MUST_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Spark", "lastModified": 0, "suid": "AWSY6", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Data pipelines", "lastModified": 0, "suid": "NREM3", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Data visualization", "lastModified": 0, "suid": "TKG4S", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Bachelor's degree", "lastModified": 0, "suid": "HFDVW", "profileAttributeTypeSuid": "NP7FU"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "D3.js", "lastModified": 0, "suid": "8GVG5", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Computer Science", "lastModified": 0, "suid": "6XNCP", "profileAttributeTypeSuid": ""}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Communication skills", "lastModified": 0, "suid": "WSBNK", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Machine learning", "lastModified": 0, "suid": "HT6WW", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "ETL", "lastModified": 0, "suid": "PRGNY", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}], "encouragementToApply": {"__typename": "MatchComparisonEngineEncouragementToApply", "score": 0, "strategy": "", "trafficLight": "YELLOW"}, "matchOverlapMetric": {"__typename": "MatchComparisonEngineMatchOverlapMetric", "coverage": 0, "jobDetailScore": 0, "locationScore": 0, "matchOverlapScore": 0, "payScore": 0, "qualificationOverlapScore": 0, "version": 0}, "occupationComparisons": [{"__typename": "MatchComparisonEngineOccupationComparison", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY", "occupation": {"__typename": "MatchComparisonEngineOccupation", "label": "Data Developers", "suid": "XXX29"}}]}}]}}, "errors": [], "query": "query getViewJobJobData($jobKey: ID!, $jobKeyString: String!, $shouldQueryCogsEligibility: Boolean!, $shouldQuerySavedJob: Boolean!, $shouldQueryTitleNorm: Boolean!, $shouldQueryCompanyFields: Boolean!, $shouldQuerySalary: Boolean!, $shouldQueryIndeedApplyLink: Boolean!, $shouldQueryParentEmployer: Boolean!, $shouldQuerySentiment: Boolean!, $shouldIncludeFragmentZone: Boolean!, $shouldQueryMatchComparison: Boolean!, $shouldQueryApplicantInsights: Boolean!, $shouldQueryJobCampaignsConnection: Boolean!, $shouldQueryJobSeekerPreferences: Boolean!, $shouldQueryJobSeekerProfileQuestions: Boolean!, $mobvjtk: String!, $continueUrl: String!, $spn: Boolean!, $jobDataInput: JobDataInput!) {\\n  jobData(input: $jobDataInput) {\\n    __typename\\n    results {\\n      __typename\\n      trackingKey\\n      job {\\n        __typename\\n        key\\n        ...jobDataFields\\n        ...titleNormFields@include(if: $shouldQueryTitleNorm)\\n        ...companyFields@include(if: $shouldQueryCompanyFields)\\n        ...parentEmployerFields@include(if: $shouldQueryParentEmployer)\\n        jobSearchMobileMigrationData @include(if: $shouldQuerySentiment) {\\n          __typename\\n          knownUserSentimentIdMap {\\n            __typename\\n            id\\n            suid\\n          }\\n          userStringDislikedPreferences {\\n            __typename\\n            uid\\n          }\\n          userMinimumPayPreferences {\\n            __typename\\n            currency\\n            payAmount\\n            salaryType\\n          }\\n          preferencesFetchStatus\\n          paySentiment\\n        }\\n        jobTypes: attributes(customClass: \\"BM62A\\") {\\n          __typename\\n          key\\n          label\\n          sentiment @include(if: $shouldQuerySentiment)\\n        }\\n        shiftAndSchedule: attributes(customClass: \\"BTSWR\\") {\\n          __typename\\n          key\\n          label\\n          sentiment @include(if: $shouldQuerySentiment)\\n        }\\n        compensation @include(if: $shouldQuerySalary) {\\n          __typename\\n          key\\n        }\\n        indeedApply @include(if: $shouldQueryIndeedApplyLink) {\\n          __typename\\n          applyLink(property: INDEED, trackingKeys: {mobvjtk : $mobvjtk}, continueUrl: $continueUrl, spn: $spn) {\\n            __typename\\n            url\\n            iaUid\\n          }\\n        }\\n        ...ViewJobFragmentZone@include(if: $shouldIncludeFragmentZone)\\n        applicants @include(if: $shouldQueryApplicantInsights) {\\n          __typename\\n          hasInsights\\n          ...ApplicantDemographicsFields\\n        }\\n        jobCampaignsConnection(input: {spendingEligibilityTypes : [FUNDED_PERIOD_ELIGIBILITY]}) @include(if: $shouldQueryJobCampaignsConnection) {\\n          __typename\\n          campaignCount\\n        }\\n      }\\n      matchComparisonResult @include(if: $shouldQueryMatchComparison) {\\n        __typename\\n        attributeComparisons {\\n          __typename\\n          jobProvenance\\n          attribute {\\n            __typename\\n            interestedParty\\n            label\\n            lastModified\\n            suid\\n            profileAttributeTypeSuid\\n          }\\n          jobRequirementStrength\\n          jsProvenance\\n          matchType\\n        }\\n        encouragementToApply {\\n          __typename\\n          score\\n          strategy\\n          trafficLight\\n        }\\n        matchOverlapMetric {\\n          __typename\\n          coverage\\n          jobDetailScore\\n          locationScore\\n          matchOverlapScore\\n          payScore\\n          qualificationOverlapScore\\n          version\\n        }\\n        occupationComparisons {\\n          __typename\\n          jsProvenance\\n          matchType\\n          occupation {\\n            __typename\\n            label\\n            suid\\n          }\\n        }\\n      }\\n    }\\n  }\\n  savedJobsByKey(keys: [$jobKey]) @include(if: $shouldQuerySavedJob) {\\n    __typename\\n    state\\n    currentStateTime\\n  }\\n  cogsCheckEligibility(input: {jobKey : $jobKeyString}) @include(if: $shouldQueryCogsEligibility) {\\n    __typename\\n    error\\n    isEligible\\n  }\\n  jobSeekerProfile @include(if: $shouldQueryApplicantInsights) {\\n    __typename\\n    profile {\\n      __typename\\n      jobSeekerPro {\\n        __typename\\n        status\\n      }\\n    }\\n  }\\n  jobSeekerProfileStructuredData(input: {queryFilter : {dataCategory : CONFIRMED_BY_USER}}) @include(if: $shouldQueryJobSeekerPreferences) {\\n    __typename\\n    preferences {\\n      __typename\\n      jobTitles {\\n        __typename\\n        jobTitle\\n      }\\n      minimumPay {\\n        __typename\\n        amount\\n        salaryType\\n      }\\n    }\\n  }\\n  jobSeekerProfileQuestionFieldSet(input: {source : VJP_GATING}) @include(if: $shouldQueryJobSeekerProfileQuestions) {\\n    __typename\\n    questionFields {\\n      __typename\\n      name\\n    }\\n  }\\n}\\n\\nfragment jobDataFields on Job {\\n  __typename\\n  title\\n  sourceEmployerName\\n  datePublished\\n  expired\\n  language\\n  normalizedTitle\\n  refNum\\n  expirationDate\\n  source {\\n    __typename\\n    key\\n    name\\n  }\\n  feed {\\n    __typename\\n    key\\n    isDradis\\n    feedSourceType\\n  }\\n  url\\n  dateOnIndeed\\n  description {\\n    __typename\\n    html\\n    text\\n    semanticSegments {\\n      __typename\\n      content\\n      header\\n      label\\n    }\\n  }\\n  location {\\n    __typename\\n    countryCode\\n    admin1Code\\n    admin2Code\\n    admin3Code\\n    admin4Code\\n    city\\n    postalCode\\n    latitude\\n    longitude\\n    streetAddress\\n    formatted {\\n      __typename\\n      long\\n      short\\n    }\\n  }\\n  occupations {\\n    __typename\\n    key\\n    label\\n  }\\n  occupationMostLikelySuids: occupations(occupationOption: MOST_LIKELY) {\\n    __typename\\n    key\\n  }\\n  benefits: attributes(customClass: \\"SXMYH\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  socialInsurance: attributes(customClass: \\"KTQQ7\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  workingSystem: attributes(customClass: \\"TY4DY\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  requiredDocumentsCategorizedAttributes: attributes(customClass: \\"PQCTE\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  indeedApply {\\n    __typename\\n    key\\n    scopes\\n  }\\n  attributes {\\n    __typename\\n    key\\n    label\\n  }\\n  employerProvidedAttributes: attributes(sources: [EMPLOYER]) {\\n    __typename\\n    key\\n    label\\n  }\\n  employerProvidedOccupations: occupations(sources: [EMPLOYER], occupationOption: MOST_SPECIFIC) {\\n    __typename\\n    label\\n  }\\n  hiringDemand {\\n    __typename\\n    isUrgentHire\\n    isHighVolumeHiring\\n  }\\n  thirdPartyTrackingUrls\\n  jobSearchMobileMigrationData {\\n    __typename\\n    advertiserId\\n    jobTypeId\\n    applyEmail\\n    applyUrl\\n    contactEmail\\n    contactPhone\\n    isNoUniqueUrl\\n    urlRewriteRule\\n    mapDisplayType\\n    jobTags\\n    locCountry\\n    waldoVisibilityLevel\\n    isKnownSponsoredOnDesktop\\n    isKnownSponsoredOnMobile\\n    tpiaAdvNum\\n    tpiaApiToken\\n    tpiaCoverLetter\\n    tpiaEmail\\n    tpiaFinishAppUrl\\n    tpiaJobCompanyName\\n    tpiaJobId\\n    tpiaJobLocation\\n    tpiaJobMeta\\n    tpiaJobTitle\\n    tpiaLocale\\n    tpiaName\\n    tpiaPhone\\n    tpiaPostUrl\\n    tpiaPresent\\n    tpiaResume\\n    tpiaResumeFieldsOptional\\n    tpiaResumeFieldsRequired\\n    tpiaScreenerQuestions\\n    iaVisibility\\n    hasPreciseLocation\\n    algoKey\\n  }\\n  jobStats {\\n    __typename\\n    organicApplyStarts\\n  }\\n  isRepost\\n  isLatestPost\\n  isPlacement\\n}\\n\\nfragment titleNormFields on Job {\\n  __typename\\n  normalizedTitle\\n  displayTitle\\n}\\n\\nfragment companyFields on Job {\\n  __typename\\n  employer {\\n    __typename\\n    key\\n    tier\\n    relativeCompanyPageUrl\\n    dossier {\\n      __typename\\n      images {\\n        __typename\\n        rectangularLogoUrl\\n        headerImageUrls {\\n          __typename\\n          url1960x400\\n        }\\n        squareLogoUrls {\\n          __typename\\n          url256\\n        }\\n      }\\n    }\\n    ugcStats {\\n      __typename\\n      globalReviewCount\\n      ratings {\\n        __typename\\n        overallRating {\\n          __typename\\n          count\\n          value\\n        }\\n      }\\n    }\\n  }\\n}\\n\\nfragment parentEmployerFields on Job {\\n  __typename\\n  employer {\\n    __typename\\n    subsidiaryOptOutStatusV2\\n    parentEmployer {\\n      __typename\\n      name\\n      subsidiaryOptOutStatusV2\\n    }\\n  }\\n}\\n\\nfragment ViewJobFragmentZone on Job {\\n  key\\n  __typename\\n}\\n\\nfragment ApplicantDemographicsFields on Applicants {\\n  __typename\\n  count {\\n    __typename\\n    total\\n    last24h\\n  }\\n  workExperience {\\n    __typename\\n    title\\n    pct\\n  }\\n  education {\\n    __typename\\n    title\\n    pct\\n  }\\n  skills {\\n    __typename\\n    title\\n    pct\\n  }\\n  certificates {\\n    __typename\\n    title\\n    pct\\n  }\\n}\\n", "variables": {"jobKey": "2adc3fd28e451945", "jobKeyString": "2adc3fd28e451945", "shouldQueryCogsEligibility": false, "shouldQuerySavedJob": false, "shouldQueryTitleNorm": false, "shouldQueryCompanyFields": true, "shouldQuerySalary": true, "shouldQueryIndeedApplyLink": false, "shouldQueryParentEmployer": true, "shouldQuerySentiment": false, "shouldIncludeFragmentZone": false, "shouldQueryMatchComparison": true, "shouldQueryApplicantInsights": false, "shouldQueryJobCampaignsConnection": false, "shouldQueryJobSeekerPreferences": false, "shouldQueryJobSeekerProfileQuestions": false, "mobvjtk": "1ihka1q7lg7fb800", "continueUrl": "http://www.indeed.com/viewjob?jk=2adc3fd28e451945&from=serp&vjs=3&applied=1", "spn": false, "jobDataInput": {"jobKeys": ["2adc3fd28e451945"], "useSearchlessPrice": false}}}}	INDEED	DATA_ENGINEER	2025-01-15 00:22:59.722096+00	f	\N	\N
3	/rc/clk?jk=4e89e05beea188ca&bb=nVAi1dqOC2Ptfy5ocQiBhV5MbrshWVafITEA_YxVVqWsZxL2HjX1dsd48aO8UnCRIWAvAP34GqHnUQQ4hZ6EOaN84Av3S96mAoSpfr_1y7tlQf67sZM_WefYTeUAHuuj&xkcb=SoCv67M330bz7mSxXB0IbzkdCdPP&fccid=1bfec2a2f61dd5c2&vjs=3	{"host_query_execution_result": {"data": {"jobData": {"__typename": "JobDataPayload", "results": [{"__typename": "JobDataResult", "trackingKey": "5-cmh1-3-1ihka2d8ug4h8801", "job": {"__typename": "Job", "key": "4e89e05beea188ca", "title": "Data Engineer", "sourceEmployerName": "Baker Tilly", "datePublished": 1736834400000, "expired": false, "language": "en", "normalizedTitle": "data engineer", "refNum": "JR101681-1", "expirationDate": null, "source": {"__typename": "JobSource", "key": "AAAAAf8Qm75CJn8/ooliTu4NFvNwvO9obYrNtMJ077TRl3HCIYAIMg==", "name": "Baker Tilly"}, "feed": {"__typename": "JobFeed", "key": "AAAAASlGRXdtuvJ6jb3beGnjVoZAYsRCBbdzEVq/jZ5uWkswYAm0JQ==", "isDradis": false, "feedSourceType": "EMPLOYER"}, "url": "https://bakertilly.wd5.myworkdayjobs.com/en-US/BTCareers/job/USA-TX-Dallas-12221-Merit-Dr/Data-Engineer_JR101681-1", "dateOnIndeed": 1736915863000, "description": {"__typename": "JobDescription", "html": "<div><div>Overview</div><div></div><div>\\nBaker Tilly is a leading advisory, tax and assurance firm, providing clients with a genuine coast-to-coast and global advantage in major regions of the U.S. and in many of the world&rsquo;s leading financial centers &ndash; New York, London, San Francisco, Los Angeles, Chicago and Boston. Baker Tilly Advisory Group, LP and Baker Tilly US, LLP (Baker Tilly) provide professional services through an alternative practice structure in accordance with the AICPA Code of Professional Conduct and applicable laws, regulations and professional standards. Baker Tilly US, LLP is a licensed independent CPA firm that provides attest services to its clients. Baker Tilly Advisory Group, LP and its subsidiary entities provide tax and business advisory services to their clients. Baker Tilly Advisory Group, LP and its subsidiary entities are not licensed CPA firms.</div><div>\\nBaker Tilly Advisory Group, LP and Baker Tilly US, LLP, trading as Baker Tilly, are independent members of Baker Tilly International, a worldwide network of independent accounting and business advisory firms in 141 territories, with 43,000 professionals and a combined worldwide revenue of $5.2 billion. Visit bakertilly.com or join the conversation on LinkedIn, Facebook and Instagram.</div><div></div><div>\\nPlease discuss the work location status with your Baker Tilly talent acquisition professional to understand the requirements for an opportunity you are exploring.</div><div></div><div><i>\\nBaker Tilly is an equal </i><i>opportunity/affirmative</i><i> action employer. All qualified applicants will receive consideration for employment without regard to race, color, religion, sex, national origin, disability or protected veteran status, gender identity, sexual orientation, or any other legally protected basis, in accordance with applicable federal, state or local law.</i></div><div></div><div><i>\\nAny unsolicited resumes submitted through our website or to Baker Tilly Advisory Group, LP, employee e-mail accounts are considered property of Baker Tilly Advisory Group, LP, and are not subject to payment of agency fees. In order to be an authorized recruitment agency (&quot;search firm&quot;) for Baker Tilly Advisory Group, LP, there must be a formal written agreement in place and the agency must be invited, by Baker Tilly's Talent Attraction team, to submit candidates for review via our applicant tracking system.</i></div><div></div><div>\\nJob Description:</div><div><br>\\nData Engineer</div><div></div><div>\\nKey Responsibilities:</div><ul><li><div>\\nCollaborate with clients and internal stakeholders to design and implement scalable data engineering solutions using the Microsoft Analytics ecosystem.</div></li><li><div>\\nDevelop and maintain data pipelines, ensuring efficient extraction, transformation, and loading (ETL) processes for structured and unstructured data.</div></li><li><div>\\nApply best practices in dimensional modeling to create robust and scalable data models for analytics and reporting.</div></li><li><div>\\nLeverage tools such as Python, dbt, and SQL to develop advanced data transformation and integration processes.</div></li><li><div>\\nOptimize data storage and retrieval mechanisms to support high-performance analytics workloads.</div></li><li><div>\\nImplement and manage hybrid analytics workloads using Azure Cloud infrastructure, including networking and security configurations.</div></li><li><div>\\nMonitor and troubleshoot data pipelines and workflows to ensure accuracy, reliability, and performance.</div></li><li><div>\\nCollaborate with analytics and BI teams to ensure seamless integration of data assets into Power BI and other reporting platforms.</div></li><li><div>\\nStay informed about emerging trends and technologies in data engineering and cloud analytics to enhance solution delivery.</div></li></ul><div></div><div>\\nRequired Qualifications:</div><ul><li><div>\\nTen (10) plus years experience in data engineering with expertise in the Microsoft Analytics stack (Fabric, Synapse, SQL, SSAS, SSRS).</div></li><li><div>\\nStrong proficiency in SQL, Python, and data modeling techniques.</div></li><li><div>\\nWorking knowledge of data extraction patterns and best practices.</div></li><li><div>\\nExperience with ETL tools and frameworks, such as dbt.</div></li><li><div>\\nSolid understanding of dimensional modeling and its application in analytics.</div></li><li><div>\\nStrong problem-solving skills with a focus on delivering scalable and efficient solutions.</div></li><li><div>\\nExcellent communication and collaboration skills, with experience in client-facing roles.</div></li></ul><div></div><div>\\nPreferred Qualifications:</div><ul><li><div>\\nExperience with Azure Cloud infrastructure, including hybrid analytics workload configurations and networking.</div></li><li><div>\\nCertifications in Azure Engineering (e.g., Azure Data Engineer Associate, Azure Solutions Architect Expert).</div></li><li><div>\\nExperience with Azure DevOps or GitHub for code repositories and deployment.</div></li><li><div>\\nFamiliarity with advanced analytics tools and concepts, including machine learning workflows.</div></li><li><div>\\nKnowledge of additional data visualization tools such as Tableau or Qlik.</div></li><li><div>\\nExperience with Agile methodologies for project management.</div></li></ul><div></div><div>\\nThe compensation range for this role is $141,530 to $306,640. Actual compensation is influenced by a variety of factors including but not limited to skills, experience, qualifications, and geographic location.</div></div><div></div>", "text": "Overview\\n\\nBaker Tilly is a leading advisory, tax and assurance firm, providing clients with a genuine coast-to-coast and global advantage in major regions of the U.S. and in many of the world\\u2019s leading financial centers \\u2013 New York, London, San Francisco, Los Angeles, Chicago and Boston. Baker Tilly Advisory Group, LP and Baker Tilly US, LLP (Baker Tilly) provide professional services through an alternative practice structure in accordance with the AICPA Code of Professional Conduct and applicable laws, regulations and professional standards. Baker Tilly US, LLP is a licensed independent CPA firm that provides attest services to its clients. Baker Tilly Advisory Group, LP and its subsidiary entities provide tax and business advisory services to their clients. Baker Tilly Advisory Group, LP and its subsidiary entities are not licensed CPA firms.\\n\\nBaker Tilly Advisory Group, LP and Baker Tilly US, LLP, trading as Baker Tilly, are independent members of Baker Tilly International, a worldwide network of independent accounting and business advisory firms in 141 territories, with 43,000 professionals and a combined worldwide revenue of $5.2 billion. Visit bakertilly.com or join the conversation on LinkedIn, Facebook and Instagram.\\n\\nPlease discuss the work location status with your Baker Tilly talent acquisition professional to understand the requirements for an opportunity you are exploring.\\n\\nBaker Tilly is an equal opportunity/affirmative action employer. All qualified applicants will receive consideration for employment without regard to race, color, religion, sex, national origin, disability or protected veteran status, gender identity, sexual orientation, or any other legally protected basis, in accordance with applicable federal, state or local law.\\n\\nAny unsolicited resumes submitted through our website or to Baker Tilly Advisory Group, LP, employee e-mail accounts are considered property of Baker Tilly Advisory Group, LP, and are not subject to payment of agency fees. In order to be an authorized recruitment agency (\\"search firm\\") for Baker Tilly Advisory Group, LP, there must be a formal written agreement in place and the agency must be invited, by Baker Tilly's Talent Attraction team, to submit candidates for review via our applicant tracking system.\\n\\nJob Description:\\n\\nData Engineer\\n\\nKey Responsibilities:\\n\\nCollaborate with clients and internal stakeholders to design and implement scalable data engineering solutions using the Microsoft Analytics ecosystem.\\n\\nDevelop and maintain data pipelines, ensuring efficient extraction, transformation, and loading (ETL) processes for structured and unstructured data.\\n\\nApply best practices in dimensional modeling to create robust and scalable data models for analytics and reporting.\\n\\nLeverage tools such as Python, dbt, and SQL to develop advanced data transformation and integration processes.\\n\\nOptimize data storage and retrieval mechanisms to support high-performance analytics workloads.\\n\\nImplement and manage hybrid analytics workloads using Azure Cloud infrastructure, including networking and security configurations.\\n\\nMonitor and troubleshoot data pipelines and workflows to ensure accuracy, reliability, and performance.\\n\\nCollaborate with analytics and BI teams to ensure seamless integration of data assets into Power BI and other reporting platforms.\\n\\nStay informed about emerging trends and technologies in data engineering and cloud analytics to enhance solution delivery.\\n\\nRequired Qualifications:\\n\\nTen (10) plus years experience in data engineering with expertise in the Microsoft Analytics stack (Fabric, Synapse, SQL, SSAS, SSRS).\\n\\nStrong proficiency in SQL, Python, and data modeling techniques.\\n\\nWorking knowledge of data extraction patterns and best practices.\\n\\nExperience with ETL tools and frameworks, such as dbt.\\n\\nSolid understanding of dimensional modeling and its application in analytics.\\n\\nStrong problem-solving skills with a focus on delivering scalable and efficient solutions.\\n\\nExcellent communication and collaboration skills, with experience in client-facing roles.\\n\\nPreferred Qualifications:\\n\\nExperience with Azure Cloud infrastructure, including hybrid analytics workload configurations and networking.\\n\\nCertifications in Azure Engineering (e.g., Azure Data Engineer Associate, Azure Solutions Architect Expert).\\n\\nExperience with Azure DevOps or GitHub for code repositories and deployment.\\n\\nFamiliarity with advanced analytics tools and concepts, including machine learning workflows.\\n\\nKnowledge of additional data visualization tools such as Tableau or Qlik.\\n\\nExperience with Agile methodologies for project management.\\n\\nThe compensation range for this role is $141,530 to $306,640. Actual compensation is influenced by a variety of factors including but not limited to skills, experience, qualifications, and geographic location.", "semanticSegments": []}, "location": {"__typename": "JobLocation", "countryCode": "US", "admin1Code": "TX", "admin2Code": "113", "admin3Code": null, "admin4Code": null, "city": "Dallas", "postalCode": null, "latitude": 32.78306, "longitude": -96.80667, "streetAddress": null, "formatted": {"__typename": "FormattedJobLocation", "long": "Dallas, TX", "short": "Dallas, TX"}}, "occupations": [{"__typename": "JobOccupation", "key": "6D2D2", "label": "Data & Database Occupations"}, {"__typename": "JobOccupation", "key": "EHPW9", "label": "Technology Occupations"}, {"__typename": "JobOccupation", "key": "XXX29", "label": "Data Developers"}], "occupationMostLikelySuids": [{"__typename": "JobOccupation", "key": "XXX29"}], "benefits": [], "socialInsurance": [], "workingSystem": [], "requiredDocumentsCategorizedAttributes": [], "indeedApply": {"__typename": "JobIndeedApplyAttributes", "key": null, "scopes": []}, "attributes": [{"__typename": "JobAttribute", "key": "4WK64", "label": "Power BI"}, {"__typename": "JobAttribute", "key": "5M3JZ", "label": "Data modeling"}, {"__typename": "JobAttribute", "key": "5QGV8", "label": "Cloud infrastructure"}, {"__typename": "JobAttribute", "key": "64VXT", "label": "Azure"}, {"__typename": "JobAttribute", "key": "9VXTC", "label": "Software deployment"}, {"__typename": "JobAttribute", "key": "AA24C", "label": "DevOps"}, {"__typename": "JobAttribute", "key": "CF3CP", "label": "Full-time"}, {"__typename": "JobAttribute", "key": "D3N2T", "label": "SSRS"}, {"__typename": "JobAttribute", "key": "DN563", "label": "Mid-level"}, {"__typename": "JobAttribute", "key": "EBFTN", "label": "Tableau"}, {"__typename": "JobAttribute", "key": "FGY89", "label": "SQL"}, {"__typename": "JobAttribute", "key": "GWNE7", "label": "Project management"}, {"__typename": "JobAttribute", "key": "HT6WW", "label": "Machine learning"}, {"__typename": "JobAttribute", "key": "PFTHH", "label": "GitHub"}, {"__typename": "JobAttribute", "key": "PRGNY", "label": "ETL"}, {"__typename": "JobAttribute", "key": "QE236", "label": "Agile"}, {"__typename": "JobAttribute", "key": "TKG4S", "label": "Data visualization"}, {"__typename": "JobAttribute", "key": "WSBNK", "label": "Communication skills"}, {"__typename": "JobAttribute", "key": "X62BT", "label": "Python"}, {"__typename": "JobAttribute", "key": "ZK3HH", "label": "Analytics"}, {"__typename": "JobAttribute", "key": "ZSXMF", "label": "10 years"}], "employerProvidedAttributes": [{"__typename": "JobAttribute", "key": "CF3CP", "label": "Full-time"}], "employerProvidedOccupations": [], "hiringDemand": {"__typename": "HiringDemand", "isUrgentHire": false, "isHighVolumeHiring": false}, "thirdPartyTrackingUrls": [], "jobSearchMobileMigrationData": null, "jobStats": {"__typename": "JobStats", "organicApplyStarts": 0}, "isRepost": true, "isLatestPost": true, "isPlacement": null, "employer": {"__typename": "Employer", "key": "f17d9171b9d09b29", "tier": "FREE", "relativeCompanyPageUrl": "/cmp/Baker-Tilly", "dossier": {"__typename": "EmployerDossier", "images": {"__typename": "ImageBundle", "rectangularLogoUrl": "https://d2q79iu7y748jz.cloudfront.net/s/_logo/809d37b2717f610c5b60b5e2ef21e337", "headerImageUrls": {"__typename": "HeaderImageUrlBundle", "url1960x400": "https://d2q79iu7y748jz.cloudfront.net/s/_headerimage/1960x400/474048c9601a156488b4661b748e00d6"}, "squareLogoUrls": {"__typename": "SquareLogoUrlBundle", "url256": "https://d2q79iu7y748jz.cloudfront.net/s/_squarelogo/256x256/4c3189157efbb4a47ff03b6d4acbfe8a"}}}, "ugcStats": {"__typename": "JobseekerUgcStats", "globalReviewCount": 638, "ratings": {"__typename": "RatingBundle", "overallRating": {"__typename": "AverageRating", "count": 638, "value": 3.7}}}, "subsidiaryOptOutStatusV2": false, "parentEmployer": null}, "jobTypes": [{"__typename": "JobAttribute", "key": "CF3CP", "label": "Full-time"}], "shiftAndSchedule": [], "compensation": {"__typename": "JobCompensation", "key": "CN2JlOEjHUDVWkggh6kWKIepFjDm3BM4m8QBQghmdWxsdGltZUoNRGF0YSBFbmdpbmVlclCS9ANiIgoeCgoNgDYKSBUAupVIEAUYBSIKCKjq3wYQwMrPDigCeAFqDWRhdGEgZW5naW5lZXJw2IuDwsYyigEFWFhYMjmSARIKDgoKDbZ35EcVPaUQSBAFeAGiAVwKA1NFUxIJZXN0U2FsYXJ5GhAKA21pbhAEOQAAAMD2jvxAGhAKA21heBAEOQAAAKCnFAJBGhMKB3NhbFR5cGUQAioGWUVBUkxZGhEKCGN1cnJlbmN5EAIqA1VTRKoBAlVTsgECVFi6AQZEYWxsYXM="}, "applicants": null}, "matchComparisonResult": {"__typename": "MatchComparisonEngineMatchResult", "attributeComparisons": [{"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "SQL", "lastModified": 0, "suid": "FGY89", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Analytics", "lastModified": 0, "suid": "ZK3HH", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "MUST_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Agile", "lastModified": 0, "suid": "QE236", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "GitHub", "lastModified": 0, "suid": "PFTHH", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Data modeling", "lastModified": 0, "suid": "5M3JZ", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "MUST_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Software deployment", "lastModified": 0, "suid": "9VXTC", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Power BI", "lastModified": 0, "suid": "4WK64", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Python", "lastModified": 0, "suid": "X62BT", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "MUST_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "SSRS", "lastModified": 0, "suid": "D3N2T", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "MUST_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "DevOps", "lastModified": 0, "suid": "AA24C", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Data visualization", "lastModified": 0, "suid": "TKG4S", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Tableau", "lastModified": 0, "suid": "EBFTN", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Project management", "lastModified": 0, "suid": "GWNE7", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Communication skills", "lastModified": 0, "suid": "WSBNK", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Azure", "lastModified": 0, "suid": "64VXT", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Machine learning", "lastModified": 0, "suid": "HT6WW", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Cloud infrastructure", "lastModified": 0, "suid": "5QGV8", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "ETL", "lastModified": 0, "suid": "PRGNY", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "MUST_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}], "encouragementToApply": {"__typename": "MatchComparisonEngineEncouragementToApply", "score": 0, "strategy": "", "trafficLight": "YELLOW"}, "matchOverlapMetric": {"__typename": "MatchComparisonEngineMatchOverlapMetric", "coverage": 0, "jobDetailScore": 0, "locationScore": 0, "matchOverlapScore": 0, "payScore": 0, "qualificationOverlapScore": 0, "version": 0}, "occupationComparisons": [{"__typename": "MatchComparisonEngineOccupationComparison", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY", "occupation": {"__typename": "MatchComparisonEngineOccupation", "label": "Data Developers", "suid": "XXX29"}}]}}]}}, "errors": [], "query": "query getViewJobJobData($jobKey: ID!, $jobKeyString: String!, $shouldQueryCogsEligibility: Boolean!, $shouldQuerySavedJob: Boolean!, $shouldQueryTitleNorm: Boolean!, $shouldQueryCompanyFields: Boolean!, $shouldQuerySalary: Boolean!, $shouldQueryIndeedApplyLink: Boolean!, $shouldQueryParentEmployer: Boolean!, $shouldQuerySentiment: Boolean!, $shouldIncludeFragmentZone: Boolean!, $shouldQueryMatchComparison: Boolean!, $shouldQueryApplicantInsights: Boolean!, $shouldQueryJobCampaignsConnection: Boolean!, $shouldQueryJobSeekerPreferences: Boolean!, $shouldQueryJobSeekerProfileQuestions: Boolean!, $mobvjtk: String!, $continueUrl: String!, $spn: Boolean!, $jobDataInput: JobDataInput!) {\\n  jobData(input: $jobDataInput) {\\n    __typename\\n    results {\\n      __typename\\n      trackingKey\\n      job {\\n        __typename\\n        key\\n        ...jobDataFields\\n        ...titleNormFields@include(if: $shouldQueryTitleNorm)\\n        ...companyFields@include(if: $shouldQueryCompanyFields)\\n        ...parentEmployerFields@include(if: $shouldQueryParentEmployer)\\n        jobSearchMobileMigrationData @include(if: $shouldQuerySentiment) {\\n          __typename\\n          knownUserSentimentIdMap {\\n            __typename\\n            id\\n            suid\\n          }\\n          userStringDislikedPreferences {\\n            __typename\\n            uid\\n          }\\n          userMinimumPayPreferences {\\n            __typename\\n            currency\\n            payAmount\\n            salaryType\\n          }\\n          preferencesFetchStatus\\n          paySentiment\\n        }\\n        jobTypes: attributes(customClass: \\"BM62A\\") {\\n          __typename\\n          key\\n          label\\n          sentiment @include(if: $shouldQuerySentiment)\\n        }\\n        shiftAndSchedule: attributes(customClass: \\"BTSWR\\") {\\n          __typename\\n          key\\n          label\\n          sentiment @include(if: $shouldQuerySentiment)\\n        }\\n        compensation @include(if: $shouldQuerySalary) {\\n          __typename\\n          key\\n        }\\n        indeedApply @include(if: $shouldQueryIndeedApplyLink) {\\n          __typename\\n          applyLink(property: INDEED, trackingKeys: {mobvjtk : $mobvjtk}, continueUrl: $continueUrl, spn: $spn) {\\n            __typename\\n            url\\n            iaUid\\n          }\\n        }\\n        ...ViewJobFragmentZone@include(if: $shouldIncludeFragmentZone)\\n        applicants @include(if: $shouldQueryApplicantInsights) {\\n          __typename\\n          hasInsights\\n          ...ApplicantDemographicsFields\\n        }\\n        jobCampaignsConnection(input: {spendingEligibilityTypes : [FUNDED_PERIOD_ELIGIBILITY]}) @include(if: $shouldQueryJobCampaignsConnection) {\\n          __typename\\n          campaignCount\\n        }\\n      }\\n      matchComparisonResult @include(if: $shouldQueryMatchComparison) {\\n        __typename\\n        attributeComparisons {\\n          __typename\\n          jobProvenance\\n          attribute {\\n            __typename\\n            interestedParty\\n            label\\n            lastModified\\n            suid\\n            profileAttributeTypeSuid\\n          }\\n          jobRequirementStrength\\n          jsProvenance\\n          matchType\\n        }\\n        encouragementToApply {\\n          __typename\\n          score\\n          strategy\\n          trafficLight\\n        }\\n        matchOverlapMetric {\\n          __typename\\n          coverage\\n          jobDetailScore\\n          locationScore\\n          matchOverlapScore\\n          payScore\\n          qualificationOverlapScore\\n          version\\n        }\\n        occupationComparisons {\\n          __typename\\n          jsProvenance\\n          matchType\\n          occupation {\\n            __typename\\n            label\\n            suid\\n          }\\n        }\\n      }\\n    }\\n  }\\n  savedJobsByKey(keys: [$jobKey]) @include(if: $shouldQuerySavedJob) {\\n    __typename\\n    state\\n    currentStateTime\\n  }\\n  cogsCheckEligibility(input: {jobKey : $jobKeyString}) @include(if: $shouldQueryCogsEligibility) {\\n    __typename\\n    error\\n    isEligible\\n  }\\n  jobSeekerProfile @include(if: $shouldQueryApplicantInsights) {\\n    __typename\\n    profile {\\n      __typename\\n      jobSeekerPro {\\n        __typename\\n        status\\n      }\\n    }\\n  }\\n  jobSeekerProfileStructuredData(input: {queryFilter : {dataCategory : CONFIRMED_BY_USER}}) @include(if: $shouldQueryJobSeekerPreferences) {\\n    __typename\\n    preferences {\\n      __typename\\n      jobTitles {\\n        __typename\\n        jobTitle\\n      }\\n      minimumPay {\\n        __typename\\n        amount\\n        salaryType\\n      }\\n    }\\n  }\\n  jobSeekerProfileQuestionFieldSet(input: {source : VJP_GATING}) @include(if: $shouldQueryJobSeekerProfileQuestions) {\\n    __typename\\n    questionFields {\\n      __typename\\n      name\\n    }\\n  }\\n}\\n\\nfragment jobDataFields on Job {\\n  __typename\\n  title\\n  sourceEmployerName\\n  datePublished\\n  expired\\n  language\\n  normalizedTitle\\n  refNum\\n  expirationDate\\n  source {\\n    __typename\\n    key\\n    name\\n  }\\n  feed {\\n    __typename\\n    key\\n    isDradis\\n    feedSourceType\\n  }\\n  url\\n  dateOnIndeed\\n  description {\\n    __typename\\n    html\\n    text\\n    semanticSegments {\\n      __typename\\n      content\\n      header\\n      label\\n    }\\n  }\\n  location {\\n    __typename\\n    countryCode\\n    admin1Code\\n    admin2Code\\n    admin3Code\\n    admin4Code\\n    city\\n    postalCode\\n    latitude\\n    longitude\\n    streetAddress\\n    formatted {\\n      __typename\\n      long\\n      short\\n    }\\n  }\\n  occupations {\\n    __typename\\n    key\\n    label\\n  }\\n  occupationMostLikelySuids: occupations(occupationOption: MOST_LIKELY) {\\n    __typename\\n    key\\n  }\\n  benefits: attributes(customClass: \\"SXMYH\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  socialInsurance: attributes(customClass: \\"KTQQ7\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  workingSystem: attributes(customClass: \\"TY4DY\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  requiredDocumentsCategorizedAttributes: attributes(customClass: \\"PQCTE\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  indeedApply {\\n    __typename\\n    key\\n    scopes\\n  }\\n  attributes {\\n    __typename\\n    key\\n    label\\n  }\\n  employerProvidedAttributes: attributes(sources: [EMPLOYER]) {\\n    __typename\\n    key\\n    label\\n  }\\n  employerProvidedOccupations: occupations(sources: [EMPLOYER], occupationOption: MOST_SPECIFIC) {\\n    __typename\\n    label\\n  }\\n  hiringDemand {\\n    __typename\\n    isUrgentHire\\n    isHighVolumeHiring\\n  }\\n  thirdPartyTrackingUrls\\n  jobSearchMobileMigrationData {\\n    __typename\\n    advertiserId\\n    jobTypeId\\n    applyEmail\\n    applyUrl\\n    contactEmail\\n    contactPhone\\n    isNoUniqueUrl\\n    urlRewriteRule\\n    mapDisplayType\\n    jobTags\\n    locCountry\\n    waldoVisibilityLevel\\n    isKnownSponsoredOnDesktop\\n    isKnownSponsoredOnMobile\\n    tpiaAdvNum\\n    tpiaApiToken\\n    tpiaCoverLetter\\n    tpiaEmail\\n    tpiaFinishAppUrl\\n    tpiaJobCompanyName\\n    tpiaJobId\\n    tpiaJobLocation\\n    tpiaJobMeta\\n    tpiaJobTitle\\n    tpiaLocale\\n    tpiaName\\n    tpiaPhone\\n    tpiaPostUrl\\n    tpiaPresent\\n    tpiaResume\\n    tpiaResumeFieldsOptional\\n    tpiaResumeFieldsRequired\\n    tpiaScreenerQuestions\\n    iaVisibility\\n    hasPreciseLocation\\n    algoKey\\n  }\\n  jobStats {\\n    __typename\\n    organicApplyStarts\\n  }\\n  isRepost\\n  isLatestPost\\n  isPlacement\\n}\\n\\nfragment titleNormFields on Job {\\n  __typename\\n  normalizedTitle\\n  displayTitle\\n}\\n\\nfragment companyFields on Job {\\n  __typename\\n  employer {\\n    __typename\\n    key\\n    tier\\n    relativeCompanyPageUrl\\n    dossier {\\n      __typename\\n      images {\\n        __typename\\n        rectangularLogoUrl\\n        headerImageUrls {\\n          __typename\\n          url1960x400\\n        }\\n        squareLogoUrls {\\n          __typename\\n          url256\\n        }\\n      }\\n    }\\n    ugcStats {\\n      __typename\\n      globalReviewCount\\n      ratings {\\n        __typename\\n        overallRating {\\n          __typename\\n          count\\n          value\\n        }\\n      }\\n    }\\n  }\\n}\\n\\nfragment parentEmployerFields on Job {\\n  __typename\\n  employer {\\n    __typename\\n    subsidiaryOptOutStatusV2\\n    parentEmployer {\\n      __typename\\n      name\\n      subsidiaryOptOutStatusV2\\n    }\\n  }\\n}\\n\\nfragment ViewJobFragmentZone on Job {\\n  key\\n  __typename\\n}\\n\\nfragment ApplicantDemographicsFields on Applicants {\\n  __typename\\n  count {\\n    __typename\\n    total\\n    last24h\\n  }\\n  workExperience {\\n    __typename\\n    title\\n    pct\\n  }\\n  education {\\n    __typename\\n    title\\n    pct\\n  }\\n  skills {\\n    __typename\\n    title\\n    pct\\n  }\\n  certificates {\\n    __typename\\n    title\\n    pct\\n  }\\n}\\n", "variables": {"jobKey": "4e89e05beea188ca", "jobKeyString": "4e89e05beea188ca", "shouldQueryCogsEligibility": false, "shouldQuerySavedJob": false, "shouldQueryTitleNorm": false, "shouldQueryCompanyFields": true, "shouldQuerySalary": true, "shouldQueryIndeedApplyLink": false, "shouldQueryParentEmployer": true, "shouldQuerySentiment": false, "shouldIncludeFragmentZone": false, "shouldQueryMatchComparison": true, "shouldQueryApplicantInsights": false, "shouldQueryJobCampaignsConnection": false, "shouldQueryJobSeekerPreferences": false, "shouldQueryJobSeekerProfileQuestions": false, "mobvjtk": "1ihka2d8mgn2i800", "continueUrl": "http://www.indeed.com/viewjob?jk=4e89e05beea188ca&from=serp&vjs=3&applied=1", "spn": false, "jobDataInput": {"jobKeys": ["4e89e05beea188ca"], "useSearchlessPrice": false}}}}	INDEED	DATA_ENGINEER	2025-01-15 00:23:48.138497+00	f	\N	\N
4	/rc/clk?jk=aace53e500b5c7c7&bb=nVAi1dqOC2Ptfy5ocQiBhVsxAQTQafg3TJuFzbLeUsdcCMILBNnpmsbDEVhfZC_LGjnewooGLvxdf1VkN0cxuckBF--oBR1l30wtQERvKrROXHNTxHEc6gOjrp-yM0sh&xkcb=SoAh67M330bz7mSxXB0PbzkdCdPP&fccid=7cb49649b2bce8f9&vjs=3	{"host_query_execution_result": {"data": {"jobData": {"__typename": "JobDataPayload", "results": [{"__typename": "JobDataResult", "trackingKey": "5-cmh1-3-1ihka3ss8g5gj801", "job": {"__typename": "Job", "key": "aace53e500b5c7c7", "title": "Data Engineer", "sourceEmployerName": "Tronair", "datePublished": 1736834400000, "expired": false, "language": "en", "normalizedTitle": "data engineer", "refNum": "8a7883ac9447f8c5019466542ad57634", "expirationDate": null, "source": {"__typename": "JobSource", "key": "AAAAAfW8WgMnxOddCBSlMj5aOhG2uPMR8ZxESsk3z3ioxsF1kp6oTA==", "name": "Tronair"}, "feed": {"__typename": "JobFeed", "key": "AAAAAWWNee+jFGM4xVQ12+IkdpuTQBN2FjrP2VFSLfVnDV2fAYfbhg==", "isDradis": false, "feedSourceType": "EMPLOYER"}, "url": "https://recruitingbypaycor.com/career/JobIntroduction.action?id=8a7883ac9447f8c5019466542ad57634&source=Indeed+Free", "dateOnIndeed": 1736900664000, "description": {"__typename": "JobDescription", "html": "<div><div>Position Summary</div>\\n<div></div><div>The Data Engineer designs and supports data systems, maintenance processes and projects by using Azure services such as Data Factory, Databricks, Synapse Analytics, Data Lake, and Blob storage along with proficiency om SQL programming languages like Python or Scala.</div>\\n<div></div><div>Essential Functions</div>\\n<ul><li>Designs and writes code for RTL data solutions.</li>\\n<li>Plans and executes data implementations following system requirements and anticipated usage.</li>\\n<li>Performs data extraction, ensures data accuracy, troubleshoots and resolves bugs during data operations.</li>\\n<li>Analyzes business intelligence data and designs and generates reports.</li>\\n<li>Understands and utilizes ETL tools like Informatica and programming languages like Python.</li>\\n<li>Acts a liaison between IT and business units.</li>\\n</ul><div>Qualifications</div>\\n<ul><li>Bachelor&rsquo;s degree in information technology or related field required.</li>\\n<li>2 &ndash; 4 years of related experience required.</li>\\n<li>Certified in Microsoft Certified: Azure Data Engineer Associate is preferred.</li>\\n<li>Skilled in building and managing ETL pipelines, big data workflows, and scalable data solutions within Azure&rsquo;s ecosystem.</li>\\n<li>Experience in cloud-native architecture, data security, and compliance in regulated industries.</li>\\n<li>Higher education and/or experience that is directly related to the duties and responsibilities specified may be interchangeable on a year for year basis.</li>\\n<li>Excellent written and oral communication skills</li>\\n<li>Knowledge of a wide range of computer systems software, applications, hardware, networking, and communications.</li>\\n<li>Ability to perform routine preventive maintenance on systems software, applications, hardware, networking, and communications.</li>\\n<li>Ability to determine computer problems and to coordinate hardware, software, and/or network solutions.</li>\\n<li>Ability to analyze and resolve basic computer problems.</li>\\n<li>Ability to communicate technical guidance and instruction to users on using PC, server, and/or network applications and systems.</li>\\n</ul><div>Physical Requirements</div>\\n<div></div><div>The physical demands described here are representative of those that must be met by an employee to successfully perform the essential functions of this position. While performing the duties of this position, the employee must be able to:</div>\\n<ul><li>Routinely sit, sometimes for extended periods, and work on a computer;</li>\\n<li>Stand, walk, stoop, kneel, crouch or crawl</li>\\n<li>Occasionally lift up to 15 pounds</li>\\n<li>Occasionally lift up to 50 pounds with assistance</li>\\n<li>At such times, a greater amount of physical exertion, standing and walking would be required.</li>\\n</ul><div>Work Environment</div>\\n<div></div><div>The work environment characteristics described are representative of those an employee encounters while performing the essential functions of this position. The noise level in the work environment when in the office is usually quiet, and usually louder in the manufacturing environment.</div>\\n<div></div><div><i>This job description reflects management&rsquo;s assignment of essential functions. It does not prescribe or restrict the tasks that may be assigned. Critical features of this job are described under the headings above. They are subject to change at any time in the course of normal business operations.</i></div>\\n<div></div><div><b><i>Tronair is an EEO/AA employer - M/F/Disabled/Veteran</i></b></div></div>", "text": "Position Summary\\n\\nThe Data Engineer designs and supports data systems, maintenance processes and projects by using Azure services such as Data Factory, Databricks, Synapse Analytics, Data Lake, and Blob storage along with proficiency om SQL programming languages like Python or Scala.\\n\\nEssential Functions\\nDesigns and writes code for RTL data solutions.\\nPlans and executes data implementations following system requirements and anticipated usage.\\nPerforms data extraction, ensures data accuracy, troubleshoots and resolves bugs during data operations.\\nAnalyzes business intelligence data and designs and generates reports.\\nUnderstands and utilizes ETL tools like Informatica and programming languages like Python.\\nActs a liaison between IT and business units.\\nQualifications\\nBachelor\\u2019s degree in information technology or related field required.\\n2 \\u2013 4 years of related experience required.\\nCertified in Microsoft Certified: Azure Data Engineer Associate is preferred.\\nSkilled in building and managing ETL pipelines, big data workflows, and scalable data solutions within Azure\\u2019s ecosystem.\\nExperience in cloud-native architecture, data security, and compliance in regulated industries.\\nHigher education and/or experience that is directly related to the duties and responsibilities specified may be interchangeable on a year for year basis.\\nExcellent written and oral communication skills\\nKnowledge of a wide range of computer systems software, applications, hardware, networking, and communications.\\nAbility to perform routine preventive maintenance on systems software, applications, hardware, networking, and communications.\\nAbility to determine computer problems and to coordinate hardware, software, and/or network solutions.\\nAbility to analyze and resolve basic computer problems.\\nAbility to communicate technical guidance and instruction to users on using PC, server, and/or network applications and systems.\\nPhysical Requirements\\n\\nThe physical demands described here are representative of those that must be met by an employee to successfully perform the essential functions of this position. While performing the duties of this position, the employee must be able to:\\nRoutinely sit, sometimes for extended periods, and work on a computer;\\nStand, walk, stoop, kneel, crouch or crawl\\nOccasionally lift up to 15 pounds\\nOccasionally lift up to 50 pounds with assistance\\nAt such times, a greater amount of physical exertion, standing and walking would be required.\\nWork Environment\\n\\nThe work environment characteristics described are representative of those an employee encounters while performing the essential functions of this position. The noise level in the work environment when in the office is usually quiet, and usually louder in the manufacturing environment.\\n\\nThis job description reflects management\\u2019s assignment of essential functions. It does not prescribe or restrict the tasks that may be assigned. Critical features of this job are described under the headings above. They are subject to change at any time in the course of normal business operations.\\n\\nTronair is an EEO/AA employer - M/F/Disabled/Veteran", "semanticSegments": []}, "location": {"__typename": "JobLocation", "countryCode": "US", "admin1Code": "OH", "admin2Code": "051", "admin3Code": null, "admin4Code": null, "city": "Swanton", "postalCode": "43558", "latitude": 41.582684, "longitude": -83.81017, "streetAddress": "Swanton,OH 43558", "formatted": {"__typename": "FormattedJobLocation", "long": "Swanton, OH 43558", "short": "Swanton, OH"}}, "occupations": [{"__typename": "JobOccupation", "key": "6D2D2", "label": "Data & Database Occupations"}, {"__typename": "JobOccupation", "key": "EHPW9", "label": "Technology Occupations"}, {"__typename": "JobOccupation", "key": "XXX29", "label": "Data Developers"}], "occupationMostLikelySuids": [{"__typename": "JobOccupation", "key": "XXX29"}], "benefits": [], "socialInsurance": [], "workingSystem": [], "requiredDocumentsCategorizedAttributes": [], "indeedApply": {"__typename": "JobIndeedApplyAttributes", "key": null, "scopes": []}, "attributes": [{"__typename": "JobAttribute", "key": "64VXT", "label": "Azure"}, {"__typename": "JobAttribute", "key": "6H8NX", "label": "Cloud architecture"}, {"__typename": "JobAttribute", "key": "6XNCP", "label": "Computer Science"}, {"__typename": "JobAttribute", "key": "73VKZ", "label": "Data lake"}, {"__typename": "JobAttribute", "key": "DN563", "label": "Mid-level"}, {"__typename": "JobAttribute", "key": "DN85V", "label": "Office"}, {"__typename": "JobAttribute", "key": "FGY89", "label": "SQL"}, {"__typename": "JobAttribute", "key": "G7ZZD", "label": "Ability to lift 50 pounds"}, {"__typename": "JobAttribute", "key": "HFDVW", "label": "Bachelor's degree"}, {"__typename": "JobAttribute", "key": "JQ94N", "label": "Scala"}, {"__typename": "JobAttribute", "key": "MQGT6", "label": "Ability to sit for extended periods"}, {"__typename": "JobAttribute", "key": "QUSBH", "label": "Computer skills"}, {"__typename": "JobAttribute", "key": "UM4V9", "label": "Informatica"}, {"__typename": "JobAttribute", "key": "UTPWG", "label": "Associate's degree"}, {"__typename": "JobAttribute", "key": "W6GUJ", "label": "2 years"}, {"__typename": "JobAttribute", "key": "WSBNK", "label": "Communication skills"}, {"__typename": "JobAttribute", "key": "X62BT", "label": "Python"}, {"__typename": "JobAttribute", "key": "ZPP7S", "label": "Information Technology"}], "employerProvidedAttributes": [], "employerProvidedOccupations": [], "hiringDemand": {"__typename": "HiringDemand", "isUrgentHire": false, "isHighVolumeHiring": false}, "thirdPartyTrackingUrls": [], "jobSearchMobileMigrationData": null, "jobStats": {"__typename": "JobStats", "organicApplyStarts": 13}, "isRepost": false, "isLatestPost": true, "isPlacement": null, "employer": {"__typename": "Employer", "key": "0a54b0fa5ed4ab0d", "tier": "ENTERPRISE", "relativeCompanyPageUrl": "/cmp/Tronair", "dossier": {"__typename": "EmployerDossier", "images": {"__typename": "ImageBundle", "rectangularLogoUrl": null, "headerImageUrls": {"__typename": "HeaderImageUrlBundle", "url1960x400": "https://d2q79iu7y748jz.cloudfront.net/s/_headerimage/1960x400/729ec1dfd26ec218613d98c9c4c9df94"}, "squareLogoUrls": {"__typename": "SquareLogoUrlBundle", "url256": "https://d2q79iu7y748jz.cloudfront.net/s/_squarelogo/256x256/3cdca47396830ae7022d85e5e456d36d"}}}, "ugcStats": {"__typename": "JobseekerUgcStats", "globalReviewCount": 98, "ratings": {"__typename": "RatingBundle", "overallRating": {"__typename": "AverageRating", "count": 98, "value": 2.8}}}, "subsidiaryOptOutStatusV2": false, "parentEmployer": null}, "jobTypes": [], "shiftAndSchedule": [], "compensation": {"__typename": "JobCompensation", "key": "CJvfhOEjHQAOnEcgsbFOKLGxTjCUu7ICOLZlSg1EYXRhIEVuZ2luZWVyUJL0A2oNZGF0YSBlbmdpbmVlcnDAteO6xjKKAQVYWFgyOZIBEgoOCgoNrNmJRxWWjK5HEAV4AaIBXAoDU0VTEgllc3RTYWxhcnkaEAoDbWluEAQ5AAAAgDU78UAaEAoDbWF4EAQ5AAAAwJLR9UAaEwoHc2FsVHlwZRACKgZZRUFSTFkaEQoIY3VycmVuY3kQAioDVVNEqgECVVOyAQJPSLoBB1N3YW50b24="}, "applicants": null}, "matchComparisonResult": {"__typename": "MatchComparisonEngineMatchResult", "attributeComparisons": [{"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Python", "lastModified": 0, "suid": "X62BT", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "SQL", "lastModified": 0, "suid": "FGY89", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Bachelor's degree", "lastModified": 0, "suid": "HFDVW", "profileAttributeTypeSuid": "NP7FU"}, "jobRequirementStrength": "MUST_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Associate's degree", "lastModified": 0, "suid": "UTPWG", "profileAttributeTypeSuid": "NP7FU"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Information Technology", "lastModified": 0, "suid": "ZPP7S", "profileAttributeTypeSuid": ""}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Informatica", "lastModified": 0, "suid": "UM4V9", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Computer Science", "lastModified": 0, "suid": "6XNCP", "profileAttributeTypeSuid": ""}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Data lake", "lastModified": 0, "suid": "73VKZ", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Communication skills", "lastModified": 0, "suid": "WSBNK", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Cloud architecture", "lastModified": 0, "suid": "6H8NX", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Azure", "lastModified": 0, "suid": "64VXT", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "MUST_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Computer skills", "lastModified": 0, "suid": "QUSBH", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Scala", "lastModified": 0, "suid": "JQ94N", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}], "encouragementToApply": {"__typename": "MatchComparisonEngineEncouragementToApply", "score": 0, "strategy": "", "trafficLight": "YELLOW"}, "matchOverlapMetric": {"__typename": "MatchComparisonEngineMatchOverlapMetric", "coverage": 0, "jobDetailScore": 0, "locationScore": 0, "matchOverlapScore": 0, "payScore": 0, "qualificationOverlapScore": 0, "version": 0}, "occupationComparisons": [{"__typename": "MatchComparisonEngineOccupationComparison", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY", "occupation": {"__typename": "MatchComparisonEngineOccupation", "label": "Data Developers", "suid": "XXX29"}}]}}]}}, "errors": [], "query": "query getViewJobJobData($jobKey: ID!, $jobKeyString: String!, $shouldQueryCogsEligibility: Boolean!, $shouldQuerySavedJob: Boolean!, $shouldQueryTitleNorm: Boolean!, $shouldQueryCompanyFields: Boolean!, $shouldQuerySalary: Boolean!, $shouldQueryIndeedApplyLink: Boolean!, $shouldQueryParentEmployer: Boolean!, $shouldQuerySentiment: Boolean!, $shouldIncludeFragmentZone: Boolean!, $shouldQueryMatchComparison: Boolean!, $shouldQueryApplicantInsights: Boolean!, $shouldQueryJobCampaignsConnection: Boolean!, $shouldQueryJobSeekerPreferences: Boolean!, $shouldQueryJobSeekerProfileQuestions: Boolean!, $mobvjtk: String!, $continueUrl: String!, $spn: Boolean!, $jobDataInput: JobDataInput!) {\\n  jobData(input: $jobDataInput) {\\n    __typename\\n    results {\\n      __typename\\n      trackingKey\\n      job {\\n        __typename\\n        key\\n        ...jobDataFields\\n        ...titleNormFields@include(if: $shouldQueryTitleNorm)\\n        ...companyFields@include(if: $shouldQueryCompanyFields)\\n        ...parentEmployerFields@include(if: $shouldQueryParentEmployer)\\n        jobSearchMobileMigrationData @include(if: $shouldQuerySentiment) {\\n          __typename\\n          knownUserSentimentIdMap {\\n            __typename\\n            id\\n            suid\\n          }\\n          userStringDislikedPreferences {\\n            __typename\\n            uid\\n          }\\n          userMinimumPayPreferences {\\n            __typename\\n            currency\\n            payAmount\\n            salaryType\\n          }\\n          preferencesFetchStatus\\n          paySentiment\\n        }\\n        jobTypes: attributes(customClass: \\"BM62A\\") {\\n          __typename\\n          key\\n          label\\n          sentiment @include(if: $shouldQuerySentiment)\\n        }\\n        shiftAndSchedule: attributes(customClass: \\"BTSWR\\") {\\n          __typename\\n          key\\n          label\\n          sentiment @include(if: $shouldQuerySentiment)\\n        }\\n        compensation @include(if: $shouldQuerySalary) {\\n          __typename\\n          key\\n        }\\n        indeedApply @include(if: $shouldQueryIndeedApplyLink) {\\n          __typename\\n          applyLink(property: INDEED, trackingKeys: {mobvjtk : $mobvjtk}, continueUrl: $continueUrl, spn: $spn) {\\n            __typename\\n            url\\n            iaUid\\n          }\\n        }\\n        ...ViewJobFragmentZone@include(if: $shouldIncludeFragmentZone)\\n        applicants @include(if: $shouldQueryApplicantInsights) {\\n          __typename\\n          hasInsights\\n          ...ApplicantDemographicsFields\\n        }\\n        jobCampaignsConnection(input: {spendingEligibilityTypes : [FUNDED_PERIOD_ELIGIBILITY]}) @include(if: $shouldQueryJobCampaignsConnection) {\\n          __typename\\n          campaignCount\\n        }\\n      }\\n      matchComparisonResult @include(if: $shouldQueryMatchComparison) {\\n        __typename\\n        attributeComparisons {\\n          __typename\\n          jobProvenance\\n          attribute {\\n            __typename\\n            interestedParty\\n            label\\n            lastModified\\n            suid\\n            profileAttributeTypeSuid\\n          }\\n          jobRequirementStrength\\n          jsProvenance\\n          matchType\\n        }\\n        encouragementToApply {\\n          __typename\\n          score\\n          strategy\\n          trafficLight\\n        }\\n        matchOverlapMetric {\\n          __typename\\n          coverage\\n          jobDetailScore\\n          locationScore\\n          matchOverlapScore\\n          payScore\\n          qualificationOverlapScore\\n          version\\n        }\\n        occupationComparisons {\\n          __typename\\n          jsProvenance\\n          matchType\\n          occupation {\\n            __typename\\n            label\\n            suid\\n          }\\n        }\\n      }\\n    }\\n  }\\n  savedJobsByKey(keys: [$jobKey]) @include(if: $shouldQuerySavedJob) {\\n    __typename\\n    state\\n    currentStateTime\\n  }\\n  cogsCheckEligibility(input: {jobKey : $jobKeyString}) @include(if: $shouldQueryCogsEligibility) {\\n    __typename\\n    error\\n    isEligible\\n  }\\n  jobSeekerProfile @include(if: $shouldQueryApplicantInsights) {\\n    __typename\\n    profile {\\n      __typename\\n      jobSeekerPro {\\n        __typename\\n        status\\n      }\\n    }\\n  }\\n  jobSeekerProfileStructuredData(input: {queryFilter : {dataCategory : CONFIRMED_BY_USER}}) @include(if: $shouldQueryJobSeekerPreferences) {\\n    __typename\\n    preferences {\\n      __typename\\n      jobTitles {\\n        __typename\\n        jobTitle\\n      }\\n      minimumPay {\\n        __typename\\n        amount\\n        salaryType\\n      }\\n    }\\n  }\\n  jobSeekerProfileQuestionFieldSet(input: {source : VJP_GATING}) @include(if: $shouldQueryJobSeekerProfileQuestions) {\\n    __typename\\n    questionFields {\\n      __typename\\n      name\\n    }\\n  }\\n}\\n\\nfragment jobDataFields on Job {\\n  __typename\\n  title\\n  sourceEmployerName\\n  datePublished\\n  expired\\n  language\\n  normalizedTitle\\n  refNum\\n  expirationDate\\n  source {\\n    __typename\\n    key\\n    name\\n  }\\n  feed {\\n    __typename\\n    key\\n    isDradis\\n    feedSourceType\\n  }\\n  url\\n  dateOnIndeed\\n  description {\\n    __typename\\n    html\\n    text\\n    semanticSegments {\\n      __typename\\n      content\\n      header\\n      label\\n    }\\n  }\\n  location {\\n    __typename\\n    countryCode\\n    admin1Code\\n    admin2Code\\n    admin3Code\\n    admin4Code\\n    city\\n    postalCode\\n    latitude\\n    longitude\\n    streetAddress\\n    formatted {\\n      __typename\\n      long\\n      short\\n    }\\n  }\\n  occupations {\\n    __typename\\n    key\\n    label\\n  }\\n  occupationMostLikelySuids: occupations(occupationOption: MOST_LIKELY) {\\n    __typename\\n    key\\n  }\\n  benefits: attributes(customClass: \\"SXMYH\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  socialInsurance: attributes(customClass: \\"KTQQ7\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  workingSystem: attributes(customClass: \\"TY4DY\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  requiredDocumentsCategorizedAttributes: attributes(customClass: \\"PQCTE\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  indeedApply {\\n    __typename\\n    key\\n    scopes\\n  }\\n  attributes {\\n    __typename\\n    key\\n    label\\n  }\\n  employerProvidedAttributes: attributes(sources: [EMPLOYER]) {\\n    __typename\\n    key\\n    label\\n  }\\n  employerProvidedOccupations: occupations(sources: [EMPLOYER], occupationOption: MOST_SPECIFIC) {\\n    __typename\\n    label\\n  }\\n  hiringDemand {\\n    __typename\\n    isUrgentHire\\n    isHighVolumeHiring\\n  }\\n  thirdPartyTrackingUrls\\n  jobSearchMobileMigrationData {\\n    __typename\\n    advertiserId\\n    jobTypeId\\n    applyEmail\\n    applyUrl\\n    contactEmail\\n    contactPhone\\n    isNoUniqueUrl\\n    urlRewriteRule\\n    mapDisplayType\\n    jobTags\\n    locCountry\\n    waldoVisibilityLevel\\n    isKnownSponsoredOnDesktop\\n    isKnownSponsoredOnMobile\\n    tpiaAdvNum\\n    tpiaApiToken\\n    tpiaCoverLetter\\n    tpiaEmail\\n    tpiaFinishAppUrl\\n    tpiaJobCompanyName\\n    tpiaJobId\\n    tpiaJobLocation\\n    tpiaJobMeta\\n    tpiaJobTitle\\n    tpiaLocale\\n    tpiaName\\n    tpiaPhone\\n    tpiaPostUrl\\n    tpiaPresent\\n    tpiaResume\\n    tpiaResumeFieldsOptional\\n    tpiaResumeFieldsRequired\\n    tpiaScreenerQuestions\\n    iaVisibility\\n    hasPreciseLocation\\n    algoKey\\n  }\\n  jobStats {\\n    __typename\\n    organicApplyStarts\\n  }\\n  isRepost\\n  isLatestPost\\n  isPlacement\\n}\\n\\nfragment titleNormFields on Job {\\n  __typename\\n  normalizedTitle\\n  displayTitle\\n}\\n\\nfragment companyFields on Job {\\n  __typename\\n  employer {\\n    __typename\\n    key\\n    tier\\n    relativeCompanyPageUrl\\n    dossier {\\n      __typename\\n      images {\\n        __typename\\n        rectangularLogoUrl\\n        headerImageUrls {\\n          __typename\\n          url1960x400\\n        }\\n        squareLogoUrls {\\n          __typename\\n          url256\\n        }\\n      }\\n    }\\n    ugcStats {\\n      __typename\\n      globalReviewCount\\n      ratings {\\n        __typename\\n        overallRating {\\n          __typename\\n          count\\n          value\\n        }\\n      }\\n    }\\n  }\\n}\\n\\nfragment parentEmployerFields on Job {\\n  __typename\\n  employer {\\n    __typename\\n    subsidiaryOptOutStatusV2\\n    parentEmployer {\\n      __typename\\n      name\\n      subsidiaryOptOutStatusV2\\n    }\\n  }\\n}\\n\\nfragment ViewJobFragmentZone on Job {\\n  key\\n  __typename\\n}\\n\\nfragment ApplicantDemographicsFields on Applicants {\\n  __typename\\n  count {\\n    __typename\\n    total\\n    last24h\\n  }\\n  workExperience {\\n    __typename\\n    title\\n    pct\\n  }\\n  education {\\n    __typename\\n    title\\n    pct\\n  }\\n  skills {\\n    __typename\\n    title\\n    pct\\n  }\\n  certificates {\\n    __typename\\n    title\\n    pct\\n  }\\n}\\n", "variables": {"jobKey": "aace53e500b5c7c7", "jobKeyString": "aace53e500b5c7c7", "shouldQueryCogsEligibility": false, "shouldQuerySavedJob": false, "shouldQueryTitleNorm": false, "shouldQueryCompanyFields": true, "shouldQuerySalary": true, "shouldQueryIndeedApplyLink": false, "shouldQueryParentEmployer": true, "shouldQuerySentiment": false, "shouldIncludeFragmentZone": false, "shouldQueryMatchComparison": true, "shouldQueryApplicantInsights": false, "shouldQueryJobCampaignsConnection": false, "shouldQueryJobSeekerPreferences": false, "shouldQueryJobSeekerProfileQuestions": false, "mobvjtk": "1ihka3ss3gmj1800", "continueUrl": "http://www.indeed.com/viewjob?jk=aace53e500b5c7c7&from=serp&vjs=3&applied=1", "spn": false, "jobDataInput": {"jobKeys": ["aace53e500b5c7c7"], "useSearchlessPrice": false}}}}	INDEED	DATA_ENGINEER	2025-01-15 00:24:36.503933+00	f	\N	\N
5	/rc/clk?jk=59b52de9c80d5c5b&bb=nVAi1dqOC2Ptfy5ocQiBhRJC2DJfwcNptaLyHktO-WKzHdjP7zHYdWvQDK1ezWgKnH-1NNAK3xRLMJR8SQkVWFhyGqkvlxUmB6x9O2vLCQ7TPxQXIaaLMYpx6zJY2ofh&xkcb=SoCV67M330bz7mSxXB0ObzkdCdPP&fccid=1abee8392c419481&cmp=Divish-LLC&ti=Data+Engineer&vjs=3	{"host_query_execution_result": {"data": {"jobData": {"__typename": "JobDataPayload", "results": [{"__typename": "JobDataResult", "trackingKey": "5-cmh1-3-1ihka5b1j21mv001", "job": {"__typename": "Job", "key": "59b52de9c80d5c5b", "title": "Sr. Azure Data Engineer", "sourceEmployerName": "Divish LLC", "datePublished": 1736912372246, "expired": false, "language": "en", "normalizedTitle": "data engineer", "refNum": "16726041-450-1", "expirationDate": null, "source": {"__typename": "JobSource", "key": "AAAAAXHBlO0UQ6sSdYmnZmefK77j/yuDiOZeC4ttnKdwWAmu86lH+Q==", "name": "Indeed"}, "feed": {"__typename": "JobFeed", "key": "AAAAATz1LkceE6fW3CrsQgS0qpd3FVOf/lXNWNJPWjHwFa4uija1pw==", "isDradis": true, "feedSourceType": "EMPLOYER"}, "url": "http://www.indeed.com/job/sr-azure-data-engineer-59b52de9c80d5c5b", "dateOnIndeed": 1736912373000, "description": {"__typename": "JobDescription", "html": "<p><b>Job Overview</b><br/>We are seeking a skilled and motivated <b>Azure DataBricks Engineer</b> to join our dynamic team. The ideal candidate will be responsible for designing, building, and maintaining scalable data pipelines and architectures that support our analytics and business intelligence initiatives. This role requires a strong understanding of data management principles, as well as proficiency in various programming languages and cloud technologies.</p><p><b>Job title: Azure DataBricks Developer/ Engineer </b></p><p><b>Location: New Jersey </b></p><p><b>Term: Long term contract</b></p><p><b>Work style: Hybrid 3 days remote 2 days onsite</b></p><p>Key Requirement: <b>Stronger candidates with Financial Services Background who are open to going to office onsite twice a week is the Right Fit.</b></p><p><b>RESPONSIBILITIES</b><br/>Build large-scale batch and real-time data pipelines with data processing frameworks in Azure cloud platform.<br/>Designing and implementing highly performant data ingestion pipelines from multiple sources using Azure Databricks.<br/>Direct experience of building data pipelines using Azure Data Factory and Databricks.<br/>Developing scalable and re-usable frameworks for ingesting of datasets<br/>Lead design of ETL, data integration and data migration.<br/>Partner with architects, engineers, information analysts, business, and technology stakeholders for developing and deploying enterprise grade platforms that enable data-driven solutions.<br/>Integrating the end to end data pipeline - to take data from source systems to target data repositories ensuring the quality and consistency of data is maintained at all times<br/>Working with event based / streaming technologies to ingest and process data<br/>Working with other members of the project team to support delivery of additional project components (API interfaces, Search)<br/>Evaluating the performance and applicability of multiple tools against customer requirements</p><p><b>REQUIREMENTS</b><br/>Experience on ADLS, Azure Databricks, Azure SQL DB and Datawarehouse<br/>Strong working experience in Implementation of Azure cloud components using Azure Data Factory , Azure Data Analytics, Azure Data Lake, Azure Data Catalogue, LogicApps and FunctionApps<br/>Have knowledge in Azure Storage services (ADLS, Storage Accounts)<br/>Expertise in designing and deploying data applications on cloud solutions on Azure<br/>Hands on experience in performance tuning and optimizing code running in Databricks environment<br/>Good understanding of SQL, T-SQL and/or PL/SQL<br/>Should have experience working in Agile projects with knowledge in Jira<br/>Good to have handled Data Ingestion projects in Azure environment<br/>Demonstrated analytical and problem-solving skills particularly those that apply to a big data environment<br/>Experience on Python scripting, Spark SQL PySpark is a plus.</p><p>Also, <b>the consultant must be on-site in Jersey City twice a week</b>.</p><p>Join us in leveraging the power of data to drive business decisions and enhance operational efficiency!</p><p>Job Types: Full-time, Contract</p><p>Pay: $70.00 per hour</p><p>Expected hours: 40 per week</p><p>Compensation Package:</p><ul><li>1099 contract</li><li>Hourly pay</li></ul><p>Schedule:</p><ul><li>Monday to Friday</li></ul><p>Work Location: Hybrid remote in Jersey City, NJ 07302</p>", "text": "*Job Overview*\\nWe are seeking a skilled and motivated *Azure DataBricks Engineer* to join our dynamic team. The ideal candidate will be responsible for designing, building, and maintaining scalable data pipelines and architectures that support our analytics and business intelligence initiatives. This role requires a strong understanding of data management principles, as well as proficiency in various programming languages and cloud technologies.\\n\\n*Job title: Azure DataBricks Developer/ Engineer *\\n\\n*Location: New Jersey *\\n\\n*Term: Long term contract*\\n\\n*Work style: Hybrid 3 days remote 2 days onsite*\\n\\nKey Requirement: *Stronger candidates with Financial Services Background who are open to going to office onsite twice a week is the Right Fit.*\\n\\n\\n\\n*RESPONSIBILITIES*\\nBuild large-scale batch and real-time data pipelines with data processing frameworks in Azure cloud platform.\\nDesigning and implementing highly performant data ingestion pipelines from multiple sources using Azure Databricks.\\nDirect experience of building data pipelines using Azure Data Factory and Databricks.\\nDeveloping scalable and re-usable frameworks for ingesting of datasets\\nLead design of ETL, data integration and data migration.\\nPartner with architects, engineers, information analysts, business, and technology stakeholders for developing and deploying enterprise grade platforms that enable data-driven solutions.\\nIntegrating the end to end data pipeline - to take data from source systems to target data repositories ensuring the quality and consistency of data is maintained at all times\\nWorking with event based / streaming technologies to ingest and process data\\nWorking with other members of the project team to support delivery of additional project components (API interfaces, Search)\\nEvaluating the performance and applicability of multiple tools against customer requirements\\n\\n*REQUIREMENTS*\\nExperience on ADLS, Azure Databricks, Azure SQL DB and Datawarehouse\\nStrong working experience in Implementation of Azure cloud components using Azure Data Factory , Azure Data Analytics, Azure Data Lake, Azure Data Catalogue, LogicApps and FunctionApps\\nHave knowledge in Azure Storage services (ADLS, Storage Accounts)\\nExpertise in designing and deploying data applications on cloud solutions on Azure\\nHands on experience in performance tuning and optimizing code running in Databricks environment\\nGood understanding of SQL, T-SQL and/or PL/SQL\\nShould have experience working in Agile projects with knowledge in Jira\\nGood to have handled Data Ingestion projects in Azure environment\\nDemonstrated analytical and problem-solving skills particularly those that apply to a big data environment\\nExperience on Python scripting, Spark SQL PySpark is a plus.\\n\\nAlso, *the consultant must be on-site in Jersey City twice a week*.\\n\\nJoin us in leveraging the power of data to drive business decisions and enhance operational efficiency!\\n\\nJob Types: Full-time, Contract\\n\\nPay: $70.00 per hour\\n\\nExpected hours: 40 per week\\n\\nCompensation Package:\\n* 1099 contract\\n* Hourly pay\\nSchedule:\\n* Monday to Friday\\n\\nWork Location: Hybrid remote in Jersey City, NJ 07302", "semanticSegments": []}, "location": {"__typename": "JobLocation", "countryCode": "US", "admin1Code": "NJ", "admin2Code": "017", "admin3Code": null, "admin4Code": null, "city": "Jersey City", "postalCode": "07302", "latitude": 40.716206, "longitude": -74.03356, "streetAddress": "30 Exchange Pl", "formatted": {"__typename": "FormattedJobLocation", "long": "Jersey City, NJ 07302", "short": "Jersey City, NJ"}}, "occupations": [{"__typename": "JobOccupation", "key": "6D2D2", "label": "Data & Database Occupations"}, {"__typename": "JobOccupation", "key": "EHPW9", "label": "Technology Occupations"}, {"__typename": "JobOccupation", "key": "XXX29", "label": "Data Developers"}], "occupationMostLikelySuids": [{"__typename": "JobOccupation", "key": "XXX29"}], "benefits": [], "socialInsurance": [], "workingSystem": [], "requiredDocumentsCategorizedAttributes": [], "indeedApply": {"__typename": "JobIndeedApplyAttributes", "key": "eyJqayI6IjU5YjUyZGU5YzgwZDVjNWIiLCJhZHZOdW0iOiI5MjExODE1NTEwNjE2NDU4IiwiYXBpVG9rZW4iOiJhYTEwMjIzNWE1Y2NiMThiZDM2NjhjMGUxNGFhM2VhN2UyNTAzY2ZhYzJhN2E5YmYzZDY1NDk4OTllMTI1YWY0IiwiY292ZXJsZXR0ZXIiOiJvcHRpb25hbCIsImpvYkNvbXBhbnlOYW1lIjoiRGl2aXNoIExMQyIsImpvYklkIjoiZDdiNDU2YzlkMzU4MjIzMTRhODciLCJqb2JMb2NhdGlvbiI6IkplcnNleSBDaXR5LCBOSiAwNzMwMiIsImpvYlRpdGxlIjoiU3IuIEF6dXJlIERhdGEgRW5naW5lZXIiLCJwaG9uZSI6Im9wdGlvbmFsIiwicG9zdFVybCI6Imh0dHA6Ly9tdWZmaXQvcHJvY2Vzcy1pbmRlZWRhcHBseSIsInJlc3VtZSI6Im9wdGlvbmFsIiwiaXNNb2JpbGUiOnRydWV9", "scopes": ["DESKTOP", "MOBILE"]}, "attributes": [{"__typename": "JobAttribute", "key": "25MDY", "label": "Jira"}, {"__typename": "JobAttribute", "key": "47KNR", "label": "Performance tuning"}, {"__typename": "JobAttribute", "key": "5F3M7", "label": "Databricks"}, {"__typename": "JobAttribute", "key": "5M3JZ", "label": "Data modeling"}, {"__typename": "JobAttribute", "key": "64VXT", "label": "Azure"}, {"__typename": "JobAttribute", "key": "82T6Z", "label": "Azure Data Lake"}, {"__typename": "JobAttribute", "key": "8AD9K", "label": "Hourly pay"}, {"__typename": "JobAttribute", "key": "9UP9X", "label": "Big data"}, {"__typename": "JobAttribute", "key": "AJY84", "label": "Data structures"}, {"__typename": "JobAttribute", "key": "AWSY6", "label": "Spark"}, {"__typename": "JobAttribute", "key": "CF3CP", "label": "Full-time"}, {"__typename": "JobAttribute", "key": "F6JAH", "label": "ADLs"}, {"__typename": "JobAttribute", "key": "F7KCW", "label": "8 years"}, {"__typename": "JobAttribute", "key": "FGY89", "label": "SQL"}, {"__typename": "JobAttribute", "key": "HFDVW", "label": "Bachelor's degree"}, {"__typename": "JobAttribute", "key": "HTGRA", "label": "Data management"}, {"__typename": "JobAttribute", "key": "JKYJH", "label": "Azure Data Factory"}, {"__typename": "JobAttribute", "key": "MWTB7", "label": "Scripting"}, {"__typename": "JobAttribute", "key": "NJXCK", "label": "Contract"}, {"__typename": "JobAttribute", "key": "NREM3", "label": "Data pipelines"}, {"__typename": "JobAttribute", "key": "PAXZC", "label": "Hybrid work"}, {"__typename": "JobAttribute", "key": "PP4CH", "label": "APIs"}, {"__typename": "JobAttribute", "key": "PRGNY", "label": "ETL"}, {"__typename": "JobAttribute", "key": "QE236", "label": "Agile"}, {"__typename": "JobAttribute", "key": "R6MKU", "label": "Financial services"}, {"__typename": "JobAttribute", "key": "SAP7A", "label": "Monday to Friday"}, {"__typename": "JobAttribute", "key": "SVWFF", "label": "Data collection"}, {"__typename": "JobAttribute", "key": "TKG4S", "label": "Data visualization"}, {"__typename": "JobAttribute", "key": "UB7SC", "label": "Senior level"}, {"__typename": "JobAttribute", "key": "V7KSJ", "label": "1099 contract"}, {"__typename": "JobAttribute", "key": "VBPMM", "label": "PL/SQL"}, {"__typename": "JobAttribute", "key": "WYQ93", "label": "Data warehouse"}, {"__typename": "JobAttribute", "key": "X62BT", "label": "Python"}, {"__typename": "JobAttribute", "key": "ZJUSV", "label": "T-SQL"}], "employerProvidedAttributes": [{"__typename": "JobAttribute", "key": "5F3M7", "label": "Databricks"}, {"__typename": "JobAttribute", "key": "5M3JZ", "label": "Data modeling"}, {"__typename": "JobAttribute", "key": "64VXT", "label": "Azure"}, {"__typename": "JobAttribute", "key": "82T6Z", "label": "Azure Data Lake"}, {"__typename": "JobAttribute", "key": "8AD9K", "label": "Hourly pay"}, {"__typename": "JobAttribute", "key": "AJY84", "label": "Data structures"}, {"__typename": "JobAttribute", "key": "CF3CP", "label": "Full-time"}, {"__typename": "JobAttribute", "key": "F6JAH", "label": "ADLs"}, {"__typename": "JobAttribute", "key": "F7KCW", "label": "8 years"}, {"__typename": "JobAttribute", "key": "FGY89", "label": "SQL"}, {"__typename": "JobAttribute", "key": "HFDVW", "label": "Bachelor's degree"}, {"__typename": "JobAttribute", "key": "HTGRA", "label": "Data management"}, {"__typename": "JobAttribute", "key": "JKYJH", "label": "Azure Data Factory"}, {"__typename": "JobAttribute", "key": "NJXCK", "label": "Contract"}, {"__typename": "JobAttribute", "key": "NREM3", "label": "Data pipelines"}, {"__typename": "JobAttribute", "key": "PAXZC", "label": "Hybrid work"}, {"__typename": "JobAttribute", "key": "PRGNY", "label": "ETL"}, {"__typename": "JobAttribute", "key": "R6MKU", "label": "Financial services"}, {"__typename": "JobAttribute", "key": "SAP7A", "label": "Monday to Friday"}, {"__typename": "JobAttribute", "key": "SVWFF", "label": "Data collection"}, {"__typename": "JobAttribute", "key": "TKG4S", "label": "Data visualization"}, {"__typename": "JobAttribute", "key": "V7KSJ", "label": "1099 contract"}, {"__typename": "JobAttribute", "key": "WYQ93", "label": "Data warehouse"}, {"__typename": "JobAttribute", "key": "ZJUSV", "label": "T-SQL"}], "employerProvidedOccupations": [], "hiringDemand": {"__typename": "HiringDemand", "isUrgentHire": false, "isHighVolumeHiring": false}, "thirdPartyTrackingUrls": [], "jobSearchMobileMigrationData": null, "jobStats": {"__typename": "JobStats", "organicApplyStarts": 2}, "isRepost": false, "isLatestPost": true, "isPlacement": null, "employer": {"__typename": "Employer", "key": "122e12421cc8ebe1", "tier": "FREE", "relativeCompanyPageUrl": "/cmp/Divish-LLC", "dossier": {"__typename": "EmployerDossier", "images": {"__typename": "ImageBundle", "rectangularLogoUrl": null, "headerImageUrls": null, "squareLogoUrls": null}}, "ugcStats": {"__typename": "JobseekerUgcStats", "globalReviewCount": 1, "ratings": {"__typename": "RatingBundle", "overallRating": {"__typename": "AverageRating", "count": 1, "value": 5}}}, "subsidiaryOptOutStatusV2": false, "parentEmployer": null}, "jobTypes": [{"__typename": "JobAttribute", "key": "CF3CP", "label": "Full-time"}, {"__typename": "JobAttribute", "key": "NJXCK", "label": "Contract"}], "shiftAndSchedule": [{"__typename": "JobAttribute", "key": "SAP7A", "label": "Monday to Friday"}], "compensation": {"__typename": "JobCompensation", "key": "CLnekeEjHQC4CEgglo6tJijJusAgMN6O9gM4nYoDQghmdWxsdGltZUIIY29udHJhY3RKF1NyLiBBenVyZSBEYXRhIEVuZ2luZWVyUNey14ECYhwKGAoKDQAAjEIVAACMQhABGAQiBgjYNhDYNngBag1kYXRhIGVuZ2luZWVycIiKrsDGMooBBVhYWDI5kgESCg4KCg267t9HFTXGDUgQBXgBogFcCgNTRVMSCWVzdFNhbGFyeRoQCgNtaW4QBDkAAABA1/37QBoQCgNtYXgQBDkAAACgxrgBQRoTCgdzYWxUeXBlEAIqBllFQVJMWRoRCghjdXJyZW5jeRACKgNVU0SqAQJVU7IBAk5KugELSmVyc2V5IENpdHk="}, "applicants": null}, "matchComparisonResult": {"__typename": "MatchComparisonEngineMatchResult", "attributeComparisons": [{"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Jira", "lastModified": 0, "suid": "25MDY", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "CONFIRMED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Financial services", "lastModified": 0, "suid": "R6MKU", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NICE_TO_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "CONFIRMED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "SQL", "lastModified": 0, "suid": "FGY89", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "MUST_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "CONFIRMED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Data warehouse", "lastModified": 0, "suid": "WYQ93", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NICE_TO_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "CONFIRMED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Data collection", "lastModified": 0, "suid": "SVWFF", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NICE_TO_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "CONFIRMED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Data modeling", "lastModified": 0, "suid": "5M3JZ", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NICE_TO_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Python", "lastModified": 0, "suid": "X62BT", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "CONFIRMED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Azure Data Lake", "lastModified": 0, "suid": "82T6Z", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "MUST_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "CONFIRMED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Data visualization", "lastModified": 0, "suid": "TKG4S", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NICE_TO_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Scripting", "lastModified": 0, "suid": "MWTB7", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "APIs", "lastModified": 0, "suid": "PP4CH", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "CONFIRMED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "T-SQL", "lastModified": 0, "suid": "ZJUSV", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NICE_TO_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "CONFIRMED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "ADLs", "lastModified": 0, "suid": "F6JAH", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "MUST_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "CONFIRMED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Databricks", "lastModified": 0, "suid": "5F3M7", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "MUST_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Agile", "lastModified": 0, "suid": "QE236", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "CONFIRMED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Data management", "lastModified": 0, "suid": "HTGRA", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "MUST_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "CONFIRMED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Azure Data Factory", "lastModified": 0, "suid": "JKYJH", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "MUST_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Big data", "lastModified": 0, "suid": "9UP9X", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Performance tuning", "lastModified": 0, "suid": "47KNR", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Spark", "lastModified": 0, "suid": "AWSY6", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "CONFIRMED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Data pipelines", "lastModified": 0, "suid": "NREM3", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NICE_TO_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "PL/SQL", "lastModified": 0, "suid": "VBPMM", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "CONFIRMED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Bachelor's degree", "lastModified": 0, "suid": "HFDVW", "profileAttributeTypeSuid": "NP7FU"}, "jobRequirementStrength": "NICE_TO_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "CONFIRMED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Azure", "lastModified": 0, "suid": "64VXT", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NICE_TO_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "CONFIRMED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Data structures", "lastModified": 0, "suid": "AJY84", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NICE_TO_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "CONFIRMED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "ETL", "lastModified": 0, "suid": "PRGNY", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NICE_TO_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}], "encouragementToApply": {"__typename": "MatchComparisonEngineEncouragementToApply", "score": 0, "strategy": "", "trafficLight": "YELLOW"}, "matchOverlapMetric": {"__typename": "MatchComparisonEngineMatchOverlapMetric", "coverage": 0, "jobDetailScore": 0, "locationScore": 0, "matchOverlapScore": 0, "payScore": 0, "qualificationOverlapScore": 0, "version": 0}, "occupationComparisons": [{"__typename": "MatchComparisonEngineOccupationComparison", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY", "occupation": {"__typename": "MatchComparisonEngineOccupation", "label": "Data Developers", "suid": "XXX29"}}]}}]}}, "errors": [], "query": "query getViewJobJobData($jobKey: ID!, $jobKeyString: String!, $shouldQueryCogsEligibility: Boolean!, $shouldQuerySavedJob: Boolean!, $shouldQueryTitleNorm: Boolean!, $shouldQueryCompanyFields: Boolean!, $shouldQuerySalary: Boolean!, $shouldQueryIndeedApplyLink: Boolean!, $shouldQueryParentEmployer: Boolean!, $shouldQuerySentiment: Boolean!, $shouldIncludeFragmentZone: Boolean!, $shouldQueryMatchComparison: Boolean!, $shouldQueryApplicantInsights: Boolean!, $shouldQueryJobCampaignsConnection: Boolean!, $shouldQueryJobSeekerPreferences: Boolean!, $shouldQueryJobSeekerProfileQuestions: Boolean!, $mobvjtk: String!, $continueUrl: String!, $spn: Boolean!, $jobDataInput: JobDataInput!) {\\n  jobData(input: $jobDataInput) {\\n    __typename\\n    results {\\n      __typename\\n      trackingKey\\n      job {\\n        __typename\\n        key\\n        ...jobDataFields\\n        ...titleNormFields@include(if: $shouldQueryTitleNorm)\\n        ...companyFields@include(if: $shouldQueryCompanyFields)\\n        ...parentEmployerFields@include(if: $shouldQueryParentEmployer)\\n        jobSearchMobileMigrationData @include(if: $shouldQuerySentiment) {\\n          __typename\\n          knownUserSentimentIdMap {\\n            __typename\\n            id\\n            suid\\n          }\\n          userStringDislikedPreferences {\\n            __typename\\n            uid\\n          }\\n          userMinimumPayPreferences {\\n            __typename\\n            currency\\n            payAmount\\n            salaryType\\n          }\\n          preferencesFetchStatus\\n          paySentiment\\n        }\\n        jobTypes: attributes(customClass: \\"BM62A\\") {\\n          __typename\\n          key\\n          label\\n          sentiment @include(if: $shouldQuerySentiment)\\n        }\\n        shiftAndSchedule: attributes(customClass: \\"BTSWR\\") {\\n          __typename\\n          key\\n          label\\n          sentiment @include(if: $shouldQuerySentiment)\\n        }\\n        compensation @include(if: $shouldQuerySalary) {\\n          __typename\\n          key\\n        }\\n        indeedApply @include(if: $shouldQueryIndeedApplyLink) {\\n          __typename\\n          applyLink(property: INDEED, trackingKeys: {mobvjtk : $mobvjtk}, continueUrl: $continueUrl, spn: $spn) {\\n            __typename\\n            url\\n            iaUid\\n          }\\n        }\\n        ...ViewJobFragmentZone@include(if: $shouldIncludeFragmentZone)\\n        applicants @include(if: $shouldQueryApplicantInsights) {\\n          __typename\\n          hasInsights\\n          ...ApplicantDemographicsFields\\n        }\\n        jobCampaignsConnection(input: {spendingEligibilityTypes : [FUNDED_PERIOD_ELIGIBILITY]}) @include(if: $shouldQueryJobCampaignsConnection) {\\n          __typename\\n          campaignCount\\n        }\\n      }\\n      matchComparisonResult @include(if: $shouldQueryMatchComparison) {\\n        __typename\\n        attributeComparisons {\\n          __typename\\n          jobProvenance\\n          attribute {\\n            __typename\\n            interestedParty\\n            label\\n            lastModified\\n            suid\\n            profileAttributeTypeSuid\\n          }\\n          jobRequirementStrength\\n          jsProvenance\\n          matchType\\n        }\\n        encouragementToApply {\\n          __typename\\n          score\\n          strategy\\n          trafficLight\\n        }\\n        matchOverlapMetric {\\n          __typename\\n          coverage\\n          jobDetailScore\\n          locationScore\\n          matchOverlapScore\\n          payScore\\n          qualificationOverlapScore\\n          version\\n        }\\n        occupationComparisons {\\n          __typename\\n          jsProvenance\\n          matchType\\n          occupation {\\n            __typename\\n            label\\n            suid\\n          }\\n        }\\n      }\\n    }\\n  }\\n  savedJobsByKey(keys: [$jobKey]) @include(if: $shouldQuerySavedJob) {\\n    __typename\\n    state\\n    currentStateTime\\n  }\\n  cogsCheckEligibility(input: {jobKey : $jobKeyString}) @include(if: $shouldQueryCogsEligibility) {\\n    __typename\\n    error\\n    isEligible\\n  }\\n  jobSeekerProfile @include(if: $shouldQueryApplicantInsights) {\\n    __typename\\n    profile {\\n      __typename\\n      jobSeekerPro {\\n        __typename\\n        status\\n      }\\n    }\\n  }\\n  jobSeekerProfileStructuredData(input: {queryFilter : {dataCategory : CONFIRMED_BY_USER}}) @include(if: $shouldQueryJobSeekerPreferences) {\\n    __typename\\n    preferences {\\n      __typename\\n      jobTitles {\\n        __typename\\n        jobTitle\\n      }\\n      minimumPay {\\n        __typename\\n        amount\\n        salaryType\\n      }\\n    }\\n  }\\n  jobSeekerProfileQuestionFieldSet(input: {source : VJP_GATING}) @include(if: $shouldQueryJobSeekerProfileQuestions) {\\n    __typename\\n    questionFields {\\n      __typename\\n      name\\n    }\\n  }\\n}\\n\\nfragment jobDataFields on Job {\\n  __typename\\n  title\\n  sourceEmployerName\\n  datePublished\\n  expired\\n  language\\n  normalizedTitle\\n  refNum\\n  expirationDate\\n  source {\\n    __typename\\n    key\\n    name\\n  }\\n  feed {\\n    __typename\\n    key\\n    isDradis\\n    feedSourceType\\n  }\\n  url\\n  dateOnIndeed\\n  description {\\n    __typename\\n    html\\n    text\\n    semanticSegments {\\n      __typename\\n      content\\n      header\\n      label\\n    }\\n  }\\n  location {\\n    __typename\\n    countryCode\\n    admin1Code\\n    admin2Code\\n    admin3Code\\n    admin4Code\\n    city\\n    postalCode\\n    latitude\\n    longitude\\n    streetAddress\\n    formatted {\\n      __typename\\n      long\\n      short\\n    }\\n  }\\n  occupations {\\n    __typename\\n    key\\n    label\\n  }\\n  occupationMostLikelySuids: occupations(occupationOption: MOST_LIKELY) {\\n    __typename\\n    key\\n  }\\n  benefits: attributes(customClass: \\"SXMYH\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  socialInsurance: attributes(customClass: \\"KTQQ7\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  workingSystem: attributes(customClass: \\"TY4DY\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  requiredDocumentsCategorizedAttributes: attributes(customClass: \\"PQCTE\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  indeedApply {\\n    __typename\\n    key\\n    scopes\\n  }\\n  attributes {\\n    __typename\\n    key\\n    label\\n  }\\n  employerProvidedAttributes: attributes(sources: [EMPLOYER]) {\\n    __typename\\n    key\\n    label\\n  }\\n  employerProvidedOccupations: occupations(sources: [EMPLOYER], occupationOption: MOST_SPECIFIC) {\\n    __typename\\n    label\\n  }\\n  hiringDemand {\\n    __typename\\n    isUrgentHire\\n    isHighVolumeHiring\\n  }\\n  thirdPartyTrackingUrls\\n  jobSearchMobileMigrationData {\\n    __typename\\n    advertiserId\\n    jobTypeId\\n    applyEmail\\n    applyUrl\\n    contactEmail\\n    contactPhone\\n    isNoUniqueUrl\\n    urlRewriteRule\\n    mapDisplayType\\n    jobTags\\n    locCountry\\n    waldoVisibilityLevel\\n    isKnownSponsoredOnDesktop\\n    isKnownSponsoredOnMobile\\n    tpiaAdvNum\\n    tpiaApiToken\\n    tpiaCoverLetter\\n    tpiaEmail\\n    tpiaFinishAppUrl\\n    tpiaJobCompanyName\\n    tpiaJobId\\n    tpiaJobLocation\\n    tpiaJobMeta\\n    tpiaJobTitle\\n    tpiaLocale\\n    tpiaName\\n    tpiaPhone\\n    tpiaPostUrl\\n    tpiaPresent\\n    tpiaResume\\n    tpiaResumeFieldsOptional\\n    tpiaResumeFieldsRequired\\n    tpiaScreenerQuestions\\n    iaVisibility\\n    hasPreciseLocation\\n    algoKey\\n  }\\n  jobStats {\\n    __typename\\n    organicApplyStarts\\n  }\\n  isRepost\\n  isLatestPost\\n  isPlacement\\n}\\n\\nfragment titleNormFields on Job {\\n  __typename\\n  normalizedTitle\\n  displayTitle\\n}\\n\\nfragment companyFields on Job {\\n  __typename\\n  employer {\\n    __typename\\n    key\\n    tier\\n    relativeCompanyPageUrl\\n    dossier {\\n      __typename\\n      images {\\n        __typename\\n        rectangularLogoUrl\\n        headerImageUrls {\\n          __typename\\n          url1960x400\\n        }\\n        squareLogoUrls {\\n          __typename\\n          url256\\n        }\\n      }\\n    }\\n    ugcStats {\\n      __typename\\n      globalReviewCount\\n      ratings {\\n        __typename\\n        overallRating {\\n          __typename\\n          count\\n          value\\n        }\\n      }\\n    }\\n  }\\n}\\n\\nfragment parentEmployerFields on Job {\\n  __typename\\n  employer {\\n    __typename\\n    subsidiaryOptOutStatusV2\\n    parentEmployer {\\n      __typename\\n      name\\n      subsidiaryOptOutStatusV2\\n    }\\n  }\\n}\\n\\nfragment ViewJobFragmentZone on Job {\\n  key\\n  __typename\\n}\\n\\nfragment ApplicantDemographicsFields on Applicants {\\n  __typename\\n  count {\\n    __typename\\n    total\\n    last24h\\n  }\\n  workExperience {\\n    __typename\\n    title\\n    pct\\n  }\\n  education {\\n    __typename\\n    title\\n    pct\\n  }\\n  skills {\\n    __typename\\n    title\\n    pct\\n  }\\n  certificates {\\n    __typename\\n    title\\n    pct\\n  }\\n}\\n", "variables": {"jobKey": "59b52de9c80d5c5b", "jobKeyString": "59b52de9c80d5c5b", "shouldQueryCogsEligibility": false, "shouldQuerySavedJob": false, "shouldQueryTitleNorm": false, "shouldQueryCompanyFields": true, "shouldQuerySalary": true, "shouldQueryIndeedApplyLink": false, "shouldQueryParentEmployer": true, "shouldQuerySentiment": false, "shouldIncludeFragmentZone": false, "shouldQueryMatchComparison": true, "shouldQueryApplicantInsights": false, "shouldQueryJobCampaignsConnection": false, "shouldQueryJobSeekerPreferences": false, "shouldQueryJobSeekerProfileQuestions": false, "mobvjtk": "1ihka5b1ag28u800", "continueUrl": "http://www.indeed.com/viewjob?cmp=Divish-LLC&t=Data+Engineer&jk=59b52de9c80d5c5b&xpse=SoC667I330cahGS8Xx0LbzkdCdPP&xfps=d9a3059b-e292-4133-b8ec-5a0c2ba17e9f&xkcb=SoCV67M330bz7mSxXB0ObzkdCdPP&vjs=3&applied=1", "spn": false, "jobDataInput": {"jobKeys": ["59b52de9c80d5c5b"], "useSearchlessPrice": false}}}}	INDEED	DATA_ENGINEER	2025-01-15 00:25:15.37634+00	f	$70 an hour	\N
6	/rc/clk?jk=b7a9a0db69da63df&bb=nVAi1dqOC2Ptfy5ocQiBhcN9yi7CSkqXR2ffLONMfxSU8nFIYdmAk5no8-BAnegg6xQu10s4XoTNZGZIo_iHjbqC7b1RafVqigBPfh7FOKDvpv5pkz2tS1AfvKyr8M_N&xkcb=SoAI67M330bz7mSxXB0NbzkdCdPP&fccid=b7e79246d922f0bc&vjs=3	{"host_query_execution_result": {"data": {"jobData": {"__typename": "JobDataPayload", "results": [{"__typename": "JobDataResult", "trackingKey": "5-cmh1-3-1ihka6gt7gbho801", "job": {"__typename": "Job", "key": "b7a9a0db69da63df", "title": "Senior Data Engineer", "sourceEmployerName": "Moser Consulting", "datePublished": 1735711200000, "expired": false, "language": "en", "normalizedTitle": "data engineer", "refNum": "f799f9a5defa", "expirationDate": null, "source": {"__typename": "JobSource", "key": "AAAAAfslCqtcSGNC84rX+pOTsO33uC/DKwsrq/ckkuQ4Nd2JTWRfag==", "name": "Moser Consulting"}, "feed": {"__typename": "JobFeed", "key": "AAAAAXK7o86FHVcjYv1MctlidI00WP32V9o931w7BSiWz3t7TCdvmg==", "isDradis": false, "feedSourceType": "EMPLOYER"}, "url": "https://moser-consulting.breezy.hr/p/f799f9a5defa-senior-data-engineer?source=indeed", "dateOnIndeed": 1736905340000, "description": {"__typename": "JobDescription", "html": "<div><h1 class=\\"jobSectionHeader\\"><b>About Moser</b></h1>\\n<p>For more than 25 years we have formed partnerships and grown through open and honest collaboration with our clients, partners, and employees. We are best known for taking great care of our clients, our dedication to creating a work environment where employees do their best work, and our deep commitment to continuous improvement. Our consultants work in a collaborative and fast-paced environment, are self-motivated, and are passionate about evolving technology. It is no accident that we are recognized as one of the Best Places to Work in Indiana for 10 consecutive years.</p>\\n<p>Internally, we believe in building strong teams from the top down with a focus on values in our Model-Coach-Care philosophy. Our leadership are encouraged and trained to model good practices, mentor other employees and each other, and show empathy and caring in all interactions. This is the base of our core values: Accountability, Balance, Collaboration, Focus, Integrity, Social Responsibility, Support and Transparency.</p>\\n<p>Moser Consulting believes in equal opportunity for all people and is committed to enabling a diverse, equitable, and inclusive culture. We foster a spirit of unity that respects the remarkable individuality of everyone's culture, history, and service.</p>\\n<h1 class=\\"jobSectionHeader\\"><b>Description</b></h1><p>\\nThe successful candidate will help integrate data from a variety of data sources into the Research Data Integration platform to support reporting and analytical applications. The candidate will work with the R&amp;D partners within the Field Solutions &amp; Digital group in Designing and Developing ETL/ELT processes as well as proper representations of the integrated data and delivery methods for downstream applications.\\n</p><h1 class=\\"jobSectionHeader\\"><b>Role Responsibilities</b></h1><ul>\\n<li>Be a trusted team member and collaborator in the Field Solutions &amp; Digital organization.</li>\\n<li>Ability to work across cross-functional teams to identify business, data, and reporting needs and assist where needed.</li>\\n<li>Design, develop, own, and evolve the data and data integration processes that power our data warehouse platform on AWS &amp; Exasol.</li>\\n<li>Design, test and implement on-premise &amp; cloud DW infrastructure.</li>\\n<li>Develop and maintain complex Cloud Data Ingestion and Transformations for data originating from multiple data sources.</li>\\n<li>Contribute to architecture of data integration solutions.</li>\\n<li>Collaborate with teams across FS&amp;D to share and acquire development ideas and knowledge.</li>\\n<li>Create efficient SQL queries &amp; Data Ingestion pipelines using the tech stack: Python, SQL, AWS Athena, AWS DMS, AWS Glue, Airflow, and others to analyze data from external applications and the data warehouse.</li>\\n<li>Evaluate and recommend products that enhance our cloud BI/DW solution.</li>\\n<li>Analyze and resolve user issues reported to the Support Desk.</li>\\n</ul><h1 class=\\"jobSectionHeader\\"><b>Requirements</b></h1><p>\\nThis position requires proven experience in data warehousing practices and concepts as well as proven experience in dimensional and relational database modeling. Highly desirable experience includes the following:\\n</p><ul><li>2-4 years of experience in AWS S3, EMR, EC2, Python, RDS, Athena, Glue, Lambda, and CloudWatch experience is preferred.</li>\\n<li>Strong working knowledge of Near Realtime Data Warehousing principles and implementations.</li>\\n<li>Working knowledge of key RDBMS databases like Oracle, Teradata, and other Cloud DW.</li>\\n<li>Experience in Data Virtualization Platform using tools like Denodo, Azure Purview, or others.</li>\\n<li>Strong practical experience with SQL and Database principles.</li>\\n<li>Strong experience in NoSQL Databases like Cassandra, DynamoDB, MongoDB, or others.</li>\\n<li>Experience in working with ETL tools and technologies like Informatica and others.</li>\\n<li>Experience with Infrastructure, Scripting, Architecture is very beneficial.</li>\\n<li>Create Technical Designs and Mapping Specifications for Data Integration projects.</li>\\n<li>Hands-on experience in Query Optimization and Performance improvement practices.</li>\\n<li>Experience in Relational and Dimensional Data Modeling.</li>\\n<li>Experience with Agile development methodologies.</li>\\n<li>Communicate well in both oral and written form.</li>\\n</ul><h1 class=\\"jobSectionHeader\\"><b>Where You'll Work</b></h1>\\n<p>Moser has two offices in Indianapolis, IN, and one in Baltimore, MD. This position will require a hybrid/onsite work schedule out of our clients work location.</p>\\n<h1 class=\\"jobSectionHeader\\"><b>Salary</b></h1>\\n<p>At Moser Consulting, we believe in pay transparency and fairness. The $100k-$135k salary range for this role is not just a number&mdash;it's a reflection of the value we place on the skills and experience our employees bring to our team. We are committed to offering a competitive salary that aligns with the industry standards and the unique competencies you bring to our community.</p>\\n<h1 class=\\"jobSectionHeader\\"><b>Benefits</b></h1>\\n<p>For over a quarter of a century, Moser Consulting has been a beacon for top-tier IT talent who excel in self-management. Our people are our greatest asset. We don't just hire the best&mdash;we welcome them into our family, connect them with opportunities, and empower them to create innovative solutions to technology challenges.</p>\\n<p>Our unique culture is our competitive edge. It fosters happiness, health, and low stress, even in an industry known for its demands. This is why we're consistently recognized as one of the Best Places to Work in Indiana. We provide our employees with an inspiring workspace, a fun and collaborative atmosphere, and a generous compensation package. But that's not all.</p>\\n<p>We also offer a suite of benefits designed to support and enrich our employees' lives. These include:</p>\\n<ul><li>Training Opportunities: We believe in lifelong learning and provide numerous avenues for skill enhancement.</li><li>\\nFully Invested 401K Plan: We help secure your future with a fully invested 401K plan.</li><li>\\nPPO and HDHP Medical Plans: Choose the health insurance program that best fits your needs.</li><li>\\nEmployer-Paid Dental and Vision Plans: We cover dental and vision plans, ensuring our employees have access to comprehensive health care.</li><li>\\nOnsite Fitness Center: Stay fit and healthy with our state-of-the-art fitness center.</li><li>\\nWellness Program: We promote a healthy lifestyle with our wellness program.</li><li>\\nCatered Lunches: Enjoy delicious catered lunches regularly.</li><li>\\nMoser Consulting, we don't just offer jobs&mdash;we offer careers, growth, and a chance to join a thriving community. Come, be a part of our family.</li><li>\\nMoser Consulting is an Equal Opportunity Employer. All qualified applicants will receive consideration for employment without regard to race, color, religion, sex, sexual orientation, gender identity, national origin, disability, or status as a protected veteran.</li></ul></div>", "text": "About Moser\\n\\nFor more than 25 years we have formed partnerships and grown through open and honest collaboration with our clients, partners, and employees. We are best known for taking great care of our clients, our dedication to creating a work environment where employees do their best work, and our deep commitment to continuous improvement. Our consultants work in a collaborative and fast-paced environment, are self-motivated, and are passionate about evolving technology. It is no accident that we are recognized as one of the Best Places to Work in Indiana for 10 consecutive years.\\n\\nInternally, we believe in building strong teams from the top down with a focus on values in our Model-Coach-Care philosophy. Our leadership are encouraged and trained to model good practices, mentor other employees and each other, and show empathy and caring in all interactions. This is the base of our core values: Accountability, Balance, Collaboration, Focus, Integrity, Social Responsibility, Support and Transparency.\\n\\nMoser Consulting believes in equal opportunity for all people and is committed to enabling a diverse, equitable, and inclusive culture. We foster a spirit of unity that respects the remarkable individuality of everyone's culture, history, and service.\\n\\nDescription\\n\\nThe successful candidate will help integrate data from a variety of data sources into the Research Data Integration platform to support reporting and analytical applications. The candidate will work with the R&D partners within the Field Solutions & Digital group in Designing and Developing ETL/ELT processes as well as proper representations of the integrated data and delivery methods for downstream applications.\\n\\nRole Responsibilities\\nBe a trusted team member and collaborator in the Field Solutions & Digital organization.\\nAbility to work across cross-functional teams to identify business, data, and reporting needs and assist where needed.\\nDesign, develop, own, and evolve the data and data integration processes that power our data warehouse platform on AWS & Exasol.\\nDesign, test and implement on-premise & cloud DW infrastructure.\\nDevelop and maintain complex Cloud Data Ingestion and Transformations for data originating from multiple data sources.\\nContribute to architecture of data integration solutions.\\nCollaborate with teams across FS&D to share and acquire development ideas and knowledge.\\nCreate efficient SQL queries & Data Ingestion pipelines using the tech stack: Python, SQL, AWS Athena, AWS DMS, AWS Glue, Airflow, and others to analyze data from external applications and the data warehouse.\\nEvaluate and recommend products that enhance our cloud BI/DW solution.\\nAnalyze and resolve user issues reported to the Support Desk.\\nRequirements\\n\\nThis position requires proven experience in data warehousing practices and concepts as well as proven experience in dimensional and relational database modeling. Highly desirable experience includes the following:\\n\\n2-4 years of experience in AWS S3, EMR, EC2, Python, RDS, Athena, Glue, Lambda, and CloudWatch experience is preferred.\\nStrong working knowledge of Near Realtime Data Warehousing principles and implementations.\\nWorking knowledge of key RDBMS databases like Oracle, Teradata, and other Cloud DW.\\nExperience in Data Virtualization Platform using tools like Denodo, Azure Purview, or others.\\nStrong practical experience with SQL and Database principles.\\nStrong experience in NoSQL Databases like Cassandra, DynamoDB, MongoDB, or others.\\nExperience in working with ETL tools and technologies like Informatica and others.\\nExperience with Infrastructure, Scripting, Architecture is very beneficial.\\nCreate Technical Designs and Mapping Specifications for Data Integration projects.\\nHands-on experience in Query Optimization and Performance improvement practices.\\nExperience in Relational and Dimensional Data Modeling.\\nExperience with Agile development methodologies.\\nCommunicate well in both oral and written form.\\nWhere You'll Work\\n\\nMoser has two offices in Indianapolis, IN, and one in Baltimore, MD. This position will require a hybrid/onsite work schedule out of our clients work location.\\n\\nSalary\\n\\nAt Moser Consulting, we believe in pay transparency and fairness. The $100k-$135k salary range for this role is not just a number\\u2014it's a reflection of the value we place on the skills and experience our employees bring to our team. We are committed to offering a competitive salary that aligns with the industry standards and the unique competencies you bring to our community.\\n\\nBenefits\\n\\nFor over a quarter of a century, Moser Consulting has been a beacon for top-tier IT talent who excel in self-management. Our people are our greatest asset. We don't just hire the best\\u2014we welcome them into our family, connect them with opportunities, and empower them to create innovative solutions to technology challenges.\\n\\nOur unique culture is our competitive edge. It fosters happiness, health, and low stress, even in an industry known for its demands. This is why we're consistently recognized as one of the Best Places to Work in Indiana. We provide our employees with an inspiring workspace, a fun and collaborative atmosphere, and a generous compensation package. But that's not all.\\n\\nWe also offer a suite of benefits designed to support and enrich our employees' lives. These include:\\n\\nTraining Opportunities: We believe in lifelong learning and provide numerous avenues for skill enhancement.\\nFully Invested 401K Plan: We help secure your future with a fully invested 401K plan.\\nPPO and HDHP Medical Plans: Choose the health insurance program that best fits your needs.\\nEmployer-Paid Dental and Vision Plans: We cover dental and vision plans, ensuring our employees have access to comprehensive health care.\\nOnsite Fitness Center: Stay fit and healthy with our state-of-the-art fitness center.\\nWellness Program: We promote a healthy lifestyle with our wellness program.\\nCatered Lunches: Enjoy delicious catered lunches regularly.\\nMoser Consulting, we don't just offer jobs\\u2014we offer careers, growth, and a chance to join a thriving community. Come, be a part of our family.\\nMoser Consulting is an Equal Opportunity Employer. All qualified applicants will receive consideration for employment without regard to race, color, religion, sex, sexual orientation, gender identity, national origin, disability, or status as a protected veteran.", "semanticSegments": []}, "location": {"__typename": "JobLocation", "countryCode": "US", "admin1Code": "IN", "admin2Code": "097", "admin3Code": null, "admin4Code": null, "city": "Indianapolis", "postalCode": "46250", "latitude": 39.900684, "longitude": -86.061066, "streetAddress": "6220 Castleway West Dr", "formatted": {"__typename": "FormattedJobLocation", "long": "Indianapolis, IN 46250", "short": "Indianapolis, IN"}}, "occupations": [{"__typename": "JobOccupation", "key": "6D2D2", "label": "Data & Database Occupations"}, {"__typename": "JobOccupation", "key": "EHPW9", "label": "Technology Occupations"}, {"__typename": "JobOccupation", "key": "XXX29", "label": "Data Developers"}], "occupationMostLikelySuids": [{"__typename": "JobOccupation", "key": "XXX29"}], "benefits": [{"__typename": "JobAttribute", "key": "4ZN8U", "label": "Wellness program"}, {"__typename": "JobAttribute", "key": "EY33Q", "label": "Health insurance"}, {"__typename": "JobAttribute", "key": "FQJ2X", "label": "Dental insurance"}, {"__typename": "JobAttribute", "key": "FVKX2", "label": "401(k)"}, {"__typename": "JobAttribute", "key": "RZAT2", "label": "Vision insurance"}], "socialInsurance": [{"__typename": "JobAttribute", "key": "EY33Q", "label": "Health insurance"}], "workingSystem": [], "requiredDocumentsCategorizedAttributes": [], "indeedApply": {"__typename": "JobIndeedApplyAttributes", "key": "eyJqayI6ImI3YTlhMGRiNjlkYTYzZGYiLCJhcGlUb2tlbiI6ImE3MzcwMDc1ZTc4M2I2MmVhYmM4YjU1NGQzNjc0NzQyMjVhNWQyZTllNWFkNjZlNjIxMGNiODUwN2Q3NTk0NDgiLCJqb2JDb21wYW55TmFtZSI6Ik1vc2VyIENvbnN1bHRpbmciLCJqb2JJZCI6ImY3OTlmOWE1ZGVmYSIsImpvYkxvY2F0aW9uIjoiSW5kaWFuYXBvbGlzLCBJTiIsImpvYlRpdGxlIjoiU2VuaW9yIERhdGEgRW5naW5lZXIiLCJwb3N0VXJsIjoiaHR0cHM6Ly9hcHAuYnJlZXp5LmhyL2FwaS9pbnRlZ3JhdGlvbi9pbmRlZWQvYXBwbHkiLCJxdWVzdGlvbnMiOiJodHRwczovL2FwcC5icmVlenkuaHIvYXBpL2ludGVncmF0aW9uL2luZGVlZC9hcHBseS9jLzBiZmM1MmI0N2NmMC9wL2Y3OTlmOWE1ZGVmYS9xLzY3OGNjNDM5ZTE0YSIsImlzTW9iaWxlIjp0cnVlfQ==", "scopes": ["DESKTOP", "MOBILE"]}, "attributes": [{"__typename": "JobAttribute", "key": "35DN8", "label": "RDBMS"}, {"__typename": "JobAttribute", "key": "4ZN8U", "label": "Wellness program"}, {"__typename": "JobAttribute", "key": "5M3JZ", "label": "Data modeling"}, {"__typename": "JobAttribute", "key": "5QGV8", "label": "Cloud infrastructure"}, {"__typename": "JobAttribute", "key": "64VXT", "label": "Azure"}, {"__typename": "JobAttribute", "key": "6AX7W", "label": "Oracle"}, {"__typename": "JobAttribute", "key": "7964P", "label": "Cassandra"}, {"__typename": "JobAttribute", "key": "9B3V2", "label": "Relational databases"}, {"__typename": "JobAttribute", "key": "CF3CP", "label": "Full-time"}, {"__typename": "JobAttribute", "key": "CH5MX", "label": "NoSQL"}, {"__typename": "JobAttribute", "key": "DN4N2", "label": "MongoDB"}, {"__typename": "JobAttribute", "key": "EY33Q", "label": "Health insurance"}, {"__typename": "JobAttribute", "key": "F5XFG", "label": "Databases"}, {"__typename": "JobAttribute", "key": "FGY89", "label": "SQL"}, {"__typename": "JobAttribute", "key": "FQJ2X", "label": "Dental insurance"}, {"__typename": "JobAttribute", "key": "FVKX2", "label": "401(k)"}, {"__typename": "JobAttribute", "key": "GFRKJ", "label": "AWS"}, {"__typename": "JobAttribute", "key": "KGHKZ", "label": "Virtualization"}, {"__typename": "JobAttribute", "key": "MWTB7", "label": "Scripting"}, {"__typename": "JobAttribute", "key": "PAXZC", "label": "Hybrid work"}, {"__typename": "JobAttribute", "key": "PRGNY", "label": "ETL"}, {"__typename": "JobAttribute", "key": "QE236", "label": "Agile"}, {"__typename": "JobAttribute", "key": "QZ8A4", "label": "S3"}, {"__typename": "JobAttribute", "key": "RJTNG", "label": "Teradata"}, {"__typename": "JobAttribute", "key": "RZAT2", "label": "Vision insurance"}, {"__typename": "JobAttribute", "key": "TRVCM", "label": "DynamoDB"}, {"__typename": "JobAttribute", "key": "UB7SC", "label": "Senior level"}, {"__typename": "JobAttribute", "key": "UM4V9", "label": "Informatica"}, {"__typename": "JobAttribute", "key": "WYQ93", "label": "Data warehouse"}, {"__typename": "JobAttribute", "key": "X62BT", "label": "Python"}], "employerProvidedAttributes": [{"__typename": "JobAttribute", "key": "CF3CP", "label": "Full-time"}], "employerProvidedOccupations": [], "hiringDemand": {"__typename": "HiringDemand", "isUrgentHire": false, "isHighVolumeHiring": false}, "thirdPartyTrackingUrls": [], "jobSearchMobileMigrationData": null, "jobStats": {"__typename": "JobStats", "organicApplyStarts": 1}, "isRepost": false, "isLatestPost": true, "isPlacement": null, "employer": {"__typename": "Employer", "key": "e2a87e997487ab85", "tier": "FREE", "relativeCompanyPageUrl": "/cmp/Moser-Consulting", "dossier": {"__typename": "EmployerDossier", "images": {"__typename": "ImageBundle", "rectangularLogoUrl": "https://d2q79iu7y748jz.cloudfront.net/s/_logo/f6fe81cdb96523f844afc0b2ac87b25c", "headerImageUrls": {"__typename": "HeaderImageUrlBundle", "url1960x400": "https://d2q79iu7y748jz.cloudfront.net/s/_headerimage/1960x400/b5da0df7f7cab05b855cbed9421e9731"}, "squareLogoUrls": {"__typename": "SquareLogoUrlBundle", "url256": "https://d2q79iu7y748jz.cloudfront.net/s/_squarelogo/256x256/95bbab933d68d453b3bba4ab26371f24"}}}, "ugcStats": {"__typename": "JobseekerUgcStats", "globalReviewCount": 14, "ratings": {"__typename": "RatingBundle", "overallRating": {"__typename": "AverageRating", "count": 14, "value": 4.1}}}, "subsidiaryOptOutStatusV2": false, "parentEmployer": null}, "jobTypes": [{"__typename": "JobAttribute", "key": "CF3CP", "label": "Full-time"}], "shiftAndSchedule": [], "compensation": {"__typename": "JobCompensation", "key": "CNeWiuEjHQB+5UcggoDaDCiZ8bwMMJHq4AM4ouQHQghmdWxsdGltZUoUU2VuaW9yIERhdGEgRW5naW5lZXJQ6MIPYiIKHgoKDQBQw0cVANYDSBAFGAUiCgiAreIEEOD8twYoAngBag1kYXRhIGVuZ2luZWVycODogL3GMooBBVhYWDI5kgESCg4KCg0Zp8NHFW2990cQBXgBogFcCgNTRVMSCWVzdFNhbGFyeRoQCgNtaW4QBDkAAAAg43T4QBoQCgNtYXgQBDkAAACgrff+QBoTCgdzYWxUeXBlEAIqBllFQVJMWRoRCghjdXJyZW5jeRACKgNVU0SqAQJVU7IBAklOugEMSW5kaWFuYXBvbGlz"}, "applicants": null}, "matchComparisonResult": {"__typename": "MatchComparisonEngineMatchResult", "attributeComparisons": [{"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Databases", "lastModified": 0, "suid": "F5XFG", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "SQL", "lastModified": 0, "suid": "FGY89", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Data warehouse", "lastModified": 0, "suid": "WYQ93", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "MUST_HAVE_JOB_REQUIREMENT", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Virtualization", "lastModified": 0, "suid": "KGHKZ", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "RDBMS", "lastModified": 0, "suid": "35DN8", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Agile", "lastModified": 0, "suid": "QE236", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "DynamoDB", "lastModified": 0, "suid": "TRVCM", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "NoSQL", "lastModified": 0, "suid": "CH5MX", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Cassandra", "lastModified": 0, "suid": "7964P", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Data modeling", "lastModified": 0, "suid": "5M3JZ", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "S3", "lastModified": 0, "suid": "QZ8A4", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "AWS", "lastModified": 0, "suid": "GFRKJ", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Teradata", "lastModified": 0, "suid": "RJTNG", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "MongoDB", "lastModified": 0, "suid": "DN4N2", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Python", "lastModified": 0, "suid": "X62BT", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Scripting", "lastModified": 0, "suid": "MWTB7", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Informatica", "lastModified": 0, "suid": "UM4V9", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Azure", "lastModified": 0, "suid": "64VXT", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Relational databases", "lastModified": 0, "suid": "9B3V2", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Cloud infrastructure", "lastModified": 0, "suid": "5QGV8", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "ETL", "lastModified": 0, "suid": "PRGNY", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}, {"__typename": "MatchComparisonEngineAttributeComparison", "jobProvenance": "EXTRACTED", "attribute": {"__typename": "MatchComparisonEngineAttribute", "interestedParty": "JOB", "label": "Oracle", "lastModified": 0, "suid": "6AX7W", "profileAttributeTypeSuid": "Q2W6Y"}, "jobRequirementStrength": "NONE", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY"}], "encouragementToApply": {"__typename": "MatchComparisonEngineEncouragementToApply", "score": 0, "strategy": "", "trafficLight": "YELLOW"}, "matchOverlapMetric": {"__typename": "MatchComparisonEngineMatchOverlapMetric", "coverage": 0, "jobDetailScore": 0, "locationScore": 0, "matchOverlapScore": 0, "payScore": 0, "qualificationOverlapScore": 0, "version": 0}, "occupationComparisons": [{"__typename": "MatchComparisonEngineOccupationComparison", "jsProvenance": "NOT_PRESENT", "matchType": "JOB_ONLY", "occupation": {"__typename": "MatchComparisonEngineOccupation", "label": "Data Developers", "suid": "XXX29"}}]}}]}}, "errors": [], "query": "query getViewJobJobData($jobKey: ID!, $jobKeyString: String!, $shouldQueryCogsEligibility: Boolean!, $shouldQuerySavedJob: Boolean!, $shouldQueryTitleNorm: Boolean!, $shouldQueryCompanyFields: Boolean!, $shouldQuerySalary: Boolean!, $shouldQueryIndeedApplyLink: Boolean!, $shouldQueryParentEmployer: Boolean!, $shouldQuerySentiment: Boolean!, $shouldIncludeFragmentZone: Boolean!, $shouldQueryMatchComparison: Boolean!, $shouldQueryApplicantInsights: Boolean!, $shouldQueryJobCampaignsConnection: Boolean!, $shouldQueryJobSeekerPreferences: Boolean!, $shouldQueryJobSeekerProfileQuestions: Boolean!, $mobvjtk: String!, $continueUrl: String!, $spn: Boolean!, $jobDataInput: JobDataInput!) {\\n  jobData(input: $jobDataInput) {\\n    __typename\\n    results {\\n      __typename\\n      trackingKey\\n      job {\\n        __typename\\n        key\\n        ...jobDataFields\\n        ...titleNormFields@include(if: $shouldQueryTitleNorm)\\n        ...companyFields@include(if: $shouldQueryCompanyFields)\\n        ...parentEmployerFields@include(if: $shouldQueryParentEmployer)\\n        jobSearchMobileMigrationData @include(if: $shouldQuerySentiment) {\\n          __typename\\n          knownUserSentimentIdMap {\\n            __typename\\n            id\\n            suid\\n          }\\n          userStringDislikedPreferences {\\n            __typename\\n            uid\\n          }\\n          userMinimumPayPreferences {\\n            __typename\\n            currency\\n            payAmount\\n            salaryType\\n          }\\n          preferencesFetchStatus\\n          paySentiment\\n        }\\n        jobTypes: attributes(customClass: \\"BM62A\\") {\\n          __typename\\n          key\\n          label\\n          sentiment @include(if: $shouldQuerySentiment)\\n        }\\n        shiftAndSchedule: attributes(customClass: \\"BTSWR\\") {\\n          __typename\\n          key\\n          label\\n          sentiment @include(if: $shouldQuerySentiment)\\n        }\\n        compensation @include(if: $shouldQuerySalary) {\\n          __typename\\n          key\\n        }\\n        indeedApply @include(if: $shouldQueryIndeedApplyLink) {\\n          __typename\\n          applyLink(property: INDEED, trackingKeys: {mobvjtk : $mobvjtk}, continueUrl: $continueUrl, spn: $spn) {\\n            __typename\\n            url\\n            iaUid\\n          }\\n        }\\n        ...ViewJobFragmentZone@include(if: $shouldIncludeFragmentZone)\\n        applicants @include(if: $shouldQueryApplicantInsights) {\\n          __typename\\n          hasInsights\\n          ...ApplicantDemographicsFields\\n        }\\n        jobCampaignsConnection(input: {spendingEligibilityTypes : [FUNDED_PERIOD_ELIGIBILITY]}) @include(if: $shouldQueryJobCampaignsConnection) {\\n          __typename\\n          campaignCount\\n        }\\n      }\\n      matchComparisonResult @include(if: $shouldQueryMatchComparison) {\\n        __typename\\n        attributeComparisons {\\n          __typename\\n          jobProvenance\\n          attribute {\\n            __typename\\n            interestedParty\\n            label\\n            lastModified\\n            suid\\n            profileAttributeTypeSuid\\n          }\\n          jobRequirementStrength\\n          jsProvenance\\n          matchType\\n        }\\n        encouragementToApply {\\n          __typename\\n          score\\n          strategy\\n          trafficLight\\n        }\\n        matchOverlapMetric {\\n          __typename\\n          coverage\\n          jobDetailScore\\n          locationScore\\n          matchOverlapScore\\n          payScore\\n          qualificationOverlapScore\\n          version\\n        }\\n        occupationComparisons {\\n          __typename\\n          jsProvenance\\n          matchType\\n          occupation {\\n            __typename\\n            label\\n            suid\\n          }\\n        }\\n      }\\n    }\\n  }\\n  savedJobsByKey(keys: [$jobKey]) @include(if: $shouldQuerySavedJob) {\\n    __typename\\n    state\\n    currentStateTime\\n  }\\n  cogsCheckEligibility(input: {jobKey : $jobKeyString}) @include(if: $shouldQueryCogsEligibility) {\\n    __typename\\n    error\\n    isEligible\\n  }\\n  jobSeekerProfile @include(if: $shouldQueryApplicantInsights) {\\n    __typename\\n    profile {\\n      __typename\\n      jobSeekerPro {\\n        __typename\\n        status\\n      }\\n    }\\n  }\\n  jobSeekerProfileStructuredData(input: {queryFilter : {dataCategory : CONFIRMED_BY_USER}}) @include(if: $shouldQueryJobSeekerPreferences) {\\n    __typename\\n    preferences {\\n      __typename\\n      jobTitles {\\n        __typename\\n        jobTitle\\n      }\\n      minimumPay {\\n        __typename\\n        amount\\n        salaryType\\n      }\\n    }\\n  }\\n  jobSeekerProfileQuestionFieldSet(input: {source : VJP_GATING}) @include(if: $shouldQueryJobSeekerProfileQuestions) {\\n    __typename\\n    questionFields {\\n      __typename\\n      name\\n    }\\n  }\\n}\\n\\nfragment jobDataFields on Job {\\n  __typename\\n  title\\n  sourceEmployerName\\n  datePublished\\n  expired\\n  language\\n  normalizedTitle\\n  refNum\\n  expirationDate\\n  source {\\n    __typename\\n    key\\n    name\\n  }\\n  feed {\\n    __typename\\n    key\\n    isDradis\\n    feedSourceType\\n  }\\n  url\\n  dateOnIndeed\\n  description {\\n    __typename\\n    html\\n    text\\n    semanticSegments {\\n      __typename\\n      content\\n      header\\n      label\\n    }\\n  }\\n  location {\\n    __typename\\n    countryCode\\n    admin1Code\\n    admin2Code\\n    admin3Code\\n    admin4Code\\n    city\\n    postalCode\\n    latitude\\n    longitude\\n    streetAddress\\n    formatted {\\n      __typename\\n      long\\n      short\\n    }\\n  }\\n  occupations {\\n    __typename\\n    key\\n    label\\n  }\\n  occupationMostLikelySuids: occupations(occupationOption: MOST_LIKELY) {\\n    __typename\\n    key\\n  }\\n  benefits: attributes(customClass: \\"SXMYH\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  socialInsurance: attributes(customClass: \\"KTQQ7\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  workingSystem: attributes(customClass: \\"TY4DY\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  requiredDocumentsCategorizedAttributes: attributes(customClass: \\"PQCTE\\") {\\n    __typename\\n    key\\n    label\\n  }\\n  indeedApply {\\n    __typename\\n    key\\n    scopes\\n  }\\n  attributes {\\n    __typename\\n    key\\n    label\\n  }\\n  employerProvidedAttributes: attributes(sources: [EMPLOYER]) {\\n    __typename\\n    key\\n    label\\n  }\\n  employerProvidedOccupations: occupations(sources: [EMPLOYER], occupationOption: MOST_SPECIFIC) {\\n    __typename\\n    label\\n  }\\n  hiringDemand {\\n    __typename\\n    isUrgentHire\\n    isHighVolumeHiring\\n  }\\n  thirdPartyTrackingUrls\\n  jobSearchMobileMigrationData {\\n    __typename\\n    advertiserId\\n    jobTypeId\\n    applyEmail\\n    applyUrl\\n    contactEmail\\n    contactPhone\\n    isNoUniqueUrl\\n    urlRewriteRule\\n    mapDisplayType\\n    jobTags\\n    locCountry\\n    waldoVisibilityLevel\\n    isKnownSponsoredOnDesktop\\n    isKnownSponsoredOnMobile\\n    tpiaAdvNum\\n    tpiaApiToken\\n    tpiaCoverLetter\\n    tpiaEmail\\n    tpiaFinishAppUrl\\n    tpiaJobCompanyName\\n    tpiaJobId\\n    tpiaJobLocation\\n    tpiaJobMeta\\n    tpiaJobTitle\\n    tpiaLocale\\n    tpiaName\\n    tpiaPhone\\n    tpiaPostUrl\\n    tpiaPresent\\n    tpiaResume\\n    tpiaResumeFieldsOptional\\n    tpiaResumeFieldsRequired\\n    tpiaScreenerQuestions\\n    iaVisibility\\n    hasPreciseLocation\\n    algoKey\\n  }\\n  jobStats {\\n    __typename\\n    organicApplyStarts\\n  }\\n  isRepost\\n  isLatestPost\\n  isPlacement\\n}\\n\\nfragment titleNormFields on Job {\\n  __typename\\n  normalizedTitle\\n  displayTitle\\n}\\n\\nfragment companyFields on Job {\\n  __typename\\n  employer {\\n    __typename\\n    key\\n    tier\\n    relativeCompanyPageUrl\\n    dossier {\\n      __typename\\n      images {\\n        __typename\\n        rectangularLogoUrl\\n        headerImageUrls {\\n          __typename\\n          url1960x400\\n        }\\n        squareLogoUrls {\\n          __typename\\n          url256\\n        }\\n      }\\n    }\\n    ugcStats {\\n      __typename\\n      globalReviewCount\\n      ratings {\\n        __typename\\n        overallRating {\\n          __typename\\n          count\\n          value\\n        }\\n      }\\n    }\\n  }\\n}\\n\\nfragment parentEmployerFields on Job {\\n  __typename\\n  employer {\\n    __typename\\n    subsidiaryOptOutStatusV2\\n    parentEmployer {\\n      __typename\\n      name\\n      subsidiaryOptOutStatusV2\\n    }\\n  }\\n}\\n\\nfragment ViewJobFragmentZone on Job {\\n  key\\n  __typename\\n}\\n\\nfragment ApplicantDemographicsFields on Applicants {\\n  __typename\\n  count {\\n    __typename\\n    total\\n    last24h\\n  }\\n  workExperience {\\n    __typename\\n    title\\n    pct\\n  }\\n  education {\\n    __typename\\n    title\\n    pct\\n  }\\n  skills {\\n    __typename\\n    title\\n    pct\\n  }\\n  certificates {\\n    __typename\\n    title\\n    pct\\n  }\\n}\\n", "variables": {"jobKey": "b7a9a0db69da63df", "jobKeyString": "b7a9a0db69da63df", "shouldQueryCogsEligibility": false, "shouldQuerySavedJob": false, "shouldQueryTitleNorm": false, "shouldQueryCompanyFields": true, "shouldQuerySalary": true, "shouldQueryIndeedApplyLink": false, "shouldQueryParentEmployer": true, "shouldQuerySentiment": false, "shouldIncludeFragmentZone": false, "shouldQueryMatchComparison": true, "shouldQueryApplicantInsights": false, "shouldQueryJobCampaignsConnection": false, "shouldQueryJobSeekerPreferences": false, "shouldQueryJobSeekerProfileQuestions": false, "mobvjtk": "1ihka6gseg6l9800", "continueUrl": "http://www.indeed.com/viewjob?jk=b7a9a0db69da63df&from=serp&vjs=3&applied=1", "spn": false, "jobDataInput": {"jobKeys": ["b7a9a0db69da63df"], "useSearchlessPrice": false}}}}	INDEED	DATA_ENGINEER	2025-01-15 00:26:03.3057+00	f	\N	\N
\.


--
-- Name: processed_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.processed_jobs_id_seq', 1, false);


--
-- Name: raw_job_posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.raw_job_posts_id_seq', 6, true);


--
-- Name: processed_jobs processed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.processed_jobs
    ADD CONSTRAINT processed_jobs_pkey PRIMARY KEY (id);


--
-- Name: processed_jobs processed_jobs_raw_job_post_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.processed_jobs
    ADD CONSTRAINT processed_jobs_raw_job_post_id_key UNIQUE (raw_job_post_id);


--
-- Name: raw_job_posts raw_job_posts_job_url_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.raw_job_posts
    ADD CONSTRAINT raw_job_posts_job_url_key UNIQUE (job_url);


--
-- Name: raw_job_posts raw_job_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.raw_job_posts
    ADD CONSTRAINT raw_job_posts_pkey PRIMARY KEY (id);


--
-- Name: ix_processed_jobs_date_posted; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_processed_jobs_date_posted ON public.processed_jobs USING btree (date_posted);


--
-- Name: ix_processed_jobs_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_processed_jobs_id ON public.processed_jobs USING btree (id);


--
-- Name: ix_processed_jobs_remote_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_processed_jobs_remote_status ON public.processed_jobs USING btree (remote_status);


--
-- Name: ix_processed_jobs_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_processed_jobs_status ON public.processed_jobs USING btree (status);


--
-- Name: ix_raw_job_posts_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_raw_job_posts_id ON public.raw_job_posts USING btree (id);


--
-- Name: ix_raw_job_posts_job_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_raw_job_posts_job_category ON public.raw_job_posts USING btree (job_category);


--
-- Name: ix_raw_job_posts_source; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_raw_job_posts_source ON public.raw_job_posts USING btree (source);


--
-- Name: processed_jobs processed_jobs_raw_job_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.processed_jobs
    ADD CONSTRAINT processed_jobs_raw_job_post_id_fkey FOREIGN KEY (raw_job_post_id) REFERENCES public.raw_job_posts(id);


--
-- Name: DATABASE job_postings; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON DATABASE job_postings TO job_postings;


--
-- PostgreSQL database dump complete
--

--
-- Database "postgres" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 15.10 (Debian 15.10-1.pgdg120+1)
-- Dumped by pg_dump version 15.10 (Debian 15.10-1.pgdg120+1)

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

DROP DATABASE postgres;
--
-- Name: postgres; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE postgres WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE postgres OWNER TO postgres;

\connect postgres

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
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

