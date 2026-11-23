--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

-- Started on 2026-11-23 13:45:07

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 16397)
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- TOC entry 5253 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- TOC entry 1066 (class 1247 OID 17270)
-- Name: assignment_role_t; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.assignment_role_t AS ENUM (
    'assignee',
    'lead_assignee',
    'reviewer'
);


ALTER TYPE public.assignment_role_t OWNER TO postgres;

--
-- TOC entry 1063 (class 1247 OID 17258)
-- Name: member_role_t; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.member_role_t AS ENUM (
    'lead',
    'dev',
    'qa',
    'analyst',
    'pm'
);


ALTER TYPE public.member_role_t OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 219 (class 1259 OID 17278)
-- Name: department; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.department (
    department_id integer NOT NULL,
    department_code text NOT NULL,
    department_name text NOT NULL,
    CONSTRAINT department_department_code_check CHECK ((department_code ~ '^[A-Z]{2,8}$'::text)),
    CONSTRAINT department_department_name_check CHECK ((length(TRIM(BOTH FROM department_name)) > 0))
);


ALTER TABLE public.department OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 17277)
-- Name: department_department_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.department_department_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.department_department_id_seq OWNER TO postgres;

--
-- TOC entry 5254 (class 0 OID 0)
-- Dependencies: 218
-- Name: department_department_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.department_department_id_seq OWNED BY public.department.department_id;


--
-- TOC entry 221 (class 1259 OID 17291)
-- Name: employee; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee (
    employee_id integer NOT NULL,
    email text NOT NULL,
    full_name text NOT NULL,
    current_department_id integer NOT NULL,
    hired_at date DEFAULT CURRENT_DATE NOT NULL,
    CONSTRAINT employee_email_check CHECK ((email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'::text)),
    CONSTRAINT employee_full_name_check CHECK ((length(TRIM(BOTH FROM full_name)) > 0))
);


ALTER TABLE public.employee OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 17308)
-- Name: employee_department_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee_department_history (
    employee_id integer NOT NULL,
    department_id integer NOT NULL,
    valid_from date NOT NULL,
    valid_to date,
    CONSTRAINT employee_department_history_check CHECK (((valid_to IS NULL) OR (valid_to > valid_from)))
);


ALTER TABLE public.employee_department_history OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 17290)
-- Name: employee_employee_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employee_employee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employee_employee_id_seq OWNER TO postgres;

--
-- TOC entry 5255 (class 0 OID 0)
-- Dependencies: 220
-- Name: employee_employee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employee_employee_id_seq OWNED BY public.employee.employee_id;


--
-- TOC entry 224 (class 1259 OID 17327)
-- Name: project; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project (
    project_id integer NOT NULL,
    project_code text NOT NULL,
    project_name text NOT NULL,
    manager_employee_id integer NOT NULL,
    started_at date DEFAULT CURRENT_DATE NOT NULL,
    CONSTRAINT project_project_code_check CHECK ((project_code ~ '^P-[0-9]{2}$'::text)),
    CONSTRAINT project_project_name_check CHECK ((length(TRIM(BOTH FROM project_name)) > 0))
);


ALTER TABLE public.project OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 17345)
-- Name: project_member; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project_member (
    project_id integer NOT NULL,
    employee_id integer NOT NULL,
    member_role public.member_role_t NOT NULL,
    joined_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.project_member OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 17326)
-- Name: project_project_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.project_project_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.project_project_id_seq OWNER TO postgres;

--
-- TOC entry 5256 (class 0 OID 0)
-- Dependencies: 223
-- Name: project_project_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.project_project_id_seq OWNED BY public.project.project_id;


--
-- TOC entry 229 (class 1259 OID 17374)
-- Name: task; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task (
    task_id integer NOT NULL,
    project_id integer NOT NULL,
    task_code text NOT NULL,
    title text NOT NULL,
    current_status_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT task_task_code_check CHECK ((task_code ~ '^T-[0-9]{4}$'::text)),
    CONSTRAINT task_title_check CHECK ((length(TRIM(BOTH FROM title)) > 0))
);


ALTER TABLE public.task OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 17397)
-- Name: task_assignment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_assignment (
    task_id integer NOT NULL,
    employee_id integer NOT NULL,
    assignment_role public.assignment_role_t DEFAULT 'assignee'::public.assignment_role_t NOT NULL,
    assigned_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.task_assignment OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 17362)
-- Name: task_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_status (
    status_id integer NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    CONSTRAINT task_status_code_check CHECK ((code = ANY (ARRAY['NEW'::text, 'IN_PROGRESS'::text, 'REVIEW'::text, 'BLOCKED'::text, 'DONE'::text, 'CLOSED'::text, 'WAITING'::text])))
);


ALTER TABLE public.task_status OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 17438)
-- Name: task_status_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_status_history (
    history_id bigint NOT NULL,
    task_id integer NOT NULL,
    changed_at timestamp with time zone DEFAULT now() NOT NULL,
    author_employee_id integer NOT NULL,
    old_status_id integer,
    new_status_id integer NOT NULL,
    CONSTRAINT task_status_history_check CHECK ((old_status_id IS DISTINCT FROM new_status_id))
);


ALTER TABLE public.task_status_history OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 17437)
-- Name: task_status_history_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.task_status_history_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_status_history_history_id_seq OWNER TO postgres;

--
-- TOC entry 5257 (class 0 OID 0)
-- Dependencies: 233
-- Name: task_status_history_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.task_status_history_history_id_seq OWNED BY public.task_status_history.history_id;


--
-- TOC entry 226 (class 1259 OID 17361)
-- Name: task_status_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.task_status_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_status_status_id_seq OWNER TO postgres;

--
-- TOC entry 5258 (class 0 OID 0)
-- Dependencies: 226
-- Name: task_status_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.task_status_status_id_seq OWNED BY public.task_status.status_id;


--
-- TOC entry 228 (class 1259 OID 17373)
-- Name: task_task_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.task_task_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_task_id_seq OWNER TO postgres;

--
-- TOC entry 5259 (class 0 OID 0)
-- Dependencies: 228
-- Name: task_task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.task_task_id_seq OWNED BY public.task.task_id;


--
-- TOC entry 232 (class 1259 OID 17415)
-- Name: time_entry; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.time_entry (
    time_entry_id bigint NOT NULL,
    task_id integer NOT NULL,
    employee_id integer NOT NULL,
    work_date date NOT NULL,
    hours numeric(6,2) NOT NULL,
    comment text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT time_entry_hours_check CHECK (((hours > (0)::numeric) AND (hours <= (24)::numeric)))
);


ALTER TABLE public.time_entry OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 17414)
-- Name: time_entry_time_entry_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.time_entry_time_entry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.time_entry_time_entry_id_seq OWNER TO postgres;

--
-- TOC entry 5260 (class 0 OID 0)
-- Dependencies: 231
-- Name: time_entry_time_entry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.time_entry_time_entry_id_seq OWNED BY public.time_entry.time_entry_id;


--
-- TOC entry 5008 (class 2604 OID 17281)
-- Name: department department_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department ALTER COLUMN department_id SET DEFAULT nextval('public.department_department_id_seq'::regclass);


--
-- TOC entry 5009 (class 2604 OID 17294)
-- Name: employee employee_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee ALTER COLUMN employee_id SET DEFAULT nextval('public.employee_employee_id_seq'::regclass);


--
-- TOC entry 5011 (class 2604 OID 17330)
-- Name: project project_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project ALTER COLUMN project_id SET DEFAULT nextval('public.project_project_id_seq'::regclass);


--
-- TOC entry 5015 (class 2604 OID 17377)
-- Name: task task_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task ALTER COLUMN task_id SET DEFAULT nextval('public.task_task_id_seq'::regclass);


--
-- TOC entry 5014 (class 2604 OID 17365)
-- Name: task_status status_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_status ALTER COLUMN status_id SET DEFAULT nextval('public.task_status_status_id_seq'::regclass);


--
-- TOC entry 5021 (class 2604 OID 17441)
-- Name: task_status_history history_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_status_history ALTER COLUMN history_id SET DEFAULT nextval('public.task_status_history_history_id_seq'::regclass);


--
-- TOC entry 5019 (class 2604 OID 17418)
-- Name: time_entry time_entry_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_entry ALTER COLUMN time_entry_id SET DEFAULT nextval('public.time_entry_time_entry_id_seq'::regclass);


--
-- TOC entry 5232 (class 0 OID 17278)
-- Dependencies: 219
-- Data for Name: department; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.department (department_id, department_code, department_name) FROM stdin;
1	DEV	Разработка
2	QA	Тестирование
3	BI	Аналитика
4	SEC	Информационная безопасность
5	OPS	Эксплуатация
\.


