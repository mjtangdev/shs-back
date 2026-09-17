--
-- PostgreSQL database dump
--

\restrict iaArNs1j6iKbvxh6376KcA4lNvHJ4Kub0cOnLezDrccGeuG3hyJtgYA88L2ZOeO

-- Dumped from database version 16.15 (Debian 16.15-1.pgdg13+2)
-- Dumped by pg_dump version 16.15 (Debian 16.15-1.pgdg13+2)

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
-- Name: business_entities; Type: TABLE; Schema: public; Owner: solar_admin
--

CREATE TABLE public.business_entities (
    id integer NOT NULL,
    name character varying NOT NULL,
    address character varying,
    entity_type smallint NOT NULL,
    region_id integer,
    is_deleted boolean
);


ALTER TABLE public.business_entities OWNER TO solar_admin;

--
-- Name: business_entities_id_seq; Type: SEQUENCE; Schema: public; Owner: solar_admin
--

CREATE SEQUENCE public.business_entities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.business_entities_id_seq OWNER TO solar_admin;

--
-- Name: business_entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: solar_admin
--

ALTER SEQUENCE public.business_entities_id_seq OWNED BY public.business_entities.id;


--
-- Name: cards; Type: TABLE; Schema: public; Owner: solar_admin
--

CREATE TABLE public.cards (
    id integer NOT NULL,
    card_number character varying(100),
    card_uuid character varying(100) NOT NULL,
    status integer,
    customer_uuid character varying(100),
    created_at timestamp without time zone,
    bound_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.cards OWNER TO solar_admin;

--
-- Name: cards_id_seq; Type: SEQUENCE; Schema: public; Owner: solar_admin
--

CREATE SEQUENCE public.cards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cards_id_seq OWNER TO solar_admin;

--
-- Name: cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: solar_admin
--

ALTER SEQUENCE public.cards_id_seq OWNED BY public.cards.id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: solar_admin
--

CREATE TABLE public.customers (
    id integer NOT NULL,
    uuid character varying(100) NOT NULL,
    offline_origin_uuid character varying(100),
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    gender character varying(10),
    mobile character varying(20) NOT NULL,
    email character varying(100),
    birthday date,
    address character varying(255),
    region_id integer NOT NULL,
    status integer,
    electric_company character varying(200),
    beneficiary_count integer,
    representative_name character varying(100),
    rep_relationship character varying(50),
    expiry_time timestamp without time zone,
    total_recharged_days numeric(10,2),
    total_recharged_amount numeric(10,2),
    installed_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.customers OWNER TO solar_admin;

--
-- Name: COLUMN customers.offline_origin_uuid; Type: COMMENT; Schema: public; Owner: solar_admin
--

COMMENT ON COLUMN public.customers.offline_origin_uuid IS 'POS离线开户时的原始字母UUID，用于映射匹配流水';


--
-- Name: COLUMN customers.electric_company; Type: COMMENT; Schema: public; Owner: solar_admin
--

COMMENT ON COLUMN public.customers.electric_company IS 'Associated with Provider Name';


--
-- Name: COLUMN customers.beneficiary_count; Type: COMMENT; Schema: public; Owner: solar_admin
--

COMMENT ON COLUMN public.customers.beneficiary_count IS 'Number of beneficiaries';


--
-- Name: COLUMN customers.representative_name; Type: COMMENT; Schema: public; Owner: solar_admin
--

COMMENT ON COLUMN public.customers.representative_name IS 'Name of the Representative';


--
-- Name: COLUMN customers.rep_relationship; Type: COMMENT; Schema: public; Owner: solar_admin
--

COMMENT ON COLUMN public.customers.rep_relationship IS 'Relationship with the representative';


--
-- Name: COLUMN customers.expiry_time; Type: COMMENT; Schema: public; Owner: solar_admin
--

COMMENT ON COLUMN public.customers.expiry_time IS '服务到期时间';


--
-- Name: COLUMN customers.total_recharged_days; Type: COMMENT; Schema: public; Owner: solar_admin
--

COMMENT ON COLUMN public.customers.total_recharged_days IS '累计充值天数';


--
-- Name: COLUMN customers.total_recharged_amount; Type: COMMENT; Schema: public; Owner: solar_admin
--

COMMENT ON COLUMN public.customers.total_recharged_amount IS '累计充值金额';


--
-- Name: COLUMN customers.installed_at; Type: COMMENT; Schema: public; Owner: solar_admin
--

COMMENT ON COLUMN public.customers.installed_at IS '设备与卡片初次安装时间';


--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: solar_admin
--

CREATE SEQUENCE public.customers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customers_id_seq OWNER TO solar_admin;

--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: solar_admin
--

ALTER SEQUENCE public.customers_id_seq OWNED BY public.customers.id;


--
-- Name: pos_action_logs; Type: TABLE; Schema: public; Owner: solar_admin
--

CREATE TABLE public.pos_action_logs (
    id integer NOT NULL,
    pos_sn character varying(16),
    action_type character varying(50),
    operator character varying(50),
    role character varying(20),
    remark text,
    "timestamp" timestamp without time zone
);


ALTER TABLE public.pos_action_logs OWNER TO solar_admin;

--
-- Name: pos_action_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: solar_admin
--

CREATE SEQUENCE public.pos_action_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pos_action_logs_id_seq OWNER TO solar_admin;

--
-- Name: pos_action_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: solar_admin
--

ALTER SEQUENCE public.pos_action_logs_id_seq OWNED BY public.pos_action_logs.id;


--
-- Name: pos_machines; Type: TABLE; Schema: public; Owner: solar_admin
--

CREATE TABLE public.pos_machines (
    id integer NOT NULL,
    pos_sn character varying(16) NOT NULL,
    pos_code character varying(2),
    status integer,
    lock_status integer,
    is_deleted boolean,
    region_id integer,
    branch_office character varying(100),
    reconciliation_deadline timestamp without time zone,
    last_reconciliation_at timestamp without time zone,
    last_lock_reason character varying(255),
    last_action_by character varying(50),
    assigned_user_id integer,
    last_login_at timestamp without time zone,
    last_ip character varying(50),
    app_version character varying(20),
    version_type character varying(20),
    mac_address character varying(30),
    latitude character varying(20),
    longitude character varying(20),
    created_at timestamp without time zone,
    created_by character varying(50)
);


ALTER TABLE public.pos_machines OWNER TO solar_admin;

--
-- Name: pos_machines_id_seq; Type: SEQUENCE; Schema: public; Owner: solar_admin
--

CREATE SEQUENCE public.pos_machines_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pos_machines_id_seq OWNER TO solar_admin;

--
-- Name: pos_machines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: solar_admin
--

ALTER SEQUENCE public.pos_machines_id_seq OWNED BY public.pos_machines.id;


--
-- Name: pos_staging_customers; Type: TABLE; Schema: public; Owner: solar_admin
--

CREATE TABLE public.pos_staging_customers (
    id integer NOT NULL,
    customer_uuid character varying(100) NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    card_uuid character varying(100),
    shs_machine_id character varying(100),
    gender character varying(10),
    mobile character varying(20) NOT NULL,
    email character varying(100),
    birthday timestamp without time zone,
    address character varying(255),
    region_id integer NOT NULL,
    status integer,
    beneficiary_count integer,
    representative_name character varying(100),
    rep_relationship character varying(50),
    pos_sn character varying(16),
    operator_username character varying(50),
    upload_time timestamp without time zone,
    processed_status integer,
    processing_error text
);


ALTER TABLE public.pos_staging_customers OWNER TO solar_admin;

--
-- Name: pos_staging_customers_id_seq; Type: SEQUENCE; Schema: public; Owner: solar_admin
--

CREATE SEQUENCE public.pos_staging_customers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pos_staging_customers_id_seq OWNER TO solar_admin;

--
-- Name: pos_staging_customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: solar_admin
--

ALTER SEQUENCE public.pos_staging_customers_id_seq OWNED BY public.pos_staging_customers.id;


--
-- Name: pos_staging_transactions; Type: TABLE; Schema: public; Owner: solar_admin
--

CREATE TABLE public.pos_staging_transactions (
    id integer NOT NULL,
    transaction_id character varying(100) NOT NULL,
    customer_uuid character varying(100) NOT NULL,
    card_uuid character varying(100) NOT NULL,
    shs_machine_id character varying(100),
    days numeric(10,2) NOT NULL,
    amount numeric(10,2) NOT NULL,
    transaction_time timestamp without time zone NOT NULL,
    action_type character varying(50),
    pos_sn character varying(16),
    operator_username character varying(50),
    upload_time timestamp without time zone,
    processed_status integer,
    processing_error text
);


ALTER TABLE public.pos_staging_transactions OWNER TO solar_admin;

--
-- Name: COLUMN pos_staging_transactions.shs_machine_id; Type: COMMENT; Schema: public; Owner: solar_admin
--

COMMENT ON COLUMN public.pos_staging_transactions.shs_machine_id IS '离线操作关联的主机ID';


--
-- Name: pos_staging_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: solar_admin
--

CREATE SEQUENCE public.pos_staging_transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pos_staging_transactions_id_seq OWNER TO solar_admin;

--
-- Name: pos_staging_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: solar_admin
--

ALTER SEQUENCE public.pos_staging_transactions_id_seq OWNED BY public.pos_staging_transactions.id;


--
-- Name: provider_configs; Type: TABLE; Schema: public; Owner: solar_admin
--

CREATE TABLE public.provider_configs (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    tin character varying(50) NOT NULL,
    logo_url character varying(255),
    phone character varying(50),
    email character varying(100),
    address text,
    is_initialized boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.provider_configs OWNER TO solar_admin;

--
-- Name: COLUMN provider_configs.name; Type: COMMENT; Schema: public; Owner: solar_admin
--

COMMENT ON COLUMN public.provider_configs.name IS 'Provider/Company Name';


--
-- Name: COLUMN provider_configs.tin; Type: COMMENT; Schema: public; Owner: solar_admin
--

COMMENT ON COLUMN public.provider_configs.tin IS 'Tax Identification Number (TIN)';


--
-- Name: COLUMN provider_configs.logo_url; Type: COMMENT; Schema: public; Owner: solar_admin
--

COMMENT ON COLUMN public.provider_configs.logo_url IS 'Storage path or URL of company logo (PNG)';


--
-- Name: COLUMN provider_configs.phone; Type: COMMENT; Schema: public; Owner: solar_admin
--

COMMENT ON COLUMN public.provider_configs.phone IS 'Company contact phone number';


--
-- Name: COLUMN provider_configs.email; Type: COMMENT; Schema: public; Owner: solar_admin
--

COMMENT ON COLUMN public.provider_configs.email IS 'Company email address';


--
-- Name: COLUMN provider_configs.address; Type: COMMENT; Schema: public; Owner: solar_admin
--

COMMENT ON COLUMN public.provider_configs.address IS 'Company physical address';


--
-- Name: COLUMN provider_configs.is_initialized; Type: COMMENT; Schema: public; Owner: solar_admin
--

COMMENT ON COLUMN public.provider_configs.is_initialized IS 'Whether the config has been updated by user';


--
-- Name: provider_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: solar_admin
--

CREATE SEQUENCE public.provider_configs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.provider_configs_id_seq OWNER TO solar_admin;

--
-- Name: provider_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: solar_admin
--

ALTER SEQUENCE public.provider_configs_id_seq OWNED BY public.provider_configs.id;


--
-- Name: regions; Type: TABLE; Schema: public; Owner: solar_admin
--

CREATE TABLE public.regions (
    id integer NOT NULL,
    name character varying NOT NULL,
    level integer,
    parent_id integer,
    daily_rate numeric(10,2),
    last_rate_updated_at timestamp without time zone,
    last_rate_modified_by_id integer
);


ALTER TABLE public.regions OWNER TO solar_admin;

--
-- Name: COLUMN regions.daily_rate; Type: COMMENT; Schema: public; Owner: solar_admin
--

COMMENT ON COLUMN public.regions.daily_rate IS '区域专属费率，若为Null则继承上级';


--
-- Name: regions_id_seq; Type: SEQUENCE; Schema: public; Owner: solar_admin
--

CREATE SEQUENCE public.regions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.regions_id_seq OWNER TO solar_admin;

--
-- Name: regions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: solar_admin
--

ALTER SEQUENCE public.regions_id_seq OWNED BY public.regions.id;


--
-- Name: solar_units; Type: TABLE; Schema: public; Owner: solar_admin
--

CREATE TABLE public.solar_units (
    id integer NOT NULL,
    shs_machine_id character varying(100) NOT NULL,
    solar_equipment_id character varying(100) NOT NULL,
    radio_id character varying(100) NOT NULL,
    flashlight_id character varying(100) NOT NULL,
    led_light_id character varying(100) NOT NULL,
    shs_status integer,
    equipment_status integer,
    radio_status integer,
    flashlight_status integer,
    led_status integer,
    customer_uuid character varying(100),
    customer_name character varying(100),
    city character varying(100),
    town character varying(100),
    production_date timestamp without time zone,
    created_at timestamp without time zone,
    bound_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.solar_units OWNER TO solar_admin;

--
-- Name: solar_units_id_seq; Type: SEQUENCE; Schema: public; Owner: solar_admin
--

CREATE SEQUENCE public.solar_units_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.solar_units_id_seq OWNER TO solar_admin;

--
-- Name: solar_units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: solar_admin
--

ALTER SEQUENCE public.solar_units_id_seq OWNED BY public.solar_units.id;


--
-- Name: transaction_logs; Type: TABLE; Schema: public; Owner: solar_admin
--

CREATE TABLE public.transaction_logs (
    id integer NOT NULL,
    transaction_id character varying(100) NOT NULL,
    customer_uuid character varying(100) NOT NULL,
    card_uuid character varying(100),
    shs_machine_id character varying(100),
    days numeric(10,2) NOT NULL,
    amount numeric(10,2) NOT NULL,
    transaction_time timestamp without time zone NOT NULL,
    action_type character varying(50),
    pos_sn character varying(16),
    operator_username character varying(50),
    created_at timestamp without time zone
);


ALTER TABLE public.transaction_logs OWNER TO solar_admin;

--
-- Name: COLUMN transaction_logs.shs_machine_id; Type: COMMENT; Schema: public; Owner: solar_admin
--

COMMENT ON COLUMN public.transaction_logs.shs_machine_id IS '交易关联的设备ID';


--
-- Name: transaction_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: solar_admin
--

CREATE SEQUENCE public.transaction_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.transaction_logs_id_seq OWNER TO solar_admin;

--
-- Name: transaction_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: solar_admin
--

ALTER SEQUENCE public.transaction_logs_id_seq OWNED BY public.transaction_logs.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: solar_admin
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying NOT NULL,
    password_hash character varying NOT NULL,
    role integer,
    is_active boolean,
    is_deleted boolean,
    first_name character varying,
    middle_name character varying,
    last_name character varying,
    mobile character varying,
    landline character varying,
    email character varying,
    ice_name character varying,
    ice_phone character varying,
    province character varying,
    region_id integer,
    address text,
    created_at timestamp without time zone
);


ALTER TABLE public.users OWNER TO solar_admin;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: solar_admin
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO solar_admin;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: solar_admin
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: business_entities id; Type: DEFAULT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.business_entities ALTER COLUMN id SET DEFAULT nextval('public.business_entities_id_seq'::regclass);


--
-- Name: cards id; Type: DEFAULT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.cards ALTER COLUMN id SET DEFAULT nextval('public.cards_id_seq'::regclass);


--
-- Name: customers id; Type: DEFAULT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.customers ALTER COLUMN id SET DEFAULT nextval('public.customers_id_seq'::regclass);


--
-- Name: pos_action_logs id; Type: DEFAULT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.pos_action_logs ALTER COLUMN id SET DEFAULT nextval('public.pos_action_logs_id_seq'::regclass);


--
-- Name: pos_machines id; Type: DEFAULT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.pos_machines ALTER COLUMN id SET DEFAULT nextval('public.pos_machines_id_seq'::regclass);


--
-- Name: pos_staging_customers id; Type: DEFAULT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.pos_staging_customers ALTER COLUMN id SET DEFAULT nextval('public.pos_staging_customers_id_seq'::regclass);


--
-- Name: pos_staging_transactions id; Type: DEFAULT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.pos_staging_transactions ALTER COLUMN id SET DEFAULT nextval('public.pos_staging_transactions_id_seq'::regclass);


--
-- Name: provider_configs id; Type: DEFAULT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.provider_configs ALTER COLUMN id SET DEFAULT nextval('public.provider_configs_id_seq'::regclass);


--
-- Name: regions id; Type: DEFAULT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.regions ALTER COLUMN id SET DEFAULT nextval('public.regions_id_seq'::regclass);


--
-- Name: solar_units id; Type: DEFAULT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.solar_units ALTER COLUMN id SET DEFAULT nextval('public.solar_units_id_seq'::regclass);


--
-- Name: transaction_logs id; Type: DEFAULT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.transaction_logs ALTER COLUMN id SET DEFAULT nextval('public.transaction_logs_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: business_entities; Type: TABLE DATA; Schema: public; Owner: solar_admin
--

COPY public.business_entities (id, name, address, entity_type, region_id, is_deleted) FROM stdin;
\.


--
-- Data for Name: cards; Type: TABLE DATA; Schema: public; Owner: solar_admin
--

COPY public.cards (id, card_number, card_uuid, status, customer_uuid, created_at, bound_at, updated_at) FROM stdin;
246	\N	F6591DBB	1	05000083	2026-09-02 06:14:01.490993	2026-09-05 06:01:26.562305	2026-09-05 06:01:26.567852
261	\N	A6EA28BB	1	05000098	2026-09-02 13:31:10.003612	2026-09-05 07:05:38.405583	2026-09-05 07:05:38.53603
264	\N	A64E3ABB	1	05000101	2026-09-02 13:31:26.085445	2026-09-05 07:05:38.485361	2026-09-05 07:05:38.536031
267	\N	E6EC58BB	1	05000104	2026-09-02 13:31:38.438522	2026-09-05 07:05:38.347157	2026-09-05 07:05:38.536033
273	\N	E66B23BB	1	05000110	2026-09-02 13:32:07.240422	2026-09-05 07:05:38.500948	2026-09-05 07:05:38.536034
292	\N	C61B25BB	1	05000129	2026-09-02 13:33:23.148298	2026-09-05 07:05:38.395648	2026-09-05 07:05:38.536038
109	\N	96241CBB	1	03000103	2026-08-31 05:31:23.306089	2026-09-15 05:50:32.374146	2026-09-15 05:50:32.37998
48	\N	E6331FBB	1	03000062	2026-08-31 05:21:06.552219	2026-09-04 02:10:35.524611	2026-09-04 02:10:35.539824
294	\N	368C59BB	1	05000131	2026-09-02 13:33:31.18657	2026-09-05 07:05:38.400577	2026-09-05 07:05:38.536039
295	\N	F6745DBB	1	05000132	2026-09-02 13:33:50.512842	2026-09-05 07:05:38.482801	2026-09-05 07:05:38.53604
296	\N	C61B1ABB	1	05000133	2026-09-02 13:33:54.034682	2026-09-05 07:05:38.378585	2026-09-05 07:05:38.53604
297	\N	F6B326BB	1	05000134	2026-09-02 13:33:58.787372	2026-09-05 07:05:38.393124	2026-09-05 07:05:38.53604
299	\N	861123BB	1	05000136	2026-09-02 13:34:05.647391	2026-09-05 07:05:38.364894	2026-09-05 07:05:38.536041
258	\N	76675CBB	1	05000095	2026-09-02 13:30:56.287243	2026-09-05 10:18:26.100351	2026-09-05 10:18:26.133054
270	\N	561E1BBB	1	05000107	2026-09-02 13:31:54.27166	2026-09-05 10:18:26.105203	2026-09-05 10:18:26.133057
276	\N	863F25BB	1	05000113	2026-09-02 13:32:24.488395	2026-09-05 10:18:26.115598	2026-09-05 10:18:26.133057
210	\N	46AF55BB	1	05000047	2026-09-02 06:10:35.110499	2026-09-05 13:13:54.255576	2026-09-05 13:13:54.272224
240	\N	96501DBB	1	05000077	2026-09-02 06:13:37.036832	2026-09-05 13:13:54.26292	2026-09-05 13:13:54.272227
3	\N	068450BB	1	03000001	2026-08-28 05:48:40.423172	2026-09-15 05:46:20.756781	2026-09-15 05:46:20.897295
9	\N	866835BB	1	03000002	2026-08-31 03:14:27.410821	2026-09-15 05:46:20.807799	2026-09-15 05:46:20.897297
45	\N	86F254BB	1	03000038	2026-08-31 05:19:51.653821	2026-09-15 06:47:55.254411	2026-09-15 06:47:55.333468
46	\N	A6B65BBB	1	03000039	2026-08-31 05:19:58.91955	2026-09-15 06:47:55.184674	2026-09-15 06:47:55.33347
94	\N	661A3EBB	1	03000087	2026-08-31 05:28:10.307511	2026-09-15 06:47:55.233765	2026-09-15 06:47:55.333477
96	\N	269C56BB	1	03000089	2026-08-31 05:28:21.652903	2026-09-15 06:47:55.202682	2026-09-15 06:47:55.333477
97	\N	662C23BB	1	03000090	2026-08-31 05:28:25.986575	2026-09-15 06:47:55.238875	2026-09-15 06:47:55.333477
99	\N	768236BB	1	03000092	2026-08-31 05:29:07.854353	2026-09-15 06:47:55.210648	2026-09-15 06:47:55.333478
108	\N	B65442BB	1	03000111	2026-08-31 05:31:12.735503	2026-09-15 06:47:55.169234	2026-09-15 06:47:55.333479
110	\N	464B51BB	1	03000113	2026-08-31 05:31:27.725044	2026-09-15 06:47:55.171714	2026-09-15 06:47:55.33348
114	\N	A6F824BB	1	03000117	2026-08-31 05:31:50.459335	2026-09-15 06:47:55.249269	2026-09-15 06:47:55.33348
116	\N	D60F4FBB	1	03000119	2026-08-31 05:33:15.159335	2026-09-15 06:47:55.174531	2026-09-15 06:47:55.33348
29	\N	662D25BB	1	03000022	2026-08-31 05:16:13.873418	2026-09-15 06:48:05.539483	2026-09-15 06:48:05.708531
30	\N	56A935BB	1	03000023	2026-08-31 05:16:21.895082	2026-09-15 06:48:05.534611	2026-09-15 06:48:05.708531
31	\N	D6ED56BB	1	03000024	2026-08-31 05:16:26.868971	2026-09-15 06:48:05.537123	2026-09-15 06:48:05.708532
32	\N	264A2EBB	1	03000025	2026-08-31 05:16:35.589626	2026-09-15 06:48:05.632656	2026-09-15 06:48:05.708532
33	\N	562F3ABB	1	03000026	2026-08-31 05:17:19.851106	2026-09-15 06:48:05.544182	2026-09-15 06:48:05.708532
34	\N	B6DA55BB	1	03000027	2026-08-31 05:17:28.040956	2026-09-15 06:48:05.579062	2026-09-15 06:48:05.708533
35	\N	664623BB	1	03000028	2026-08-31 05:17:35.407087	2026-09-15 06:48:05.622151	2026-09-15 06:48:05.708533
36	\N	C62043BB	1	03000029	2026-08-31 05:17:41.900412	2026-09-15 06:48:05.548494	2026-09-15 06:48:05.708533
37	\N	063D44BB	1	03000030	2026-08-31 05:18:58.498931	2026-09-15 06:48:05.541972	2026-09-15 06:48:05.708534
38	\N	76364DBB	1	03000031	2026-08-31 05:19:05.362648	2026-09-15 06:48:05.624801	2026-09-15 06:48:05.708534
39	\N	169E4BBB	1	03000032	2026-08-31 05:19:10.466942	2026-09-15 06:48:05.627544	2026-09-15 06:48:05.708534
41	\N	264759BB	1	03000034	2026-08-31 05:19:22.579366	2026-09-15 06:48:05.635244	2026-09-15 06:48:05.708535
87	\N	D6DF41BB	1	03000080	2026-08-31 05:27:30.048556	2026-09-15 06:48:05.586019	2026-09-15 06:48:05.708536
92	\N	96EA26BB	1	03000085	2026-08-31 05:27:59.80185	2026-09-15 06:48:05.553217	2026-09-15 06:48:05.708536
164	\N	764431BB	1	05000001	2026-09-02 05:54:13.440884	2026-09-03 06:50:21.387557	2026-09-03 06:50:21.434327
93	\N	964151BB	1	03000086	2026-08-31 05:28:04.382402	2026-09-15 06:48:05.588307	2026-09-15 06:48:05.708536
170	\N	76F62EBB	1	05000007	2026-09-02 05:54:43.194732	2026-09-05 02:49:34.020485	2026-09-05 02:49:34.065293
183	\N	A6904BBB	1	05000020	2026-09-02 05:56:02.22414	2026-09-05 03:09:46.025414	2026-09-05 03:09:46.031949
189	\N	66B219BB	1	05000026	2026-09-02 05:56:29.706541	2026-09-05 03:14:44.704273	2026-09-05 03:14:44.717821
192	\N	76F65BBB	1	05000029	2026-09-02 05:56:44.5966	2026-09-05 03:14:44.707807	2026-09-05 03:14:44.717823
186	\N	F6D335BB	1	05000023	2026-09-02 05:56:15.77943	2026-09-05 03:22:07.264442	2026-09-05 03:22:07.290412
195	\N	263F5DBB	1	05000032	2026-09-02 05:56:58.849503	2026-09-05 03:22:07.257955	2026-09-05 03:22:07.290416
199	\N	16574BBB	1	05000036	2026-09-02 05:57:15.878622	2026-09-05 03:22:07.262325	2026-09-05 03:22:07.290417
202	\N	564944BB	1	05000039	2026-09-02 05:57:28.310996	2026-09-05 03:22:07.244622	2026-09-05 03:22:07.290418
213	\N	364E52BB	1	05000050	2026-09-02 06:10:49.803299	2026-09-05 05:23:20.916508	2026-09-05 05:23:20.957549
216	\N	860627BB	1	05000053	2026-09-02 06:11:05.541475	2026-09-05 05:23:20.873455	2026-09-05 05:23:20.95755
219	\N	C6354DBB	1	05000056	2026-09-02 06:11:18.675354	2026-09-05 05:23:20.833905	2026-09-05 05:23:20.957551
222	\N	26EA39BB	1	05000059	2026-09-02 06:11:29.442735	2026-09-05 05:23:20.828929	2026-09-05 05:23:20.957552
98	\N	362E58BB	1	03000091	2026-08-31 05:29:02.36438	2026-09-15 06:48:05.591106	2026-09-15 06:48:05.708537
100	\N	262B35BB	1	03000093	2026-08-31 05:29:13.16685	2026-09-15 06:48:05.593615	2026-09-15 06:48:05.708537
111	\N	06942ABB	1	03000114	2026-08-31 05:31:34.950246	2026-09-15 06:48:05.596195	2026-09-15 06:48:05.708539
112	\N	960E4BBB	1	03000120	2026-08-31 05:31:39.331712	2026-09-15 06:48:05.564662	2026-09-15 06:48:05.708539
113	\N	96C343BB	1	03000116	2026-08-31 05:31:45.834833	2026-09-15 06:48:05.566803	2026-09-15 06:48:05.708539
115	\N	56B937BB	1	03000118	2026-08-31 05:31:55.368665	2026-09-15 06:48:05.562505	2026-09-15 06:48:05.70854
21	\N	16D83CBB	1	03000014	2026-08-31 05:13:04.485886	2026-08-31 06:12:27.951494	2026-08-31 06:12:27.978001
22	\N	165F3ABB	1	03000015	2026-08-31 05:13:12.414455	2026-08-31 06:12:27.961406	2026-08-31 06:12:27.978002
95	\N	36AE35BB	1	03000088	2026-08-31 05:28:16.398328	2026-08-31 09:06:09.523228	2026-08-31 09:06:09.562159
257	\N	767645BB	1	05000094	2026-09-02 06:14:56.151274	2026-09-05 05:24:12.524479	2026-09-05 05:24:12.527583
262	\N	C69D2BBB	1	05000099	2026-09-02 13:31:13.776957	2026-09-05 07:05:38.467502	2026-09-05 07:05:38.536031
265	\N	46F043BB	1	05000102	2026-09-02 13:31:29.886829	2026-09-05 07:05:38.374153	2026-09-05 07:05:38.536032
268	\N	D64726BB	1	05000105	2026-09-02 13:31:44.308185	2026-09-05 07:05:38.352316	2026-09-05 07:05:38.536033
271	\N	165B27BB	1	05000108	2026-09-02 13:31:59.172484	2026-09-05 07:05:38.385625	2026-09-05 07:05:38.536033
274	\N	066B58BB	1	05000111	2026-09-02 13:32:11.36352	2026-09-05 07:05:38.403069	2026-09-05 07:05:38.536034
277	\N	769D49BB	1	05000114	2026-09-02 13:32:28.826413	2026-09-05 07:05:38.381016	2026-09-05 07:05:38.536035
279	\N	F6F72CBB	1	05000116	2026-09-02 13:32:38.00556	2026-09-05 07:05:38.383269	2026-09-05 07:05:38.536035
280	\N	F67339BB	1	05000117	2026-09-02 13:32:41.932323	2026-09-05 07:05:38.361157	2026-09-05 07:05:38.536036
282	\N	26F151BB	1	05000119	2026-09-02 13:32:48.723031	2026-09-05 07:05:38.475216	2026-09-05 07:05:38.536037
283	\N	568A3BBB	1	05000120	2026-09-02 13:32:52.095744	2026-09-05 07:05:38.493139	2026-09-05 07:05:38.536037
286	\N	367C4CBB	1	05000123	2026-09-02 13:33:02.252878	2026-09-05 07:05:38.470138	2026-09-05 07:05:38.536037
288	\N	16CE4DBB	1	05000125	2026-09-02 13:33:08.798279	2026-09-05 07:05:38.390588	2026-09-05 07:05:38.536038
308	\N	C6DD37BB	1	05000145	2026-09-02 13:40:12.777672	2026-09-05 09:47:49.534117	2026-09-05 09:47:49.607373
309	\N	C6214ABB	1	05000146	2026-09-02 13:40:16.46443	2026-09-05 09:47:49.544455	2026-09-05 09:47:49.607376
310	\N	16FB28BB	1	05000147	2026-09-02 13:40:19.768284	2026-09-05 09:47:49.457561	2026-09-05 09:47:49.607377
311	\N	A66D31BB	1	05000148	2026-09-02 13:40:23.355437	2026-09-05 09:47:49.513721	2026-09-05 09:47:49.607377
312	\N	36305BBB	1	05000149	2026-09-02 13:40:28.446369	2026-09-05 09:47:49.559943	2026-09-05 09:47:49.607377
313	\N	46AC26BB	1	05000150	2026-09-02 13:40:33.454751	2026-09-05 09:47:49.491263	2026-09-05 09:47:49.607378
314	\N	16C41EBB	1	05000151	2026-09-02 13:40:37.274513	2026-09-05 09:47:49.504625	2026-09-05 09:47:49.607378
315	\N	561451BB	1	05000152	2026-09-02 13:40:42.309602	2026-09-05 09:47:49.562469	2026-09-05 09:47:49.607378
316	\N	26B121BB	1	05000153	2026-09-02 13:40:46.096846	2026-09-05 09:47:49.471638	2026-09-05 09:47:49.607379
317	\N	B65D55BB	1	05000154	2026-09-02 13:40:50.424007	2026-09-05 09:47:49.484743	2026-09-05 09:47:49.607379
318	\N	86AA58BB	1	05000155	2026-09-02 13:40:53.951702	2026-09-05 09:47:49.511468	2026-09-05 09:47:49.60738
126	\N	56682BBB	1	03000110	2026-08-31 05:34:32.161036	2026-08-31 10:49:02.505424	2026-08-31 10:49:02.524267
133	\N	E68C40BB	1	03000126	2026-08-31 05:36:01.858997	2026-09-01 05:31:06.692095	2026-09-01 05:31:06.746359
161	\N	163236BB	1	03000154	2026-08-31 05:41:31.313418	2026-09-01 05:31:06.624901	2026-09-01 05:31:06.74637
319	\N	665039BB	1	05000156	2026-09-02 13:40:58.835306	2026-09-05 09:47:49.486918	2026-09-05 09:47:49.60738
320	\N	A6E022BB	1	05000157	2026-09-02 13:41:03.563751	2026-09-05 09:47:49.521356	2026-09-05 09:47:49.60738
321	\N	F68156BB	1	05000158	2026-09-02 13:41:08.517708	2026-09-05 09:47:49.554746	2026-09-05 09:47:49.607381
322	\N	66D452BB	1	05000159	2026-09-02 13:41:13.25594	2026-09-05 09:47:49.541883	2026-09-05 09:47:49.607381
323	\N	B60035BB	1	05000160	2026-09-02 13:41:18.356227	2026-09-05 09:47:49.536639	2026-09-05 09:47:49.607381
259	\N	061D29BB	1	05000096	2026-09-02 13:31:02.085027	2026-09-05 10:18:26.10283	2026-09-05 10:18:26.133056
285	\N	765252BB	1	05000122	2026-09-02 13:32:58.855181	2026-09-05 10:18:26.122879	2026-09-05 10:18:26.133058
289	\N	76635EBB	1	05000126	2026-09-02 13:33:12.317387	2026-09-05 10:18:26.109605	2026-09-05 10:18:26.133059
291	\N	D6D040BB	1	05000135	2026-09-02 13:33:19.616547	2026-09-05 10:18:26.107322	2026-09-05 10:18:26.133059
298	\N	A61E27BB	1	05000128	2026-09-02 13:34:02.241532	2026-09-05 10:18:26.112374	2026-09-05 10:18:26.133059
238	\N	B6CE4DBB	1	05000075	2026-09-02 06:13:27.72847	2026-09-05 13:13:54.260463	2026-09-05 13:13:54.272226
247	\N	16C250BB	1	05000084	2026-09-02 06:14:05.153057	2026-09-05 13:13:54.252329	2026-09-05 13:13:54.272227
10	\N	86865CBB	1	03000003	2026-08-31 03:21:44.203374	2026-09-15 05:46:20.762315	2026-09-15 05:46:20.897298
11	\N	36634FBB	1	03000004	2026-08-31 03:21:51.13275	2026-09-15 05:46:20.812863	2026-09-15 05:46:20.897298
12	\N	460D47BB	1	03000005	2026-08-31 03:22:02.964733	2026-09-15 05:46:20.764471	2026-09-15 05:46:20.897299
13	\N	F6C756BB	1	03000006	2026-08-31 03:22:14.334749	2026-09-15 05:46:20.810614	2026-09-15 05:46:20.897299
14	\N	160145BB	1	03000007	2026-08-31 03:22:24.048052	2026-09-15 05:46:20.815188	2026-09-15 05:46:20.8973
15	\N	36F64CBB	1	03000008	2026-08-31 03:22:30.428411	2026-09-15 05:46:20.817454	2026-09-15 05:46:20.8973
16	\N	968C52BB	1	03000009	2026-08-31 03:22:39.898356	2026-09-15 05:46:20.819805	2026-09-15 05:46:20.8973
17	\N	96B937BB	1	03000010	2026-08-31 03:22:47.294295	2026-09-15 05:46:20.771152	2026-09-15 05:46:20.897301
18	\N	F6FF4CBB	1	03000011	2026-08-31 05:12:40.078993	2026-09-15 05:46:20.759393	2026-09-15 05:46:20.897301
20	\N	56EF5ABB	1	03000013	2026-08-31 05:12:57.709534	2026-09-15 05:46:20.766729	2026-09-15 05:46:20.897302
42	\N	36142BBB	1	03000035	2026-08-31 05:19:29.083396	2026-09-15 05:46:20.768882	2026-09-15 05:46:20.897302
43	\N	D6752BBB	1	03000036	2026-08-31 05:19:35.519253	2026-09-15 05:46:20.822102	2026-09-15 05:46:20.897302
44	\N	E6D828BB	1	03000037	2026-08-31 05:19:44.014153	2026-09-15 05:46:20.82458	2026-09-15 05:46:20.897303
47	\N	263E2DBB	1	03000061	2026-08-31 05:21:00.021787	2026-09-15 05:46:20.837146	2026-09-15 05:46:20.897303
49	\N	A6391ABB	1	03000063	2026-08-31 05:21:12.226192	2026-09-15 05:46:20.8268	2026-09-15 05:46:20.897303
50	\N	D6DF37BB	1	03000064	2026-08-31 05:21:19.136491	2026-09-15 05:46:20.828975	2026-09-15 05:46:20.897304
124	\N	C66140BB	1	03000108	2026-08-31 05:34:20.459325	2026-09-15 05:50:32.376901	2026-09-15 05:50:32.379982
121	\N	56143ABB	1	03000105	2026-08-31 05:34:03.070915	2026-09-15 06:47:55.166609	2026-09-15 06:47:55.333481
122	\N	96124BBB	1	03000106	2026-08-31 05:34:08.981788	2026-09-15 06:47:55.21312	2026-09-15 06:47:55.333481
123	\N	46B81BBB	1	03000107	2026-08-31 05:34:15.443755	2026-09-15 06:47:55.246689	2026-09-15 06:47:55.333482
129	\N	764B5EBB	1	03000122	2026-08-31 05:35:36.754874	2026-09-15 06:47:55.182156	2026-09-15 06:47:55.333482
130	\N	F6EA27BB	1	03000123	2026-08-31 05:35:41.912532	2026-09-15 06:47:55.225999	2026-09-15 06:47:55.333482
131	\N	769C3EBB	1	03000124	2026-08-31 05:35:50.243341	2026-09-15 06:47:55.289528	2026-09-15 06:47:55.333483
135	\N	E63058BB	1	03000128	2026-08-31 05:36:14.762772	2026-09-15 06:47:55.251832	2026-09-15 06:47:55.333483
136	\N	26F840BB	1	03000129	2026-08-31 05:36:19.836916	2026-09-15 06:47:55.179662	2026-09-15 06:47:55.333483
160	\N	C6774FBB	1	03000153	2026-08-31 05:41:25.545563	2026-09-15 06:47:55.23119	2026-09-15 06:47:55.333486
127	\N	868D3BBB	1	03000157	2026-08-31 05:35:26.207129	2026-09-15 06:48:05.560388	2026-09-15 06:48:05.708541
128	\N	26203ABB	1	03000121	2026-08-31 05:35:32.197712	2026-09-15 06:48:05.603773	2026-09-15 06:48:05.708541
132	\N	662449BB	1	03000125	2026-08-31 05:35:56.900581	2026-09-15 06:48:05.525589	2026-09-15 06:48:05.708541
134	\N	764E2DBB	1	03000127	2026-08-31 05:36:06.776022	2026-09-15 06:48:05.598731	2026-09-15 06:48:05.708542
148	\N	06ED30BB	1	03000150	2026-08-31 05:40:04.134173	2026-09-15 06:48:05.608886	2026-09-15 06:48:05.708544
158	\N	F6542BBB	1	03000151	2026-08-31 05:41:14.561795	2026-09-15 06:48:05.656166	2026-09-15 06:48:05.708549
159	\N	663438BB	1	03000152	2026-08-31 05:41:19.372447	2026-09-15 06:48:05.643166	2026-09-15 06:48:05.70855
162	\N	06D046BB	1	03000155	2026-08-31 05:41:35.879139	2026-09-15 06:48:05.637794	2026-09-15 06:48:05.70855
163	\N	565129BB	1	03000156	2026-08-31 05:41:41.902506	2026-09-15 06:48:05.645771	2026-09-15 06:48:05.708551
171	\N	D6CB4EBB	1	05000008	2026-09-02 05:54:48.523071	2026-09-05 02:49:34.025453	2026-09-05 02:49:34.065294
184	\N	D6B23EBB	1	05000021	2026-09-02 05:56:07.188381	2026-09-05 03:09:46.022898	2026-09-05 03:09:46.03195
187	\N	B6DA3FBB	1	05000024	2026-09-02 05:56:19.67758	2026-09-05 03:22:07.24125	2026-09-05 03:22:07.290415
196	\N	16D41CBB	1	05000033	2026-09-02 05:57:03.092363	2026-09-05 03:22:07.269045	2026-09-05 03:22:07.290416
197	\N	26A523BB	1	05000034	2026-09-02 05:57:08.246931	2026-09-05 03:22:07.252816	2026-09-05 03:22:07.290416
190	\N	B6B442BB	1	05000027	2026-09-02 05:56:34.201531	2026-09-05 03:26:45.731661	2026-09-05 03:26:45.739006
193	\N	763C3ABB	1	05000030	2026-09-02 05:56:49.183056	2026-09-05 03:26:45.735845	2026-09-05 03:26:45.739008
208	\N	860A2BBB	1	05000045	2026-09-02 06:10:21.701354	2026-09-05 05:23:20.880909	2026-09-05 05:23:20.957545
211	\N	26632BBB	1	05000048	2026-09-02 06:10:40.735703	2026-09-05 05:23:20.904506	2026-09-05 05:23:20.957548
214	\N	46875CBB	1	05000051	2026-09-02 06:10:53.733191	2026-09-05 05:23:20.885569	2026-09-05 05:23:20.957549
217	\N	F6BC53BB	1	05000054	2026-09-02 06:11:10.131251	2026-09-05 05:23:20.870853	2026-09-05 05:23:20.95755
260	\N	F68E37BB	1	05000097	2026-09-02 13:31:06.07208	2026-09-05 07:05:38.472726	2026-09-05 07:05:38.536028
263	\N	B67A25BB	1	05000100	2026-09-02 13:31:19.162285	2026-09-05 07:05:38.495731	2026-09-05 07:05:38.536031
266	\N	C6DB37BB	1	05000103	2026-09-02 13:31:34.742514	2026-09-05 07:05:38.490533	2026-09-05 07:05:38.536032
275	\N	766C25BB	1	05000112	2026-09-02 13:32:15.185699	2026-09-05 07:05:38.369893	2026-09-05 07:05:38.536034
278	\N	D65B3EBB	1	05000115	2026-09-02 13:32:34.285858	2026-09-05 07:05:38.461547	2026-09-05 07:05:38.536035
281	\N	F64943BB	1	05000118	2026-09-02 13:32:45.288639	2026-09-05 07:05:38.498308	2026-09-05 07:05:38.536036
290	\N	C66940BB	1	05000127	2026-09-02 13:33:15.747628	2026-09-05 07:05:38.356605	2026-09-05 07:05:38.536038
293	\N	F65152BB	1	05000130	2026-09-02 13:33:26.497417	2026-09-05 07:05:38.376314	2026-09-05 07:05:38.536039
300	\N	16612BBB	1	05000137	2026-09-02 13:34:09.20285	2026-09-05 07:05:38.477782	2026-09-05 07:05:38.536041
301	\N	36254CBB	1	05000138	2026-09-02 13:34:12.460305	2026-09-05 07:05:38.464941	2026-09-05 07:05:38.536041
302	\N	D60132BB	1	05000139	2026-09-02 13:34:16.970274	2026-09-05 07:05:38.487945	2026-09-05 07:05:38.536042
269	\N	26155EBB	1	05000106	2026-09-02 13:31:47.913786	2026-09-05 10:18:26.097793	2026-09-05 10:18:26.133056
272	\N	26895BBB	1	05000109	2026-09-02 13:32:02.753855	2026-09-05 10:18:26.120555	2026-09-05 10:18:26.133057
284	\N	96A04BBB	1	05000121	2026-09-02 13:32:55.564701	2026-09-05 10:18:26.09427	2026-09-05 10:18:26.133058
287	\N	66073EBB	1	05000124	2026-09-02 13:33:05.535936	2026-09-05 10:18:26.118182	2026-09-05 10:18:26.133058
239	\N	C6A33EBB	1	05000076	2026-09-02 06:13:32.473496	2026-09-05 13:13:54.265407	2026-09-05 13:13:54.272226
248	\N	F67A43BB	1	05000085	2026-09-02 06:14:10.329013	2026-09-05 13:13:54.258	2026-09-05 13:13:54.272227
51	\N	F67423BB	1	03000065	2026-08-31 05:21:24.633794	2026-09-15 05:46:20.832005	2026-09-15 05:46:20.897304
52	\N	D6E539BB	1	03000066	2026-08-31 05:21:30.017541	2026-09-15 05:46:20.847564	2026-09-15 05:46:20.897304
54	\N	468B40BB	1	03000068	2026-08-31 05:21:42.141567	2026-08-31 07:10:59.324521	2026-08-31 07:10:59.379092
77	\N	662E3EBB	1	03000070	2026-08-31 05:26:17.391029	2026-08-31 07:10:59.283169	2026-08-31 07:10:59.3791
53	\N	665439BB	1	03000067	2026-08-31 05:21:34.550931	2026-09-15 05:46:20.850135	2026-09-15 05:46:20.897305
55	\N	F6FA4CBB	1	03000069	2026-08-31 05:21:46.615732	2026-09-15 05:46:20.839807	2026-09-15 05:46:20.897305
74	\N	86CB24BB	1	03000048	2026-08-31 05:24:59.503435	2026-09-15 05:46:20.842406	2026-09-15 05:46:20.897305
56	\N	56A931BB	1	03000051	2026-08-31 05:22:32.071505	2026-09-15 06:47:55.195238	2026-09-15 06:47:55.33347
57	\N	76271BBB	1	03000052	2026-08-31 05:22:38.680812	2026-09-15 06:47:55.197722	2026-09-15 06:47:55.333471
58	\N	E6DD4ABB	1	03000053	2026-08-31 05:22:44.874116	2026-09-15 06:47:55.200207	2026-09-15 06:47:55.333471
59	\N	B69056BB	1	03000054	2026-08-31 05:22:50.023467	2026-09-15 06:47:55.265139	2026-09-15 06:47:55.333472
60	\N	863238BB	1	03000055	2026-08-31 05:22:55.1512	2026-09-15 06:47:55.272883	2026-09-15 06:47:55.333472
61	\N	A62047BB	1	03000056	2026-08-31 05:23:00.171666	2026-09-15 06:47:55.275684	2026-09-15 06:47:55.333472
62	\N	36FC1BBB	1	03000057	2026-08-31 05:23:05.398883	2026-09-15 06:47:55.267692	2026-09-15 06:47:55.333473
23	\N	86C133BB	1	03000016	2026-08-31 05:13:20.150603	2026-09-15 06:48:05.576507	2026-09-15 06:48:05.708527
24	\N	966E56BB	1	03000017	2026-08-31 05:13:27.225821	2026-09-15 06:48:05.619604	2026-09-15 06:48:05.708529
25	\N	660953BB	1	03000018	2026-08-31 05:13:34.602077	2026-09-15 06:48:05.546327	2026-09-15 06:48:05.708529
26	\N	36E644BB	1	03000019	2026-08-31 05:13:40.181258	2026-09-15 06:48:05.532442	2026-09-15 06:48:05.70853
27	\N	363D51BB	1	03000020	2026-08-31 05:13:47.163581	2026-09-15 06:48:05.614485	2026-09-15 06:48:05.70853
28	\N	B69F28BB	1	03000021	2026-08-31 05:16:05.514642	2026-09-15 06:48:05.617035	2026-09-15 06:48:05.70853
40	\N	463633BB	1	03000033	2026-08-31 05:19:15.644015	2026-09-15 06:48:05.63009	2026-09-15 06:48:05.708535
105	\N	067733BB	1	03000098	2026-08-31 05:29:38.936985	2026-09-15 06:48:05.583752	2026-09-15 06:48:05.708537
107	\N	46B81EBB	1	03000100	2026-08-31 05:29:50.194194	2026-09-15 06:48:05.550932	2026-09-15 06:48:05.708538
117	\N	265145BB	1	03000101	2026-08-31 05:33:37.806872	2026-09-15 06:48:05.581302	2026-09-15 06:48:05.70854
118	\N	36DC52BB	1	03000102	2026-08-31 05:33:43.223477	2026-09-15 06:48:05.555747	2026-09-15 06:48:05.70854
138	\N	D6114FBB	1	03000131	2026-08-31 05:38:16.857985	2026-09-15 06:48:05.606304	2026-09-15 06:48:05.708542
139	\N	962D2FBB	1	03000132	2026-08-31 05:38:21.810094	2026-09-15 06:48:05.528004	2026-09-15 06:48:05.708543
143	\N	B65E3CBB	1	03000136	2026-08-31 05:38:43.575143	2026-09-15 06:48:05.530286	2026-09-15 06:48:05.708543
144	\N	F6AF5DBB	1	03000137	2026-08-31 05:38:47.435741	2026-09-15 06:48:05.601223	2026-09-15 06:48:05.708543
149	\N	B65B2BBB	1	03000141	2026-08-31 05:40:18.399854	2026-09-15 06:48:05.569248	2026-09-15 06:48:05.708544
150	\N	86CC54BB	1	03000142	2026-08-31 05:40:23.895943	2026-09-15 06:48:05.571791	2026-09-15 06:48:05.708544
151	\N	C65B4DBB	1	03000143	2026-08-31 05:40:29.070476	2026-09-15 06:48:05.574255	2026-09-15 06:48:05.708545
152	\N	967F4BBB	1	03000144	2026-08-31 05:40:34.031075	2026-09-15 06:48:05.64058	2026-09-15 06:48:05.708545
153	\N	F69327BB	1	03000145	2026-08-31 05:40:40.128077	2026-09-15 06:48:05.611843	2026-09-15 06:48:05.708546
154	\N	A6944DBB	1	03000146	2026-08-31 05:40:45.060092	2026-09-15 06:48:05.653528	2026-09-15 06:48:05.708547
155	\N	F61B55BB	1	03000147	2026-08-31 05:40:50.267008	2026-09-15 06:48:05.658998	2026-09-15 06:48:05.708547
156	\N	368946BB	1	03000148	2026-08-31 05:40:55.446282	2026-09-15 06:48:05.648394	2026-09-15 06:48:05.708548
157	\N	560853BB	1	03000149	2026-08-31 05:41:01.668986	2026-09-15 06:48:05.650979	2026-09-15 06:48:05.708549
169	\N	C65A5EBB	1	05000006	2026-09-02 05:54:39.408838	2026-09-05 02:49:34.033761	2026-09-05 02:49:34.065289
179	\N	36E856BB	1	05000016	2026-09-02 05:55:37.500193	2026-09-05 03:09:46.014469	2026-09-05 03:09:46.031947
182	\N	865B58BB	1	05000019	2026-09-02 05:55:57.958248	2026-09-05 03:09:46.017715	2026-09-05 03:09:46.031949
191	\N	86764DBB	1	05000028	2026-09-02 05:56:39.0515	2026-09-05 03:14:44.71031	2026-09-05 03:14:44.717823
194	\N	D62C3ABB	1	05000031	2026-09-02 05:56:55.062142	2026-09-05 03:14:44.712746	2026-09-05 03:14:44.717824
188	\N	566137BB	1	05000025	2026-09-02 05:56:24.307149	2026-09-05 03:22:07.237591	2026-09-05 03:22:07.290415
198	\N	76253CBB	1	05000035	2026-09-02 05:57:12.249282	2026-09-05 03:22:07.27339	2026-09-05 03:22:07.290417
209	\N	66DC2ABB	1	05000046	2026-09-02 06:10:31.624398	2026-09-05 05:23:20.826212	2026-09-05 05:23:20.957547
212	\N	16AC23BB	1	05000049	2026-09-02 06:10:44.326561	2026-09-05 05:23:20.909099	2026-09-05 05:23:20.957548
215	\N	C67C48BB	1	05000052	2026-09-02 06:10:59.896738	2026-09-05 05:23:20.878432	2026-09-05 05:23:20.95755
218	\N	76234FBB	1	05000055	2026-09-02 06:11:13.874938	2026-09-05 05:23:20.859151	2026-09-05 05:23:20.957551
75	\N	86DD19BB	1	03000049	2026-08-31 05:25:03.909986	2026-09-15 05:46:20.844984	2026-09-15 05:46:20.897306
76	\N	861D45BB	1	03000050	2026-08-31 05:25:09.961876	2026-09-15 05:46:20.834597	2026-09-15 05:46:20.897306
78	\N	A65547BB	1	03000071	2026-08-31 05:26:23.954088	2026-09-15 05:46:20.787124	2026-09-15 05:46:20.897306
79	\N	96543ABB	1	03000072	2026-08-31 05:26:28.65888	2026-09-15 05:46:20.795849	2026-09-15 05:46:20.897307
80	\N	76A92CBB	1	03000073	2026-08-31 05:26:34.283464	2026-09-15 05:46:20.80288	2026-09-15 05:46:20.897307
81	\N	36B459BB	1	03000074	2026-08-31 05:26:39.051663	2026-09-15 05:46:20.805091	2026-09-15 05:46:20.897307
82	\N	F6CE2ABB	1	03000075	2026-08-31 05:26:44.370287	2026-09-15 05:46:20.782569	2026-09-15 05:46:20.897308
83	\N	96302BBB	1	03000076	2026-08-31 05:26:49.097784	2026-09-15 05:46:20.789315	2026-09-15 05:46:20.897308
84	\N	963049BB	1	03000077	2026-08-31 05:26:55.833693	2026-09-15 05:46:20.791553	2026-09-15 05:46:20.897308
85	\N	66C733BB	1	03000078	2026-08-31 05:27:01.47727	2026-09-15 05:46:20.776104	2026-09-15 05:46:20.897309
86	\N	96ED42BB	1	03000079	2026-08-31 05:27:06.563761	2026-09-15 05:46:20.793662	2026-09-15 05:46:20.897309
88	\N	969931BB	1	03000081	2026-08-31 05:27:39.473573	2026-09-15 05:46:20.778308	2026-09-15 05:46:20.897309
89	\N	36AE39BB	1	03000082	2026-08-31 05:27:45.595067	2026-09-15 05:46:20.780432	2026-09-15 05:46:20.89731
90	\N	A65221BB	1	03000083	2026-08-31 05:27:50.87272	2026-09-15 05:46:20.852685	2026-09-15 05:46:20.89731
91	\N	161838BB	1	03000084	2026-08-31 05:27:55.278917	2026-09-15 05:46:20.773785	2026-09-15 05:46:20.89731
101	\N	469619BB	1	03000094	2026-08-31 05:29:17.555849	2026-09-15 05:46:20.800307	2026-09-15 05:46:20.897311
120	\N	D61153BB	1	03000104	2026-08-31 05:33:55.456571	2026-09-15 05:46:20.797924	2026-09-15 05:46:20.897311
125	\N	E6FD2ABB	1	03000109	2026-08-31 05:34:26.155836	2026-09-15 05:46:20.855373	2026-09-15 05:46:20.897311
147	\N	76A644BB	1	03000140	2026-08-31 05:39:56.333987	2026-09-15 05:46:20.784931	2026-09-15 05:46:20.897312
303	\N	D66558BB	1	05000140	2026-09-02 13:34:20.411461	2026-09-05 07:05:38.371985	2026-09-05 07:05:38.536042
304	\N	361222BB	1	05000141	2026-09-02 13:34:24.433606	2026-09-05 07:05:38.398129	2026-09-05 07:05:38.536043
305	\N	E62125BB	1	05000142	2026-09-02 13:34:27.927093	2026-09-05 07:05:38.388111	2026-09-05 07:05:38.536043
306	\N	961249BB	1	05000143	2026-09-02 13:34:31.463951	2026-09-05 07:05:38.367698	2026-09-05 07:05:38.536044
307	\N	E6E835BB	1	05000144	2026-09-02 13:34:35.13923	2026-09-05 07:05:38.480313	2026-09-05 07:05:38.536044
324	\N	A69629BB	1	05000161	2026-09-02 13:41:23.237999	2026-09-05 09:47:49.465314	2026-09-05 09:47:49.607382
327	\N	96882FBB	1	05000164	2026-09-02 13:41:34.554159	2026-09-05 09:47:49.467383	2026-09-05 09:47:49.607383
330	\N	965159BB	1	05000167	2026-09-02 13:41:47.535441	2026-09-05 09:47:49.482588	2026-09-05 09:47:49.607384
333	\N	D64B5BBB	1	05000170	2026-09-02 13:42:23.509063	2026-09-05 09:47:49.497716	2026-09-05 09:47:49.607385
336	\N	B6B933BB	1	05000173	2026-09-02 13:42:35.656208	2026-09-05 09:47:49.546963	2026-09-05 09:47:49.607386
339	\N	36A753BB	1	05000176	2026-09-02 13:42:46.284818	2026-09-05 09:47:49.509222	2026-09-05 09:47:49.607387
342	\N	F69740BB	1	05000179	2026-09-02 13:42:56.879927	2026-09-05 09:47:49.516265	2026-09-05 09:47:49.607388
345	\N	D61F3CBB	1	05000182	2026-09-02 13:43:11.686643	2026-09-05 09:47:49.495507	2026-09-05 09:47:49.607389
348	\N	76A35CBB	1	05000185	2026-09-02 13:43:23.29136	2026-09-05 09:47:49.463243	2026-09-05 09:47:49.60739
351	\N	E6BA2CBB	1	05000188	2026-09-02 13:43:36.923704	2026-09-05 09:47:49.480323	2026-09-05 09:47:49.607391
357	\N	365635BB	1	05000194	2026-09-02 13:44:06.453448	2026-09-05 09:47:49.502411	2026-09-05 09:47:49.607392
354	\N	B62F20BB	1	05000191	2026-09-02 13:43:48.44449	2026-09-05 09:49:46.157056	2026-09-05 09:49:46.160547
358	\N	C6B61EBB	1	05000200	2026-09-02 13:46:12.722819	2026-09-05 10:12:13.097429	2026-09-05 10:12:13.189939
361	\N	E6FD37BB	1	05000198	2026-09-02 13:46:24.55512	2026-09-05 10:12:13.037467	2026-09-05 10:12:13.189942
364	\N	36FA52BB	1	05000202	2026-09-02 13:46:34.553167	2026-09-05 10:12:13.080073	2026-09-05 10:12:13.189943
367	\N	865657BB	1	05000205	2026-09-02 13:46:44.957749	2026-09-05 10:12:13.08883	2026-09-05 10:12:13.189944
370	\N	16B45CBB	1	05000208	2026-09-02 13:46:55.566644	2026-09-05 10:12:13.075628	2026-09-05 10:12:13.189945
373	\N	A6A333BB	1	05000211	2026-09-02 13:47:07.097141	2026-09-05 10:12:13.070826	2026-09-05 10:12:13.189947
376	\N	66D03EBB	1	05000214	2026-09-02 13:47:18.442612	2026-09-05 10:12:13.052506	2026-09-05 10:12:13.189948
379	\N	464935BB	1	05000217	2026-09-02 13:47:31.59638	2026-09-05 10:12:13.073378	2026-09-05 10:12:13.189948
382	\N	B6CE48BB	1	05000220	2026-09-02 13:47:41.844525	2026-09-05 10:12:13.130276	2026-09-05 10:12:13.189949
385	\N	B61D3ABB	1	05000223	2026-09-02 13:47:54.380973	2026-09-05 10:12:13.108659	2026-09-05 10:12:13.18995
63	\N	562C4BBB	1	03000058	2026-08-31 05:23:10.32896	2026-09-15 06:47:55.280859	2026-09-15 06:47:55.333473
64	\N	E64151BB	1	03000059	2026-08-31 05:23:16.528943	2026-09-15 06:47:55.283456	2026-09-15 06:47:55.333473
65	\N	B62543BB	1	03000060	2026-08-31 05:23:23.862367	2026-09-15 06:47:55.286018	2026-09-15 06:47:55.333474
66	\N	46444FBB	1	03000040	2026-08-31 05:23:53.206651	2026-09-15 06:47:55.262609	2026-09-15 06:47:55.333474
67	\N	56BF3ABB	1	03000041	2026-08-31 05:24:04.387662	2026-09-15 06:47:55.260049	2026-09-15 06:47:55.333474
68	\N	F69F59BB	1	03000042	2026-08-31 05:24:09.709682	2026-09-15 06:47:55.270255	2026-09-15 06:47:55.333475
69	\N	26BE4DBB	1	03000043	2026-08-31 05:24:16.167297	2026-09-15 06:47:55.187248	2026-09-15 06:47:55.333475
70	\N	763931BB	1	03000044	2026-08-31 05:24:21.102525	2026-09-15 06:47:55.189697	2026-09-15 06:47:55.333475
71	\N	B6C01ABB	1	03000045	2026-08-31 05:24:42.426271	2026-09-15 06:47:55.192427	2026-09-15 06:47:55.333476
72	\N	561D3DBB	1	03000046	2026-08-31 05:24:49.72415	2026-09-15 06:47:55.257476	2026-09-15 06:47:55.333476
73	\N	66A91EBB	1	03000047	2026-08-31 05:24:54.430824	2026-09-15 06:47:55.278317	2026-09-15 06:47:55.333476
102	\N	C67C44BB	1	03000095	2026-08-31 05:29:22.07348	2026-09-15 06:47:55.236321	2026-09-15 06:47:55.333478
103	\N	66804DBB	1	03000096	2026-08-31 05:29:28.160918	2026-09-15 06:47:55.241612	2026-09-15 06:47:55.333478
104	\N	16C940BB	1	03000097	2026-08-31 05:29:33.606467	2026-09-15 06:47:55.205329	2026-09-15 06:47:55.333479
119	\N	C6BC23BB	1	03000112	2026-08-31 05:33:47.908833	2026-09-15 06:47:55.244145	2026-09-15 06:47:55.333481
137	\N	460A5BBB	1	03000130	2026-08-31 05:38:10.175651	2026-09-15 06:47:55.223244	2026-09-15 06:47:55.333484
140	\N	C65B29BB	1	03000133	2026-08-31 05:38:27.241889	2026-09-15 06:47:55.228554	2026-09-15 06:47:55.333484
141	\N	96033EBB	1	03000134	2026-08-31 05:38:33.562161	2026-09-15 06:47:55.218198	2026-09-15 06:47:55.333484
142	\N	261851BB	1	03000135	2026-08-31 05:38:37.867372	2026-09-15 06:47:55.220684	2026-09-15 06:47:55.333485
145	\N	96D342BB	1	03000138	2026-08-31 05:38:51.566939	2026-09-15 06:47:55.177123	2026-09-15 06:47:55.333485
325	\N	A6043DBB	1	05000162	2026-09-02 13:41:27.156022	2026-09-05 09:47:49.523836	2026-09-05 09:47:49.607382
326	\N	36FD44BB	1	05000163	2026-09-02 13:41:30.886734	2026-09-05 09:47:49.528922	2026-09-05 09:47:49.607382
328	\N	965D1DBB	1	05000165	2026-09-02 13:41:40.107826	2026-09-05 09:47:49.489118	2026-09-05 09:47:49.607383
329	\N	168B30BB	1	05000166	2026-09-02 13:41:43.97271	2026-09-05 09:47:49.557379	2026-09-05 09:47:49.607383
331	\N	26082FBB	1	05000168	2026-09-02 13:41:51.305998	2026-09-05 09:47:49.473871	2026-09-05 09:47:49.607384
332	\N	A60524BB	1	05000169	2026-09-02 13:42:20.036592	2026-09-05 09:47:49.478171	2026-09-05 09:47:49.607384
334	\N	A65C59BB	1	05000171	2026-09-02 13:42:27.272376	2026-09-05 09:47:49.453501	2026-09-05 09:47:49.607385
335	\N	E6F73BBB	1	05000172	2026-09-02 13:42:30.81891	2026-09-05 09:47:49.54951	2026-09-05 09:47:49.607385
337	\N	A6E344BB	1	05000174	2026-09-02 13:42:39.291134	2026-09-05 09:47:49.449922	2026-09-05 09:47:49.607386
338	\N	A6D942BB	1	05000175	2026-09-02 13:42:42.801503	2026-09-05 09:47:49.476071	2026-09-05 09:47:49.607386
340	\N	26433CBB	1	05000177	2026-09-02 13:42:49.701774	2026-09-05 09:47:49.531464	2026-09-05 09:47:49.607387
341	\N	E60A27BB	1	05000178	2026-09-02 13:42:53.227314	2026-09-05 09:47:49.493386	2026-09-05 09:47:49.607387
343	\N	66284FBB	1	05000180	2026-09-02 13:43:04.389683	2026-09-05 09:47:49.500177	2026-09-05 09:47:49.607388
344	\N	266958BB	1	05000181	2026-09-02 13:43:08.119635	2026-09-05 09:47:49.552191	2026-09-05 09:47:49.607388
346	\N	263425BB	1	05000183	2026-09-02 13:43:14.996027	2026-09-05 09:47:49.439479	2026-09-05 09:47:49.607389
347	\N	C6BF43BB	1	05000184	2026-09-02 13:43:18.339692	2026-09-05 09:47:49.446434	2026-09-05 09:47:49.607389
349	\N	068347BB	1	05000186	2026-09-02 13:43:26.873991	2026-09-05 09:47:49.506782	2026-09-05 09:47:49.60739
350	\N	765F49BB	1	05000187	2026-09-02 13:43:33.351375	2026-09-05 09:47:49.460841	2026-09-05 09:47:49.60739
352	\N	76114EBB	1	05000189	2026-09-02 13:43:40.297164	2026-09-05 09:47:49.469437	2026-09-05 09:47:49.607391
353	\N	768C42BB	1	05000190	2026-09-02 13:43:44.923949	2026-09-05 09:47:49.539234	2026-09-05 09:47:49.607391
355	\N	16D03ABB	1	05000192	2026-09-02 13:43:51.887419	2026-09-05 09:47:49.526367	2026-09-05 09:47:49.607392
356	\N	467A1ABB	1	05000193	2026-09-02 13:44:00.600247	2026-09-05 09:47:49.518818	2026-09-05 09:47:49.607392
359	\N	069D1FBB	1	05000196	2026-09-02 13:46:17.937667	2026-09-05 10:12:13.068274	2026-09-05 10:12:13.189941
362	\N	66A619BB	1	05000199	2026-09-02 13:46:28.005848	2026-09-05 10:12:13.125752	2026-09-05 10:12:13.189943
365	\N	561224BB	1	05000203	2026-09-02 13:46:37.701241	2026-09-05 10:12:13.050053	2026-09-05 10:12:13.189944
368	\N	761B2BBB	1	05000206	2026-09-02 13:46:48.436869	2026-09-05 10:12:13.095327	2026-09-05 10:12:13.189945
371	\N	26595CBB	1	05000209	2026-09-02 13:46:58.955862	2026-09-05 10:12:13.07793	2026-09-05 10:12:13.189946
374	\N	F60F1BBB	1	05000212	2026-09-02 13:47:11.637861	2026-09-05 10:12:13.110948	2026-09-05 10:12:13.189947
377	\N	C6344BBB	1	05000215	2026-09-02 13:47:22.794025	2026-09-05 10:12:13.059219	2026-09-05 10:12:13.189948
380	\N	760647BB	1	05000218	2026-09-02 13:47:34.997479	2026-09-05 10:12:13.106286	2026-09-05 10:12:13.189949
383	\N	36CD3BBB	1	05000221	2026-09-02 13:47:45.491795	2026-09-05 10:12:13.061721	2026-09-05 10:12:13.18995
384	\N	A64129BB	1	05000222	2026-09-02 13:47:50.795783	2026-09-05 10:12:13.090974	2026-09-05 10:12:13.18995
386	\N	E6A247BB	1	05000224	2026-09-02 13:48:00.274766	2026-09-05 10:12:13.05692	2026-09-05 10:12:13.189951
387	\N	C65155BB	1	05000244	2026-09-02 13:49:15.38802	2026-09-05 10:12:13.123315	2026-09-05 10:12:13.189951
388	\N	26F551BB	1	05000243	2026-09-02 13:49:19.238071	2026-09-05 10:12:13.044886	2026-09-05 10:12:13.189951
389	\N	A6F725BB	1	05000242	2026-09-02 13:49:22.369684	2026-09-05 10:12:13.047427	2026-09-05 10:12:13.189952
391	\N	06F337BB	1	05000195	2026-09-02 13:49:29.044851	2026-09-05 10:12:13.054672	2026-09-05 10:12:13.189952
392	\N	16205CBB	1	05000225	2026-09-02 13:49:34.314025	2026-09-05 10:12:13.099618	2026-09-05 10:12:13.189952
393	\N	86885ABB	1	05000226	2026-09-02 13:49:38.863069	2026-09-05 10:12:13.031933	2026-09-05 10:12:13.189953
394	\N	46C13DBB	1	05000227	2026-09-02 13:49:42.465478	2026-09-05 10:12:13.127985	2026-09-05 10:12:13.189953
395	\N	46232EBB	1	05000228	2026-09-02 13:49:46.125785	2026-09-05 10:12:13.115503	2026-09-05 10:12:13.189953
396	\N	46635DBB	1	05000229	2026-09-02 13:49:50.719849	2026-09-05 10:12:13.137274	2026-09-05 10:12:13.189954
397	\N	56FF2CBB	1	05000230	2026-09-02 13:49:55.383152	2026-09-05 10:12:13.104036	2026-09-05 10:12:13.189954
398	\N	06CF1ABB	1	05000231	2026-09-02 13:49:59.341607	2026-09-05 10:12:13.144946	2026-09-05 10:12:13.189954
399	\N	D60922BB	1	05000232	2026-09-02 13:50:02.803806	2026-09-05 10:12:13.118022	2026-09-05 10:12:13.189955
400	\N	56493DBB	1	05000233	2026-09-02 13:50:08.430885	2026-09-05 10:12:13.113268	2026-09-05 10:12:13.189955
401	\N	A6E631BB	1	05000234	2026-09-02 13:50:28.728611	2026-09-05 10:12:13.034956	2026-09-05 10:12:13.189955
402	\N	16DB21BB	1	05000235	2026-09-02 13:50:32.248003	2026-09-05 10:12:13.120552	2026-09-05 10:12:13.189956
403	\N	A61349BB	1	05000236	2026-09-02 13:50:35.518177	2026-09-05 10:12:13.142388	2026-09-05 10:12:13.189956
404	\N	66C833BB	1	05000237	2026-09-02 13:50:38.768738	2026-09-05 10:12:13.039937	2026-09-05 10:12:13.189956
405	\N	266E2BBB	1	05000238	2026-09-02 13:50:42.261716	2026-09-05 10:12:13.063869	2026-09-05 10:12:13.189957
406	\N	A6003BBB	1	05000239	2026-09-02 13:50:45.706431	2026-09-05 10:12:13.134765	2026-09-05 10:12:13.189957
407	\N	06475BBB	1	05000240	2026-09-02 13:50:50.44511	2026-09-05 10:12:13.101783	2026-09-05 10:12:13.189957
146	\N	06B35DBB	1	03000139	2026-08-31 05:38:57.079953	2026-09-15 06:47:55.215658	2026-09-15 06:47:55.333485
106	\N	566E2BBB	1	03000099	2026-08-31 05:29:44.548008	2026-09-15 06:48:05.558153	2026-09-15 06:48:05.708538
19	\N	16782DBB	1	03000012	2026-08-31 05:12:50.14147	2026-09-15 05:46:20.751432	2026-09-15 05:46:20.897301
408	\N	B67F51BB	0	\N	2026-09-03 00:23:26.539856	\N	2026-09-03 00:23:26.547497
409	\N	965633BB	0	\N	2026-09-03 00:23:50.265458	\N	2026-09-03 00:23:50.266043
410	\N	C61031BB	0	\N	2026-09-03 00:23:56.91017	\N	2026-09-03 00:23:56.910668
411	\N	26514BBB	0	\N	2026-09-03 00:24:02.615468	\N	2026-09-03 00:24:02.616127
412	\N	062853BB	0	\N	2026-09-03 00:24:07.485148	\N	2026-09-03 00:24:07.485585
413	\N	46D335BB	0	\N	2026-09-03 00:24:13.212075	\N	2026-09-03 00:24:13.212361
414	\N	B62431BB	0	\N	2026-09-03 00:24:25.904234	\N	2026-09-03 00:24:25.905145
415	\N	06BB44BB	0	\N	2026-09-03 00:24:34.561646	\N	2026-09-03 00:24:34.562634
416	\N	E6FD21BB	0	\N	2026-09-03 00:24:38.164431	\N	2026-09-03 00:24:38.165001
417	\N	A6EE33BB	0	\N	2026-09-03 00:24:42.50969	\N	2026-09-03 00:24:42.510173
418	\N	D6C94ABB	0	\N	2026-09-03 00:24:47.433881	\N	2026-09-03 00:24:47.434633
419	\N	36935CBB	0	\N	2026-09-03 00:24:51.550438	\N	2026-09-03 00:24:51.551251
420	\N	166D52BB	0	\N	2026-09-03 00:24:56.64866	\N	2026-09-03 00:24:56.649135
421	\N	162D53BB	0	\N	2026-09-03 00:25:01.087677	\N	2026-09-03 00:25:01.088224
422	\N	16E442BB	0	\N	2026-09-03 00:25:04.748879	\N	2026-09-03 00:25:04.749195
423	\N	A69333BB	0	\N	2026-09-03 00:25:08.747806	\N	2026-09-03 00:25:08.748637
424	\N	56AD26BB	0	\N	2026-09-03 00:25:13.379999	\N	2026-09-03 00:25:13.380519
425	\N	A60D1BBB	0	\N	2026-09-03 00:25:16.945922	\N	2026-09-03 00:25:16.946754
426	\N	D60F43BB	0	\N	2026-09-03 00:25:22.586978	\N	2026-09-03 00:25:22.587323
427	\N	E6AB1ABB	0	\N	2026-09-03 00:25:27.170168	\N	2026-09-03 00:25:27.170774
428	\N	B66551BB	0	\N	2026-09-03 00:25:35.581254	\N	2026-09-03 00:25:35.581455
429	\N	B6D639BB	0	\N	2026-09-03 00:25:40.562048	\N	2026-09-03 00:25:40.562835
430	\N	E66442BB	0	\N	2026-09-03 00:25:44.833373	\N	2026-09-03 00:25:44.833861
431	\N	56002FBB	0	\N	2026-09-03 00:25:50.643664	\N	2026-09-03 00:25:50.644275
432	\N	F6A62FBB	0	\N	2026-09-03 00:25:54.265282	\N	2026-09-03 00:25:54.26597
433	\N	763836BB	0	\N	2026-09-03 00:26:02.620738	\N	2026-09-03 00:26:02.621191
434	\N	D68C22BB	0	\N	2026-09-03 00:26:08.545127	\N	2026-09-03 00:26:08.545714
435	\N	062732BB	0	\N	2026-09-03 00:26:12.999927	\N	2026-09-03 00:26:13.000697
436	\N	86DE52BB	0	\N	2026-09-03 00:26:19.910604	\N	2026-09-03 00:26:19.911096
437	\N	56FB36BB	0	\N	2026-09-03 00:30:57.79767	\N	2026-09-03 00:30:57.800013
438	\N	D69949BB	0	\N	2026-09-03 00:31:02.501148	\N	2026-09-03 00:31:02.501594
439	\N	F62D25BB	0	\N	2026-09-03 00:31:05.677569	\N	2026-09-03 00:31:05.678177
440	\N	76382DBB	0	\N	2026-09-03 00:31:09.819021	\N	2026-09-03 00:31:09.819852
441	\N	06C039BB	0	\N	2026-09-03 00:31:12.836499	\N	2026-09-03 00:31:12.836917
442	\N	66CC21BB	0	\N	2026-09-03 00:31:16.209252	\N	2026-09-03 00:31:16.209852
443	\N	56D234BB	0	\N	2026-09-03 00:31:26.176647	\N	2026-09-03 00:31:26.177917
444	\N	A67A47BB	0	\N	2026-09-03 00:31:30.694216	\N	2026-09-03 00:31:30.694453
445	\N	F6FC2ABB	0	\N	2026-09-03 00:31:35.723134	\N	2026-09-03 00:31:35.723625
446	\N	466235BB	0	\N	2026-09-03 00:31:40.990459	\N	2026-09-03 00:31:40.990789
447	\N	867B4FBB	0	\N	2026-09-03 00:31:44.873597	\N	2026-09-03 00:31:44.874134
448	\N	C67B4DBB	0	\N	2026-09-03 00:31:48.959624	\N	2026-09-03 00:31:48.959879
449	\N	E6A34BBB	0	\N	2026-09-03 00:31:53.090785	\N	2026-09-03 00:31:53.091337
450	\N	863939BB	0	\N	2026-09-03 00:31:56.685079	\N	2026-09-03 00:31:56.685513
451	\N	E6F943BB	0	\N	2026-09-03 00:32:00.66352	\N	2026-09-03 00:32:00.663846
452	\N	C6382BBB	0	\N	2026-09-03 00:32:04.022545	\N	2026-09-03 00:32:04.023205
453	\N	368B3DBB	0	\N	2026-09-03 00:32:07.158743	\N	2026-09-03 00:32:07.159158
454	\N	268B33BB	0	\N	2026-09-03 00:32:10.304599	\N	2026-09-03 00:32:10.305168
455	\N	E6F450BB	0	\N	2026-09-03 00:32:13.326612	\N	2026-09-03 00:32:13.32728
456	\N	D61E52BB	0	\N	2026-09-03 00:32:16.639963	\N	2026-09-03 00:32:16.640316
457	\N	668B42BB	0	\N	2026-09-03 00:32:20.833029	\N	2026-09-03 00:32:20.833809
458	\N	66BB34BB	0	\N	2026-09-03 00:32:25.900799	\N	2026-09-03 00:32:25.901245
459	\N	C6601DBB	0	\N	2026-09-03 00:32:29.830426	\N	2026-09-03 00:32:29.831112
460	\N	462A1BBB	0	\N	2026-09-03 00:32:32.967647	\N	2026-09-03 00:32:32.968334
461	\N	368B35BB	0	\N	2026-09-03 00:32:36.263242	\N	2026-09-03 00:32:36.263912
462	\N	D6F34EBB	0	\N	2026-09-03 00:32:40.981021	\N	2026-09-03 00:32:40.981403
463	\N	067F40BB	0	\N	2026-09-03 00:32:45.134217	\N	2026-09-03 00:32:45.134924
464	\N	66DA4CBB	0	\N	2026-09-03 00:32:49.86374	\N	2026-09-03 00:32:49.864546
465	\N	863353BB	0	\N	2026-09-03 00:32:54.427659	\N	2026-09-03 00:32:54.428189
466	\N	069233BB	0	\N	2026-09-03 02:38:42.725213	\N	2026-09-03 02:38:42.726042
467	\N	06E63ABB	0	\N	2026-09-03 02:38:59.613733	\N	2026-09-03 02:38:59.614215
468	\N	560F47BB	0	\N	2026-09-03 02:39:45.619975	\N	2026-09-03 02:39:45.620399
469	\N	46DE4ABB	0	\N	2026-09-03 02:40:01.3911	\N	2026-09-03 02:40:01.391509
470	\N	B6351ABB	0	\N	2026-09-03 02:40:10.377048	\N	2026-09-03 02:40:10.377446
471	\N	56332BBB	0	\N	2026-09-03 02:40:19.425137	\N	2026-09-03 02:40:19.425501
472	\N	36924BBB	0	\N	2026-09-03 02:40:43.051332	\N	2026-09-03 02:40:43.051663
473	\N	C62D1ABB	0	\N	2026-09-03 02:40:52.46432	\N	2026-09-03 02:40:52.464734
474	\N	265F2DBB	0	\N	2026-09-03 02:41:03.912654	\N	2026-09-03 02:41:03.913058
475	\N	B62C25BB	0	\N	2026-09-03 02:41:20.078791	\N	2026-09-03 02:41:20.079316
476	\N	F64C2BBB	0	\N	2026-09-03 02:41:38.850864	\N	2026-09-03 02:41:38.851653
477	\N	46C81EBB	0	\N	2026-09-03 02:41:51.354545	\N	2026-09-03 02:41:51.354729
478	\N	C6AF5CBB	0	\N	2026-09-03 02:42:01.132389	\N	2026-09-03 02:42:01.132826
479	\N	16EB46BB	0	\N	2026-09-03 02:42:14.561654	\N	2026-09-03 02:42:14.562504
480	\N	B68C56BB	0	\N	2026-09-03 02:42:26.436467	\N	2026-09-03 02:42:26.436854
481	\N	56AC21BB	0	\N	2026-09-03 02:42:37.578858	\N	2026-09-03 02:42:37.579348
482	\N	B6113CBB	0	\N	2026-09-03 02:42:48.768691	\N	2026-09-03 02:42:48.769149
165	\N	364A45BB	1	05000002	2026-09-02 05:54:19.016762	2026-09-03 06:50:21.374039	2026-09-03 06:50:21.434335
166	\N	96AB23BB	1	05000003	2026-09-02 05:54:23.837067	2026-09-03 06:50:21.377034	2026-09-03 06:50:21.434336
360	\N	96762BBB	1	05000197	2026-09-02 13:46:21.297417	2026-09-05 10:12:13.093119	2026-09-05 10:12:13.189942
363	\N	96003BBB	1	05000201	2026-09-02 13:46:31.35777	2026-09-05 10:12:13.066033	2026-09-05 10:12:13.189943
366	\N	368D31BB	1	05000204	2026-09-02 13:46:40.836863	2026-09-05 10:12:13.139813	2026-09-05 10:12:13.189944
369	\N	266839BB	1	05000207	2026-09-02 13:46:51.968811	2026-09-05 10:12:13.132511	2026-09-05 10:12:13.189945
372	\N	16BD1FBB	1	05000210	2026-09-02 13:47:03.053281	2026-09-05 10:12:13.082254	2026-09-05 10:12:13.189946
375	\N	C65229BB	1	05000213	2026-09-02 13:47:14.980327	2026-09-05 10:12:13.084464	2026-09-05 10:12:13.189947
378	\N	169B23BB	1	05000216	2026-09-02 13:47:26.773897	2026-09-05 10:12:13.042398	2026-09-05 10:12:13.189948
381	\N	E68621BB	1	05000219	2026-09-02 13:47:38.349271	2026-09-05 10:12:13.086637	2026-09-05 10:12:13.189949
390	\N	B6685ABB	1	05000241	2026-09-02 13:49:25.852194	2026-09-05 10:13:12.7843	2026-09-05 10:13:12.790033
167	\N	567427BB	1	05000004	2026-09-02 05:54:27.865804	2026-09-03 06:50:21.38164	2026-09-03 06:50:21.434337
168	\N	D6AC3EBB	1	05000005	2026-09-02 05:54:34.566648	2026-09-03 06:50:21.364011	2026-09-03 06:50:21.434338
483	\N	D7595CAD	1	23000001	2026-09-03 07:17:29.620907	2026-09-03 07:30:04.169846	2026-09-03 07:30:04.172935
484	\N	B6822DBB	0	\N	2026-09-04 00:56:32.931474	\N	2026-09-04 00:56:32.940618
486	\N	C62C27BB	0	\N	2026-09-04 00:56:42.715435	\N	2026-09-04 00:56:42.715927
487	\N	36FC2FBB	0	\N	2026-09-04 00:56:46.239732	\N	2026-09-04 00:56:46.240718
489	\N	264251BB	0	\N	2026-09-04 00:56:53.643178	\N	2026-09-04 00:56:53.643494
490	\N	860245BB	0	\N	2026-09-04 00:56:57.651754	\N	2026-09-04 00:56:57.652238
492	\N	F64537BB	0	\N	2026-09-04 00:57:05.322573	\N	2026-09-04 00:57:05.323159
493	\N	663238BB	0	\N	2026-09-04 00:57:09.108975	\N	2026-09-04 00:57:09.109532
495	\N	26072FBB	0	\N	2026-09-04 00:57:16.620617	\N	2026-09-04 00:57:16.621143
496	\N	76FA1CBB	0	\N	2026-09-04 00:57:20.705369	\N	2026-09-04 00:57:20.705808
498	\N	066335BB	0	\N	2026-09-04 00:57:28.727266	\N	2026-09-04 00:57:28.728046
499	\N	860C20BB	0	\N	2026-09-04 00:57:32.320671	\N	2026-09-04 00:57:32.321186
501	\N	E67F3CBB	0	\N	2026-09-04 00:57:40.024126	\N	2026-09-04 00:57:40.025497
502	\N	26195BBB	0	\N	2026-09-04 00:57:44.121213	\N	2026-09-04 00:57:44.121705
504	\N	46095BBB	0	\N	2026-09-04 00:57:52.335193	\N	2026-09-04 00:57:52.335691
505	\N	565B31BB	0	\N	2026-09-04 01:18:54.024373	\N	2026-09-04 01:18:54.027478
185	\N	262F27BB	1	05000022	2026-09-02 05:56:11.423293	2026-09-05 03:09:46.020278	2026-09-05 03:09:46.03195
200	\N	D60D4EBB	1	05000037	2026-09-02 05:57:20.361868	2026-09-05 03:22:07.255653	2026-09-05 03:22:07.290418
201	\N	E67740BB	1	05000038	2026-09-02 05:57:24.366899	2026-09-05 03:22:07.230922	2026-09-05 03:22:07.290418
203	\N	065149BB	1	05000040	2026-09-02 05:57:32.589969	2026-09-05 03:22:07.248849	2026-09-05 03:22:07.290419
204	\N	B6A921BB	1	05000041	2026-09-02 05:57:36.925733	2026-09-05 03:22:07.260208	2026-09-05 03:22:07.290419
205	\N	16FF21BB	1	05000042	2026-09-02 05:57:40.788975	2026-09-05 03:22:07.27124	2026-09-05 03:22:07.290419
206	\N	765C37BB	1	05000043	2026-09-02 05:57:45.121411	2026-09-05 03:22:07.275546	2026-09-05 03:22:07.29042
207	\N	B6D844BB	1	05000044	2026-09-02 05:57:51.412168	2026-09-05 03:22:07.266834	2026-09-05 03:22:07.29042
485	\N	26513CBB	0	\N	2026-09-04 00:56:39.240847	\N	2026-09-04 00:56:39.241167
488	\N	367C4DBB	0	\N	2026-09-04 00:56:49.900871	\N	2026-09-04 00:56:49.90121
491	\N	E61D51BB	0	\N	2026-09-04 00:57:01.573919	\N	2026-09-04 00:57:01.574285
494	\N	06B651BB	0	\N	2026-09-04 00:57:12.936205	\N	2026-09-04 00:57:12.936774
497	\N	76C354BB	0	\N	2026-09-04 00:57:25.100785	\N	2026-09-04 00:57:25.101188
500	\N	D62627BB	0	\N	2026-09-04 00:57:36.513565	\N	2026-09-04 00:57:36.514172
503	\N	66C656BB	0	\N	2026-09-04 00:57:48.463677	\N	2026-09-04 00:57:48.46491
172	\N	161025BB	1	05000009	2026-09-02 05:54:54.580123	2026-09-05 02:49:34.005544	2026-09-05 02:49:34.065294
173	\N	C6D552BB	1	05000010	2026-09-02 05:54:59.861011	2026-09-05 02:49:34.017605	2026-09-05 02:49:34.065295
174	\N	56BF1EBB	1	05000011	2026-09-02 05:55:04.940289	2026-09-05 02:49:34.008895	2026-09-05 02:49:34.065296
175	\N	567835BB	1	05000012	2026-09-02 05:55:11.041191	2026-09-05 02:49:34.036386	2026-09-05 02:49:34.065296
176	\N	F67333BB	1	05000013	2026-09-02 05:55:16.389464	2026-09-05 02:49:34.022965	2026-09-05 02:49:34.065297
177	\N	063C53BB	1	05000014	2026-09-02 05:55:22.712407	2026-09-05 02:49:33.999935	2026-09-05 02:49:34.065298
178	\N	E69B5CBB	1	05000015	2026-09-02 05:55:26.663945	2026-09-05 02:49:34.028489	2026-09-05 02:49:34.065298
180	\N	C6EB21BB	1	05000017	2026-09-02 05:55:43.678632	2026-09-05 02:49:34.013268	2026-09-05 02:49:34.065299
181	\N	A6A222BB	1	05000018	2026-09-02 05:55:52.965356	2026-09-05 02:49:34.031168	2026-09-05 02:49:34.0653
220	\N	36AE4EBB	1	05000057	2026-09-02 06:11:22.242012	2026-09-05 05:23:20.913838	2026-09-05 05:23:20.957551
221	\N	66633CBB	1	05000058	2026-09-02 06:11:25.662614	2026-09-05 05:23:20.820407	2026-09-05 05:23:20.957552
223	\N	16514CBB	1	05000060	2026-09-02 06:11:34.426064	2026-09-05 05:23:20.823474	2026-09-05 05:23:20.957553
224	\N	C6A01EBB	1	05000061	2026-09-02 06:11:38.474627	2026-09-05 05:23:20.861463	2026-09-05 05:23:20.957553
225	\N	A66836BB	1	05000062	2026-09-02 06:11:45.93253	2026-09-05 05:23:20.856824	2026-09-05 05:23:20.957553
226	\N	86134BBB	1	05000063	2026-09-02 06:11:53.677977	2026-09-05 05:23:20.911402	2026-09-05 05:23:20.957554
227	\N	F6984DBB	1	05000064	2026-09-02 06:12:31.61908	2026-09-05 05:23:20.892099	2026-09-05 05:23:20.957554
228	\N	D6B842BB	1	05000065	2026-09-02 06:12:40.698153	2026-09-05 05:23:20.883204	2026-09-05 05:23:20.957554
229	\N	36A43CBB	1	05000066	2026-09-02 06:12:44.633816	2026-09-05 05:23:20.836328	2026-09-05 05:23:20.957555
230	\N	96371FBB	1	05000067	2026-09-02 06:12:49.7603	2026-09-05 05:23:20.875867	2026-09-05 05:23:20.957555
231	\N	061449BB	1	05000068	2026-09-02 06:12:54.599111	2026-09-05 05:23:20.866087	2026-09-05 05:23:20.957556
232	\N	26BF45BB	1	05000069	2026-09-02 06:13:02.491069	2026-09-05 05:23:20.924455	2026-09-05 05:23:20.957556
233	\N	C6E81ABB	1	05000070	2026-09-02 06:13:06.337269	2026-09-05 05:23:20.838755	2026-09-05 05:23:20.957556
234	\N	66FF21BB	1	05000071	2026-09-02 06:13:10.347879	2026-09-05 05:23:20.849243	2026-09-05 05:23:20.957557
235	\N	A6585CBB	1	05000072	2026-09-02 06:13:14.468849	2026-09-05 05:23:20.844286	2026-09-05 05:23:20.957557
236	\N	46CB3ABB	1	05000073	2026-09-02 06:13:18.753492	2026-09-05 05:23:20.906803	2026-09-05 05:23:20.957557
237	\N	F67533BB	1	05000074	2026-09-02 06:13:22.651828	2026-09-05 05:23:20.921847	2026-09-05 05:23:20.957558
241	\N	C65B3EBB	1	05000078	2026-09-02 06:13:42.117055	2026-09-05 05:23:20.90194	2026-09-05 05:23:20.957558
242	\N	76F352BB	1	05000079	2026-09-02 06:13:45.357751	2026-09-05 05:23:20.897177	2026-09-05 05:23:20.957558
243	\N	269021BB	1	05000080	2026-09-02 06:13:49.508458	2026-09-05 05:23:20.863778	2026-09-05 05:23:20.957559
244	\N	56C051BB	1	05000081	2026-09-02 06:13:52.940124	2026-09-05 05:23:20.854373	2026-09-05 05:23:20.957559
245	\N	06561DBB	1	05000082	2026-09-02 06:13:56.830128	2026-09-05 05:23:20.851762	2026-09-05 05:23:20.957559
249	\N	56363ABB	1	05000086	2026-09-02 06:14:18.295122	2026-09-05 05:23:20.8467	2026-09-05 05:23:20.95756
250	\N	C6D73BBB	1	05000087	2026-09-02 06:14:21.542547	2026-09-05 05:23:20.899657	2026-09-05 05:23:20.95756
251	\N	668A1FBB	1	05000088	2026-09-02 06:14:25.842075	2026-09-05 05:23:20.841599	2026-09-05 05:23:20.957561
252	\N	661D38BB	1	05000089	2026-09-02 06:14:29.661866	2026-09-05 05:23:20.919331	2026-09-05 05:23:20.957561
253	\N	A67125BB	1	05000090	2026-09-02 06:14:34.174177	2026-09-05 05:23:20.894547	2026-09-05 05:23:20.957561
254	\N	86FB44BB	1	05000091	2026-09-02 06:14:40.03883	2026-09-05 05:23:20.831539	2026-09-05 05:23:20.957562
255	\N	16CC46BB	1	05000092	2026-09-02 06:14:44.589457	2026-09-05 05:23:20.868518	2026-09-05 05:23:20.957562
256	\N	667547BB	1	05000093	2026-09-02 06:14:51.216442	2026-09-05 05:23:20.888838	2026-09-05 05:23:20.957563
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: solar_admin
--

COPY public.customers (id, uuid, offline_origin_uuid, first_name, last_name, gender, mobile, email, birthday, address, region_id, status, electric_company, beneficiary_count, representative_name, rep_relationship, expiry_time, total_recharged_days, total_recharged_amount, installed_at, created_at, updated_at) FROM stdin;
269	05000112	\N	LUBAIDA K.	BEYAO	male	268	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:51:56	30.00	210.00	2026-09-05 14:51:56	2026-08-28 12:45:05.033669	2026-09-05 07:05:38.338649
271	05000114	\N	FATIMA N.	GUINTAWAN	male	270	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:52:39	30.00	210.00	2026-09-05 14:52:39	2026-08-28 12:45:05.035843	2026-09-05 07:05:38.338649
272	05000115	\N	BAI P.	GUINTAWAN	male	271	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:53:02	30.00	210.00	2026-09-05 14:53:02	2026-08-28 12:45:05.036899	2026-09-05 07:05:38.338649
273	05000116	\N	TOBIE P.	GUINTAWAN	male	272	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:53:23	30.00	210.00	2026-09-05 14:53:23	2026-08-28 12:45:05.037992	2026-09-05 07:05:38.338649
274	05000117	\N	FARIDA B.	MALASAM	male	273	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:53:46	30.00	210.00	2026-09-05 14:53:46	2026-08-28 12:45:05.039062	2026-09-05 07:05:38.338649
275	05000118	\N	MONIDA G.	BLASIM	male	274	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:54:09	30.00	210.00	2026-09-05 14:54:09	2026-08-28 12:45:05.040357	2026-09-05 07:05:38.338649
39	03000038	\N	KODIKAN,	DATUAN B.	male	38	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:43:05	20.00	140.00	2026-08-31 14:34:35	2026-08-28 06:19:33.126123	2026-09-15 06:47:55.163753
40	03000039	\N	MAMINTAL,	BAINISA BACANA	male	39	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:46:41	20.00	140.00	2026-08-31 14:35:52	2026-08-28 06:19:33.127324	2026-09-15 06:47:55.163753
41	03000040	\N	PALAKAT,	MAKAAYAO B.	male	40	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:43:51	20.00	140.00	2026-08-31 14:49:23	2026-08-28 06:19:33.128454	2026-09-15 06:47:55.163753
42	03000041	\N	PASANDALAN,	SARAH R.	male	41	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:44:16	20.00	140.00	2026-08-31 14:50:21	2026-08-28 06:19:33.129479	2026-09-15 06:47:55.163753
43	03000042	\N	PASANDALAN,	MOHAMAD A.	male	42	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:44:30	20.00	140.00	2026-08-31 14:54:05	2026-08-28 06:19:33.130498	2026-09-15 06:47:55.163753
44	03000043	\N	TASIL,	SALAHUDIN D.	male	43	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:44:46	20.00	140.00	2026-08-31 14:54:26	2026-08-28 06:19:33.131589	2026-09-15 06:47:55.163753
45	03000044	\N	MUSA,	HUSAIN S.	male	44	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:45:00	20.00	140.00	2026-08-31 14:54:49	2026-08-28 06:19:33.133263	2026-09-15 06:47:55.163753
46	03000045	\N	MOHAMAD,	JANICE M.	male	45	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:45:21	20.00	140.00	2026-08-31 14:55:10	2026-08-28 06:19:33.135285	2026-09-15 06:47:55.163753
17	03000016	\N	MAMINTAL,	MENDOTS P.	male	16	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:39:35	20.00	140.00	2026-08-31 14:04:54	2026-08-28 06:19:33.097442	2026-09-15 06:48:05.522893
23	03000022	\N	HARON,	BADRUDIN D.	male	22	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:41:01	20.00	140.00	2026-08-31 14:13:36	2026-08-28 06:19:33.106727	2026-09-15 06:48:05.522893
24	03000023	\N	MAMENTAL,	BENJADED D.	male	23	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:41:18	20.00	140.00	2026-08-31 14:17:18	2026-08-28 06:19:33.107744	2026-09-15 06:48:05.522893
25	03000024	\N	GUIALAL,	HARES D.	male	24	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:41:33	20.00	140.00	2026-08-31 14:17:45	2026-08-28 06:19:33.108723	2026-09-15 06:48:05.522893
26	03000025	\N	KADIL,	TONTON M.	male	25	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:41:47	20.00	140.00	2026-08-31 14:22:40	2026-08-28 06:19:33.109673	2026-09-15 06:48:05.522893
27	03000026	\N	ABDULLAH,	JOKARNAIN S.	male	26	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:42:02	20.00	140.00	2026-08-31 14:23:36	2026-08-28 06:19:33.110863	2026-09-15 06:48:05.522893
28	03000027	\N	MANTIKAYAN,	MOTIN P.	male	27	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:42:15	20.00	140.00	2026-08-31 14:24:07	2026-08-28 06:19:33.112025	2026-09-15 06:48:05.522893
29	03000028	\N	APLAL,	KADIGIA D.	male	28	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:42:29	20.00	140.00	2026-08-31 14:24:31	2026-08-28 06:19:33.113065	2026-09-15 06:48:05.522893
30	03000029	\N	DALAMBA,	ABEDIN L.	male	29	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:43:22	20.00	140.00	2026-08-31 14:24:54	2026-08-28 06:19:33.114134	2026-09-15 06:48:05.522893
15	03000014	\N	HARON,	USMAN D.	male	14	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-10 14:03:53	10.00	70.00	2026-08-31 14:03:53	2026-08-28 06:19:33.095244	2026-08-31 06:12:27.93093
16	03000015	\N	DAGADAS,	MUJAHEDIN M.	male	15	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-10 14:04:24	10.00	70.00	2026-08-31 14:04:24	2026-08-28 06:19:33.096344	2026-08-31 06:12:27.93093
276	05000119	\N	MANNY D.	SAPALON	male	275	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:54:27	30.00	210.00	2026-09-05 14:54:27	2026-08-28 12:45:05.041494	2026-09-05 07:05:38.338649
277	05000120	\N	MINDA M.	LAMALAN	male	276	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:54:53	30.00	210.00	2026-09-05 14:54:53	2026-08-28 12:45:05.042621	2026-09-05 07:05:38.338649
280	05000123	\N	ALI B.	LAMALAN	male	279	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:56:22	30.00	210.00	2026-09-05 14:56:22	2026-08-28 12:45:05.046142	2026-09-05 07:05:38.338649
282	05000125	\N	RAHIMA N.	LAMALAN	male	281	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:57:04	30.00	210.00	2026-09-05 14:57:04	2026-08-28 12:45:05.049613	2026-09-05 07:05:38.338649
284	05000127	\N	MUHAMMED G.	KEMPEK	male	283	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:57:40	30.00	210.00	2026-09-05 14:57:40	2026-08-28 12:45:05.051911	2026-09-05 07:05:38.338649
286	05000129	\N	MANDUNGAN S.	DALID	male	285	bbb@bbb.com	\N	PROPER,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:58:28	30.00	210.00	2026-09-05 14:58:28	2026-08-28 12:45:05.054097	2026-09-05 07:05:38.338649
287	05000130	\N	NURSALAM S.	LUMANGKA	male	286	bbb@bbb.com	\N	PROPER,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:58:52	30.00	210.00	2026-09-05 14:58:52	2026-08-28 12:45:05.055192	2026-09-05 07:05:38.338649
288	05000131	\N	SAMRAIDA A.	DALID	male	287	bbb@bbb.com	\N	PROPER,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:59:10	30.00	210.00	2026-09-05 14:59:10	2026-08-28 12:45:05.056316	2026-09-05 07:05:38.338649
289	05000132	\N	PAPS K.	BULANON	male	288	bbb@bbb.com	\N	PROPER,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:59:33	30.00	210.00	2026-09-05 14:59:33	2026-08-28 12:45:05.057382	2026-09-05 07:05:38.338649
290	05000133	\N	ALBASSER A.	MAMOLINDAS	male	289	bbb@bbb.com	\N	PROPER,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:00:05	30.00	210.00	2026-09-05 15:00:05	2026-08-28 12:45:05.058513	2026-09-05 07:05:38.338649
291	05000134	\N	AISA S.	SULTAN	male	290	bbb@bbb.com	\N	PROPER,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:00:33	30.00	210.00	2026-09-05 15:00:33	2026-08-28 12:45:05.059568	2026-09-05 07:05:38.338649
293	05000136	\N	SAGUIRA D.	SANDAYAN	male	292	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:01:30	30.00	210.00	2026-09-05 15:01:30	2026-08-28 12:45:05.06227	2026-09-05 07:05:38.338649
294	05000137	\N	RACHMA L.	MAGANOD	male	293	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:01:58	30.00	210.00	2026-09-05 15:01:58	2026-08-28 12:45:05.064079	2026-09-05 07:05:38.338649
295	05000138	\N	NORAISA L.	MAGANOD	male	294	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:02:30	30.00	210.00	2026-09-05 15:02:30	2026-08-28 12:45:05.065814	2026-09-05 07:05:38.338649
296	05000139	\N	JOMAR A.	DUMALAMBA	male	295	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:02:56	30.00	210.00	2026-09-05 15:02:56	2026-08-28 12:45:05.067079	2026-09-05 07:05:38.338649
297	05000140	\N	BABAY A.	YUSOP	male	296	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:03:18	30.00	210.00	2026-09-05 15:03:18	2026-08-28 12:45:05.068345	2026-09-05 07:05:38.338649
298	05000141	\N	DATUALI B.	GUIAMAD	male	297	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:03:44	30.00	210.00	2026-09-05 15:03:44	2026-08-28 12:45:05.069564	2026-09-05 07:05:38.338649
299	05000142	\N	PAGS P.	USOP	male	298	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:04:13	30.00	210.00	2026-09-05 15:04:13	2026-08-28 12:45:05.070688	2026-09-05 07:05:38.338649
300	05000143	\N	JULHARI M.	ALAM	male	299	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:04:38	30.00	210.00	2026-09-05 15:04:38	2026-08-28 12:45:05.071791	2026-09-05 07:05:38.338649
88	03000087	\N	ZAINODIN,MORSED	D.	male	87	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:27:27	20.00	140.00	2026-08-31 16:57:49	2026-08-28 06:19:33.188529	2026-09-15 06:47:55.163753
90	03000089	\N	SALIK,	NORODIN S.	male	89	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:27:59	20.00	140.00	2026-08-31 16:58:33	2026-08-28 06:19:33.190785	2026-09-15 06:47:55.163753
91	03000090	\N	PANDALAT,	ABDULATIP M.	male	90	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:27:40	20.00	140.00	2026-08-31 16:58:57	2026-08-28 06:19:33.191859	2026-09-15 06:47:55.163753
81	03000080	\N	ALI,	NORUDIN P.	male	80	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:37:12	20.00	140.00	2026-08-31 16:54:50	2026-08-28 06:19:33.179396	2026-09-15 06:48:05.522893
86	03000085	\N	PANGATO,	HAMDANIE S.	male	85	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:26:28	20.00	140.00	2026-08-31 16:57:04	2026-08-28 06:19:33.186495	2026-09-15 06:48:05.522893
87	03000086	\N	SALIK	(HADJI), ABDULLAH M.	male	86	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:27:23	20.00	140.00	2026-08-31 16:57:27	2026-08-28 06:19:33.187534	2026-09-15 06:48:05.522893
89	03000088	\N	SAKAL,	TIMBOY E.	male	88	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-10 16:58:10	10.00	70.00	2026-08-31 16:58:10	2026-08-28 06:19:33.189555	2026-08-31 09:06:09.417
301	05000144	\N	SAYMEN K.	BANGON	male	300	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:05:05	30.00	210.00	2026-09-05 15:05:05	2026-08-28 12:45:05.07284	2026-09-05 07:05:38.338649
51	03000050	\N	ADZED,	NIDA A.	male	50	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:26:36	20.00	140.00	2026-08-31 14:57:46	2026-08-28 06:19:33.142293	2026-09-15 05:46:20.744285
62	03000061	\N	TONG,	NORODIN A.	male	61	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:36:32	20.00	140.00	2026-08-31 15:04:59	2026-08-28 06:19:33.156019	2026-09-15 05:46:20.744285
64	03000063	\N	PANDALAT	, ZAKARIA B.	male	63	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:29:13	20.00	140.00	2026-08-31 15:05:44	2026-08-28 06:19:33.158227	2026-09-15 05:46:20.744285
65	03000064	\N	TONG,	PAUAN U.	male	64	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:30:19	20.00	140.00	2026-08-31 15:06:07	2026-08-28 06:19:33.159345	2026-09-15 05:46:20.744285
66	03000065	\N	MARINGKONG,	BABAY B.	male	65	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:30:55	20.00	140.00	2026-08-31 15:06:33	2026-08-28 06:19:33.160472	2026-09-15 05:46:20.744285
67	03000066	\N	HARON,	SOHAIL D.	male	66	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:31:15	20.00	140.00	2026-08-31 15:06:55	2026-08-28 06:19:33.161566	2026-09-15 05:46:20.744285
68	03000067	\N	ASAB,	MARIAM A.	male	67	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:38:38	20.00	140.00	2026-08-31 15:07:17	2026-08-28 06:19:33.16271	2026-09-15 05:46:20.744285
70	03000069	\N	SAKAL,	NORHATA A.	male	69	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:41:54	20.00	140.00	2026-08-31 15:08:53	2026-08-28 06:19:33.165415	2026-09-15 05:46:20.744285
72	03000071	\N	GILMAN,	RAHMA P.	male	71	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:35:29	20.00	140.00	2026-08-31 16:51:12	2026-08-28 06:19:33.169487	2026-09-15 05:46:20.744285
73	03000072	\N	SIBO,	ABDULHAMID P.	male	72	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:35:10	20.00	140.00	2026-08-31 16:51:38	2026-08-28 06:19:33.170746	2026-09-15 05:46:20.744285
74	03000073	\N	ALI,	EDRES M.	male	73	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:34:46	20.00	140.00	2026-08-31 16:51:59	2026-08-28 06:19:33.171856	2026-09-15 05:46:20.744285
75	03000074	\N	DATUAN,	NOR-AIN B.	male	74	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:34:25	20.00	140.00	2026-08-31 16:52:29	2026-08-28 06:19:33.172884	2026-09-15 05:46:20.744285
76	03000075	\N	ABDULMAULA,	MAHDIE M.	male	75	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:34:04	20.00	140.00	2026-08-31 16:52:51	2026-08-28 06:19:33.174055	2026-09-15 05:46:20.744285
104	03000103	\N	ALI,	NORAIN B.	male	103	aaa@aaa.com	2000-01-01	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:48:42	20.00	140.00	2026-08-31 19:05:29	2026-08-28 06:19:33.208055	2026-09-15 05:50:32.370841
106	03000105	\N	ABUBAKAR,	NORHAIN L.	male	105	aaa@aaa.com	2000-01-01	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:39:27	20.00	140.00	2026-08-31 18:43:19	2026-08-28 06:19:33.210064	2026-09-15 06:47:55.163753
107	03000106	\N	DALAMBA,	NOHARODIN H.	male	106	aaa@aaa.com	2000-01-01	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:25:32	20.00	140.00	2026-08-31 18:44:25	2026-08-28 06:19:33.211057	2026-09-15 06:47:55.163753
115	03000114	\N	PANDALAT,	GUIAMA M.	male	114	aaa@aaa.com	2000-01-01	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:27:51	20.00	140.00	2026-08-31 19:06:34	2026-08-28 06:19:33.221582	2026-09-15 06:48:05.522893
117	03000116	\N	ALI,	IBRAHIM N.	male	116	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:28:07	20.00	140.00	2026-09-01 09:48:27	2026-08-28 06:19:33.22385	2026-09-15 06:48:05.522893
119	03000118	\N	YUSOP,	BADJUNAID M.	male	118	aaa@aaa.com	\N	MA'AHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:29:35	20.00	140.00	2026-09-01 09:49:16	2026-08-28 06:19:33.226102	2026-09-15 06:48:05.522893
121	03000120	\N	YUSOP,	NORSALIN K.	male	120	aaa@aaa.com	\N	MA'AHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:29:15	20.00	140.00	2026-09-01 09:57:48	2026-08-28 06:19:33.228337	2026-09-15 06:48:05.522893
122	03000121	\N	USOP,	NORHAMIN M.	male	121	aaa@aaa.com	\N	MA'AHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:29:53	20.00	140.00	2026-09-01 13:03:45	2026-08-28 06:19:33.229405	2026-09-15 06:48:05.522893
116	03000115	\N	PANDALAT,	GUIAMA M.	male	115	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 06:19:33.222802	2026-08-28 06:19:32.726601
126	03000125	\N	SALANGANI,	BADRUDIN D.	male	125	aaa@aaa.com	\N	MAHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:38:12	20.00	140.00	2026-09-01 13:06:48	2026-08-28 06:19:33.235628	2026-09-15 06:48:05.522893
128	03000127	\N	KAMLAN,	FATIMA P.	male	127	aaa@aaa.com	\N	MAHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:38:29	20.00	140.00	2026-09-01 13:08:03	2026-08-28 06:19:33.238283	2026-09-15 06:48:05.522893
111	03000110	\N	PANDALAT,	BONG D.	male	110	aaa@aaa.com	2000-01-01	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-10 18:46:06	10.00	70.00	2026-08-31 18:46:06	2026-08-28 06:19:33.215694	2026-09-01 01:30:35.700965
127	03000126	\N	ABAS,	MOHAMMAD S.	male	126	aaa@aaa.com	\N	MAHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-11 13:07:46	10.00	70.00	2026-09-01 13:07:46	2026-08-28 06:19:33.237043	2026-09-01 05:31:06.576768
319	05000162	\N	SAMAON B.	INIDAL	male	318	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:27:33	30.00	210.00	2026-09-05 17:27:33	2026-08-28 12:45:05.098177	2026-09-05 09:47:49.427465
320	05000163	\N	DELI L.	MANGAKOP	male	319	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:28:02	30.00	210.00	2026-09-05 17:28:02	2026-08-28 12:45:05.100172	2026-09-05 09:47:49.427465
321	05000164	\N	INTAN G.	AWAT	male	320	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:28:27	30.00	210.00	2026-09-05 17:28:27	2026-08-28 12:45:05.101507	2026-09-05 09:47:49.427465
322	05000165	\N	NASSER A.	SANDAYAN	male	321	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:29:00	30.00	210.00	2026-09-05 17:29:00	2026-08-28 12:45:05.102667	2026-09-05 09:47:49.427465
323	05000166	\N	DENO B.	GUMAGA	male	322	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:29:40	30.00	210.00	2026-09-05 17:29:40	2026-08-28 12:45:05.104058	2026-09-05 09:47:49.427465
324	05000167	\N	ABDULLAH T.	BORAY	male	323	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:30:14	30.00	210.00	2026-09-05 17:30:14	2026-08-28 12:45:05.105346	2026-09-05 09:47:49.427465
325	05000168	\N	PANGGUTIN M.	MAGANOD	male	324	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:30:57	30.00	210.00	2026-09-05 17:30:57	2026-08-28 12:45:05.10649	2026-09-05 09:47:49.427465
326	05000169	\N	BOTS B.	BALAWAG	male	325	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:31:31	30.00	210.00	2026-09-05 17:31:31	2026-08-28 12:45:05.107544	2026-09-05 09:47:49.427465
327	05000170	\N	AKMAD B.	SALABAN	male	326	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:32:09	30.00	210.00	2026-09-05 17:32:09	2026-08-28 12:45:05.108584	2026-09-05 09:47:49.427465
328	05000171	\N	MANSORI A.	MAMENTAL	male	327	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:32:35	30.00	210.00	2026-09-05 17:32:35	2026-08-28 12:45:05.109627	2026-09-05 09:47:49.427465
329	05000172	\N	BAILAGA A.	ANDIK	male	328	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:34:06	30.00	210.00	2026-09-05 17:34:06	2026-08-28 12:45:05.11077	2026-09-05 09:47:49.427465
156	03000155	\N	ASAB,	AMINA M.	male	155	aaa@aaa.com	\N	TUGAL,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:34:49	20.00	140.00	2026-09-01 13:31:32	2026-08-28 06:19:33.27241	2026-09-15 06:48:05.522893
158	05000001	\N	RASMIA E.	DULOAN	male	157	bbb@bbb.com	\N	Budta,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-03 11:30:59	30.00	210.00	2026-09-03 11:30:59	2026-08-28 12:45:04.882999	2026-09-03 06:50:21.293078
159	05000002	\N	JOHN AZAROUF U.	MONDERJAR	male	158	bbb@bbb.com	\N	Budta,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-03 11:24:16	30.00	210.00	2026-09-03 11:24:16	2026-08-28 12:45:04.890407	2026-09-03 06:50:21.293078
160	05000003	\N	TAYAAN K.	PENDATUN	male	159	bbb@bbb.com	\N	Budta,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-03 14:48:28	30.00	210.00	2026-09-03 14:48:28	2026-08-28 12:45:04.892219	2026-09-03 06:50:21.293078
161	05000004	\N	KANAKAN M.	BEDA	male	160	bbb@bbb.com	\N	Budta,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-03 14:43:54	30.00	210.00	2026-09-03 14:43:54	2026-08-28 12:45:04.893592	2026-09-03 06:50:21.293078
162	05000005	\N	MASTURA K.	LAMALAN	male	161	bbb@bbb.com	\N	Budta,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-03 14:41:05	30.00	210.00	2026-09-03 14:41:05	2026-08-28 12:45:04.894878	2026-09-03 06:50:21.293078
163	05000006	\N	BOWAO S.	MAMASAPAWA	male	162	bbb@bbb.com	\N	Budta,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 10:37:08	30.00	210.00	2026-09-05 10:37:08	2026-08-28 12:45:04.896506	2026-09-05 02:49:33.969375
164	05000007	\N	MATENDO M.	KAMAT	male	163	bbb@bbb.com	\N	Budta,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 10:37:52	30.00	210.00	2026-09-05 10:37:52	2026-08-28 12:45:04.899693	2026-09-05 02:49:33.969375
165	05000008	\N	EBRAHIM E.	SABDULLAH	male	164	bbb@bbb.com	\N	Budta,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 10:40:41	30.00	210.00	2026-09-05 10:40:41	2026-08-28 12:45:04.902209	2026-09-05 02:49:33.969375
166	05000009	\N	FATIMA P.	SABDULLAH	male	165	bbb@bbb.com	\N	Budta,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 10:41:20	30.00	210.00	2026-09-05 10:41:20	2026-08-28 12:45:04.903455	2026-09-05 02:49:33.969375
167	05000010	\N	ALEX S.	KANAKAN	male	166	bbb@bbb.com	\N	Budta,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 10:41:54	30.00	210.00	2026-09-05 10:41:54	2026-08-28 12:45:04.904633	2026-09-05 02:49:33.969375
168	05000011	\N	BASSER M.	ALIMUNDO	male	167	bbb@bbb.com	\N	INALASAN,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 10:42:28	30.00	210.00	2026-09-05 10:42:28	2026-08-28 12:45:04.905929	2026-09-05 02:49:33.969375
169	05000012	\N	ZONAIDE M.	ALIMUNDO	male	168	bbb@bbb.com	\N	INALASAN,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 10:44:18	30.00	210.00	2026-09-05 10:44:18	2026-08-28 12:45:04.907034	2026-09-05 02:49:33.969375
170	05000013	\N	MARIAM S.	MASLA	male	169	bbb@bbb.com	\N	INALASAN,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 10:45:09	30.00	210.00	2026-09-05 10:45:09	2026-08-28 12:45:04.908132	2026-09-05 02:49:33.969375
171	05000014	\N	KAMARUDIN M.	ALIMUNDO	male	170	bbb@bbb.com	\N	INALASAN,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 10:45:36	30.00	210.00	2026-09-05 10:45:36	2026-08-28 12:45:04.909155	2026-09-05 02:49:33.969375
172	05000015	\N	MAIMONA M.	MANGAPAS	male	171	bbb@bbb.com	\N	INALASAN,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 10:46:16	30.00	210.00	2026-09-05 10:46:16	2026-08-28 12:45:04.910232	2026-09-05 02:49:33.969375
174	05000017	\N	TAUTIN D.	SANGGAYAKAN	male	173	bbb@bbb.com	\N	INALASAN,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 10:48:51	30.00	210.00	2026-09-05 10:48:51	2026-08-28 12:45:04.912478	2026-09-05 02:49:33.969375
175	05000018	\N	DATUALI O.	ABDULMANAN	male	174	bbb@bbb.com	\N	INALASAN,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 10:49:18	30.00	210.00	2026-09-05 10:49:18	2026-08-28 12:45:04.914329	2026-09-05 02:49:33.969375
173	05000016	\N	KONONGKON S.	DITTIE	male	172	bbb@bbb.com	\N	INALASAN,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:05:35	30.00	210.00	2026-09-05 11:05:35	2026-08-28 12:45:04.911309	2026-09-05 03:09:46.007619
176	05000019	\N	SURBAYA C.	PENDATUN	male	175	bbb@bbb.com	\N	INALASAN,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:06:11	30.00	210.00	2026-09-05 11:06:11	2026-08-28 12:45:04.915932	2026-09-05 03:09:46.007619
177	05000020	\N	MAMATO M.	MANGAPAS	male	176	bbb@bbb.com	\N	INALASAN,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:06:40	30.00	210.00	2026-09-05 11:06:40	2026-08-28 12:45:04.918705	2026-09-05 03:09:46.007619
178	05000021	\N	NORHATA SULTAN	MANGAPAS	male	177	bbb@bbb.com	\N	INALASAN,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:07:05	30.00	210.00	2026-09-05 11:07:05	2026-08-28 12:45:04.920073	2026-09-05 03:09:46.007619
179	05000022	\N	NASRODIN SEMAM	MASLA	male	178	bbb@bbb.com	\N	INALASAN,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:07:33	30.00	210.00	2026-09-05 11:07:33	2026-08-28 12:45:04.921213	2026-09-05 03:09:46.007619
183	05000026	\N	KUSARI O.	KUSANDING	male	182	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:12:03	30.00	210.00	2026-09-05 11:12:03	2026-08-28 12:45:04.925368	2026-09-05 03:14:44.693346
180	05000023	\N	JOMAX H.	MATALAM JR.	male	179	bbb@bbb.com	\N	INALASAN,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:15:15	30.00	210.00	2026-09-05 11:15:15	2026-08-28 12:45:04.922245	2026-09-05 03:22:07.224696
181	05000024	\N	AIDA M.	DALAMBAN	male	180	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:15:41	30.00	210.00	2026-09-05 11:15:41	2026-08-28 12:45:04.923276	2026-09-05 03:22:07.224696
182	05000025	\N	MANAP M.	MOHAMAD	male	181	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:16:05	30.00	210.00	2026-09-05 11:16:05	2026-08-28 12:45:04.92428	2026-09-05 03:22:07.224696
330	05000173	\N	NAIDA A.	ANDIK	male	329	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:33:31	30.00	210.00	2026-09-05 17:33:31	2026-08-28 12:45:05.111813	2026-09-05 09:47:49.427465
331	05000174	\N	OMAR A.	ANDIK	male	330	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:34:41	30.00	210.00	2026-09-05 17:34:41	2026-08-28 12:45:05.113741	2026-09-05 09:47:49.427465
332	05000175	\N	GUIAMA K.	MANDAL	male	331	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:35:06	30.00	210.00	2026-09-05 17:35:06	2026-08-28 12:45:05.115622	2026-09-05 09:47:49.427465
333	05000176	\N	SANSALONA T.	KASIM	male	332	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:35:51	30.00	210.00	2026-09-05 17:35:51	2026-08-28 12:45:05.11703	2026-09-05 09:47:49.427465
334	05000177	\N	SINANTAO T.	ALIMAN	male	333	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:36:16	30.00	210.00	2026-09-05 17:36:16	2026-08-28 12:45:05.118163	2026-09-05 09:47:49.427465
335	05000178	\N	MAUMBAY M.	AMAN	male	334	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:36:46	30.00	210.00	2026-09-05 17:36:46	2026-08-28 12:45:05.11936	2026-09-05 09:47:49.427465
336	05000179	\N	BAILANE L.	MAGANOD	male	335	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:37:23	30.00	210.00	2026-09-05 17:37:23	2026-08-28 12:45:05.12065	2026-09-05 09:47:49.427465
337	05000180	\N	NORAISA K.	YUSOP	male	336	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:38:09	30.00	210.00	2026-09-05 17:38:09	2026-08-28 12:45:05.12181	2026-09-05 09:47:49.427465
338	05000181	\N	INDEG K.	GUIAMAT	male	337	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:38:44	30.00	210.00	2026-09-05 17:38:44	2026-08-28 12:45:05.122969	2026-09-05 09:47:49.427465
339	05000182	\N	NORA G.	TAMBAO	male	338	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:39:23	30.00	210.00	2026-09-05 17:39:23	2026-08-28 12:45:05.124004	2026-09-05 09:47:49.427465
340	05000183	\N	SAPATOLA A.	SALABAN	male	339	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:40:00	30.00	210.00	2026-09-05 17:40:00	2026-08-28 12:45:05.125041	2026-09-05 09:47:49.427465
341	05000184	\N	BAYNON P.	LAGO	male	340	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:41:17	30.00	210.00	2026-09-05 17:41:17	2026-08-28 12:45:05.126091	2026-09-05 09:47:49.427465
342	05000185	\N	SAMSUDIN G.	LAMALAN	male	341	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:42:56	30.00	210.00	2026-09-05 17:42:56	2026-08-28 12:45:05.127171	2026-09-05 09:47:49.427465
343	05000186	\N	LAGINDI S.	BAKUNA	male	342	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:43:21	30.00	210.00	2026-09-05 17:43:21	2026-08-28 12:45:05.128237	2026-09-05 09:47:49.427465
344	05000187	\N	PIKAS L.	GUIAMAD	male	343	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:43:56	30.00	210.00	2026-09-05 17:43:56	2026-08-28 12:45:05.129619	2026-09-05 09:47:49.427465
345	05000188	\N	MAMOT A.	ANDIK	male	344	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:44:26	30.00	210.00	2026-09-05 17:44:26	2026-08-28 12:45:05.131269	2026-09-05 09:47:49.427465
346	05000189	\N	KEMON S.	SALILA	male	345	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:45:37	30.00	210.00	2026-09-05 17:45:37	2026-08-28 12:45:05.133159	2026-09-05 09:47:49.427465
347	05000190	\N	ABDUL YASER B.	MANALINDING	male	346	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:46:08	30.00	210.00	2026-09-05 17:46:08	2026-08-28 12:45:05.134527	2026-09-05 09:47:49.427465
349	05000192	\N	AMINA T.	SALI	male	348	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:47:00	30.00	210.00	2026-09-05 17:47:00	2026-08-28 12:45:05.136916	2026-09-05 09:47:49.427465
350	05000193	\N	MELIA M.	MIDSAPAK	male	349	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:47:22	30.00	210.00	2026-09-05 17:47:22	2026-08-28 12:45:05.138164	2026-09-05 09:47:49.427465
351	05000194	\N	MAGUID S.	LIMPANGAN	male	350	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:47:41	30.00	210.00	2026-09-05 17:47:41	2026-08-28 12:45:05.139323	2026-09-05 09:47:49.427465
368	05000211	\N	NORMINA U.	SALI	male	367	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:00:22	30.00	210.00	2026-09-05 18:00:22	2026-08-28 12:45:05.161228	2026-09-05 10:12:13.027057
369	05000212	\N	TAYA M.	UNTI	male	368	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:00:39	30.00	210.00	2026-09-05 18:00:39	2026-08-28 12:45:05.162509	2026-09-05 10:12:13.027057
370	05000213	\N	NORIA K.	SALIPADA	male	369	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:00:56	30.00	210.00	2026-09-05 18:00:56	2026-08-28 12:45:05.163968	2026-09-05 10:12:13.027057
189	05000032	\N	TAYA S.	PAGA	male	188	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:16:34	30.00	210.00	2026-09-05 11:16:34	2026-08-28 12:45:04.934361	2026-09-05 03:22:07.224696
190	05000033	\N	MAGNO D.	AKMAD	male	189	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:17:00	30.00	210.00	2026-09-05 11:17:00	2026-08-28 12:45:04.935642	2026-09-05 03:22:07.224696
191	05000034	\N	MAX L.	AKMAD	male	190	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:17:22	30.00	210.00	2026-09-05 11:17:22	2026-08-28 12:45:04.936848	2026-09-05 03:22:07.224696
184	05000027	\N	MAX K.	MOKAMAD	male	183	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:26:15	30.00	210.00	2026-09-05 11:26:15	2026-08-28 12:45:04.926451	2026-09-05 03:26:45.723541
187	05000030	\N	ALI M.	GUIAMBLANG	male	186	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:26:41	30.00	210.00	2026-09-05 11:26:41	2026-08-28 12:45:04.930756	2026-09-05 03:26:45.723541
202	05000045	\N	LUGAYA B.	INOK	male	201	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:19:45	30.00	210.00	2026-09-05 12:19:45	2026-08-28 12:45:04.950675	2026-09-05 05:23:20.812187
203	05000046	\N	KOLAYAN S.	MALIDAS	male	202	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:20:28	30.00	210.00	2026-09-05 12:20:28	2026-08-28 12:45:04.951745	2026-09-05 05:23:20.812187
205	05000048	\N	LUNA U.	BARAGUIR	male	204	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:44:46	30.00	210.00	2026-09-05 12:44:46	2026-08-28 12:45:04.95393	2026-09-05 05:23:20.812187
206	05000049	\N	GULIDTEM G.	PANDALAT	male	205	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:45:14	30.00	210.00	2026-09-05 12:45:14	2026-08-28 12:45:04.955156	2026-09-05 05:23:20.812187
207	05000050	\N	ZAINAB P.	BISALAO	male	206	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:45:43	30.00	210.00	2026-09-05 12:45:43	2026-08-28 12:45:04.956267	2026-09-05 05:23:20.812187
208	05000051	\N	GUIAPAL S.	BISALAO	male	207	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:46:10	30.00	210.00	2026-09-05 12:46:10	2026-08-28 12:45:04.957374	2026-09-05 05:23:20.812187
209	05000052	\N	BOY M.	USOP	male	208	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:46:43	30.00	210.00	2026-09-05 12:46:43	2026-08-28 12:45:04.958462	2026-09-05 05:23:20.812187
210	05000053	\N	MALIYAM M.	SEBANGAN	male	209	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:47:18	30.00	210.00	2026-09-05 12:47:18	2026-08-28 12:45:04.959492	2026-09-05 05:23:20.812187
211	05000054	\N	AISA G.	TAMUKAN	male	210	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:47:41	30.00	210.00	2026-09-05 12:47:41	2026-08-28 12:45:04.960544	2026-09-05 05:23:20.812187
212	05000055	\N	WENG P.	SANDIGAN	male	211	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:48:09	30.00	210.00	2026-09-05 12:48:09	2026-08-28 12:45:04.96156	2026-09-05 05:23:20.812187
251	05000094	\N	GUIOLING P.	KAMID	male	250	bbb@bbb.com	\N	LUMANGKA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 13:24:02	30.00	210.00	2026-09-05 13:24:02	2026-08-28 12:45:05.01087	2026-09-05 05:24:12.517015
240	05000083	\N	AMERA S.	SOLAIMAN	male	239	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 13:31:01	30.00	210.00	2026-09-05 13:31:01	2026-08-28 12:45:04.998901	2026-09-05 06:01:26.555575
254	05000097	\N	MUSA B.	MALUGAYAK	male	253	bbb@bbb.com	\N	LUMANGKA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:35:51	30.00	210.00	2026-09-05 14:35:51	2026-08-28 12:45:05.015466	2026-09-05 07:05:38.338649
255	05000098	\N	MONERA M.	LAMALAN	male	254	bbb@bbb.com	\N	LUMANGKA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:37:12	30.00	210.00	2026-09-05 14:37:12	2026-08-28 12:45:05.016626	2026-09-05 07:05:38.338649
256	05000099	\N	FARIDA A.	SALABAN	male	255	bbb@bbb.com	\N	LUMANGKA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:46:12	30.00	210.00	2026-09-05 14:46:12	2026-08-28 12:45:05.017695	2026-09-05 07:05:38.338649
257	05000100	\N	DATU MAIDO P.	ABDULKADIL	male	256	bbb@bbb.com	\N	LUMANGKA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:46:40	30.00	210.00	2026-09-05 14:46:40	2026-08-28 12:45:05.01884	2026-09-05 07:05:38.338649
258	05000101	\N	SANDATO B.	LAMALAN	male	257	bbb@bbb.com	\N	LUMANGKA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:47:09	30.00	210.00	2026-09-05 14:47:09	2026-08-28 12:45:05.019918	2026-09-05 07:05:38.338649
259	05000102	\N	NAMRA O.	LAGUIALAM	male	258	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:47:43	30.00	210.00	2026-09-05 14:47:43	2026-08-28 12:45:05.020996	2026-09-05 07:05:38.338649
260	05000103	\N	MAMA L.	OTOWAO	male	259	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:48:07	30.00	210.00	2026-09-05 14:48:07	2026-08-28 12:45:05.022081	2026-09-05 07:05:38.338649
261	05000104	\N	RAIHANA P.	LANGGOYUAN	male	260	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:48:31	30.00	210.00	2026-09-05 14:48:31	2026-08-28 12:45:05.023103	2026-09-05 07:05:38.338649
262	05000105	\N	AMERUDIN A.	DALID	male	261	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:48:57	30.00	210.00	2026-09-05 14:48:57	2026-08-28 12:45:05.024128	2026-09-05 07:05:38.338649
265	05000108	\N	AMILUDIN T.	SALILUAY	male	264	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:50:05	30.00	210.00	2026-09-05 14:50:05	2026-08-28 12:45:05.027627	2026-09-05 07:05:38.338649
267	05000110	\N	AKBAR G.	ADZAB	male	266	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:51:07	30.00	210.00	2026-09-05 14:51:07	2026-08-28 12:45:05.030564	2026-09-05 07:05:38.338649
268	05000111	\N	LATIP K.	LAGASAN	male	267	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 14:51:32	30.00	210.00	2026-09-05 14:51:32	2026-08-28 12:45:05.032299	2026-09-05 07:05:38.338649
371	05000214	\N	DURIAN P.	GUTIERREZ	male	370	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:01:16	30.00	210.00	2026-09-05 18:01:16	2026-08-28 12:45:05.165309	2026-09-05 10:12:13.027057
372	05000215	\N	ZAHRA A.	ANDAL	male	371	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:01:32	30.00	210.00	2026-09-05 18:01:32	2026-08-28 12:45:05.167398	2026-09-05 10:12:13.027057
373	05000216	\N	AMINA A.	LAMALAN	male	372	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:01:51	30.00	210.00	2026-09-05 18:01:51	2026-08-28 12:45:05.168848	2026-09-05 10:12:13.027057
374	05000217	\N	AISA A.	LAMALAN	male	373	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:02:13	30.00	210.00	2026-09-05 18:02:13	2026-08-28 12:45:05.170129	2026-09-05 10:12:13.027057
375	05000218	\N	JAMER G.	LAMALAN	male	374	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:02:36	30.00	210.00	2026-09-05 18:02:36	2026-08-28 12:45:05.171218	2026-09-05 10:12:13.027057
376	05000219	\N	ABDULLAH M.	SALI	male	375	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:02:52	30.00	210.00	2026-09-05 18:02:52	2026-08-28 12:45:05.172311	2026-09-05 10:12:13.027057
377	05000220	\N	SAPIA M.	ADAM	male	376	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:03:11	30.00	210.00	2026-09-05 18:03:11	2026-08-28 12:45:05.173388	2026-09-05 10:12:13.027057
378	05000221	\N	NENGKO A.	DANDUA	male	377	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:03:35	30.00	210.00	2026-09-05 18:03:35	2026-08-28 12:45:05.174473	2026-09-05 10:12:13.027057
379	05000222	\N	ESMAEL T.	ABAD	male	378	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:03:51	30.00	210.00	2026-09-05 18:03:51	2026-08-28 12:45:05.175567	2026-09-05 10:12:13.027057
380	05000223	\N	BASHER U.	MALANIAN	male	379	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:04:10	30.00	210.00	2026-09-05 18:04:10	2026-08-28 12:45:05.176619	2026-09-05 10:12:13.027057
381	05000224	\N	LANIEBAI G.	HASSAN	male	380	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:04:29	30.00	210.00	2026-09-05 18:04:29	2026-08-28 12:45:05.177667	2026-09-05 10:12:13.027057
382	05000225	\N	TAHIRA A.	DANDUA	male	381	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:04:48	30.00	210.00	2026-09-05 18:04:48	2026-08-28 12:45:05.178896	2026-09-05 10:12:13.027057
383	05000226	\N	MOGIANG T.	MOTALIB	male	382	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:05:08	30.00	210.00	2026-09-05 18:05:08	2026-08-28 12:45:05.180703	2026-09-05 10:12:13.027057
384	05000227	\N	MAKABUAT G.	SUMINSIL	male	383	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:05:31	30.00	210.00	2026-09-05 18:05:31	2026-08-28 12:45:05.182474	2026-09-05 10:12:13.027057
385	05000228	\N	ABDULNASSER M.	GUILMO	male	384	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:05:55	30.00	210.00	2026-09-05 18:05:55	2026-08-28 12:45:05.184191	2026-09-05 10:12:13.027057
386	05000229	\N	EBRAHIM Z.	BAKULUDAN	male	385	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:06:15	30.00	210.00	2026-09-05 18:06:15	2026-08-28 12:45:05.185369	2026-09-05 10:12:13.027057
232	05000075	\N	NORODIN M.	MANION	male	231	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 21:11:03	30.00	210.00	2026-09-05 21:11:03	2026-08-28 12:45:04.98872	2026-09-05 13:13:54.246694
233	05000076	\N	TAMPA B.	ADAM	male	232	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 21:07:30	30.00	210.00	2026-09-05 21:07:30	2026-08-28 12:45:04.989823	2026-09-05 13:13:54.246694
234	05000077	\N	NORZAMIN B.	ADAM	male	233	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 21:08:06	30.00	210.00	2026-09-05 21:08:06	2026-08-28 12:45:04.990932	2026-09-05 13:13:54.246694
241	05000084	\N	NORALYN P.	SOLAIMAN	male	240	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 21:09:14	30.00	210.00	2026-09-05 21:09:14	2026-08-28 12:45:05.000206	2026-09-05 13:13:54.246694
242	05000085	\N	BASKO M.	MACAGBA	male	241	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 21:10:06	30.00	210.00	2026-09-05 21:10:06	2026-08-28 12:45:05.001315	2026-09-05 13:13:54.246694
302	05000145	\N	JOSIE B.	SIGUA	male	301	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:22:01	30.00	210.00	2026-09-05 15:22:01	2026-08-28 12:45:05.073889	2026-09-05 09:47:49.427465
303	05000146	\N	SITTE S.	GUIAMAT	male	302	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:22:57	30.00	210.00	2026-09-05 15:22:57	2026-08-28 12:45:05.07497	2026-09-05 09:47:49.427465
304	05000147	\N	ERAP S.	GUIAMAT	male	303	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:23:19	30.00	210.00	2026-09-05 15:23:19	2026-08-28 12:45:05.076137	2026-09-05 09:47:49.427465
305	05000148	\N	FARIDA M.	MENDIT	male	304	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:23:40	30.00	210.00	2026-09-05 15:23:40	2026-08-28 12:45:05.077362	2026-09-05 09:47:49.427465
306	05000149	\N	ZAINA A.	ALAM	male	305	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:24:03	30.00	210.00	2026-09-05 15:24:03	2026-08-28 12:45:05.078654	2026-09-05 09:47:49.427465
307	05000150	\N	MEGA H.	TUMANONG	male	306	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:24:21	30.00	210.00	2026-09-05 15:24:21	2026-08-28 12:45:05.080498	2026-09-05 09:47:49.427465
308	05000151	\N	TAONDO B.	BARAGEL	male	307	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:24:42	30.00	210.00	2026-09-05 15:24:42	2026-08-28 12:45:05.0829	2026-09-05 09:47:49.427465
309	05000152	\N	MULOD B.	KUMBO	male	308	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:25:05	30.00	210.00	2026-09-05 15:25:05	2026-08-28 12:45:05.084351	2026-09-05 09:47:49.427465
310	05000153	\N	KILAGA B.	KUMBO	male	309	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:25:21	30.00	210.00	2026-09-05 15:25:21	2026-08-28 12:45:05.085629	2026-09-05 09:47:49.427465
311	05000154	\N	KADATUAN M.	TILONA	male	310	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:25:42	30.00	210.00	2026-09-05 15:25:42	2026-08-28 12:45:05.086898	2026-09-05 09:47:49.427465
312	05000155	\N	ANNIE B.	ABDULKADIL	male	311	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:26:08	30.00	210.00	2026-09-05 15:26:08	2026-08-28 12:45:05.088407	2026-09-05 09:47:49.427465
313	05000156	\N	ABIBA E.	SALANGANAN	male	312	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:27:00	30.00	210.00	2026-09-05 15:27:00	2026-08-28 12:45:05.090086	2026-09-05 09:47:49.427465
314	05000157	\N	NORAIDA T.	ANDATUAN	male	313	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 15:28:22	30.00	210.00	2026-09-05 15:28:22	2026-08-28 12:45:05.091339	2026-09-05 09:47:49.427465
315	05000158	\N	KARAB A.	LUGEM	male	314	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:24:31	30.00	210.00	2026-09-05 17:24:31	2026-08-28 12:45:05.092469	2026-09-05 09:47:49.427465
316	05000159	\N	SALIMUDIN A.	SALILAMA	male	315	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:25:15	30.00	210.00	2026-09-05 17:25:15	2026-08-28 12:45:05.093647	2026-09-05 09:47:49.427465
317	05000160	\N	KATUWA M.	BULINGKEG	male	316	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:25:54	30.00	210.00	2026-09-05 17:25:54	2026-08-28 12:45:05.094852	2026-09-05 09:47:49.427465
318	05000161	\N	PENDI S.	LANGGOYUAN	male	317	bbb@bbb.com	\N	SALAKOP,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:27:05	30.00	210.00	2026-09-05 17:27:05	2026-08-28 12:45:05.096168	2026-09-05 09:47:49.427465
278	05000121	\N	ANISA P.	LAMALAN	male	277	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:16:23	30.00	210.00	2026-09-05 18:16:23	2026-08-28 12:45:05.043744	2026-09-05 10:18:26.088465
279	05000122	\N	ELOT M.	LAMALAN	male	278	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:16:08	30.00	210.00	2026-09-05 18:16:08	2026-08-28 12:45:05.044787	2026-09-05 10:18:26.088465
281	05000124	\N	SULAIMAN B.	LAMALAN	male	280	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:15:52	30.00	210.00	2026-09-05 18:15:52	2026-08-28 12:45:05.047916	2026-09-05 10:18:26.088465
283	05000126	\N	NORALIZA P.	LAMALAN	male	282	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:15:31	30.00	210.00	2026-09-05 18:15:31	2026-08-28 12:45:05.050753	2026-09-05 10:18:26.088465
285	05000128	\N	TIYA M.	ABUBAKAR	male	284	bbb@bbb.com	\N	PROPER,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:14:49	30.00	210.00	2026-09-05 18:14:49	2026-08-28 12:45:05.052997	2026-09-05 10:18:26.088465
292	05000135	\N	TIYA M. EDIT	ABUBAKAR	male	291	bbb@bbb.com	\N	PROPER,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:15:12	30.00	210.00	2026-09-05 18:15:12	2026-08-28 12:45:05.060615	2026-09-05 10:18:26.088465
348	05000191	\N	DALIS B.	MANALINDING	male	347	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:49:26	30.00	210.00	2026-09-05 17:49:26	2026-08-28 12:45:05.135756	2026-09-05 09:49:46.150829
352	05000195	\N	SOLAIMAN U.	MALANIAN	male	351	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:53:44	30.00	210.00	2026-09-05 17:53:44	2026-08-28 12:45:05.14044	2026-09-05 10:12:13.027057
353	05000196	\N	SAMSUDIN S.	PEDRO	male	352	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:54:10	30.00	210.00	2026-09-05 17:54:10	2026-08-28 12:45:05.141495	2026-09-05 10:12:13.027057
354	05000197	\N	BERT P.	MANALINDING	male	353	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:54:40	30.00	210.00	2026-09-05 17:54:40	2026-08-28 12:45:05.142599	2026-09-05 10:12:13.027057
355	05000198	\N	GARY K.	SALABAN	male	354	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:55:09	30.00	210.00	2026-09-05 17:55:09	2026-08-28 12:45:05.143658	2026-09-05 10:12:13.027057
356	05000199	\N	NORHAMIN B.	PANDAPATAN	male	355	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:55:34	30.00	210.00	2026-09-05 17:55:34	2026-08-28 12:45:05.144699	2026-09-05 10:12:13.027057
357	05000200	\N	NORAIN U.	MALANIAN	male	356	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:56:17	30.00	210.00	2026-09-05 17:56:17	2026-08-28 12:45:05.145993	2026-09-05 10:12:13.027057
358	05000201	\N	BADRUDIN U.	MOHAMAD	male	357	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:56:38	30.00	210.00	2026-09-05 17:56:38	2026-08-28 12:45:05.147604	2026-09-05 10:12:13.027057
359	05000202	\N	NORHAN K.	BUALAN	male	358	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:57:25	30.00	210.00	2026-09-05 17:57:25	2026-08-28 12:45:05.149218	2026-09-05 10:12:13.027057
360	05000203	\N	ABDULBASIT M.	BUALAN	male	359	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:57:46	30.00	210.00	2026-09-05 17:57:46	2026-08-28 12:45:05.151097	2026-09-05 10:12:13.027057
361	05000204	\N	BEBENTON K.	BUALAN	male	360	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:58:11	30.00	210.00	2026-09-05 17:58:11	2026-08-28 12:45:05.152963	2026-09-05 10:12:13.027057
362	05000205	\N	AMERODIN M.	BUALAN	male	361	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:58:30	30.00	210.00	2026-09-05 17:58:30	2026-08-28 12:45:05.154143	2026-09-05 10:12:13.027057
363	05000206	\N	DALAIDA S.	ALOGAO	male	362	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:58:49	30.00	210.00	2026-09-05 17:58:49	2026-08-28 12:45:05.155292	2026-09-05 10:12:13.027057
364	05000207	\N	LANDONI M.	SUMAKIL	male	363	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:59:08	30.00	210.00	2026-09-05 17:59:08	2026-08-28 12:45:05.156438	2026-09-05 10:12:13.027057
365	05000208	\N	MANGUTIN B.	DALANDAS	male	364	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:59:29	30.00	210.00	2026-09-05 17:59:29	2026-08-28 12:45:05.157632	2026-09-05 10:12:13.027057
366	05000209	\N	RAHIB M.	KASIM	male	365	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 17:59:46	30.00	210.00	2026-09-05 17:59:46	2026-08-28 12:45:05.15905	2026-09-05 10:12:13.027057
367	05000210	\N	KATIGUIA M	BISALAO	male	366	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:00:04	30.00	210.00	2026-09-05 18:00:04	2026-08-28 12:45:05.160139	2026-09-05 10:12:13.027057
402	07000001	\N	BENNY C.	CABAYA	male	401	CCC@CCC.COM	\N	PUROK 1,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.121704	2026-08-28 13:14:53.079296
403	07000002	\N	NOEH C.	FORTUNA	male	402	CCC@CCC.COM	\N	PUROK 1,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.125236	2026-08-28 13:14:53.079296
404	07000003	\N	GERALDINE C.	CALAWIGAN	male	403	CCC@CCC.COM	\N	PUROK 1A,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.126857	2026-08-28 13:14:53.079296
405	07000004	\N	JOCELL T.	CALAMBRO	male	404	CCC@CCC.COM	\N	PUROK 1A,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.128228	2026-08-28 13:14:53.079296
406	07000005	\N	PETER C.	PLAMERAN	male	405	CCC@CCC.COM	\N	PUROK 1A,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.12997	2026-08-28 13:14:53.079296
407	07000006	\N	ROSELYN A.	CAMARON	male	406	CCC@CCC.COM	\N	PUROK 2,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.134006	2026-08-28 13:14:53.079296
408	07000007	\N	HAGEO C.	CALIBAYAN	male	407	CCC@CCC.COM	\N	PUROK 2,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.136478	2026-08-28 13:14:53.079296
409	07000008	\N	ESMAEL P.	MANDIG	male	408	CCC@CCC.COM	\N	PUROK 3,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.140633	2026-08-28 13:14:53.079296
410	07000009	\N	AMERA M.	MANSAO	male	409	CCC@CCC.COM	\N	PUROK 4A ,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.142809	2026-08-28 13:14:53.079296
411	07000010	\N	HASNA A.	TALIB	male	410	CCC@CCC.COM	\N	PUROK 4A ,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.145026	2026-08-28 13:14:53.079296
412	07000011	\N	AMINA P.	ADAM	male	411	CCC@CCC.COM	\N	PUROK 4A ,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.147304	2026-08-28 13:14:53.079296
413	07000012	\N	BASSER M.	LAGANDANG	male	412	CCC@CCC.COM	\N	PUROK 4A ,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.151744	2026-08-28 13:14:53.079296
398	05000241	\N	BADRODIN S.	SANGKENAN	male	397	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:13:08	30.00	210.00	2026-09-05 18:13:08	2026-08-28 12:45:05.20187	2026-09-05 10:13:12.777824
414	07000013	\N	MUJAHIDEN P.	TUMANONG	male	413	CCC@CCC.COM	\N	PUROK 4A ,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.155225	2026-08-28 13:14:53.079296
415	07000014	\N	MAISALAM A.	PIGCAULAN	male	414	CCC@CCC.COM	\N	PUROK 4A ,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.157451	2026-08-28 13:14:53.079296
416	07000015	\N	ANTONINO K.	BARAGER	male	415	CCC@CCC.COM	\N	PUROK 4A ,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.158931	2026-08-28 13:14:53.079296
417	07000016	\N	DAURIN S.	BARAGUIR	male	416	CCC@CCC.COM	\N	PUROK 4A ,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.160473	2026-08-28 13:14:53.079296
418	07000017	\N	NASSER T.	ALILAYA	male	417	CCC@CCC.COM	\N	PUROK 4A ,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.16256	2026-08-28 13:14:53.079296
419	07000018	\N	PUASA T.	ALILAYA	male	418	CCC@CCC.COM	\N	PUROK 4A ,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.164822	2026-08-28 13:14:53.079296
420	07000019	\N	ZORAINI S.	ESMAEL	male	419	CCC@CCC.COM	\N	PUROK 4A ,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.168864	2026-08-28 13:14:53.079296
421	07000020	\N	MUSLIMEN G.	PIGCAULAN	male	420	CCC@CCC.COM	\N	PUROK 4A ,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.171821	2026-08-28 13:14:53.079296
422	07000021	\N	FARIDA A.	PIGCAULAN	male	421	CCC@CCC.COM	\N	PUROK 4A ,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.173339	2026-08-28 13:14:53.079296
423	07000022	\N	MOSMERA G.	PIGCAULAN	male	422	CCC@CCC.COM	\N	PUROK 4A ,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.174694	2026-08-28 13:14:53.079296
424	07000023	\N	ALIMODEN D.	KASAN	male	423	CCC@CCC.COM	\N	PUROK 4A ,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.175979	2026-08-28 13:14:53.079296
425	07000024	\N	DATOALI K.	BARAGUER	male	424	CCC@CCC.COM	\N	PUROK 4A ,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.177214	2026-08-28 13:14:53.079296
426	07000025	\N	SADIYA M.	GUIAMAT	male	425	CCC@CCC.COM	\N	PUROK 4B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.178455	2026-08-28 13:14:53.079296
427	07000026	\N	KIPAD K.	BARAGUER	male	426	CCC@CCC.COM	\N	PUROK 4B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.17992	2026-08-28 13:14:53.079296
428	07000027	\N	MELINDO P.	GUIANIB	male	427	CCC@CCC.COM	\N	PUROK 4B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.18365	2026-08-28 13:14:53.079296
429	07000028	\N	SAMIDEN Z.	TAMBUKO	male	428	CCC@CCC.COM	\N	PUROK 4B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.186013	2026-08-28 13:14:53.079296
430	07000029	\N	WAHIDA A.	TAMBUKO	male	429	CCC@CCC.COM	\N	PUROK 4B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.188016	2026-08-28 13:14:53.079296
431	07000030	\N	MIA A.	USMAN	male	430	CCC@CCC.COM	\N	PUROK 4B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.189454	2026-08-28 13:14:53.079296
432	07000031	\N	LUMANDA B.	BARAGIL	male	431	CCC@CCC.COM	\N	PUROK 4B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.190698	2026-08-28 13:14:53.079296
433	07000032	\N	ANISA T.	BALABAGAN	male	432	CCC@CCC.COM	\N	PUROK 4B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.191859	2026-08-28 13:14:53.079296
434	07000033	\N	ZUHOROP P.	LANGEBAN	male	433	CCC@CCC.COM	\N	PUROK 4B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.193168	2026-08-28 13:14:53.079296
435	07000034	\N	nan	MINALANG KUNDANG	male	434	CCC@CCC.COM	\N	PUROK 4B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.195509	2026-08-28 13:14:53.079296
436	07000035	\N	NORMA S.	BAKAN	male	435	CCC@CCC.COM	\N	PUROK 4B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.197764	2026-08-28 13:14:53.079296
437	07000036	\N	PASCUAL P.	MINALAG	male	436	CCC@CCC.COM	\N	PUROK 4B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.201116	2026-08-28 13:14:53.079296
438	07000037	\N	NORODIN G.	BACAN	male	437	CCC@CCC.COM	\N	PUROK 4B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.203585	2026-08-28 13:14:53.079296
439	07000038	\N	LAGIAB B.	BAGLED	male	438	CCC@CCC.COM	\N	PUROK 5A,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.204901	2026-08-28 13:14:53.079296
440	07000039	\N	MAKASIKOT P.	ZALIKA	male	439	CCC@CCC.COM	\N	PUROK 5A,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.206138	2026-08-28 13:14:53.079296
441	07000040	\N	OMRAN A.	PANDALAT	male	440	CCC@CCC.COM	\N	PUROK 5A,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.207389	2026-08-28 13:14:53.079296
442	07000041	\N	ALKOBAR I.	MALIDAS	male	441	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.208681	2026-08-28 13:14:53.079296
443	07000042	\N	ULAY A.	KANAKAN	male	442	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.210035	2026-08-28 13:14:53.079296
444	07000043	\N	KALID D.	KAYUN	male	443	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.211239	2026-08-28 13:14:53.079296
445	07000044	\N	HASMEN L.	KASULUTAN	male	444	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.212355	2026-08-28 13:14:53.079296
446	07000045	\N	MENSO K.	MAETEM	male	445	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.213681	2026-08-28 13:14:53.079296
447	07000046	\N	MOLAIDA S.	PANDITA	male	446	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.215712	2026-08-28 13:14:53.079296
448	07000047	\N	MAOTI P.	KADATOAN	male	447	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.217642	2026-08-28 13:14:53.079296
449	07000048	\N	LANDAYAN K.	ABDULKAREEM	male	448	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.219698	2026-08-28 13:14:53.079296
450	07000049	\N	SARIDAH A.	GINTWAN	male	449	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.221186	2026-08-28 13:14:53.079296
451	07000050	\N	ALEX C.	PANDITA	male	450	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.222332	2026-08-28 13:14:53.079296
452	07000051	\N	TATO B.	SANGGILNA	male	451	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.223565	2026-08-28 13:14:53.079296
453	07000052	\N	PETA P.	LIDASAN	male	452	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.224727	2026-08-28 13:14:53.079296
454	07000053	\N	AMINA M.	MALIDAS	male	453	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.225862	2026-08-28 13:14:53.079296
455	07000054	\N	MAKMOD M.	SANGKUPAN	male	454	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.226965	2026-08-28 13:14:53.079296
456	07000055	\N	MUSA M.	PANDITA	male	455	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.228072	2026-08-28 13:14:53.079296
457	07000056	\N	TONTO GU.	BANAG	male	456	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.229173	2026-08-28 13:14:53.079296
458	07000057	\N	FATIMA A.	TUMAGANTANG	male	457	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.230654	2026-08-28 13:14:53.079296
459	07000058	\N	POGE A.	SULAEMAN	male	458	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.23328	2026-08-28 13:14:53.079296
460	07000059	\N	LAGA M.	SANGKUPAN	male	459	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.235883	2026-08-28 13:14:53.079296
461	07000060	\N	TOKS M.	KIMBA	male	460	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.237289	2026-08-28 13:14:53.079296
462	07000061	\N	SARAH D.	SANGKUPAN	male	461	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.238646	2026-08-28 13:14:53.079296
463	07000062	\N	JHALIMEN T.	SALIPADA	male	462	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.239791	2026-08-28 13:14:53.079296
464	07000063	\N	BADRODEN G.	ADAL	male	463	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.240867	2026-08-28 13:14:53.079296
465	07000064	\N	TAMBUNGAN A.	GUIANON	male	464	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.241927	2026-08-28 13:14:53.079296
466	07000065	\N	KUNDATO K.	LIDASAN	male	465	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.242978	2026-08-28 13:14:53.079296
467	07000066	\N	COSME G.	MAMASALAT	male	466	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.243987	2026-08-28 13:14:53.079296
468	07000067	\N	BAYAN G.	SAMBALI	male	467	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.245051	2026-08-28 13:14:53.079296
469	07000068	\N	MUSIB M.	LANGGUKAN	male	468	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.246348	2026-08-28 13:14:53.079296
470	07000069	\N	SAPIELAN L.	SALAMAT	male	469	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.248264	2026-08-28 13:14:53.079296
471	07000070	\N	DATOALI P.	MAMALIMBA	male	470	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.249608	2026-08-28 13:14:53.079296
472	07000071	\N	HASMIN U.	TALIB	male	471	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.251118	2026-08-28 13:14:53.079296
473	07000072	\N	AMINA M.	BANGKONIAN	male	472	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.252851	2026-08-28 13:14:53.079296
474	07000073	\N	NORIA S.	ABDUL	male	473	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.254145	2026-08-28 13:14:53.079296
475	07000074	\N	BADRODEN B.	SANGILNA	male	474	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.255259	2026-08-28 13:14:53.079296
476	07000075	\N	SAIDE M.	SANGKUPAN	male	475	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.256333	2026-08-28 13:14:53.079296
477	07000076	\N	ALADIN S.	SANGGILDA	male	476	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.257357	2026-08-28 13:14:53.079296
478	07000077	\N	TOKS D.	MAETEM	male	477	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.258452	2026-08-28 13:14:53.079296
479	07000078	\N	MUTALIB M.	MALIDAS	male	478	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.259512	2026-08-28 13:14:53.079296
480	07000079	\N	NANO M.	MALIDAS	male	479	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.260592	2026-08-28 13:14:53.079296
481	07000080	\N	GUIAPAL M.	LINDAN	male	480	CCC@CCC.COM	\N	PUROK 5B,MALAPANG,ALEOSAN	7	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-28 13:14:53.261662	2026-08-28 13:14:53.079296
482	09000001	\N	BINONG S.	ENIDAL	male	481	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.032895	2026-08-31 01:21:59.803535
483	09000002	\N	JAHER S.	SULTAN	male	482	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.041751	2026-08-31 01:21:59.803535
484	09000003	\N	ABRAHAM M.	AMAN	male	483	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.044809	2026-08-31 01:21:59.803535
485	09000004	\N	GADS M.	MALA	male	484	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.046173	2026-08-31 01:21:59.803535
486	09000005	\N	AKRIMA S.	TALITAY	male	485	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.047414	2026-08-31 01:21:59.803535
487	09000006	\N	ARJIE C.	BALAYANAN	male	486	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.049839	2026-08-31 01:21:59.803535
488	09000007	\N	RONNIE L.	SULTAN	male	487	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.051636	2026-08-31 01:21:59.803535
489	09000008	\N	TABOYA P.	KASAN	male	488	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.052855	2026-08-31 01:21:59.803535
490	09000009	\N	DATU JHON K.	SULTAN	male	489	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.054629	2026-08-31 01:21:59.803535
491	09000010	\N	GORNDON L.	SULTAN	male	490	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.059386	2026-08-31 01:21:59.803535
492	09000011	\N	NASRIA D.	WAHAB	male	491	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.063629	2026-08-31 01:21:59.803535
493	09000012	\N	NORAISA L.	ABDULKARIM	male	492	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.065311	2026-08-31 01:21:59.803535
494	09000013	\N	BAINITA L.	SULTAN	male	493	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.067175	2026-08-31 01:21:59.803535
495	09000014	\N	SANDRA S.	DALAMBAN	male	494	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.068393	2026-08-31 01:21:59.803535
496	09000015	\N	KALID Y.	TATO	male	495	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.069951	2026-08-31 01:21:59.803535
497	09000016	\N	JUBAIKA M.	WAHAB	male	496	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.071195	2026-08-31 01:21:59.803535
498	09000017	\N	DATU KING K.	SULTAN	male	497	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.072528	2026-08-31 01:21:59.803535
499	09000018	\N	SAMMY L.	SULTAN	male	498	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.074554	2026-08-31 01:21:59.803535
500	09000019	\N	GUIAMIPA G.	KADING	male	499	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.077582	2026-08-31 01:21:59.803535
501	09000020	\N	DATU ALI L.	SULTAN	male	500	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.078908	2026-08-31 01:21:59.803535
502	09000021	\N	MONIB B.	MOKAMAD	male	501	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.080065	2026-08-31 01:21:59.803535
503	09000022	\N	JOHANA E.	SULTAN	male	502	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.081238	2026-08-31 01:21:59.803535
504	09000023	\N	JOMAR E.	SULTAN	male	503	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.082391	2026-08-31 01:21:59.803535
505	09000024	\N	ALIX K.	KASAN	male	504	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.083446	2026-08-31 01:21:59.803535
506	09000025	\N	SITTIE W.	MUSA	male	505	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.085923	2026-08-31 01:21:59.803535
507	09000026	\N	SAMERA D.	SULTAN	male	506	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.087018	2026-08-31 01:21:59.803535
508	09000027	\N	ZAIJAN S.	SULTAN	male	507	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.0881	2026-08-31 01:21:59.803535
509	09000028	\N	HARRIS M.	LIBUNGAN	male	508	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.089535	2026-08-31 01:21:59.803535
510	09000029	\N	MOJAHED L.	USMAN	male	509	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.092261	2026-08-31 01:21:59.803535
511	09000030	\N	SOL L.	PAMASAG	male	510	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.093973	2026-08-31 01:21:59.803535
512	09000031	\N	BADDY L.	PAMANSAG	male	511	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.095932	2026-08-31 01:21:59.803535
513	09000032	\N	JUNALYN P.	PAMANSAG	male	512	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.097278	2026-08-31 01:21:59.803535
514	09000033	\N	RAHIM U.	MALANIAN	male	513	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.098667	2026-08-31 01:21:59.803535
515	09000034	\N	LAMERA D.	SAMBULAWAN	male	514	ccc@ccc.com	\N	ALENG, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.100186	2026-08-31 01:21:59.803535
516	09000035	\N	NORMA T.	MAMASALIDO	male	515	ccc@ccc.com	\N	GADUNGAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.102927	2026-08-31 01:21:59.803535
517	09000036	\N	NAREX M.	TAUP	male	516	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.104144	2026-08-31 01:21:59.803535
518	09000037	\N	TAYA D.	TALITAY	male	517	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.105308	2026-08-31 01:21:59.803535
519	09000038	\N	LAGA T.	MUSA	male	518	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.107415	2026-08-31 01:21:59.803535
520	09000039	\N	NASSER A.	PANDULO	male	519	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.109368	2026-08-31 01:21:59.803535
521	09000040	\N	HALIMA M.	BANTAYAN	male	520	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.110762	2026-08-31 01:21:59.803535
522	09000041	\N	SAPIA M.	DELANGALEN	male	521	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.111912	2026-08-31 01:21:59.803535
523	09000042	\N	MAMA G.	SULTAN	male	522	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.113222	2026-08-31 01:21:59.803535
524	09000043	\N	ZAHRA A.	SOLAIMAN	male	523	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.114321	2026-08-31 01:21:59.803535
525	09000044	\N	SUKARNO B.	MASIL	male	524	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.116256	2026-08-31 01:21:59.803535
526	09000045	\N	KATIGUIA K.	BANDILA	male	525	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.117397	2026-08-31 01:21:59.803535
527	09000046	\N	KUSAIN B.	MASIL	male	526	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.118469	2026-08-31 01:21:59.803535
528	09000047	\N	MUSA D.	TALITAY	male	527	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.11949	2026-08-31 01:21:59.803535
529	09000048	\N	BASSER K.	ABDUL	male	528	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.120626	2026-08-31 01:21:59.803535
530	09000049	\N	SAMRA N.	BUTUAN	male	529	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.121806	2026-08-31 01:21:59.803535
531	09000050	\N	MUSALLAM D.	DATUGAN	male	530	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.123882	2026-08-31 01:21:59.803535
532	09000051	\N	EBRAHIM K.	ABDUL	male	531	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.126078	2026-08-31 01:21:59.803535
533	09000052	\N	BAILANIE A.	KALIBAY	male	532	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.127278	2026-08-31 01:21:59.803535
534	09000053	\N	KONIYAG U.	SANSAWI	male	533	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.128342	2026-08-31 01:21:59.803535
535	09000054	\N	KAMIRON T.	GUIALOSON	male	534	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.129472	2026-08-31 01:21:59.803535
536	09000055	\N	ROBELYN M.	MACAALAY	male	535	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.13134	2026-08-31 01:21:59.803535
537	09000056	\N	NORIA M.	SULTAN	male	536	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.134098	2026-08-31 01:21:59.803535
538	09000057	\N	SOBAITON D.	TALITAY	male	537	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.135508	2026-08-31 01:21:59.803535
539	09000058	\N	ZENAIDA G	MALAO	male	538	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.136774	2026-08-31 01:21:59.803535
540	09000059	\N	ABDULATIP S.	MALAO	male	539	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.13796	2026-08-31 01:21:59.803535
541	09000060	\N	SAMRAH P.	KONIYAG	male	540	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.139585	2026-08-31 01:21:59.803535
542	09000061	\N	BUAGAS	BUNGKALIS	male	541	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.141962	2026-08-31 01:21:59.803535
543	09000062	\N	EBRAHEM B.	SULTAN	male	542	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.144086	2026-08-31 01:21:59.803535
544	09000063	\N	PATENA Y.	MAMADRA	male	543	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.145374	2026-08-31 01:21:59.803535
545	09000064	\N	YUSOPH B.	MAKATIMBEL	male	544	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.146509	2026-08-31 01:21:59.803535
546	09000065	\N	ALMERA K.	ADTA	male	545	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.147608	2026-08-31 01:21:59.803535
547	09000066	\N	MOHAMED P.	GALO	male	546	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.148759	2026-08-31 01:21:59.803535
548	09000067	\N	ABDULLAH G.	MANDAGUIA	male	547	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.149964	2026-08-31 01:21:59.803535
549	09000068	\N	ALI B.	MAKATIMBEL	male	548	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.151842	2026-08-31 01:21:59.803535
550	09000069	\N	FAHIMA M.	MASIL	male	549	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.153057	2026-08-31 01:21:59.803535
551	09000070	\N	NASSER L.	ABDULKARIM	male	550	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.154304	2026-08-31 01:21:59.803535
552	09000071	\N	BADDY M.	LIBUNGAN	male	551	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.15538	2026-08-31 01:21:59.803535
553	09000072	\N	JHOMAR K.	MAMASABULOD	male	552	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.157501	2026-08-31 01:21:59.803535
554	09000073	\N	ANGELYN K.	APLAL	male	553	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.16299	2026-08-31 01:21:59.803535
555	09000074	\N	ONTO D.	WAGIA	male	554	ccc@ccc.com	\N	KABABAAN, BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.164366	2026-08-31 01:21:59.803535
556	09000075	\N	RAHMIYA D.	PANGAKO	male	555	ccc@ccc.com	\N	LULISAN,BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.165544	2026-08-31 01:21:59.803535
557	09000076	\N	NADJI P.	ENGED	male	556	ccc@ccc.com	\N	LULISAN,BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.166716	2026-08-31 01:21:59.803535
558	09000077	\N	PONG P.	SALABAN	male	557	ccc@ccc.com	\N	LULISAN,BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.167855	2026-08-31 01:21:59.803535
559	09000078	\N	RHEX T.	LABAS	male	558	ccc@ccc.com	\N	LULISAN,BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.168966	2026-08-31 01:21:59.803535
560	09000079	\N	BUTO M.	TALITAY	male	559	ccc@ccc.com	\N	LULISAN,BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.170528	2026-08-31 01:21:59.803535
561	09000080	\N	RAHIB G.	PHILAS	male	560	ccc@ccc.com	\N	LULISAN,BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.171594	2026-08-31 01:21:59.803535
562	09000081	\N	BASCO P.	SANDAY	male	561	ccc@ccc.com	\N	LULISAN,BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.172914	2026-08-31 01:21:59.803535
563	09000082	\N	MARY B.	SANDAYAN	male	562	ccc@ccc.com	\N	LULISAN,BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.174853	2026-08-31 01:21:59.803535
564	09000083	\N	SAMSUDIN B.	SUGAGUIL	male	563	ccc@ccc.com	\N	LULISAN,BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.17667	2026-08-31 01:21:59.803535
565	09000084	\N	ANDREA I.	KADING	male	564	ccc@ccc.com	\N	PALAO,BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.178205	2026-08-31 01:21:59.803535
566	09000085	\N	MOHAMAD D.	SULAIK	male	565	ccc@ccc.com	\N	PALAO,BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.179509	2026-08-31 01:21:59.803535
567	09000086	\N	MOHAMAD M.	KADING	male	566	ccc@ccc.com	\N	PALAO,BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.180776	2026-08-31 01:21:59.803535
568	09000087	\N	KRISTINE T.	LABAS	male	567	ccc@ccc.com	\N	PALAO,BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.181999	2026-08-31 01:21:59.803535
569	09000088	\N	JAHMER I.	KADING	male	568	ccc@ccc.com	\N	PALAO,BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.183143	2026-08-31 01:21:59.803535
570	09000089	\N	KHEM B.	PANTAS	male	569	ccc@ccc.com	\N	PALAO,BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.184233	2026-08-31 01:21:59.803535
571	09000090	\N	SALABON M.	KADING	male	570	ccc@ccc.com	\N	PALAO,BALATICAN, PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.185271	2026-08-31 01:21:59.803535
572	09000091	\N	BOTS G.	ALI	male	571	ccc@ccc.com	\N	PROPER,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.18637	2026-08-31 01:21:59.803535
573	09000092	\N	JEFFREY M.	DAMATINGCAL	male	572	ccc@ccc.com	\N	PROPER,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.18737	2026-08-31 01:21:59.803535
574	09000093	\N	BAI LINANG S.	DALAMBAN	male	573	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.188377	2026-08-31 01:21:59.803535
575	09000094	\N	DAUMILING L.	PAMANSAG	male	574	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.19015	2026-08-31 01:21:59.803535
576	09000095	\N	NADZYA L.	MONTAWAL	male	575	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.192099	2026-08-31 01:21:59.803535
577	09000096	\N	ANIDA L.	PEDTUKASAN	male	576	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.193884	2026-08-31 01:21:59.803535
578	09000097	\N	MERIAM G.	BUTUAN	male	577	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.195004	2026-08-31 01:21:59.803535
579	09000098	\N	NORUDIN B.	ABUBAKAR	male	578	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.196093	2026-08-31 01:21:59.803535
580	09000099	\N	EDDIE L.	LINGGONA	male	579	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.19714	2026-08-31 01:21:59.803535
581	09000100	\N	JAMECA H.	BUTUAN	male	580	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.198155	2026-08-31 01:21:59.803535
582	09000101	\N	KABAISA S.	PANGAWILAN	male	581	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.199309	2026-08-31 01:21:59.803535
583	09000102	\N	LYKA MAE G.	MINDAL	male	582	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.200333	2026-08-31 01:21:59.803535
584	09000103	\N	BAIDIDO S.	ESDAGULA	male	583	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.201352	2026-08-31 01:21:59.803535
585	09000104	\N	TANUMBAI S.	SISON	male	584	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.203296	2026-08-31 01:21:59.803535
586	09000105	\N	MASTURA P.	ENSO	male	585	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.204405	2026-08-31 01:21:59.803535
587	09000106	\N	DATUALI G.	EBAD	male	586	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.205461	2026-08-31 01:21:59.803535
588	09000107	\N	GUIALISA L.	SALILAMA	male	587	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.207608	2026-08-31 01:21:59.803535
589	09000108	\N	MACARAEG P.	BUTUAN	male	588	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.209747	2026-08-31 01:21:59.803535
590	09000109	\N	MONIL S.	USMAN	male	589	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.210992	2026-08-31 01:21:59.803535
591	09000110	\N	KLAT T.	SAMBILAN	male	590	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.212194	2026-08-31 01:21:59.803535
592	09000111	\N	MOJAHED O.	PAMANSAG	male	591	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.213302	2026-08-31 01:21:59.803535
593	09000112	\N	MARATO P.	SIMA	male	592	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.214342	2026-08-31 01:21:59.803535
594	09000113	\N	ZUKARNO S.	GUIMA	male	593	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.215414	2026-08-31 01:21:59.803535
595	09000114	\N	MAMA D.	KALUDAN	male	594	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.216466	2026-08-31 01:21:59.803535
596	09000115	\N	MIKE M.	BACANA	male	595	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.217517	2026-08-31 01:21:59.803535
597	09000116	\N	BAILINANG B.	EBAD	male	596	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.21992	2026-08-31 01:21:59.803535
598	09000117	\N	NORHANA M.	SALILAMA	male	597	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.220979	2026-08-31 01:21:59.803535
599	09000118	\N	ZUKARNAIN G.	ZUMBAGA	male	598	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.222046	2026-08-31 01:21:59.803535
600	09000119	\N	ROSHELNA S.	KAMSA	male	599	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.224132	2026-08-31 01:21:59.803535
601	09000120	\N	SALUNGBAE S.	EBAD	male	600	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.226579	2026-08-31 01:21:59.803535
602	09000121	\N	LAGA M.	SULTAN	male	601	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.227925	2026-08-31 01:21:59.803535
603	09000122	\N	NATHANIEL S.	SISON	male	602	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.229158	2026-08-31 01:21:59.803535
604	09000123	\N	ABDULRADZAK S.	MACAALAY	male	603	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.230359	2026-08-31 01:21:59.803535
605	09000124	\N	NORIA M.	BUTUAN	male	604	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.231512	2026-08-31 01:21:59.803535
606	09000125	\N	MOHAMEDIN S.	ABDULBAYAN	male	605	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.232635	2026-08-31 01:21:59.803535
607	09000126	\N	BAINGAN M.	MACOL	male	606	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.23377	2026-08-31 01:21:59.803535
608	09000127	\N	MONISA M.	EBAD	male	607	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.234908	2026-08-31 01:21:59.803535
609	09000128	\N	SALAMIA T.	BUTUAN	male	608	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.237441	2026-08-31 01:21:59.803535
610	09000129	\N	EBRAHIM S.	EBAD	male	609	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.238494	2026-08-31 01:21:59.803535
611	09000130	\N	JALEL P.	KANACAN	male	610	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.241834	2026-08-31 01:21:59.803535
612	09000131	\N	RAMEL D.	KANACAN	male	611	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.244984	2026-08-31 01:21:59.803535
613	09000132	\N	ABDULRADZAK S.	BALUNO	male	612	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.246362	2026-08-31 01:21:59.803535
614	09000133	\N	ARNAL K.	TAMPIPI	male	613	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.247554	2026-08-31 01:21:59.803535
615	09000134	\N	EBRAHIM M.	AMULAN	male	614	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.248657	2026-08-31 01:21:59.803535
616	09000135	\N	ZAINAB A.	PAMANSAG	male	615	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.249874	2026-08-31 01:21:59.803535
617	09000136	\N	DUKILMAN A.	LUMANGGAL	male	616	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.251031	2026-08-31 01:21:59.803535
618	09000137	\N	USOP G.	AMOLAN	male	617	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.252076	2026-08-31 01:21:59.803535
619	09000138	\N	MERIAM M.	AMOLAN	male	618	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.25316	2026-08-31 01:21:59.803535
620	09000139	\N	ABDILA D.	ABAS	male	619	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.255019	2026-08-31 01:21:59.803535
621	09000140	\N	ROSANA D.	AMBULODAN	male	620	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.256645	2026-08-31 01:21:59.803535
622	09000141	\N	MUSA B.	MALLA	male	621	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.25867	2026-08-31 01:21:59.803535
623	09000142	\N	NORA L.	MALINA	male	622	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.260641	2026-08-31 01:21:59.803535
624	09000143	\N	TAAGA G.	SALAPUDIN	male	623	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.261973	2026-08-31 01:21:59.803535
625	09000144	\N	NORMIYAH S.	MACAALAY	male	624	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.263139	2026-08-31 01:21:59.803535
626	09000145	\N	ROMEL P.	SALILAMA	male	625	ccc@ccc.com	\N	PULAN-PULAN,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.264355	2026-08-31 01:21:59.803535
627	09000146	\N	GUIAPAL K.	SEMA	male	626	ccc@ccc.com	\N	QUARRY,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.265567	2026-08-31 01:21:59.803535
628	09000147	\N	MAMALANGKONG M.	MAMADRA	male	627	ccc@ccc.com	\N	QUARRY,BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.266661	2026-08-31 01:21:59.803535
629	09000148	\N	MIDSULBAN B.	DADTING	male	628	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.267706	2026-08-31 01:21:59.803535
630	09000149	\N	KANAKAN P.	BUKA	male	629	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.268837	2026-08-31 01:21:59.803535
631	09000150	\N	TATO M.	ANTIPOLO	male	630	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.269942	2026-08-31 01:21:59.803535
632	09000151	\N	NORHATA D.	MOLAO	male	631	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.271893	2026-08-31 01:21:59.803535
633	09000152	\N	DIDS P.	SALUD	male	632	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.273713	2026-08-31 01:21:59.803535
634	09000153	\N	NORJEHAD M.	BATEG	male	633	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.275589	2026-08-31 01:21:59.803535
635	09000154	\N	ABEL M.	MAGALUYAN	male	634	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.277174	2026-08-31 01:21:59.803535
636	09000155	\N	NHORHANA S.	ABDULKADIR	male	635	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.278331	2026-08-31 01:21:59.803535
637	09000156	\N	DATUKI S.	MALAN	male	636	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.279467	2026-08-31 01:21:59.803535
638	09000157	\N	MALAIDA P.	AGAO	male	637	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.280669	2026-08-31 01:21:59.803535
639	09000158	\N	FAISAL D.	MANAMPAN	male	638	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.281806	2026-08-31 01:21:59.803535
640	09000159	\N	BAIRONA C.	MOLAO	male	639	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.28288	2026-08-31 01:21:59.803535
641	09000160	\N	MONA P.	KAMANGON	male	640	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.284928	2026-08-31 01:21:59.803535
642	09000161	\N	ABDULRAHIM T.	KAMSA	male	641	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.286312	2026-08-31 01:21:59.803535
643	09000162	\N	ALINOR M.	KASIM	male	642	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.287507	2026-08-31 01:21:59.803535
644	09000163	\N	AHMAD B.	PENDINGAN	male	643	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.288726	2026-08-31 01:21:59.803535
645	09000164	\N	ABDULRASID P.	BUKA	male	644	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.290573	2026-08-31 01:21:59.803535
646	09000165	\N	MAMALINTA M.	SULTAN	male	645	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.292586	2026-08-31 01:21:59.803535
647	09000166	\N	ABDULKADIR S.	BUDSAGUIL	male	646	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.294026	2026-08-31 01:21:59.803535
648	09000167	\N	SARAH K.	SILONGAN	male	647	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.295272	2026-08-31 01:21:59.803535
649	09000168	\N	HASNA T.	MOLAO	male	648	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.296406	2026-08-31 01:21:59.803535
650	09000169	\N	LAHMUDIN A.	KAMODIA	male	649	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.297559	2026-08-31 01:21:59.803535
651	09000170	\N	NORHAMIN M.	BATEG	male	650	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.29869	2026-08-31 01:21:59.803535
652	09000171	\N	SAMSODIN K.	ABON	male	651	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.29979	2026-08-31 01:21:59.803535
653	09000172	\N	ADALOS R.	GUIAPLOS	male	652	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.301019	2026-08-31 01:21:59.803535
654	09000173	\N	SADAM K.	PANDULO	male	653	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.302329	2026-08-31 01:21:59.803535
655	09000174	\N	GULIDTEM K.	SIAWAN	male	654	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.303514	2026-08-31 01:21:59.803535
656	09000175	\N	ZUKARNO I.	MOLAO	male	655	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.304677	2026-08-31 01:21:59.803535
657	09000176	\N	MOHAMMAD B.	AGAO	male	656	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.307012	2026-08-31 01:21:59.803535
658	09000177	\N	ALI S.	BUDZAGUIL	male	657	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.309051	2026-08-31 01:21:59.803535
659	09000178	\N	BUTO A.	AGAW	male	658	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.310505	2026-08-31 01:21:59.803535
660	09000179	\N	BAINENA B.	MAKAALAY	male	659	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.311762	2026-08-31 01:21:59.803535
661	09000180	\N	MONERA K.	BUDSAGUIL	male	660	ccc@ccc.com	\N	TUKA NA ULS, BALATICAN,PIKIT	9	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:22:00.312978	2026-08-31 01:21:59.803535
662	11000001	\N	MARIAM T.	ABDUL	male	661	DDD@DDD.COM	\N	PUROK 1, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.39532	2026-08-31 01:42:44.349198
663	11000002	\N	NORGUIANA S.	MANGULAMAS	male	662	DDD@DDD.COM	\N	PUROK 1, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.403606	2026-08-31 01:42:44.349198
664	11000003	\N	NORMINA M.	MAKABANGEN	male	663	DDD@DDD.COM	\N	PUROK 1, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.406317	2026-08-31 01:42:44.349198
665	11000004	\N	ARBAYA M.	LUNDAYAN	male	664	DDD@DDD.COM	\N	PUROK 2, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.411106	2026-08-31 01:42:44.349198
666	11000005	\N	TOTO A.	MANTUYA	male	665	DDD@DDD.COM	\N	PUROK 2, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.415534	2026-08-31 01:42:44.349198
667	11000006	\N	MIN S.	ABUBAKAR	male	666	DDD@DDD.COM	\N	PUROK 2, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.4183	2026-08-31 01:42:44.349198
668	11000007	\N	SAUDI D.	EMBA	male	667	DDD@DDD.COM	\N	PUROK 2, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.420004	2026-08-31 01:42:44.349198
669	11000008	\N	MOHALIDIN T.	SABILOLA	male	668	DDD@DDD.COM	\N	PUROK 2, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.421569	2026-08-31 01:42:44.349198
670	11000009	\N	LABAIDA U.	DALID	male	669	DDD@DDD.COM	\N	PUROK 2, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.423029	2026-08-31 01:42:44.349198
671	11000010	\N	MALINGKO S.	ABUBAKAR	male	670	DDD@DDD.COM	\N	PUROK 2, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.424789	2026-08-31 01:42:44.349198
672	11000011	\N	AIDA A.	MANEDSEN	male	671	DDD@DDD.COM	\N	PUROK 2, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.427037	2026-08-31 01:42:44.349198
673	11000012	\N	SARAH D.	SULAO	male	672	DDD@DDD.COM	\N	PUROK 2, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.428599	2026-08-31 01:42:44.349198
674	11000013	\N	ANNIE A.	SALIK	male	673	DDD@DDD.COM	\N	PUROK 2, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.430486	2026-08-31 01:42:44.349198
675	11000014	\N	BAINAUT M.	MAKABAKEG	male	674	DDD@DDD.COM	\N	PUROK 2, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.431721	2026-08-31 01:42:44.349198
676	11000015	\N	BAILYN E.	BASIT	male	675	DDD@DDD.COM	\N	PUROK 2, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.432843	2026-08-31 01:42:44.349198
677	11000016	\N	JAIME D.	BASSIT	male	676	DDD@DDD.COM	\N	PUROK 2, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.434151	2026-08-31 01:42:44.349198
678	11000017	\N	TOKA M.	AGAO	male	677	DDD@DDD.COM	\N	PUROK 2, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.435373	2026-08-31 01:42:44.349198
679	11000018	\N	MANGOMPIS L.	ABUBAKAR	male	678	DDD@DDD.COM	\N	PUROK 2, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.436458	2026-08-31 01:42:44.349198
680	11000019	\N	MAMATANTO B.	MAKALMA	male	679	DDD@DDD.COM	\N	PUROK 2, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.43759	2026-08-31 01:42:44.349198
681	11000020	\N	DANNY M.	MASANDAG	male	680	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.438664	2026-08-31 01:42:44.349198
682	11000021	\N	RASID P.	OLYMPAIN	male	681	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.440043	2026-08-31 01:42:44.349198
683	11000022	\N	SAMBRA M.	ELYAS	male	682	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.442565	2026-08-31 01:42:44.349198
684	11000023	\N	SARAH S.	TADALUS	male	683	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.443894	2026-08-31 01:42:44.349198
685	11000024	\N	DODIN O.	MANDALAIT	male	684	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.445547	2026-08-31 01:42:44.349198
686	11000025	\N	SAHARA D.	OLYMPAIN	male	685	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.447714	2026-08-31 01:42:44.349198
687	11000026	\N	TALIB D.	MALON	male	686	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.448931	2026-08-31 01:42:44.349198
688	11000027	\N	NORMINA S.	LUCAS	male	687	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.450433	2026-08-31 01:42:44.349198
689	11000028	\N	FATIMA G.	LUCAS	male	688	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.451591	2026-08-31 01:42:44.349198
690	11000029	\N	JULHAMID M.	MASANDAG	male	689	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.452715	2026-08-31 01:42:44.349198
691	11000030	\N	ALONTO A.	ADIL	male	690	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.45394	2026-08-31 01:42:44.349198
692	11000031	\N	MONTASER M.	MASANDAG	male	691	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.455496	2026-08-31 01:42:44.349198
693	11000032	\N	MUHAMMAD S.	MANDALAIT	male	692	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.456847	2026-08-31 01:42:44.349198
694	11000033	\N	MARISSA S.	OLYMPAIN	male	693	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.458799	2026-08-31 01:42:44.349198
695	11000034	\N	SAPTULA A.	MACMOD	male	694	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.46084	2026-08-31 01:42:44.349198
696	11000035	\N	RASID S.	DALID	male	695	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.462894	2026-08-31 01:42:44.349198
697	11000036	\N	JOLHAIREN M.	MASANDAG	male	696	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.464194	2026-08-31 01:42:44.349198
698	11000037	\N	NORHAYNA O.	SAGER	male	697	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.46534	2026-08-31 01:42:44.349198
699	11000038	\N	ABDULBADY B.	SAGER	male	698	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.466432	2026-08-31 01:42:44.349198
700	11000039	\N	ABDULBAYAN D.	LUCAS	male	699	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.467534	2026-08-31 01:42:44.349198
701	11000040	\N	SAMMY E.	TADALOS	male	700	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.468659	2026-08-31 01:42:44.349198
702	11000041	\N	ABDULKARIM E.	NAWAL	male	701	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.469883	2026-08-31 01:42:44.349198
703	11000042	\N	ALADIN D.	SAGER	male	702	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.471294	2026-08-31 01:42:44.349198
704	11000043	\N	TAMANO S.	MASANDAG	male	703	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.472387	2026-08-31 01:42:44.349198
705	11000044	\N	NORMINA S.	MASANDAG	male	704	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.473892	2026-08-31 01:42:44.349198
706	11000045	\N	NORAIDA M.	MAMALANGKAY	male	705	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.475475	2026-08-31 01:42:44.349198
707	11000046	\N	YASSER U.	MAMALANGKAY	male	706	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.476848	2026-08-31 01:42:44.349198
708	11000047	\N	JON T.	BANSUAN	male	707	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.479849	2026-08-31 01:42:44.349198
709	11000048	\N	AMERUDIN M.	MASULOT	male	708	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.481201	2026-08-31 01:42:44.349198
710	11000049	\N	MOSARAP G.	MASANDAG	male	709	DDD@DDD.COM	\N	PUROK 3, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.482376	2026-08-31 01:42:44.349198
711	11000050	\N	ALADIN A.	ABDUL	male	710	DDD@DDD.COM	\N	PUROK 4, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.483458	2026-08-31 01:42:44.349198
712	11000051	\N	ABOBAKAR M.	BUKA	male	711	DDD@DDD.COM	\N	PUROK 4, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.485441	2026-08-31 01:42:44.349198
713	11000052	\N	ROBIN M.	KAMAMA	male	712	DDD@DDD.COM	\N	PUROK 4, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.486612	2026-08-31 01:42:44.349198
714	11000053	\N	BAINOR P.	BANGKALING	male	713	DDD@DDD.COM	\N	PUROK 4, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.487787	2026-08-31 01:42:44.349198
715	11000054	\N	ABDUL-MANAN A.	HASIM	male	714	DDD@DDD.COM	\N	PUROK 4, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.488961	2026-08-31 01:42:44.349198
716	11000055	\N	ABDULMALIK B.	ALIMAN	male	715	DDD@DDD.COM	\N	PUROK 4, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.490692	2026-08-31 01:42:44.349198
717	11000056	\N	NORA A.	EMBANGALA	male	716	DDD@DDD.COM	\N	PUROK 4, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.492511	2026-08-31 01:42:44.349198
718	11000057	\N	NASSER M.	KATOG	male	717	DDD@DDD.COM	\N	PUROK 4, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.494225	2026-08-31 01:42:44.349198
719	11000058	\N	JEHAD M.	PENDIWATA	male	718	DDD@DDD.COM	\N	PUROK 4, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.496344	2026-08-31 01:42:44.349198
720	11000059	\N	BASSER M.	UMAL	male	719	DDD@DDD.COM	\N	PUROK 4, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.498148	2026-08-31 01:42:44.349198
721	11000060	\N	SAGUIRA M.	BANGKALING	male	720	DDD@DDD.COM	\N	PUROK 4, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.499271	2026-08-31 01:42:44.349198
722	11000061	\N	MAANO M.	BANGKALING	male	721	DDD@DDD.COM	\N	PUROK 4, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.500688	2026-08-31 01:42:44.349198
723	11000062	\N	SANGGUTIN U.	BANGKALING	male	722	DDD@DDD.COM	\N	PUROK 4, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.502247	2026-08-31 01:42:44.349198
724	11000063	\N	RADZAK E.	BUKA	male	723	DDD@DDD.COM	\N	PUROK 4, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.503553	2026-08-31 01:42:44.349198
725	11000064	\N	KATIGUIA P.	GUINALAN	male	724	DDD@DDD.COM	\N	PUROK 4, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.504694	2026-08-31 01:42:44.349198
726	11000065	\N	MALUDTEM P.	MANDALAIT	male	725	DDD@DDD.COM	\N	PUROK 4, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.505909	2026-08-31 01:42:44.349198
727	11000066	\N	SAMSUDIN S.	PANGO	male	726	DDD@DDD.COM	\N	PUROK 4, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.507795	2026-08-31 01:42:44.349198
728	11000067	\N	NORODIN E.	MAULANA	male	727	DDD@DDD.COM	\N	PUROK 4, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.509464	2026-08-31 01:42:44.349198
729	11000068	\N	NORJIHAN H.	SUNGKA	male	728	DDD@DDD.COM	\N	PUROK 4, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.511085	2026-08-31 01:42:44.349198
730	11000069	\N	AHMAD H.U.	SAGER	male	729	DDD@DDD.COM	\N	PUROK 5, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.513213	2026-08-31 01:42:44.349198
731	11000070	\N	OMAR P.	SAMA	male	730	DDD@DDD.COM	\N	PUROK 5, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.514587	2026-08-31 01:42:44.349198
732	11000071	\N	ABDULA U.	SAGER	male	731	DDD@DDD.COM	\N	PUROK 5, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.516358	2026-08-31 01:42:44.349198
733	11000072	\N	KUSAIN E.	HASIM	male	732	DDD@DDD.COM	\N	PUROK 5, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.517545	2026-08-31 01:42:44.349198
734	11000073	\N	NASSER M.	DAGADAS	male	733	DDD@DDD.COM	\N	PUROK 5, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.518733	2026-08-31 01:42:44.349198
735	11000074	\N	GARICA K.	SAKANDAL	male	734	DDD@DDD.COM	\N	PUROK 5, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.519871	2026-08-31 01:42:44.349198
736	11000075	\N	MOHAMID M.	SAKANDAL	male	735	DDD@DDD.COM	\N	PUROK 5, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.520946	2026-08-31 01:42:44.349198
737	11000076	\N	ABDULAMGAUID H.	SAGER	male	736	DDD@DDD.COM	\N	PUROK 5, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.522014	2026-08-31 01:42:44.349198
738	11000077	\N	SAMSUDIN A.	HASIM	male	737	DDD@DDD.COM	\N	PUROK 5, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.523232	2026-08-31 01:42:44.349198
739	11000078	\N	AQUINO B.	BANGKUNIAN	male	738	DDD@DDD.COM	\N	PUROK 5, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.525159	2026-08-31 01:42:44.349198
740	11000079	\N	HAIRODIN G.	AKIL	male	739	DDD@DDD.COM	\N	PUROK 5, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.527476	2026-08-31 01:42:44.349198
741	11000080	\N	KADIL D.	ABDULLAH	male	740	DDD@DDD.COM	\N	PUROK 6, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.528856	2026-08-31 01:42:44.349198
742	11000081	\N	SALBO E.	ABDULKARIM	male	741	DDD@DDD.COM	\N	PUROK 6, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.530137	2026-08-31 01:42:44.349198
743	11000082	\N	KONG S.	ALIM	male	742	DDD@DDD.COM	\N	PUROK 6, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.531352	2026-08-31 01:42:44.349198
744	11000083	\N	TIDZ P.	BONGKALIS	male	743	DDD@DDD.COM	\N	PUROK 6, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.532416	2026-08-31 01:42:44.349198
745	11000084	\N	SAMIRUDIN M.	ALON	male	744	DDD@DDD.COM	\N	PUROK 6, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.534132	2026-08-31 01:42:44.349198
746	11000085	\N	MUNAIM I.	ALON	male	745	DDD@DDD.COM	\N	PUROK 6, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.535159	2026-08-31 01:42:44.349198
747	11000086	\N	MONIB H.E.	ABDULLA	male	746	DDD@DDD.COM	\N	PUROK 6, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.536173	2026-08-31 01:42:44.349198
748	11000087	\N	HOPER T.	MENTANG	male	747	DDD@DDD.COM	\N	PUROK 6, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.537342	2026-08-31 01:42:44.349198
749	11000088	\N	YUSSOP T.	TALIB	male	748	DDD@DDD.COM	\N	PUROK 6, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.538373	2026-08-31 01:42:44.349198
750	11000089	\N	DANNY B.	BANDON	male	749	DDD@DDD.COM	\N	PUROK 6, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.539361	2026-08-31 01:42:44.349198
751	11000090	\N	FROP T.	BANDON	male	750	DDD@DDD.COM	\N	PUROK 6, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.541723	2026-08-31 01:42:44.349198
752	11000091	\N	SALIK A.	MAKALINGGANG	male	751	DDD@DDD.COM	\N	PUROK 6, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.543577	2026-08-31 01:42:44.349198
753	11000092	\N	SALIK A.	BONGKALIS	male	752	DDD@DDD.COM	\N	PUROK 6, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.545196	2026-08-31 01:42:44.349198
754	11000093	\N	AGA A.	SULAO	male	753	DDD@DDD.COM	\N	PUROK 6, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.546312	2026-08-31 01:42:44.349198
755	11000094	\N	JENNIFER M.	UMAL	male	754	DDD@DDD.COM	\N	PUROK 6, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.547565	2026-08-31 01:42:44.349198
756	11000095	\N	MONERA S.	PINDIWATA	male	755	DDD@DDD.COM	\N	PUROK 6, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.548684	2026-08-31 01:42:44.349198
757	11000096	\N	ABIDEN A.	SULAO	male	756	DDD@DDD.COM	\N	PUROK 6, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.550555	2026-08-31 01:42:44.349198
758	11000097	\N	BENJIE B.	ATIP	male	757	DDD@DDD.COM	\N	PUROK 6, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.55173	2026-08-31 01:42:44.349198
759	11000098	\N	MOHAMAD B.	PAGALAD	male	758	DDD@DDD.COM	\N	PUROK 6, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.552782	2026-08-31 01:42:44.349198
760	11000099	\N	ASNA A.	ADULMUTALIB	male	759	DDD@DDD.COM	\N	PUROK 6, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.553857	2026-08-31 01:42:44.349198
761	11000100	\N	PIYA B.	BUNGKALIS	male	760	DDD@DDD.COM	\N	PUROK 6, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.55491	2026-08-31 01:42:44.349198
762	11000101	\N	DATUKAN L.	MAKALINGGANG	male	761	DDD@DDD.COM	\N	PUROK 6, LUANAN, PIKIT	11	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-08-31 01:42:44.556248	2026-08-31 01:42:44.349198
48	03000047	\N	SANGGUTIN,	NORMIDA T.	male	47	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:46:06	20.00	140.00	2026-08-31 14:55:53	2026-08-28 06:19:33.137998	2026-09-15 06:47:55.163753
18	03000017	\N	USMAN	(HADJI), MOCTAR A.	male	17	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:39:51	20.00	140.00	2026-08-31 14:05:25	2026-08-28 06:19:33.099027	2026-09-15 06:48:05.522893
19	03000018	\N	HADJI	USMAN, DATU HARIS A.	male	18	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:40:06	20.00	140.00	2026-08-31 14:05:55	2026-08-28 06:19:33.100589	2026-09-15 06:48:05.522893
20	03000019	\N	MAMINTAL,	BASIT G.	male	19	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:40:19	20.00	140.00	2026-08-31 14:07:21	2026-08-28 06:19:33.10299	2026-09-15 06:48:05.522893
21	03000020	\N	HARON,	ABDULHAMID P.	male	20	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:40:33	20.00	140.00	2026-08-31 14:08:15	2026-08-28 06:19:33.104407	2026-09-15 06:48:05.522893
22	03000021	\N	HARON,	ABDULBASIR U.	male	21	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:40:47	20.00	140.00	2026-08-31 14:09:54	2026-08-28 06:19:33.105552	2026-09-15 06:48:05.522893
387	05000230	\N	SAMSUDIN M.	BAGUINDA	male	386	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:06:36	30.00	210.00	2026-09-05 18:06:36	2026-08-28 12:45:05.1866	2026-09-05 10:12:13.027057
69	03000068	\N	HADJISALIK,	SABILA P.	male	68	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-10 15:08:21	10.00	70.00	2026-08-31 15:08:21	2026-08-28 06:19:33.164056	2026-08-31 07:10:59.272029
71	03000070	\N	DALIMBANG,	NASRUDIN P.	male	70	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-10 15:10:14	10.00	70.00	2026-08-31 15:10:14	2026-08-28 06:19:33.167506	2026-08-31 07:10:59.272029
52	03000051	\N	MAMINTAL,	MONAHER A.	male	51	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:42:48	20.00	140.00	2026-08-31 14:58:47	2026-08-28 06:19:33.143524	2026-09-15 06:47:55.163753
53	03000052	\N	MAMINTAL,	BENZAR M.	male	52	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:42:33	20.00	140.00	2026-08-31 14:59:11	2026-08-28 06:19:33.144613	2026-09-15 06:47:55.163753
92	03000091	\N	HADJID,	ALI B.	male	91	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:28:44	20.00	140.00	2026-08-31 16:59:56	2026-08-28 06:19:33.192925	2026-09-15 06:48:05.522893
54	03000053	\N	ADZID,	RASOL A.	male	53	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:42:19	20.00	140.00	2026-08-31 14:59:31	2026-08-28 06:19:33.145733	2026-09-15 06:47:55.163753
55	03000054	\N	MAMOT,	TOMAME P.	male	54	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:42:02	20.00	140.00	2026-08-31 14:59:52	2026-08-28 06:19:33.146818	2026-09-15 06:47:55.163753
56	03000055	\N	TONG,	NASSER B.	male	55	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:41:45	20.00	140.00	2026-08-31 15:00:16	2026-08-28 06:19:33.147852	2026-09-15 06:47:55.163753
57	03000056	\N	MARADTUGAN,	ABUBAKAR E.	male	56	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:41:30	20.00	140.00	2026-08-31 15:00:43	2026-08-28 06:19:33.149477	2026-09-15 06:47:55.163753
58	03000057	\N	ADZID,	MOGIAHID A.	male	57	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:41:13	20.00	140.00	2026-08-31 15:01:09	2026-08-28 06:19:33.150985	2026-09-15 06:47:55.163753
59	03000058	\N	SABDULLA,	ESMAEL B.	male	58	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:40:53	20.00	140.00	2026-08-31 15:01:30	2026-08-28 06:19:33.152539	2026-09-15 06:47:55.163753
60	03000059	\N	ALI,	MARY JANE T.	male	59	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:40:30	20.00	140.00	2026-08-31 15:02:08	2026-08-28 06:19:33.153849	2026-09-15 06:47:55.163753
61	03000060	\N	GILA,	NORHAN A.	male	60	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:40:15	20.00	140.00	2026-08-31 15:02:33	2026-08-28 06:19:33.154951	2026-09-15 06:47:55.163753
93	03000092	\N	MANTICAYAN,	NORHANA B.	male	92	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:27:12	20.00	140.00	2026-08-31 17:00:20	2026-08-28 06:19:33.194053	2026-09-15 06:47:55.163753
94	03000093	\N	MAMINTAL	, JOMAR P.	male	93	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:26:55	20.00	140.00	2026-08-31 17:00:43	2026-08-28 06:19:33.195081	2026-09-15 06:48:05.522893
99	03000098	\N	HADJISALIK,	ABIL P.	male	98	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:28:23	20.00	140.00	2026-08-31 17:02:22	2026-08-28 06:19:33.202335	2026-09-15 06:48:05.522893
101	03000100	\N	MANTIKAYAN,	HARIS D.	male	100	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:30:15	20.00	140.00	2026-08-31 17:03:06	2026-08-28 06:19:33.204665	2026-09-15 06:48:05.522893
102	03000101	\N	MUSAID,	KERI D.	male	101	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:25:33	20.00	140.00	2026-08-31 17:04:08	2026-08-28 06:19:33.205948	2026-09-15 06:48:05.522893
103	03000102	\N	MOSAID,	BADRUDIN D.	male	102	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:24:01	20.00	140.00	2026-08-31 17:04:29	2026-08-28 06:19:33.207035	2026-09-15 06:48:05.522893
764	03000157	\N	ABUBAKAR	KUSAIN L.	male	1005	aaa@aaa.com	2000-01-01	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0		-	2026-09-25 14:37:00	20.00	140.00	2026-09-01 09:45:14	2026-09-01 01:44:25.306243	2026-09-15 06:48:05.522893
155	03000154	\N	LUMINOG,	ARBAYA P.	male	154	aaa@aaa.com	\N	TUGAL,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-11 13:22:23	10.00	70.00	2026-09-01 13:22:23	2026-08-28 06:19:33.271353	2026-09-01 05:31:06.576768
134	03000133	\N	BADA,	RASID B.	male	133	aaa@aaa.com	\N	MAHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:30:00	20.00	140.00	2026-09-01 13:11:52	2026-08-28 06:19:33.244748	2026-09-15 06:47:55.163753
765	23000001	\N	JOHN PAUL	OTOD	male	022501	SSS@sss.com	2000-01-01	PUROK 1 , VILLARICA	23	1	Default SHS Provider	0		-	2026-09-08 15:27:48	5.00	35.00	2026-09-03 15:27:48	2026-09-03 07:22:55.188834	2026-09-03 07:30:04.163992
63	03000062	\N	ABUBAKAR,	EBRAHIM L.	male	62	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-20 15:05:20	20.00	140.00	2026-08-31 15:05:20	2026-08-28 06:19:33.157101	2026-09-04 02:10:35.489716
766	13000001	\N	NASRUDIN S.	PANDAY	male	762	EEE@EEE.COM	\N	PUROK 2, BUALAN, PIKIT	13	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:10:03.815968	2026-09-04 06:10:03.040567
767	13000002	\N	ABDUL KAHAR P.	MANGILAY	male	763	EEE@EEE.COM	\N	PUROK 2, BUALAN, PIKIT	13	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:10:03.839614	2026-09-04 06:10:03.040567
768	13000003	\N	ABDULKADIR A.	MANGILAY	male	764	EEE@EEE.COM	\N	PUROK 2, BUALAN, PIKIT	13	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:10:03.843969	2026-09-04 06:10:03.040567
769	13000004	\N	MURSHID N.	GUIAMAN	male	765	EEE@EEE.COM	\N	PUROK 2, BUALAN, PIKIT	13	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:10:03.846761	2026-09-04 06:10:03.040567
770	13000005	\N	BADRODIN M.	MACAPEGES	male	766	EEE@EEE.COM	\N	PUROK 2, BUALAN, PIKIT	13	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:10:03.849434	2026-09-04 06:10:03.040567
771	13000006	\N	ARMIA P.	AKMAD	male	767	EEE@EEE.COM	\N	PUROK 2, BUALAN, PIKIT	13	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:10:03.8509	2026-09-04 06:10:03.040567
772	13000007	\N	MUHIDIN M.	GUIAMAT	male	768	EEE@EEE.COM	\N	PUROK 2, BUALAN, PIKIT	13	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:10:03.852176	2026-09-04 06:10:03.040567
773	13000008	\N	ALIPIN S.	KODARAT	male	769	EEE@EEE.COM	\N	PUROK 2, BUALAN, PIKIT	13	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:10:03.854513	2026-09-04 06:10:03.040567
774	13000009	\N	OMULHAIR P.	GUIAMALON	male	770	EEE@EEE.COM	\N	PUROK 3, BUALAN, PIKIT	13	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:10:03.855851	2026-09-04 06:10:03.040567
775	13000010	\N	KABAIKA S.	MANGCONGAN	male	771	EEE@EEE.COM	\N	PUROK 3, BUALAN, PIKIT	13	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:10:03.856994	2026-09-04 06:10:03.040567
776	13000011	\N	ALADIN D.	KADANDUYAN	male	772	EEE@EEE.COM	\N	PUROK 4, BUALAN, PIKIT	13	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:10:03.858726	2026-09-04 06:10:03.040567
777	13000012	\N	NASRUDEN M.	TALIPASAN	male	773	EEE@EEE.COM	\N	PUROK 4, BUALAN, PIKIT	13	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:10:03.86074	2026-09-04 06:10:03.040567
778	13000013	\N	TAYA S	SAMSUDEN	male	774	EEE@EEE.COM	\N	PUROK 4, BUALAN, PIKIT	13	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:10:03.862806	2026-09-04 06:10:03.040567
779	13000014	\N	THOCKS G.	BUDAY	male	775	EEE@EEE.COM	\N	PUROK 4, BUALAN, PIKIT	13	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:10:03.865335	2026-09-04 06:10:03.040567
780	13000015	\N	KUYAG A.	BUDAY	male	776	EEE@EEE.COM	\N	PUROK 4, BUALAN, PIKIT	13	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:10:03.867963	2026-09-04 06:10:03.040567
132	03000131	\N	KUSAIN,	NORHANA T.	male	131	aaa@aaa.com	\N	MAHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:39:05	20.00	140.00	2026-09-01 13:14:06	2026-08-28 06:19:33.242632	2026-09-15 06:48:05.522893
133	03000132	\N	MUSA,	ALEDIN A.	male	132	aaa@aaa.com	\N	MAHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:38:49	20.00	140.00	2026-09-01 13:13:43	2026-08-28 06:19:33.243734	2026-09-15 06:48:05.522893
137	03000136	\N	DALAMBA,	ABUHARIS T.	male	136	aaa@aaa.com	\N	MAHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:36:48	20.00	140.00	2026-09-01 13:10:59	2026-08-28 06:19:33.247966	2026-09-15 06:48:05.522893
138	03000137	\N	DALAMBA,	KADIGUIA M.	male	137	aaa@aaa.com	\N	MAHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:37:26	20.00	140.00	2026-09-01 13:10:43	2026-08-28 06:19:33.24973	2026-09-15 06:48:05.522893
142	03000141	\N	GUIALAL,	ALLAN M.	male	141	aaa@aaa.com	\N	MAHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:31:19	20.00	140.00	2026-09-01 13:20:56	2026-08-28 06:19:33.255098	2026-09-15 06:48:05.522893
781	13000016	\N	JUN M.	KALANDUYAN	male	777	EEE@EEE.COM	\N	PUROK 5, BUALAN, PIKIT	13	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:10:03.869516	2026-09-04 06:10:03.040567
846	17000001	\N	TENGAN O.	INIDAL	male	842	GGG@GGG.COM	\N	DABABAT, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.626051	2026-09-04 06:13:38.60504
847	17000002	\N	FAISAL A.	MANGANSAKAN	male	843	GGG@GGG.COM	\N	DABABAT, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.630754	2026-09-04 06:13:38.60504
848	17000003	\N	BATI D.	RAUF	male	844	GGG@GGG.COM	\N	DABABAT, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.635268	2026-09-04 06:13:38.60504
849	17000004	\N	MONTASER D.	PALTE	male	845	GGG@GGG.COM	\N	DABABAT, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.637291	2026-09-04 06:13:38.60504
850	17000005	\N	KANDAO K.	KABIB	male	846	GGG@GGG.COM	\N	DABABAT, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.638779	2026-09-04 06:13:38.60504
851	17000006	\N	ABDULHAMID D.	KABIB	male	847	GGG@GGG.COM	\N	DABABAT, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.640333	2026-09-04 06:13:38.60504
852	17000007	\N	SALLY B.	KUSAY	male	848	GGG@GGG.COM	\N	DAMANINOL , PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.642137	2026-09-04 06:13:38.60504
853	17000008	\N	ABUSAMA S.	SAGUIALON	male	849	GGG@GGG.COM	\N	DAMANINOL , PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.645865	2026-09-04 06:13:38.60504
854	17000009	\N	NORSAMIN M.	KUSAY	male	850	GGG@GGG.COM	\N	DAMANINOL , PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.648993	2026-09-04 06:13:38.60504
855	17000010	\N	NARIE S.	MANGINDLA	male	851	GGG@GGG.COM	\N	DAMANINOL , PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.650829	2026-09-04 06:13:38.60504
856	17000011	\N	SALILA L.	WACAB	male	852	GGG@GGG.COM	\N	DAMANINOL , PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.652265	2026-09-04 06:13:38.60504
857	17000012	\N	ABDULMAULA M.	MANTUKAN	male	853	GGG@GGG.COM	\N	DAMANINOL , PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.653594	2026-09-04 06:13:38.60504
858	17000013	\N	MAISARAH S.	ZAILON	male	854	GGG@GGG.COM	\N	DAMANINOL , PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.655156	2026-09-04 06:13:38.60504
859	17000014	\N	ESMAEL S.	MANGINDLA	male	855	GGG@GGG.COM	\N	DAMANINOL , PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.656681	2026-09-04 06:13:38.60504
860	17000015	\N	SARAH M.	SAGUIALON	male	856	GGG@GGG.COM	\N	DAMANINOL , PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.658259	2026-09-04 06:13:38.60504
861	17000016	\N	ABDUL M.	PANGANDIGAN	male	857	GGG@GGG.COM	\N	DAMANINOL , PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.663646	2026-09-04 06:13:38.60504
862	17000017	\N	BASSER S.	LUMANTANG	male	858	GGG@GGG.COM	\N	DAMANINOL , PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.667473	2026-09-04 06:13:38.60504
863	17000018	\N	BASER HADJI O.	ABDULATIP	male	859	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.6697	2026-09-04 06:13:38.60504
864	17000019	\N	DAWI G.	BATUNAN	male	860	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.671718	2026-09-04 06:13:38.60504
865	17000020	\N	BHONG M.	KALEM	male	861	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.673495	2026-09-04 06:13:38.60504
866	17000021	\N	EBRAHIM D.	ALANGKAT	male	862	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.675555	2026-09-04 06:13:38.60504
867	17000022	\N	BENTO K.	SANGGUTIN	male	863	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.680319	2026-09-04 06:13:38.60504
868	17000023	\N	EBRAHIM B.	TAKUKO	male	864	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.683574	2026-09-04 06:13:38.60504
869	17000024	\N	MOHAYMIN A.	KALID	male	865	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.685357	2026-09-04 06:13:38.60504
870	17000025	\N	BASKIE G.	MAMA	male	866	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.686924	2026-09-04 06:13:38.60504
871	17000026	\N	SALINDAB A.	KALID	male	867	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.688268	2026-09-04 06:13:38.60504
872	17000027	\N	ABDUL K.	ADZAL	male	868	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.689478	2026-09-04 06:13:38.60504
873	17000028	\N	ADAM D.	ABDUL	male	869	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.693746	2026-09-04 06:13:38.60504
874	17000029	\N	MOHAMIDEN A.	KALID	male	870	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.696594	2026-09-04 06:13:38.60504
875	17000030	\N	BASIT H. D.	H. ABDULLAH	male	871	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.698907	2026-09-04 06:13:38.60504
876	17000031	\N	UMBRA K.	KADIYA	male	872	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.700407	2026-09-04 06:13:38.60504
877	17000032	\N	SITTIE K.	KADIYA	male	873	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.701682	2026-09-04 06:13:38.60504
878	17000033	\N	RAMOS A.	TUNDA	male	874	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.702897	2026-09-04 06:13:38.60504
879	17000034	\N	ALMIN G.	GUMANDING	male	875	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.704322	2026-09-04 06:13:38.60504
880	17000035	\N	RASID G.	GUMANDING	male	876	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.70549	2026-09-04 06:13:38.60504
881	17000036	\N	ABDULLAH T.	SANSALUNA	male	877	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.706645	2026-09-04 06:13:38.60504
882	17000037	\N	GUINAID T.	MAMA	male	878	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.707899	2026-09-04 06:13:38.60504
883	17000038	\N	MUSA G.	KAMID	male	879	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.709618	2026-09-04 06:13:38.60504
884	17000039	\N	BRAHIM B.	KAGKOG	male	880	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.712438	2026-09-04 06:13:38.60504
885	17000040	\N	NORA D.	SOLAIMAN	male	881	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.714661	2026-09-04 06:13:38.60504
886	17000041	\N	MBAYONG A.	OMAR	male	882	GGG@GGG.COM	\N	LABU-LABO, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.716392	2026-09-04 06:13:38.60504
887	17000042	\N	AKMAD T.	DIAGAO	male	883	GGG@GGG.COM	\N	MAGANDING,  PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.717844	2026-09-04 06:13:38.60504
888	17000043	\N	RASOL M.	SALIGAN	male	884	GGG@GGG.COM	\N	MAGANDING,  PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.719206	2026-09-04 06:13:38.60504
889	17000044	\N	ALI S.	BALAD	male	885	GGG@GGG.COM	\N	MAGANDING,  PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.72052	2026-09-04 06:13:38.60504
890	17000045	\N	ABUBAKAR A. H.	KASIM	male	886	GGG@GGG.COM	\N	MAGANDING,  PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.721702	2026-09-04 06:13:38.60504
782	15000001	\N	MANSOR U.	SAPTOLA	male	778	FFF@FFF.COM	\N	PAGKET, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.146964	2026-09-04 06:11:11.113942
783	15000002	\N	MOHALIDIN U.	TINO	male	779	FFF@FFF.COM	\N	PAGKET, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.154088	2026-09-04 06:11:11.113942
784	15000003	\N	HOMIDI S.	PAITAN	male	780	FFF@FFF.COM	\N	PAGKET, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.156243	2026-09-04 06:11:11.113942
785	15000004	\N	MIKE A.	BANDAO	male	781	FFF@FFF.COM	\N	PAGKET, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.157794	2026-09-04 06:11:11.113942
786	15000005	\N	OMAR A.	ULANGKAYA	male	782	FFF@FFF.COM	\N	PAGKET, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.160008	2026-09-04 06:11:11.113942
787	15000006	\N	NASRUDIN Y.	BADA	male	783	FFF@FFF.COM	\N	PAGKET, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.162695	2026-09-04 06:11:11.113942
788	15000007	\N	DATUNAUT P.	TINO	male	784	FFF@FFF.COM	\N	PAGKET, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.165377	2026-09-04 06:11:11.113942
789	15000008	\N	NASSER U.	TINO	male	785	FFF@FFF.COM	\N	PAGKET, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.166817	2026-09-04 06:11:11.113942
790	15000009	\N	SARIFA K.	BADA	male	786	FFF@FFF.COM	\N	PAGKET, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.168054	2026-09-04 06:11:11.113942
791	15000010	\N	BAINGAN S.	DATALA	male	787	FFF@FFF.COM	\N	PAGKET, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.169248	2026-09-04 06:11:11.113942
792	15000011	\N	ALI A.	ISON	male	788	FFF@FFF.COM	\N	PAGKET, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.170579	2026-09-04 06:11:11.113942
793	15000012	\N	TAIB A.	UNDALAYAN	male	789	FFF@FFF.COM	\N	PAGKET, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.171888	2026-09-04 06:11:11.113942
794	15000013	\N	FATIMA U.	LABA	male	790	FFF@FFF.COM	\N	PAGKET, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.173132	2026-09-04 06:11:11.113942
795	15000014	\N	AMNAH G.	GAYAGAY	male	791	FFF@FFF.COM	\N	PAGKET, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.174334	2026-09-04 06:11:11.113942
796	15000015	\N	ANGUTOB S.	TABAY	male	792	FFF@FFF.COM	\N	PAGKET, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.17564	2026-09-04 06:11:11.113942
797	15000016	\N	MASTURA B.	SILONGAN	male	793	FFF@FFF.COM	\N	PAGKET, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.178099	2026-09-04 06:11:11.113942
798	15000017	\N	HASSIM S.	SAMBOTOAN	male	794	FFF@FFF.COM	\N	PAGKET, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.180351	2026-09-04 06:11:11.113942
799	15000018	\N	RAHIMA G.	ULANGKAYA	male	795	FFF@FFF.COM	\N	PROPER, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.182314	2026-09-04 06:11:11.113942
800	15000019	\N	DENCIO Z.	DIMALANES	male	796	FFF@FFF.COM	\N	PROPER, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.183726	2026-09-04 06:11:11.113942
801	15000020	\N	HABIBA C.	MADAG	male	797	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.184939	2026-09-04 06:11:11.113942
802	15000021	\N	ALEX G.	ABDULLAH	male	798	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.186159	2026-09-04 06:11:11.113942
803	15000022	\N	BAIDIDO S.	DUMA	male	799	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.187426	2026-09-04 06:11:11.113942
804	15000023	\N	ABDULLAH D.	BADA	male	800	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.188691	2026-09-04 06:11:11.113942
805	15000024	\N	TONDATO B.	UTTO	male	801	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.189921	2026-09-04 06:11:11.113942
806	15000025	\N	USMAN U.	MADAG	male	802	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.191232	2026-09-04 06:11:11.113942
807	15000026	\N	MONAWARA S.	ALI	male	803	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.19268	2026-09-04 06:11:11.113942
808	15000027	\N	SAID M.	ABUBAKAR	male	804	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.195816	2026-09-04 06:11:11.113942
809	15000028	\N	BADRODIN W.	GAYAK	male	805	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.197631	2026-09-04 06:11:11.113942
810	15000029	\N	GANI A.	ANGKAD	male	806	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.19951	2026-09-04 06:11:11.113942
811	15000030	\N	ABDULLAH M.	ADIL	male	807	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.200821	2026-09-04 06:11:11.113942
812	15000031	\N	HABIL M.	PAMANTANGAN	male	808	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.202083	2026-09-04 06:11:11.113942
813	15000032	\N	DAUD M.	KIMULA	male	809	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.203339	2026-09-04 06:11:11.113942
814	15000033	\N	AWAL S.	SILONGAN	male	810	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.204582	2026-09-04 06:11:11.113942
815	15000034	\N	FATIMA S.	PAMANTANGAN	male	811	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.205801	2026-09-04 06:11:11.113942
816	15000035	\N	JUHARI M.	DUMA	male	812	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.207161	2026-09-04 06:11:11.113942
817	15000036	\N	KONGAN S.	PANGA	male	813	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.208926	2026-09-04 06:11:11.113942
818	15000037	\N	MAHMOD N.	SAIB	male	814	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.211026	2026-09-04 06:11:11.113942
819	15000038	\N	JULIE M.	DALANDAG	male	815	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.213196	2026-09-04 06:11:11.113942
820	15000039	\N	UMBAS S.	UNGAS	male	816	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.21519	2026-09-04 06:11:11.113942
821	15000040	\N	MOHMIN P.	MAGALUYAN	male	817	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.216726	2026-09-04 06:11:11.113942
822	15000041	\N	REX K.	ABAN	male	818	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.218079	2026-09-04 06:11:11.113942
823	15000042	\N	AMINA P.	MAGALUYAN	male	819	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.219315	2026-09-04 06:11:11.113942
824	15000043	\N	PELOT G.	ULANGKAYA	male	820	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.220702	2026-09-04 06:11:11.113942
825	15000044	\N	TAHIR P.	UNGAS	male	821	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.221971	2026-09-04 06:11:11.113942
826	15000045	\N	ABDUL P.	TINO	male	822	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.22321	2026-09-04 06:11:11.113942
827	15000046	\N	KADIL A.	ABAN	male	823	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.224407	2026-09-04 06:11:11.113942
828	15000047	\N	ANWAR P.	DAGANDAL	male	824	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.225769	2026-09-04 06:11:11.113942
829	15000048	\N	JERRY A.	UNDALAYAN	male	825	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.228581	2026-09-04 06:11:11.113942
830	15000049	\N	GUMAYAN U.	MENTAYAN	male	826	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.230605	2026-09-04 06:11:11.113942
831	15000050	\N	NORMINA A.	BADA	male	827	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.232596	2026-09-04 06:11:11.113942
832	15000051	\N	TOTO S.	SILONGAN	male	828	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.233947	2026-09-04 06:11:11.113942
833	15000052	\N	LATIP M.	SALIK	male	829	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.236364	2026-09-04 06:11:11.113942
834	15000053	\N	BASER M.	UDAS	male	830	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.237687	2026-09-04 06:11:11.113942
835	15000054	\N	AQUINO S.	DUMA	male	831	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.238918	2026-09-04 06:11:11.113942
836	15000055	\N	KAMARUDIN M.	MAGALUYAN	male	832	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.240186	2026-09-04 06:11:11.113942
837	15000056	\N	SAMRAIDA D.	BADA	male	833	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.241581	2026-09-04 06:11:11.113942
838	15000057	\N	MARIAM A.	ZACARIA	male	834	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.243165	2026-09-04 06:11:11.113942
839	15000058	\N	AMER P.	MADAG	male	835	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.245532	2026-09-04 06:11:11.113942
840	15000059	\N	BAILYN S.	ULANGKAYA	male	836	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.24743	2026-09-04 06:11:11.113942
841	15000060	\N	PAHIMA M.	ULANGKAYA	male	837	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.248911	2026-09-04 06:11:11.113942
842	15000061	\N	AIRA KIMULA	ABAN	male	838	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.250115	2026-09-04 06:11:11.113942
843	15000062	\N	ZALIKA A.	MAMINTAL	male	839	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.2515	2026-09-04 06:11:11.113942
844	15000063	\N	BADA M.	SALAPUDIN	male	840	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.252676	2026-09-04 06:11:11.113942
845	15000064	\N	SITTIE H.	MATO	male	841	FFF@FFF.COM	\N	TAPUNAN, PAMALIAN, PIKIT	15	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:11:11.253767	2026-09-04 06:11:11.113942
388	05000231	\N	MAUGIA K.	BAGINDA	male	387	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:07:10	30.00	210.00	2026-09-05 18:07:10	2026-08-28 12:45:05.187793	2026-09-05 10:12:13.027057
389	05000232	\N	GEORGE A.	KAMARUDIN	male	388	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:07:35	30.00	210.00	2026-09-05 18:07:35	2026-08-28 12:45:05.188957	2026-09-05 10:12:13.027057
390	05000233	\N	SAMSUDEN P.	DALANDAS	male	389	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:08:00	30.00	210.00	2026-09-05 18:08:00	2026-08-28 12:45:05.190139	2026-09-05 10:12:13.027057
391	05000234	\N	HASIM A.	MAKABALANG	male	390	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:08:22	30.00	210.00	2026-09-05 18:08:22	2026-08-28 12:45:05.191358	2026-09-05 10:12:13.027057
392	05000235	\N	ESMAIL K.	SANDIGAN	male	391	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:08:41	30.00	210.00	2026-09-05 18:08:41	2026-08-28 12:45:05.19262	2026-09-05 10:12:13.027057
393	05000236	\N	NORA P.	MANGGOTIN	male	392	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:09:02	30.00	210.00	2026-09-05 18:09:02	2026-08-28 12:45:05.193811	2026-09-05 10:12:13.027057
394	05000237	\N	BENJIE L.	DALANDAS	male	393	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:09:24	30.00	210.00	2026-09-05 18:09:24	2026-08-28 12:45:05.195015	2026-09-05 10:12:13.027057
395	05000238	\N	NORAISA M.	LUMANGKA	male	394	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:09:48	30.00	210.00	2026-09-05 18:09:48	2026-08-28 12:45:05.196812	2026-09-05 10:12:13.027057
396	05000239	\N	PAO U.	LAMALAN	male	395	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:10:11	30.00	210.00	2026-09-05 18:10:11	2026-08-28 12:45:05.198302	2026-09-05 10:12:13.027057
397	05000240	\N	BAINAOT S.	SANGKENAN	male	396	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:10:37	30.00	210.00	2026-09-05 18:10:37	2026-08-28 12:45:05.20056	2026-09-05 10:12:13.027057
399	05000242	\N	TABAY B.	GUIAMALON	male	398	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:11:27	30.00	210.00	2026-09-05 18:11:27	2026-08-28 12:45:05.203112	2026-09-05 10:12:13.027057
400	05000243	\N	PEDRO G.	SANGKENAN	male	399	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:11:47	30.00	210.00	2026-09-05 18:11:47	2026-08-28 12:45:05.204308	2026-09-05 10:12:13.027057
401	05000244	\N	ARLYN P.	LAMALAN	male	400	bbb@bbb.com	\N	SAWA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:12:07	30.00	210.00	2026-09-05 18:12:07	2026-08-28 12:45:05.205517	2026-09-05 10:12:13.027057
252	05000095	\N	JEFFREY P.	ANDATUAN	male	251	bbb@bbb.com	\N	LUMANGKA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:18:20	30.00	210.00	2026-09-05 18:18:20	2026-08-28 12:45:05.011957	2026-09-05 10:18:26.088465
253	05000096	\N	ZABIDE P.	ABDULKADIL	male	252	bbb@bbb.com	\N	LUMANGKA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:18:01	30.00	210.00	2026-09-05 18:18:01	2026-08-28 12:45:05.013673	2026-09-05 10:18:26.088465
263	05000106	\N	FAQROUQ G.	ADIL	male	262	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:17:42	30.00	210.00	2026-09-05 18:17:42	2026-08-28 12:45:05.025501	2026-09-05 10:18:26.088465
264	05000107	\N	BAINA D.	PANTAS	male	263	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:17:18	30.00	210.00	2026-09-05 18:17:18	2026-08-28 12:45:05.026609	2026-09-05 10:18:26.088465
266	05000109	\N	NASRODIN M.	MAKALIKOD	male	265	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:17:02	30.00	210.00	2026-09-05 18:17:02	2026-08-28 12:45:05.028651	2026-09-05 10:18:26.088465
270	05000113	\N	ESKEY G.	BAGUINDA	male	269	bbb@bbb.com	\N	PINTEL,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 18:16:41	30.00	210.00	2026-09-05 18:16:41	2026-08-28 12:45:05.034775	2026-09-05 10:18:26.088465
77	03000076	\N	BATUGAN,	MUHIDEN K.	male	76	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:44:35	20.00	140.00	2026-08-31 16:53:12	2026-08-28 06:19:33.175105	2026-09-15 05:46:20.744285
78	03000077	\N	PANDALAT,	TOGS M.	male	77	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:44:02	20.00	140.00	2026-08-31 16:53:30	2026-08-28 06:19:33.176187	2026-09-15 05:46:20.744285
79	03000078	\N	MAMINTAL,	SOLAIMAN L.	male	78	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:43:34	20.00	140.00	2026-08-31 16:53:51	2026-08-28 06:19:33.177209	2026-09-15 05:46:20.744285
80	03000079	\N	AZZID,	SAID B.	male	79	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:42:49	20.00	140.00	2026-08-31 16:54:13	2026-08-28 06:19:33.178295	2026-09-15 05:46:20.744285
82	03000081	\N	ALIMAMA,	JACKIE S.	male	81	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:36:48	20.00	140.00	2026-08-31 16:55:13	2026-08-28 06:19:33.180499	2026-09-15 05:46:20.744285
891	17000046	\N	WADJERIE K.	BAGUMBAYAN	male	887	GGG@GGG.COM	\N	MAGANDING,  PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.722864	2026-09-04 06:13:38.60504
892	17000047	\N	ABILOSA G.	KASIM	male	888	GGG@GGG.COM	\N	PIDSULUAN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.724252	2026-09-04 06:13:38.60504
893	17000048	\N	ALADIN S.	BANSILAN	male	889	GGG@GGG.COM	\N	TUKA, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.726315	2026-09-04 06:13:38.60504
894	17000049	\N	BASCO H.	MOKALAM	male	890	GGG@GGG.COM	\N	TUKA, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.729542	2026-09-04 06:13:38.60504
895	17000050	\N	KAHARUDIN S.	PANALUNSONG	male	891	GGG@GGG.COM	\N	TUKA, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.731825	2026-09-04 06:13:38.60504
896	17000051	\N	WAHIDA E.	KASAN	male	892	GGG@GGG.COM	\N	TUKA, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.733389	2026-09-04 06:13:38.60504
897	17000052	\N	MENTATO H. M.	PUNTUAN	male	893	GGG@GGG.COM	\N	TUKA, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.734739	2026-09-04 06:13:38.60504
898	17000053	\N	TAHIR P.	MAULANA	male	894	GGG@GGG.COM	\N	TUKA, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.73599	2026-09-04 06:13:38.60504
899	17000054	\N	MOGS H. H.	MALIGA	male	895	GGG@GGG.COM	\N	TUKA, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.737258	2026-09-04 06:13:38.60504
900	17000055	\N	NORALYN H.	MANDAGIYA	male	896	GGG@GGG.COM	\N	TUKA, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.738571	2026-09-04 06:13:38.60504
901	17000056	\N	MIKE B.	LAGUIAB	male	897	GGG@GGG.COM	\N	TUKA, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.739733	2026-09-04 06:13:38.60504
902	17000057	\N	TAHA M.	AKIL	male	898	GGG@GGG.COM	\N	TUKA, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.741089	2026-09-04 06:13:38.60504
903	17000058	\N	TUGAYA D.	HARON (HADJI)	male	899	GGG@GGG.COM	\N	TUKA, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.742482	2026-09-04 06:13:38.60504
904	17000059	\N	ABDILA A.	HADJI HARON	male	900	GGG@GGG.COM	\N	TUKA, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.744869	2026-09-04 06:13:38.60504
905	17000060	\N	MUNTASSIR K.	MUSANIP	male	901	GGG@GGG.COM	\N	TUKA, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.746758	2026-09-04 06:13:38.60504
906	17000061	\N	MOKALAM M.	BUDTONG	male	902	GGG@GGG.COM	\N	TUKA, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.748999	2026-09-04 06:13:38.60504
907	17000062	\N	KADIL M.	AMILIL	male	903	GGG@GGG.COM	\N	TUKA, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.750299	2026-09-04 06:13:38.60504
908	17000063	\N	WACAB H.	LASID	male	904	GGG@GGG.COM	\N	TUKA, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.751486	2026-09-04 06:13:38.60504
909	17000064	\N	ALIBAI M.	KAKIM	male	905	GGG@GGG.COM	\N	TUKA, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.752696	2026-09-04 06:13:38.60504
910	17000065	\N	ABDULMAULA B.	SANIP	male	906	GGG@GGG.COM	\N	TUKA, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.753831	2026-09-04 06:13:38.60504
911	17000066	\N	SALMAN P.	HARON	male	907	GGG@GGG.COM	\N	TUKA, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.754924	2026-09-04 06:13:38.60504
912	17000067	\N	ALLAN S.	ABAS	male	908	GGG@GGG.COM	\N	TUKA, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.75606	2026-09-04 06:13:38.60504
913	17000068	\N	DIN H.	MANDAGIYA	male	909	GGG@GGG.COM	\N	TUKA, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.757274	2026-09-04 06:13:38.60504
914	17000069	\N	KAHARODIN G.	MAMA	male	910	GGG@GGG.COM	\N	TUKA, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.758733	2026-09-04 06:13:38.60504
915	17000070	\N	ABRIS K.	MAUTIN	male	911	GGG@GGG.COM	\N	TUKA, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.760801	2026-09-04 06:13:38.60504
916	17000071	\N	BIMBO G.	ABDUL	male	912	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.762621	2026-09-04 06:13:38.60504
917	17000072	\N	GUIALUDIN B.	GUIAMAN	male	913	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.764992	2026-09-04 06:13:38.60504
918	17000073	\N	MOHAMAD S.	ENIDAL	male	914	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.766302	2026-09-04 06:13:38.60504
919	17000074	\N	SATAR M.	MIKE	male	915	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.76754	2026-09-04 06:13:38.60504
920	17000075	\N	RANDY S.	MADIDIS	male	916	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.768855	2026-09-04 06:13:38.60504
921	17000076	\N	SAMSUDIN L.	SAIDALI	male	917	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.770062	2026-09-04 06:13:38.60504
922	17000077	\N	SOPINA L.	SAYDALI	male	918	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.771208	2026-09-04 06:13:38.60504
923	17000078	\N	ISMAEL D.	SAIKENG	male	919	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.77241	2026-09-04 06:13:38.60504
924	17000079	\N	OMAR D.	BILANG	male	920	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.773511	2026-09-04 06:13:38.60504
925	17000080	\N	KASIM L.	ADZAL	male	921	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.77486	2026-09-04 06:13:38.60504
926	17000081	\N	UNGGA S.	BITOL	male	922	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.776764	2026-09-04 06:13:38.60504
927	17000082	\N	EBRAHIM P.	LIWALA	male	923	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.778339	2026-09-04 06:13:38.60504
928	17000083	\N	JOHAMIN L.	LUCAS	male	924	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.780347	2026-09-04 06:13:38.60504
929	17000084	\N	ALEX A.	MANTIKAYAN	male	925	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.782191	2026-09-04 06:13:38.60504
930	17000085	\N	KAROTIN M.	BOSIGAO	male	926	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.783465	2026-09-04 06:13:38.60504
931	17000086	\N	OMAR A.	ENGKAL	male	927	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.784736	2026-09-04 06:13:38.60504
932	17000087	\N	WAHID A.	ENGKAL	male	928	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.785906	2026-09-04 06:13:38.60504
933	17000088	\N	L RAHIB A.	ENGKA	male	929	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.787077	2026-09-04 06:13:38.60504
934	17000089	\N	ALINOR A.	SAPTULA	male	930	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.788223	2026-09-04 06:13:38.60504
935	17000090	\N	TARU A.	MANTIKAYAN	male	931	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.78933	2026-09-04 06:13:38.60504
936	17000091	\N	NORHAMIN A.	ENGKIL	male	932	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.790433	2026-09-04 06:13:38.60504
937	17000092	\N	JONATHAN T.	ENGKIL	male	933	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.791939	2026-09-04 06:13:38.60504
938	17000093	\N	JAMIL A.	ENGKEL	male	934	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.794257	2026-09-04 06:13:38.60504
939	17000094	\N	MORSID A.	PANDAPATAN	male	935	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.796474	2026-09-04 06:13:38.60504
940	17000095	\N	RAHIB A.	PALOTIANG	male	936	GGG@GGG.COM	\N	TUNTUNGEN, PUNOL , PIKIT	17	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:13:38.797768	2026-09-04 06:13:38.60504
941	19000001	\N	MEDDE G.	ALERIANO	male	937	HHH@HHH.COM	\N	ANAHAW 1,PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.225206	2026-09-04 06:14:43.205711
942	19000002	\N	TEMOLEN I.	TAPAYA	male	938	HHH@HHH.COM	\N	ANAHAW 1,PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.230333	2026-09-04 06:14:43.205711
943	19000003	\N	BINIBICTA B.	SAMILLANO	male	939	HHH@HHH.COM	\N	BACOLOD, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.23358	2026-09-04 06:14:43.205711
944	19000004	\N	CORNELIO S.	ANDRESIO	male	940	HHH@HHH.COM	\N	BACOLOD, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.23532	2026-09-04 06:14:43.205711
945	19000005	\N	JULITO V.	ANDRECIO	male	941	HHH@HHH.COM	\N	BACOLOD, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.236783	2026-09-04 06:14:43.205711
946	19000006	\N	GENALYN R.	LUQUINARIO	male	942	HHH@HHH.COM	\N	BACOLOD, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.238392	2026-09-04 06:14:43.205711
947	19000007	\N	AIAN B.	SAMILLANO	male	943	HHH@HHH.COM	\N	BACOLOD, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.239665	2026-09-04 06:14:43.205711
948	19000008	\N	ANILYN S.	ACOGIDO	male	944	HHH@HHH.COM	\N	BACOLOD, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.240883	2026-09-04 06:14:43.205711
949	19000009	\N	DENNIS S.	ACOGIDO	male	945	HHH@HHH.COM	\N	BACOLOD, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.242826	2026-09-04 06:14:43.205711
950	19000010	\N	MYLENE G.	AMBON	male	946	HHH@HHH.COM	\N	BACOLOD, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.246493	2026-09-04 06:14:43.205711
951	19000011	\N	ANGELICA M	SAMILLANO	male	947	HHH@HHH.COM	\N	BACOLOD, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.249871	2026-09-04 06:14:43.205711
952	19000012	\N	RONALD D.	SAMILLANO	male	948	HHH@HHH.COM	\N	BLASTING, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.251548	2026-09-04 06:14:43.205711
953	19000013	\N	ANGIE D.	SAMILLANO	male	949	HHH@HHH.COM	\N	BLASTING, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.253087	2026-09-04 06:14:43.205711
954	19000014	\N	AISA D.	SAMILLANO	male	950	HHH@HHH.COM	\N	BLASTING, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.254623	2026-09-04 06:14:43.205711
955	19000015	\N	EDUARDO C.	LINAWAGAN	male	951	HHH@HHH.COM	\N	BLASTING, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.256225	2026-09-04 06:14:43.205711
956	19000016	\N	GEMMA D.	SAMILLANO	male	952	HHH@HHH.COM	\N	BLASTING, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.257934	2026-09-04 06:14:43.205711
957	19000017	\N	WILSON V.	BLASÉ	male	953	HHH@HHH.COM	\N	BLASTING, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.261035	2026-09-04 06:14:43.205711
958	19000018	\N	REMBO P.	VALENZUELA	male	954	HHH@HHH.COM	\N	BUSAY, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.267435	2026-09-04 06:14:43.205711
959	19000019	\N	JAY ANN S.	PARAJELE	male	955	HHH@HHH.COM	\N	BUSAY, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.269711	2026-09-04 06:14:43.205711
960	19000020	\N	EVELYN P.	AMISTOSO	male	956	HHH@HHH.COM	\N	CAMPO-UNO, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.271339	2026-09-04 06:14:43.205711
961	19000021	\N	JENNY M.	BISAYA	male	957	HHH@HHH.COM	\N	CAMPO-UNO, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.272836	2026-09-04 06:14:43.205711
962	19000022	\N	KYLA S.	DIESTO	male	958	HHH@HHH.COM	\N	CAMPO-UNO, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.274115	2026-09-04 06:14:43.205711
963	19000023	\N	MARIALYN B.	PARA-AT	male	959	HHH@HHH.COM	\N	CAMPO-UNO, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.275524	2026-09-04 06:14:43.205711
964	19000024	\N	EVERLYN E.	DEMASUAY	male	960	HHH@HHH.COM	\N	CAMPO-UNO, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.278426	2026-09-04 06:14:43.205711
965	19000025	\N	NERALYN D.	ACOSTA	male	961	HHH@HHH.COM	\N	CAMPO-UNO, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.280959	2026-09-04 06:14:43.205711
966	19000026	\N	JUCEL B.	LONGARES	male	962	HHH@HHH.COM	\N	CAMPO-UNO, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.28254	2026-09-04 06:14:43.205711
967	19000027	\N	CHARHIZ D.	LABAJO	male	963	HHH@HHH.COM	\N	CAMPO-UNO, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.283929	2026-09-04 06:14:43.205711
968	19000028	\N	REYNALDO P.	SUNGA	male	964	HHH@HHH.COM	\N	CAMPO-UNO, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.285086	2026-09-04 06:14:43.205711
969	19000029	\N	RANDY EMANEL	ALPAS	male	965	HHH@HHH.COM	\N	CAMPO-UNO, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.286276	2026-09-04 06:14:43.205711
970	19000030	\N	MICHELLE J.	CALLAO	male	966	HHH@HHH.COM	\N	CAMPO-UNO, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.287414	2026-09-04 06:14:43.205711
971	19000031	\N	JONA JOY C.	DIMASUAY	male	967	HHH@HHH.COM	\N	CAMPO-UNO, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.288581	2026-09-04 06:14:43.205711
972	19000032	\N	PAMPILA A.	DIMASUAY	male	968	HHH@HHH.COM	\N	CAMPO-UNO, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.28973	2026-09-04 06:14:43.205711
973	19000033	\N	JESSABEL L.	BALANZA	male	969	HHH@HHH.COM	\N	CAMPO-UNO, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.290933	2026-09-04 06:14:43.205711
974	19000034	\N	ORLAN G.	DIESTO	male	970	HHH@HHH.COM	\N	CENTRO PARUAYAN, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.293004	2026-09-04 06:14:43.205711
975	19000035	\N	EVELYN E.	PARAN	male	971	HHH@HHH.COM	\N	COOP,  PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.295657	2026-09-04 06:14:43.205711
976	19000036	\N	PETER PAUL NERY D.	ACOSTA	male	972	HHH@HHH.COM	\N	CRISLAM, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.298258	2026-09-04 06:14:43.205711
977	19000037	\N	ANNIE JANE B.	TECSON	male	973	HHH@HHH.COM	\N	CRISLAM, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.29972	2026-09-04 06:14:43.205711
978	19000038	\N	REYMARK C.	JARME	male	974	HHH@HHH.COM	\N	FOREST GUARD, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.300952	2026-09-04 06:14:43.205711
979	19000039	\N	CHERRY A.	ADRIAS	male	975	HHH@HHH.COM	\N	PARABUAT, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.302454	2026-09-04 06:14:43.205711
980	19000040	\N	DONATO B.	BERMOY	male	976	HHH@HHH.COM	\N	PROPER MAHAYAHAY, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.303654	2026-09-04 06:14:43.205711
981	19000041	\N	CATHERINE A.	BENOY	male	977	HHH@HHH.COM	\N	PROPER MAHAYAHAY, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.304828	2026-09-04 06:14:43.205711
982	19000042	\N	MARILOU V.	PADRONIA	male	978	HHH@HHH.COM	\N	PROPER MAHAYAHAY, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.305986	2026-09-04 06:14:43.205711
983	19000043	\N	KURT DAYNE P.	MACEREN	male	979	HHH@HHH.COM	\N	PROPER MAHAYAHAY, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.307229	2026-09-04 06:14:43.205711
984	19000044	\N	DANNY D.	DIMASU-AY	male	980	HHH@HHH.COM	\N	PROPER PARUAYAN, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.309213	2026-09-04 06:14:43.205711
985	19000045	\N	ANEJAY A.	REQUITA	male	981	HHH@HHH.COM	\N	QUIBLAD 1, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.31219	2026-09-04 06:14:43.205711
986	19000046	\N	EDREN F.	ELECCION	male	982	HHH@HHH.COM	\N	QUIBLAD 1, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.314524	2026-09-04 06:14:43.205711
987	19000047	\N	GEMAR J.	FEROLIN	male	983	HHH@HHH.COM	\N	QUIBLAD 1, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.315935	2026-09-04 06:14:43.205711
988	19000048	\N	ALFONSO JR. L.	FEROLINO	male	984	HHH@HHH.COM	\N	QUIBLAD 1, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.317171	2026-09-04 06:14:43.205711
989	19000049	\N	JOVY T.	MACAYA	male	985	HHH@HHH.COM	\N	QUIBLAD 1, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.318406	2026-09-04 06:14:43.205711
990	19000050	\N	RENATO M.	GALANG	male	986	HHH@HHH.COM	\N	QUIBLAD 1, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.319559	2026-09-04 06:14:43.205711
991	19000051	\N	RESTY F.	COMIGHOD	male	987	HHH@HHH.COM	\N	QUIBLAD 2, PARUAYAN, ALAMADA	19	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:14:43.320784	2026-09-04 06:14:43.205711
992	21000001	\N	JOSIE M.	BACIA	male	988	JJJ@JJJ.COM	\N	KATUD-AN, PACAO, ALAMADA 	21	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:15:04.539191	2026-09-04 06:15:04.522583
993	21000002	\N	CEASAREX G.	SOLIVIO	male	989	JJJ@JJJ.COM	\N	PUROK 2, PACAO, ALAMADA 	21	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:15:04.541774	2026-09-04 06:15:04.522583
994	21000003	\N	KAREN C.	VILLAREAL	male	990	JJJ@JJJ.COM	\N	PUROK 2, PACAO, ALAMADA 	21	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:15:04.545936	2026-09-04 06:15:04.522583
995	21000004	\N	JIMMY C.	TAMAYO	male	991	JJJ@JJJ.COM	\N	PUROK 2, PACAO, ALAMADA 	21	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:15:04.548858	2026-09-04 06:15:04.522583
996	21000005	\N	MARY JOY M.	BABA	male	992	JJJ@JJJ.COM	\N	PUROK 2, PACAO, ALAMADA 	21	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:15:04.550855	2026-09-04 06:15:04.522583
997	21000006	\N	CIRILO D.	MILLIONES	male	993	JJJ@JJJ.COM	\N	PUROK 5, PACAO, ALAMADA 	21	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:15:04.552409	2026-09-04 06:15:04.522583
998	21000007	\N	JEANELYN A.	SANGUINES	male	994	JJJ@JJJ.COM	\N	PUROK 7, PACAO, ALAMADA	21	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:15:04.553728	2026-09-04 06:15:04.522583
999	21000008	\N	ROLANDO JR. T.	MAGBANUA	male	995	JJJ@JJJ.COM	\N	PUROK 7, PACAO, ALAMADA	21	1	Default SHS Provider	0	\N	-	\N	0.00	0.00	\N	2026-09-04 06:15:04.555015	2026-09-04 06:15:04.522583
185	05000028	\N	SADDAM A.	MASUKAT	male	184	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:12:59	30.00	210.00	2026-09-05 11:12:59	2026-08-28 12:45:04.927793	2026-09-05 03:14:44.693346
186	05000029	\N	BIYANG P.	TALIDTEG	male	185	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:13:29	30.00	210.00	2026-09-05 11:13:29	2026-08-28 12:45:04.929005	2026-09-05 03:14:44.693346
188	05000031	\N	JOMAR T.	OMAR	male	187	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:14:34	30.00	210.00	2026-09-05 11:14:34	2026-08-28 12:45:04.932344	2026-09-05 03:14:44.693346
192	05000035	\N	BAINAUT Y.	DAOMILANG	male	191	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:17:52	30.00	210.00	2026-09-05 11:17:52	2026-08-28 12:45:04.937959	2026-09-05 03:22:07.224696
193	05000036	\N	LUMINOG S.	SULAIMAN	male	192	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:18:21	30.00	210.00	2026-09-05 11:18:21	2026-08-28 12:45:04.939074	2026-09-05 03:22:07.224696
194	05000037	\N	FATIMA B.	LAMALAN	male	193	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:18:51	30.00	210.00	2026-09-05 11:18:51	2026-08-28 12:45:04.940169	2026-09-05 03:22:07.224696
195	05000038	\N	PUWASA B.	MILOG	male	194	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:19:16	30.00	210.00	2026-09-05 11:19:16	2026-08-28 12:45:04.941311	2026-09-05 03:22:07.224696
196	05000039	\N	BITOY A.	GUIAMBLANG	male	195	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:19:45	30.00	210.00	2026-09-05 11:19:45	2026-08-28 12:45:04.942359	2026-09-05 03:22:07.224696
197	05000040	\N	KADALI P.	MANION	male	196	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:20:11	30.00	210.00	2026-09-05 11:20:11	2026-08-28 12:45:04.943436	2026-09-05 03:22:07.224696
198	05000041	\N	KALID S.	GUIAMBALANG	male	197	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:20:48	30.00	210.00	2026-09-05 11:20:48	2026-08-28 12:45:04.944488	2026-09-05 03:22:07.224696
199	05000042	\N	SAIK A.	SALILAMA	male	198	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:21:14	30.00	210.00	2026-09-05 11:21:14	2026-08-28 12:45:04.945604	2026-09-05 03:22:07.224696
200	05000043	\N	GIANIBA B.	ABAG	male	199	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:21:36	30.00	210.00	2026-09-05 11:21:36	2026-08-28 12:45:04.947484	2026-09-05 03:22:07.224696
201	05000044	\N	NORHAN K.	SALIPADA	male	200	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 11:21:59	30.00	210.00	2026-09-05 11:21:59	2026-08-28 12:45:04.949391	2026-09-05 03:22:07.224696
213	05000056	\N	TAHIR K.	AFDAL	male	212	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:48:36	30.00	210.00	2026-09-05 12:48:36	2026-08-28 12:45:04.962895	2026-09-05 05:23:20.812187
214	05000057	\N	KABONAN G.	BISALAO	male	213	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:49:07	30.00	210.00	2026-09-05 12:49:07	2026-08-28 12:45:04.964618	2026-09-05 05:23:20.812187
215	05000058	\N	MERIAM B.	ANTAO	male	214	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:49:36	30.00	210.00	2026-09-05 12:49:36	2026-08-28 12:45:04.966357	2026-09-05 05:23:20.812187
216	05000059	\N	MONISA A.	SOLAIMAN	male	215	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:50:07	30.00	210.00	2026-09-05 12:50:07	2026-08-28 12:45:04.967504	2026-09-05 05:23:20.812187
217	05000060	\N	KALIMUDAN M.	GUIAMBLANG	male	216	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:50:42	30.00	210.00	2026-09-05 12:50:42	2026-08-28 12:45:04.968591	2026-09-05 05:23:20.812187
218	05000061	\N	SADAT B.	LUMOT	male	217	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:51:09	30.00	210.00	2026-09-05 12:51:09	2026-08-28 12:45:04.969616	2026-09-05 05:23:20.812187
219	05000062	\N	ZAINAB P.	LUMOT	male	218	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:51:52	30.00	210.00	2026-09-05 12:51:52	2026-08-28 12:45:04.970715	2026-09-05 05:23:20.812187
220	05000063	\N	TONGAN B.	LUMOT	male	219	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:52:31	30.00	210.00	2026-09-05 12:52:31	2026-08-28 12:45:04.97179	2026-09-05 05:23:20.812187
221	05000064	\N	AMIL B.	LUMOT	male	220	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:53:10	30.00	210.00	2026-09-05 12:53:10	2026-08-28 12:45:04.972848	2026-09-05 05:23:20.812187
222	05000065	\N	MIDSULBAN P.	LUMOT	male	221	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:53:36	30.00	210.00	2026-09-05 12:53:36	2026-08-28 12:45:04.973906	2026-09-05 05:23:20.812187
223	05000066	\N	HASIM P.	LUMOT	male	222	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:54:00	30.00	210.00	2026-09-05 12:54:00	2026-08-28 12:45:04.975007	2026-09-05 05:23:20.812187
224	05000067	\N	DAUD A.	SUMAEL	male	223	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:54:23	30.00	210.00	2026-09-05 12:54:23	2026-08-28 12:45:04.9762	2026-09-05 05:23:20.812187
225	05000068	\N	JEHAN K.	ABEDIN	male	224	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:55:07	30.00	210.00	2026-09-05 12:55:07	2026-08-28 12:45:04.977335	2026-09-05 05:23:20.812187
226	05000069	\N	PAHIMA S.	BAGUILAN	male	225	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:55:37	30.00	210.00	2026-09-05 12:55:37	2026-08-28 12:45:04.978778	2026-09-05 05:23:20.812187
227	05000070	\N	OMAR B.	MAKOD	male	226	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:56:04	30.00	210.00	2026-09-05 12:56:04	2026-08-28 12:45:04.980991	2026-09-05 05:23:20.812187
228	05000071	\N	ABDUL D.	PAIDUMAMA	male	227	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:56:30	30.00	210.00	2026-09-05 12:56:30	2026-08-28 12:45:04.983231	2026-09-05 05:23:20.812187
229	05000072	\N	MOHAMMIDIN D.	DIAGAO	male	228	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:57:41	30.00	210.00	2026-09-05 12:57:41	2026-08-28 12:45:04.984814	2026-09-05 05:23:20.812187
230	05000073	\N	ELLAH SENDAD	MANGELIN	male	229	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:58:07	30.00	210.00	2026-09-05 12:58:07	2026-08-28 12:45:04.986151	2026-09-05 05:23:20.812187
231	05000074	\N	KADTUNGAN A.	SALILAMA	male	230	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 12:59:04	30.00	210.00	2026-09-05 12:59:04	2026-08-28 12:45:04.987504	2026-09-05 05:23:20.812187
235	05000078	\N	TAHIRA B.	ADAM	male	234	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 13:13:44	30.00	210.00	2026-09-05 13:13:44	2026-08-28 12:45:04.992034	2026-09-05 05:23:20.812187
236	05000079	\N	BEN S.	ADAM	male	235	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 13:14:08	30.00	210.00	2026-09-05 13:14:08	2026-08-28 12:45:04.993069	2026-09-05 05:23:20.812187
237	05000080	\N	KUTAP L.	USOP	male	236	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 13:14:31	30.00	210.00	2026-09-05 13:14:31	2026-08-28 12:45:04.994168	2026-09-05 05:23:20.812187
238	05000081	\N	AMILOL P.	PAYAG	male	237	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 13:16:08	30.00	210.00	2026-09-05 13:16:08	2026-08-28 12:45:04.99534	2026-09-05 05:23:20.812187
239	05000082	\N	SARAH K.	BUISAN	male	238	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 13:16:32	30.00	210.00	2026-09-05 13:16:32	2026-08-28 12:45:04.997112	2026-09-05 05:23:20.812187
243	05000086	\N	BELONG L.	ENOK	male	242	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 13:18:05	30.00	210.00	2026-09-05 13:18:05	2026-08-28 12:45:05.002417	2026-09-05 05:23:20.812187
244	05000087	\N	BIBING S.	SALIMBA	male	243	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 13:18:33	30.00	210.00	2026-09-05 13:18:33	2026-08-28 12:45:05.003537	2026-09-05 05:23:20.812187
245	05000088	\N	SABAI S.	ABEDIN	male	244	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 13:18:55	30.00	210.00	2026-09-05 13:18:55	2026-08-28 12:45:05.004623	2026-09-05 05:23:20.812187
246	05000089	\N	ALVIN A.	PANEGAS	male	245	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 13:19:24	30.00	210.00	2026-09-05 13:19:24	2026-08-28 12:45:05.005649	2026-09-05 05:23:20.812187
247	05000090	\N	BRODZ T.	PLANG	male	246	bbb@bbb.com	\N	LUMANGKA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 13:19:55	30.00	210.00	2026-09-05 13:19:55	2026-08-28 12:45:05.006687	2026-09-05 05:23:20.812187
248	05000091	\N	ZUCRIA M.	MANGELEN	male	247	bbb@bbb.com	\N	LUMANGKA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 13:20:31	30.00	210.00	2026-09-05 13:20:31	2026-08-28 12:45:05.007692	2026-09-05 05:23:20.812187
249	05000092	\N	DATULNA B.	ANDATUAN	male	248	bbb@bbb.com	\N	LUMANGKA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 13:20:59	30.00	210.00	2026-09-05 13:20:59	2026-08-28 12:45:05.008721	2026-09-05 05:23:20.812187
250	05000093	\N	FATIMA S.	ABDULKADIL	male	249	bbb@bbb.com	\N	LUMANGKA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 13:21:28	30.00	210.00	2026-09-05 13:21:28	2026-08-28 12:45:05.009738	2026-09-05 05:23:20.812187
204	05000047	\N	PAUDZIA B.	TALIB	male	203	bbb@bbb.com	\N	KITABA,Tinultulan,Pikit	5	1	Default SHS Provider	0	\N	-	2026-10-05 21:13:28	30.00	210.00	2026-09-05 21:13:28	2026-08-28 12:45:04.952792	2026-09-05 13:13:54.246694
2	03000001	\N	MANTIKAYAN,	SUBO B.	male	1	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-10-07 14:35:31	40.00	280.00	2026-08-28 14:35:31	2026-08-28 06:19:33.075193	2026-09-15 05:46:20.744285
3	03000002	\N	PINTEL,	MISRIA E.	male	2	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:32:27	21.00	147.00	2026-08-31 11:16:49	2026-08-28 06:19:33.078704	2026-09-15 05:46:20.744285
4	03000003	\N	MUSA,	ZAITON M.	male	3	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:32:50	20.00	140.00	2026-08-31 11:25:14	2026-08-28 06:19:33.080089	2026-09-15 05:46:20.744285
5	03000004	\N	LUNDAYAN,	DEXON S.	male	4	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:33:10	20.00	140.00	2026-08-31 13:58:24	2026-08-28 06:19:33.081701	2026-09-15 05:46:20.744285
6	03000005	\N	AMIN,	NASSER L.	male	5	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:38:19	20.00	140.00	2026-08-31 13:57:59	2026-08-28 06:19:33.083837	2026-09-15 05:46:20.744285
7	03000006	\N	DALIASAN,	GUIALUDIN A.	male	6	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:26:18	20.00	140.00	2026-08-31 13:56:29	2026-08-28 06:19:33.085515	2026-09-15 05:46:20.744285
8	03000007	\N	ABDULLAH,	KHALID S.	male	7	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:32:02	20.00	140.00	2026-08-31 13:53:50	2026-08-28 06:19:33.087171	2026-09-15 05:46:20.744285
9	03000008	\N	ALI,	ROSDA M.	male	8	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:31:44	20.00	140.00	2026-08-31 13:53:09	2026-08-28 06:19:33.088388	2026-09-15 05:46:20.744285
10	03000009	\N	AMPATUAN,	YASSER M.	male	9	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:33:51	20.00	140.00	2026-08-31 13:52:10	2026-08-28 06:19:33.089569	2026-09-15 05:46:20.744285
11	03000010	\N	MAMOLINDAS,	SOWAD N.	male	10	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:33:33	20.00	140.00	2026-08-31 13:51:17	2026-08-28 06:19:33.090971	2026-09-15 05:46:20.744285
12	03000011	\N	MAMULINDAS,	BENLADEN M.	male	11	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-10-14 14:00:26	44.00	308.00	2026-08-31 14:00:26	2026-08-28 06:19:33.092001	2026-09-15 05:46:20.744285
13	03000012	\N	HASSEM,	GUIAMALUDIN A.	male	12	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:14:04	21.00	147.00	2026-08-31 14:00:55	2026-08-28 06:19:33.093117	2026-09-15 05:46:20.744285
14	03000013	\N	HARON,	SABRE U.	male	13	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:25:31	20.00	140.00	2026-08-31 14:03:23	2026-08-28 06:19:33.094218	2026-09-15 05:46:20.744285
36	03000035	\N	MAMINTAL,	ABDULLA S.	male	35	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:12:40	20.00	140.00	2026-08-31 14:32:36	2026-08-28 06:19:33.122787	2026-09-15 05:46:20.744285
37	03000036	\N	MUSA,	LAGA L.	male	36	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:12:06	20.00	140.00	2026-08-31 14:33:12	2026-08-28 06:19:33.123869	2026-09-15 05:46:20.744285
38	03000037	\N	DALIMBANG,	MORSID P.	male	37	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:27:29	20.00	140.00	2026-08-31 14:34:06	2026-08-28 06:19:33.124951	2026-09-15 05:46:20.744285
49	03000048	\N	MAMINTAL,	BENLADIN J.	male	48	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-10-15 13:27:11	40.00	280.00	2026-08-31 14:56:14	2026-08-28 06:19:33.140079	2026-09-15 05:46:20.744285
50	03000049	\N	SULTAN,	SAKINA P.	male	49	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-10-15 13:26:56	40.00	280.00	2026-08-31 14:56:38	2026-08-28 06:19:33.141182	2026-09-15 05:46:20.744285
83	03000082	\N	SALIK	HADJI, ESMAIL M.	male	82	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:37:11	20.00	140.00	2026-08-31 16:55:39	2026-08-28 06:19:33.181643	2026-09-15 05:46:20.744285
84	03000083	\N	DALIMBANG,	NORIA T.	male	83	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:37:33	20.00	140.00	2026-08-31 16:56:20	2026-08-28 06:19:33.183595	2026-09-15 05:46:20.744285
85	03000084	\N	ABUBAKAR,	SAIDA T.	male	84	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:37:50	20.00	140.00	2026-08-31 16:56:43	2026-08-28 06:19:33.185255	2026-09-15 05:46:20.744285
95	03000094	\N	MUSA,	NORMINA M.	male	94	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:44:48	20.00	140.00	2026-08-31 17:01:04	2026-08-28 06:19:33.19613	2026-09-15 05:46:20.744285
105	03000104	\N	HADJI	ALI, BIYAN M.	male	104	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:45:06	20.00	140.00	2026-08-31 17:05:32	2026-08-28 06:19:33.209063	2026-09-15 05:46:20.744285
110	03000109	\N	ABDULLAH,	DANTE D.	male	109	aaa@aaa.com	2000-01-01	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:45:43	20.00	140.00	2026-08-31 18:45:38	2026-08-28 06:19:33.21414	2026-09-15 05:46:20.744285
141	03000140	\N	MUSA,	MUSLIMIN K.	male	140	aaa@aaa.com	\N	MAHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:45:21	20.00	140.00	2026-09-01 13:21:17	2026-08-28 06:19:33.253963	2026-09-15 05:46:20.744285
109	03000108	\N	HUSSAIN,	RASUL K.	male	108	aaa@aaa.com	2000-01-01	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 13:48:14	20.00	140.00	2026-08-31 18:45:15	2026-08-28 06:19:33.213073	2026-09-15 05:50:32.370841
47	03000046	\N	SANGGUTIN,	NORHASIM T.	male	46	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:45:51	20.00	140.00	2026-08-31 14:55:34	2026-08-28 06:19:33.136836	2026-09-15 06:47:55.163753
96	03000095	\N	DATUAN,	MAYSARAH B.	male	95	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:28:10	20.00	140.00	2026-08-31 17:01:23	2026-08-28 06:19:33.197095	2026-09-15 06:47:55.163753
97	03000096	\N	MONDAS,	ALKAN A.	male	96	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:28:22	20.00	140.00	2026-08-31 17:01:41	2026-08-28 06:19:33.198518	2026-09-15 06:47:55.163753
98	03000097	\N	ABDULLAH,	NORSID B.	male	97	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:28:50	20.00	140.00	2026-08-31 17:02:03	2026-08-28 06:19:33.200429	2026-09-15 06:47:55.163753
108	03000107	\N	TUMENDEG,	TARHATA E.	male	107	aaa@aaa.com	2000-01-01	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:08:47	20.00	140.00	2026-08-31 18:44:52	2026-08-28 06:19:33.212032	2026-09-15 06:47:55.163753
112	03000111	\N	HADJI ALI,	RAHIMA G.	male	111	aaa@aaa.com	2000-01-01	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:29:25	20.00	140.00	2026-08-31 19:04:43	2026-08-28 06:19:33.217453	2026-09-15 06:47:55.163753
113	03000112	\N	HADJI ALI,	RAHIMA M.	male	112	aaa@aaa.com	2000-01-01	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:26:54	20.00	140.00	2026-08-31 17:05:13	2026-08-28 06:19:33.219177	2026-09-15 06:47:55.163753
114	03000113	\N	MANONGGAL,	JUNIOR S.	male	113	aaa@aaa.com	2000-01-01	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:10:17	20.00	140.00	2026-08-31 19:06:09	2026-08-28 06:19:33.220397	2026-09-15 06:47:55.163753
118	03000117	\N	HADJI	ALI, ESMAIL M.	male	117	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:29:39	20.00	140.00	2026-09-01 09:48:52	2026-08-28 06:19:33.224956	2026-09-15 06:47:55.163753
120	03000119	\N	ALI,	SURAIDA M.	male	119	aaa@aaa.com	\N	MA'AHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:26:04	20.00	140.00	2026-09-01 09:49:49	2026-08-28 06:19:33.227203	2026-09-15 06:47:55.163753
123	03000122	\N	ABIDIN,	KARATO K.	male	122	aaa@aaa.com	\N	MAHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:39:44	20.00	140.00	2026-09-01 13:04:04	2026-08-28 06:19:33.230622	2026-09-15 06:47:55.163753
124	03000123	\N	GANDAL,	DONDON U.	male	123	aaa@aaa.com	\N	MAHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:24:41	20.00	140.00	2026-09-01 13:06:07	2026-08-28 06:19:33.23196	2026-09-15 06:47:55.163753
125	03000124	\N	KAMLAN,	BHING H.	male	124	aaa@aaa.com	\N	MAHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:30:40	20.00	140.00	2026-09-01 13:06:31	2026-08-28 06:19:33.233771	2026-09-15 06:47:55.163753
129	03000128	\N	DAGANDAL,	NORAISA P.	male	128	aaa@aaa.com	\N	MAHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:26:26	20.00	140.00	2026-09-01 13:08:19	2026-08-28 06:19:33.239368	2026-09-15 06:47:55.163753
130	03000129	\N	ABAS,	NASRUDIN K.	male	129	aaa@aaa.com	\N	MAHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:30:56	20.00	140.00	2026-09-01 13:08:36	2026-08-28 06:19:33.24043	2026-09-15 06:47:55.163753
131	03000130	\N	MUSA,	MOHAMED A.	male	130	aaa@aaa.com	\N	MAHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:38:27	20.00	140.00	2026-09-01 13:14:31	2026-08-28 06:19:33.241479	2026-09-15 06:47:55.163753
135	03000134	\N	PANGATO,	HUSAIRE S.	male	134	aaa@aaa.com	\N	MAHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:31:12	20.00	140.00	2026-09-01 13:11:33	2026-08-28 06:19:33.245801	2026-09-15 06:47:55.163753
136	03000135	\N	TAYATO,	LAGA A.	male	135	aaa@aaa.com	\N	MAHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:31:31	20.00	140.00	2026-09-01 13:11:16	2026-08-28 06:19:33.246923	2026-09-15 06:47:55.163753
139	03000138	\N	PANGATO,	ANWAR M.	male	138	aaa@aaa.com	\N	MAHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:38:54	20.00	140.00	2026-09-01 13:10:23	2026-08-28 06:19:33.251151	2026-09-15 06:47:55.163753
140	03000139	\N	DIALANGAN,	GUIRIA A.	male	139	aaa@aaa.com	\N	MAHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:37:02	20.00	140.00	2026-09-01 13:10:03	2026-08-28 06:19:33.252798	2026-09-15 06:47:55.163753
154	03000153	\N	PAMANTANGAN,	FARHANA S.	male	153	aaa@aaa.com	\N	TUGAL,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:33:16	20.00	140.00	2026-09-01 13:22:41	2026-08-28 06:19:33.270175	2026-09-15 06:47:55.163753
31	03000030	\N	ABDULLAH,	MUCTAR S.	male	30	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:44:09	20.00	140.00	2026-08-31 14:26:22	2026-08-28 06:19:33.115586	2026-09-15 06:48:05.522893
32	03000031	\N	MONDOK,	NANO S.	male	31	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:45:00	20.00	140.00	2026-08-31 14:26:41	2026-08-28 06:19:33.117391	2026-09-15 06:48:05.522893
33	03000032	\N	DALAMBA,	ESMAEL B.	male	32	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:45:39	20.00	140.00	2026-08-31 14:27:11	2026-08-28 06:19:33.119371	2026-09-15 06:48:05.522893
34	03000033	\N	MALAGINTING,	PATAK M.	male	33	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:45:56	20.00	140.00	2026-08-31 14:27:36	2026-08-28 06:19:33.120514	2026-09-15 06:48:05.522893
35	03000034	\N	LINTANGI,	MALIGA A.	male	34	aaa@aaa.com	\N	BLAH,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:46:16	20.00	140.00	2026-08-31 14:30:09	2026-08-28 06:19:33.121693	2026-09-15 06:48:05.522893
100	03000099	\N	SALIK,	OMAR A.	male	99	aaa@aaa.com	\N	GAWANG,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-10-05 14:30:19	30.00	210.00	2026-08-31 17:02:44	2026-08-28 06:19:33.203583	2026-09-15 06:48:05.522893
143	03000142	\N	GUIALAL,	ABUZAID K.	male	142	aaa@aaa.com	\N	MAHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:33:35	20.00	140.00	2026-09-01 13:20:38	2026-08-28 06:19:33.256154	2026-09-15 06:48:05.522893
144	03000143	\N	OPING,	NASSER A.	male	143	aaa@aaa.com	\N	MAHAD,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:33:53	20.00	140.00	2026-09-01 13:20:17	2026-08-28 06:19:33.257188	2026-09-15 06:48:05.522893
145	03000144	\N	ADZAL,	SALMAN P.	male	144	aaa@aaa.com	\N	PADIYAN,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:31:58	20.00	140.00	2026-09-01 13:16:41	2026-08-28 06:19:33.258166	2026-09-15 06:48:05.522893
146	03000145	\N	PANGATO,	SHARGE S.	male	145	aaa@aaa.com	\N	PADIYAN,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:31:39	20.00	140.00	2026-09-01 13:16:24	2026-08-28 06:19:33.259221	2026-09-15 06:48:05.522893
147	03000146	\N	KUYAG,	HADIGIA D.	male	146	aaa@aaa.com	\N	SPDA,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:36:12	20.00	140.00	2026-09-01 13:16:04	2026-08-28 06:19:33.260209	2026-09-15 06:48:05.522893
148	03000147	\N	DALIMBANG,	TUNAN B.	male	147	aaa@aaa.com	\N	SPDA,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:33:01	20.00	140.00	2026-09-01 13:15:36	2026-08-28 06:19:33.261232	2026-09-15 06:48:05.522893
149	03000148	\N	ALANG,	TAWAB L.	male	148	aaa@aaa.com	\N	SPDA,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:35:42	20.00	140.00	2026-09-01 13:15:18	2026-08-28 06:19:33.262528	2026-09-15 06:48:05.522893
150	03000149	\N	ALANG	SAMMER L.	male	149	aaa@aaa.com	\N	SPDA,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:35:58	20.00	140.00	2026-09-01 13:14:54	2026-08-28 06:19:33.26366	2026-09-15 06:48:05.522893
151	03000150	\N	LUNA,	HASNA D.	male	150	aaa@aaa.com	\N	SPDA,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:34:08	20.00	140.00	2026-09-01 13:23:35	2026-08-28 06:19:33.264811	2026-09-15 06:48:05.522893
152	03000151	\N	GUTOM,	IBRAHIM M.	male	151	aaa@aaa.com	\N	TUGAL,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:35:27	20.00	140.00	2026-09-01 13:23:17	2026-08-28 06:19:33.266698	2026-09-15 06:48:05.522893
153	03000152	\N	TUGAL,	JEMAR P.	male	152	aaa@aaa.com	\N	TUGAL,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:35:10	20.00	140.00	2026-09-01 13:22:59	2026-08-28 06:19:33.268525	2026-09-15 06:48:05.522893
157	03000156	\N	GUIABAR,	JOEL T.	male	156	aaa@aaa.com	\N	TUGAL,MANAULANAN,TUGUNAN	3	1	Default SHS Provider	0	\N	-	2026-09-25 14:32:35	20.00	140.00	2026-09-01 13:21:40	2026-08-28 06:19:33.273437	2026-09-15 06:48:05.522893
\.


--
-- Data for Name: pos_action_logs; Type: TABLE DATA; Schema: public; Owner: solar_admin
--

COPY public.pos_action_logs (id, pos_sn, action_type, operator, role, remark, "timestamp") FROM stdin;
1	0310742010375680	CREATE	admin	1	Manually created device	2026-08-28 05:46:08.149828
2	0310742010375680	POS_LOGIN	admin	1	Login successful on device 0310742010375680	2026-08-28 05:48:06.439646
3	0310742010377045	MANUAL_LOCK	admin	1	Authorized by admin. Executed by admin. Remark: missing	2026-08-28 06:05:34.895339
4	0310742010377045	MANUAL_UNLOCK	admin	1	Authorized by admin. Executed by admin. Remark: None	2026-08-28 06:07:34.261414
5	0310742010377045	POS_LOGIN	admin	1	Login successful on device 0310742010377045	2026-08-28 06:13:18.842904
6	0310742010375680	POS_LOGIN	MANAULANAN_SOLAR	2	Login successful on device 0310742010375680	2026-08-28 06:30:01.287832
7	0310742010377053	POS_LOGIN	admin	1	Login successful on device 0310742010377053	2026-09-01 02:30:57.560391
8	0310742010377062	POS_LOGIN	MANAULANAN_SOLAR	2	Login successful on device 0310742010377062	2026-09-02 02:27:15.418509
9	0310742010377062	POS_LOGIN	MANAULANAN_SOLAR	2	Login successful on device 0310742010377062	2026-09-02 02:27:21.10223
10	0310742010377062	POS_LOGIN	MANAULANAN_SOLAR	2	Login successful on device 0310742010377062	2026-09-02 02:27:25.914685
11	0310742010377062	POS_LOGIN	MANAULANAN_SOLAR	2	Login successful on device 0310742010377062	2026-09-02 02:27:27.105487
12	0310742010377062	POS_LOGIN	MANAULANAN_SOLAR	2	Login successful on device 0310742010377062	2026-09-02 02:27:28.656181
13	0310742010377062	POS_LOGIN	MANAULANAN_SOLAR	2	Login successful on device 0310742010377062	2026-09-02 02:30:32.345874
14	0310742010377045	POS_LOGIN	MANAULANAN_SOLAR	2	Login successful on device 0310742010377045	2026-09-02 02:31:26.440163
15	0310742010377062	POS_LOGIN	MANAULANAN_SOLAR	2	Login successful on device 0310742010377062	2026-09-02 02:31:43.105989
16	0310742010377062	POS_LOGIN	MANAULANAN_SOLAR	2	Login successful on device 0310742010377062	2026-09-02 02:31:44.968305
17	0310742010377062	POS_LOGIN	BRGY_TINULTULAN	2	Login successful on device 0310742010377062	2026-09-02 02:32:22.546164
18	0310742010377045	POS_LOGIN	MANAULANAN_SOLAR	2	Login successful on device 0310742010377045	2026-09-02 10:59:43.569508
19	0310742010377062	POS_LOGIN	MANAULANAN_SOLAR	2	Login successful on device 0310742010377062	2026-09-02 11:01:01.471222
20	0310742010377062	POS_LOGIN	MANAULANAN_SOLAR	2	Login successful on device 0310742010377062	2026-09-02 11:01:10.559739
21	0310742010377062	POS_LOGIN	MANAULANAN_SOLAR	2	Login successful on device 0310742010377062	2026-09-03 02:04:56.299975
22	0310742010377062	POS_LOGIN	admin	1	Login successful on device 0310742010377062	2026-09-03 02:36:32.193838
23	0310742010377062	POS_LOGIN	BRGY_TINULTULAN	2	Login successful on device 0310742010377062	2026-09-03 03:14:38.358439
24	0310742010375680	POS_LOGIN	RED_TESTING	2	Login successful on device 0310742010375680	2026-09-03 07:27:03.458154
25	0310742010377062	POS_LOGIN	MANAULANAN_SOLAR	2	Login successful on device 0310742010377062	2026-09-03 13:13:48.059289
26	0310742010377062	POS_LOGIN	BRGY_TINULTULAN	2	Login successful on device 0310742010377062	2026-09-04 06:21:22.784212
27	0310742010377062	POS_LOGIN	MANAULANAN_SOLAR	2	Login successful on device 0310742010377062	2026-09-15 05:08:06.234745
28	0310742010375680	POS_LOGIN	MANAULANAN_SOLAR	2	Login successful on device 0310742010375680	2026-09-15 05:56:54.788662
\.


--
-- Data for Name: pos_machines; Type: TABLE DATA; Schema: public; Owner: solar_admin
--

COPY public.pos_machines (id, pos_sn, pos_code, status, lock_status, is_deleted, region_id, branch_office, reconciliation_deadline, last_reconciliation_at, last_lock_reason, last_action_by, assigned_user_id, last_login_at, last_ip, app_version, version_type, mac_address, latitude, longitude, created_at, created_by) FROM stdin;
5	0310742010377053	13	1	0	f	\N	\N	\N	\N	\N	\N	\N	2026-09-01 02:30:57.558927	172.27.160.1	1.0.0	Stable	\N	0.0	0.0	2026-09-01 02:29:46.753805	\N
6	0310742010377064	14	1	0	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-01 03:03:11.574279	\N
3	0310742010377045	11	1	0	f	\N	\N	\N	\N	Manual security restoration	admin	\N	2026-09-02 10:59:43.553975	172.27.160.1	1.6.0	Stable	\N	0.0	0.0	2026-08-28 06:04:48.718407	\N
4	0310742010377062	12	1	0	f	\N	\N	\N	\N	\N	\N	\N	2026-09-15 05:08:06.233012	172.27.160.1	1.6.0	Stable	\N	0.0	0.0	2026-09-01 02:03:54.285829	\N
2	0310742010375680	10	0	0	f	\N	\N	\N	\N	\N	\N	\N	2026-09-15 05:56:54.788273	172.27.160.1	1.6.0	Stable	\N	0.0	0.0	2026-08-28 05:46:08.151773	admin
\.


--
-- Data for Name: pos_staging_customers; Type: TABLE DATA; Schema: public; Owner: solar_admin
--

COPY public.pos_staging_customers (id, customer_uuid, first_name, last_name, card_uuid, shs_machine_id, gender, mobile, email, birthday, address, region_id, status, beneficiary_count, representative_name, rep_relationship, pos_sn, operator_username, upload_time, processed_status, processing_error) FROM stdin;
\.


--
-- Data for Name: pos_staging_transactions; Type: TABLE DATA; Schema: public; Owner: solar_admin
--

COPY public.pos_staging_transactions (id, transaction_id, customer_uuid, card_uuid, shs_machine_id, days, amount, transaction_time, action_type, pos_sn, operator_username, upload_time, processed_status, processing_error) FROM stdin;
\.


--
-- Data for Name: provider_configs; Type: TABLE DATA; Schema: public; Owner: solar_admin
--

COPY public.provider_configs (id, name, tin, logo_url, phone, email, address, is_initialized, created_at, updated_at) FROM stdin;
1	Default SHS Provider	TIN_INIT_0000	\N	\N	\N	\N	f	2026-08-28 05:37:42.998716	2026-08-28 05:37:42.998719
\.


--
-- Data for Name: regions; Type: TABLE DATA; Schema: public; Owner: solar_admin
--

COPY public.regions (id, name, level, parent_id, daily_rate, last_rate_updated_at, last_rate_modified_by_id) FROM stdin;
2	BRGY. MANAULANAN	1	1	7.00	\N	\N
3	BLAH/GAWANG/MA'AHAD/MAHAD/PADIYAN/SPDA/TUGAL	2	2	7.00	\N	\N
4	BRGY. TINULTULAN	1	1	7.00	\N	\N
5	BUDTA, INALASAN, KITABA, LUMANGKA, PINTEL, PROPER, SALAKOP, SAWA	2	4	7.00	\N	\N
6	BRGY. MALAPANG	1	1	7.00	\N	\N
7	1, 1A, 2, 3, 4A, 4B, 5A, 5B	2	6	7.00	\N	\N
1	COTELCO-PPALMA	0	\N	7.00	\N	\N
8	BRGY. BALATICAN	1	1	7.00	\N	\N
9	ALENG, GADUNGAN, KABABAAN, LULISAN, PALAO, PROPER, PULAN-PULAN,  QUARRY, TUKA NA ULS	2	8	7.00	\N	\N
10	BRGY. LUANAN	1	1	7.00	\N	\N
11	1, 2, 3, 4, 5, 6	2	10	7.00	\N	\N
12	BRGY. BUALAN	1	1	7.00	\N	\N
13	2, 3, 4, 5	2	12	7.00	\N	\N
14	BRGY. PAMALIAN	1	1	7.00	\N	\N
15	PAGKET, PROPER, TAPUNAN	2	14	7.00	\N	\N
16	BRGY. PUNOL	1	1	7.00	\N	\N
17	DABABAT, DAMANINOL , LABU-LABO, MAGANDING,  PIDSULUAN, TUKA , TUNTUNGEN	2	16	7.00	\N	\N
18	BRGY. PARUAYAN	1	1	7.00	\N	\N
19	ANAHAW 1, BACOLOD, BLASTING, BUSAY, CAMPO-UNO, ETC.	2	18	7.00	\N	\N
20	BRGY. PACAO	1	1	7.00	\N	\N
21	2, 5, 7	2	20	7.00	\N	\N
22	RED	1	1	7.00	\N	\N
23	PVM	2	22	7.00	\N	\N
\.


--
-- Data for Name: solar_units; Type: TABLE DATA; Schema: public; Owner: solar_admin
--

COPY public.solar_units (id, shs_machine_id, solar_equipment_id, radio_id, flashlight_id, led_light_id, shs_status, equipment_status, radio_status, flashlight_status, led_status, customer_uuid, customer_name, city, town, production_date, created_at, bound_at, updated_at) FROM stdin;
479	HT2026072001660	HT20260720016601	HT20260720016602	HT20260720016603	HT20260720016604	1	0	0	0	0	05000191	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 09:48:25.746781	2026-09-05 09:49:46.15896	2026-09-05 09:49:46.161414
362	HT2026072001397	HT20260720013971	HT20260720013972	HT20260720013973	HT20260720013974	1	0	0	0	0	05000218	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:50:58.158378	2026-09-05 10:12:13.107217	2026-09-05 10:12:13.207722
18	HT2026072002146	HT20260720021461	HT20260720021462	HT20260720021463	HT20260720021464	1	0	0	0	0	03000043	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 02:58:57.798818	2026-09-15 06:47:55.188271	2026-09-15 06:47:55.349908
19	HT2026072002652	HT20260720026521	HT20260720026522	HT20260720026523	HT20260720026524	1	0	0	0	0	03000044	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 02:59:02.600943	2026-09-15 06:47:55.190964	2026-09-15 06:47:55.34991
20	HT2026072002187	HT20260720021871	HT20260720021872	HT20260720021873	HT20260720021874	1	0	0	0	0	03000045	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 02:59:06.963712	2026-09-15 06:47:55.193691	2026-09-15 06:47:55.349911
21	HT2026072002703	HT20260720027031	HT20260720027032	HT20260720027033	HT20260720027034	1	0	0	0	0	03000051	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 02:59:12.341571	2026-09-15 06:47:55.196269	2026-09-15 06:47:55.349911
22	HT2026072002497	HT20260720024971	HT20260720024972	HT20260720024973	HT20260720024974	1	0	0	0	0	03000052	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 02:59:17.788	2026-09-15 06:47:55.19877	2026-09-15 06:47:55.349911
23	HT2026072002199	HT20260720021991	HT20260720021992	HT20260720021993	HT20260720021994	1	0	0	0	0	03000053	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 02:59:22.113389	2026-09-15 06:47:55.201233	2026-09-15 06:47:55.349912
40	HT2026072002643	HT20260720026431	HT20260720026432	HT20260720026433	HT20260720026434	1	0	0	0	0	03000039	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:02:36.034378	2026-09-15 06:47:55.185702	2026-09-15 06:47:55.349914
9	HT2026072001602	HT20260720016021	HT20260720016022	HT20260720016023	HT20260720016024	1	0	0	0	0	03000023	\N	\N	\N	2026-08-28 00:00:00	2026-08-28 05:52:45.196088	2026-09-15 06:48:05.535671	2026-09-15 06:48:05.726811
10	HT2026072001603	HT20260720016031	HT20260720016032	HT20260720016033	HT20260720016034	1	0	0	0	0	03000024	\N	\N	\N	2026-08-28 00:00:00	2026-08-28 05:52:51.698198	2026-09-15 06:48:05.538183	2026-09-15 06:48:05.726813
14	HT2026072002608	HT20260720026081	HT20260720026082	HT20260720026083	HT20260720026084	1	0	0	0	0	03000019	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 02:57:31.242556	2026-09-15 06:48:05.533335	2026-09-15 06:48:05.726813
15	HT2026072002627	HT20260720026271	HT20260720026272	HT20260720026273	HT20260720026274	1	0	0	0	0	03000022	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 02:57:36.802044	2026-09-15 06:48:05.540492	2026-09-15 06:48:05.726813
16	HT2026072002150	HT20260720021501	HT20260720021502	HT20260720021503	HT20260720021504	1	0	0	0	0	03000030	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 02:57:42.641519	2026-09-15 06:48:05.542926	2026-09-15 06:48:05.726814
32	HT2026072002594	HT20260720025941	HT20260720025942	HT20260720025943	HT20260720025944	1	0	0	0	0	03000026	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:00:57.750497	2026-09-15 06:48:05.545068	2026-09-15 06:48:05.726815
165	HT2026072002540	HT20260720025401	HT20260720025402	HT20260720025403	HT20260720025404	1	0	0	0	0	05000007	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:45:43.637525	2026-09-05 02:49:34.02147	2026-09-05 02:49:34.080117
172	HT2026072002582	HT20260720025821	HT20260720025822	HT20260720025823	HT20260720025824	1	0	0	0	0	05000010	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:49:29.081382	2026-09-05 02:49:34.018909	2026-09-05 02:49:34.080118
173	FT2109972692576	FT21099726925761	FT21099726925762	FT21099726925763	FT21099726925764	1	0	0	0	0	05000011	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:49:56.868234	2026-09-05 02:49:34.01067	2026-09-05 02:49:34.080119
176	HT2026072002152	HT20260720021521	HT20260720021522	HT20260720021523	HT20260720021524	1	0	0	0	0	05000019	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:50:33.294586	2026-09-05 03:09:46.018754	2026-09-05 03:09:46.035245
183	HT2026072002571	HT20260720025711	HT20260720025712	HT20260720025713	HT20260720025714	1	0	0	0	0	05000022	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:52:50.161599	2026-09-05 03:09:46.021408	2026-09-05 03:09:46.035247
179	HT2026072002243	HT20260720022431	HT20260720022432	HT20260720022433	HT20260720022434	1	0	0	0	0	05000031	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:51:32.460306	2026-09-05 03:14:44.71382	2026-09-05 03:14:44.730701
168	HT2026072002121	HT20260720021211	HT20260720021212	HT20260720021213	HT20260720021214	1	0	0	0	0	05000035	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:47:10.087014	2026-09-05 03:22:07.27429	2026-09-05 03:22:07.295667
169	HT2026072002943	HT20260720029431	HT20260720029432	HT20260720029433	HT20260720029434	1	0	0	0	0	05000032	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:48:30.173266	2026-09-05 03:22:07.258932	2026-09-05 03:22:07.295668
180	HT2026072002585	HT20260720025851	HT20260720025852	HT20260720025853	HT20260720025854	1	0	0	0	0	05000033	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:51:54.12539	2026-09-05 03:22:07.269963	2026-09-05 03:22:07.295669
114	HT2026072002706	HT20260720027061	HT20260720027062	HT20260720027063	HT20260720027064	1	0	0	0	0	03000125	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:35:40.967457	2026-09-15 06:48:05.526655	2026-09-15 06:48:05.726823
134	HT2026072002174	HT20260720021741	HT20260720021742	HT20260720021743	HT20260720021744	1	0	0	0	0	03000132	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:40:05.825554	2026-09-15 06:48:05.528961	2026-09-15 06:48:05.726825
141	HT2026072002677	HT20260720026771	HT20260720026772	HT20260720026773	HT20260720026774	1	0	0	0	0	03000136	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:41:31.420814	2026-09-15 06:48:05.531187	2026-09-15 06:48:05.726826
8	HT2026072002609	HT20260720026091	HT20260720026092	HT20260720026093	HT20260720026094	1	0	0	0	0	03000014	\N	\N	\N	2026-08-28 00:00:00	2026-08-28 05:52:39.526234	2026-08-31 06:12:27.952554	2026-08-31 06:12:27.987987
365	HT2026072001410	HT20260720014101	HT20260720014102	HT20260720014103	HT20260720014104	1	0	0	0	0	05000221	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:52:31.25952	2026-09-05 10:12:13.062597	2026-09-05 10:12:13.207723
366	HT2026072001398	HT20260720013981	HT20260720013982	HT20260720013983	HT20260720013984	1	0	0	0	0	05000222	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:52:46.173349	2026-09-05 10:12:13.091855	2026-09-05 10:12:13.207723
368	HT2026072001427	HT20260720014271	HT20260720014272	HT20260720014273	HT20260720014274	1	0	0	0	0	05000225	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:53:16.987678	2026-09-05 10:12:13.1005	2026-09-05 10:12:13.207724
369	HT2026072001408	HT20260720014081	HT20260720014082	HT20260720014083	HT20260720014084	1	0	0	0	0	05000226	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:53:42.44991	2026-09-05 10:12:13.0334	2026-09-05 10:12:13.207724
129	HT2026072002734	HT20260720027341	HT20260720027342	HT20260720027343	HT20260720027344	1	0	0	0	0	03000103	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:39:21.221008	2026-09-15 05:50:32.375457	2026-09-15 05:50:32.381468
84	HT2026072001478	HT20260720014781	HT20260720014782	HT20260720014783	HT20260720014784	1	0	0	0	0	03000089	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:28:02.417292	2026-09-15 06:47:55.203847	2026-09-15 06:47:55.349917
87	HT2026072001429	HT20260720014291	HT20260720014292	HT20260720014293	HT20260720014294	1	0	0	0	0	03000097	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:28:20.468676	2026-09-15 06:47:55.206415	2026-09-15 06:47:55.349918
189	HT2026072002576	HT20260720025761	HT20260720025762	HT20260720025763	HT20260720025764	0	0	0	0	0	\N	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:57:31.511465	\N	2026-09-03 02:57:31.511866
101	HT2026072001466	HT20260720014661	HT20260720014662	HT20260720014663	HT20260720014664	1	0	0	0	0	03000092	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:32:27.241496	2026-09-15 06:47:55.211691	2026-09-15 06:47:55.349919
166	HT2026072002250	HT20260720022501	HT20260720022502	HT20260720022503	HT20260720022504	1	0	0	0	0	05000004	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:46:01.691051	2026-09-03 06:50:21.384716	2026-09-03 06:50:21.480982
109	HT2026072002781	HT20260720027811	HT20260720027812	HT20260720027813	HT20260720027814	1	0	0	0	0	03000106	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:34:57.865454	2026-09-15 06:47:55.214212	2026-09-15 06:47:55.34992
181	HT2026072002595	HT20260720025951	HT20260720025952	HT20260720025953	HT20260720025954	1	0	0	0	0	05000020	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:52:29.135823	2026-09-05 03:09:46.026554	2026-09-05 03:09:46.035247
177	HT2026072002256	HT20260720022561	HT20260720022562	HT20260720022563	HT20260720022564	1	0	0	0	0	05000026	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:51:00.158061	2026-09-05 03:14:44.706059	2026-09-05 03:14:44.730698
186	HT2026072002265	HT20260720022651	HT20260720022652	HT20260720022653	HT20260720022654	1	0	0	0	0	05000029	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:56:29.508488	2026-09-05 03:14:44.708812	2026-09-05 03:14:44.730702
193	HT2026072002240	HT20260720022401	HT20260720022402	HT20260720022403	HT20260720022404	1	0	0	0	0	05000130	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 01:49:56.094491	2026-09-05 07:05:38.377252	2026-09-05 07:05:38.552467
119	HT2026072002686	HT20260720026861	HT20260720026862	HT20260720026863	HT20260720026864	1	0	0	0	0	03000139	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:37:26.967859	2026-09-15 06:47:55.216696	2026-09-15 06:47:55.349922
125	HT2026072002118	HT20260720021181	HT20260720021182	HT20260720021183	HT20260720021184	1	0	0	0	0	03000134	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:38:34.488084	2026-09-15 06:47:55.219246	2026-09-15 06:47:55.349923
52	HT2026072001595	HT20260720015951	HT20260720015952	HT20260720015953	HT20260720015954	1	0	0	0	0	03000018	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:04:28.107131	2026-09-15 06:48:05.547197	2026-09-15 06:48:05.726816
55	HT2026072002644	HT20260720026441	HT20260720026442	HT20260720026443	HT20260720026444	1	0	0	0	0	03000029	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:04:54.719074	2026-09-15 06:48:05.549522	2026-09-15 06:48:05.726817
78	HT2026072001473	HT20260720014731	HT20260720014732	HT20260720014733	HT20260720014734	1	0	0	0	0	03000100	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:27:15.056275	2026-09-15 06:48:05.551877	2026-09-15 06:48:05.726819
91	HT2026072001501	HT20260720015011	HT20260720015012	HT20260720015013	HT20260720015014	1	0	0	0	0	03000085	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:29:30.226033	2026-09-15 06:48:05.554264	2026-09-15 06:48:05.72682
94	HT2026072001465	HT20260720014651	HT20260720014652	HT20260720014653	HT20260720014654	1	0	0	0	0	03000102	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:30:26.465382	2026-09-15 06:48:05.556775	2026-09-15 06:48:05.726821
95	HT2026072001418	HT20260720014181	HT20260720014182	HT20260720014183	HT20260720014184	1	0	0	0	0	03000099	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:31:05.352656	2026-09-15 06:48:05.559113	2026-09-15 06:48:05.726822
98	HT2026072001489	HT20260720014891	HT20260720014892	HT20260720014893	HT20260720014894	1	0	0	0	0	03000157	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:31:51.658723	2026-09-15 06:48:05.561276	2026-09-15 06:48:05.726822
112	HT2026072002767	HT20260720027671	HT20260720027672	HT20260720027673	HT20260720027674	1	0	0	0	0	03000118	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:35:26.124696	2026-09-15 06:48:05.563412	2026-09-15 06:48:05.726823
122	HT2026072002720	HT20260720027201	HT20260720027202	HT20260720027203	HT20260720027204	1	0	0	0	0	03000120	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:37:56.605577	2026-09-15 06:48:05.565537	2026-09-15 06:48:05.726824
143	HT2026072002669	HT20260720026691	HT20260720026692	HT20260720026693	HT20260720026694	1	0	0	0	0	03000141	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:46:30.9334	2026-09-15 06:48:05.570322	2026-09-15 06:48:05.726826
144	HT2026072002660	HT20260720026601	HT20260720026602	HT20260720026603	HT20260720026604	1	0	0	0	0	03000142	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:46:35.740965	2026-09-15 06:48:05.572828	2026-09-15 06:48:05.726826
115	HT2026072002698	HT20260720026981	HT20260720026982	HT20260720026983	HT20260720026984	1	0	0	0	0	03000126	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:35:46.910327	2026-09-01 05:31:06.693358	2026-09-01 05:31:06.779712
145	HT2026072002108	HT20260720021081	HT20260720021082	HT20260720021083	HT20260720021084	1	0	0	0	0	03000143	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:46:38.867776	2026-09-15 06:48:05.575175	2026-09-15 06:48:05.726827
370	HT2026072001414	HT20260720014141	HT20260720014142	HT20260720014143	HT20260720014144	1	0	0	0	0	05000227	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:53:59.394793	2026-09-05 10:12:13.128935	2026-09-05 10:12:13.207724
371	HT2026072001420	HT20260720014201	HT20260720014202	HT20260720014203	HT20260720014204	1	0	0	0	0	05000223	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:54:19.188528	2026-09-05 10:12:13.10962	2026-09-05 10:12:13.207725
372	HT2026072001416	HT20260720014161	HT20260720014162	HT20260720014163	HT20260720014164	1	0	0	0	0	05000229	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:54:38.799928	2026-09-05 10:12:13.13835	2026-09-05 10:12:13.207725
120	HT2026072002208	HT20260720022081	HT20260720022082	HT20260720022083	HT20260720022084	1	0	0	0	0	03000108	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:37:41.023882	2026-09-15 05:50:32.377904	2026-09-15 05:50:32.381466
76	HT2026072001479	HT20260720014791	HT20260720014792	HT20260720014793	HT20260720014794	1	0	0	0	0	03000087	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:27:00.833702	2026-09-15 06:47:55.234836	2026-09-15 06:47:55.349917
77	HT2026072001464	HT20260720014641	HT20260720014642	HT20260720014643	HT20260720014644	1	0	0	0	0	03000095	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:27:05.617318	2026-09-15 06:47:55.237385	2026-09-15 06:47:55.349917
85	HT2026072001493	HT20260720014931	HT20260720014932	HT20260720014933	HT20260720014934	1	0	0	0	0	03000090	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:28:07.96694	2026-09-15 06:47:55.240013	2026-09-15 06:47:55.349918
191	HT2026072001074	HT20260720010741	HT20260720010742	HT20260720010743	HT20260720010744	0	0	0	0	0	\N	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 01:48:04.573209	\N	2026-09-04 01:48:04.579373
86	HT2026072001445	HT20260720014451	HT20260720014452	HT20260720014453	HT20260720014454	1	0	0	0	0	03000096	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:28:15.504092	2026-09-15 06:47:55.242686	2026-09-15 06:47:55.349918
96	HT2026072001434	HT20260720014341	HT20260720014342	HT20260720014343	HT20260720014344	1	0	0	0	0	03000112	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:31:16.659654	2026-09-15 06:47:55.24521	2026-09-15 06:47:55.349919
182	HT2026072002123	HT20260720021231	HT20260720021232	HT20260720021233	HT20260720021234	1	0	0	0	0	05000021	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:52:41.756459	2026-09-05 03:09:46.023941	2026-09-05 03:09:46.035247
187	HT2026072002939	HT20260720029391	HT20260720029392	HT20260720029393	HT20260720029394	1	0	0	0	0	05000028	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:56:38.957633	2026-09-05 03:14:44.711319	2026-09-05 03:14:44.730702
178	HT2026072002785	HT20260720027851	HT20260720027852	HT20260720027853	HT20260720027854	1	0	0	0	0	05000034	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:51:15.805206	2026-09-05 03:22:07.25409	2026-09-05 03:22:07.295669
194	HT2026072002279	HT20260720022791	HT20260720022792	HT20260720022793	HT20260720022794	1	0	0	0	0	05000040	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 01:51:21.45166	2026-09-05 03:22:07.250651	2026-09-05 03:22:07.29567
197	HT2026072002287	HT20260720022871	HT20260720022872	HT20260720022873	HT20260720022874	1	0	0	0	0	05000038	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 01:52:05.630566	2026-09-05 03:22:07.233927	2026-09-05 03:22:07.295671
110	HT2026072000528	HT20260720005281	HT20260720005282	HT20260720005283	HT20260720005284	1	0	0	0	0	03000107	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:35:01.666987	2026-09-15 06:47:55.247781	2026-09-15 06:47:55.34992
113	HT2026072002909	HT20260720029091	HT20260720029092	HT20260720029093	HT20260720029094	1	0	0	0	0	03000117	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:35:33.342469	2026-09-15 06:47:55.250349	2026-09-15 06:47:55.349921
123	HT2026072002830	HT20260720028301	HT20260720028302	HT20260720028303	HT20260720028304	1	0	0	0	0	03000128	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:38:05.81573	2026-09-15 06:47:55.252908	2026-09-15 06:47:55.349922
50	HT2026072002617	HT20260720026171	HT20260720026172	HT20260720026173	HT20260720026174	1	0	0	0	0	03000016	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:04:14.898508	2026-09-15 06:48:05.577571	2026-09-15 06:48:05.726815
53	HT2026072002170	HT20260720021701	HT20260720021702	HT20260720021703	HT20260720021704	1	0	0	0	0	03000027	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:04:36.77576	2026-09-15 06:48:05.580018	2026-09-15 06:48:05.726816
79	HT2026072001486	HT20260720014861	HT20260720014862	HT20260720014863	HT20260720014864	1	0	0	0	0	03000101	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:27:22.750133	2026-09-15 06:48:05.582341	2026-09-15 06:48:05.726819
88	HT2026072001482	HT20260720014821	HT20260720014822	HT20260720014823	HT20260720014824	1	0	0	0	0	03000098	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:28:27.266468	2026-09-15 06:48:05.584701	2026-09-15 06:48:05.726819
83	HT2026072001492	HT20260720014921	HT20260720014922	HT20260720014923	HT20260720014924	1	0	0	0	0	03000088	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:27:53.433652	2026-08-31 09:06:09.524322	2026-08-31 09:06:09.582342
90	HT2026072001470	HT20260720014701	HT20260720014702	HT20260720014703	HT20260720014704	1	0	0	0	0	03000080	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:29:23.827006	2026-09-15 06:48:05.587009	2026-09-15 06:48:05.72682
92	HT2026072001472	HT20260720014721	HT20260720014722	HT20260720014723	HT20260720014724	1	0	0	0	0	03000086	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:29:59.543086	2026-09-15 06:48:05.589478	2026-09-15 06:48:05.72682
93	HT2026072001463	HT20260720014631	HT20260720014632	HT20260720014633	HT20260720014634	1	0	0	0	0	03000091	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:30:07.769744	2026-09-15 06:48:05.592162	2026-09-15 06:48:05.726821
99	HT2026072001430	HT20260720014301	HT20260720014302	HT20260720014303	HT20260720014304	1	0	0	0	0	03000093	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:32:04.286242	2026-09-15 06:48:05.594744	2026-09-15 06:48:05.726822
116	HT2026072002699	HT20260720026991	HT20260720026992	HT20260720026993	HT20260720026994	1	0	0	0	0	03000127	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:35:54.720497	2026-09-15 06:48:05.59978	2026-09-15 06:48:05.726823
33	HT2026072002183	HT20260720021831	HT20260720021832	HT20260720021833	HT20260720021834	1	0	0	0	0	03000046	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:01:12.717329	2026-09-15 06:47:55.25857	2026-09-15 06:47:55.349912
161	HT2026072002564	HT20260720025641	HT20260720025642	HT20260720025643	HT20260720025644	1	0	0	0	0	05000001	\N	\N	\N	2026-09-02 00:00:00	2026-09-02 04:23:56.202135	2026-09-03 06:50:21.388632	2026-09-03 06:50:21.480973
162	HT2026072002245	HT20260720022451	HT20260720022452	HT20260720022453	HT20260720022454	1	0	0	0	0	05000002	\N	\N	\N	2026-09-02 00:00:00	2026-09-02 04:24:01.982879	2026-09-03 06:50:21.375529	2026-09-03 06:50:21.480979
373	HT2026072001423	HT20260720014231	HT20260720014232	HT20260720014233	HT20260720014234	1	0	0	0	0	05000230	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:54:57.181097	2026-09-05 10:12:13.104957	2026-09-05 10:12:13.207725
163	HT2026072002254	HT20260720022541	HT20260720022542	HT20260720022543	HT20260720022544	1	0	0	0	0	05000003	\N	\N	\N	2026-09-02 00:00:00	2026-09-02 04:24:07.931467	2026-09-03 06:50:21.378395	2026-09-03 06:50:21.480981
188	HT2026072002577	HT20260720025771	HT20260720025772	HT20260720025773	HT20260720025774	1	0	0	0	0	05000005	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:56:57.361059	2026-09-03 06:50:21.371351	2026-09-03 06:50:21.480983
374	HT2026072001689	HT20260720016891	HT20260720016892	HT20260720016893	HT20260720016894	1	0	0	0	0	05000231	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:55:27.793724	2026-09-05 10:12:13.146022	2026-09-05 10:12:13.207726
190	HT2026072002422	HT20260720024221	HT20260720024222	HT20260720024223	HT20260720024224	1	0	0	0	0	23000001	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 07:20:10.561139	2026-09-03 07:30:04.17141	2026-09-03 07:30:04.176037
34	HT2026072002147	HT20260720021471	HT20260720021472	HT20260720021473	HT20260720021474	1	0	0	0	0	03000041	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:01:20.840801	2026-09-15 06:47:55.261103	2026-09-15 06:47:55.349912
35	HT2026072002163	HT20260720021631	HT20260720021632	HT20260720021633	HT20260720021634	1	0	0	0	0	03000040	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:01:26.459883	2026-09-15 06:47:55.263662	2026-09-15 06:47:55.349913
36	HT2026072003003	HT20260720030031	HT20260720030032	HT20260720030033	HT20260720030034	1	0	0	0	0	03000054	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:01:48.283111	2026-09-15 06:47:55.266223	2026-09-15 06:47:55.349913
192	HT2026072002550	HT20260720025501	HT20260720025502	HT20260720025503	HT20260720025504	1	0	0	0	0	05000006	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 01:48:14.038333	2026-09-05 02:49:34.034815	2026-09-05 02:49:34.080121
195	HT2026072002891	HT20260720028911	HT20260720028912	HT20260720028913	HT20260720028914	1	0	0	0	0	05000036	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 01:51:37.126766	2026-09-05 03:22:07.263211	2026-09-05 03:22:07.29567
37	HT2026072002704	HT20260720027041	HT20260720027042	HT20260720027043	HT20260720027044	1	0	0	0	0	03000057	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:01:54.678156	2026-09-15 06:47:55.268768	2026-09-15 06:47:55.349913
41	HT2026072002180	HT20260720021801	HT20260720021802	HT20260720021803	HT20260720021804	1	0	0	0	0	03000042	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:02:45.22436	2026-09-15 06:47:55.271348	2026-09-15 06:47:55.349914
43	HT2026072003004	HT20260720030041	HT20260720030042	HT20260720030043	HT20260720030044	1	0	0	0	0	03000055	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:03:11.827763	2026-09-15 06:47:55.274165	2026-09-15 06:47:55.349914
44	HT2026072002695	HT20260720026951	HT20260720026952	HT20260720026953	HT20260720026954	1	0	0	0	0	03000056	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:03:22.668859	2026-09-15 06:47:55.276769	2026-09-15 06:47:55.349915
29	HT2026072002153	HT20260720021531	HT20260720021532	HT20260720021533	HT20260720021534	1	0	0	0	0	03000015	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:00:29.620923	2026-08-31 06:12:27.96248	2026-08-31 06:12:27.987988
58	HT2026072002167	HT20260720021671	HT20260720021672	HT20260720021673	HT20260720021674	1	0	0	0	0	03000038	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:05:51.766334	2026-09-15 06:47:55.255799	2026-09-15 06:47:55.349915
30	HT2026072002603	HT20260720026031	HT20260720026032	HT20260720026033	HT20260720026034	1	0	0	0	0	03000020	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:00:42.008047	2026-09-15 06:48:05.615554	2026-09-15 06:48:05.726814
31	HT2026072001607	HT20260720016071	HT20260720016072	HT20260720016073	HT20260720016074	1	0	0	0	0	03000021	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:00:50.908522	2026-09-15 06:48:05.618143	2026-09-15 06:48:05.726814
39	HT2026072003010	HT20260720030101	HT20260720030102	HT20260720030103	HT20260720030104	1	0	0	0	0	03000070	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:02:14.018946	2026-08-31 07:10:59.284829	2026-08-31 07:10:59.401136
51	HT2026072002602	HT20260720026021	HT20260720026022	HT20260720026023	HT20260720026024	1	0	0	0	0	03000017	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:04:20.914797	2026-09-15 06:48:05.62066	2026-09-15 06:48:05.726815
54	HT2026072002622	HT20260720026221	HT20260720026222	HT20260720026223	HT20260720026224	1	0	0	0	0	03000028	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:04:48.922407	2026-09-15 06:48:05.623202	2026-09-15 06:48:05.726816
68	HT2026072002173	HT20260720021731	HT20260720021732	HT20260720021733	HT20260720021734	1	0	0	0	0	03000031	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:08:17.926993	2026-09-15 06:48:05.626	2026-09-15 06:48:05.726817
69	HT2026072002653	HT20260720026531	HT20260720026532	HT20260720026533	HT20260720026534	1	0	0	0	0	03000032	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:08:23.999818	2026-09-15 06:48:05.628605	2026-09-15 06:48:05.726817
70	HT2026072002634	HT20260720026341	HT20260720026342	HT20260720026343	HT20260720026344	1	0	0	0	0	03000033	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:08:29.778146	2026-09-15 06:48:05.631179	2026-09-15 06:48:05.726818
71	HT2026072001598	HT20260720015981	HT20260720015982	HT20260720015983	HT20260720015984	1	0	0	0	0	03000025	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 06:21:54.000458	2026-09-15 06:48:05.633729	2026-09-15 06:48:05.726818
72	HT2026072002654	HT20260720026541	HT20260720026542	HT20260720026543	HT20260720026544	1	0	0	0	0	03000034	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 06:29:20.539649	2026-09-15 06:48:05.636321	2026-09-15 06:48:05.726818
67	HT2026072001497	HT20260720014971	HT20260720014972	HT20260720014973	HT20260720014974	1	0	0	0	0	03000068	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:07:45.623372	2026-08-31 07:10:59.325452	2026-08-31 07:10:59.401141
375	HT2026072001422	HT20260720014221	HT20260720014222	HT20260720014223	HT20260720014224	1	0	0	0	0	05000232	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:55:41.715608	2026-09-05 10:12:13.119067	2026-09-05 10:12:13.207726
199	991835219654	9918352196541	9918352196542	9918352196543	9918352196544	0	0	0	0	0	\N	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 01:53:13.85595	\N	2026-09-04 01:53:13.856511
376	HT2026072001405	HT20260720014051	HT20260720014052	HT20260720014053	HT20260720014054	1	0	0	0	0	05000228	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:56:00.877567	2026-09-05 10:12:13.116457	2026-09-05 10:12:13.207726
377	HT2026072001437	HT20260720014371	HT20260720014372	HT20260720014373	HT20260720014374	1	0	0	0	0	05000237	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:56:21.880103	2026-09-05 10:12:13.04094	2026-09-05 10:12:13.207727
137	HT2026072002220	HT20260720022201	HT20260720022202	HT20260720022203	HT20260720022204	1	0	0	0	0	03000110	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:40:50.644959	2026-08-31 10:49:02.506604	2026-08-31 10:49:02.544801
378	HT2026072001677	HT20260720016771	HT20260720016772	HT20260720016773	HT20260720016774	1	0	0	0	0	05000233	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:56:40.53912	2026-09-05 10:12:13.114219	2026-09-05 10:12:13.207727
147	HT2026072002490	HT20260720024901	HT20260720024902	HT20260720024903	HT20260720024904	1	0	0	0	0	03000154	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:46:49.029846	2026-09-01 05:31:06.626059	2026-09-01 05:31:06.779721
379	HT2026072001438	HT20260720014381	HT20260720014382	HT20260720014383	HT20260720014384	1	0	0	0	0	05000234	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:57:09.334253	2026-09-05 10:12:13.036036	2026-09-05 10:12:13.207727
380	HT2026072001417	HT20260720014171	HT20260720014172	HT20260720014173	HT20260720014174	1	0	0	0	0	05000235	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:58:00.597391	2026-09-05 10:12:13.121635	2026-09-05 10:12:13.207728
381	HT2026072001688	HT20260720016881	HT20260720016882	HT20260720016883	HT20260720016884	1	0	0	0	0	05000236	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:59:36.366889	2026-09-05 10:12:13.143446	2026-09-05 10:12:13.207728
382	HT2026072001435	HT20260720014351	HT20260720014352	HT20260720014353	HT20260720014354	1	0	0	0	0	05000240	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 08:00:16.44259	2026-09-05 10:12:13.102715	2026-09-05 10:12:13.207729
384	HT2026072001444	HT20260720014441	HT20260720014442	HT20260720014443	HT20260720014444	1	0	0	0	0	05000242	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 08:00:37.385875	2026-09-05 10:12:13.048548	2026-09-05 10:12:13.207729
385	HT2026072001428	HT20260720014281	HT20260720014282	HT20260720014283	HT20260720014284	1	0	0	0	0	05000239	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 08:01:13.241126	2026-09-05 10:12:13.135735	2026-09-05 10:12:13.207729
206	HT2026072002873	HT20260720028731	HT20260720028732	HT20260720028733	HT20260720028734	1	0	0	0	0	05000047	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 01:57:28.275682	2026-09-05 13:13:54.256603	2026-09-05 13:13:54.275144
60	HT2026072002683	HT20260720026831	HT20260720026832	HT20260720026833	HT20260720026834	1	0	0	0	0	03000048	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:06:14.044676	2026-09-15 05:46:20.843506	2026-09-15 05:46:20.92016
61	HT2026072002645	HT20260720026451	HT20260720026452	HT20260720026453	HT20260720026454	1	0	0	0	0	03000049	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:06:26.278443	2026-09-15 05:46:20.846047	2026-09-15 05:46:20.920161
65	HT2026072002500	HT20260720025001	HT20260720025002	HT20260720025003	HT20260720025004	1	0	0	0	0	03000066	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:07:30.46354	2026-09-15 05:46:20.848632	2026-09-15 05:46:20.920161
66	HT2026072003007	HT20260720030071	HT20260720030072	HT20260720030073	HT20260720030074	1	0	0	0	0	03000067	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:07:38.121545	2026-09-15 05:46:20.851205	2026-09-15 05:46:20.920161
59	HT2026072002688	HT20260720026881	HT20260720026882	HT20260720026883	HT20260720026884	1	0	0	0	0	03000047	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:05:59.327915	2026-09-15 06:47:55.279386	2026-09-15 06:47:55.349915
62	HT2026072002650	HT20260720026501	HT20260720026502	HT20260720026503	HT20260720026504	1	0	0	0	0	03000058	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:06:35.390209	2026-09-15 06:47:55.281923	2026-09-15 06:47:55.349916
63	HT2026072002483	HT20260720024831	HT20260720024832	HT20260720024833	HT20260720024834	1	0	0	0	0	03000059	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:06:43.192002	2026-09-15 06:47:55.284541	2026-09-15 06:47:55.349916
64	HT2026072002679	HT20260720026791	HT20260720026792	HT20260720026793	HT20260720026794	1	0	0	0	0	03000060	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:06:49.006847	2026-09-15 06:47:55.287684	2026-09-15 06:47:55.349916
140	HT2026072002678	HT20260720026781	HT20260720026782	HT20260720026783	HT20260720026784	1	0	0	0	0	03000124	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:41:19.756685	2026-09-15 06:47:55.290938	2026-09-15 06:47:55.349925
149	HT2026072002184	HT20260720021841	HT20260720021842	HT20260720021843	HT20260720021844	1	0	0	0	0	03000144	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:47:23.981508	2026-09-15 06:48:05.641666	2026-09-15 06:48:05.726827
203	HT2026072002994	HT20260720029941	HT20260720029942	HT20260720029943	HT20260720029944	1	0	0	0	0	05000045	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 01:55:02.053804	2026-09-05 05:23:20.881909	2026-09-05 05:23:20.971407
205	HT2026072002298	HT20260720022981	HT20260720022982	HT20260720022983	HT20260720022984	1	0	0	0	0	05000046	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 01:57:09.604293	2026-09-05 05:23:20.827406	2026-09-05 05:23:20.971409
207	HT2026072002282	HT20260720022821	HT20260720022822	HT20260720022823	HT20260720022824	1	0	0	0	0	05000048	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 01:58:05.782301	2026-09-05 05:23:20.905476	2026-09-05 05:23:20.97141
208	HT2026072002864	HT20260720028641	HT20260720028642	HT20260720028643	HT20260720028644	1	0	0	0	0	05000049	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 01:58:17.156558	2026-09-05 05:23:20.910052	2026-09-05 05:23:20.97141
150	HT2026072002482	HT20260720024821	HT20260720024822	HT20260720024823	HT20260720024824	1	0	0	0	0	03000152	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:47:32.200021	2026-09-15 06:48:05.644239	2026-09-15 06:48:05.726827
151	HT2026072002494	HT20260720024941	HT20260720024942	HT20260720024943	HT20260720024944	1	0	0	0	0	03000156	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:47:37.669694	2026-09-15 06:48:05.646882	2026-09-15 06:48:05.726828
152	HT2026072002665	HT20260720026651	HT20260720026652	HT20260720026653	HT20260720026654	1	0	0	0	0	03000148	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:47:46.313426	2026-09-15 06:48:05.649457	2026-09-15 06:48:05.726828
153	HT2026072002185	HT20260720021851	HT20260720021852	HT20260720021853	HT20260720021854	1	0	0	0	0	03000149	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:47:51.931778	2026-09-15 06:48:05.652061	2026-09-15 06:48:05.726828
156	HT2026072002492	HT20260720024921	HT20260720024922	HT20260720024923	HT20260720024924	1	0	0	0	0	03000146	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:49:10.20893	2026-09-15 06:48:05.654628	2026-09-15 06:48:05.726829
463	HT2026072002957	HT20260720029571	HT20260720029572	HT20260720029573	HT20260720029574	1	0	0	0	0	05000096	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 07:26:23.611849	2026-09-05 10:18:26.103911	2026-09-05 10:18:26.136639
464	HT2026072002966	HT20260720029661	HT20260720029662	HT20260720029663	HT20260720029664	1	0	0	0	0	05000095	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 07:28:29.154374	2026-09-05 10:18:26.101414	2026-09-05 10:18:26.136641
465	HT2026072001469	HT20260720014691	HT20260720014692	HT20260720014693	HT20260720014694	1	0	0	0	0	05000106	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 09:14:45.444391	2026-09-05 10:18:26.098825	2026-09-05 10:18:26.136641
466	HT2026072001494	HT20260720014941	HT20260720014942	HT20260720014943	HT20260720014944	1	0	0	0	0	05000107	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 09:15:10.888839	2026-09-05 10:18:26.106094	2026-09-05 10:18:26.136642
467	HT2026072001485	HT20260720014851	HT20260720014852	HT20260720014853	HT20260720014854	1	0	0	0	0	05000109	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 09:15:40.699701	2026-09-05 10:18:26.12148	2026-09-05 10:18:26.136642
468	HT2026072001498	HT20260720014981	HT20260720014982	HT20260720014983	HT20260720014984	1	0	0	0	0	05000113	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 09:16:02.880252	2026-09-05 10:18:26.116724	2026-09-05 10:18:26.136643
469	HT2026072001509	HT20260720015091	HT20260720015092	HT20260720015093	HT20260720015094	1	0	0	0	0	05000121	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 09:16:25.57509	2026-09-05 10:18:26.096092	2026-09-05 10:18:26.136643
24	HT2026072002489	HT20260720024891	HT20260720024892	HT20260720024893	HT20260720024894	1	0	0	0	0	03000062	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 02:59:26.695396	2026-09-04 02:10:35.530347	2026-09-04 02:10:35.547535
470	HT2026072001505	HT20260720015051	HT20260720015052	HT20260720015053	HT20260720015054	1	0	0	0	0	05000122	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 09:17:15.907761	2026-09-05 10:18:26.123924	2026-09-05 10:18:26.136643
471	HT2026072001507	HT20260720015071	HT20260720015072	HT20260720015073	HT20260720015074	1	0	0	0	0	05000124	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 09:17:42.093247	2026-09-05 10:18:26.119161	2026-09-05 10:18:26.136644
472	HT2026072001515	HT20260720015151	HT20260720015152	HT20260720015153	HT20260720015154	1	0	0	0	0	05000126	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 09:18:11.431643	2026-09-05 10:18:26.110712	2026-09-05 10:18:26.136644
473	HT2026072002931	HT20260720029311	HT20260720029312	HT20260720029313	HT20260720029314	1	0	0	0	0	05000135	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 09:18:49.676769	2026-09-05 10:18:26.108253	2026-09-05 10:18:26.136644
474	HT2026072002326	HT20260720023261	HT20260720023262	HT20260720023263	HT20260720023264	1	0	0	0	0	05000128	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 09:19:18.229282	2026-09-05 10:18:26.113745	2026-09-05 10:18:26.136645
480	HT2026072002673	HT20260720026731	HT20260720026732	HT20260720026733	HT20260720026734	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:34:43.216502	\N	2026-09-06 06:34:43.222348
482	HT2026072001452	HT20260720014521	HT20260720014522	HT20260720014523	HT20260720014524	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:36:12.469179	\N	2026-09-06 06:36:12.469952
484	HT2026072002021	HT20260720020211	HT20260720020212	HT20260720020213	HT20260720020214	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:38:20.674368	\N	2026-09-06 06:38:20.675014
486	HT2026072002016	HT20260720020161	HT20260720020162	HT20260720020163	HT20260720020164	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:38:57.287013	\N	2026-09-06 06:38:57.287479
488	HT2026072001436	HT20260720014361	HT20260720014362	HT20260720014363	HT20260720014364	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:39:26.856351	\N	2026-09-06 06:39:26.857216
489	HT2026072001453	HT20260720014531	HT20260720014532	HT20260720014533	HT20260720014534	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:39:44.474404	\N	2026-09-06 06:39:44.475059
491	HT2026072001459	HT20260720014591	HT20260720014592	HT20260720014593	HT20260720014594	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:40:21.296004	\N	2026-09-06 06:40:21.296478
239	HT2026007002913	HT20260070029131	HT20260070029132	HT20260070029133	HT20260070029134	0	0	0	0	0	\N	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:39:13.962289	\N	2026-09-04 02:39:13.962701
494	HT2026072002015	HT20260720020151	HT20260720020152	HT20260720020153	HT20260720020154	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:41:36.654456	\N	2026-09-06 06:41:36.654864
499	HT2026072001448	HT20260720014481	HT20260720014482	HT20260720014483	HT20260720014484	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:44:21.553808	\N	2026-09-06 06:44:21.554259
236	HT2026072002984	HT20260720029841	HT20260720029842	HT20260720029843	HT20260720029844	1	0	0	0	0	05000098	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:37:37.234066	2026-09-05 07:05:38.406608	2026-09-05 07:05:38.55247
237	HT2026072002885	HT20260720028851	HT20260720028852	HT20260720028853	HT20260720028854	1	0	0	0	0	05000099	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:37:46.514364	2026-09-05 07:05:38.468626	2026-09-05 07:05:38.55247
238	HT2026072002967	HT20260720029671	HT20260720029672	HT20260720029673	HT20260720029674	1	0	0	0	0	05000100	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:38:01.285742	2026-09-05 07:05:38.496833	2026-09-05 07:05:38.552471
242	HT2026072001512	HT20260720015121	HT20260720015122	HT20260720015123	HT20260720015124	1	0	0	0	0	05000125	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:44:27.111122	2026-09-05 07:05:38.391611	2026-09-05 07:05:38.552471
245	HT2026072002865	HT20260720028651	HT20260720028652	HT20260720028653	HT20260720028654	1	0	0	0	0	05000129	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:48:25.398293	2026-09-05 07:05:38.39667	2026-09-05 07:05:38.552472
246	HT2026072001503	HT20260720015031	HT20260720015032	HT20260720015033	HT20260720015034	1	0	0	0	0	05000119	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:48:34.551722	2026-09-05 07:05:38.476312	2026-09-05 07:05:38.552472
247	HT2026072001504	HT20260720015041	HT20260720015042	HT20260720015043	HT20260720015044	1	0	0	0	0	05000118	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:49:04.656908	2026-09-05 07:05:38.499359	2026-09-05 07:05:38.552472
248	HT2026072001487	HT20260720014871	HT20260720014872	HT20260720014873	HT20260720014874	1	0	0	0	0	05000111	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:49:10.579277	2026-09-05 07:05:38.404128	2026-09-05 07:05:38.552473
249	HT2026072001491	HT20260720014911	HT20260720014912	HT20260720014913	HT20260720014914	1	0	0	0	0	05000108	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:49:18.84565	2026-09-05 07:05:38.386667	2026-09-05 07:05:38.552473
250	HT2026072001424	HT20260720014241	HT20260720014242	HT20260720014243	HT20260720014244	1	0	0	0	0	05000127	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:49:39.354385	2026-09-05 07:05:38.358469	2026-09-05 07:05:38.552474
252	HT2026072002968	HT20260720029681	HT20260720029682	HT20260720029683	HT20260720029684	1	0	0	0	0	05000101	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:50:11.57711	2026-09-05 07:05:38.486402	2026-09-05 07:05:38.552474
254	HT2026072002928	HT20260720029281	HT20260720029282	HT20260720029283	HT20260720029284	1	0	0	0	0	05000134	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:56:43.46532	2026-09-05 07:05:38.39418	2026-09-05 07:05:38.552475
255	HT2026072002855	HT20260720028551	HT20260720028552	HT20260720028553	HT20260720028554	1	0	0	0	0	05000133	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:58:19.722384	2026-09-05 07:05:38.379523	2026-09-05 07:05:38.552475
256	HT2026072001518	HT20260720015181	HT20260720015182	HT20260720015183	HT20260720015184	1	0	0	0	0	05000132	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:58:27.019026	2026-09-05 07:05:38.4839	2026-09-05 07:05:38.552475
257	HT2026072001500	HT20260720015001	HT20260720015002	HT20260720015003	HT20260720015004	1	0	0	0	0	05000123	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:58:46.842375	2026-09-05 07:05:38.471205	2026-09-05 07:05:38.552476
258	HT2026072001506	HT20260720015061	HT20260720015062	HT20260720015063	HT20260720015064	1	0	0	0	0	05000136	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:58:55.269468	2026-09-05 07:05:38.366139	2026-09-05 07:05:38.552476
259	HT2026072001516	HT20260720015161	HT20260720015162	HT20260720015163	HT20260720015164	1	0	0	0	0	05000137	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 03:00:12.546458	2026-09-05 07:05:38.478835	2026-09-05 07:05:38.552476
260	HT2026072001496	HT20260720014961	HT20260720014962	HT20260720014963	HT20260720014964	1	0	0	0	0	05000115	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 03:00:37.130201	2026-09-05 07:05:38.463203	2026-09-05 07:05:38.552477
261	HT2026072001499	HT20260720014991	HT20260720014992	HT20260720014993	HT20260720014994	1	0	0	0	0	05000114	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 03:00:55.390488	2026-09-05 07:05:38.381958	2026-09-05 07:05:38.552477
262	HT2026072001484	HT20260720014841	HT20260720014842	HT20260720014843	HT20260720014844	1	0	0	0	0	05000105	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 03:01:29.91822	2026-09-05 07:05:38.353765	2026-09-05 07:05:38.552477
286	HT2026072002899	HT20260720028991	HT20260720028992	HT20260720028993	HT20260720028994	1	0	0	0	0	05000196	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:14:27.388289	2026-09-05 10:12:13.069363	2026-09-05 10:12:13.207711
394	HT2026072002842	HT20260720028421	HT20260720028422	HT20260720028423	HT20260720028424	1	0	0	0	0	05000075	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 05:25:45.182774	2026-09-05 13:13:54.261485	2026-09-05 13:13:54.275145
481	HT2026072002036	HT20260720020361	HT20260720020362	HT20260720020363	HT20260720020364	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:34:50.620299	\N	2026-09-06 06:34:50.621012
483	HT2026072001441	HT20260720014411	HT20260720014412	HT20260720014413	HT20260720014414	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:37:19.256624	\N	2026-09-06 06:37:19.257159
487	HT2026072001626	HT20260720016261	HT20260720016262	HT20260720016263	HT20260720016264	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:39:10.283242	\N	2026-09-06 06:39:10.283611
492	HT2026072001439	HT20260720014391	HT20260720014392	HT20260720014393	HT20260720014394	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:40:26.540547	\N	2026-09-06 06:40:26.54137
496	HT2026072002033	HT20260720020331	HT20260720020332	HT20260720020333	HT20260720020334	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:43:38.153976	\N	2026-09-06 06:43:38.154441
497	HT2026072001454	HT20260720014541	HT20260720014542	HT20260720014543	HT20260720014544	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:44:01.652011	\N	2026-09-06 06:44:01.652447
501	HT2026072001702	HT20260720017021	HT20260720017022	HT20260720017023	HT20260720017024	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:44:55.624304	\N	2026-09-06 06:44:55.62456
503	HT2026072001373	HT20260720013731	HT20260720013732	HT20260720013733	HT20260720013734	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:46:12.941071	\N	2026-09-06 06:46:12.941354
267	HT2026072002339	HT20260720023391	HT20260720023392	HT20260720023393	HT20260720023394	1	0	0	0	0	05000072	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 03:03:15.960545	2026-09-05 05:23:20.84531	2026-09-05 05:23:20.971423
268	HT2026072002921	HT20260720029211	HT20260720029212	HT20260720029213	HT20260720029214	1	0	0	0	0	05000073	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 03:03:22.344133	2026-09-05 05:23:20.907765	2026-09-05 05:23:20.971423
269	HT2026072002975	HT20260720029751	HT20260720029752	HT20260720029753	HT20260720029754	1	0	0	0	0	05000078	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 03:03:36.029456	2026-09-05 05:23:20.903007	2026-09-05 05:23:20.971424
276	HT2026072002969	HT20260720029691	HT20260720029692	HT20260720029693	HT20260720029694	1	0	0	0	0	05000086	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 03:13:34.850367	2026-09-05 05:23:20.8476	2026-09-05 05:23:20.971424
266	HT2026072002281	HT20260720022811	HT20260720022812	HT20260720022813	HT20260720022814	1	0	0	0	0	05000131	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 03:03:11.894809	2026-09-05 07:05:38.401611	2026-09-05 07:05:38.552479
270	HT2026072001508	HT20260720015081	HT20260720015082	HT20260720015083	HT20260720015084	1	0	0	0	0	05000138	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 03:03:44.15923	2026-09-05 07:05:38.466006	2026-09-05 07:05:38.552479
271	HT2026072001510	HT20260720015101	HT20260720015102	HT20260720015103	HT20260720015104	1	0	0	0	0	05000120	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 03:03:54.045226	2026-09-05 07:05:38.494225	2026-09-05 07:05:38.552479
272	HT2026072001388	HT20260720013881	HT20260720013882	HT20260720013883	HT20260720013884	1	0	0	0	0	05000116	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 03:05:36.44275	2026-09-05 07:05:38.384188	2026-09-05 07:05:38.55248
280	HT2026072001623	HT20260720016231	HT20260720016232	HT20260720016233	HT20260720016234	1	0	0	0	0	05000175	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:13:42.911102	2026-09-05 09:47:49.476953	2026-09-05 09:47:49.625853
283	HT2026072001635	HT20260720016351	HT20260720016352	HT20260720016353	HT20260720016354	1	0	0	0	0	05000187	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:14:09.915341	2026-09-05 09:47:49.461914	2026-09-05 09:47:49.625854
506	HT2026072001442	HT20260720014421	HT20260720014422	HT20260720014423	HT20260720014424	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:46:32.215571	\N	2026-09-06 06:46:32.216358
287	HT2026072002320	HT20260720023201	HT20260720023202	HT20260720023203	HT20260720023204	1	0	0	0	0	05000197	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:14:42.897831	2026-09-05 10:12:13.094032	2026-09-05 10:12:13.207713
289	HT2026072001404	HT20260720014041	HT20260720014042	HT20260720014043	HT20260720014044	1	0	0	0	0	05000206	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:15:14.503785	2026-09-05 10:12:13.096221	2026-09-05 10:12:13.207714
485	HT2026072001456	HT20260720014561	HT20260720014562	HT20260720014563	HT20260720014564	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:38:45.129676	\N	2026-09-06 06:38:45.13035
490	HT2026072002010	HT20260720020101	HT20260720020102	HT20260720020103	HT20260720020104	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:40:01.455683	\N	2026-09-06 06:40:01.456059
493	HT2026072001432	HT20260720014321	HT20260720014322	HT20260720014323	HT20260720014324	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:40:36.882886	\N	2026-09-06 06:40:36.88343
495	HT2026072001419	HT20260720014191	HT20260720014192	HT20260720014193	HT20260720014194	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:43:00.079252	\N	2026-09-06 06:43:00.079575
275	HT2026072001594	HT20260720015941	HT20260720015942	HT20260720015943	HT20260720015944	1	0	0	0	0	05000089	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 03:07:41.533659	2026-09-05 05:23:20.92043	2026-09-05 05:23:20.971424
273	HT2026072001460	HT20260720014601	HT20260720014602	HT20260720014603	HT20260720014604	1	0	0	0	0	05000110	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 03:06:05.980867	2026-09-05 07:05:38.502002	2026-09-05 07:05:38.55248
274	HT2026072001690	HT20260720016901	HT20260720016902	HT20260720016903	HT20260720016904	1	0	0	0	0	05000112	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 03:07:02.801718	2026-09-05 07:05:38.370753	2026-09-05 07:05:38.55248
277	HT2026072002959	HT20260720029591	HT20260720029592	HT20260720029593	HT20260720029594	1	0	0	0	0	05000097	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 03:13:46.666003	2026-09-05 07:05:38.473765	2026-09-05 07:05:38.552481
281	HT2026072001630	HT20260720016301	HT20260720016302	HT20260720016303	HT20260720016304	1	0	0	0	0	05000174	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:13:47.672328	2026-09-05 09:47:49.451408	2026-09-05 09:47:49.625853
284	HT2026072001632	HT20260720016321	HT20260720016322	HT20260720016323	HT20260720016324	1	0	0	0	0	05000186	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:14:16.605795	2026-09-05 09:47:49.507695	2026-09-05 09:47:49.625854
498	HT2026072001709	HT20260720017091	HT20260720017092	HT20260720017093	HT20260720017094	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:44:13.880389	\N	2026-09-06 06:44:13.880861
502	HT2026072002774	HT20260720027741	HT20260720027742	HT20260720027743	HT20260720027744	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:45:07.846908	\N	2026-09-06 06:45:07.847182
504	HT2026072001433	HT20260720014331	HT20260720014332	HT20260720014333	HT20260720014334	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:46:20.278351	\N	2026-09-06 06:46:20.278932
288	HT2026072002971	HT20260720029711	HT20260720029712	HT20260720029713	HT20260720029714	1	0	0	0	0	05000198	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:14:52.906887	2026-09-05 10:12:13.038498	2026-09-05 10:12:13.207713
290	HT2026072002972	HT20260720029721	HT20260720029722	HT20260720029723	HT20260720029724	1	0	0	0	0	05000205	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:15:27.574664	2026-09-05 10:12:13.089692	2026-09-05 10:12:13.207714
282	HT2026072001502	HT20260720015021	HT20260720015022	HT20260720015023	HT20260720015024	0	0	0	0	0	\N	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:13:59.846297	\N	2026-09-04 05:13:59.846723
291	HT2026072002989	HT20260720029891	HT20260720029892	HT20260720029893	HT20260720029894	1	0	0	0	0	05000204	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:15:36.216387	2026-09-05 10:12:13.140919	2026-09-05 10:12:13.207714
297	HT2026072002324	HT20260720023241	HT20260720023242	HT20260720023243	HT20260720023244	1	0	0	0	0	05000199	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:16:57.899605	2026-09-05 10:12:13.126707	2026-09-05 10:12:13.207715
298	HT2026072001394	HT20260720013941	HT20260720013942	HT20260720013943	HT20260720013944	1	0	0	0	0	05000207	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:17:13.066713	2026-09-05 10:12:13.133441	2026-09-05 10:12:13.207715
304	HT2026072002963	HT20260720029631	HT20260720029632	HT20260720029633	HT20260720029634	1	0	0	0	0	05000200	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:19:11.862334	2026-09-05 10:12:13.098391	2026-09-05 10:12:13.207715
305	HT2026072002331	HT20260720023311	HT20260720023312	HT20260720023313	HT20260720023314	1	0	0	0	0	05000201	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:19:22.03925	2026-09-05 10:12:13.066959	2026-09-05 10:12:13.207716
306	HT2026072002747	HT20260720027471	HT20260720027472	HT20260720027473	HT20260720027474	1	0	0	0	0	05000202	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:19:34.226941	2026-09-05 10:12:13.080998	2026-09-05 10:12:13.207716
311	HT2026072002543	HT20260720025431	HT20260720025432	HT20260720025433	HT20260720025434	1	0	0	0	0	05000195	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:21:10.498166	2026-09-05 10:12:13.055605	2026-09-05 10:12:13.207716
312	HT2026072002325	HT20260720023251	HT20260720023252	HT20260720023253	HT20260720023254	1	0	0	0	0	05000203	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:21:30.498658	2026-09-05 10:12:13.05106	2026-09-05 10:12:13.207717
500	HT2026072001706	HT20260720017061	HT20260720017062	HT20260720017063	HT20260720017064	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:44:43.884125	\N	2026-09-06 06:44:43.884458
505	HT2026072002001	HT20260720020011	HT20260720020012	HT20260720020013	HT20260720020014	0	0	0	0	0	\N	\N	\N	\N	2026-09-06 00:00:00	2026-09-06 06:46:26.114863	\N	2026-09-06 06:46:26.115615
279	HT2026072001614	HT20260720016141	HT20260720016142	HT20260720016143	HT20260720016144	1	0	0	0	0	05000176	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:13:36.728452	2026-09-05 09:47:49.510223	2026-09-05 09:47:49.625851
285	HT2026072001636	HT20260720016361	HT20260720016362	HT20260720016363	HT20260720016364	1	0	0	0	0	05000185	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:14:21.249988	2026-09-05 09:47:49.464124	2026-09-05 09:47:49.625854
292	HT2026072001640	HT20260720016401	HT20260720016402	HT20260720016403	HT20260720016404	1	0	0	0	0	05000177	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:15:52.578814	2026-09-05 09:47:49.532612	2026-09-05 09:47:49.625855
293	HT2026072001653	HT20260720016531	HT20260720016532	HT20260720016533	HT20260720016534	1	0	0	0	0	05000188	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:16:00.626573	2026-09-05 09:47:49.481313	2026-09-05 09:47:49.625855
351	HT2026072001707	HT20260720017071	HT20260720017072	HT20260720017073	HT20260720017074	1	0	0	0	0	05000238	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:47:36.576272	2026-09-05 10:12:13.064776	2026-09-05 10:12:13.207718
354	HT2026072000530	HT20260720005301	HT20260720005302	HT20260720005303	HT20260720005304	1	0	0	0	0	05000210	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:48:29.162913	2026-09-05 10:12:13.083169	2026-09-05 10:12:13.207719
355	HT2026072001425	HT20260720014251	HT20260720014252	HT20260720014253	HT20260720014254	1	0	0	0	0	05000208	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:48:49.32655	2026-09-05 10:12:13.076641	2026-09-05 10:12:13.207719
359	HT2026072001374	HT20260720013741	HT20260720013742	HT20260720013743	HT20260720013744	1	0	0	0	0	05000214	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:50:12.742749	2026-09-05 10:12:13.053453	2026-09-05 10:12:13.207721
364	HT2026072001692	HT20260720016921	HT20260720016922	HT20260720016923	HT20260720016924	1	0	0	0	0	05000220	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:52:17.167222	2026-09-05 10:12:13.131245	2026-09-05 10:12:13.207722
3	HT2026072001599	HT20260720015991	HT20260720015992	HT20260720015993	HT20260720015994	1	0	0	0	0	03000001	\N	\N	\N	2026-08-28 00:00:00	2026-08-28 05:52:11.675635	2026-09-15 05:46:20.757876	2026-09-15 05:46:20.92015
4	HT2026072001585	HT20260720015851	HT20260720015852	HT20260720015853	HT20260720015854	1	0	0	0	0	03000002	\N	\N	\N	2026-08-28 00:00:00	2026-08-28 05:52:15.993354	2026-09-15 05:46:20.809088	2026-09-15 05:46:20.920153
342	HT2026072001612	HT20260720016121	HT20260720016122	HT20260720016123	HT20260720016124	1	0	0	0	0	05000143	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:29:29.828994	2026-09-05 07:05:38.368631	2026-09-05 07:05:38.552483
332	HT2026072001620	HT20260720016201	HT20260720016202	HT20260720016203	HT20260720016204	1	0	0	0	0	05000172	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:26:00.300361	2026-09-05 09:47:49.55059	2026-09-05 09:47:49.625865
333	HT2026072001645	HT20260720016451	HT20260720016452	HT20260720016453	HT20260720016454	1	0	0	0	0	05000147	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:26:29.308448	2026-09-05 09:47:49.459084	2026-09-05 09:47:49.625865
338	HT2026072001610	HT20260720016101	HT20260720016102	HT20260720016103	HT20260720016104	1	0	0	0	0	05000154	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:27:26.883658	2026-09-05 09:47:49.485654	2026-09-05 09:47:49.625866
341	HT2026072001628	HT20260720016281	HT20260720016282	HT20260720016283	HT20260720016284	1	0	0	0	0	05000165	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:29:07.277075	2026-09-05 09:47:49.490027	2026-09-05 09:47:49.625867
345	HT2026072001654	HT20260720016541	HT20260720016542	HT20260720016543	HT20260720016544	1	0	0	0	0	05000157	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:29:48.835212	2026-09-05 09:47:49.522385	2026-09-05 09:47:49.625868
348	HT2026072001622	HT20260720016221	HT20260720016222	HT20260720016223	HT20260720016224	1	0	0	0	0	05000173	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:30:16.676209	2026-09-05 09:47:49.548043	2026-09-05 09:47:49.625869
5	HT2026072001596	HT20260720015961	HT20260720015962	HT20260720015963	HT20260720015964	1	0	0	0	0	03000003	\N	\N	\N	2026-08-28 00:00:00	2026-08-28 05:52:20.131141	2026-09-15 05:46:20.763222	2026-09-15 05:46:20.920153
6	HT2026072001601	HT20260720016011	HT20260720016012	HT20260720016013	HT20260720016014	1	0	0	0	0	03000012	\N	\N	\N	2026-08-28 00:00:00	2026-08-28 05:52:28.134082	2026-09-15 05:46:20.754968	2026-09-15 05:46:20.920154
7	HT2026072002615	HT20260720026151	HT20260720026152	HT20260720026153	HT20260720026154	1	0	0	0	0	03000013	\N	\N	\N	2026-08-28 00:00:00	2026-08-28 05:52:34.472402	2026-09-15 05:46:20.76765	2026-09-15 05:46:20.920154
11	HT2026072001588	HT20260720015881	HT20260720015882	HT20260720015883	HT20260720015884	1	0	0	0	0	03000005	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 02:56:58.662255	2026-09-15 05:46:20.765406	2026-09-15 05:46:20.920154
12	HT2026072001587	HT20260720015871	HT20260720015872	HT20260720015873	HT20260720015874	1	0	0	0	0	03000006	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 02:57:15.664429	2026-09-15 05:46:20.811571	2026-09-15 05:46:20.920155
13	HT2026072002628	HT20260720026281	HT20260720026282	HT20260720026283	HT20260720026284	1	0	0	0	0	03000011	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 02:57:22.59717	2026-09-15 05:46:20.760935	2026-09-15 05:46:20.920155
17	HT2026072002179	HT20260720021791	HT20260720021792	HT20260720021793	HT20260720021794	1	0	0	0	0	03000035	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 02:57:48.444756	2026-09-15 05:46:20.76977	2026-09-15 05:46:20.920155
25	HT2026072002498	HT20260720024981	HT20260720024982	HT20260720024983	HT20260720024984	1	0	0	0	0	03000063	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 02:59:32.610847	2026-09-15 05:46:20.827757	2026-09-15 05:46:20.920156
26	HT2026072002479	HT20260720024791	HT20260720024792	HT20260720024793	HT20260720024794	1	0	0	0	0	03000064	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 02:59:39.369365	2026-09-15 05:46:20.830061	2026-09-15 05:46:20.920156
27	HT2026072001600	HT20260720016001	HT20260720016002	HT20260720016003	HT20260720016004	1	0	0	0	0	03000004	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:00:14.271146	2026-09-15 05:46:20.813773	2026-09-15 05:46:20.920157
28	HT2026072001604	HT20260720016041	HT20260720016042	HT20260720016043	HT20260720016044	1	0	0	0	0	03000007	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:00:22.163294	2026-09-15 05:46:20.816165	2026-09-15 05:46:20.920157
38	HT2026072001511	HT20260720015111	HT20260720015112	HT20260720015113	HT20260720015114	1	0	0	0	0	03000065	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:02:02.95432	2026-09-15 05:46:20.833133	2026-09-15 05:46:20.920157
42	HT2026072002671	HT20260720026711	HT20260720026712	HT20260720026713	HT20260720026714	1	0	0	0	0	03000050	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:02:50.761339	2026-09-15 05:46:20.835621	2026-09-15 05:46:20.920158
45	HT2026072002486	HT20260720024861	HT20260720024862	HT20260720024863	HT20260720024864	1	0	0	0	0	03000061	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:03:29.150705	2026-09-15 05:46:20.83826	2026-09-15 05:46:20.920158
46	HT2026072003006	HT20260720030061	HT20260720030062	HT20260720030063	HT20260720030064	1	0	0	0	0	03000069	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:03:39.414352	2026-09-15 05:46:20.840924	2026-09-15 05:46:20.920158
47	HT2026072001583	HT20260720015831	HT20260720015832	HT20260720015833	HT20260720015834	1	0	0	0	0	03000008	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:03:52.698272	2026-09-15 05:46:20.818358	2026-09-15 05:46:20.920159
48	HT2026072001605	HT20260720016051	HT20260720016052	HT20260720016053	HT20260720016054	1	0	0	0	0	03000009	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:03:59.526102	2026-09-15 05:46:20.820771	2026-09-15 05:46:20.920159
49	HT2026072001593	HT20260720015931	HT20260720015932	HT20260720015933	HT20260720015934	1	0	0	0	0	03000010	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:04:06.016388	2026-09-15 05:46:20.7722	2026-09-15 05:46:20.920159
56	HT2026072002655	HT20260720026551	HT20260720026552	HT20260720026553	HT20260720026554	1	0	0	0	0	03000036	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:05:40.022653	2026-09-15 05:46:20.823185	2026-09-15 05:46:20.92016
57	HT2026072002596	HT20260720025961	HT20260720025962	HT20260720025963	HT20260720025964	1	0	0	0	0	03000037	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 03:05:45.795256	2026-09-15 05:46:20.825541	2026-09-15 05:46:20.92016
73	HT2026072001461	HT20260720014611	HT20260720014612	HT20260720014613	HT20260720014614	1	0	0	0	0	03000071	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:26:32.750896	2026-09-15 05:46:20.788028	2026-09-15 05:46:20.920162
74	HT2026072002499	HT20260720024991	HT20260720024992	HT20260720024993	HT20260720024994	1	0	0	0	0	03000076	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:26:42.752872	2026-09-15 05:46:20.790322	2026-09-15 05:46:20.920162
75	HT2026072001488	HT20260720014881	HT20260720014882	HT20260720014883	HT20260720014884	1	0	0	0	0	03000084	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:26:53.782906	2026-09-15 05:46:20.774833	2026-09-15 05:46:20.920162
80	HT2026072001471	HT20260720014711	HT20260720014712	HT20260720014713	HT20260720014714	1	0	0	0	0	03000077	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:27:35.640734	2026-09-15 05:46:20.792447	2026-09-15 05:46:20.920163
349	HT2026072001681	HT20260720016811	HT20260720016812	HT20260720016813	HT20260720016814	1	0	0	0	0	05000244	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:46:29.86644	2026-09-05 10:12:13.124411	2026-09-05 10:12:13.207717
335	HT2026072002852	HT20260720028521	HT20260720028522	HT20260720028523	HT20260720028524	0	0	0	0	0	\N	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:26:49.580567	\N	2026-09-04 05:26:49.580777
350	HT2026072001719	HT20260720017191	HT20260720017192	HT20260720017193	HT20260720017194	1	0	0	0	0	05000243	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:46:57.976576	2026-09-05 10:12:13.045963	2026-09-05 10:12:13.207717
353	HT2026072001683	HT20260720016831	HT20260720016832	HT20260720016833	HT20260720016834	1	0	0	0	0	05000211	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:48:15.204863	2026-09-05 10:12:13.071914	2026-09-05 10:12:13.207719
358	HT2026072001431	HT20260720014311	HT20260720014312	HT20260720014313	HT20260720014314	1	0	0	0	0	05000213	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:49:51.126103	2026-09-05 10:12:13.085365	2026-09-05 10:12:13.20772
361	Fn:206078001400	Fn:2060780014001	Fn:2060780014002	Fn:2060780014003	Fn:2060780014004	1	0	0	0	0	05000216	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:50:37.847672	2026-09-05 10:12:13.043392	2026-09-05 10:12:13.207721
343	HT2026072001514	HT20260720015141	HT20260720015142	HT20260720015143	HT20260720015144	1	0	0	0	0	05000144	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:29:35.941617	2026-09-05 07:05:38.481349	2026-09-05 07:05:38.552483
334	FT2026072002852	FT20260720028521	FT20260720028522	FT20260720028523	FT20260720028524	1	0	0	0	0	05000148	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:26:37.24042	2026-09-05 09:47:49.51465	2026-09-05 09:47:49.625865
336	HT2026072001637	HT20260720016371	HT20260720016372	HT20260720016373	HT20260720016374	1	0	0	0	0	05000156	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:27:10.246671	2026-09-05 09:47:49.487828	2026-09-05 09:47:49.625866
339	HT2026072001634	HT20260720016341	HT20260720016342	HT20260720016343	HT20260720016344	1	0	0	0	0	05000167	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:27:34.37202	2026-09-05 09:47:49.483458	2026-09-05 09:47:49.625867
346	HT2026072001606	HT20260720016061	HT20260720016062	HT20260720016063	HT20260720016064	1	0	0	0	0	05000160	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:29:57.136782	2026-09-05 09:47:49.537747	2026-09-05 09:47:49.625868
363	HT2026072002019	HT20260720020191	HT20260720020192	HT20260720020193	HT20260720020194	1	0	0	0	0	05000219	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:51:45.454185	2026-09-05 10:12:13.087537	2026-09-05 10:12:13.207722
367	HT2026072001421	HT20260720014211	HT20260720014212	HT20260720014213	HT20260720014214	1	0	0	0	0	05000224	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:53:04.303687	2026-09-05 10:12:13.057876	2026-09-05 10:12:13.207723
81	HT2026072002491	HT20260720024911	HT20260720024912	HT20260720024913	HT20260720024914	1	0	0	0	0	03000078	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:27:40.719446	2026-09-15 05:46:20.777008	2026-09-15 05:46:20.920163
82	HT2026072001475	HT20260720014751	HT20260720014752	HT20260720014753	HT20260720014754	1	0	0	0	0	03000079	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:27:45.331851	2026-09-15 05:46:20.794613	2026-09-15 05:46:20.920163
89	HT2021963001481	HT20219630014811	HT20219630014812	HT20219630014813	HT20219630014814	1	0	0	0	0	03000072	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:28:56.168535	2026-09-15 05:46:20.796732	2026-09-15 05:46:20.920164
97	HT2026072001480	HT20260720014801	HT20260720014802	HT20260720014803	HT20260720014804	1	0	0	0	0	03000104	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:31:22.629358	2026-09-15 05:46:20.798828	2026-09-15 05:46:20.920164
100	HT2026072000533	HT20260720005331	HT20260720005332	HT20260720005333	HT20260720005334	1	0	0	0	0	03000094	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:32:13.776263	2026-09-15 05:46:20.801428	2026-09-15 05:46:20.920164
102	HT2026072001476	HT20260720014761	HT20260720014762	HT20260720014763	HT20260720014764	1	0	0	0	0	03000081	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:32:33.094841	2026-09-15 05:46:20.779202	2026-09-15 05:46:20.920165
103	HT2026072001468	HT20260720014681	HT20260720014682	HT20260720014683	HT20260720014684	1	0	0	0	0	03000082	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:32:40.174103	2026-09-15 05:46:20.781313	2026-09-15 05:46:20.920165
104	HT2026072001483	HT20260720014831	HT20260720014832	HT20260720014833	HT20260720014834	1	0	0	0	0	03000073	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:32:51.401436	2026-09-15 05:46:20.803828	2026-09-15 05:46:20.920166
105	HT2026072002462	HT20260720024621	HT20260720024622	HT20260720024623	HT20260720024624	1	0	0	0	0	03000074	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:32:57.061645	2026-09-15 05:46:20.805971	2026-09-15 05:46:20.920166
106	HT2026072002487	HT20260720024871	HT20260720024872	HT20260720024873	HT20260720024874	1	0	0	0	0	03000075	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:33:02.743766	2026-09-15 05:46:20.783515	2026-09-15 05:46:20.920166
107	HT2026072001490	HT20260720014901	HT20260720014902	HT20260720014903	HT20260720014904	1	0	0	0	0	03000083	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:33:23.097646	2026-09-15 05:46:20.853802	2026-09-15 05:46:20.920167
136	HT2026072002014	HT20260720020141	HT20260720020142	HT20260720020143	HT20260720020144	1	0	0	0	0	03000109	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:40:44.795262	2026-09-15 05:46:20.856568	2026-09-15 05:46:20.920167
139	HT2026072002910	HT20260720029101	HT20260720029102	HT20260720029103	HT20260720029104	1	0	0	0	0	03000140	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:41:07.037451	2026-09-15 05:46:20.78583	2026-09-15 05:46:20.920167
352	HT2026072001426	HT20260720014261	HT20260720014262	HT20260720014263	HT20260720014264	1	0	0	0	0	05000212	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:47:56.866874	2026-09-05 10:12:13.111949	2026-09-05 10:12:13.207718
356	HT2026072001656	HT20260720016561	HT20260720016562	HT20260720016563	HT20260720016564	1	0	0	0	0	05000209	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:49:04.276905	2026-09-05 10:12:13.078809	2026-09-05 10:12:13.20772
357	HT2026072001406	HT20260720014061	HT20260720014062	HT20260720014063	HT20260720014064	1	0	0	0	0	05000217	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:49:28.638594	2026-09-05 10:12:13.074354	2026-09-05 10:12:13.20772
360	HT2026072001412	HT20260720014121	HT20260720014122	HT20260720014123	HT20260720014124	1	0	0	0	0	05000215	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 07:50:26.244755	2026-09-05 10:12:13.060311	2026-09-05 10:12:13.207721
383	HT2026072001443	HT20260720014431	HT20260720014432	HT20260720014433	HT20260720014434	1	0	0	0	0	05000241	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 08:00:27.032445	2026-09-05 10:13:12.787018	2026-09-05 10:13:12.791276
164	HT2026072001440	HT20260720014401	HT20260720014402	HT20260720014403	HT20260720014404	1	0	0	0	0	05000014	\N	\N	\N	2026-09-02 00:00:00	2026-09-02 04:24:15.506175	2026-09-05 02:49:34.003446	2026-09-05 02:49:34.080115
167	HT2026072002591	HT20260720025911	HT20260720025912	HT20260720025913	HT20260720025914	1	0	0	0	0	05000015	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:46:52.215231	2026-09-05 02:49:34.029578	2026-09-05 02:49:34.080117
170	HT2026072002570	HT20260720025701	HT20260720025702	HT20260720025703	HT20260720025704	1	0	0	0	0	05000008	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:48:55.925862	2026-09-05 02:49:34.027034	2026-09-05 02:49:34.080117
171	HT2026072002575	HT20260720025751	HT20260720025752	HT20260720025753	HT20260720025754	1	0	0	0	0	05000009	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:49:10.577568	2026-09-05 02:49:34.006899	2026-09-05 02:49:34.080118
174	HT2026072002136	HT20260720021361	HT20260720021362	HT20260720021363	HT20260720021364	1	0	0	0	0	05000018	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:50:10.808319	2026-09-05 02:49:34.032232	2026-09-05 02:49:34.080119
175	HT2026072002144	HT20260720021441	HT20260720021442	HT20260720021443	HT20260720021444	1	0	0	0	0	05000017	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:50:21.262921	2026-09-05 02:49:34.015189	2026-09-05 02:49:34.080119
184	HT2026072000529	HT20260720005291	HT20260720005292	HT20260720005293	HT20260720005294	1	0	0	0	0	05000012	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:53:05.063057	2026-09-05 02:49:34.037503	2026-09-05 02:49:34.08012
185	HT2026072002561	HT20260720025611	HT20260720025612	HT20260720025613	HT20260720025614	1	0	0	0	0	05000013	\N	\N	\N	2026-09-03 00:00:00	2026-09-03 02:53:14.89177	2026-09-05 02:49:34.023948	2026-09-05 02:49:34.08012
386	HT2026072002590	HT20260720025901	HT20260720025902	HT20260720025903	HT20260720025904	1	0	0	0	0	05000016	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 02:48:59.475528	2026-09-05 03:09:46.016104	2026-09-05 03:09:46.035248
108	HT2026072002820	HT20260720028201	HT20260720028202	HT20260720028203	HT20260720028204	1	0	0	0	0	03000105	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:34:54.221056	2026-09-15 06:47:55.167749	2026-09-15 06:47:55.34992
111	HT2026072002718	HT20260720027181	HT20260720027182	HT20260720027183	HT20260720027184	1	0	0	0	0	03000119	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:35:06.617722	2026-09-15 06:47:55.17554	2026-09-15 06:47:55.349921
118	HT2026072002657	HT20260720026571	HT20260720026572	HT20260720026573	HT20260720026574	1	0	0	0	0	03000138	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:37:18.767525	2026-09-15 06:47:55.178165	2026-09-15 06:47:55.349921
196	HT2026072002276	HT20260720022761	HT20260720022762	HT20260720022763	HT20260720022764	1	0	0	0	0	05000037	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 01:51:48.305938	2026-09-05 03:22:07.256643	2026-09-05 03:22:07.29567
198	HT2026072002277	HT20260720022771	HT20260720022772	HT20260720022773	HT20260720022774	1	0	0	0	0	05000039	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 01:52:21.318139	2026-09-05 03:22:07.246283	2026-09-05 03:22:07.295671
200	HT2026072002719	HT20260720027191	HT20260720027192	HT20260720027193	HT20260720027194	1	0	0	0	0	05000042	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 01:53:32.695725	2026-09-05 03:22:07.272159	2026-09-05 03:22:07.295672
201	HT2026072002973	HT20260720029731	HT20260720029732	HT20260720029733	HT20260720029734	1	0	0	0	0	05000043	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 01:53:49.462528	2026-09-05 03:22:07.276433	2026-09-05 03:22:07.295672
202	HT2026072002283	HT20260720022831	HT20260720022832	HT20260720022833	HT20260720022834	1	0	0	0	0	05000044	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 01:54:18.258711	2026-09-05 03:22:07.267737	2026-09-05 03:22:07.295672
121	HT2026072002764	HT20260720027641	HT20260720027642	HT20260720027643	HT20260720027644	1	0	0	0	0	03000111	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:37:47.485788	2026-09-15 06:47:55.170285	2026-09-15 06:47:55.349922
124	HT2026072002701	HT20260720027011	HT20260720027012	HT20260720027013	HT20260720027014	1	0	0	0	0	03000129	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:38:27.643681	2026-09-15 06:47:55.180699	2026-09-15 06:47:55.349923
390	HT2026072002597	HT20260720025971	HT20260720025972	HT20260720025973	HT20260720025974	1	0	0	0	0	05000027	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 03:24:01.887982	2026-09-05 03:26:45.733866	2026-09-05 03:26:45.740426
126	HT2026072002715	HT20260720027151	HT20260720027152	HT20260720027153	HT20260720027154	1	0	0	0	0	03000135	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:38:44.239622	2026-09-15 06:47:55.221725	2026-09-15 06:47:55.349923
337	HT2026072001646	HT20260720016461	HT20260720016462	HT20260720016463	HT20260720016464	1	0	0	0	0	05000155	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:27:19.654856	2026-09-05 09:47:49.512414	2026-09-05 09:47:49.625866
128	HT2026072001723	HT20260720017231	HT20260720017232	HT20260720017233	HT20260720017234	1	0	0	0	0	03000113	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:39:09.023431	2026-09-15 06:47:55.17274	2026-09-15 06:47:55.349924
131	HT2026072002192	HT20260720021921	HT20260720021922	HT20260720021923	HT20260720021924	1	0	0	0	0	03000122	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:39:40.345586	2026-09-15 06:47:55.183213	2026-09-15 06:47:55.349924
132	HT2026072002692	HT20260720026921	HT20260720026922	HT20260720026923	HT20260720026924	1	0	0	0	0	03000130	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:39:48.705933	2026-09-15 06:47:55.224534	2026-09-15 06:47:55.349924
135	HT2026072002672	HT20260720026721	HT20260720026722	HT20260720026723	HT20260720026724	1	0	0	0	0	03000123	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:40:16.586511	2026-09-15 06:47:55.22711	2026-09-15 06:47:55.349925
142	HT2026072002201	HT20260720022011	HT20260720022012	HT20260720022013	HT20260720022014	1	0	0	0	0	03000133	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:41:40.304976	2026-09-15 06:47:55.229615	2026-09-15 06:47:55.349925
146	HT2026072002495	HT20260720024951	HT20260720024952	HT20260720024953	HT20260720024954	1	0	0	0	0	03000153	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:46:44.88032	2026-09-15 06:47:55.23226	2026-09-15 06:47:55.349926
117	HT2026072002667	HT20260720026671	HT20260720026672	HT20260720026673	HT20260720026674	1	0	0	0	0	03000137	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:37:11.90167	2026-09-15 06:48:05.602285	2026-09-15 06:48:05.726824
127	HT2026072002749	HT20260720027491	HT20260720027492	HT20260720027493	HT20260720027494	1	0	0	0	0	03000114	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:39:00.252834	2026-09-15 06:48:05.597275	2026-09-15 06:48:05.726824
130	HT2026072002231	HT20260720022311	HT20260720022312	HT20260720022313	HT20260720022314	1	0	0	0	0	03000121	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:39:32.361649	2026-09-15 06:48:05.604817	2026-09-15 06:48:05.726825
133	HT2026072002687	HT20260720026871	HT20260720026872	HT20260720026873	HT20260720026874	1	0	0	0	0	03000131	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:39:59.725593	2026-09-15 06:48:05.607411	2026-09-15 06:48:05.726825
154	HT2026072002488	HT20260720024881	HT20260720024882	HT20260720024883	HT20260720024884	1	0	0	0	0	03000150	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:48:00.668752	2026-09-15 06:48:05.610192	2026-09-15 06:48:05.726829
155	HT2026072002681	HT20260720026811	HT20260720026812	HT20260720026813	HT20260720026814	1	0	0	0	0	03000145	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:48:32.487477	2026-09-15 06:48:05.612903	2026-09-15 06:48:05.726829
157	HT2026072001056	HT20260720010561	HT20260720010562	HT20260720010563	HT20260720010564	1	0	0	0	0	03000151	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:49:18.255254	2026-09-15 06:48:05.657462	2026-09-15 06:48:05.72683
158	HT2026072002682	HT20260720026821	HT20260720026822	HT20260720026823	HT20260720026824	1	0	0	0	0	03000147	\N	\N	\N	2026-08-31 00:00:00	2026-08-31 07:49:37.84679	2026-09-15 06:48:05.660101	2026-09-15 06:48:05.72683
159	HT2026072002755	HT20260720027551	HT20260720027552	HT20260720027553	HT20260720027554	1	0	0	0	0	03000116	\N	\N	\N	2026-09-01 00:00:00	2026-09-01 01:16:11.821023	2026-09-15 06:48:05.56782	2026-09-15 06:48:05.72683
204	HT2026072002270	HT20260720022701	HT20260720022702	HT20260720022703	HT20260720022704	1	0	0	0	0	05000041	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 01:55:18.512104	2026-09-05 03:22:07.261103	2026-09-05 03:22:07.295673
387	HT2026072002272	HT20260720022721	HT20260720022722	HT20260720022723	HT20260720022724	1	0	0	0	0	05000023	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 03:13:23.582508	2026-09-05 03:22:07.26543	2026-09-05 03:22:07.295673
388	HT2026072002244	HT20260720022441	HT20260720022442	HT20260720022443	HT20260720022444	1	0	0	0	0	05000024	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 03:13:42.950412	2026-09-05 03:22:07.242604	2026-09-05 03:22:07.295673
389	HT2026072002906	HT20260720029061	HT20260720029062	HT20260720029063	HT20260720029064	1	0	0	0	0	05000025	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 03:13:58.114094	2026-09-05 03:22:07.239264	2026-09-05 03:22:07.295674
160	HT2026072002493	HT20260720024931	HT20260720024932	HT20260720024933	HT20260720024934	1	0	0	0	0	03000155	\N	\N	\N	2026-09-01 00:00:00	2026-09-01 05:30:40.055856	2026-09-15 06:48:05.638915	2026-09-15 06:48:05.726831
391	HT2026072002266	HT20260720022661	HT20260720022662	HT20260720022663	HT20260720022664	1	0	0	0	0	05000030	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 03:24:40.126135	2026-09-05 03:26:45.736908	2026-09-05 03:26:45.740428
393	HT2026072001597	HT20260720015971	HT20260720015972	HT20260720015973	HT20260720015974	1	0	0	0	0	05000083	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 05:23:34.484621	2026-09-05 06:01:26.565364	2026-09-05 06:01:26.571273
209	HT2026072002986	HT20260720029861	HT20260720029862	HT20260720029863	HT20260720029864	1	0	0	0	0	05000050	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 01:58:34.552279	2026-09-05 05:23:20.917606	2026-09-05 05:23:20.97141
210	HT2026072002307	HT20260720023071	HT20260720023072	HT20260720023073	HT20260720023074	1	0	0	0	0	05000054	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 01:59:05.210059	2026-09-05 05:23:20.871893	2026-09-05 05:23:20.971411
211	HT2026072002296	HT20260720022961	HT20260720022962	HT20260720022963	HT20260720022964	1	0	0	0	0	05000055	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 01:59:21.540269	2026-09-05 05:23:20.860081	2026-09-05 05:23:20.971411
212	HT2026072002319	HT20260720023191	HT20260720023192	HT20260720023193	HT20260720023194	1	0	0	0	0	05000051	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 01:59:34.2238	2026-09-05 05:23:20.886517	2026-09-05 05:23:20.971412
213	HT2026072002868	HT20260720028681	HT20260720028682	HT20260720028683	HT20260720028684	1	0	0	0	0	05000052	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 01:59:50.324987	2026-09-05 05:23:20.879409	2026-09-05 05:23:20.971412
214	HT2026072002937	HT20260720029371	HT20260720029372	HT20260720029373	HT20260720029374	1	0	0	0	0	05000053	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:00:06.725094	2026-09-05 05:23:20.874479	2026-09-05 05:23:20.971412
215	HT2026072002107	HT20260720021071	HT20260720021072	HT20260720021073	HT20260720021074	1	0	0	0	0	05000057	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:00:38.761118	2026-09-05 05:23:20.914979	2026-09-05 05:23:20.971413
216	HT2026072002297	HT20260720022971	HT20260720022972	HT20260720022973	HT20260720022974	1	0	0	0	0	05000058	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:00:53.056504	2026-09-05 05:23:20.821859	2026-09-05 05:23:20.971413
217	HT2026072002821	HT20260720028211	HT20260720028212	HT20260720028213	HT20260720028214	1	0	0	0	0	05000059	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:01:01.361478	2026-09-05 05:23:20.829998	2026-09-05 05:23:20.971414
218	HT2026072002618	HT20260720026181	HT20260720026182	HT20260720026183	HT20260720026184	1	0	0	0	0	05000060	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:01:14.226211	2026-09-05 05:23:20.824604	2026-09-05 05:23:20.971414
219	BX2147778002871	BX21477780028711	BX21477780028712	BX21477780028713	BX21477780028714	1	0	0	0	0	05000056	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:01:29.898908	2026-09-05 05:23:20.834972	2026-09-05 05:23:20.971414
220	HT2026072002313	HT20260720023131	HT20260720023132	HT20260720023133	HT20260720023134	1	0	0	0	0	05000065	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:02:00.524533	2026-09-05 05:23:20.884232	2026-09-05 05:23:20.971415
221	HT2026072002312	HT20260720023121	HT20260720023122	HT20260720023123	HT20260720023124	1	0	0	0	0	05000061	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:02:20.200961	2026-09-05 05:23:20.862413	2026-09-05 05:23:20.971415
222	HT2026072002327	HT20260720023271	HT20260720023272	HT20260720023273	HT20260720023274	1	0	0	0	0	05000062	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:02:53.339042	2026-09-05 05:23:20.857815	2026-09-05 05:23:20.971415
223	HT2026072002302	HT20260720023021	HT20260720023022	HT20260720023023	HT20260720023024	1	0	0	0	0	05000063	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:03:06.958018	2026-09-05 05:23:20.912349	2026-09-05 05:23:20.971416
224	HT2026072002847	HT20260720028471	HT20260720028472	HT20260720028473	HT20260720028474	1	0	0	0	0	05000064	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:03:45.485026	2026-09-05 05:23:20.893085	2026-09-05 05:23:20.971416
225	HT2026072002614	HT20260720026141	HT20260720026142	HT20260720026143	HT20260720026144	1	0	0	0	0	05000067	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:04:29.578913	2026-09-05 05:23:20.876936	2026-09-05 05:23:20.971417
226	HT2026072002995	HT20260720029951	HT20260720029952	HT20260720029953	HT20260720029954	1	0	0	0	0	05000066	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:07:23.718247	2026-09-05 05:23:20.837401	2026-09-05 05:23:20.971417
227	HT2026072002889	HT20260720028891	HT20260720028892	HT20260720028893	HT20260720028894	1	0	0	0	0	05000068	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:36:32.353691	2026-09-05 05:23:20.867032	2026-09-05 05:23:20.971417
228	HT2026072002340	HT20260720023401	HT20260720023402	HT20260720023403	HT20260720023404	1	0	0	0	0	05000069	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:36:41.83233	2026-09-05 05:23:20.925487	2026-09-05 05:23:20.971418
229	HT2026072002919	HT20260720029191	HT20260720029192	HT20260720029193	HT20260720029194	1	0	0	0	0	05000070	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:36:45.647265	2026-09-05 05:23:20.839781	2026-09-05 05:23:20.971418
230	HT2026072002542	HT20260720025421	HT20260720025422	HT20260720025423	HT20260720025424	1	0	0	0	0	05000079	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:36:56.743318	2026-09-05 05:23:20.898236	2026-09-05 05:23:20.971418
231	HT2026072002832	HT20260720028321	HT20260720028322	HT20260720028323	HT20260720028324	1	0	0	0	0	05000080	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:37:02.097067	2026-09-05 05:23:20.864734	2026-09-05 05:23:20.971419
232	HT2026072002927	HT20260720029271	HT20260720029272	HT20260720029273	HT20260720029274	1	0	0	0	0	05000081	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:37:07.174851	2026-09-05 05:23:20.855454	2026-09-05 05:23:20.971419
233	HT2026072002958	HT20260720029581	HT20260720029582	HT20260720029583	HT20260720029584	1	0	0	0	0	05000092	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:37:14.172897	2026-09-05 05:23:20.869524	2026-09-05 05:23:20.971419
234	HT2026072001609	HT20260720016091	HT20260720016092	HT20260720016093	HT20260720016094	1	0	0	0	0	05000091	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:37:19.267021	2026-09-05 05:23:20.832545	2026-09-05 05:23:20.97142
235	HT2026072001584	HT20260720015841	HT20260720015842	HT20260720015843	HT20260720015844	1	0	0	0	0	05000090	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:37:27.53767	2026-09-05 05:23:20.895639	2026-09-05 05:23:20.97142
240	HT2026072002930	HT20260720029301	HT20260720029302	HT20260720029303	HT20260720029304	1	0	0	0	0	05000074	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:43:39.938528	2026-09-05 05:23:20.922956	2026-09-05 05:23:20.971421
241	HT2026072002932	HT20260720029321	HT20260720029322	HT20260720029323	HT20260720029324	1	0	0	0	0	05000071	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:43:54.75737	2026-09-05 05:23:20.850291	2026-09-05 05:23:20.971421
243	HT2026072001592	HT20260720015921	HT20260720015922	HT20260720015923	HT20260720015924	1	0	0	0	0	05000087	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:45:55.943029	2026-09-05 05:23:20.900609	2026-09-05 05:23:20.971421
244	HT2026072002902	HT20260720029021	HT20260720029022	HT20260720029023	HT20260720029024	1	0	0	0	0	05000082	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:46:17.59602	2026-09-05 05:23:20.852821	2026-09-05 05:23:20.971422
251	HT2026072001591	HT20260720015911	HT20260720015912	HT20260720015913	HT20260720015914	1	0	0	0	0	05000093	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:50:01.103541	2026-09-05 05:23:20.890622	2026-09-05 05:23:20.971422
253	HT2026072001586	HT20260720015861	HT20260720015862	HT20260720015863	HT20260720015864	1	0	0	0	0	05000088	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 02:50:59.259216	2026-09-05 05:23:20.842762	2026-09-05 05:23:20.971423
392	HT2026072002883	HT20260720028831	HT20260720028832	HT20260720028833	HT20260720028834	1	0	0	0	0	05000094	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 05:22:55.22789	2026-09-05 05:24:12.526285	2026-09-05 05:24:12.528317
395	HT2026072001384	HT20260720013841	HT20260720013842	HT20260720013843	HT20260720013844	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:19:26.279102	\N	2026-09-05 06:19:26.280838
396	HT2026072001395	HT20260720013951	HT20260720013952	HT20260720013953	HT20260720013954	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:19:48.910138	\N	2026-09-05 06:19:48.910507
397	HT2026072001415	HT20260720014151	HT20260720014152	HT20260720014153	HT20260720014154	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:19:55.290654	\N	2026-09-05 06:19:55.291053
398	HT2026072001663	HT20260720016631	HT20260720016632	HT20260720016633	HT20260720016634	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:20:05.817136	\N	2026-09-05 06:20:05.817782
399	HT2026072001671	HT20260720016711	HT20260720016712	HT20260720016713	HT20260720016714	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:20:18.711318	\N	2026-09-05 06:20:18.711572
400	HT2026072001411	HT20260720014111	HT20260720014112	HT20260720014113	HT20260720014114	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:20:24.245153	\N	2026-09-05 06:20:24.245585
401	HT2026072001662	HT20260720016621	HT20260720016622	HT20260720016623	HT20260720016624	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:20:33.151638	\N	2026-09-05 06:20:33.152219
402	HT2026072001686	HT20260720016861	HT20260720016862	HT20260720016863	HT20260720016864	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:20:39.979303	\N	2026-09-05 06:20:39.979697
403	HT2026072001666	HT20260720016661	HT20260720016662	HT20260720016663	HT20260720016664	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:21:02.841162	\N	2026-09-05 06:21:02.84139
404	HT2026072001685	HT20260720016851	HT20260720016852	HT20260720016853	HT20260720016854	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:25:00.107358	\N	2026-09-05 06:25:00.108518
406	HT2026072001669	HT20260720016691	HT20260720016692	HT20260720016693	HT20260720016694	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:25:25.249098	\N	2026-09-05 06:25:25.249528
408	HT2026072001402	HT20260720014021	HT20260720014022	HT20260720014023	HT20260720014024	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:26:12.212911	\N	2026-09-05 06:26:12.213151
410	HT2026072001679	HT20260720016791	HT20260720016792	HT20260720016793	HT20260720016794	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:27:09.045844	\N	2026-09-05 06:27:09.046268
412	HT2026072001687	HT20260720016871	HT20260720016872	HT20260720016873	HT20260720016874	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:27:35.07537	\N	2026-09-05 06:27:35.076347
413	HT2026072002029	HT20260720020291	HT20260720020292	HT20260720020293	HT20260720020294	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:28:03.628772	\N	2026-09-05 06:28:03.629435
416	HT2026072001409	HT20260720014091	HT20260720014092	HT20260720014093	HT20260720014094	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:31:44.517591	\N	2026-09-05 06:31:44.518014
418	HT2026072001668	HT20260720016681	HT20260720016682	HT20260720016683	HT20260720016684	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:32:37.185047	\N	2026-09-05 06:32:37.18544
419	HT2026072002026	HT20260720020261	HT20260720020262	HT20260720020263	HT20260720020264	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:33:07.479112	\N	2026-09-05 06:33:07.479562
421	HT2026072000531	HT20260720005311	HT20260720005312	HT20260720005313	HT20260720005314	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:33:29.091381	\N	2026-09-05 06:33:29.091781
424	HT2026072001399	HT20260720013991	HT20260720013992	HT20260720013993	HT20260720013994	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:35:11.335165	\N	2026-09-05 06:35:11.335517
426	HT2026072001657	HT20260720016571	HT20260720016572	HT20260720016573	HT20260720016574	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:35:35.955599	\N	2026-09-05 06:35:35.956314
428	HT2026072002022	HT20260720020221	HT20260720020222	HT20260720020223	HT20260720020224	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:36:17.352769	\N	2026-09-05 06:36:17.3532
430	HT2026072002822	HT20260720028221	HT20260720028222	HT20260720028223	HT20260720028224	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:39:22.182285	\N	2026-09-05 06:39:22.182772
435	HT2026072001446	HT20260720014461	HT20260720014462	HT20260720014463	HT20260720014464	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:40:14.047876	\N	2026-09-05 06:40:14.048481
437	HT2026072002216	HT20260720022161	HT20260720022162	HT20260720022163	HT20260720022164	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:42:37.07522	\N	2026-09-05 06:42:37.075647
438	HT2026072001718	HT20260720017181	HT20260720017182	HT20260720017183	HT20260720017184	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:42:43.443841	\N	2026-09-05 06:42:43.444403
439	HT2026072001720	HT20260720017201	HT20260720017202	HT20260720017203	HT20260720017204	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:42:52.201529	\N	2026-09-05 06:42:52.201883
442	HT2026072002689	HT20260720026891	HT20260720026892	HT20260720026893	HT20260720026894	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:43:12.136208	\N	2026-09-05 06:43:12.136703
444	HT2026072002215	HT20260720022151	HT20260720022152	HT20260720022153	HT20260720022154	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:43:30.397545	\N	2026-09-05 06:43:30.398049
449	HT2026072001458	HT20260720014581	HT20260720014582	HT20260720014583	HT20260720014584	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:51:29.247636	\N	2026-09-05 06:51:29.248172
451	HT2026072001708	HT20260720017081	HT20260720017082	HT20260720017083	HT20260720017084	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:52:32.501261	\N	2026-09-05 06:52:32.501833
455	HT2026072002193	HT20260720021931	HT20260720021932	HT20260720021933	HT20260720021934	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:53:06.65364	\N	2026-09-05 06:53:06.65406
457	HT2026072001447	HT20260720014471	HT20260720014472	HT20260720014473	HT20260720014474	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:53:31.05267	\N	2026-09-05 06:53:31.053108
460	HT2026072001734	HT20260720017341	HT20260720017342	HT20260720017343	HT20260720017344	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:54:14.048228	\N	2026-09-05 06:54:14.048614
405	HT2026072001675	HT20260720016751	HT20260720016752	HT20260720016753	HT20260720016754	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:25:10.838403	\N	2026-09-05 06:25:10.838847
407	HT2026072001396	HT20260720013961	HT20260720013962	HT20260720013963	HT20260720013964	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:26:03.471724	\N	2026-09-05 06:26:03.472539
411	HT2026072001631	HT20260720016311	HT20260720016312	HT20260720016313	HT20260720016314	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:27:18.915185	\N	2026-09-05 06:27:18.916415
414	HT2026072001407	HT20260720014071	HT20260720014072	HT20260720014073	HT20260720014074	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:28:21.724245	\N	2026-09-05 06:28:21.724709
415	HT2026072001401	HT20260720014011	HT20260720014012	HT20260720014013	HT20260720014014	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:31:27.154584	\N	2026-09-05 06:31:27.155113
417	HT2026072001659	HT20260720016591	HT20260720016592	HT20260720016593	HT20260720016594	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:32:29.298095	\N	2026-09-05 06:32:29.298626
422	HT2026072002028	HT20260720020281	HT20260720020282	HT20260720020283	HT20260720020284	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:33:39.835735	\N	2026-09-05 06:33:39.836365
423	HT2026072001403	HT20260720014031	HT20260720014032	HT20260720014033	HT20260720014034	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:33:52.97981	\N	2026-09-05 06:33:52.980403
427	HT2026072002020	HT20260720020201	HT20260720020202	HT20260720020203	HT20260720020204	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:35:48.164698	\N	2026-09-05 06:35:48.165038
432	HT2026072002903	HT20260720029031	HT20260720029032	HT20260720029033	HT20260720029034	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:39:41.924939	\N	2026-09-05 06:39:41.925537
433	HT2026072002746	HT20260720027461	HT20260720027462	HT20260720027463	HT20260720027464	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:39:57.263029	\N	2026-09-05 06:39:57.264063
434	HT2026072001450	HT20260720014501	HT20260720014502	HT20260720014503	HT20260720014504	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:40:05.495378	\N	2026-09-05 06:40:05.496491
440	HT2026072002952	HT20260720029521	HT20260720029522	HT20260720029523	HT20260720029524	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:42:59.798088	\N	2026-09-05 06:42:59.798549
443	HT2026072002730	HT20260720027301	HT20260720027302	HT20260720027303	HT20260720027304	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:43:18.394641	\N	2026-09-05 06:43:18.395065
446	HT2026072002769	HT20260720027691	HT20260720027692	HT20260720027693	HT20260720027694	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:44:20.721844	\N	2026-09-05 06:44:20.722251
452	HT2026072002013	HT20260720020131	HT20260720020132	HT20260720020133	HT20260720020134	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:52:41.689444	\N	2026-09-05 06:52:41.689839
453	HT2026072002041	HT20260720020411	HT20260720020412	HT20260720020413	HT20260720020414	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:52:51.197684	\N	2026-09-05 06:52:51.19868
456	HT2026072002693	HT20260720026931	HT20260720026932	HT20260720026933	HT20260720026934	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:53:16.962436	\N	2026-09-05 06:53:16.962833
461	HT2026072001457	HT20260720014571	HT20260720014572	HT20260720014573	HT20260720014574	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:54:23.306386	\N	2026-09-05 06:54:23.306845
409	HT2026072001667	HT20260720016671	HT20260720016672	HT20260720016673	HT20260720016674	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:26:58.583289	\N	2026-09-05 06:26:58.583724
420	HT2026072001673	HT20260720016731	HT20260720016732	HT20260720016733	HT20260720016734	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:33:17.627113	\N	2026-09-05 06:33:17.627567
425	HT2026072001655	HT20260720016551	HT20260720016552	HT20260720016553	HT20260720016554	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:35:26.922439	\N	2026-09-05 06:35:26.922901
429	HT2026072001400	HT20260720014001	HT20260720014002	HT20260720014003	HT20260720014004	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:37:14.358939	\N	2026-09-05 06:37:14.359368
431	HT2026072002722	HT20260720027221	HT20260720027222	HT20260720027223	HT20260720027224	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:39:28.904184	\N	2026-09-05 06:39:28.904803
436	HT2026072001413	HT20260720014131	HT20260720014132	HT20260720014133	HT20260720014134	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:42:04.989393	\N	2026-09-05 06:42:04.99001
441	HT2026072001455	HT20260720014551	HT20260720014552	HT20260720014553	HT20260720014554	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:43:04.540518	\N	2026-09-05 06:43:04.541143
445	HT2026072002039	HT20260720020391	HT20260720020392	HT20260720020393	HT20260720020394	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:43:45.098454	\N	2026-09-05 06:43:45.098963
447	HT2026072001736	HT20260720017361	HT20260720017362	HT20260720017363	HT20260720017364	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:44:39.330999	\N	2026-09-05 06:44:39.331507
448	HT2026072002217	HT20260720022171	HT20260720022172	HT20260720022173	HT20260720022174	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:49:21.119166	\N	2026-09-05 06:49:21.119736
450	HT2026072002710	HT20260720027101	HT20260720027102	HT20260720027103	HT20260720027104	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:52:21.474316	\N	2026-09-05 06:52:21.474951
454	HT2026072002721	HT20260720027211	HT20260720027212	HT20260720027213	HT20260720027214	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:52:59.88659	\N	2026-09-05 06:52:59.887042
458	HT2026072002009	HT20260720020091	HT20260720020092	HT20260720020093	HT20260720020094	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:53:47.594673	\N	2026-09-05 06:53:47.595103
459	HT2026072001449	HT20260720014491	HT20260720014492	HT20260720014493	HT20260720014494	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:53:56.74776	\N	2026-09-05 06:53:56.748376
462	HT2026072002011	HT20260720020111	HT20260720020112	HT20260720020113	HT20260720020114	0	0	0	0	0	\N	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 06:54:29.628934	\N	2026-09-05 06:54:29.62963
263	HT2026072001474	HT20260720014741	HT20260720014742	HT20260720014743	HT20260720014744	1	0	0	0	0	05000104	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 03:01:44.084385	2026-09-05 07:05:38.349337	2026-09-05 07:05:38.552478
264	HT2026072001495	HT20260720014951	HT20260720014952	HT20260720014953	HT20260720014954	1	0	0	0	0	05000117	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 03:02:23.850609	2026-09-05 07:05:38.362889	2026-09-05 07:05:38.552478
265	HT2026072001467	HT20260720014671	HT20260720014672	HT20260720014673	HT20260720014674	1	0	0	0	0	05000103	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 03:02:36.950978	2026-09-05 07:05:38.4916	2026-09-05 07:05:38.552478
278	HT2026072002897	HT20260720028971	HT20260720028972	HT20260720028973	HT20260720028974	1	0	0	0	0	05000102	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 03:14:08.77918	2026-09-05 07:05:38.375026	2026-09-05 07:05:38.552481
313	HT2026072001517	HT20260720015171	HT20260720015172	HT20260720015173	HT20260720015174	1	0	0	0	0	05000139	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:21:51.078143	2026-09-05 07:05:38.489068	2026-09-05 07:05:38.552481
314	HT2026072001513	HT20260720015131	HT20260720015132	HT20260720015133	HT20260720015134	1	0	0	0	0	05000140	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:21:55.958428	2026-09-05 07:05:38.372839	2026-09-05 07:05:38.552482
315	HT2026072002300	HT20260720023001	HT20260720023002	HT20260720023003	HT20260720023004	1	0	0	0	0	05000141	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:21:59.874221	2026-09-05 07:05:38.399138	2026-09-05 07:05:38.552482
326	HT2026072002267	HT20260720022671	HT20260720022672	HT20260720022673	HT20260720022674	1	0	0	0	0	05000142	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:24:40.994225	2026-09-05 07:05:38.389136	2026-09-05 07:05:38.552482
294	HT2026072001624	HT20260720016241	HT20260720016242	HT20260720016243	HT20260720016244	1	0	0	0	0	05000180	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:16:10.981828	2026-09-05 09:47:49.501157	2026-09-05 09:47:49.625856
295	HT2026072001649	HT20260720016491	HT20260720016492	HT20260720016493	HT20260720016494	1	0	0	0	0	05000193	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:16:38.345446	2026-09-05 09:47:49.519848	2026-09-05 09:47:49.625856
296	HT2026072002853	HT20260720028531	HT20260720028532	HT20260720028533	HT20260720028534	1	0	0	0	0	05000194	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:16:47.696039	2026-09-05 09:47:49.503344	2026-09-05 09:47:49.625856
299	HT2026072001699	HT20260720016991	HT20260720016992	HT20260720016993	HT20260720016994	1	0	0	0	0	05000190	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:17:23.864342	2026-09-05 09:47:49.540411	2026-09-05 09:47:49.625857
300	HT2026072002964	HT20260720029641	HT20260720029642	HT20260720029643	HT20260720029644	1	0	0	0	0	05000183	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:17:43.468102	2026-09-05 09:47:49.443408	2026-09-05 09:47:49.625857
301	HT2026072002328	HT20260720023281	HT20260720023282	HT20260720023283	HT20260720023284	1	0	0	0	0	05000182	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:17:55.045213	2026-09-05 09:47:49.496436	2026-09-05 09:47:49.625857
302	HT2026072001650	HT20260720016501	HT20260720016502	HT20260720016503	HT20260720016504	1	0	0	0	0	05000181	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:18:00.107665	2026-09-05 09:47:49.553281	2026-09-05 09:47:49.625858
475	HT2026072002962	HT20260720029621	HT20260720029622	HT20260720029623	HT20260720029624	1	0	0	0	0	05000085	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 09:20:27.840953	2026-09-05 13:13:54.258985	2026-09-05 13:13:54.275146
476	HT2026072002981	HT20260720029811	HT20260720029812	HT20260720029813	HT20260720029814	1	0	0	0	0	05000084	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 09:20:58.99968	2026-09-05 13:13:54.253965	2026-09-05 13:13:54.275146
477	HT2026072002840	HT20260720028401	HT20260720028402	HT20260720028403	HT20260720028404	1	0	0	0	0	05000077	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 09:21:23.999215	2026-09-05 13:13:54.263979	2026-09-05 13:13:54.275147
478	HT2026072001589	HT20260720015891	HT20260720015892	HT20260720015893	HT20260720015894	1	0	0	0	0	05000076	\N	\N	\N	2026-09-05 00:00:00	2026-09-05 09:22:07.828209	2026-09-05 13:13:54.266453	2026-09-05 13:13:54.275147
303	HT2026072002318	HT20260720023181	HT20260720023182	HT20260720023183	HT20260720023184	1	0	0	0	0	05000189	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:18:35.290476	2026-09-05 09:47:49.47038	2026-09-05 09:47:49.625858
307	HT2026072001629	HT20260720016291	HT20260720016292	HT20260720016293	HT20260720016294	1	0	0	0	0	05000178	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:19:56.570054	2026-09-05 09:47:49.494297	2026-09-05 09:47:49.625858
308	HT2026072001651	HT20260720016511	HT20260720016512	HT20260720016513	HT20260720016514	1	0	0	0	0	05000179	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:20:04.994195	2026-09-05 09:47:49.517337	2026-09-05 09:47:49.625859
309	HT2026072001648	HT20260720016481	HT20260720016482	HT20260720016483	HT20260720016484	1	0	0	0	0	05000184	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:20:32.489643	2026-09-05 09:47:49.44793	2026-09-05 09:47:49.625859
310	HT2026072001658	HT20260720016581	HT20260720016582	HT20260720016583	HT20260720016584	1	0	0	0	0	05000192	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:20:47.344558	2026-09-05 09:47:49.527422	2026-09-05 09:47:49.625859
316	HT2026072001611	HT20260720016111	HT20260720016112	HT20260720016113	HT20260720016114	1	0	0	0	0	05000150	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:22:05.582865	2026-09-05 09:47:49.492154	2026-09-05 09:47:49.62586
317	HT2026072002304	HT20260720023041	HT20260720023042	HT20260720023043	HT20260720023044	1	0	0	0	0	05000151	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:22:17.334909	2026-09-05 09:47:49.50552	2026-09-05 09:47:49.62586
318	HT2026072002239	HT20260720022391	HT20260720022392	HT20260720022393	HT20260720022394	1	0	0	0	0	05000152	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:22:24.431661	2026-09-05 09:47:49.563528	2026-09-05 09:47:49.62586
319	HT2026072001615	HT20260720016151	HT20260720016152	HT20260720016153	HT20260720016154	1	0	0	0	0	05000161	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:22:30.221939	2026-09-05 09:47:49.46617	2026-09-05 09:47:49.625861
320	HT2026072001613	HT20260720016131	HT20260720016132	HT20260720016133	HT20260720016134	1	0	0	0	0	05000162	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:22:36.068245	2026-09-05 09:47:49.524908	2026-09-05 09:47:49.625861
321	HT2026072001572	HT20260720015721	HT20260720015722	HT20260720015723	HT20260720015724	1	0	0	0	0	05000163	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:22:44.873757	2026-09-05 09:47:49.530002	2026-09-05 09:47:49.625861
322	HT2026072001608	HT20260720016081	HT20260720016082	HT20260720016083	HT20260720016084	1	0	0	0	0	05000169	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:22:53.966389	2026-09-05 09:47:49.479073	2026-09-05 09:47:49.625862
323	HT2026072001625	HT20260720016251	HT20260720016252	HT20260720016253	HT20260720016254	1	0	0	0	0	05000170	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:23:00.558506	2026-09-05 09:47:49.498638	2026-09-05 09:47:49.625862
324	HT2026072001641	HT20260720016411	HT20260720016412	HT20260720016413	HT20260720016414	1	0	0	0	0	05000171	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:24:17.933975	2026-09-05 09:47:49.455249	2026-09-05 09:47:49.625862
325	HT2026072002322	HT20260720023221	HT20260720023222	HT20260720023223	HT20260720023224	1	0	0	0	0	05000145	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:24:32.799173	2026-09-05 09:47:49.535158	2026-09-05 09:47:49.625863
327	HT2026072002306	HT20260720023061	HT20260720023062	HT20260720023063	HT20260720023064	1	0	0	0	0	05000146	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:24:48.959108	2026-09-05 09:47:49.545502	2026-09-05 09:47:49.625863
328	HT2026072002232	HT20260720022321	HT20260720022322	HT20260720022323	HT20260720022324	1	0	0	0	0	05000153	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:25:16.177944	2026-09-05 09:47:49.472507	2026-09-05 09:47:49.625863
329	HT2026072001590	HT20260720015901	HT20260720015902	HT20260720015903	HT20260720015904	1	0	0	0	0	05000158	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:25:22.489735	2026-09-05 09:47:49.555812	2026-09-05 09:47:49.625864
330	HT2026072001643	HT20260720016431	HT20260720016432	HT20260720016433	HT20260720016434	1	0	0	0	0	05000159	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:25:36.327106	2026-09-05 09:47:49.542945	2026-09-05 09:47:49.625864
331	HT2026072001616	HT20260720016161	HT20260720016162	HT20260720016163	HT20260720016164	1	0	0	0	0	05000164	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:25:45.998986	2026-09-05 09:47:49.468225	2026-09-05 09:47:49.625864
340	HT2026072001618	HT20260720016181	HT20260720016182	HT20260720016183	HT20260720016184	1	0	0	0	0	05000166	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:28:23.187828	2026-09-05 09:47:49.558455	2026-09-05 09:47:49.625867
344	HT2026072002321	HT20260720023211	HT20260720023212	HT20260720023213	HT20260720023214	1	0	0	0	0	05000149	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:29:43.192393	2026-09-05 09:47:49.561009	2026-09-05 09:47:49.625868
347	HT2026072001621	HT20260720016211	HT20260720016212	HT20260720016213	HT20260720016214	1	0	0	0	0	05000168	\N	\N	\N	2026-09-04 00:00:00	2026-09-04 05:30:05.51645	2026-09-05 09:47:49.47473	2026-09-05 09:47:49.625869
\.


--
-- Data for Name: transaction_logs; Type: TABLE DATA; Schema: public; Owner: solar_admin
--

COPY public.transaction_logs (id, transaction_id, customer_uuid, card_uuid, shs_machine_id, days, amount, transaction_time, action_type, pos_sn, operator_username, created_at) FROM stdin;
2	5BB80-2DC6C1-260828143531	03000001	068450BB	HT2026072001599	30.00	210.00	2026-08-28 14:35:31	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-28 06:36:09.63912
3	5BB80-2DC6C2-260831111649	03000002	866835BB	HT2026072001585	10.00	70.00	2026-08-31 11:16:49	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 03:24:45.200361
4	5BB80-2DC6C3-260831112514	03000003	86865CBB	HT2026072001596	10.00	70.00	2026-08-31 11:25:14	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 05:11:47.575842
5	5BB80-2DC6CA-260831135117	03000010	96B937BB	HT2026072001593	10.00	70.00	2026-08-31 13:51:17	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 05:59:00.635093
6	5BB80-2DC6C9-260831135210	03000009	968C52BB	HT2026072001605	10.00	70.00	2026-08-31 13:52:10	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 05:59:00.635096
7	5BB80-2DC6C8-260831135309	03000008	36F64CBB	HT2026072001583	10.00	70.00	2026-08-31 13:53:09	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 05:59:00.635097
8	5BB80-2DC6C7-260831135350	03000007	160145BB	HT2026072001604	10.00	70.00	2026-08-31 13:53:50	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 05:59:00.635098
9	5BB80-2DC6C6-260831135629	03000006	F6C756BB	HT2026072001587	10.00	70.00	2026-08-31 13:56:29	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 05:59:00.635099
10	5BB80-2DC6C5-260831135759	03000005	460D47BB	HT2026072001588	10.00	70.00	2026-08-31 13:57:59	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 05:59:00.6351
11	5BB80-2DC6C4-260831135824	03000004	36634FBB	HT2026072001600	10.00	70.00	2026-08-31 13:58:24	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 05:59:00.635101
12	5BB80-2DC6CB-260831140026	03000011	F6FF4CBB	HT2026072002628	10.00	70.00	2026-08-31 14:00:26	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:12:27.993665
13	5BB80-2DC6CC-260831140055	03000012	16782DBB	HT2026072001601	10.00	70.00	2026-08-31 14:00:55	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:12:27.993667
14	5BB80-2DC6CD-260831140323	03000013	56EF5ABB	HT2026072002615	10.00	70.00	2026-08-31 14:03:23	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:12:27.993667
15	5BB80-2DC6CE-260831140353	03000014	16D83CBB	HT2026072002609	10.00	70.00	2026-08-31 14:03:53	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:12:27.993668
16	5BB80-2DC6CF-260831140424	03000015	165F3ABB	HT2026072002153	10.00	70.00	2026-08-31 14:04:24	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:12:27.993668
17	5BB80-2DC6D0-260831140454	03000016	86C133BB	HT2026072002617	10.00	70.00	2026-08-31 14:04:54	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:12:27.993668
18	5BB80-2DC6D1-260831140525	03000017	966E56BB	HT2026072002602	10.00	70.00	2026-08-31 14:05:25	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:12:27.993669
19	5BB80-2DC6D2-260831140555	03000018	660953BB	HT2026072001595	10.00	70.00	2026-08-31 14:05:55	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:12:27.993669
20	5BB80-2DC6D3-260831140721	03000019	36E644BB	HT2026072002608	10.00	70.00	2026-08-31 14:07:21	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:12:27.99367
21	5BB80-2DC6D4-260831140815	03000020	363D51BB	HT2026072002603	10.00	70.00	2026-08-31 14:08:15	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:12:27.99367
22	5BB80-2DC6D5-260831140954	03000021	B69F28BB	HT2026072001607	10.00	70.00	2026-08-31 14:09:54	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:12:27.99367
23	5BB80-2DC6D6-260831141336	03000022	662D25BB	HT2026072002627	10.00	70.00	2026-08-31 14:13:36	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:22:24.562304
24	5BB80-2DC6D7-260831141718	03000023	56A935BB	HT2026072001602	10.00	70.00	2026-08-31 14:17:18	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:22:24.562307
25	5BB80-2DC6D8-260831141745	03000024	D6ED56BB	HT2026072001603	10.00	70.00	2026-08-31 14:17:45	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:22:24.562307
26	5BB80-2DC6D9-260831142240	03000025	264A2EBB	HT2026072001598	10.00	70.00	2026-08-31 14:22:40	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:29:43.666454
27	5BB80-2DC6DA-260831142336	03000026	562F3ABB	HT2026072002594	10.00	70.00	2026-08-31 14:23:36	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:29:43.666456
28	5BB80-2DC6DB-260831142407	03000027	B6DA55BB	HT2026072002170	10.00	70.00	2026-08-31 14:24:07	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:29:43.666456
29	5BB80-2DC6DC-260831142431	03000028	664623BB	HT2026072002622	10.00	70.00	2026-08-31 14:24:31	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:29:43.666457
30	5BB80-2DC6DD-260831142454	03000029	C62043BB	HT2026072002644	10.00	70.00	2026-08-31 14:24:54	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:29:43.666457
31	5BB80-2DC6DE-260831142622	03000030	063D44BB	HT2026072002150	10.00	70.00	2026-08-31 14:26:22	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:29:43.666458
32	5BB80-2DC6DF-260831142641	03000031	76364DBB	HT2026072002173	10.00	70.00	2026-08-31 14:26:41	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:29:43.666458
33	5BB80-2DC6E0-260831142711	03000032	169E4BBB	HT2026072002653	10.00	70.00	2026-08-31 14:27:11	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:29:43.666458
34	5BB80-2DC6E1-260831142736	03000033	463633BB	HT2026072002634	10.00	70.00	2026-08-31 14:27:36	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:29:43.666459
35	5BB80-2DC6E2-260831143009	03000034	264759BB	HT2026072002654	10.00	70.00	2026-08-31 14:30:09	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:31:09.508852
36	5BB80-2DC6E3-260831143236	03000035	36142BBB	HT2026072002179	10.00	70.00	2026-08-31 14:32:36	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:46:16.584163
37	5BB80-2DC6E4-260831143312	03000036	D6752BBB	HT2026072002655	10.00	70.00	2026-08-31 14:33:12	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:46:16.584165
38	5BB80-2DC6E5-260831143406	03000037	E6D828BB	HT2026072002596	10.00	70.00	2026-08-31 14:34:06	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:46:16.584166
39	5BB80-2DC6E6-260831143435	03000038	86F254BB	HT2026072002167	10.00	70.00	2026-08-31 14:34:35	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:46:16.584166
40	5BB80-2DC6E7-260831143552	03000039	A6B65BBB	HT2026072002643	10.00	70.00	2026-08-31 14:35:52	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 06:46:16.584167
41	5BB80-2DC6E8-260831144923	03000040	46444FBB	HT2026072002163	10.00	70.00	2026-08-31 14:49:23	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413469
42	5BB80-2DC6E9-260831145021	03000041	56BF3ABB	HT2026072002147	10.00	70.00	2026-08-31 14:50:21	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413471
43	5BB80-2DC6EA-260831145405	03000042	F69F59BB	HT2026072002180	10.00	70.00	2026-08-31 14:54:05	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413472
44	5BB80-2DC6EB-260831145426	03000043	26BE4DBB	HT2026072002146	10.00	70.00	2026-08-31 14:54:26	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413472
45	5BB80-2DC6EC-260831145449	03000044	763931BB	HT2026072002652	10.00	70.00	2026-08-31 14:54:49	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413472
46	5BB80-2DC6ED-260831145510	03000045	B6C01ABB	HT2026072002187	10.00	70.00	2026-08-31 14:55:10	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413473
47	5BB80-2DC6EE-260831145534	03000046	561D3DBB	HT2026072002183	10.00	70.00	2026-08-31 14:55:34	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413473
48	5BB80-2DC6EF-260831145553	03000047	66A91EBB	HT2026072002688	10.00	70.00	2026-08-31 14:55:53	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413474
49	5BB80-2DC6F0-260831145614	03000048	86CB24BB	HT2026072002683	10.00	70.00	2026-08-31 14:56:14	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413474
50	5BB80-2DC6F1-260831145638	03000049	86DD19BB	HT2026072002645	10.00	70.00	2026-08-31 14:56:38	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413474
51	5BB80-2DC6F2-260831145746	03000050	861D45BB	HT2026072002671	10.00	70.00	2026-08-31 14:57:46	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413475
52	5BB80-2DC6F3-260831145847	03000051	56A931BB	HT2026072002703	10.00	70.00	2026-08-31 14:58:47	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413475
53	5BB80-2DC6F4-260831145911	03000052	76271BBB	HT2026072002497	10.00	70.00	2026-08-31 14:59:11	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413476
54	5BB80-2DC6F5-260831145931	03000053	E6DD4ABB	HT2026072002199	10.00	70.00	2026-08-31 14:59:31	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413476
55	5BB80-2DC6F6-260831145952	03000054	B69056BB	HT2026072003003	10.00	70.00	2026-08-31 14:59:52	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413476
56	5BB80-2DC6F7-260831150016	03000055	863238BB	HT2026072003004	10.00	70.00	2026-08-31 15:00:16	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413477
57	5BB80-2DC6F8-260831150043	03000056	A62047BB	HT2026072002695	10.00	70.00	2026-08-31 15:00:43	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413477
58	5BB80-2DC6F9-260831150109	03000057	36FC1BBB	HT2026072002704	10.00	70.00	2026-08-31 15:01:09	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413477
59	5BB80-2DC6FA-260831150130	03000058	562C4BBB	HT2026072002650	10.00	70.00	2026-08-31 15:01:30	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413478
60	5BB80-2DC6FB-260831150208	03000059	E64151BB	HT2026072002483	10.00	70.00	2026-08-31 15:02:08	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413478
61	5BB80-2DC6FC-260831150233	03000060	B62543BB	HT2026072002679	10.00	70.00	2026-08-31 15:02:33	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413478
62	5BB80-2DC6FD-260831150459	03000061	263E2DBB	HT2026072002486	10.00	70.00	2026-08-31 15:04:59	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413479
63	5BB80-2DC6FE-260831150520	03000062	E6331FBB	HT2026072002489	10.00	70.00	2026-08-31 15:05:20	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413479
64	5BB80-2DC6FF-260831150544	03000063	A6391ABB	HT2026072002498	10.00	70.00	2026-08-31 15:05:44	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413479
65	5BB80-2DC700-260831150607	03000064	D6DF37BB	HT2026072002479	10.00	70.00	2026-08-31 15:06:07	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.41348
66	5BB80-2DC701-260831150633	03000065	F67423BB	HT2026072001511	10.00	70.00	2026-08-31 15:06:33	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.41348
67	5BB80-2DC702-260831150655	03000066	D6E539BB	HT2026072002500	10.00	70.00	2026-08-31 15:06:55	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.41348
68	5BB80-2DC703-260831150717	03000067	665439BB	HT2026072003007	10.00	70.00	2026-08-31 15:07:17	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413481
69	5BB80-2DC704-260831150821	03000068	468B40BB	HT2026072001497	10.00	70.00	2026-08-31 15:08:21	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413481
70	5BB80-2DC705-260831150853	03000069	F6FA4CBB	HT2026072003006	10.00	70.00	2026-08-31 15:08:53	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413481
71	5BB80-2DC706-260831151014	03000070	662E3EBB	HT2026072003010	10.00	70.00	2026-08-31 15:10:14	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 07:10:59.413482
72	5BB80-2DC707-260831165112	03000071	A65547BB	HT2026072001461	10.00	70.00	2026-08-31 16:51:12	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595571
73	5BB80-2DC708-260831165138	03000072	96543ABB	HT2021963001481	10.00	70.00	2026-08-31 16:51:38	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595573
74	5BB80-2DC709-260831165159	03000073	76A92CBB	HT2026072001483	10.00	70.00	2026-08-31 16:51:59	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595574
75	5BB80-2DC70A-260831165229	03000074	36B459BB	HT2026072002462	10.00	70.00	2026-08-31 16:52:29	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595574
76	5BB80-2DC70B-260831165251	03000075	F6CE2ABB	HT2026072002487	10.00	70.00	2026-08-31 16:52:51	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595575
77	5BB80-2DC70C-260831165312	03000076	96302BBB	HT2026072002499	10.00	70.00	2026-08-31 16:53:12	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595575
78	5BB80-2DC70D-260831165330	03000077	963049BB	HT2026072001471	10.00	70.00	2026-08-31 16:53:30	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595576
79	5BB80-2DC70E-260831165351	03000078	66C733BB	HT2026072002491	10.00	70.00	2026-08-31 16:53:51	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595576
80	5BB80-2DC70F-260831165413	03000079	96ED42BB	HT2026072001475	10.00	70.00	2026-08-31 16:54:13	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595576
81	5BB80-2DC710-260831165450	03000080	D6DF41BB	HT2026072001470	10.00	70.00	2026-08-31 16:54:50	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595577
82	5BB80-2DC711-260831165513	03000081	969931BB	HT2026072001476	10.00	70.00	2026-08-31 16:55:13	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595577
83	5BB80-2DC712-260831165539	03000082	36AE39BB	HT2026072001468	10.00	70.00	2026-08-31 16:55:39	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595577
84	5BB80-2DC713-260831165620	03000083	A65221BB	HT2026072001490	10.00	70.00	2026-08-31 16:56:20	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595578
85	5BB80-2DC714-260831165643	03000084	161838BB	HT2026072001488	10.00	70.00	2026-08-31 16:56:43	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595578
86	5BB80-2DC715-260831165704	03000085	96EA26BB	HT2026072001501	10.00	70.00	2026-08-31 16:57:04	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595578
87	5BB80-2DC716-260831165727	03000086	964151BB	HT2026072001472	10.00	70.00	2026-08-31 16:57:27	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595579
88	5BB80-2DC717-260831165749	03000087	661A3EBB	HT2026072001479	10.00	70.00	2026-08-31 16:57:49	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595579
89	5BB80-2DC718-260831165810	03000088	36AE35BB	HT2026072001492	10.00	70.00	2026-08-31 16:58:10	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.59558
90	5BB80-2DC719-260831165833	03000089	269C56BB	HT2026072001478	10.00	70.00	2026-08-31 16:58:33	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.59558
91	5BB80-2DC71A-260831165857	03000090	662C23BB	HT2026072001493	10.00	70.00	2026-08-31 16:58:57	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.59558
92	5BB80-2DC71B-260831165956	03000091	362E58BB	HT2026072001463	10.00	70.00	2026-08-31 16:59:56	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595581
93	5BB80-2DC71C-260831170020	03000092	768236BB	HT2026072001466	10.00	70.00	2026-08-31 17:00:20	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595581
94	5BB80-2DC71D-260831170043	03000093	262B35BB	HT2026072001430	10.00	70.00	2026-08-31 17:00:43	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595582
95	5BB80-2DC71E-260831170104	03000094	469619BB	HT2026072000533	10.00	70.00	2026-08-31 17:01:04	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595582
96	5BB80-2DC71F-260831170123	03000095	C67C44BB	HT2026072001464	10.00	70.00	2026-08-31 17:01:23	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595582
97	5BB80-2DC720-260831170141	03000096	66804DBB	HT2026072001445	10.00	70.00	2026-08-31 17:01:41	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595583
98	5BB80-2DC721-260831170203	03000097	16C940BB	HT2026072001429	10.00	70.00	2026-08-31 17:02:03	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595583
99	5BB80-2DC722-260831170222	03000098	067733BB	HT2026072001482	10.00	70.00	2026-08-31 17:02:22	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595583
100	5BB80-2DC723-260831170244	03000099	566E2BBB	HT2026072001418	10.00	70.00	2026-08-31 17:02:44	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595584
101	5BB80-2DC724-260831170306	03000100	46B81EBB	HT2026072001473	10.00	70.00	2026-08-31 17:03:06	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595584
102	5BB80-2DC725-260831170408	03000101	265145BB	HT2026072001486	10.00	70.00	2026-08-31 17:04:08	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595584
103	5BB80-2DC726-260831170429	03000102	36DC52BB	HT2026072001465	10.00	70.00	2026-08-31 17:04:29	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595585
104	5BB80-2DC730-260831170513	03000112	C6BC23BB	HT2026072001434	10.00	70.00	2026-08-31 17:05:13	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595585
105	5BB80-2DC728-260831170532	03000104	D61153BB	HT2026072001480	10.00	70.00	2026-08-31 17:05:32	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 09:06:09.595586
106	5BB80-2DC729-260831184319	03000105	56143ABB	HT2026072002820	10.00	70.00	2026-08-31 18:43:19	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 10:49:02.556758
107	5BB80-2DC72A-260831184425	03000106	96124BBB	HT2026072002781	10.00	70.00	2026-08-31 18:44:25	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 10:49:02.556761
108	5BB80-2DC72B-260831184452	03000107	46B81BBB	HT2026072000528	10.00	70.00	2026-08-31 18:44:52	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 10:49:02.556762
109	5BB80-2DC72C-260831184515	03000108	C66140BB	HT2026072002208	10.00	70.00	2026-08-31 18:45:15	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 10:49:02.556762
110	5BB80-2DC72D-260831184538	03000109	E6FD2ABB	HT2026072002014	10.00	70.00	2026-08-31 18:45:38	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 10:49:02.556763
111	5BB80-2DC72E-260831184606	03000110	56682BBB	HT2026072002220	10.00	70.00	2026-08-31 18:46:06	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 10:49:02.556763
112	5BB80-2DC72F-260831190443	03000111	B65442BB	HT2026072002764	10.00	70.00	2026-08-31 19:04:43	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 11:44:49.059248
113	5BB80-2DC727-260831190529	03000103	96241CBB	HT2026072002734	10.00	70.00	2026-08-31 19:05:29	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 11:44:49.059252
114	5BB80-2DC731-260831190609	03000113	464B51BB	HT2026072001723	10.00	70.00	2026-08-31 19:06:09	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 11:44:49.059253
115	5BB80-2DC732-260831190634	03000114	06942ABB	HT2026072002749	10.00	70.00	2026-08-31 19:06:34	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-08-31 11:44:49.059253
116	5BB80-2DC75D-260901094514	03000157	868D3BBB	HT2026072001489	10.00	70.00	2026-09-01 09:45:14	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 02:04:08.292913
117	5BB80-2DC734-260901094827	03000116	96C343BB	HT2026072002755	10.00	70.00	2026-09-01 09:48:27	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 02:04:08.292916
118	5BB80-2DC735-260901094852	03000117	A6F824BB	HT2026072002909	10.00	70.00	2026-09-01 09:48:52	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 02:04:08.292917
119	5BB80-2DC736-260901094916	03000118	56B937BB	HT2026072002767	10.00	70.00	2026-09-01 09:49:16	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 02:04:08.292917
120	5BB80-2DC737-260901094949	03000119	D60F4FBB	HT2026072002718	10.00	70.00	2026-09-01 09:49:49	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 02:04:08.292918
121	5BB80-2DC738-260901095748	03000120	960E4BBB	HT2026072002720	10.00	70.00	2026-09-01 09:57:48	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 02:04:08.292919
122	5BB80-2DC739-260901130345	03000121	26203ABB	HT2026072002231	10.00	70.00	2026-09-01 13:03:45	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.79298
123	5BB80-2DC73A-260901130404	03000122	764B5EBB	HT2026072002192	10.00	70.00	2026-09-01 13:04:04	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792982
124	5BB80-2DC73B-260901130607	03000123	F6EA27BB	HT2026072002672	10.00	70.00	2026-09-01 13:06:07	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792982
125	5BB80-2DC73C-260901130631	03000124	769C3EBB	HT2026072002678	10.00	70.00	2026-09-01 13:06:31	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792983
126	5BB80-2DC73D-260901130648	03000125	662449BB	HT2026072002706	10.00	70.00	2026-09-01 13:06:48	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792983
127	5BB80-2DC73E-260901130746	03000126	E68C40BB	HT2026072002698	10.00	70.00	2026-09-01 13:07:46	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792984
128	5BB80-2DC73F-260901130803	03000127	764E2DBB	HT2026072002699	10.00	70.00	2026-09-01 13:08:03	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792984
129	5BB80-2DC740-260901130819	03000128	E63058BB	HT2026072002830	10.00	70.00	2026-09-01 13:08:19	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792984
130	5BB80-2DC741-260901130836	03000129	26F840BB	HT2026072002701	10.00	70.00	2026-09-01 13:08:36	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792985
131	5BB80-2DC74B-260901131003	03000139	06B35DBB	HT2026072002686	10.00	70.00	2026-09-01 13:10:03	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792985
132	5BB80-2DC74A-260901131023	03000138	96D342BB	HT2026072002657	10.00	70.00	2026-09-01 13:10:23	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792986
133	5BB80-2DC749-260901131043	03000137	F6AF5DBB	HT2026072002667	10.00	70.00	2026-09-01 13:10:43	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792986
134	5BB80-2DC748-260901131059	03000136	B65E3CBB	HT2026072002677	10.00	70.00	2026-09-01 13:10:59	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792986
135	5BB80-2DC747-260901131116	03000135	261851BB	HT2026072002715	10.00	70.00	2026-09-01 13:11:16	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792987
136	5BB80-2DC746-260901131133	03000134	96033EBB	HT2026072002118	10.00	70.00	2026-09-01 13:11:33	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792987
137	5BB80-2DC745-260901131152	03000133	C65B29BB	HT2026072002201	10.00	70.00	2026-09-01 13:11:52	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792988
138	5BB80-2DC744-260901131343	03000132	962D2FBB	HT2026072002174	10.00	70.00	2026-09-01 13:13:43	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792988
139	5BB80-2DC743-260901131406	03000131	D6114FBB	HT2026072002687	10.00	70.00	2026-09-01 13:14:06	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792988
140	5BB80-2DC742-260901131431	03000130	460A5BBB	HT2026072002692	10.00	70.00	2026-09-01 13:14:31	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792989
141	5BB80-2DC755-260901131454	03000149	560853BB	HT2026072002185	10.00	70.00	2026-09-01 13:14:54	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792989
142	5BB80-2DC754-260901131518	03000148	368946BB	HT2026072002665	10.00	70.00	2026-09-01 13:15:18	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792989
143	5BB80-2DC753-260901131536	03000147	F61B55BB	HT2026072002682	10.00	70.00	2026-09-01 13:15:36	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.79299
144	5BB80-2DC752-260901131604	03000146	A6944DBB	HT2026072002492	10.00	70.00	2026-09-01 13:16:04	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.79299
145	5BB80-2DC751-260901131624	03000145	F69327BB	HT2026072002681	10.00	70.00	2026-09-01 13:16:24	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.79299
146	5BB80-2DC750-260901131641	03000144	967F4BBB	HT2026072002184	10.00	70.00	2026-09-01 13:16:41	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792991
147	5BB80-2DC74F-260901132017	03000143	C65B4DBB	HT2026072002108	10.00	70.00	2026-09-01 13:20:17	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792991
148	5BB80-2DC74E-260901132038	03000142	86CC54BB	HT2026072002660	10.00	70.00	2026-09-01 13:20:38	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792992
149	5BB80-2DC74D-260901132056	03000141	B65B2BBB	HT2026072002669	10.00	70.00	2026-09-01 13:20:56	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792992
150	5BB80-2DC74C-260901132117	03000140	76A644BB	HT2026072002910	10.00	70.00	2026-09-01 13:21:17	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792992
151	5BB80-2DC75C-260901132140	03000156	565129BB	HT2026072002494	10.00	70.00	2026-09-01 13:21:40	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792993
152	5BB80-2DC75A-260901132223	03000154	163236BB	HT2026072002490	10.00	70.00	2026-09-01 13:22:23	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792993
153	5BB80-2DC759-260901132241	03000153	C6774FBB	HT2026072002495	10.00	70.00	2026-09-01 13:22:41	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792993
154	5BB80-2DC758-260901132259	03000152	663438BB	HT2026072002482	10.00	70.00	2026-09-01 13:22:59	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792994
155	5BB80-2DC757-260901132317	03000151	F6542BBB	HT2026072001056	10.00	70.00	2026-09-01 13:23:17	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792994
156	5BB80-2DC756-260901132335	03000150	06ED30BB	HT2026072002488	10.00	70.00	2026-09-01 13:23:35	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:31:06.792995
157	5BB80-2DC75B-260901133132	03000155	06D046BB	HT2026072002493	10.00	70.00	2026-09-01 13:31:32	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-01 05:56:29.952946
158	5BB80-2DC6CB-260902094350	03000011	F6FF4CBB	HT2026072002628	2.00	14.00	2026-09-02 09:43:50	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-02 01:56:28.828215
159	5BB80-2DC6C2-260902095345	03000002	866835BB	HT2026072001585	1.00	7.00	2026-09-02 09:53:45	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-02 01:56:28.828217
160	5BB80-2DC6CC-260902095906	03000012	16782DBB	HT2026072001601	1.00	7.00	2026-09-02 09:59:06	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-03 01:43:31.348142
161	5C0E6-2DC6CB-260903100701	03000011	F6FF4CBB	HT2026072002628	1.00	7.00	2026-09-03 10:07:01	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-03 02:12:32.807745
162	5C0E6-2DC6CB-260903100911	03000011	F6FF4CBB	HT2026072002628	10.00	70.00	2026-09-03 10:09:11	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-03 02:12:32.807747
163	5C0E6-2DC6CB-260903101413	03000011	F6FF4CBB	HT2026072002628	5.00	35.00	2026-09-03 10:14:13	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-03 03:07:23.717718
164	5C0E6-2DC6CB-260903102800	03000011	F6FF4CBB	HT2026072002628	5.00	35.00	2026-09-03 10:28:00	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-03 03:07:23.717721
165	5C0E6-4C4B42-260903112416	05000002	364A45BB	HT2026072002245	30.00	210.00	2026-09-03 11:24:16	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-03 06:50:21.49337
166	5C0E6-4C4B41-260903113059	05000001	764431BB	HT2026072002564	30.00	210.00	2026-09-03 11:30:59	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-03 06:50:21.493375
167	5C0E6-4C4B45-260903144105	05000005	D6AC3EBB	HT2026072002577	30.00	210.00	2026-09-03 14:41:05	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-03 06:50:21.493376
168	5C0E6-4C4B44-260903144354	05000004	567427BB	HT2026072002250	30.00	210.00	2026-09-03 14:43:54	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-03 06:50:21.493377
169	5C0E6-4C4B43-260903144828	05000003	96AB23BB	HT2026072002254	30.00	210.00	2026-09-03 14:48:28	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-03 06:50:21.493378
170	5BB80-2DC6CB-260903094350	03000011	F6FF4CBB	HT2026072002628	1.00	7.00	2026-09-03 09:43:50	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-03 07:20:22.530906
171	5BB80-15EF3C1-260903152748	23000001	D7595CAD	HT2026072002422	5.00	35.00	2026-09-03 15:27:48	RECHARGE	0310742010375680	RED_TESTING	2026-09-03 07:30:04.17969
172	5C0E6-2DC6FE-260903212340	03000062	E6331FBB	HT2026072002489	10.00	70.00	2026-09-03 21:23:40	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-04 02:10:35.549946
173	5C0E6-4C4B46-260905103708	05000006	C65A5EBB	HT2026072002550	30.00	210.00	2026-09-05 10:37:08	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 02:49:34.086123
174	5C0E6-4C4B47-260905103752	05000007	76F62EBB	HT2026072002540	30.00	210.00	2026-09-05 10:37:52	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 02:49:34.086125
175	5C0E6-4C4B48-260905104041	05000008	D6CB4EBB	HT2026072002570	30.00	210.00	2026-09-05 10:40:41	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 02:49:34.086126
176	5C0E6-4C4B49-260905104120	05000009	161025BB	HT2026072002575	30.00	210.00	2026-09-05 10:41:20	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 02:49:34.086127
177	5C0E6-4C4B4A-260905104154	05000010	C6D552BB	HT2026072002582	30.00	210.00	2026-09-05 10:41:54	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 02:49:34.086127
178	5C0E6-4C4B4B-260905104228	05000011	56BF1EBB	FT2109972692576	30.00	210.00	2026-09-05 10:42:28	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 02:49:34.086128
179	5C0E6-4C4B4C-260905104418	05000012	567835BB	HT2026072000529	30.00	210.00	2026-09-05 10:44:18	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 02:49:34.086128
180	5C0E6-4C4B4D-260905104509	05000013	F67333BB	HT2026072002561	30.00	210.00	2026-09-05 10:45:09	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 02:49:34.086128
181	5C0E6-4C4B4E-260905104536	05000014	063C53BB	HT2026072001440	30.00	210.00	2026-09-05 10:45:36	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 02:49:34.086129
182	5C0E6-4C4B4F-260905104616	05000015	E69B5CBB	HT2026072002591	30.00	210.00	2026-09-05 10:46:16	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 02:49:34.086129
183	5C0E6-4C4B51-260905104851	05000017	C6EB21BB	HT2026072002144	30.00	210.00	2026-09-05 10:48:51	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 02:49:34.08613
184	5C0E6-4C4B52-260905104918	05000018	A6A222BB	HT2026072002136	30.00	210.00	2026-09-05 10:49:18	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 02:49:34.08613
185	5C0E6-4C4B50-260905110535	05000016	36E856BB	HT2026072002590	30.00	210.00	2026-09-05 11:05:35	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:09:46.037373
186	5C0E6-4C4B53-260905110611	05000019	865B58BB	HT2026072002152	30.00	210.00	2026-09-05 11:06:11	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:09:46.037375
187	5C0E6-4C4B54-260905110640	05000020	A6904BBB	HT2026072002595	30.00	210.00	2026-09-05 11:06:40	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:09:46.037375
188	5C0E6-4C4B55-260905110705	05000021	D6B23EBB	HT2026072002123	30.00	210.00	2026-09-05 11:07:05	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:09:46.037376
189	5C0E6-4C4B56-260905110733	05000022	262F27BB	HT2026072002571	30.00	210.00	2026-09-05 11:07:33	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:09:46.037376
190	5C0E6-4C4B5A-260905111203	05000026	66B219BB	HT2026072002256	30.00	210.00	2026-09-05 11:12:03	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:14:44.732072
191	5C0E6-4C4B5C-260905111259	05000028	86764DBB	HT2026072002939	30.00	210.00	2026-09-05 11:12:59	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:14:44.732073
192	5C0E6-4C4B5D-260905111329	05000029	76F65BBB	HT2026072002265	30.00	210.00	2026-09-05 11:13:29	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:14:44.732074
193	5C0E6-4C4B5F-260905111434	05000031	D62C3ABB	HT2026072002243	30.00	210.00	2026-09-05 11:14:34	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:14:44.732074
194	5C0E6-4C4B57-260905111515	05000023	F6D335BB	HT2026072002272	30.00	210.00	2026-09-05 11:15:15	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:22:07.299986
195	5C0E6-4C4B58-260905111541	05000024	B6DA3FBB	HT2026072002244	30.00	210.00	2026-09-05 11:15:41	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:22:07.299988
196	5C0E6-4C4B59-260905111605	05000025	566137BB	HT2026072002906	30.00	210.00	2026-09-05 11:16:05	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:22:07.299989
197	5C0E6-4C4B60-260905111634	05000032	263F5DBB	HT2026072002943	30.00	210.00	2026-09-05 11:16:34	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:22:07.29999
198	5C0E6-4C4B61-260905111700	05000033	16D41CBB	HT2026072002585	30.00	210.00	2026-09-05 11:17:00	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:22:07.29999
199	5C0E6-4C4B62-260905111722	05000034	26A523BB	HT2026072002785	30.00	210.00	2026-09-05 11:17:22	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:22:07.299991
200	5C0E6-4C4B63-260905111752	05000035	76253CBB	HT2026072002121	30.00	210.00	2026-09-05 11:17:52	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:22:07.299992
201	5C0E6-4C4B64-260905111821	05000036	16574BBB	HT2026072002891	30.00	210.00	2026-09-05 11:18:21	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:22:07.299993
202	5C0E6-4C4B65-260905111851	05000037	D60D4EBB	HT2026072002276	30.00	210.00	2026-09-05 11:18:51	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:22:07.299993
203	5C0E6-4C4B66-260905111916	05000038	E67740BB	HT2026072002287	30.00	210.00	2026-09-05 11:19:16	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:22:07.299994
204	5C0E6-4C4B67-260905111945	05000039	564944BB	HT2026072002277	30.00	210.00	2026-09-05 11:19:45	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:22:07.299994
205	5C0E6-4C4B68-260905112011	05000040	065149BB	HT2026072002279	30.00	210.00	2026-09-05 11:20:11	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:22:07.299995
206	5C0E6-4C4B69-260905112048	05000041	B6A921BB	HT2026072002270	30.00	210.00	2026-09-05 11:20:48	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:22:07.299996
207	5C0E6-4C4B6A-260905112114	05000042	16FF21BB	HT2026072002719	30.00	210.00	2026-09-05 11:21:14	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:22:07.299996
208	5C0E6-4C4B6B-260905112136	05000043	765C37BB	HT2026072002973	30.00	210.00	2026-09-05 11:21:36	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:22:07.299997
209	5C0E6-4C4B6C-260905112159	05000044	B6D844BB	HT2026072002283	30.00	210.00	2026-09-05 11:21:59	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:22:07.299997
210	5C0E6-4C4B5B-260905112615	05000027	B6B442BB	HT2026072002597	30.00	210.00	2026-09-05 11:26:15	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:26:45.741553
211	5C0E6-4C4B5E-260905112641	05000030	763C3ABB	HT2026072002266	30.00	210.00	2026-09-05 11:26:41	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 03:26:45.741555
212	5C0E6-4C4B6D-260905121945	05000045	860A2BBB	HT2026072002994	30.00	210.00	2026-09-05 12:19:45	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979389
213	5C0E6-4C4B6E-260905122028	05000046	66DC2ABB	HT2026072002298	30.00	210.00	2026-09-05 12:20:28	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979391
214	5C0E6-4C4B70-260905124446	05000048	26632BBB	HT2026072002282	30.00	210.00	2026-09-05 12:44:46	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979391
215	5C0E6-4C4B71-260905124514	05000049	16AC23BB	HT2026072002864	30.00	210.00	2026-09-05 12:45:14	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979391
216	5C0E6-4C4B72-260905124543	05000050	364E52BB	HT2026072002986	30.00	210.00	2026-09-05 12:45:43	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979392
217	5C0E6-4C4B73-260905124610	05000051	46875CBB	HT2026072002319	30.00	210.00	2026-09-05 12:46:10	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979392
218	5C0E6-4C4B74-260905124643	05000052	C67C48BB	HT2026072002868	30.00	210.00	2026-09-05 12:46:43	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979392
219	5C0E6-4C4B75-260905124718	05000053	860627BB	HT2026072002937	30.00	210.00	2026-09-05 12:47:18	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979393
220	5C0E6-4C4B76-260905124741	05000054	F6BC53BB	HT2026072002307	30.00	210.00	2026-09-05 12:47:41	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979393
221	5C0E6-4C4B77-260905124809	05000055	76234FBB	HT2026072002296	30.00	210.00	2026-09-05 12:48:09	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979394
222	5C0E6-4C4B78-260905124836	05000056	C6354DBB	BX2147778002871	30.00	210.00	2026-09-05 12:48:36	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979394
223	5C0E6-4C4B79-260905124907	05000057	36AE4EBB	HT2026072002107	30.00	210.00	2026-09-05 12:49:07	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979394
224	5C0E6-4C4B7A-260905124936	05000058	66633CBB	HT2026072002297	30.00	210.00	2026-09-05 12:49:36	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979395
225	5C0E6-4C4B7B-260905125007	05000059	26EA39BB	HT2026072002821	30.00	210.00	2026-09-05 12:50:07	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979395
226	5C0E6-4C4B7C-260905125042	05000060	16514CBB	HT2026072002618	30.00	210.00	2026-09-05 12:50:42	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979395
227	5C0E6-4C4B7D-260905125109	05000061	C6A01EBB	HT2026072002312	30.00	210.00	2026-09-05 12:51:09	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979396
228	5C0E6-4C4B7E-260905125152	05000062	A66836BB	HT2026072002327	30.00	210.00	2026-09-05 12:51:52	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979396
229	5C0E6-4C4B7F-260905125231	05000063	86134BBB	HT2026072002302	30.00	210.00	2026-09-05 12:52:31	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979397
230	5C0E6-4C4B80-260905125310	05000064	F6984DBB	HT2026072002847	30.00	210.00	2026-09-05 12:53:10	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979397
231	5C0E6-4C4B81-260905125336	05000065	D6B842BB	HT2026072002313	30.00	210.00	2026-09-05 12:53:36	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979397
232	5C0E6-4C4B82-260905125400	05000066	36A43CBB	HT2026072002995	30.00	210.00	2026-09-05 12:54:00	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979398
233	5C0E6-4C4B83-260905125423	05000067	96371FBB	HT2026072002614	30.00	210.00	2026-09-05 12:54:23	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979398
234	5C0E6-4C4B84-260905125507	05000068	061449BB	HT2026072002889	30.00	210.00	2026-09-05 12:55:07	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979398
235	5C0E6-4C4B85-260905125537	05000069	26BF45BB	HT2026072002340	30.00	210.00	2026-09-05 12:55:37	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979399
236	5C0E6-4C4B86-260905125604	05000070	C6E81ABB	HT2026072002919	30.00	210.00	2026-09-05 12:56:04	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979399
237	5C0E6-4C4B87-260905125630	05000071	66FF21BB	HT2026072002932	30.00	210.00	2026-09-05 12:56:30	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979399
238	5C0E6-4C4B88-260905125741	05000072	A6585CBB	HT2026072002339	30.00	210.00	2026-09-05 12:57:41	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.9794
239	5C0E6-4C4B89-260905125807	05000073	46CB3ABB	HT2026072002921	30.00	210.00	2026-09-05 12:58:07	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.9794
240	5C0E6-4C4B8A-260905125904	05000074	F67533BB	HT2026072002930	30.00	210.00	2026-09-05 12:59:04	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979401
241	5C0E6-4C4B8E-260905131344	05000078	C65B3EBB	HT2026072002975	30.00	210.00	2026-09-05 13:13:44	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979401
242	5C0E6-4C4B8F-260905131408	05000079	76F352BB	HT2026072002542	30.00	210.00	2026-09-05 13:14:08	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979401
243	5C0E6-4C4B90-260905131431	05000080	269021BB	HT2026072002832	30.00	210.00	2026-09-05 13:14:31	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979402
244	5C0E6-4C4B91-260905131608	05000081	56C051BB	HT2026072002927	30.00	210.00	2026-09-05 13:16:08	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979402
245	5C0E6-4C4B92-260905131632	05000082	06561DBB	HT2026072002902	30.00	210.00	2026-09-05 13:16:32	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979402
246	5C0E6-4C4B96-260905131805	05000086	56363ABB	HT2026072002969	30.00	210.00	2026-09-05 13:18:05	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979403
247	5C0E6-4C4B97-260905131833	05000087	C6D73BBB	HT2026072001592	30.00	210.00	2026-09-05 13:18:33	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979403
248	5C0E6-4C4B98-260905131855	05000088	668A1FBB	HT2026072001586	30.00	210.00	2026-09-05 13:18:55	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979404
249	5C0E6-4C4B99-260905131924	05000089	661D38BB	HT2026072001594	30.00	210.00	2026-09-05 13:19:24	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979404
250	5C0E6-4C4B9A-260905131955	05000090	A67125BB	HT2026072001584	30.00	210.00	2026-09-05 13:19:55	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979404
251	5C0E6-4C4B9B-260905132031	05000091	86FB44BB	HT2026072001609	30.00	210.00	2026-09-05 13:20:31	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979405
252	5C0E6-4C4B9C-260905132059	05000092	16CC46BB	HT2026072002958	30.00	210.00	2026-09-05 13:20:59	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979405
253	5C0E6-4C4B9D-260905132128	05000093	667547BB	HT2026072001591	30.00	210.00	2026-09-05 13:21:28	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:23:20.979405
254	5C0E6-4C4B9E-260905132402	05000094	767645BB	HT2026072002883	30.00	210.00	2026-09-05 13:24:02	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 05:24:12.528753
255	5C0E6-4C4B93-260905133101	05000083	F6591DBB	HT2026072001597	30.00	210.00	2026-09-05 13:31:01	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 06:01:26.572728
256	5C0E6-4C4BA1-260905143551	05000097	F68E37BB	HT2026072002959	30.00	210.00	2026-09-05 14:35:51	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561794
257	5C0E6-4C4BA2-260905143712	05000098	A6EA28BB	HT2026072002984	30.00	210.00	2026-09-05 14:37:12	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561796
258	5C0E6-4C4BA3-260905144612	05000099	C69D2BBB	HT2026072002885	30.00	210.00	2026-09-05 14:46:12	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561797
259	5C0E6-4C4BA4-260905144640	05000100	B67A25BB	HT2026072002967	30.00	210.00	2026-09-05 14:46:40	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561797
260	5C0E6-4C4BA5-260905144709	05000101	A64E3ABB	HT2026072002968	30.00	210.00	2026-09-05 14:47:09	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561798
261	5C0E6-4C4BA6-260905144743	05000102	46F043BB	HT2026072002897	30.00	210.00	2026-09-05 14:47:43	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561798
262	5C0E6-4C4BA7-260905144807	05000103	C6DB37BB	HT2026072001467	30.00	210.00	2026-09-05 14:48:07	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561798
263	5C0E6-4C4BA8-260905144831	05000104	E6EC58BB	HT2026072001474	30.00	210.00	2026-09-05 14:48:31	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561799
264	5C0E6-4C4BA9-260905144857	05000105	D64726BB	HT2026072001484	30.00	210.00	2026-09-05 14:48:57	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561799
265	5C0E6-4C4BAC-260905145005	05000108	165B27BB	HT2026072001491	30.00	210.00	2026-09-05 14:50:05	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.5618
266	5C0E6-4C4BAE-260905145107	05000110	E66B23BB	HT2026072001460	30.00	210.00	2026-09-05 14:51:07	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.5618
267	5C0E6-4C4BAF-260905145132	05000111	066B58BB	HT2026072001487	30.00	210.00	2026-09-05 14:51:32	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.5618
268	5C0E6-4C4BB0-260905145156	05000112	766C25BB	HT2026072001690	30.00	210.00	2026-09-05 14:51:56	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561801
269	5C0E6-4C4BB2-260905145239	05000114	769D49BB	HT2026072001499	30.00	210.00	2026-09-05 14:52:39	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561801
270	5C0E6-4C4BB3-260905145302	05000115	D65B3EBB	HT2026072001496	30.00	210.00	2026-09-05 14:53:02	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561801
271	5C0E6-4C4BB4-260905145323	05000116	F6F72CBB	HT2026072001388	30.00	210.00	2026-09-05 14:53:23	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561802
272	5C0E6-4C4BB5-260905145346	05000117	F67339BB	HT2026072001495	30.00	210.00	2026-09-05 14:53:46	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561802
273	5C0E6-4C4BB6-260905145409	05000118	F64943BB	HT2026072001504	30.00	210.00	2026-09-05 14:54:09	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561803
274	5C0E6-4C4BB7-260905145427	05000119	26F151BB	HT2026072001503	30.00	210.00	2026-09-05 14:54:27	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561803
275	5C0E6-4C4BB8-260905145453	05000120	568A3BBB	HT2026072001510	30.00	210.00	2026-09-05 14:54:53	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561803
276	5C0E6-4C4BBB-260905145622	05000123	367C4CBB	HT2026072001500	30.00	210.00	2026-09-05 14:56:22	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561804
277	5C0E6-4C4BBD-260905145704	05000125	16CE4DBB	HT2026072001512	30.00	210.00	2026-09-05 14:57:04	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561804
278	5C0E6-4C4BBF-260905145740	05000127	C66940BB	HT2026072001424	30.00	210.00	2026-09-05 14:57:40	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561804
279	5C0E6-4C4BC1-260905145828	05000129	C61B25BB	HT2026072002865	30.00	210.00	2026-09-05 14:58:28	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561805
280	5C0E6-4C4BC2-260905145852	05000130	F65152BB	HT2026072002240	30.00	210.00	2026-09-05 14:58:52	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561805
281	5C0E6-4C4BC3-260905145910	05000131	368C59BB	HT2026072002281	30.00	210.00	2026-09-05 14:59:10	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561806
282	5C0E6-4C4BC4-260905145933	05000132	F6745DBB	HT2026072001518	30.00	210.00	2026-09-05 14:59:33	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561806
283	5C0E6-4C4BC5-260905150005	05000133	C61B1ABB	HT2026072002855	30.00	210.00	2026-09-05 15:00:05	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561806
284	5C0E6-4C4BC6-260905150033	05000134	F6B326BB	HT2026072002928	30.00	210.00	2026-09-05 15:00:33	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561807
285	5C0E6-4C4BC8-260905150130	05000136	861123BB	HT2026072001506	30.00	210.00	2026-09-05 15:01:30	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561807
286	5C0E6-4C4BC9-260905150158	05000137	16612BBB	HT2026072001516	30.00	210.00	2026-09-05 15:01:58	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561807
287	5C0E6-4C4BCA-260905150230	05000138	36254CBB	HT2026072001508	30.00	210.00	2026-09-05 15:02:30	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561808
288	5C0E6-4C4BCB-260905150256	05000139	D60132BB	HT2026072001517	30.00	210.00	2026-09-05 15:02:56	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561808
289	5C0E6-4C4BCC-260905150318	05000140	D66558BB	HT2026072001513	30.00	210.00	2026-09-05 15:03:18	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561808
290	5C0E6-4C4BCD-260905150344	05000141	361222BB	HT2026072002300	30.00	210.00	2026-09-05 15:03:44	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561809
291	5C0E6-4C4BCE-260905150413	05000142	E62125BB	HT2026072002267	30.00	210.00	2026-09-05 15:04:13	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.561809
292	5C0E6-4C4BCF-260905150438	05000143	961249BB	HT2026072001612	30.00	210.00	2026-09-05 15:04:38	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.56181
293	5C0E6-4C4BD0-260905150505	05000144	E6E835BB	HT2026072001514	30.00	210.00	2026-09-05 15:05:05	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 07:05:38.56181
294	5C0E6-4C4BD1-260905152201	05000145	C6DD37BB	HT2026072002322	30.00	210.00	2026-09-05 15:22:01	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636068
295	5C0E6-4C4BD2-260905152257	05000146	C6214ABB	HT2026072002306	30.00	210.00	2026-09-05 15:22:57	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.63607
296	5C0E6-4C4BD3-260905152319	05000147	16FB28BB	HT2026072001645	30.00	210.00	2026-09-05 15:23:19	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.63607
297	5C0E6-4C4BD4-260905152340	05000148	A66D31BB	FT2026072002852	30.00	210.00	2026-09-05 15:23:40	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636071
298	5C0E6-4C4BD5-260905152403	05000149	36305BBB	HT2026072002321	30.00	210.00	2026-09-05 15:24:03	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636071
299	5C0E6-4C4BD6-260905152421	05000150	46AC26BB	HT2026072001611	30.00	210.00	2026-09-05 15:24:21	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636071
300	5C0E6-4C4BD7-260905152442	05000151	16C41EBB	HT2026072002304	30.00	210.00	2026-09-05 15:24:42	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636072
301	5C0E6-4C4BD8-260905152505	05000152	561451BB	HT2026072002239	30.00	210.00	2026-09-05 15:25:05	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636072
302	5C0E6-4C4BD9-260905152521	05000153	26B121BB	HT2026072002232	30.00	210.00	2026-09-05 15:25:21	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636073
303	5C0E6-4C4BDA-260905152542	05000154	B65D55BB	HT2026072001610	30.00	210.00	2026-09-05 15:25:42	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636073
304	5C0E6-4C4BDB-260905152608	05000155	86AA58BB	HT2026072001646	30.00	210.00	2026-09-05 15:26:08	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636073
305	5C0E6-4C4BDC-260905152700	05000156	665039BB	HT2026072001637	30.00	210.00	2026-09-05 15:27:00	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636074
306	5C0E6-4C4BDD-260905152822	05000157	A6E022BB	HT2026072001654	30.00	210.00	2026-09-05 15:28:22	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636074
307	5C0E6-4C4BDE-260905172431	05000158	F68156BB	HT2026072001590	30.00	210.00	2026-09-05 17:24:31	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636075
308	5C0E6-4C4BDF-260905172515	05000159	66D452BB	HT2026072001643	30.00	210.00	2026-09-05 17:25:15	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636075
309	5C0E6-4C4BE0-260905172554	05000160	B60035BB	HT2026072001606	30.00	210.00	2026-09-05 17:25:54	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636075
310	5C0E6-4C4BE1-260905172705	05000161	A69629BB	HT2026072001615	30.00	210.00	2026-09-05 17:27:05	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636076
311	5C0E6-4C4BE2-260905172733	05000162	A6043DBB	HT2026072001613	30.00	210.00	2026-09-05 17:27:33	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636076
312	5C0E6-4C4BE3-260905172802	05000163	36FD44BB	HT2026072001572	30.00	210.00	2026-09-05 17:28:02	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636076
313	5C0E6-4C4BE4-260905172827	05000164	96882FBB	HT2026072001616	30.00	210.00	2026-09-05 17:28:27	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636077
314	5C0E6-4C4BE5-260905172900	05000165	965D1DBB	HT2026072001628	30.00	210.00	2026-09-05 17:29:00	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636077
315	5C0E6-4C4BE6-260905172940	05000166	168B30BB	HT2026072001618	30.00	210.00	2026-09-05 17:29:40	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636078
316	5C0E6-4C4BE7-260905173014	05000167	965159BB	HT2026072001634	30.00	210.00	2026-09-05 17:30:14	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636078
317	5C0E6-4C4BE8-260905173057	05000168	26082FBB	HT2026072001621	30.00	210.00	2026-09-05 17:30:57	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636078
318	5C0E6-4C4BE9-260905173131	05000169	A60524BB	HT2026072001608	30.00	210.00	2026-09-05 17:31:31	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636079
319	5C0E6-4C4BEA-260905173209	05000170	D64B5BBB	HT2026072001625	30.00	210.00	2026-09-05 17:32:09	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636079
320	5C0E6-4C4BEB-260905173235	05000171	A65C59BB	HT2026072001641	30.00	210.00	2026-09-05 17:32:35	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636079
321	5C0E6-4C4BED-260905173331	05000173	B6B933BB	HT2026072001622	30.00	210.00	2026-09-05 17:33:31	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.63608
322	5C0E6-4C4BEC-260905173406	05000172	E6F73BBB	HT2026072001620	30.00	210.00	2026-09-05 17:34:06	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.63608
323	5C0E6-4C4BEE-260905173441	05000174	A6E344BB	HT2026072001630	30.00	210.00	2026-09-05 17:34:41	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.63608
324	5C0E6-4C4BEF-260905173506	05000175	A6D942BB	HT2026072001623	30.00	210.00	2026-09-05 17:35:06	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636081
325	5C0E6-4C4BF0-260905173551	05000176	36A753BB	HT2026072001614	30.00	210.00	2026-09-05 17:35:51	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636081
326	5C0E6-4C4BF1-260905173616	05000177	26433CBB	HT2026072001640	30.00	210.00	2026-09-05 17:36:16	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636082
327	5C0E6-4C4BF2-260905173646	05000178	E60A27BB	HT2026072001629	30.00	210.00	2026-09-05 17:36:46	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636082
328	5C0E6-4C4BF3-260905173723	05000179	F69740BB	HT2026072001651	30.00	210.00	2026-09-05 17:37:23	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636082
329	5C0E6-4C4BF4-260905173809	05000180	66284FBB	HT2026072001624	30.00	210.00	2026-09-05 17:38:09	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636083
330	5C0E6-4C4BF5-260905173844	05000181	266958BB	HT2026072001650	30.00	210.00	2026-09-05 17:38:44	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636083
331	5C0E6-4C4BF6-260905173923	05000182	D61F3CBB	HT2026072002328	30.00	210.00	2026-09-05 17:39:23	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636083
332	5C0E6-4C4BF7-260905174000	05000183	263425BB	HT2026072002964	30.00	210.00	2026-09-05 17:40:00	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636084
333	5C0E6-4C4BF8-260905174117	05000184	C6BF43BB	HT2026072001648	30.00	210.00	2026-09-05 17:41:17	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636084
334	5C0E6-4C4BF9-260905174256	05000185	76A35CBB	HT2026072001636	30.00	210.00	2026-09-05 17:42:56	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636085
335	5C0E6-4C4BFA-260905174321	05000186	068347BB	HT2026072001632	30.00	210.00	2026-09-05 17:43:21	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636085
336	5C0E6-4C4BFB-260905174356	05000187	765F49BB	HT2026072001635	30.00	210.00	2026-09-05 17:43:56	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636085
337	5C0E6-4C4BFC-260905174426	05000188	E6BA2CBB	HT2026072001653	30.00	210.00	2026-09-05 17:44:26	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636086
338	5C0E6-4C4BFD-260905174537	05000189	76114EBB	HT2026072002318	30.00	210.00	2026-09-05 17:45:37	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636086
339	5C0E6-4C4BFE-260905174608	05000190	768C42BB	HT2026072001699	30.00	210.00	2026-09-05 17:46:08	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636086
340	5C0E6-4C4C00-260905174700	05000192	16D03ABB	HT2026072001658	30.00	210.00	2026-09-05 17:47:00	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636087
341	5C0E6-4C4C01-260905174722	05000193	467A1ABB	HT2026072001649	30.00	210.00	2026-09-05 17:47:22	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636087
342	5C0E6-4C4C02-260905174741	05000194	365635BB	HT2026072002853	30.00	210.00	2026-09-05 17:47:41	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:47:49.636087
343	5C0E6-4C4BFF-260905174926	05000191	B62F20BB	HT2026072001660	30.00	210.00	2026-09-05 17:49:26	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 09:49:46.161776
344	5C0E6-4C4C03-260905175344	05000195	06F337BB	HT2026072002543	30.00	210.00	2026-09-05 17:53:44	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217475
345	5C0E6-4C4C04-260905175410	05000196	069D1FBB	HT2026072002899	30.00	210.00	2026-09-05 17:54:10	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217477
346	5C0E6-4C4C05-260905175440	05000197	96762BBB	HT2026072002320	30.00	210.00	2026-09-05 17:54:40	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217478
347	5C0E6-4C4C06-260905175509	05000198	E6FD37BB	HT2026072002971	30.00	210.00	2026-09-05 17:55:09	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217478
348	5C0E6-4C4C07-260905175534	05000199	66A619BB	HT2026072002324	30.00	210.00	2026-09-05 17:55:34	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217478
349	5C0E6-4C4C08-260905175617	05000200	C6B61EBB	HT2026072002963	30.00	210.00	2026-09-05 17:56:17	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217479
350	5C0E6-4C4C09-260905175638	05000201	96003BBB	HT2026072002331	30.00	210.00	2026-09-05 17:56:38	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217479
351	5C0E6-4C4C0A-260905175725	05000202	36FA52BB	HT2026072002747	30.00	210.00	2026-09-05 17:57:25	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.21748
352	5C0E6-4C4C0B-260905175746	05000203	561224BB	HT2026072002325	30.00	210.00	2026-09-05 17:57:46	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.21748
353	5C0E6-4C4C0C-260905175811	05000204	368D31BB	HT2026072002989	30.00	210.00	2026-09-05 17:58:11	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.21748
354	5C0E6-4C4C0D-260905175830	05000205	865657BB	HT2026072002972	30.00	210.00	2026-09-05 17:58:30	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217481
355	5C0E6-4C4C0E-260905175849	05000206	761B2BBB	HT2026072001404	30.00	210.00	2026-09-05 17:58:49	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217481
356	5C0E6-4C4C0F-260905175908	05000207	266839BB	HT2026072001394	30.00	210.00	2026-09-05 17:59:08	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217481
357	5C0E6-4C4C10-260905175929	05000208	16B45CBB	HT2026072001425	30.00	210.00	2026-09-05 17:59:29	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217482
358	5C0E6-4C4C11-260905175946	05000209	26595CBB	HT2026072001656	30.00	210.00	2026-09-05 17:59:46	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217482
359	5C0E6-4C4C12-260905180004	05000210	16BD1FBB	HT2026072000530	30.00	210.00	2026-09-05 18:00:04	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217483
360	5C0E6-4C4C13-260905180022	05000211	A6A333BB	HT2026072001683	30.00	210.00	2026-09-05 18:00:22	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217483
361	5C0E6-4C4C14-260905180039	05000212	F60F1BBB	HT2026072001426	30.00	210.00	2026-09-05 18:00:39	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217483
362	5C0E6-4C4C15-260905180056	05000213	C65229BB	HT2026072001431	30.00	210.00	2026-09-05 18:00:56	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217484
363	5C0E6-4C4C16-260905180116	05000214	66D03EBB	HT2026072001374	30.00	210.00	2026-09-05 18:01:16	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217484
364	5C0E6-4C4C17-260905180132	05000215	C6344BBB	HT2026072001412	30.00	210.00	2026-09-05 18:01:32	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217485
365	5C0E6-4C4C18-260905180151	05000216	169B23BB	Fn:206078001400	30.00	210.00	2026-09-05 18:01:51	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217485
366	5C0E6-4C4C19-260905180213	05000217	464935BB	HT2026072001406	30.00	210.00	2026-09-05 18:02:13	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217485
367	5C0E6-4C4C1A-260905180236	05000218	760647BB	HT2026072001397	30.00	210.00	2026-09-05 18:02:36	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217486
368	5C0E6-4C4C1B-260905180252	05000219	E68621BB	HT2026072002019	30.00	210.00	2026-09-05 18:02:52	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217486
369	5C0E6-4C4C1C-260905180311	05000220	B6CE48BB	HT2026072001692	30.00	210.00	2026-09-05 18:03:11	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217486
370	5C0E6-4C4C1D-260905180335	05000221	36CD3BBB	HT2026072001410	30.00	210.00	2026-09-05 18:03:35	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217487
371	5C0E6-4C4C1E-260905180351	05000222	A64129BB	HT2026072001398	30.00	210.00	2026-09-05 18:03:51	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217487
372	5C0E6-4C4C1F-260905180410	05000223	B61D3ABB	HT2026072001420	30.00	210.00	2026-09-05 18:04:10	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217488
373	5C0E6-4C4C20-260905180429	05000224	E6A247BB	HT2026072001421	30.00	210.00	2026-09-05 18:04:29	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217488
374	5C0E6-4C4C21-260905180448	05000225	16205CBB	HT2026072001427	30.00	210.00	2026-09-05 18:04:48	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217488
375	5C0E6-4C4C22-260905180508	05000226	86885ABB	HT2026072001408	30.00	210.00	2026-09-05 18:05:08	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217489
376	5C0E6-4C4C23-260905180531	05000227	46C13DBB	HT2026072001414	30.00	210.00	2026-09-05 18:05:31	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217489
377	5C0E6-4C4C24-260905180555	05000228	46232EBB	HT2026072001405	30.00	210.00	2026-09-05 18:05:55	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217489
378	5C0E6-4C4C25-260905180615	05000229	46635DBB	HT2026072001416	30.00	210.00	2026-09-05 18:06:15	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.21749
379	5C0E6-4C4C26-260905180636	05000230	56FF2CBB	HT2026072001423	30.00	210.00	2026-09-05 18:06:36	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.21749
380	5C0E6-4C4C27-260905180710	05000231	06CF1ABB	HT2026072001689	30.00	210.00	2026-09-05 18:07:10	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.21749
381	5C0E6-4C4C28-260905180735	05000232	D60922BB	HT2026072001422	30.00	210.00	2026-09-05 18:07:35	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217491
382	5C0E6-4C4C29-260905180800	05000233	56493DBB	HT2026072001677	30.00	210.00	2026-09-05 18:08:00	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217491
383	5C0E6-4C4C2A-260905180822	05000234	A6E631BB	HT2026072001438	30.00	210.00	2026-09-05 18:08:22	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217492
384	5C0E6-4C4C2B-260905180841	05000235	16DB21BB	HT2026072001417	30.00	210.00	2026-09-05 18:08:41	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217492
385	5C0E6-4C4C2C-260905180902	05000236	A61349BB	HT2026072001688	30.00	210.00	2026-09-05 18:09:02	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217492
386	5C0E6-4C4C2D-260905180924	05000237	66C833BB	HT2026072001437	30.00	210.00	2026-09-05 18:09:24	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217493
387	5C0E6-4C4C2E-260905180948	05000238	266E2BBB	HT2026072001707	30.00	210.00	2026-09-05 18:09:48	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217493
388	5C0E6-4C4C2F-260905181011	05000239	A6003BBB	HT2026072001428	30.00	210.00	2026-09-05 18:10:11	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217493
389	5C0E6-4C4C30-260905181037	05000240	06475BBB	HT2026072001435	30.00	210.00	2026-09-05 18:10:37	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217494
390	5C0E6-4C4C32-260905181127	05000242	A6F725BB	HT2026072001444	30.00	210.00	2026-09-05 18:11:27	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217494
391	5C0E6-4C4C33-260905181147	05000243	26F551BB	HT2026072001719	30.00	210.00	2026-09-05 18:11:47	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217495
392	5C0E6-4C4C34-260905181207	05000244	C65155BB	HT2026072001681	30.00	210.00	2026-09-05 18:12:07	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:12:13.217495
393	5C0E6-4C4C31-260905181308	05000241	B6685ABB	HT2026072001443	30.00	210.00	2026-09-05 18:13:08	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:13:12.791868
394	5C0E6-4C4BC0-260905181449	05000128	A61E27BB	HT2026072002326	30.00	210.00	2026-09-05 18:14:49	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:18:26.138758
395	5C0E6-4C4BC7-260905181512	05000135	D6D040BB	HT2026072002931	30.00	210.00	2026-09-05 18:15:12	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:18:26.138759
396	5C0E6-4C4BBE-260905181531	05000126	76635EBB	HT2026072001515	30.00	210.00	2026-09-05 18:15:31	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:18:26.13876
397	5C0E6-4C4BBC-260905181552	05000124	66073EBB	HT2026072001507	30.00	210.00	2026-09-05 18:15:52	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:18:26.13876
398	5C0E6-4C4BBA-260905181608	05000122	765252BB	HT2026072001505	30.00	210.00	2026-09-05 18:16:08	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:18:26.138761
399	5C0E6-4C4BB9-260905181623	05000121	96A04BBB	HT2026072001509	30.00	210.00	2026-09-05 18:16:23	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:18:26.138761
400	5C0E6-4C4BB1-260905181641	05000113	863F25BB	HT2026072001498	30.00	210.00	2026-09-05 18:16:41	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:18:26.138762
401	5C0E6-4C4BAD-260905181702	05000109	26895BBB	HT2026072001485	30.00	210.00	2026-09-05 18:17:02	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:18:26.138762
402	5C0E6-4C4BAB-260905181718	05000107	561E1BBB	HT2026072001494	30.00	210.00	2026-09-05 18:17:18	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:18:26.138762
403	5C0E6-4C4BAA-260905181742	05000106	26155EBB	HT2026072001469	30.00	210.00	2026-09-05 18:17:42	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:18:26.138763
404	5C0E6-4C4BA0-260905181801	05000096	061D29BB	HT2026072002957	30.00	210.00	2026-09-05 18:18:01	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:18:26.138763
405	5C0E6-4C4B9F-260905181820	05000095	76675CBB	HT2026072002966	30.00	210.00	2026-09-05 18:18:20	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 10:18:26.138763
406	5C0E6-4C4B8C-260905210730	05000076	C6A33EBB	HT2026072001589	30.00	210.00	2026-09-05 21:07:30	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 13:13:54.276851
407	5C0E6-4C4B8D-260905210806	05000077	96501DBB	HT2026072002840	30.00	210.00	2026-09-05 21:08:06	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 13:13:54.276853
408	5C0E6-4C4B94-260905210914	05000084	16C250BB	HT2026072002981	30.00	210.00	2026-09-05 21:09:14	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 13:13:54.276853
409	5C0E6-4C4B95-260905211006	05000085	F67A43BB	HT2026072002962	30.00	210.00	2026-09-05 21:10:06	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 13:13:54.276853
410	5C0E6-4C4B8B-260905211103	05000075	B6CE4DBB	HT2026072002842	30.00	210.00	2026-09-05 21:11:03	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 13:13:54.276854
411	5C0E6-4C4B6F-260905211328	05000047	46AF55BB	HT2026072002873	30.00	210.00	2026-09-05 21:13:28	RECHARGE	0310742010377062	BRGY_TINULTULAN	2026-09-05 13:13:54.276854
412	5C0E6-2DC6E4-260915131206	03000036	D6752BBB	HT2026072002655	10.00	70.00	2026-09-15 13:12:06	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935302
413	5C0E6-2DC6E3-260915131240	03000035	36142BBB	HT2026072002179	10.00	70.00	2026-09-15 13:12:40	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935306
414	5C0E6-2DC6CC-260915131404	03000012	16782DBB	HT2026072001601	10.00	70.00	2026-09-15 13:14:04	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935306
415	5C0E6-2DC6CB-260915132513	03000011	F6FF4CBB	HT2026072002628	10.00	70.00	2026-09-15 13:25:13	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935307
416	5C0E6-2DC6CD-260915132531	03000013	56EF5ABB	HT2026072002615	10.00	70.00	2026-09-15 13:25:31	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935308
417	5C0E6-2DC6C1-260915132556	03000001	068450BB	HT2026072001599	10.00	70.00	2026-09-15 13:25:56	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935309
418	5C0E6-2DC6C6-260915132618	03000006	F6C756BB	HT2026072001587	10.00	70.00	2026-09-15 13:26:18	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935309
419	5C0E6-2DC6F2-260915132636	03000050	861D45BB	HT2026072002671	10.00	70.00	2026-09-15 13:26:36	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.93531
420	5C0E6-2DC6F1-260915132656	03000049	86DD19BB	HT2026072002645	30.00	210.00	2026-09-15 13:26:56	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935311
421	5C0E6-2DC6F0-260915132711	03000048	86CB24BB	HT2026072002683	30.00	210.00	2026-09-15 13:27:11	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935312
422	5C0E6-2DC6E5-260915132729	03000037	E6D828BB	HT2026072002596	10.00	70.00	2026-09-15 13:27:29	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935312
423	5C0E6-2DC6FF-260915132913	03000063	A6391ABB	HT2026072002498	10.00	70.00	2026-09-15 13:29:13	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935313
424	5C0E6-2DC700-260915133019	03000064	D6DF37BB	HT2026072002479	10.00	70.00	2026-09-15 13:30:19	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935314
425	5C0E6-2DC701-260915133055	03000065	F67423BB	HT2026072001511	10.00	70.00	2026-09-15 13:30:55	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935315
426	5C0E6-2DC702-260915133115	03000066	D6E539BB	HT2026072002500	10.00	70.00	2026-09-15 13:31:15	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935315
427	5C0E6-2DC6C8-260915133144	03000008	36F64CBB	HT2026072001583	10.00	70.00	2026-09-15 13:31:44	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935316
428	5C0E6-2DC6C7-260915133202	03000007	160145BB	HT2026072001604	10.00	70.00	2026-09-15 13:32:02	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935317
429	5C0E6-2DC6C2-260915133227	03000002	866835BB	HT2026072001585	10.00	70.00	2026-09-15 13:32:27	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935318
430	5C0E6-2DC6C3-260915133250	03000003	86865CBB	HT2026072001596	10.00	70.00	2026-09-15 13:32:50	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935319
431	5C0E6-2DC6C4-260915133310	03000004	36634FBB	HT2026072001600	10.00	70.00	2026-09-15 13:33:10	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935319
432	5C0E6-2DC6CA-260915133333	03000010	96B937BB	HT2026072001593	10.00	70.00	2026-09-15 13:33:33	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.93532
433	5C0E6-2DC6C9-260915133351	03000009	968C52BB	HT2026072001605	10.00	70.00	2026-09-15 13:33:51	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935321
434	5C0E6-2DC70B-260915133404	03000075	F6CE2ABB	HT2026072002487	10.00	70.00	2026-09-15 13:34:04	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935321
435	5C0E6-2DC70A-260915133425	03000074	36B459BB	HT2026072002462	10.00	70.00	2026-09-15 13:34:25	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935322
436	5C0E6-2DC709-260915133446	03000073	76A92CBB	HT2026072001483	10.00	70.00	2026-09-15 13:34:46	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935323
437	5C0E6-2DC708-260915133510	03000072	96543ABB	HT2021963001481	10.00	70.00	2026-09-15 13:35:10	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935323
438	5C0E6-2DC707-260915133529	03000071	A65547BB	HT2026072001461	10.00	70.00	2026-09-15 13:35:29	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935324
439	5C0E6-2DC6FD-260915133632	03000061	263E2DBB	HT2026072002486	10.00	70.00	2026-09-15 13:36:32	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935325
440	5C0E6-2DC711-260915133648	03000081	969931BB	HT2026072001476	10.00	70.00	2026-09-15 13:36:48	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935325
441	5C0E6-2DC712-260915133711	03000082	36AE39BB	HT2026072001468	10.00	70.00	2026-09-15 13:37:11	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935326
442	5C0E6-2DC713-260915133733	03000083	A65221BB	HT2026072001490	10.00	70.00	2026-09-15 13:37:33	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935327
443	5C0E6-2DC714-260915133750	03000084	161838BB	HT2026072001488	10.00	70.00	2026-09-15 13:37:50	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935328
444	5C0E6-2DC6C5-260915133819	03000005	460D47BB	HT2026072001588	10.00	70.00	2026-09-15 13:38:19	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935328
445	5C0E6-2DC703-260915133838	03000067	665439BB	HT2026072003007	10.00	70.00	2026-09-15 13:38:38	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935329
446	5C0E6-2DC705-260915134154	03000069	F6FA4CBB	HT2026072003006	10.00	70.00	2026-09-15 13:41:54	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.93533
447	5C0E6-2DC70F-260915134249	03000079	96ED42BB	HT2026072001475	10.00	70.00	2026-09-15 13:42:49	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935331
448	5C0E6-2DC70E-260915134334	03000078	66C733BB	HT2026072002491	10.00	70.00	2026-09-15 13:43:34	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935331
449	5C0E6-2DC70D-260915134402	03000077	963049BB	HT2026072001471	10.00	70.00	2026-09-15 13:44:02	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935332
450	5C0E6-2DC70C-260915134435	03000076	96302BBB	HT2026072002499	10.00	70.00	2026-09-15 13:44:35	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935333
451	5C0E6-2DC71E-260915134448	03000094	469619BB	HT2026072000533	10.00	70.00	2026-09-15 13:44:48	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935334
452	5C0E6-2DC728-260915134506	03000104	D61153BB	HT2026072001480	10.00	70.00	2026-09-15 13:45:06	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935335
453	5C0E6-2DC74C-260915134521	03000140	76A644BB	HT2026072002910	10.00	70.00	2026-09-15 13:45:21	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935335
454	5C0E6-2DC72D-260915134543	03000109	E6FD2ABB	HT2026072002014	10.00	70.00	2026-09-15 13:45:43	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:46:20.935336
455	5C0E6-2DC72C-260915134814	03000108	C66140BB	HT2026072002208	10.00	70.00	2026-09-15 13:48:14	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:50:32.382169
456	5C0E6-2DC727-260915134842	03000103	96241CBB	HT2026072002734	10.00	70.00	2026-09-15 13:48:42	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 05:50:32.382171
457	5BB80-2DC72B-260915140847	03000107	46B81BBB	HT2026072000528	10.00	70.00	2026-09-15 14:08:47	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.35886
458	5BB80-2DC731-260915141017	03000113	464B51BB	HT2026072001723	10.00	70.00	2026-09-15 14:10:17	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358862
459	5BB80-2DC73B-260915142441	03000123	F6EA27BB	HT2026072002672	10.00	70.00	2026-09-15 14:24:41	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358863
460	5BB80-2DC72A-260915142532	03000106	96124BBB	HT2026072002781	10.00	70.00	2026-09-15 14:25:32	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358863
461	5BB80-2DC737-260915142604	03000119	D60F4FBB	HT2026072002718	10.00	70.00	2026-09-15 14:26:04	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358863
462	5BB80-2DC740-260915142626	03000128	E63058BB	HT2026072002830	10.00	70.00	2026-09-15 14:26:26	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358864
463	5BB80-2DC730-260915142654	03000112	C6BC23BB	HT2026072001434	10.00	70.00	2026-09-15 14:26:54	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358864
464	5BB80-2DC71C-260915142712	03000092	768236BB	HT2026072001466	10.00	70.00	2026-09-15 14:27:12	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358864
465	5BB80-2DC717-260915142727	03000087	661A3EBB	HT2026072001479	10.00	70.00	2026-09-15 14:27:27	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358865
466	5BB80-2DC71A-260915142740	03000090	662C23BB	HT2026072001493	10.00	70.00	2026-09-15 14:27:40	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358865
467	5BB80-2DC719-260915142759	03000089	269C56BB	HT2026072001478	10.00	70.00	2026-09-15 14:27:59	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358865
468	5BB80-2DC71F-260915142810	03000095	C67C44BB	HT2026072001464	10.00	70.00	2026-09-15 14:28:10	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358866
469	5BB80-2DC720-260915142822	03000096	66804DBB	HT2026072001445	10.00	70.00	2026-09-15 14:28:22	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358866
470	5BB80-2DC721-260915142850	03000097	16C940BB	HT2026072001429	10.00	70.00	2026-09-15 14:28:50	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358866
471	5BB80-2DC72F-260915142925	03000111	B65442BB	HT2026072002764	10.00	70.00	2026-09-15 14:29:25	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358867
472	5BB80-2DC735-260915142939	03000117	A6F824BB	HT2026072002909	10.00	70.00	2026-09-15 14:29:39	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358867
473	5BB80-2DC745-260915143000	03000133	C65B29BB	HT2026072002201	10.00	70.00	2026-09-15 14:30:00	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358867
474	5BB80-2DC723-260915143019	03000099	566E2BBB	HT2026072001418	10.00	70.00	2026-09-15 14:30:19	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358868
475	5BB80-2DC73C-260915143040	03000124	769C3EBB	HT2026072002678	10.00	70.00	2026-09-15 14:30:40	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358868
476	5BB80-2DC741-260915143056	03000129	26F840BB	HT2026072002701	10.00	70.00	2026-09-15 14:30:56	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358868
477	5BB80-2DC746-260915143112	03000134	96033EBB	HT2026072002118	10.00	70.00	2026-09-15 14:31:12	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358869
478	5BB80-2DC747-260915143131	03000135	261851BB	HT2026072002715	10.00	70.00	2026-09-15 14:31:31	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358869
479	5BB80-2DC759-260915143316	03000153	C6774FBB	HT2026072002495	10.00	70.00	2026-09-15 14:33:16	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358869
480	5BB80-2DC74B-260915143702	03000139	06B35DBB	HT2026072002686	10.00	70.00	2026-09-15 14:37:02	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.35887
481	5BB80-2DC742-260915143827	03000130	460A5BBB	HT2026072002692	10.00	70.00	2026-09-15 14:38:27	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.35887
482	5BB80-2DC74A-260915143854	03000138	96D342BB	HT2026072002657	10.00	70.00	2026-09-15 14:38:54	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.35887
483	5BB80-2DC729-260915143927	03000105	56143ABB	HT2026072002820	10.00	70.00	2026-09-15 14:39:27	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358871
484	5BB80-2DC73A-260915143944	03000122	764B5EBB	HT2026072002192	10.00	70.00	2026-09-15 14:39:44	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358871
485	5BB80-2DC6FC-260915144015	03000060	B62543BB	HT2026072002679	10.00	70.00	2026-09-15 14:40:15	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358871
486	5BB80-2DC6FB-260915144030	03000059	E64151BB	HT2026072002483	10.00	70.00	2026-09-15 14:40:30	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358872
487	5BB80-2DC6FA-260915144053	03000058	562C4BBB	HT2026072002650	10.00	70.00	2026-09-15 14:40:53	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358872
488	5BB80-2DC6F9-260915144113	03000057	36FC1BBB	HT2026072002704	10.00	70.00	2026-09-15 14:41:13	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358873
489	5BB80-2DC6F8-260915144130	03000056	A62047BB	HT2026072002695	10.00	70.00	2026-09-15 14:41:30	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358873
490	5BB80-2DC6F7-260915144145	03000055	863238BB	HT2026072003004	10.00	70.00	2026-09-15 14:41:45	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358873
491	5BB80-2DC6F6-260915144202	03000054	B69056BB	HT2026072003003	10.00	70.00	2026-09-15 14:42:02	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358874
492	5BB80-2DC6F5-260915144219	03000053	E6DD4ABB	HT2026072002199	10.00	70.00	2026-09-15 14:42:19	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358874
493	5BB80-2DC6F4-260915144233	03000052	76271BBB	HT2026072002497	10.00	70.00	2026-09-15 14:42:33	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358874
494	5BB80-2DC6F3-260915144248	03000051	56A931BB	HT2026072002703	10.00	70.00	2026-09-15 14:42:48	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358875
495	5BB80-2DC6E6-260915144305	03000038	86F254BB	HT2026072002167	10.00	70.00	2026-09-15 14:43:05	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358875
496	5BB80-2DC6E8-260915144351	03000040	46444FBB	HT2026072002163	10.00	70.00	2026-09-15 14:43:51	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358875
497	5BB80-2DC6E9-260915144416	03000041	56BF3ABB	HT2026072002147	10.00	70.00	2026-09-15 14:44:16	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358876
498	5BB80-2DC6EA-260915144430	03000042	F69F59BB	HT2026072002180	10.00	70.00	2026-09-15 14:44:30	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358876
499	5BB80-2DC6EB-260915144446	03000043	26BE4DBB	HT2026072002146	10.00	70.00	2026-09-15 14:44:46	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358876
500	5BB80-2DC6EC-260915144500	03000044	763931BB	HT2026072002652	10.00	70.00	2026-09-15 14:45:00	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358877
501	5BB80-2DC6ED-260915144521	03000045	B6C01ABB	HT2026072002187	10.00	70.00	2026-09-15 14:45:21	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358877
502	5BB80-2DC6EE-260915144551	03000046	561D3DBB	HT2026072002183	10.00	70.00	2026-09-15 14:45:51	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358877
503	5BB80-2DC6EF-260915144606	03000047	66A91EBB	HT2026072002688	10.00	70.00	2026-09-15 14:46:06	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358878
504	5BB80-2DC6E7-260915144641	03000039	A6B65BBB	HT2026072002643	10.00	70.00	2026-09-15 14:46:41	RECHARGE	0310742010375680	MANAULANAN_SOLAR	2026-09-15 06:47:55.358878
505	5C0E6-2DC726-260915142401	03000102	36DC52BB	HT2026072001465	10.00	70.00	2026-09-15 14:24:01	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736281
506	5C0E6-2DC725-260915142533	03000101	265145BB	HT2026072001486	10.00	70.00	2026-09-15 14:25:33	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736283
507	5C0E6-2DC715-260915142628	03000085	96EA26BB	HT2026072001501	10.00	70.00	2026-09-15 14:26:28	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736283
508	5C0E6-2DC71D-260915142655	03000093	262B35BB	HT2026072001430	10.00	70.00	2026-09-15 14:26:55	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736284
509	5C0E6-2DC716-260915142723	03000086	964151BB	HT2026072001472	10.00	70.00	2026-09-15 14:27:23	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736284
510	5C0E6-2DC732-260915142751	03000114	06942ABB	HT2026072002749	10.00	70.00	2026-09-15 14:27:51	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736284
511	5C0E6-2DC734-260915142807	03000116	96C343BB	HT2026072002755	10.00	70.00	2026-09-15 14:28:07	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736285
512	5C0E6-2DC722-260915142823	03000098	067733BB	HT2026072001482	10.00	70.00	2026-09-15 14:28:23	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736285
513	5C0E6-2DC71B-260915142844	03000091	362E58BB	HT2026072001463	10.00	70.00	2026-09-15 14:28:44	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736286
514	5C0E6-2DC738-260915142915	03000120	960E4BBB	HT2026072002720	10.00	70.00	2026-09-15 14:29:15	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736286
515	5C0E6-2DC736-260915142935	03000118	56B937BB	HT2026072002767	10.00	70.00	2026-09-15 14:29:35	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736286
516	5C0E6-2DC739-260915142953	03000121	26203ABB	HT2026072002231	10.00	70.00	2026-09-15 14:29:53	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736287
517	5C0E6-2DC724-260915143015	03000100	46B81EBB	HT2026072001473	10.00	70.00	2026-09-15 14:30:15	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736287
518	5C0E6-2DC723-260915143058	03000099	566E2BBB	HT2026072001418	10.00	70.00	2026-09-15 14:30:58	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736287
519	5C0E6-2DC74D-260915143119	03000141	B65B2BBB	HT2026072002669	10.00	70.00	2026-09-15 14:31:19	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736288
520	5C0E6-2DC751-260915143139	03000145	F69327BB	HT2026072002681	10.00	70.00	2026-09-15 14:31:39	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736288
521	5C0E6-2DC750-260915143158	03000144	967F4BBB	HT2026072002184	10.00	70.00	2026-09-15 14:31:58	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736288
522	5C0E6-2DC75C-260915143235	03000156	565129BB	HT2026072002494	10.00	70.00	2026-09-15 14:32:35	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736289
523	5C0E6-2DC753-260915143301	03000147	F61B55BB	HT2026072002682	10.00	70.00	2026-09-15 14:33:01	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736289
524	5C0E6-2DC74E-260915143335	03000142	86CC54BB	HT2026072002660	10.00	70.00	2026-09-15 14:33:35	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.73629
525	5C0E6-2DC74F-260915143353	03000143	C65B4DBB	HT2026072002108	10.00	70.00	2026-09-15 14:33:53	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.73629
526	5C0E6-2DC756-260915143408	03000150	06ED30BB	HT2026072002488	10.00	70.00	2026-09-15 14:34:08	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.73629
527	5C0E6-2DC75B-260915143449	03000155	06D046BB	HT2026072002493	10.00	70.00	2026-09-15 14:34:49	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736291
528	5C0E6-2DC758-260915143510	03000152	663438BB	HT2026072002482	10.00	70.00	2026-09-15 14:35:10	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736291
529	5C0E6-2DC757-260915143527	03000151	F6542BBB	HT2026072001056	10.00	70.00	2026-09-15 14:35:27	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736292
530	5C0E6-2DC754-260915143542	03000148	368946BB	HT2026072002665	10.00	70.00	2026-09-15 14:35:42	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736292
531	5C0E6-2DC755-260915143558	03000149	560853BB	HT2026072002185	10.00	70.00	2026-09-15 14:35:58	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736292
532	5C0E6-2DC752-260915143612	03000146	A6944DBB	HT2026072002492	10.00	70.00	2026-09-15 14:36:12	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736293
533	5C0E6-2DC748-260915143648	03000136	B65E3CBB	HT2026072002677	10.00	70.00	2026-09-15 14:36:48	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736293
534	5C0E6-2DC75D-260915143700	03000157	868D3BBB	HT2026072001489	10.00	70.00	2026-09-15 14:37:00	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736293
535	5C0E6-2DC710-260915143712	03000080	D6DF41BB	HT2026072001470	10.00	70.00	2026-09-15 14:37:12	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736294
536	5C0E6-2DC749-260915143726	03000137	F6AF5DBB	HT2026072002667	10.00	70.00	2026-09-15 14:37:26	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736294
537	5C0E6-2DC73D-260915143812	03000125	662449BB	HT2026072002706	10.00	70.00	2026-09-15 14:38:12	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736295
538	5C0E6-2DC73F-260915143829	03000127	764E2DBB	HT2026072002699	10.00	70.00	2026-09-15 14:38:29	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736295
539	5C0E6-2DC744-260915143849	03000132	962D2FBB	HT2026072002174	10.00	70.00	2026-09-15 14:38:49	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736295
540	5C0E6-2DC743-260915143905	03000131	D6114FBB	HT2026072002687	10.00	70.00	2026-09-15 14:39:05	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736296
541	5C0E6-2DC6D0-260915143935	03000016	86C133BB	HT2026072002617	10.00	70.00	2026-09-15 14:39:35	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736296
542	5C0E6-2DC6D1-260915143951	03000017	966E56BB	HT2026072002602	10.00	70.00	2026-09-15 14:39:51	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736296
543	5C0E6-2DC6D2-260915144006	03000018	660953BB	HT2026072001595	10.00	70.00	2026-09-15 14:40:06	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736297
544	5C0E6-2DC6D3-260915144019	03000019	36E644BB	HT2026072002608	10.00	70.00	2026-09-15 14:40:19	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736297
545	5C0E6-2DC6D4-260915144033	03000020	363D51BB	HT2026072002603	10.00	70.00	2026-09-15 14:40:33	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736297
546	5C0E6-2DC6D5-260915144047	03000021	B69F28BB	HT2026072001607	10.00	70.00	2026-09-15 14:40:47	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736298
547	5C0E6-2DC6D6-260915144101	03000022	662D25BB	HT2026072002627	10.00	70.00	2026-09-15 14:41:01	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736298
548	5C0E6-2DC6D7-260915144118	03000023	56A935BB	HT2026072001602	10.00	70.00	2026-09-15 14:41:18	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736298
549	5C0E6-2DC6D8-260915144133	03000024	D6ED56BB	HT2026072001603	10.00	70.00	2026-09-15 14:41:33	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736299
550	5C0E6-2DC6D9-260915144147	03000025	264A2EBB	HT2026072001598	10.00	70.00	2026-09-15 14:41:47	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736299
551	5C0E6-2DC6DA-260915144202	03000026	562F3ABB	HT2026072002594	10.00	70.00	2026-09-15 14:42:02	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.7363
552	5C0E6-2DC6DB-260915144215	03000027	B6DA55BB	HT2026072002170	10.00	70.00	2026-09-15 14:42:15	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.7363
553	5C0E6-2DC6DC-260915144229	03000028	664623BB	HT2026072002622	10.00	70.00	2026-09-15 14:42:29	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.7363
554	5C0E6-2DC6DD-260915144322	03000029	C62043BB	HT2026072002644	10.00	70.00	2026-09-15 14:43:22	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736301
555	5C0E6-2DC6DE-260915144409	03000030	063D44BB	HT2026072002150	10.00	70.00	2026-09-15 14:44:09	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736301
556	5C0E6-2DC6DF-260915144500	03000031	76364DBB	HT2026072002173	10.00	70.00	2026-09-15 14:45:00	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736301
557	5C0E6-2DC6E0-260915144539	03000032	169E4BBB	HT2026072002653	10.00	70.00	2026-09-15 14:45:39	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736302
558	5C0E6-2DC6E1-260915144556	03000033	463633BB	HT2026072002634	10.00	70.00	2026-09-15 14:45:56	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736302
559	5C0E6-2DC6E2-260915144616	03000034	264759BB	HT2026072002654	10.00	70.00	2026-09-15 14:46:16	RECHARGE	0310742010377062	MANAULANAN_SOLAR	2026-09-15 06:48:05.736303
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: solar_admin
--

COPY public.users (id, username, password_hash, role, is_active, is_deleted, first_name, middle_name, last_name, mobile, landline, email, ice_name, ice_phone, province, region_id, address, created_at) FROM stdin;
1	superadmin	$2b$12$LkwkaGCb6aZX7yf9jiqiVeDxLdugmLUz2WICDXX8C9/OBexXhnDaG	0	t	f	Supplier	\N	Support	1111111111	\N	\N	\N	\N	Pangasinan	1	\N	2026-08-28 05:37:43.000814
2	admin	$2b$12$7VkxgyS8NbAb3/ONtzAjEejMrms.XzGJHvXY1VEWBDRLYP2f6/LB6	1	t	f	System	\N	Admin	09123456789	\N	\N	\N	\N	Pangasinan	1	\N	2026-08-28 05:37:43.000817
3	MANAULANAN_SOLAR	$2b$12$./zKE0zn5UC8cWCz.1ZLPOlAAtcjcfuUZaRALySm3K6ObczpWYOvu	2	t	f	JOHN PAUL	\N	OTOD	09162423286	\N	johnpaulotod04@gmail.com	\N	\N	Pangasinan	3	Default HQ	2026-08-28 06:29:14.083089
4	BRGY_TINULTULAN	$2b$12$n79A35u1YyfcnhRlZn5nPu57ePIPjM1Ans.bMzAjPRaQhLZqZtpe2	2	t	f	JOHN PAUL	\N	OTOD	12345	\N	AAA@aaa.com	\N	\N	Pangasinan	5	Default HQ	2026-08-28 12:44:28.915305
5	BRGY_MALAPANG	$2b$12$Yd3sOZaCoBpCxm/fCtAKpOqFniopqBOIiASh6aufPNsXyKgqT5PYq	2	t	f	JOHN PAUL	\N	OTOD	11111	\N	BBB@bbb.com	\N	\N	Pangasinan	7	Default HQ	2026-08-28 13:14:29.520774
6	BRGY_BALATICAN	$2b$12$jFDzRrn/XgGTmbEYSP81O.CVYEKQk03gRkqZKa1zg3VoK2IS.0bvS	2	t	f	JOHN PAUL	\N	OTOD	33333	\N	CCC@ccc.com	\N	\N	Pangasinan	9	Default HQ	2026-08-31 01:21:27.977158
7	BRGY_LUANAN	$2b$12$zheuS7tIvlrBdfFMGMKVOu/SSzCvimR69bDat0ZSbJ2DmadLxLTqS	2	t	f	JOHN PAUL	\N	OTOD	44444	\N	DDD@ddd.com	\N	\N	Pangasinan	11	Default HQ	2026-08-31 01:42:04.410241
8	RED_TESTING	$2b$12$tx3UD2yIQcNQW/76uXeZf.CLPIfAnBtD2.eE.iDuEsvPAyR0ybegm	2	t	f	JOHN PAUL	\N	OTOD	77777	\N	OOO@ooo.com	\N	\N	Pangasinan	23	Default HQ	2026-09-03 07:26:37.285362
\.


--
-- Name: business_entities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: solar_admin
--

SELECT pg_catalog.setval('public.business_entities_id_seq', 1, false);


--
-- Name: cards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: solar_admin
--

SELECT pg_catalog.setval('public.cards_id_seq', 505, true);


--
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: solar_admin
--

SELECT pg_catalog.setval('public.customers_id_seq', 999, true);


--
-- Name: pos_action_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: solar_admin
--

SELECT pg_catalog.setval('public.pos_action_logs_id_seq', 28, true);


--
-- Name: pos_machines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: solar_admin
--

SELECT pg_catalog.setval('public.pos_machines_id_seq', 6, true);


--
-- Name: pos_staging_customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: solar_admin
--

SELECT pg_catalog.setval('public.pos_staging_customers_id_seq', 1, false);


--
-- Name: pos_staging_transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: solar_admin
--

SELECT pg_catalog.setval('public.pos_staging_transactions_id_seq', 1, false);


--
-- Name: provider_configs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: solar_admin
--

SELECT pg_catalog.setval('public.provider_configs_id_seq', 1, true);


--
-- Name: regions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: solar_admin
--

SELECT pg_catalog.setval('public.regions_id_seq', 23, true);


--
-- Name: solar_units_id_seq; Type: SEQUENCE SET; Schema: public; Owner: solar_admin
--

SELECT pg_catalog.setval('public.solar_units_id_seq', 506, true);


--
-- Name: transaction_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: solar_admin
--

SELECT pg_catalog.setval('public.transaction_logs_id_seq', 559, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: solar_admin
--

SELECT pg_catalog.setval('public.users_id_seq', 8, true);


--
-- Name: business_entities business_entities_name_key; Type: CONSTRAINT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.business_entities
    ADD CONSTRAINT business_entities_name_key UNIQUE (name);


--
-- Name: business_entities business_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.business_entities
    ADD CONSTRAINT business_entities_pkey PRIMARY KEY (id);


--
-- Name: business_entities business_entities_region_id_key; Type: CONSTRAINT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.business_entities
    ADD CONSTRAINT business_entities_region_id_key UNIQUE (region_id);


--
-- Name: cards cards_pkey; Type: CONSTRAINT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: pos_action_logs pos_action_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.pos_action_logs
    ADD CONSTRAINT pos_action_logs_pkey PRIMARY KEY (id);


--
-- Name: pos_machines pos_machines_pkey; Type: CONSTRAINT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.pos_machines
    ADD CONSTRAINT pos_machines_pkey PRIMARY KEY (id);


--
-- Name: pos_staging_customers pos_staging_customers_pkey; Type: CONSTRAINT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.pos_staging_customers
    ADD CONSTRAINT pos_staging_customers_pkey PRIMARY KEY (id);


--
-- Name: pos_staging_transactions pos_staging_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.pos_staging_transactions
    ADD CONSTRAINT pos_staging_transactions_pkey PRIMARY KEY (id);


--
-- Name: provider_configs provider_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.provider_configs
    ADD CONSTRAINT provider_configs_pkey PRIMARY KEY (id);


--
-- Name: regions regions_pkey; Type: CONSTRAINT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_pkey PRIMARY KEY (id);


--
-- Name: solar_units solar_units_pkey; Type: CONSTRAINT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.solar_units
    ADD CONSTRAINT solar_units_pkey PRIMARY KEY (id);


--
-- Name: transaction_logs transaction_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.transaction_logs
    ADD CONSTRAINT transaction_logs_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: ix_business_entities_id; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_business_entities_id ON public.business_entities USING btree (id);


--
-- Name: ix_business_entities_is_deleted; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_business_entities_is_deleted ON public.business_entities USING btree (is_deleted);


--
-- Name: ix_cards_card_number; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE UNIQUE INDEX ix_cards_card_number ON public.cards USING btree (card_number);


--
-- Name: ix_cards_card_uuid; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE UNIQUE INDEX ix_cards_card_uuid ON public.cards USING btree (card_uuid);


--
-- Name: ix_cards_customer_uuid; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_cards_customer_uuid ON public.cards USING btree (customer_uuid);


--
-- Name: ix_cards_id; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_cards_id ON public.cards USING btree (id);


--
-- Name: ix_cards_status; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_cards_status ON public.cards USING btree (status);


--
-- Name: ix_customers_expiry_time; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_customers_expiry_time ON public.customers USING btree (expiry_time);


--
-- Name: ix_customers_id; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_customers_id ON public.customers USING btree (id);


--
-- Name: ix_customers_mobile; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_customers_mobile ON public.customers USING btree (mobile);


--
-- Name: ix_customers_offline_origin_uuid; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_customers_offline_origin_uuid ON public.customers USING btree (offline_origin_uuid);


--
-- Name: ix_customers_region_id; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_customers_region_id ON public.customers USING btree (region_id);


--
-- Name: ix_customers_uuid; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE UNIQUE INDEX ix_customers_uuid ON public.customers USING btree (uuid);


--
-- Name: ix_pos_action_logs_id; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_pos_action_logs_id ON public.pos_action_logs USING btree (id);


--
-- Name: ix_pos_action_logs_pos_sn; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_pos_action_logs_pos_sn ON public.pos_action_logs USING btree (pos_sn);


--
-- Name: ix_pos_machines_id; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_pos_machines_id ON public.pos_machines USING btree (id);


--
-- Name: ix_pos_machines_pos_code; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE UNIQUE INDEX ix_pos_machines_pos_code ON public.pos_machines USING btree (pos_code);


--
-- Name: ix_pos_machines_pos_sn; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE UNIQUE INDEX ix_pos_machines_pos_sn ON public.pos_machines USING btree (pos_sn);


--
-- Name: ix_pos_staging_customers_customer_uuid; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE UNIQUE INDEX ix_pos_staging_customers_customer_uuid ON public.pos_staging_customers USING btree (customer_uuid);


--
-- Name: ix_pos_staging_customers_id; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_pos_staging_customers_id ON public.pos_staging_customers USING btree (id);


--
-- Name: ix_pos_staging_customers_mobile; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_pos_staging_customers_mobile ON public.pos_staging_customers USING btree (mobile);


--
-- Name: ix_pos_staging_customers_operator_username; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_pos_staging_customers_operator_username ON public.pos_staging_customers USING btree (operator_username);


--
-- Name: ix_pos_staging_customers_pos_sn; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_pos_staging_customers_pos_sn ON public.pos_staging_customers USING btree (pos_sn);


--
-- Name: ix_pos_staging_customers_region_id; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_pos_staging_customers_region_id ON public.pos_staging_customers USING btree (region_id);


--
-- Name: ix_pos_staging_transactions_card_uuid; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_pos_staging_transactions_card_uuid ON public.pos_staging_transactions USING btree (card_uuid);


--
-- Name: ix_pos_staging_transactions_customer_uuid; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_pos_staging_transactions_customer_uuid ON public.pos_staging_transactions USING btree (customer_uuid);


--
-- Name: ix_pos_staging_transactions_id; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_pos_staging_transactions_id ON public.pos_staging_transactions USING btree (id);


--
-- Name: ix_pos_staging_transactions_operator_username; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_pos_staging_transactions_operator_username ON public.pos_staging_transactions USING btree (operator_username);


--
-- Name: ix_pos_staging_transactions_pos_sn; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_pos_staging_transactions_pos_sn ON public.pos_staging_transactions USING btree (pos_sn);


--
-- Name: ix_pos_staging_transactions_transaction_id; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE UNIQUE INDEX ix_pos_staging_transactions_transaction_id ON public.pos_staging_transactions USING btree (transaction_id);


--
-- Name: ix_provider_configs_id; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_provider_configs_id ON public.provider_configs USING btree (id);


--
-- Name: ix_provider_configs_name; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_provider_configs_name ON public.provider_configs USING btree (name);


--
-- Name: ix_provider_configs_tin; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE UNIQUE INDEX ix_provider_configs_tin ON public.provider_configs USING btree (tin);


--
-- Name: ix_regions_id; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_regions_id ON public.regions USING btree (id);


--
-- Name: ix_solar_units_city; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_solar_units_city ON public.solar_units USING btree (city);


--
-- Name: ix_solar_units_customer_uuid; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_solar_units_customer_uuid ON public.solar_units USING btree (customer_uuid);


--
-- Name: ix_solar_units_equipment_status; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_solar_units_equipment_status ON public.solar_units USING btree (equipment_status);


--
-- Name: ix_solar_units_flashlight_id; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE UNIQUE INDEX ix_solar_units_flashlight_id ON public.solar_units USING btree (flashlight_id);


--
-- Name: ix_solar_units_flashlight_status; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_solar_units_flashlight_status ON public.solar_units USING btree (flashlight_status);


--
-- Name: ix_solar_units_id; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_solar_units_id ON public.solar_units USING btree (id);


--
-- Name: ix_solar_units_led_light_id; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE UNIQUE INDEX ix_solar_units_led_light_id ON public.solar_units USING btree (led_light_id);


--
-- Name: ix_solar_units_led_status; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_solar_units_led_status ON public.solar_units USING btree (led_status);


--
-- Name: ix_solar_units_radio_id; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE UNIQUE INDEX ix_solar_units_radio_id ON public.solar_units USING btree (radio_id);


--
-- Name: ix_solar_units_radio_status; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_solar_units_radio_status ON public.solar_units USING btree (radio_status);


--
-- Name: ix_solar_units_shs_machine_id; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE UNIQUE INDEX ix_solar_units_shs_machine_id ON public.solar_units USING btree (shs_machine_id);


--
-- Name: ix_solar_units_shs_status; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_solar_units_shs_status ON public.solar_units USING btree (shs_status);


--
-- Name: ix_solar_units_solar_equipment_id; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE UNIQUE INDEX ix_solar_units_solar_equipment_id ON public.solar_units USING btree (solar_equipment_id);


--
-- Name: ix_solar_units_town; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_solar_units_town ON public.solar_units USING btree (town);


--
-- Name: ix_transaction_logs_card_uuid; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_transaction_logs_card_uuid ON public.transaction_logs USING btree (card_uuid);


--
-- Name: ix_transaction_logs_customer_uuid; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_transaction_logs_customer_uuid ON public.transaction_logs USING btree (customer_uuid);


--
-- Name: ix_transaction_logs_id; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_transaction_logs_id ON public.transaction_logs USING btree (id);


--
-- Name: ix_transaction_logs_operator_username; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_transaction_logs_operator_username ON public.transaction_logs USING btree (operator_username);


--
-- Name: ix_transaction_logs_pos_sn; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_transaction_logs_pos_sn ON public.transaction_logs USING btree (pos_sn);


--
-- Name: ix_transaction_logs_transaction_id; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE UNIQUE INDEX ix_transaction_logs_transaction_id ON public.transaction_logs USING btree (transaction_id);


--
-- Name: ix_users_id; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_users_id ON public.users USING btree (id);


--
-- Name: ix_users_is_deleted; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_users_is_deleted ON public.users USING btree (is_deleted);


--
-- Name: ix_users_region_id; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE INDEX ix_users_region_id ON public.users USING btree (region_id);


--
-- Name: ix_users_username; Type: INDEX; Schema: public; Owner: solar_admin
--

CREATE UNIQUE INDEX ix_users_username ON public.users USING btree (username);


--
-- Name: business_entities business_entities_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.business_entities
    ADD CONSTRAINT business_entities_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.regions(id);


--
-- Name: customers customers_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.regions(id);


--
-- Name: pos_machines pos_machines_assigned_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.pos_machines
    ADD CONSTRAINT pos_machines_assigned_user_id_fkey FOREIGN KEY (assigned_user_id) REFERENCES public.users(id);


--
-- Name: pos_staging_customers pos_staging_customers_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.pos_staging_customers
    ADD CONSTRAINT pos_staging_customers_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.regions(id);


--
-- Name: regions regions_last_rate_modified_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_last_rate_modified_by_id_fkey FOREIGN KEY (last_rate_modified_by_id) REFERENCES public.users(id);


--
-- Name: regions regions_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: solar_admin
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.regions(id);


--
-- PostgreSQL database dump complete
--

\unrestrict iaArNs1j6iKbvxh6376KcA4lNvHJ4Kub0cOnLezDrccGeuG3hyJtgYA88L2ZOeO