--
-- TOC entry 5234 (class 0 OID 17291)
-- Dependencies: 221
-- Data for Name: employee; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employee (employee_id, email, full_name, current_department_id, hired_at) FROM stdin;
1	user01@corp.ru	Сотрудник 1	1	2026-11-23
2	user02@corp.ru	Сотрудник 2	2	2026-11-23
3	user03@corp.ru	Сотрудник 3	3	2026-11-23
4	user04@corp.ru	Сотрудник 4	4	2026-11-23
5	user05@corp.ru	Сотрудник 5	5	2026-11-23
6	user06@corp.ru	Сотрудник 6	1	2026-11-23
7	user07@corp.ru	Сотрудник 7	2	2026-11-23
8	user08@corp.ru	Сотрудник 8	3	2026-11-23
9	user09@corp.ru	Сотрудник 9	4	2026-11-23
10	user10@corp.ru	Сотрудник 10	5	2026-11-23
11	user11@corp.ru	Сотрудник 11	1	2026-11-23
12	user12@corp.ru	Сотрудник 12	2	2026-11-23
13	user13@corp.ru	Сотрудник 13	3	2026-11-23
14	user14@corp.ru	Сотрудник 14	4	2026-11-23
15	user15@corp.ru	Сотрудник 15	5	2026-11-23
16	user16@corp.ru	Сотрудник 16	1	2026-11-23
17	user17@corp.ru	Сотрудник 17	2	2026-11-23
18	user18@corp.ru	Сотрудник 18	3	2026-11-23
19	user19@corp.ru	Сотрудник 19	4	2026-11-23
20	user20@corp.ru	Сотрудник 20	5	2026-11-23
21	user21@corp.ru	Сотрудник 21	1	2026-11-23
22	user22@corp.ru	Сотрудник 22	2	2026-11-23
23	user23@corp.ru	Сотрудник 23	3	2026-11-23
24	user24@corp.ru	Сотрудник 24	4	2026-11-23
25	user25@corp.ru	Сотрудник 25	5	2026-11-23
\.


--
-- TOC entry 5235 (class 0 OID 17308)
-- Dependencies: 222
-- Data for Name: employee_department_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employee_department_history (employee_id, department_id, valid_from, valid_to) FROM stdin;
1	1	2026-11-23	\N
2	2	2026-11-23	\N
3	3	2026-11-23	\N
4	4	2026-11-23	\N
5	5	2026-11-23	\N
6	1	2026-11-23	\N
7	2	2026-11-23	\N
8	3	2026-11-23	\N
9	4	2026-11-23	\N
10	5	2026-11-23	\N
11	1	2026-11-23	\N
12	2	2026-11-23	\N
13	3	2026-11-23	\N
14	4	2026-11-23	\N
15	5	2026-11-23	\N
16	1	2026-11-23	\N
17	2	2026-11-23	\N
18	3	2026-11-23	\N
19	4	2026-11-23	\N
20	5	2026-11-23	\N
21	1	2026-11-23	\N
22	2	2026-11-23	\N
23	3	2026-11-23	\N
24	4	2026-11-23	\N
25	5	2026-11-23	\N
\.


--
-- TOC entry 5237 (class 0 OID 17327)
-- Dependencies: 224
-- Data for Name: project; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project (project_id, project_code, project_name, manager_employee_id, started_at) FROM stdin;
1	P-01	Проект 1	4	2026-11-23
2	P-02	Проект 2	7	2026-11-23
3	P-03	Проект 3	10	2026-11-23
4	P-04	Проект 4	13	2026-11-23
5	P-05	Проект 5	16	2026-11-23
6	P-06	Проект 6	19	2026-11-23
7	P-07	Проект 7	22	2026-11-23
8	P-08	Проект 8	25	2026-11-23
9	P-09	Проект 9	3	2026-11-23
10	P-10	Проект 10	6	2026-11-23
\.


--
-- TOC entry 5238 (class 0 OID 17345)
-- Dependencies: 225
-- Data for Name: project_member; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_member (project_id, employee_id, member_role, joined_at) FROM stdin;
1	4	lead	2026-11-23 13:27:30.268978+03
2	7	lead	2026-11-23 13:27:30.268978+03
3	10	lead	2026-11-23 13:27:30.268978+03
4	13	lead	2026-11-23 13:27:30.268978+03
5	16	lead	2026-11-23 13:27:30.268978+03
6	19	lead	2026-11-23 13:27:30.268978+03
7	22	lead	2026-11-23 13:27:30.268978+03
8	25	lead	2026-11-23 13:27:30.268978+03
9	3	lead	2026-11-23 13:27:30.268978+03
10	6	lead	2026-11-23 13:27:30.268978+03
1	7	qa	2026-11-23 13:27:30.268978+03
2	12	qa	2026-11-23 13:27:30.268978+03
3	17	qa	2026-11-23 13:27:30.268978+03
4	22	qa	2026-11-23 13:27:30.268978+03
5	2	qa	2026-11-23 13:27:30.268978+03
6	7	qa	2026-11-23 13:27:30.268978+03
7	12	qa	2026-11-23 13:27:30.268978+03
8	17	qa	2026-11-23 13:27:30.268978+03
9	22	qa	2026-11-23 13:27:30.268978+03
10	2	qa	2026-11-23 13:27:30.268978+03
1	8	analyst	2026-11-23 13:27:30.268978+03
2	13	analyst	2026-11-23 13:27:30.268978+03
3	18	analyst	2026-11-23 13:27:30.268978+03
4	23	analyst	2026-11-23 13:27:30.268978+03
5	3	analyst	2026-11-23 13:27:30.268978+03
6	8	analyst	2026-11-23 13:27:30.268978+03
7	13	analyst	2026-11-23 13:27:30.268978+03
8	18	analyst	2026-11-23 13:27:30.268978+03
9	23	analyst	2026-11-23 13:27:30.268978+03
10	3	analyst	2026-11-23 13:27:30.268978+03
1	9	dev	2026-11-23 13:27:30.268978+03
2	14	dev	2026-11-23 13:27:30.268978+03
3	19	dev	2026-11-23 13:27:30.268978+03
4	24	dev	2026-11-23 13:27:30.268978+03
5	4	dev	2026-11-23 13:27:30.268978+03
6	9	dev	2026-11-23 13:27:30.268978+03
7	14	dev	2026-11-23 13:27:30.268978+03
8	19	dev	2026-11-23 13:27:30.268978+03
9	24	dev	2026-11-23 13:27:30.268978+03
10	4	dev	2026-11-23 13:27:30.268978+03
1	10	pm	2026-11-23 13:27:30.268978+03
2	15	pm	2026-11-23 13:27:30.268978+03
3	20	pm	2026-11-23 13:27:30.268978+03
4	25	pm	2026-11-23 13:27:30.268978+03
5	5	pm	2026-11-23 13:27:30.268978+03
6	10	pm	2026-11-23 13:27:30.268978+03
7	15	pm	2026-11-23 13:27:30.268978+03
8	20	pm	2026-11-23 13:27:30.268978+03
9	25	pm	2026-11-23 13:27:30.268978+03
10	5	pm	2026-11-23 13:27:30.268978+03
1	11	dev	2026-11-23 13:27:30.268978+03
2	16	dev	2026-11-23 13:27:30.268978+03
3	21	dev	2026-11-23 13:27:30.268978+03
4	1	dev	2026-11-23 13:27:30.268978+03
5	6	dev	2026-11-23 13:27:30.268978+03
6	11	dev	2026-11-23 13:27:30.268978+03
7	16	dev	2026-11-23 13:27:30.268978+03
8	21	dev	2026-11-23 13:27:30.268978+03
9	1	dev	2026-11-23 13:27:30.268978+03
\.


--
-- TOC entry 5242 (class 0 OID 17374)
-- Dependencies: 229
-- Data for Name: task; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task (task_id, project_id, task_code, title, current_status_id, created_at) FROM stdin;
1	1	T-0001	Задача 1	2	2026-11-23 13:27:30.268978+03
2	2	T-0007	Задача 7	2	2026-11-23 13:27:30.268978+03
3	3	T-0013	Задача 13	2	2026-11-23 13:27:30.268978+03
4	4	T-0019	Задача 19	2	2026-11-23 13:27:30.268978+03
5	5	T-0025	Задача 25	2	2026-11-23 13:27:30.268978+03
6	6	T-0031	Задача 31	2	2026-11-23 13:27:30.268978+03
7	7	T-0037	Задача 37	2	2026-11-23 13:27:30.268978+03
8	8	T-0043	Задача 43	2	2026-11-23 13:27:30.268978+03
9	9	T-0049	Задача 49	2	2026-11-23 13:27:30.268978+03
10	10	T-0055	Задача 55	2	2026-11-23 13:27:30.268978+03
11	1	T-0002	Задача 2	3	2026-11-23 13:27:30.268978+03
12	2	T-0008	Задача 8	3	2026-11-23 13:27:30.268978+03
13	3	T-0014	Задача 14	3	2026-11-23 13:27:30.268978+03
14	4	T-0020	Задача 20	3	2026-11-23 13:27:30.268978+03
15	5	T-0026	Задача 26	3	2026-11-23 13:27:30.268978+03
16	6	T-0032	Задача 32	3	2026-11-23 13:27:30.268978+03
17	7	T-0038	Задача 38	3	2026-11-23 13:27:30.268978+03
18	8	T-0044	Задача 44	3	2026-11-23 13:27:30.268978+03
19	9	T-0050	Задача 50	3	2026-11-23 13:27:30.268978+03
20	10	T-0056	Задача 56	3	2026-11-23 13:27:30.268978+03
21	1	T-0003	Задача 3	4	2026-11-23 13:27:30.268978+03
22	2	T-0009	Задача 9	4	2026-11-23 13:27:30.268978+03
23	3	T-0015	Задача 15	4	2026-11-23 13:27:30.268978+03
24	4	T-0021	Задача 21	4	2026-11-23 13:27:30.268978+03
25	5	T-0027	Задача 27	4	2026-11-23 13:27:30.268978+03
26	6	T-0033	Задача 33	4	2026-11-23 13:27:30.268978+03
27	7	T-0039	Задача 39	4	2026-11-23 13:27:30.268978+03
28	8	T-0045	Задача 45	4	2026-11-23 13:27:30.268978+03
29	9	T-0051	Задача 51	4	2026-11-23 13:27:30.268978+03
30	10	T-0057	Задача 57	4	2026-11-23 13:27:30.268978+03
31	1	T-0004	Задача 4	5	2026-11-23 13:27:30.268978+03
32	2	T-0010	Задача 10	5	2026-11-23 13:27:30.268978+03
33	3	T-0016	Задача 16	5	2026-11-23 13:27:30.268978+03
34	4	T-0022	Задача 22	5	2026-11-23 13:27:30.268978+03
35	5	T-0028	Задача 28	5	2026-11-23 13:27:30.268978+03
36	6	T-0034	Задача 34	5	2026-11-23 13:27:30.268978+03
37	7	T-0040	Задача 40	5	2026-11-23 13:27:30.268978+03
38	8	T-0046	Задача 46	5	2026-11-23 13:27:30.268978+03
39	9	T-0052	Задача 52	5	2026-11-23 13:27:30.268978+03
40	10	T-0058	Задача 58	5	2026-11-23 13:27:30.268978+03
41	1	T-0005	Задача 5	6	2026-11-23 13:27:30.268978+03
42	2	T-0011	Задача 11	6	2026-11-23 13:27:30.268978+03
43	3	T-0017	Задача 17	6	2026-11-23 13:27:30.268978+03
44	4	T-0023	Задача 23	6	2026-11-23 13:27:30.268978+03
45	5	T-0029	Задача 29	6	2026-11-23 13:27:30.268978+03
46	6	T-0035	Задача 35	6	2026-11-23 13:27:30.268978+03
47	7	T-0041	Задача 41	6	2026-11-23 13:27:30.268978+03
48	8	T-0047	Задача 47	6	2026-11-23 13:27:30.268978+03
49	9	T-0053	Задача 53	6	2026-11-23 13:27:30.268978+03
50	10	T-0059	Задача 59	6	2026-11-23 13:27:30.268978+03
51	1	T-0006	Задача 6	1	2026-11-23 13:27:30.268978+03
52	2	T-0012	Задача 12	1	2026-11-23 13:27:30.268978+03
53	3	T-0018	Задача 18	1	2026-11-23 13:27:30.268978+03
54	4	T-0024	Задача 24	1	2026-11-23 13:27:30.268978+03
55	5	T-0030	Задача 30	1	2026-11-23 13:27:30.268978+03
56	6	T-0036	Задача 36	1	2026-11-23 13:27:30.268978+03
57	7	T-0042	Задача 42	1	2026-11-23 13:27:30.268978+03
58	8	T-0048	Задача 48	1	2026-11-23 13:27:30.268978+03
59	9	T-0054	Задача 54	1	2026-11-23 13:27:30.268978+03
60	10	T-0060	Задача 60	1	2026-11-23 13:27:30.268978+03
\.


--
-- TOC entry 5243 (class 0 OID 17397)
-- Dependencies: 230
-- Data for Name: task_assignment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_assignment (task_id, employee_id, assignment_role, assigned_at) FROM stdin;
1	9	lead_assignee	2026-11-23 13:27:30.268978+03
2	16	lead_assignee	2026-11-23 13:27:30.268978+03
3	23	lead_assignee	2026-11-23 13:27:30.268978+03
4	5	lead_assignee	2026-11-23 13:27:30.268978+03
5	12	lead_assignee	2026-11-23 13:27:30.268978+03
6	19	lead_assignee	2026-11-23 13:27:30.268978+03
7	1	lead_assignee	2026-11-23 13:27:30.268978+03
8	8	lead_assignee	2026-11-23 13:27:30.268978+03
9	15	lead_assignee	2026-11-23 13:27:30.268978+03
10	22	lead_assignee	2026-11-23 13:27:30.268978+03
11	4	lead_assignee	2026-11-23 13:27:30.268978+03
12	11	lead_assignee	2026-11-23 13:27:30.268978+03
13	18	lead_assignee	2026-11-23 13:27:30.268978+03
14	25	lead_assignee	2026-11-23 13:27:30.268978+03
15	7	lead_assignee	2026-11-23 13:27:30.268978+03
16	14	lead_assignee	2026-11-23 13:27:30.268978+03
17	21	lead_assignee	2026-11-23 13:27:30.268978+03
18	3	lead_assignee	2026-11-23 13:27:30.268978+03
19	10	lead_assignee	2026-11-23 13:27:30.268978+03
20	17	lead_assignee	2026-11-23 13:27:30.268978+03
21	24	lead_assignee	2026-11-23 13:27:30.268978+03
22	6	lead_assignee	2026-11-23 13:27:30.268978+03
23	13	lead_assignee	2026-11-23 13:27:30.268978+03
24	20	lead_assignee	2026-11-23 13:27:30.268978+03
25	2	lead_assignee	2026-11-23 13:27:30.268978+03
26	9	lead_assignee	2026-11-23 13:27:30.268978+03
27	16	lead_assignee	2026-11-23 13:27:30.268978+03
28	23	lead_assignee	2026-11-23 13:27:30.268978+03
29	5	lead_assignee	2026-11-23 13:27:30.268978+03
30	12	lead_assignee	2026-11-23 13:27:30.268978+03
31	19	lead_assignee	2026-11-23 13:27:30.268978+03
32	1	lead_assignee	2026-11-23 13:27:30.268978+03
33	8	lead_assignee	2026-11-23 13:27:30.268978+03
34	15	lead_assignee	2026-11-23 13:27:30.268978+03
35	22	lead_assignee	2026-11-23 13:27:30.268978+03
36	4	lead_assignee	2026-11-23 13:27:30.268978+03
37	11	lead_assignee	2026-11-23 13:27:30.268978+03
38	18	lead_assignee	2026-11-23 13:27:30.268978+03
39	25	lead_assignee	2026-11-23 13:27:30.268978+03
40	7	lead_assignee	2026-11-23 13:27:30.268978+03
41	14	lead_assignee	2026-11-23 13:27:30.268978+03
42	21	lead_assignee	2026-11-23 13:27:30.268978+03
43	3	lead_assignee	2026-11-23 13:27:30.268978+03
44	10	lead_assignee	2026-11-23 13:27:30.268978+03
45	17	lead_assignee	2026-11-23 13:27:30.268978+03
46	24	lead_assignee	2026-11-23 13:27:30.268978+03
47	6	lead_assignee	2026-11-23 13:27:30.268978+03
48	13	lead_assignee	2026-11-23 13:27:30.268978+03
49	20	lead_assignee	2026-11-23 13:27:30.268978+03
50	2	lead_assignee	2026-11-23 13:27:30.268978+03
51	9	lead_assignee	2026-11-23 13:27:30.268978+03
52	16	lead_assignee	2026-11-23 13:27:30.268978+03
53	23	lead_assignee	2026-11-23 13:27:30.268978+03
54	5	lead_assignee	2026-11-23 13:27:30.268978+03
55	12	lead_assignee	2026-11-23 13:27:30.268978+03
56	19	lead_assignee	2026-11-23 13:27:30.268978+03
57	1	lead_assignee	2026-11-23 13:27:30.268978+03
58	8	lead_assignee	2026-11-23 13:27:30.268978+03
59	15	lead_assignee	2026-11-23 13:27:30.268978+03
60	22	lead_assignee	2026-11-23 13:27:30.268978+03
1	10	reviewer	2026-11-23 13:27:30.268978+03
2	17	reviewer	2026-11-23 13:27:30.268978+03
3	24	reviewer	2026-11-23 13:27:30.268978+03
4	6	reviewer	2026-11-23 13:27:30.268978+03
5	13	reviewer	2026-11-23 13:27:30.268978+03
6	20	reviewer	2026-11-23 13:27:30.268978+03
7	2	reviewer	2026-11-23 13:27:30.268978+03
8	9	reviewer	2026-11-23 13:27:30.268978+03
9	16	reviewer	2026-11-23 13:27:30.268978+03
10	23	reviewer	2026-11-23 13:27:30.268978+03
11	5	reviewer	2026-11-23 13:27:30.268978+03
12	12	reviewer	2026-11-23 13:27:30.268978+03
13	19	reviewer	2026-11-23 13:27:30.268978+03
14	1	reviewer	2026-11-23 13:27:30.268978+03
15	8	reviewer	2026-11-23 13:27:30.268978+03
16	15	reviewer	2026-11-23 13:27:30.268978+03
17	22	reviewer	2026-11-23 13:27:30.268978+03
18	4	reviewer	2026-11-23 13:27:30.268978+03
19	11	reviewer	2026-11-23 13:27:30.268978+03
20	18	reviewer	2026-11-23 13:27:30.268978+03
21	25	reviewer	2026-11-23 13:27:30.268978+03
22	7	reviewer	2026-11-23 13:27:30.268978+03
23	14	reviewer	2026-11-23 13:27:30.268978+03
24	21	reviewer	2026-11-23 13:27:30.268978+03
25	3	reviewer	2026-11-23 13:27:30.268978+03
26	10	reviewer	2026-11-23 13:27:30.268978+03
27	17	reviewer	2026-11-23 13:27:30.268978+03
28	24	reviewer	2026-11-23 13:27:30.268978+03
29	6	reviewer	2026-11-23 13:27:30.268978+03
30	13	reviewer	2026-11-23 13:27:30.268978+03
31	20	reviewer	2026-11-23 13:27:30.268978+03
32	2	reviewer	2026-11-23 13:27:30.268978+03
33	9	reviewer	2026-11-23 13:27:30.268978+03
34	16	reviewer	2026-11-23 13:27:30.268978+03
35	23	reviewer	2026-11-23 13:27:30.268978+03
36	5	reviewer	2026-11-23 13:27:30.268978+03
37	12	reviewer	2026-11-23 13:27:30.268978+03
38	19	reviewer	2026-11-23 13:27:30.268978+03
39	1	reviewer	2026-11-23 13:27:30.268978+03
40	8	reviewer	2026-11-23 13:27:30.268978+03
\.


--
-- TOC entry 5240 (class 0 OID 17362)
-- Dependencies: 227
-- Data for Name: task_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_status (status_id, code, name) FROM stdin;
1	NEW	Новая
2	IN_PROGRESS	В работе
3	REVIEW	На проверке
4	BLOCKED	Заблокирована
5	DONE	Выполнена
6	CLOSED	Закрыта
\.


--
-- TOC entry 5247 (class 0 OID 17438)
-- Dependencies: 234
-- Data for Name: task_status_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_status_history (history_id, task_id, changed_at, author_employee_id, old_status_id, new_status_id) FROM stdin;
1	1	2026-01-02 00:00:00+03	3	\N	1
2	1	2026-01-03 00:00:00+03	4	1	2
3	2	2026-01-04 00:00:00+03	4	\N	1
4	2	2026-01-05 00:00:00+03	5	1	2
5	3	2026-01-06 00:00:00+03	5	\N	1
6	3	2026-01-07 00:00:00+03	6	1	2
7	4	2026-01-08 00:00:00+03	6	\N	1
8	4	2026-01-09 00:00:00+03	7	1	2
9	5	2026-01-10 00:00:00+03	7	\N	1
10	5	2026-01-11 00:00:00+03	8	1	2
11	6	2026-01-12 00:00:00+03	8	\N	1
12	6	2026-01-13 00:00:00+03	9	1	2
13	7	2026-01-14 00:00:00+03	9	\N	1
14	7	2026-01-15 00:00:00+03	10	1	2
15	8	2026-01-16 00:00:00+03	10	\N	1
16	8	2026-01-17 00:00:00+03	11	1	2
17	9	2026-01-18 00:00:00+03	11	\N	1
18	9	2026-01-19 00:00:00+03	12	1	2
19	10	2026-01-20 00:00:00+03	12	\N	1
20	10	2026-01-21 00:00:00+03	13	1	2
21	11	2026-01-22 00:00:00+03	13	\N	1
22	11	2026-01-23 00:00:00+03	14	1	2
23	12	2026-01-24 00:00:00+03	14	\N	1
24	12	2026-01-25 00:00:00+03	15	1	2
25	13	2026-01-26 00:00:00+03	15	\N	1
26	13	2026-01-27 00:00:00+03	16	1	2
27	14	2026-01-28 00:00:00+03	16	\N	1
28	14	2026-01-29 00:00:00+03	17	1	2
29	15	2026-01-30 00:00:00+03	17	\N	1
30	15	2026-01-31 00:00:00+03	18	1	2
31	16	2026-02-01 00:00:00+03	18	\N	1
32	16	2026-02-02 00:00:00+03	19	1	2
33	17	2026-02-03 00:00:00+03	19	\N	1
34	17	2026-02-04 00:00:00+03	20	1	2
35	18	2026-02-05 00:00:00+03	20	\N	1
36	18	2026-02-06 00:00:00+03	21	1	2
37	19	2026-02-07 00:00:00+03	21	\N	1
38	19	2026-02-08 00:00:00+03	22	1	2
39	20	2026-02-09 00:00:00+03	22	\N	1
40	20	2026-02-10 00:00:00+03	23	1	2
41	21	2026-02-11 00:00:00+03	23	\N	1
42	21	2026-02-12 00:00:00+03	24	1	2
43	22	2026-02-13 00:00:00+03	24	\N	1
44	22	2026-02-14 00:00:00+03	25	1	2
45	23	2026-02-15 00:00:00+03	25	\N	1
46	23	2026-02-16 00:00:00+03	1	1	2
47	24	2026-02-17 00:00:00+03	1	\N	1
48	24	2026-02-18 00:00:00+03	2	1	2
49	25	2026-02-19 00:00:00+03	2	\N	1
50	25	2026-02-20 00:00:00+03	3	1	2
51	26	2026-02-21 00:00:00+03	3	\N	1
52	26	2026-02-22 00:00:00+03	4	1	2
53	27	2026-02-23 00:00:00+03	4	\N	1
54	27	2026-02-24 00:00:00+03	5	1	2
55	28	2026-02-25 00:00:00+03	5	\N	1
56	28	2026-02-26 00:00:00+03	6	1	2
57	29	2026-02-27 00:00:00+03	6	\N	1
58	29	2026-02-28 00:00:00+03	7	1	2
59	30	2026-03-01 00:00:00+03	7	\N	1
60	30	2026-03-02 00:00:00+03	8	1	2
61	31	2026-03-03 00:00:00+03	8	\N	1
62	31	2026-03-04 00:00:00+03	9	1	2
63	32	2026-03-05 00:00:00+03	9	\N	1
64	32	2026-03-06 00:00:00+03	10	1	2
65	33	2026-03-07 00:00:00+03	10	\N	1
66	33	2026-03-08 00:00:00+03	11	1	2
67	34	2026-03-09 00:00:00+03	11	\N	1
68	34	2026-03-10 00:00:00+03	12	1	2
69	35	2026-03-11 00:00:00+03	12	\N	1
70	35	2026-03-12 00:00:00+03	13	1	2
71	36	2026-03-13 00:00:00+03	13	\N	1
72	36	2026-03-14 00:00:00+03	14	1	2
73	37	2026-03-15 00:00:00+03	14	\N	1
74	37	2026-03-16 00:00:00+03	15	1	2
75	38	2026-03-17 00:00:00+03	15	\N	1
76	38	2026-03-18 00:00:00+03	16	1	2
77	39	2026-03-19 00:00:00+03	16	\N	1
78	39	2026-03-20 00:00:00+03	17	1	2
79	40	2026-03-21 00:00:00+03	17	\N	1
80	40	2026-03-22 00:00:00+03	18	1	2
81	41	2026-03-23 00:00:00+03	18	\N	1
82	41	2026-03-24 00:00:00+03	19	1	2
83	42	2026-03-25 00:00:00+03	19	\N	1
84	42	2026-03-26 00:00:00+03	20	1	2
85	43	2026-03-27 00:00:00+03	20	\N	1
86	43	2026-03-28 00:00:00+03	21	1	2
87	44	2026-03-29 00:00:00+03	21	\N	1
88	44	2026-03-30 00:00:00+03	22	1	2
89	45	2026-03-31 00:00:00+03	22	\N	1
90	45	2026-04-01 00:00:00+03	23	1	2
91	46	2026-04-02 00:00:00+03	23	\N	1
92	46	2026-04-03 00:00:00+03	24	1	2
93	47	2026-04-04 00:00:00+03	24	\N	1
94	47	2026-04-05 00:00:00+03	25	1	2
95	48	2026-04-06 00:00:00+03	25	\N	1
96	48	2026-04-07 00:00:00+03	1	1	2
97	49	2026-04-08 00:00:00+03	1	\N	1
98	49	2026-04-09 00:00:00+03	2	1	2
99	50	2026-04-10 00:00:00+03	2	\N	1
100	50	2026-04-11 00:00:00+03	3	1	2
101	51	2026-04-12 00:00:00+03	3	\N	1
102	51	2026-04-13 00:00:00+03	4	1	2
103	52	2026-04-14 00:00:00+03	4	\N	1
104	52	2026-04-15 00:00:00+03	5	1	2
105	53	2026-04-16 00:00:00+03	5	\N	1
106	53	2026-04-17 00:00:00+03	6	1	2
107	54	2026-04-18 00:00:00+03	6	\N	1
108	54	2026-04-19 00:00:00+03	7	1	2
109	55	2026-04-20 00:00:00+03	7	\N	1
110	55	2026-04-21 00:00:00+03	8	1	2
111	56	2026-04-22 00:00:00+03	8	\N	1
112	56	2026-04-23 00:00:00+03	9	1	2
113	57	2026-04-24 00:00:00+03	9	\N	1
114	57	2026-04-25 00:00:00+03	10	1	2
115	58	2026-04-26 00:00:00+03	10	\N	1
116	58	2026-04-27 00:00:00+03	11	1	2
117	59	2026-04-28 00:00:00+03	11	\N	1
118	59	2026-04-29 00:00:00+03	12	1	2
119	60	2026-04-30 00:00:00+03	12	\N	1
120	60	2026-05-01 00:00:00+03	13	1	2
\.


--
-- TOC entry 5245 (class 0 OID 17415)
-- Dependencies: 232
-- Data for Name: time_entry; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.time_entry (time_entry_id, task_id, employee_id, work_date, hours, comment, created_at) FROM stdin;
2	1	10	2026-01-15	3.50	\N	2026-11-23 13:27:30.268978+03
3	2	16	2026-01-22	5.00	\N	2026-11-23 13:27:30.268978+03
4	2	17	2026-01-29	6.50	\N	2026-11-23 13:27:30.268978+03
5	3	23	2026-02-05	0.50	\N	2026-11-23 13:27:30.268978+03
6	3	24	2026-02-12	2.00	\N	2026-11-23 13:27:30.268978+03
7	4	5	2026-02-19	3.50	\N	2026-11-23 13:27:30.268978+03
8	4	6	2026-02-26	5.00	\N	2026-11-23 13:27:30.268978+03
9	5	12	2026-03-05	6.50	\N	2026-11-23 13:27:30.268978+03
10	5	13	2026-03-12	0.50	\N	2026-11-23 13:27:30.268978+03
11	6	19	2026-03-19	2.00	\N	2026-11-23 13:27:30.268978+03
12	6	20	2026-03-26	3.50	\N	2026-11-23 13:27:30.268978+03
13	7	1	2026-04-02	5.00	\N	2026-11-23 13:27:30.268978+03
14	7	2	2026-04-09	6.50	\N	2026-11-23 13:27:30.268978+03
15	8	8	2026-04-16	0.50	\N	2026-11-23 13:27:30.268978+03
16	8	9	2026-04-23	2.00	\N	2026-11-23 13:27:30.268978+03
17	9	15	2026-04-30	3.50	\N	2026-11-23 13:27:30.268978+03
18	9	16	2026-05-07	5.00	\N	2026-11-23 13:27:30.268978+03
19	10	22	2026-05-14	6.50	\N	2026-11-23 13:27:30.268978+03
20	10	23	2026-05-21	0.50	\N	2026-11-23 13:27:30.268978+03
21	11	4	2026-05-28	2.00	\N	2026-11-23 13:27:30.268978+03
22	11	5	2026-06-04	3.50	\N	2026-11-23 13:27:30.268978+03
23	12	11	2026-06-11	5.00	\N	2026-11-23 13:27:30.268978+03
24	12	12	2026-06-18	6.50	\N	2026-11-23 13:27:30.268978+03
25	13	18	2026-06-25	0.50	\N	2026-11-23 13:27:30.268978+03
26	13	19	2026-01-03	2.00	\N	2026-11-23 13:27:30.268978+03
27	14	1	2026-01-10	3.50	\N	2026-11-23 13:27:30.268978+03
28	14	25	2026-01-17	5.00	\N	2026-11-23 13:27:30.268978+03
29	15	7	2026-01-24	6.50	\N	2026-11-23 13:27:30.268978+03
30	15	8	2026-01-31	0.50	\N	2026-11-23 13:27:30.268978+03
31	16	14	2026-02-07	2.00	\N	2026-11-23 13:27:30.268978+03
32	16	15	2026-02-14	3.50	\N	2026-11-23 13:27:30.268978+03
33	17	21	2026-02-21	5.00	\N	2026-11-23 13:27:30.268978+03
34	17	22	2026-02-28	6.50	\N	2026-11-23 13:27:30.268978+03
35	18	3	2026-03-07	0.50	\N	2026-11-23 13:27:30.268978+03
36	18	4	2026-03-14	2.00	\N	2026-11-23 13:27:30.268978+03
37	19	10	2026-03-21	3.50	\N	2026-11-23 13:27:30.268978+03
38	19	11	2026-03-28	5.00	\N	2026-11-23 13:27:30.268978+03
39	20	17	2026-04-04	6.50	\N	2026-11-23 13:27:30.268978+03
40	20	18	2026-04-11	0.50	\N	2026-11-23 13:27:30.268978+03
41	21	24	2026-04-18	2.00	\N	2026-11-23 13:27:30.268978+03
42	21	25	2026-04-25	3.50	\N	2026-11-23 13:27:30.268978+03
43	22	6	2026-05-02	5.00	\N	2026-11-23 13:27:30.268978+03
44	22	7	2026-05-09	6.50	\N	2026-11-23 13:27:30.268978+03
45	23	13	2026-05-16	0.50	\N	2026-11-23 13:27:30.268978+03
46	23	14	2026-05-23	2.00	\N	2026-11-23 13:27:30.268978+03
47	24	20	2026-05-30	3.50	\N	2026-11-23 13:27:30.268978+03
48	24	21	2026-06-06	5.00	\N	2026-11-23 13:27:30.268978+03
49	25	2	2026-06-13	6.50	\N	2026-11-23 13:27:30.268978+03
50	25	3	2026-06-20	0.50	\N	2026-11-23 13:27:30.268978+03
51	26	9	2026-06-27	2.00	\N	2026-11-23 13:27:30.268978+03
52	26	10	2026-01-05	3.50	\N	2026-11-23 13:27:30.268978+03
53	27	16	2026-01-12	5.00	\N	2026-11-23 13:27:30.268978+03
54	27	17	2026-01-19	6.50	\N	2026-11-23 13:27:30.268978+03
55	28	23	2026-01-26	0.50	\N	2026-11-23 13:27:30.268978+03
56	28	24	2026-02-02	2.00	\N	2026-11-23 13:27:30.268978+03
57	29	5	2026-02-09	3.50	\N	2026-11-23 13:27:30.268978+03
58	29	6	2026-02-16	5.00	\N	2026-11-23 13:27:30.268978+03
59	30	12	2026-02-23	6.50	\N	2026-11-23 13:27:30.268978+03
60	30	13	2026-03-02	0.50	\N	2026-11-23 13:27:30.268978+03
61	31	19	2026-03-09	2.00	\N	2026-11-23 13:27:30.268978+03
62	31	20	2026-03-16	3.50	\N	2026-11-23 13:27:30.268978+03
63	32	1	2026-03-23	5.00	\N	2026-11-23 13:27:30.268978+03
64	32	2	2026-03-30	6.50	\N	2026-11-23 13:27:30.268978+03
65	33	8	2026-04-06	0.50	\N	2026-11-23 13:27:30.268978+03
66	33	9	2026-04-13	2.00	\N	2026-11-23 13:27:30.268978+03
67	34	15	2026-04-20	3.50	\N	2026-11-23 13:27:30.268978+03
68	34	16	2026-04-27	5.00	\N	2026-11-23 13:27:30.268978+03
69	35	22	2026-05-04	6.50	\N	2026-11-23 13:27:30.268978+03
70	35	23	2026-05-11	0.50	\N	2026-11-23 13:27:30.268978+03
71	36	4	2026-05-18	2.00	\N	2026-11-23 13:27:30.268978+03
72	36	5	2026-05-25	3.50	\N	2026-11-23 13:27:30.268978+03
73	37	11	2026-06-01	5.00	\N	2026-11-23 13:27:30.268978+03
74	37	12	2026-06-08	6.50	\N	2026-11-23 13:27:30.268978+03
75	38	18	2026-06-15	0.50	\N	2026-11-23 13:27:30.268978+03
76	38	19	2026-06-22	2.00	\N	2026-11-23 13:27:30.268978+03
77	39	1	2026-06-29	3.50	\N	2026-11-23 13:27:30.268978+03
78	39	25	2026-01-07	5.00	\N	2026-11-23 13:27:30.268978+03
79	40	7	2026-01-14	6.50	\N	2026-11-23 13:27:30.268978+03
80	40	8	2026-01-21	0.50	\N	2026-11-23 13:27:30.268978+03
81	41	14	2026-01-28	2.00	\N	2026-11-23 13:27:30.268978+03
82	42	21	2026-02-04	3.50	\N	2026-11-23 13:27:30.268978+03
83	43	3	2026-02-11	5.00	\N	2026-11-23 13:27:30.268978+03
84	44	10	2026-02-18	6.50	\N	2026-11-23 13:27:30.268978+03
85	45	17	2026-02-25	0.50	\N	2026-11-23 13:27:30.268978+03
86	46	24	2026-03-04	2.00	\N	2026-11-23 13:27:30.268978+03
87	47	6	2026-03-11	3.50	\N	2026-11-23 13:27:30.268978+03
88	48	13	2026-03-18	5.00	\N	2026-11-23 13:27:30.268978+03
89	49	20	2026-03-25	6.50	\N	2026-11-23 13:27:30.268978+03
90	50	2	2026-04-01	0.50	\N	2026-11-23 13:27:30.268978+03
91	51	9	2026-04-08	2.00	\N	2026-11-23 13:27:30.268978+03
92	52	16	2026-04-15	3.50	\N	2026-11-23 13:27:30.268978+03
93	53	23	2026-04-22	5.00	\N	2026-11-23 13:27:30.268978+03
94	54	5	2026-04-29	6.50	\N	2026-11-23 13:27:30.268978+03
95	55	12	2026-05-06	0.50	\N	2026-11-23 13:27:30.268978+03
96	56	19	2026-05-13	2.00	\N	2026-11-23 13:27:30.268978+03
97	57	1	2026-05-20	3.50	\N	2026-11-23 13:27:30.268978+03
98	58	8	2026-05-27	5.00	\N	2026-11-23 13:27:30.268978+03
99	59	15	2026-06-03	6.50	\N	2026-11-23 13:27:30.268978+03
100	60	22	2026-06-10	0.50	\N	2026-11-23 13:27:30.268978+03
102	1	10	2026-06-24	3.50	\N	2026-11-23 13:27:30.268978+03
103	2	16	2026-01-02	5.00	\N	2026-11-23 13:27:30.268978+03
104	2	17	2026-01-09	6.50	\N	2026-11-23 13:27:30.268978+03
105	3	23	2026-01-16	0.50	\N	2026-11-23 13:27:30.268978+03
106	3	24	2026-01-23	2.00	\N	2026-11-23 13:27:30.268978+03
107	4	5	2026-01-30	3.50	\N	2026-11-23 13:27:30.268978+03
108	4	6	2026-02-06	5.00	\N	2026-11-23 13:27:30.268978+03
109	5	12	2026-02-13	6.50	\N	2026-11-23 13:27:30.268978+03
110	5	13	2026-02-20	0.50	\N	2026-11-23 13:27:30.268978+03
111	6	19	2026-02-27	2.00	\N	2026-11-23 13:27:30.268978+03
112	6	20	2026-03-06	3.50	\N	2026-11-23 13:27:30.268978+03
113	7	1	2026-03-13	5.00	\N	2026-11-23 13:27:30.268978+03
114	7	2	2026-03-20	6.50	\N	2026-11-23 13:27:30.268978+03
115	8	8	2026-03-27	0.50	\N	2026-11-23 13:27:30.268978+03
116	8	9	2026-04-03	2.00	\N	2026-11-23 13:27:30.268978+03
117	9	15	2026-04-10	3.50	\N	2026-11-23 13:27:30.268978+03
118	9	16	2026-04-17	5.00	\N	2026-11-23 13:27:30.268978+03
119	10	22	2026-04-24	6.50	\N	2026-11-23 13:27:30.268978+03
120	10	23	2026-05-01	0.50	\N	2026-11-23 13:27:30.268978+03
121	11	4	2026-05-08	2.00	\N	2026-11-23 13:27:30.268978+03
122	11	5	2026-05-15	3.50	\N	2026-11-23 13:27:30.268978+03
123	12	11	2026-05-22	5.00	\N	2026-11-23 13:27:30.268978+03
124	12	12	2026-05-29	6.50	\N	2026-11-23 13:27:30.268978+03
125	13	18	2026-06-05	0.50	\N	2026-11-23 13:27:30.268978+03
126	13	19	2026-06-12	2.00	\N	2026-11-23 13:27:30.268978+03
127	14	1	2026-06-19	3.50	\N	2026-11-23 13:27:30.268978+03
128	14	25	2026-06-26	5.00	\N	2026-11-23 13:27:30.268978+03
129	15	7	2026-01-04	6.50	\N	2026-11-23 13:27:30.268978+03
130	15	8	2026-01-11	0.50	\N	2026-11-23 13:27:30.268978+03
131	16	14	2026-01-18	2.00	\N	2026-11-23 13:27:30.268978+03
132	16	15	2026-01-25	3.50	\N	2026-11-23 13:27:30.268978+03
133	17	21	2026-02-01	5.00	\N	2026-11-23 13:27:30.268978+03
134	17	22	2026-02-08	6.50	\N	2026-11-23 13:27:30.268978+03
135	18	3	2026-02-15	0.50	\N	2026-11-23 13:27:30.268978+03
136	18	4	2026-02-22	2.00	\N	2026-11-23 13:27:30.268978+03
137	19	10	2026-03-01	3.50	\N	2026-11-23 13:27:30.268978+03
138	19	11	2026-03-08	5.00	\N	2026-11-23 13:27:30.268978+03
139	20	17	2026-03-15	6.50	\N	2026-11-23 13:27:30.268978+03
140	20	18	2026-03-22	0.50	\N	2026-11-23 13:27:30.268978+03
141	21	24	2026-03-29	2.00	\N	2026-11-23 13:27:30.268978+03
142	21	25	2026-04-05	3.50	\N	2026-11-23 13:27:30.268978+03
143	22	6	2026-04-12	5.00	\N	2026-11-23 13:27:30.268978+03
144	22	7	2026-04-19	6.50	\N	2026-11-23 13:27:30.268978+03
145	23	13	2026-04-26	0.50	\N	2026-11-23 13:27:30.268978+03
146	23	14	2026-05-03	2.00	\N	2026-11-23 13:27:30.268978+03
147	24	20	2026-05-10	3.50	\N	2026-11-23 13:27:30.268978+03
148	24	21	2026-05-17	5.00	\N	2026-11-23 13:27:30.268978+03
149	25	2	2026-05-24	6.50	\N	2026-11-23 13:27:30.268978+03
150	25	3	2026-05-31	0.50	\N	2026-11-23 13:27:30.268978+03
151	26	9	2026-06-07	2.00	\N	2026-11-23 13:27:30.268978+03
152	26	10	2026-06-14	3.50	\N	2026-11-23 13:27:30.268978+03
153	27	16	2026-06-21	5.00	\N	2026-11-23 13:27:30.268978+03
154	27	17	2026-06-28	6.50	\N	2026-11-23 13:27:30.268978+03
155	28	23	2026-01-06	0.50	\N	2026-11-23 13:27:30.268978+03
156	28	24	2026-01-13	2.00	\N	2026-11-23 13:27:30.268978+03
157	29	5	2026-01-20	3.50	\N	2026-11-23 13:27:30.268978+03
158	29	6	2026-01-27	5.00	\N	2026-11-23 13:27:30.268978+03
159	30	12	2026-02-03	6.50	\N	2026-11-23 13:27:30.268978+03
160	30	13	2026-02-10	0.50	\N	2026-11-23 13:27:30.268978+03
161	31	19	2026-02-17	2.00	\N	2026-11-23 13:27:30.268978+03
162	31	20	2026-02-24	3.50	\N	2026-11-23 13:27:30.268978+03
163	32	1	2026-03-03	5.00	\N	2026-11-23 13:27:30.268978+03
164	32	2	2026-03-10	6.50	\N	2026-11-23 13:27:30.268978+03
165	33	8	2026-03-17	0.50	\N	2026-11-23 13:27:30.268978+03
166	33	9	2026-03-24	2.00	\N	2026-11-23 13:27:30.268978+03
167	34	15	2026-03-31	3.50	\N	2026-11-23 13:27:30.268978+03
168	34	16	2026-04-07	5.00	\N	2026-11-23 13:27:30.268978+03
169	35	22	2026-04-14	6.50	\N	2026-11-23 13:27:30.268978+03
170	35	23	2026-04-21	0.50	\N	2026-11-23 13:27:30.268978+03
171	36	4	2026-04-28	2.00	\N	2026-11-23 13:27:30.268978+03
172	36	5	2026-05-05	3.50	\N	2026-11-23 13:27:30.268978+03
173	37	11	2026-05-12	5.00	\N	2026-11-23 13:27:30.268978+03
174	37	12	2026-05-19	6.50	\N	2026-11-23 13:27:30.268978+03
175	38	18	2026-05-26	0.50	\N	2026-11-23 13:27:30.268978+03
176	38	19	2026-06-02	2.00	\N	2026-11-23 13:27:30.268978+03
177	39	1	2026-06-09	3.50	\N	2026-11-23 13:27:30.268978+03
178	39	25	2026-06-16	5.00	\N	2026-11-23 13:27:30.268978+03
179	40	7	2026-06-23	6.50	\N	2026-11-23 13:27:30.268978+03
180	40	8	2026-01-01	0.50	\N	2026-11-23 13:27:30.268978+03
181	41	14	2026-01-08	2.00	\N	2026-11-23 13:27:30.268978+03
182	42	21	2026-01-15	3.50	\N	2026-11-23 13:27:30.268978+03
183	43	3	2026-01-22	5.00	\N	2026-11-23 13:27:30.268978+03
184	44	10	2026-01-29	6.50	\N	2026-11-23 13:27:30.268978+03
185	45	17	2026-02-05	0.50	\N	2026-11-23 13:27:30.268978+03
186	46	24	2026-02-12	2.00	\N	2026-11-23 13:27:30.268978+03
187	47	6	2026-02-19	3.50	\N	2026-11-23 13:27:30.268978+03
188	48	13	2026-02-26	5.00	\N	2026-11-23 13:27:30.268978+03
189	49	20	2026-03-05	6.50	\N	2026-11-23 13:27:30.268978+03
190	50	2	2026-03-12	0.50	\N	2026-11-23 13:27:30.268978+03
191	51	9	2026-03-19	2.00	\N	2026-11-23 13:27:30.268978+03
192	52	16	2026-03-26	3.50	\N	2026-11-23 13:27:30.268978+03
193	53	23	2026-04-02	5.00	\N	2026-11-23 13:27:30.268978+03
194	54	5	2026-04-09	6.50	\N	2026-11-23 13:27:30.268978+03
195	55	12	2026-04-16	0.50	\N	2026-11-23 13:27:30.268978+03
196	56	19	2026-04-23	2.00	\N	2026-11-23 13:27:30.268978+03
197	57	1	2026-04-30	3.50	\N	2026-11-23 13:27:30.268978+03
198	58	8	2026-05-07	5.00	\N	2026-11-23 13:27:30.268978+03
199	59	15	2026-05-14	6.50	\N	2026-11-23 13:27:30.268978+03
200	60	22	2026-05-21	0.50	\N	2026-11-23 13:27:30.268978+03
202	1	10	2026-06-04	3.50	\N	2026-11-23 13:27:30.268978+03
203	2	16	2026-06-11	5.00	\N	2026-11-23 13:27:30.268978+03
204	2	17	2026-06-18	6.50	\N	2026-11-23 13:27:30.268978+03
205	3	23	2026-06-25	0.50	\N	2026-11-23 13:27:30.268978+03
206	3	24	2026-01-03	2.00	\N	2026-11-23 13:27:30.268978+03
207	4	5	2026-01-10	3.50	\N	2026-11-23 13:27:30.268978+03
208	4	6	2026-01-17	5.00	\N	2026-11-23 13:27:30.268978+03
209	5	12	2026-01-24	6.50	\N	2026-11-23 13:27:30.268978+03
210	5	13	2026-01-31	0.50	\N	2026-11-23 13:27:30.268978+03
211	6	19	2026-02-07	2.00	\N	2026-11-23 13:27:30.268978+03
212	6	20	2026-02-14	3.50	\N	2026-11-23 13:27:30.268978+03
213	7	1	2026-02-21	5.00	\N	2026-11-23 13:27:30.268978+03
214	7	2	2026-02-28	6.50	\N	2026-11-23 13:27:30.268978+03
215	8	8	2026-03-07	0.50	\N	2026-11-23 13:27:30.268978+03
216	8	9	2026-03-14	2.00	\N	2026-11-23 13:27:30.268978+03
217	9	15	2026-03-21	3.50	\N	2026-11-23 13:27:30.268978+03
218	9	16	2026-03-28	5.00	\N	2026-11-23 13:27:30.268978+03
219	10	22	2026-04-04	6.50	\N	2026-11-23 13:27:30.268978+03
220	10	23	2026-04-11	0.50	\N	2026-11-23 13:27:30.268978+03
221	11	4	2026-04-18	2.00	\N	2026-11-23 13:27:30.268978+03
222	11	5	2026-04-25	3.50	\N	2026-11-23 13:27:30.268978+03
223	12	11	2026-05-02	5.00	\N	2026-11-23 13:27:30.268978+03
224	12	12	2026-05-09	6.50	\N	2026-11-23 13:27:30.268978+03
225	13	18	2026-05-16	0.50	\N	2026-11-23 13:27:30.268978+03
226	13	19	2026-05-23	2.00	\N	2026-11-23 13:27:30.268978+03
227	14	1	2026-05-30	3.50	\N	2026-11-23 13:27:30.268978+03
228	14	25	2026-06-06	5.00	\N	2026-11-23 13:27:30.268978+03
229	15	7	2026-06-13	6.50	\N	2026-11-23 13:27:30.268978+03
230	15	8	2026-06-20	0.50	\N	2026-11-23 13:27:30.268978+03
231	16	14	2026-06-27	2.00	\N	2026-11-23 13:27:30.268978+03
232	16	15	2026-01-05	3.50	\N	2026-11-23 13:27:30.268978+03
233	17	21	2026-01-12	5.00	\N	2026-11-23 13:27:30.268978+03
234	17	22	2026-01-19	6.50	\N	2026-11-23 13:27:30.268978+03
235	18	3	2026-01-26	0.50	\N	2026-11-23 13:27:30.268978+03
236	18	4	2026-02-02	2.00	\N	2026-11-23 13:27:30.268978+03
237	19	10	2026-02-09	3.50	\N	2026-11-23 13:27:30.268978+03
238	19	11	2026-02-16	5.00	\N	2026-11-23 13:27:30.268978+03
239	20	17	2026-02-23	6.50	\N	2026-11-23 13:27:30.268978+03
240	20	18	2026-03-02	0.50	\N	2026-11-23 13:27:30.268978+03
241	21	24	2026-03-09	2.00	\N	2026-11-23 13:27:30.268978+03
242	21	25	2026-03-16	3.50	\N	2026-11-23 13:27:30.268978+03
243	22	6	2026-03-23	5.00	\N	2026-11-23 13:27:30.268978+03
244	22	7	2026-03-30	6.50	\N	2026-11-23 13:27:30.268978+03
245	23	13	2026-04-06	0.50	\N	2026-11-23 13:27:30.268978+03
246	23	14	2026-04-13	2.00	\N	2026-11-23 13:27:30.268978+03
247	24	20	2026-04-20	3.50	\N	2026-11-23 13:27:30.268978+03
248	24	21	2026-04-27	5.00	\N	2026-11-23 13:27:30.268978+03
249	25	2	2026-05-04	6.50	\N	2026-11-23 13:27:30.268978+03
250	25	3	2026-05-11	0.50	\N	2026-11-23 13:27:30.268978+03
\.


--
-- TOC entry 5261 (class 0 OID 0)
-- Dependencies: 218
-- Name: department_department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.department_department_id_seq', 5, true);


--
-- TOC entry 5262 (class 0 OID 0)
-- Dependencies: 220
-- Name: employee_employee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employee_employee_id_seq', 25, true);


--
-- TOC entry 5263 (class 0 OID 0)
-- Dependencies: 223
-- Name: project_project_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.project_project_id_seq', 10, true);


--
-- TOC entry 5264 (class 0 OID 0)
-- Dependencies: 233
-- Name: task_status_history_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.task_status_history_history_id_seq', 120, true);


--
-- TOC entry 5265 (class 0 OID 0)
-- Dependencies: 226
-- Name: task_status_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.task_status_status_id_seq', 6, true);


--
-- TOC entry 5266 (class 0 OID 0)
-- Dependencies: 228
-- Name: task_task_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.task_task_id_seq', 60, true);


--
-- TOC entry 5267 (class 0 OID 0)
-- Dependencies: 231
-- Name: time_entry_time_entry_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.time_entry_time_entry_id_seq', 253, true);


--
-- TOC entry 5036 (class 2606 OID 17289)
-- Name: department department_department_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_department_code_key UNIQUE (department_code);


--
-- TOC entry 5038 (class 2606 OID 17287)
-- Name: department department_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_pkey PRIMARY KEY (department_id);


--
-- TOC entry 5043 (class 2606 OID 17315)
-- Name: employee_department_history employee_department_history_employee_id_daterange_excl; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_department_history
    ADD CONSTRAINT employee_department_history_employee_id_daterange_excl EXCLUDE USING gist (employee_id WITH =, daterange(valid_from, valid_to, '[)'::text) WITH &&);


--
-- TOC entry 5045 (class 2606 OID 17313)
-- Name: employee_department_history employee_department_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_department_history
    ADD CONSTRAINT employee_department_history_pkey PRIMARY KEY (employee_id, valid_from);


--
-- TOC entry 5041 (class 2606 OID 17301)
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employee_id);


--
-- TOC entry 5051 (class 2606 OID 17350)
-- Name: project_member project_member_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_member
    ADD CONSTRAINT project_member_pkey PRIMARY KEY (project_id, employee_id);


--
-- TOC entry 5047 (class 2606 OID 17337)
-- Name: project project_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (project_id);


--
-- TOC entry 5049 (class 2606 OID 17339)
-- Name: project project_project_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_project_code_key UNIQUE (project_code);


--
-- TOC entry 5061 (class 2606 OID 17403)
-- Name: task_assignment task_assignment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_assignment
    ADD CONSTRAINT task_assignment_pkey PRIMARY KEY (task_id, employee_id);


--
-- TOC entry 5057 (class 2606 OID 17384)
-- Name: task task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_pkey PRIMARY KEY (task_id);


--
-- TOC entry 5059 (class 2606 OID 17386)
-- Name: task task_project_id_task_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_project_id_task_code_key UNIQUE (project_id, task_code);


--
-- TOC entry 5053 (class 2606 OID 17372)
-- Name: task_status task_status_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_status
    ADD CONSTRAINT task_status_code_key UNIQUE (code);


--
-- TOC entry 5067 (class 2606 OID 17445)
-- Name: task_status_history task_status_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_status_history
    ADD CONSTRAINT task_status_history_pkey PRIMARY KEY (history_id);


--
-- TOC entry 5055 (class 2606 OID 17370)
-- Name: task_status task_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_status
    ADD CONSTRAINT task_status_pkey PRIMARY KEY (status_id);


--
-- TOC entry 5064 (class 2606 OID 17424)
-- Name: time_entry time_entry_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_entry
    ADD CONSTRAINT time_entry_pkey PRIMARY KEY (time_entry_id);


--
-- TOC entry 5039 (class 1259 OID 17307)
-- Name: employee_email_lower_uidx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX employee_email_lower_uidx ON public.employee USING btree (lower(TRIM(BOTH FROM email)));


--
-- TOC entry 5068 (class 1259 OID 17466)
-- Name: task_status_history_task_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX task_status_history_task_idx ON public.task_status_history USING btree (task_id, changed_at DESC);


--
-- TOC entry 5062 (class 1259 OID 17436)
-- Name: time_entry_employee_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX time_entry_employee_date_idx ON public.time_entry USING btree (employee_id, work_date);


--
-- TOC entry 5065 (class 1259 OID 17435)
-- Name: time_entry_task_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX time_entry_task_date_idx ON public.time_entry USING btree (task_id, work_date);


--
-- TOC entry 5069 (class 2606 OID 17302)
-- Name: employee employee_current_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_current_department_id_fkey FOREIGN KEY (current_department_id) REFERENCES public.department(department_id);


--
-- TOC entry 5070 (class 2606 OID 17321)
-- Name: employee_department_history employee_department_history_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_department_history
    ADD CONSTRAINT employee_department_history_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.department(department_id);


--
-- TOC entry 5071 (class 2606 OID 17316)
-- Name: employee_department_history employee_department_history_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_department_history
    ADD CONSTRAINT employee_department_history_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id);


--
-- TOC entry 5079 (class 2606 OID 17516)
-- Name: time_entry fk_time_entry_assignment; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_entry
    ADD CONSTRAINT fk_time_entry_assignment FOREIGN KEY (task_id, employee_id) REFERENCES public.task_assignment(task_id, employee_id) ON DELETE RESTRICT;


--
-- TOC entry 5072 (class 2606 OID 17340)
-- Name: project project_manager_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_manager_employee_id_fkey FOREIGN KEY (manager_employee_id) REFERENCES public.employee(employee_id);


--
-- TOC entry 5073 (class 2606 OID 17356)
-- Name: project_member project_member_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_member
    ADD CONSTRAINT project_member_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id) ON DELETE RESTRICT;


--
-- TOC entry 5074 (class 2606 OID 17351)
-- Name: project_member project_member_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_member
    ADD CONSTRAINT project_member_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(project_id) ON DELETE RESTRICT;


--
-- TOC entry 5077 (class 2606 OID 17409)
-- Name: task_assignment task_assignment_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_assignment
    ADD CONSTRAINT task_assignment_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id) ON DELETE RESTRICT;


--
-- TOC entry 5078 (class 2606 OID 17404)
-- Name: task_assignment task_assignment_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_assignment
    ADD CONSTRAINT task_assignment_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(task_id) ON DELETE RESTRICT;


--
-- TOC entry 5075 (class 2606 OID 17392)
-- Name: task task_current_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_current_status_id_fkey FOREIGN KEY (current_status_id) REFERENCES public.task_status(status_id);


--
-- TOC entry 5076 (class 2606 OID 17387)
-- Name: task task_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task
    ADD CONSTRAINT task_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.project(project_id) ON DELETE RESTRICT;


--
-- TOC entry 5082 (class 2606 OID 17451)
-- Name: task_status_history task_status_history_author_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_status_history
    ADD CONSTRAINT task_status_history_author_employee_id_fkey FOREIGN KEY (author_employee_id) REFERENCES public.employee(employee_id);


--
-- TOC entry 5083 (class 2606 OID 17461)
-- Name: task_status_history task_status_history_new_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_status_history
    ADD CONSTRAINT task_status_history_new_status_id_fkey FOREIGN KEY (new_status_id) REFERENCES public.task_status(status_id);


--
-- TOC entry 5084 (class 2606 OID 17456)
-- Name: task_status_history task_status_history_old_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_status_history
    ADD CONSTRAINT task_status_history_old_status_id_fkey FOREIGN KEY (old_status_id) REFERENCES public.task_status(status_id);


--
-- TOC entry 5085 (class 2606 OID 17446)
-- Name: task_status_history task_status_history_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_status_history
    ADD CONSTRAINT task_status_history_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(task_id) ON DELETE CASCADE;


--
-- TOC entry 5080 (class 2606 OID 17430)
-- Name: time_entry time_entry_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_entry
    ADD CONSTRAINT time_entry_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id) ON DELETE RESTRICT;


--
-- TOC entry 5081 (class 2606 OID 17425)
-- Name: time_entry time_entry_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.time_entry
    ADD CONSTRAINT time_entry_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.task(task_id) ON DELETE RESTRICT;


-- Completed on 2026-11-23 13:45:08

--
-- PostgreSQL database dump complete
--

