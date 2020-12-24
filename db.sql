--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Drop databases (except postgres and template1)
--

DROP DATABASE cinemart;
DROP DATABASE test;




--
-- Drop roles
--

DROP ROLE postgres;


--
-- Roles
--

CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'md53175bce1d3201d16594cebf9d7eb3f9d';






--
-- Databases
--

--
-- Database "template1" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.1 (Debian 13.1-1.pgdg100+1)
-- Dumped by pg_dump version 13.1 (Debian 13.1-1.pgdg100+1)

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

CREATE DATABASE template1 WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.utf8';


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
-- Database "cinemart" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.1 (Debian 13.1-1.pgdg100+1)
-- Dumped by pg_dump version 13.1 (Debian 13.1-1.pgdg100+1)

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
-- Name: cinemart; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE cinemart WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.utf8';


ALTER DATABASE cinemart OWNER TO postgres;

\connect cinemart

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
-- Name: genre; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.genre AS (
	id integer,
	name text
);


ALTER TYPE public.genre OWNER TO postgres;

--
-- Name: delete_invoices_trigger(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_invoices_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  update schedules
  set reserved = reserved - old.tickets_count
  where schedules.id = old.schedule;
  RETURN OLD;
END;
$$;


ALTER FUNCTION public.delete_invoices_trigger() OWNER TO postgres;

--
-- Name: delete_tickets_trigger(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_tickets_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  update invoices
  set cost = cost - old.price,
      tickets_count = tickets_count - 1
  where invoices.id = old.invoice;
  RETURN OLD;
END;
$$;


ALTER FUNCTION public.delete_tickets_trigger() OWNER TO postgres;

--
-- Name: insert_tickets_trigger(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_tickets_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  update invoices
  set cost = cost + new.price,
      tickets_count = tickets_count + 1
  where invoices.id = new.invoice;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_tickets_trigger() OWNER TO postgres;

--
-- Name: update_invoices_trigger(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_invoices_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  update schedules
  set reserved = reserved - old.tickets_count + new.tickets_count
  where schedules.id = new.schedule;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_invoices_trigger() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admins (
    id integer NOT NULL,
    password text NOT NULL,
    mail text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.admins OWNER TO postgres;

--
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.admins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.admins_id_seq OWNER TO postgres;

--
-- Name: admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.admins_id_seq OWNED BY public.admins.id;


--
-- Name: auth; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth (
    token text NOT NULL,
    refresh_token text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.auth OWNER TO postgres;

--
-- Name: invoices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoices (
    id integer NOT NULL,
    user_id integer NOT NULL,
    schedule integer NOT NULL,
    paid boolean DEFAULT false NOT NULL,
    tickets_count integer DEFAULT 0,
    cost integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.invoices OWNER TO postgres;

--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.invoices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.invoices_id_seq OWNER TO postgres;

--
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.invoices_id_seq OWNED BY public.invoices.id;


--
-- Name: invoices_schedule_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.invoices_schedule_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.invoices_schedule_seq OWNER TO postgres;

--
-- Name: invoices_schedule_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.invoices_schedule_seq OWNED BY public.invoices.schedule;


--
-- Name: invoices_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.invoices_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.invoices_user_id_seq OWNER TO postgres;

--
-- Name: invoices_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.invoices_user_id_seq OWNED BY public.invoices.user_id;


--
-- Name: management; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.management (
    manager integer NOT NULL,
    theater integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.management OWNER TO postgres;

--
-- Name: management_manager_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.management_manager_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.management_manager_seq OWNER TO postgres;

--
-- Name: management_manager_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.management_manager_seq OWNED BY public.management.manager;


--
-- Name: management_theater_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.management_theater_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.management_theater_seq OWNER TO postgres;

--
-- Name: management_theater_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.management_theater_seq OWNED BY public.management.theater;


--
-- Name: managers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.managers (
    id integer NOT NULL,
    password text NOT NULL,
    mail text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.managers OWNER TO postgres;

--
-- Name: managers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.managers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.managers_id_seq OWNER TO postgres;

--
-- Name: managers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.managers_id_seq OWNED BY public.managers.id;


--
-- Name: movies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.movies (
    id integer NOT NULL,
    runtime integer,
    genres json,
    overview text,
    title text,
    poster_path text,
    backdrop_path text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.movies OWNER TO postgres;

--
-- Name: movies_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.movies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.movies_id_seq OWNER TO postgres;

--
-- Name: movies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.movies_id_seq OWNED BY public.movies.id;


--
-- Name: schedules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schedules (
    id integer NOT NULL,
    movie integer NOT NULL,
    theater integer NOT NULL,
    room integer NOT NULL,
    nrow integer NOT NULL,
    ncolumn integer NOT NULL,
    price integer NOT NULL,
    "time" timestamp without time zone NOT NULL,
    reserved integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.schedules OWNER TO postgres;

--
-- Name: schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.schedules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.schedules_id_seq OWNER TO postgres;

--
-- Name: schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.schedules_id_seq OWNED BY public.schedules.id;


--
-- Name: schedules_movie_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.schedules_movie_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.schedules_movie_seq OWNER TO postgres;

--
-- Name: schedules_movie_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.schedules_movie_seq OWNED BY public.schedules.movie;


--
-- Name: schedules_theater_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.schedules_theater_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.schedules_theater_seq OWNER TO postgres;

--
-- Name: schedules_theater_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.schedules_theater_seq OWNED BY public.schedules.theater;


--
-- Name: theaters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.theaters (
    id integer NOT NULL,
    name text NOT NULL,
    address text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.theaters OWNER TO postgres;

--
-- Name: theaters_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.theaters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.theaters_id_seq OWNER TO postgres;

--
-- Name: theaters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.theaters_id_seq OWNED BY public.theaters.id;


--
-- Name: tickets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tickets (
    invoice integer NOT NULL,
    seat integer NOT NULL,
    seat_name text NOT NULL,
    price integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.tickets OWNER TO postgres;

--
-- Name: tickets_invoice_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tickets_invoice_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tickets_invoice_seq OWNER TO postgres;

--
-- Name: tickets_invoice_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tickets_invoice_seq OWNED BY public.tickets.invoice;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    fullname text NOT NULL,
    dob timestamp without time zone NOT NULL,
    username text NOT NULL,
    password text NOT NULL,
    mail text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: admins id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admins ALTER COLUMN id SET DEFAULT nextval('public.admins_id_seq'::regclass);


--
-- Name: invoices id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices ALTER COLUMN id SET DEFAULT nextval('public.invoices_id_seq'::regclass);


--
-- Name: invoices user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices ALTER COLUMN user_id SET DEFAULT nextval('public.invoices_user_id_seq'::regclass);


--
-- Name: invoices schedule; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices ALTER COLUMN schedule SET DEFAULT nextval('public.invoices_schedule_seq'::regclass);


--
-- Name: management manager; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.management ALTER COLUMN manager SET DEFAULT nextval('public.management_manager_seq'::regclass);


--
-- Name: management theater; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.management ALTER COLUMN theater SET DEFAULT nextval('public.management_theater_seq'::regclass);


--
-- Name: managers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.managers ALTER COLUMN id SET DEFAULT nextval('public.managers_id_seq'::regclass);


--
-- Name: movies id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movies ALTER COLUMN id SET DEFAULT nextval('public.movies_id_seq'::regclass);


--
-- Name: schedules id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedules ALTER COLUMN id SET DEFAULT nextval('public.schedules_id_seq'::regclass);


--
-- Name: schedules movie; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedules ALTER COLUMN movie SET DEFAULT nextval('public.schedules_movie_seq'::regclass);


--
-- Name: schedules theater; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedules ALTER COLUMN theater SET DEFAULT nextval('public.schedules_theater_seq'::regclass);


--
-- Name: theaters id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.theaters ALTER COLUMN id SET DEFAULT nextval('public.theaters_id_seq'::regclass);


--
-- Name: tickets invoice; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets ALTER COLUMN invoice SET DEFAULT nextval('public.tickets_invoice_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: admins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admins (id, password, mail, created_at) FROM stdin;
1	bcrypt+sha512$5a30e1154b4f9430a5a243b490596a1b$12$203d2bbb9bad639fd0442b974573e979c0b122ef312d53a2	admin@cinemart.com	2020-12-18 16:09:17.691576
\.


--
-- Data for Name: auth; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth (token, refresh_token, created_at) FROM stdin;
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invoices (id, user_id, schedule, paid, tickets_count, cost, created_at) FROM stdin;
12	2	14	f	14	840000	2020-12-21 02:06:36.893918
2	2	10	f	4	200000	2020-12-20 14:32:12.54275
13	3	12	f	1	50000	2020-12-21 02:23:52.453963
3	2	10	f	3	150000	2020-12-20 15:05:45.872252
4	2	9	f	6	300000	2020-12-20 15:39:38.664491
5	2	7	f	6	300000	2020-12-20 15:43:46.340241
6	2	2	f	4	200000	2020-12-20 16:07:54.424477
7	2	10	f	3	150000	2020-12-20 17:47:42.55703
8	2	11	f	3	150000	2020-12-20 17:48:17.969027
9	2	11	f	3	150000	2020-12-20 17:49:17.460031
10	2	11	f	3	150000	2020-12-20 17:53:50.029119
11	2	14	f	9	540000	2020-12-20 18:13:55.18811
\.


--
-- Data for Name: management; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.management (manager, theater, created_at) FROM stdin;
1	1	2020-12-18 16:11:43.732163
2	2	2020-12-19 20:06:12.741608
3	3	2020-12-19 20:17:44.777869
4	4	2020-12-19 20:34:13.971242
5	5	2020-12-19 20:43:12.885776
6	6	2020-12-19 21:05:08.922693
7	7	2020-12-19 21:07:13.391508
8	3	2020-12-19 21:13:21.825457
\.


--
-- Data for Name: managers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.managers (id, password, mail, created_at) FROM stdin;
3	bcrypt+sha512$608cd17a09f3ebbf6e03531301f061fc$12$12a22593922ef92748aa0d490974c42fa097dc5c003b3b11	cinestar@manager.com	2020-12-19 20:17:44.761442
2	bcrypt+sha512$74b008a792fd4c92e4d7313edf204434$12$203fb4d6d1f5247fb897a7a0f374a02c9d0dcb8964b580f9	megastar@manager.com	2020-12-19 20:06:12.723672
4	bcrypt+sha512$a33eb5916b207f7ce47b65ae79f21db1$12$e3019d756006f27ab68bc3f59e90ead2c8b71e25560b0371	cinebox@manager.com	2020-12-19 20:34:13.954909
5	bcrypt+sha512$eac144fbb76e7fb7d3b9609043dc2033$12$7d5518d1b9eba428ac2a5257fa1366651a163e0d8592d51c	ddc@manager.com	2020-12-19 20:43:12.869494
6	bcrypt+sha512$b80081beadb09092a5aa95f3baafb343$12$83037e341d6a75f771f3a82fd6045b4fa88ba3294d3035f1	cgv@manager.com	2020-12-19 21:05:08.906169
8	bcrypt+sha512$2c29f8bfdba6f3214028ad6260fdbd9e$12$ae96a70ccb49d474e9837b62599c2f7dee2fe941e505cec1	3hoim@sad24	2020-12-19 21:13:21.792059
7	bcrypt+sha512$79f1a8ed13351512157f52da82cb8cc4$12$a99e1ddff126c001b1011fb81a3d3dacca68772144910b52	galaxy@manager.com	2020-12-19 21:07:13.375827
1	bcrypt+sha512$023ed58be3dde44839554ffb8272337f$12$b76044f0c21cfea67af2d6dd07b82f4e945c8d182df00a3a	lotte@manager.com	2020-12-18 16:11:43.714063
\.


--
-- Data for Name: movies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.movies (id, runtime, genres, overview, title, poster_path, backdrop_path, created_at) FROM stdin;
335984	164	[{"id": 878, "name": "Science Fiction"}, {"id": 18, "name": "Drama"}]	Thirty years after the events of the first film, a new blade runner, LAPD Officer K, unearths a long-buried secret that has the potential to plunge what's left of society into chaos. K's discovery leads him on a quest to find Rick Deckard, a former LAPD blade runner who has been missing for 30 years.	Blade Runner 2049	https://image.tmdb.org/t/p/w780/gajva2L0rPYkEWjzgFlBXCAVBE5.jpg	https://image.tmdb.org/t/p/w1280/sAtoMqDVhNDQBc3QJL3RF6hlhGq.jpg	2020-12-18 16:10:21.692417
335983	112	[{"id": 878, "name": "Science Fiction"}, {"id": 28, "name": "Action"}]	Investigative journalist Eddie Brock attempts a comeback following a scandal, but accidentally becomes the host of Venom, a violent, super powerful alien symbiote. Soon, he must rely on his newfound powers to protect the world from a shadowy organization looking for a symbiote of their own.	Venom	https://image.tmdb.org/t/p/w780/2uNW4WbgBXL25BAbXGLnLqX71Sw.jpg	https://image.tmdb.org/t/p/w1280/VuukZLgaCrho2Ar8Scl9HtV3yD.jpg	2020-12-18 16:55:10.191095
646593	94	[{"id": 53, "name": "Thriller"}, {"id": 80, "name": "Crime"}, {"id": 9648, "name": "Mystery"}]	After getting hired to probe a suspicious death in the small town of Wander, a mentally unstable private investigator becomes convinced the case is linked to the same 'conspiracy cover up' that caused the death of his daughter.	Wander	https://image.tmdb.org/t/p/w780/2AwPvNHphpZBJDqjZKVuMAbvS0v.jpg	https://image.tmdb.org/t/p/w1280/wk58aoyWpMTVkKkdjw889XfWGdL.jpg	2020-12-18 16:56:06.822957
716675	91	[{"id": 53, "name": "Thriller"}]	High in the remote Welsh mountains, five builders are brought together to renovate a sprawling old farmhouse. Housed in mouldy portacabins, tensions soon simmer between the men and the self-entitled aristocratic homeowner as well as amongst the ragtag group of men themselves. World-weary old-timer Dave and kindly foreman Bob try to keep the peace, but his nephew Steve falls under the malign influence of bigot Jim, the pair taking a dislike to Viktor, a Ukranian labourer. As the weather closes in and payments are late, tempers fray. Blood is spilled. As the blue-collar men are confronted with an increasingly dark spiral of moral choices, Jim makes an astonishing proposition.	Concrete Plans	https://image.tmdb.org/t/p/w780/xufj5c6SzLVkkP4F1bH88LogBts.jpg	https://image.tmdb.org/t/p/w1280/ydO7ft4DX3cRX4E3JLIVR8K1Oiz.jpg	2020-12-18 16:56:44.887435
577922	150	[{"id": 28, "name": "Action"}, {"id": 53, "name": "Thriller"}, {"id": 878, "name": "Science Fiction"}]	Armed with only one word - Tenet - and fighting for the survival of the entire world, the Protagonist journeys through a twilight world of international espionage on a mission that will unfold in something beyond real time.	Tenet	https://image.tmdb.org/t/p/w780/k68nPLbIST6NP96JmTxmZijEvCA.jpg	https://image.tmdb.org/t/p/w1280/wzJRB4MKi3yK138bJyuL9nx47y6.jpg	2020-12-18 16:57:30.623929
157336	169	[{"id": 12, "name": "Adventure"}, {"id": 18, "name": "Drama"}, {"id": 878, "name": "Science Fiction"}]	The adventures of a group of explorers who make use of a newly discovered wormhole to surpass the limitations on human space travel and conquer the vast distances involved in an interstellar voyage.	Interstellar	https://image.tmdb.org/t/p/w780/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg	https://image.tmdb.org/t/p/w1280/xJHokMbljvjADYdit5fK5VQsXEG.jpg	2020-12-18 16:58:27.09267
137113	113	[{"id": 28, "name": "Action"}, {"id": 878, "name": "Science Fiction"}]	Major Bill Cage is an officer who has never seen a day of combat when he is unceremoniously demoted and dropped into combat. Cage is killed within minutes, managing to take an alpha alien down with him. He awakens back at the beginning of the same day and is forced to fight and die again... and again - as physical contact with the alien has thrown him into a time loop.	Edge of Tomorrow	https://image.tmdb.org/t/p/w780/uUHvlkLavotfGsNtosDy8ShsIYF.jpg	https://image.tmdb.org/t/p/w1280/auZIuHEUec5tBTns3tCRXfayxZq.jpg	2020-12-18 16:59:26.688097
335970	107	[{"id": 35, "name": "Comedy"}]	When happy family man Joe Dirt finds himself transported to the recent past, he begins an epic journey to get back to his loved ones in the present.	Joe Dirt 2: Beautiful Loser	https://image.tmdb.org/t/p/w780/nde744Wjaj11BXA4npXcByLDMkw.jpg	https://image.tmdb.org/t/p/w1280/fv2gE7zmROZcHt5MtifYSr43E6U.jpg	2020-12-18 18:16:37.511088
11104	103	[{"id": 18, "name": "Drama"}, {"id": 35, "name": "Comedy"}, {"id": 10749, "name": "Romance"}]	Two melancholic Hong Kong policemen fall in love: one with a mysterious underworld figure, the other with a beautiful and ethereal server at a late-night restaurant he frequents.	Chungking Express	https://image.tmdb.org/t/p/w780/43I9DcNoCzpyzK8JCkJYpHqHqGG.jpg	https://image.tmdb.org/t/p/w1280/i4m14DMv0JG4AOH6sP7Pes87A9x.jpg	2020-12-19 16:39:33.462319
33591	94	[{"id": 35, "name": "Comedy"}, {"id": 18, "name": "Drama"}]	At a small border-post on the Yugoslav-Albanian border, yet another generation of soldiers suffering the usual amount of boredom awaits the end of their service, counting days to the moment when they should take their uniforms off for good. It is the spring of 1987 and the thought never even crosses their mind that they would, in fact, put them back on quite soon and go to war.	The Border Post	https://image.tmdb.org/t/p/w780/yfJ5rIiS8HRSZTJJ2lC2oKsOgSs.jpg	https://image.tmdb.org/t/p/w1280/qPLevjAwozIvKRvLMualxH5ug0c.jpg	2020-12-19 17:37:02.544172
336000	127	[{"id": 18, "name": "Drama"}]	A young girl is raised in a dysfunctional family constantly on the run from the FBI. Living in poverty, she comes of age guided by her drunkard, ingenious father who distracts her with magical stories to keep her mind off the family's dire state, and her selfish, nonconformist mother who has no intention of raising a family, along with her younger brother and sister, and her other older sister. Together, they fend for each other as they mature in an unorthodox journey that is their family life.	The Glass Castle	https://image.tmdb.org/t/p/w780/d5fLQ9ZMa1jZ2mODCv5lOWJDugX.jpg	https://image.tmdb.org/t/p/w1280/mIaR9Wno6FhBLCqoICe09PUFnYu.jpg	2020-12-19 17:37:32.842485
579400	109	[{"id": 18, "name": "Drama"}, {"id": 10402, "name": "Music"}]	David Bowie went to America for the first time to promote his third album, The Man Who Sold the World. There, he embarked on a coast-to-coast publicity tour. During this tour, Bowie came up with the idea of his iconic Ziggy Stardust character, inspired by artists like Iggy Pop and Lou Reed.	Stardust	https://image.tmdb.org/t/p/w780/woOQx1s4mNVAprRpky3ntRgdlf4.jpg	https://image.tmdb.org/t/p/w1280/cfCEAkvTS49uOxw23qvX3GxNyv9.jpg	2020-12-19 18:14:38.474675
336016	94	[{"id": 10749, "name": "Romance"}, {"id": 18, "name": "Drama"}]	The story of one man not only battling the bottle, but the city that won’t let him put it down.	Ruben Guthrie	https://image.tmdb.org/t/p/w780/4A1j72rWGC01aajRB58n8bN3JHd.jpg	https://image.tmdb.org/t/p/w1280/ujV9zhJc5N4x3XhEkCa3jBlhUBT.jpg	2020-12-19 17:41:20.725458
336082	138	[{"id": 28, "name": "Action"}, {"id": 80, "name": "Crime"}, {"id": 35, "name": "Comedy"}]	A conman faces his biggest threat when he is in urgent need for a lump sum and a policeman is after him to catch him red handed.	Dohchay	https://image.tmdb.org/t/p/w780/yBz390NbT9rAPZiXoWZ6hw7b95.jpg	https://image.tmdb.org/t/p/w1280/A2TI3LajhDZlBkuUIkUMT6ZOGLQ.jpg	2020-12-19 17:47:05.366544
90812	91	[{"id": 37, "name": "Western"}]	Four people are killed in a saloon hold-up. The townspeople pin the murders on local no-count black sheep Chester Conway. Lawyer Jeff Plummer and prostitute Polly Winters don't believe that Chester is guilty of these crimes, so they hire smooth and suave gunman Silver to prove Chester's innocence and find the real killers.	The Price of Death	https://image.tmdb.org/t/p/w780/i2Mw15QkyFTeH79iXvDBbL0RmXn.jpg	https://image.tmdb.org/t/p/w1280/uPDRXrFw1spcshUKIT5apDfnDN6.jpg	2020-12-19 17:51:05.599012
560144	110	[{"id": 878, "name": "Science Fiction"}, {"id": 28, "name": "Action"}]	When a virus threatens to turn the now earth-dwelling friendly alien hybrids against humans, Captain Rose Corley must lead a team of elite mercenaries on a mission to the alien world in order to save what's left of humanity.	Skylines	https://image.tmdb.org/t/p/w780/ewMNLXgDyiyaBGdCzQqCF8hKWy2.jpg	https://image.tmdb.org/t/p/w1280/3WQqRrrctYQZC1Ub7OhI8BybScM.jpg	2020-12-19 18:04:44.044796
632322	93	[{"id": 18, "name": "Drama"}, {"id": 10749, "name": "Romance"}]	A couple's wedding plans are thrown off course when the groom is diagnosed with liver cancer.	All My Life	https://image.tmdb.org/t/p/w780/xoKZ4ZkVApcTaTYlGoZ3J8xcIzG.jpg	https://image.tmdb.org/t/p/w1280/7Gzsn4yiwMSXvYcbWXsoDhq8QO2.jpg	2020-12-19 18:05:32.233484
527400	94	[{"id": 14, "name": "Fantasy"}, {"id": 12, "name": "Adventure"}, {"id": 18, "name": "Drama"}]	Before Alice went to Wonderland, and before Peter became Pan, they were brother and sister. When their eldest brother dies in a tragic accident, they each seek to save their parents from their downward spirals of despair until finally they are forced to choose between home and imagination, setting the stage for their iconic journeys into Wonderland and Neverland.	Come Away	https://image.tmdb.org/t/p/w780/vwa0DgR2tHMouIDTJWje2k7Pp30.jpg	https://image.tmdb.org/t/p/w1280/nfBT7RR8kYFBORhVhcCqk5T0ZiX.jpg	2020-12-19 18:07:07.251645
464052	151	[{"id": 14, "name": "Fantasy"}, {"id": 28, "name": "Action"}, {"id": 12, "name": "Adventure"}]	Wonder Woman comes into conflict with the Soviet Union during the Cold War in the 1980s and finds a formidable foe by the name of the Cheetah.	Wonder Woman 1984	https://image.tmdb.org/t/p/w780/di1bCAfGoJ0BzNEavLsPyxQ2AaB.jpg	https://image.tmdb.org/t/p/w1280/srYya1ZlI97Au4jUYAktDe3avyA.jpg	2020-12-19 18:09:13.821399
400160	95	[{"id": 16, "name": "Animation"}, {"id": 14, "name": "Fantasy"}, {"id": 12, "name": "Adventure"}, {"id": 35, "name": "Comedy"}, {"id": 10751, "name": "Family"}]	When his best friend Gary is suddenly snatched away, SpongeBob takes Patrick on a madcap mission far beyond Bikini Bottom to save their pink-shelled pal.	The SpongeBob Movie: Sponge on the Run	https://image.tmdb.org/t/p/w780/jlJ8nDhMhCYJuzOw3f52CP1W8MW.jpg	https://image.tmdb.org/t/p/w1280/wu1uilmhM4TdluKi2ytfz8gidHf.jpg	2020-12-19 18:10:20.759431
413518	125	[{"id": 14, "name": "Fantasy"}, {"id": 10751, "name": "Family"}, {"id": 12, "name": "Adventure"}, {"id": 18, "name": "Drama"}]	In this live-action adaptation of the beloved fairytale, old woodcarver Geppetto fashions a wooden puppet, Pinocchio, who magically comes to life. Pinocchio longs for adventure and is easily led astray, encountering magical beasts, fantastical spectacles, while making friends and foes along his journey. However, his dream is to become a real boy, which can only come true if he finally changes his ways.	Pinocchio	https://image.tmdb.org/t/p/w780/4w1ItwCJCTtSi9nPfJC1vU6NIVg.jpg	https://image.tmdb.org/t/p/w1280/AdqOBPw4PdtzOcfEuQuZ8MNeTKb.jpg	2020-12-19 18:10:59.835674
582014	113	[{"id": 53, "name": "Thriller"}, {"id": 80, "name": "Crime"}, {"id": 18, "name": "Drama"}]	A young woman haunted by a tragedy in her past takes revenge on the predatory men unlucky enough to cross her path.	Promising Young Woman	https://image.tmdb.org/t/p/w780/cjzU4g6SlScnP4MdkleyI25KGlR.jpg	https://image.tmdb.org/t/p/w1280/kAXN6HfoHcGqTGX9H6K2P77ESBp.jpg	2020-12-19 18:11:42.434134
766208	114	[{"id": 12, "name": "Adventure"}]	Set in 1869, two children receive a mysterious game after their father goes missing in the jungles of Africa. They unravel both the secret of their father’s disappearance and the origin of Jumanji.  See how it all began.	Jumanji: Level One	https://image.tmdb.org/t/p/w780/mI7sIBqIsCsTjLvuiVVTfvW3FLU.jpg	https://image.tmdb.org/t/p/w1280/mTW5ssHIgGvGzAaOJmyxmuHd62j.jpg	2020-12-19 18:12:24.748671
581032	118	[{"id": 18, "name": "Drama"}, {"id": 37, "name": "Western"}]	A Texan traveling across the wild West bringing the news of the world to local townspeople, agrees to help rescue a young girl who was kidnapped.	News of the World	https://image.tmdb.org/t/p/w780/fYQCgVRsQTEfUrP7cW5iAFVYOlh.jpg	https://image.tmdb.org/t/p/w1280/ugoims6PfRgcAcIgTRoK2uvjhOu.jpg	2020-12-19 18:12:58.579544
765123	105	[{"id": 35, "name": "Comedy"}, {"id": 80, "name": "Crime"}, {"id": 53, "name": "Thriller"}]	A man foils an attempted murder, then flees the crew of would-be killers along with their intended target as a woman he's just met tries to find him.	Christmas Crossfire	https://image.tmdb.org/t/p/w780/ajKpYK7XdzIYjy9Uy8nkgRboKyv.jpg	https://image.tmdb.org/t/p/w1280/zMcEalkxEiRjvmijliLBk0sYern.jpg	2020-12-19 18:20:43.554953
590706	102	[{"id": 28, "name": "Action"}, {"id": 14, "name": "Fantasy"}, {"id": 878, "name": "Science Fiction"}]	Every six years, an ancient order of jiu-jitsu fighters joins forces to battle a vicious race of alien invaders. But when a celebrated war hero goes down in defeat, the fate of the planet and mankind hangs in the balance.	Jiu Jitsu	https://image.tmdb.org/t/p/w780/eLT8Cu357VOwBVTitkmlDEg32Fs.jpg	https://image.tmdb.org/t/p/w1280/jeAQdDX9nguP6YOX6QSWKDPkbBo.jpg	2020-12-19 18:21:06.716494
602211	100	[{"id": 28, "name": "Action"}, {"id": 35, "name": "Comedy"}, {"id": 14, "name": "Fantasy"}]	A rowdy, unorthodox Santa Claus is fighting to save his declining business. Meanwhile, Billy, a neglected and precocious 12 year old, hires a hit man to kill Santa after receiving a lump of coal in his stocking.	Fatman	https://image.tmdb.org/t/p/w780/4n8QNNdk4BOX9Dslfbz5Dy6j1HK.jpg	https://image.tmdb.org/t/p/w1280/ckfwfLkl0CkafTasoRw5FILhZAS.jpg	2020-12-19 18:22:06.01685
529203	95	[{"id": 12, "name": "Adventure"}, {"id": 14, "name": "Fantasy"}, {"id": 10751, "name": "Family"}, {"id": 16, "name": "Animation"}]	After leaving their cave, the Croods encounter their biggest threat since leaving: another family called the Bettermans, who claim and show to be better and evolved. Grug grows suspicious of the Betterman parents, Phil and Hope,  as they secretly plan to break up his daughter Eep with her loving boyfriend Guy to ensure that their daughter Dawn has a loving and smart partner to protect her.	The Croods: A New Age	https://image.tmdb.org/t/p/w780/tK1zy5BsCt1J4OzoDicXmr0UTFH.jpg	https://image.tmdb.org/t/p/w1280/cjaOSjsjV6cl3uXdJqimktT880L.jpg	2020-12-19 18:22:41.008942
553604	98	[{"id": 28, "name": "Action"}, {"id": 53, "name": "Thriller"}, {"id": 80, "name": "Crime"}, {"id": 18, "name": "Drama"}]	A bank robber tries to turn himself in because he's falling in love and wants to live an honest life...but when he realizes the Feds are more corrupt than him, he must fight back to clear his name.	Honest Thief	https://image.tmdb.org/t/p/w780/zeD4PabP6099gpE0STWJrJrCBCs.jpg	https://image.tmdb.org/t/p/w1280/tYkMtYPNpUdLdzGDUTC5atyMh9X.jpg	2020-12-19 18:23:34.481439
581392	114	[{"id": 28, "name": "Action"}, {"id": 27, "name": "Horror"}, {"id": 53, "name": "Thriller"}]	A soldier and his team battle hordes of post-apocalyptic zombies in the wastelands of the Korean Peninsula.	Peninsula	https://image.tmdb.org/t/p/w780/sy6DvAu72kjoseZEjocnm2ZZ09i.jpg	https://image.tmdb.org/t/p/w1280/d2UxKyaJ5GgzuHaSsWinFfv3g6L.jpg	2020-12-19 18:24:03.344519
713825	79	[{"id": 28, "name": "Action"}, {"id": 878, "name": "Science Fiction"}]	Unconscious soldiers are dropped into a testing site only to discover their memories have been wiped and that once docile machines are the new intelligence.	Robot Riot	https://image.tmdb.org/t/p/w780/pXv4qbWyj6ycMaWkK2LzlizZQjf.jpg	https://image.tmdb.org/t/p/w1280/tWxCVe4rQZa3BvR3tMT3t74oVTT.jpg	2020-12-19 18:24:28.034095
682377	97	[{"id": 28, "name": "Action"}, {"id": 35, "name": "Comedy"}]	When Anna Wyncomb is introduced to an an underground, all-female fight club in order to turn the mess of her life around, she discovers she is much more personally connected to the history of the club than she could ever imagine.	Chick Fight	https://image.tmdb.org/t/p/w780/4ZocdxnOO6q2UbdKye2wgofLFhB.jpg	https://image.tmdb.org/t/p/w1280/fTDzKoQIh1HeyjfpG5AHMi2jxAJ.jpg	2020-12-19 18:25:44.483052
590995	94	[{"id": 27, "name": "Horror"}, {"id": 18, "name": "Drama"}, {"id": 14, "name": "Fantasy"}]	An eclectic foursome of aspiring teenage witches get more than they bargained for as they lean into their newfound powers.	The Craft: Legacy	https://image.tmdb.org/t/p/w780/lhMIra0pqWNuD6CIXoTmGwZ0EBS.jpg	https://image.tmdb.org/t/p/w1280/lIE7kfdLBRd0KENNtOaIqPPWNqh.jpg	2020-12-19 18:26:22.058843
724989	98	[{"id": 28, "name": "Action"}, {"id": 53, "name": "Thriller"}]	The work of billionaire tech CEO Donovan Chalmers is so valuable that he hires mercenaries to protect it, and a terrorist group kidnaps his daughter just to get it.	Hard Kill	https://image.tmdb.org/t/p/w780/ugZW8ocsrfgI95pnQ7wrmKDxIe.jpg	https://image.tmdb.org/t/p/w1280/86L8wqGMDbwURPni2t7FQ0nDjsH.jpg	2020-12-19 18:26:49.795979
754433	82	[{"id": 12, "name": "Adventure"}, {"id": 16, "name": "Animation"}, {"id": 35, "name": "Comedy"}, {"id": 10751, "name": "Family"}]	Get ready for a big shake-up when misfit bobbleheads take on trashy humans and a slobbery dog who crash their home with plans to swap a new baseball player bobblehead for a valuable one of them. With some guidance from Bobblehead Cher, they find the courage to bobble-up for an outrageous battle of wits and wobble.	Bobbleheads: The Movie	https://image.tmdb.org/t/p/w780/t7gNfiDRZLgNka0Q7hPmRgmxLoG.jpg	https://image.tmdb.org/t/p/w1280/3HPqLM6o9PZHrrasrC9VytFdIGT.jpg	2020-12-19 18:27:11.220119
524047	120	[{"id": 28, "name": "Action"}, {"id": 53, "name": "Thriller"}]	John Garrity, his estranged wife and their young son embark on a perilous journey to find sanctuary as a planet-killing comet hurtles toward Earth. Amid terrifying accounts of cities getting levelled, the Garrity's experience the best and worst in humanity. As the countdown to the global apocalypse approaches zero, their incredible trek culminates in a desperate and last-minute flight to a possible safe haven.	Greenland	https://image.tmdb.org/t/p/w780/bNo2mcvSwIvnx8K6y1euAc1TLVq.jpg	https://image.tmdb.org/t/p/w1280/2Fk3AB8E9dYIBc2ywJkxk8BTyhc.jpg	2020-12-19 18:27:42.105602
662546	113	[{"id": 10751, "name": "Family"}, {"id": 14, "name": "Fantasy"}, {"id": 35, "name": "Comedy"}]	A young and unskilled fairy godmother that ventures out on her own to prove her worth by tracking down a young girl whose request for help was ignored. What she discovers is that the girl has now become a grown woman in need of something very different than a "prince charming."	Godmothered	https://image.tmdb.org/t/p/w780/ir8Qqi90mENhH7CDxEpdeCcm6UL.jpg	https://image.tmdb.org/t/p/w1280/2ltadt0HtHS8qD3xREVds3PDxkP.jpg	2020-12-19 18:28:11.70386
753926	89	[{"id": 27, "name": "Horror"}]	A big family moves into a dusty old house in the snowy woods of Washington with hopes of it being a nice holiday escape. But the kids soon discover a stash of old toys that just so happen to belong to a creepy ghost boy. As stranger and stranger things start to happen, some of the kids begin to sense that something in the house is not quite right…	Toys of Terror	https://image.tmdb.org/t/p/w780/c6hmAgPVXxZHwMHfS9z3W2n9Gz9.jpg	https://image.tmdb.org/t/p/w1280/j6Er72CMHKiZgFr0HBMbuyj7Ssa.jpg	2020-12-19 18:28:58.350681
671039	116	[{"id": 53, "name": "Thriller"}, {"id": 28, "name": "Action"}, {"id": 18, "name": "Drama"}, {"id": 80, "name": "Crime"}]	Caught in the crosshairs of police corruption and Marseille’s warring gangs, a loyal cop must protect his squad by taking matters into his own hands.	Rogue City	https://image.tmdb.org/t/p/w780/9HT9982bzgN5on1sLRmc1GMn6ZC.jpg	https://image.tmdb.org/t/p/w1280/gnf4Cb2rms69QbCnGFJyqwBWsxv.jpg	2020-12-19 18:29:33.739882
568467	118	[{"id": 10749, "name": "Romance"}, {"id": 18, "name": "Drama"}]	In 1840s England, palaeontologist Mary Anning and a young woman sent by her husband to convalesce by the sea develop an intense relationship. Despite the chasm between their social spheres and personalities, Mary and Charlotte discover they can each offer what the other has been searching for: the realisation that they are not alone. It is the beginning of a passionate and all-consuming love affair that will defy all social bounds and alter the course of both lives irrevocably.	Ammonite	https://image.tmdb.org/t/p/w780/5lx4pUHWZoOKJWsVsvurRRNW9FK.jpg	https://image.tmdb.org/t/p/w1280/DpPoSYKlfcHUdOLQNdaUiF7liS.jpg	2020-12-19 18:30:31.0174
458576	104	[{"id": 14, "name": "Fantasy"}, {"id": 28, "name": "Action"}, {"id": 12, "name": "Adventure"}]	A portal transports Lt. Artemis and an elite unit of soldiers to a strange world where powerful monsters rule with deadly ferocity. Faced with relentless danger, the team encounters a mysterious hunter who may be their only hope to find a way home.	Monster Hunter	https://image.tmdb.org/t/p/w780/zO9R7Z6DRDgRO9QVz4lAJg3L15o.jpg	https://image.tmdb.org/t/p/w1280/z8TvnEVRenMSTemxYZwLGqFofgF.jpg	2020-12-19 18:30:55.295772
633908	101	[{"id": 35, "name": "Comedy"}]	The story of a disaffected comedy actress and her ambitious stand-in trading places.	The Stand In	https://image.tmdb.org/t/p/w780/twQeFldoNaDnMYXmZNXpm3NHlhP.jpg	https://image.tmdb.org/t/p/w1280/t4V82jen6LKBjs8WMuMpGxbtFgJ.jpg	2020-12-19 18:31:32.514911
580175	117	[{"id": 18, "name": "Drama"}, {"id": 35, "name": "Comedy"}]	Four high school teachers launch a drinking experiment: upholding a constant low level of intoxication.	Another Round	https://image.tmdb.org/t/p/w780/aDcIt4NHURLKnAEu7gow51Yd00Q.jpg	https://image.tmdb.org/t/p/w1280/a2pPepVPtKY7E4XEkT7W3ZxUOY5.jpg	2020-12-19 18:32:37.188603
592643	117	[{"id": 28, "name": "Action"}, {"id": 18, "name": "Drama"}]	The eldest son of a ruthlessly tough MMA champion must fight his way out of the abusive cycle his father has continued.	Embattled	https://image.tmdb.org/t/p/w780/7Tx14J5al5anC5BCnhy1fegOyxW.jpg	https://image.tmdb.org/t/p/w1280/g8aklDRGzz4xWh9IDJvwDiT7hsv.jpg	2020-12-19 18:34:44.137169
540023	97	[{"id": 18, "name": "Drama"}, {"id": 10749, "name": "Romance"}]	New parents Adrienne and Matteo are forced to reckon with trauma amidst their troubled relationship. They must revisit the memories of their past and unravel haunting truths in order to face their uncertain future.	Wander Darkly	https://image.tmdb.org/t/p/w780/96snLzPYifC4FyL2uOnzo4DPgCv.jpg	https://image.tmdb.org/t/p/w1280/eloKau9wkizru6nLwS6NxPYk5Xc.jpg	2020-12-19 18:35:08.96861
516632	137	[{"id": 80, "name": "Crime"}, {"id": 18, "name": "Drama"}, {"id": 27, "name": "Horror"}]	After a group of teens from a small Midwestern town begin to mysteriously disappear, the locals believe it is the work of an urban legend known as The Empty Man. As a retired cop investigates and struggles to make sense of the stories, he discovers a secretive group and their attempts to summon a horrific, mystical entity, and soon his life—and the lives of those close to him—are in grave danger.	The Empty Man	https://image.tmdb.org/t/p/w780/gBRM1EgfslcxcZCSf6Vp89VYCmP.jpg	https://image.tmdb.org/t/p/w1280/9nm3eQY0FiPL391vlQrr4Q5WC9w.jpg	2020-12-19 18:35:37.616463
650783	105	[{"id": 28, "name": "Action"}, {"id": 35, "name": "Comedy"}, {"id": 80, "name": "Crime"}]	After his latest film bombs, Producer Max Barber creates a new film, all to kill his lead, Duke Montana, in a stunt for insurance. But when Duke is unable to be killed in a basic stunt, Max puts him into more dangerous situations.	The Comeback Trail	https://image.tmdb.org/t/p/w780/1aAJreHMi0eKh0emmMkc7RTovaT.jpg	https://image.tmdb.org/t/p/w1280/kbvdJO4ABoWaGeuiQuqFe0JZSp9.jpg	2020-12-19 18:36:08.050202
558574	94	[{"id": 80, "name": "Crime"}, {"id": 18, "name": "Drama"}, {"id": 28, "name": "Action"}]	Five post grads figure the best way to get back at the unfair economy and live the life they've always wanted is to steal from the rich and give to themselves.	Echo Boomers	https://image.tmdb.org/t/p/w780/nQbd4u1NrvcXUbfnmCQYxkF5GIC.jpg	https://image.tmdb.org/t/p/w1280/A7eqPt8jNich5GGLpfQsjpVPWr3.jpg	2020-12-19 18:36:37.961765
729293	84	[{"id": 80, "name": "Crime"}, {"id": 18, "name": "Drama"}, {"id": 28, "name": "Action"}]	A young man returns to his hometown after years of being gone to get revenge on a gang that ruined his life.	Vigilante	https://image.tmdb.org/t/p/w780/7kxqUdjEZPWu8lIZSJmzsHCF4Pz.jpg	https://image.tmdb.org/t/p/w1280/i7w3h5RX92AKrEpNoE0DQzIfhZ8.jpg	2020-12-19 18:37:06.304038
724089	105	[{"id": 10749, "name": "Romance"}]	Professor Gabriel Emerson finally learns the truth about Julia Mitchell's identity, but his realization comes a moment too late. Julia is done waiting for the well-respected Dante specialist to remember her and wants nothing more to do with him. Can Gabriel win back her heart before she finds love in another's arms?	Gabriel's Inferno Part II	https://image.tmdb.org/t/p/w780/pci1ArYW7oJ2eyTo2NMYEKHHiCP.jpg	https://image.tmdb.org/t/p/w1280/jtAI6OJIWLWiRItNSZoWjrsUtmi.jpg	2020-12-19 18:39:28.981344
696374	122	[{"id": 10749, "name": "Romance"}]	An intriguing and sinful exploration of seduction, forbidden love, and redemption, Gabriel's Inferno is a captivating and wildly passionate tale of one man's escape from his own personal hell as he tries to earn the impossible--forgiveness and love.	Gabriel's Inferno	https://image.tmdb.org/t/p/w780/oyG9TL7FcRP4EZ9Vid6uKzwdndz.jpg	https://image.tmdb.org/t/p/w1280/w2uGvCpMtvRqZg6waC1hvLyZoJa.jpg	2020-12-19 18:40:17.327949
278	142	[{"id": 18, "name": "Drama"}, {"id": 80, "name": "Crime"}]	Framed in the 1940s for the double murder of his wife and her lover, upstanding banker Andy Dufresne begins a new life at the Shawshank prison, where he puts his accounting skills to work for an amoral warden. During his long stretch in prison, Dufresne comes to be admired by the other inmates -- including an older prisoner named Red -- for his integrity and unquenchable sense of hope.	The Shawshank Redemption	https://image.tmdb.org/t/p/w780/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg	https://image.tmdb.org/t/p/w1280/iNh3BivHyg5sQRPP1KOkzguEX0H.jpg	2020-12-19 18:41:36.026219
372058	106	[{"id": 10749, "name": "Romance"}, {"id": 16, "name": "Animation"}, {"id": 18, "name": "Drama"}]	High schoolers Mitsuha and Taki are complete strangers living separate lives. But one night, they suddenly switch places. Mitsuha wakes up in Taki’s body, and he in hers. This bizarre occurrence continues to happen randomly, and the two must adjust their lives around each other.	Your Name.	https://image.tmdb.org/t/p/w780/q719jXXEzOoYaps6babgKnONONX.jpg	https://image.tmdb.org/t/p/w1280/mMtUybQ6hL24FXo0F3Z4j2KG7kZ.jpg	2020-12-19 18:42:04.422476
424	195	[{"id": 18, "name": "Drama"}, {"id": 36, "name": "History"}, {"id": 10752, "name": "War"}]	The true story of how businessman Oskar Schindler saved over a thousand Jewish lives from the Nazis while they worked as slaves in his factory during World War II.	Schindler's List	https://image.tmdb.org/t/p/w780/c8Ass7acuOe4za6DhSattE359gr.jpg	https://image.tmdb.org/t/p/w1280/loRmRzQXZeqG78TqZuyvSlEQfZb.jpg	2020-12-19 18:42:30.860383
238	175	[{"id": 18, "name": "Drama"}, {"id": 80, "name": "Crime"}]	Spanning the years 1945 to 1955, a chronicle of the fictional Italian-American Corleone crime family. When organized crime family patriarch, Vito Corleone barely survives an attempt on his life, his youngest son, Michael steps in to take care of the would-be killers, launching a campaign of bloody revenge.	The Godfather	https://image.tmdb.org/t/p/w780/3bhkrj58Vtu7enYsRolD1fZdja1.jpg	https://image.tmdb.org/t/p/w1280/rSPw7tgCH9c6NqICZef4kZjFOQ5.jpg	2020-12-19 18:42:56.321515
19404	190	[{"id": 35, "name": "Comedy"}, {"id": 18, "name": "Drama"}, {"id": 10749, "name": "Romance"}]	Raj is a rich, carefree, happy-go-lucky second generation NRI. Simran is the daughter of Chaudhary Baldev Singh, who in spite of being an NRI is very strict about adherence to Indian values. Simran has left for India to be married to her childhood fiancé. Raj leaves for India with a mission at his hands, to claim his lady love under the noses of her whole family. Thus begins a saga.	Dilwale Dulhania Le Jayenge	https://image.tmdb.org/t/p/w780/2CAL2433ZeIihfX1Hb2139CX0pW.jpg	https://image.tmdb.org/t/p/w1280/svYzz6A6xleZv5toTLAhigXd1DX.jpg	2020-12-19 18:43:23.231001
240	202	[{"id": 18, "name": "Drama"}, {"id": 80, "name": "Crime"}]	In the continuing saga of the Corleone crime family, a young Vito Corleone grows up in Sicily and in 1910s New York. In the 1950s, Michael Corleone attempts to expand the family business into Las Vegas, Hollywood and Cuba.	The Godfather: Part II	https://image.tmdb.org/t/p/w780/hek3koDUyRQk7FIhPXsa6mT2Zc3.jpg	https://image.tmdb.org/t/p/w1280/poec6RqOKY9iSiIUmfyfPfiLtvB.jpg	2020-12-19 18:43:50.559675
129	125	[{"id": 16, "name": "Animation"}, {"id": 10751, "name": "Family"}, {"id": 14, "name": "Fantasy"}]	A young girl, Chihiro, becomes trapped in a strange new world of spirits. When her parents undergo a mysterious transformation, she must call upon the courage she never knew she had to free her family.	Spirited Away	https://image.tmdb.org/t/p/w780/2TeJfUZMGolfDdW6DKhfIWqvq8y.jpg	https://image.tmdb.org/t/p/w1280/mSDsSDwaP3E7dEfUPWy4J0djt4O.jpg	2020-12-19 18:44:14.189771
496243	133	[{"id": 35, "name": "Comedy"}, {"id": 53, "name": "Thriller"}, {"id": 18, "name": "Drama"}]	All unemployed, Ki-taek's family takes peculiar interest in the wealthy and glamorous Parks for their livelihood until they get entangled in an unexpected incident.	Parasite	https://image.tmdb.org/t/p/w780/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg	https://image.tmdb.org/t/p/w1280/ApiBzeaa95TNYliSbQ8pJv4Fje7.jpg	2020-12-19 18:44:57.665505
497	189	[{"id": 14, "name": "Fantasy"}, {"id": 18, "name": "Drama"}, {"id": 80, "name": "Crime"}]	A supernatural tale set on death row in a Southern prison, where gentle giant John Coffey possesses the mysterious power to heal people's ailments. When the cell block's head guard, Paul Edgecomb, recognizes Coffey's miraculous gift, he tries desperately to help stave off the condemned man's execution.	The Green Mile	https://image.tmdb.org/t/p/w780/velWPhVMQeQKcxggNEU8YmIo52R.jpg	https://image.tmdb.org/t/p/w1280/xMIyotorUv2Yz7zpQz2QYc8wkWB.jpg	2020-12-19 18:45:22.482607
630566	121	[{"id": 10402, "name": "Music"}, {"id": 18, "name": "Drama"}, {"id": 10749, "name": "Romance"}]	Young musician Zach Sobiech discovers his cancer has spread, leaving him just a few months to live. With limited time, he follows his dream and makes an album, unaware that it will soon be a viral music phenomenon.	Clouds	https://image.tmdb.org/t/p/w780/2YvT3pdGngzpbAuxamTz4ZlabnT.jpg	https://image.tmdb.org/t/p/w1280/bx326cwBtDsfDcnTgFlK5dXkyaC.jpg	2020-12-19 18:46:10.843981
556574	160	[{"id": 36, "name": "History"}, {"id": 10402, "name": "Music"}, {"id": 18, "name": "Drama"}]	Presenting the tale of American founding father Alexander Hamilton, this filmed version of the original Broadway smash hit is the story of America then, told by America now.	Hamilton	https://image.tmdb.org/t/p/w780/h1B7tW0t399VDjAcWJh8m87469b.jpg	https://image.tmdb.org/t/p/w1280/uWVkEo9PWHu9algZsiLPi6sRU64.jpg	2020-12-19 18:46:36.777348
592350	104	[{"id": 16, "name": "Animation"}, {"id": 28, "name": "Action"}, {"id": 35, "name": "Comedy"}, {"id": 14, "name": "Fantasy"}, {"id": 12, "name": "Adventure"}]	Class 1-A visits Nabu Island where they finally get to do some real hero work. The place is so peaceful that it's more like a vacation … until they're attacked by a villain with an unfathomable Quirk! His power is eerily familiar, and it looks like Shigaraki had a hand in the plan. But with All Might retired and citizens' lives on the line, there's no time for questions. Deku and his friends are the next generation of heroes, and they're the island's only hope.	My Hero Academia: Heroes Rising	https://image.tmdb.org/t/p/w780/zGVbrulkupqpbwgiNedkJPyQum4.jpg	https://image.tmdb.org/t/p/w1280/9guoVF7zayiiUq5ulKQpt375VIy.jpg	2020-12-19 18:47:10.340717
680	154	[{"id": 53, "name": "Thriller"}, {"id": 80, "name": "Crime"}]	A burger-loving hit man, his philosophical partner, a drug-addled gangster's moll and a washed-up boxer converge in this sprawling, comedic crime caper. Their adventures unfurl in three stories that ingeniously trip back and forth in time.	Pulp Fiction	https://image.tmdb.org/t/p/w780/dRZpdpKLgN9nk57zggJCs1TjJb4.jpg	https://image.tmdb.org/t/p/w1280/w7RDIgQM6bLT7JXtH4iUQd3Iwxm.jpg	2020-12-19 18:47:44.378622
637	116	[{"id": 35, "name": "Comedy"}, {"id": 18, "name": "Drama"}]	A touching story of an Italian book seller of Jewish ancestry who lives in his own little fairy tale. His creative and happy life would come to an abrupt halt when his entire family is deported to a concentration camp during World War II. While locked up he tries to convince his son that the whole thing is just a game.	Life Is Beautiful	https://image.tmdb.org/t/p/w780/74hLDKjD5aGYOotO6esUVaeISa2.jpg	https://image.tmdb.org/t/p/w1280/6aNKD81RHR1DqUUa8kOZ1TBY1Lp.jpg	2020-12-19 18:48:09.230831
122	201	[{"id": 12, "name": "Adventure"}, {"id": 14, "name": "Fantasy"}, {"id": 28, "name": "Action"}]	Aragorn is revealed as the heir to the ancient kings as he, Gandalf and the other members of the broken fellowship struggle to save Gondor from Sauron's forces. Meanwhile, Frodo and Sam take the ring closer to the heart of Mordor, the dark lord's realm.	The Lord of the Rings: The Return of the King	https://image.tmdb.org/t/p/w780/rCzpDGLbOoPwLjy3OAm5NUPOTrC.jpg	https://image.tmdb.org/t/p/w1280/lXhgCODAbBXL5buk9yEmTpOoOgR.jpg	2020-12-19 18:48:32.057213
311	229	[{"id": 18, "name": "Drama"}, {"id": 80, "name": "Crime"}]	A former Prohibition-era Jewish gangster returns to the Lower East Side of Manhattan over thirty years later, where he once again must confront the ghosts and regrets of his old life.	Once Upon a Time in America	https://image.tmdb.org/t/p/w780/i0enkzsL5dPeneWnjl1fCWm6L7k.jpg	https://image.tmdb.org/t/p/w1280/rO4pfAIIrt3N905wTTe2HrH3uUv.jpg	2020-12-19 18:48:52.475277
155	152	[{"id": 18, "name": "Drama"}, {"id": 28, "name": "Action"}, {"id": 80, "name": "Crime"}, {"id": 53, "name": "Thriller"}]	Batman raises the stakes in his war on crime. With the help of Lt. Jim Gordon and District Attorney Harvey Dent, Batman sets out to dismantle the remaining criminal organizations that plague the streets. The partnership proves to be effective, but they soon find themselves prey to a reign of chaos unleashed by a rising criminal mastermind known to the terrified citizens of Gotham as the Joker.	The Dark Knight	https://image.tmdb.org/t/p/w780/qJ2tW6WMUDux911r6m7haRef0WH.jpg	https://image.tmdb.org/t/p/w1280/hkBaDkMWbLaf8B1lsWsKX7Ew3Xq.jpg	2020-12-19 18:49:33.279164
769	145	[{"id": 18, "name": "Drama"}, {"id": 80, "name": "Crime"}]	The true story of Henry Hill, a half-Irish, half-Sicilian Brooklyn kid who is adopted by neighbourhood gangsters at an early age and climbs the ranks of a Mafia family under the guidance of Jimmy Conway.	GoodFellas	https://image.tmdb.org/t/p/w780/6QMSLvU5ziIL2T6VrkaKzN2YkxK.jpg	https://image.tmdb.org/t/p/w1280/chrngg9mjM6tSU3BF9VHITgn1Ke.jpg	2020-12-19 18:50:10.029264
11216	124	[{"id": 18, "name": "Drama"}, {"id": 10749, "name": "Romance"}]	A filmmaker recalls his childhood, when he fell in love with the movies at his village's theater and formed a deep friendship with the theater's projectionist.	Cinema Paradiso	https://image.tmdb.org/t/p/w780/8SRUfRUi6x4O68n0VCbDNRa6iGL.jpg	https://image.tmdb.org/t/p/w1280/zoVeIgKzGJzpdG6Gwnr7iOYfIMU.jpg	2020-12-19 18:50:41.114533
550	139	[{"id": 18, "name": "Drama"}]	A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy. Their concept catches on, with underground "fight clubs" forming in every town, until an eccentric gets in the way and ignites an out-of-control spiral toward oblivion.	Fight Club	https://image.tmdb.org/t/p/w780/bptfVGEQuv6vDTIMVCHjJ9Dz8PX.jpg	https://image.tmdb.org/t/p/w1280/52AfXWuXCHn3UjD17rBruA9f5qb.jpg	2020-12-19 18:59:00.948466
12	100	[{"id": 16, "name": "Animation"}, {"id": 10751, "name": "Family"}]	Nemo, an adventurous young clownfish, is unexpectedly taken from his Great Barrier Reef home to a dentist's office aquarium. It's up to his worrisome father Marlin and a friendly but forgetful fish Dory to bring Nemo home -- meeting vegetarian sharks, surfer dude turtles, hypnotic jellyfish, hungry seagulls, and more along the way.	Finding Nemo	https://image.tmdb.org/t/p/w780/eHuGQ10FUzK1mdOY69wF5pGgEf5.jpg	https://image.tmdb.org/t/p/w1280/dFYguAfeVt19qAbzJ5mArn7DEJw.jpg	2020-12-19 18:51:15.018803
389	97	[{"id": 18, "name": "Drama"}]	The defense and the prosecution have rested and the jury is filing into the jury room to decide if a young Spanish-American is guilty or innocent of murdering his father. What begins as an open and shut case soon becomes a mini-drama of each of the jurors' prejudices and preconceptions about the trial, the accused, and each other.	12 Angry Men	https://image.tmdb.org/t/p/w780/ppd84D2i9W8jXmsyInGyihiSyqz.jpg	https://image.tmdb.org/t/p/w1280/qqHQsStV6exghCM7zbObuYBiYxw.jpg	2020-12-19 18:53:32.809815
13	142	[{"id": 35, "name": "Comedy"}, {"id": 18, "name": "Drama"}, {"id": 10749, "name": "Romance"}]	A man with a low IQ has accomplished great things in his life and been present during significant historic events—in each case, far exceeding what anyone imagined he could do. But despite all he has achieved, his one true love eludes him.	Forrest Gump	https://image.tmdb.org/t/p/w780/h5J4W4veyxMXDMjeNxZI46TsHOb.jpg	https://image.tmdb.org/t/p/w1280/7c9UVPPiTPltouxRVY6N9uugaVA.jpg	2020-12-19 18:54:10.718023
429	161	[{"id": 37, "name": "Western"}]	While the Civil War rages between the Union and the Confederacy, three men – a quiet loner, a ruthless hit man and a Mexican bandit – comb the American Southwest in search of a strongbox containing $200,000 in stolen gold.	The Good, the Bad and the Ugly	https://image.tmdb.org/t/p/w780/eWivEg4ugIMAd7d4uWI37b17Cgj.jpg	https://image.tmdb.org/t/p/w1280/1IBOXagfmwTvhb8prIfRvt89ePs.jpg	2020-12-19 18:55:11.17108
537061	82	[{"id": 16, "name": "Animation"}, {"id": 12, "name": "Adventure"}, {"id": 35, "name": "Comedy"}, {"id": 10751, "name": "Family"}, {"id": 14, "name": "Fantasy"}, {"id": 10402, "name": "Music"}, {"id": 28, "name": "Action"}, {"id": 18, "name": "Drama"}]	Two years after the events of "Change Your Mind", Steven (now 16 years old) and his friends are ready to enjoy the rest of their lives peacefully. However, all of that changes when a new sinister Gem arrives, armed with a giant drill that saps the life force of all living things on Earth. In their biggest challenge ever, the Crystal Gems must work together to save all organic life on Earth within 48 hours.	Steven Universe: The Movie	https://image.tmdb.org/t/p/w780/8mRgpubxHqnqvENK4Bei30xMDvy.jpg	https://image.tmdb.org/t/p/w1280/re3ZvlKJg04iLpLRf1xTKHS2wLU.jpg	2020-12-19 18:56:15.259671
522924	109	[{"id": 35, "name": "Comedy"}, {"id": 18, "name": "Drama"}, {"id": 10749, "name": "Romance"}]	A family dog—with a near-human soul and a philosopher's mind—evaluates his life through the lessons learned by his human owner, a race-car driver.	The Art of Racing in the Rain	https://image.tmdb.org/t/p/w780/mi5VN4ww0JZgRFJIaPxxTGKjUg7.jpg	https://image.tmdb.org/t/p/w1280/6esNUoXh4xQvucB7o7e3TCfjI65.jpg	2020-12-19 18:56:59.146148
346	207	[{"id": 28, "name": "Action"}, {"id": 18, "name": "Drama"}]	A samurai answers a village's request for protection after he falls on hard times. The town needs protection from bandits, so the samurai gathers six others to help him teach the people how to defend themselves, and the villagers provide the soldiers with food. A giant battle occurs when 40 bandits attack the village.	Seven Samurai	https://image.tmdb.org/t/p/w780/1wCRVLGI7SoTOoDRzWlbt2dMDuy.jpg	https://image.tmdb.org/t/p/w1280/sJNNMCc6B7KZIY3LH3JMYJJNH5j.jpg	2020-12-19 18:57:49.849285
510	133	[{"id": 18, "name": "Drama"}]	While serving time for insanity at a state mental hospital, implacable rabble-rouser, Randle Patrick McMurphy, inspires his fellow patients to rebel against the authoritarian rule of head nurse, Mildred Ratched.	One Flew Over the Cuckoo's Nest	https://image.tmdb.org/t/p/w780/3jcbDmRFiQ83drXNOvRDeKHxS0C.jpg	https://image.tmdb.org/t/p/w1280/3KwAmIKMaDcBMonF5wmyNTL0SR6.jpg	2020-12-19 18:58:14.652389
598	130	[{"id": 18, "name": "Drama"}, {"id": 80, "name": "Crime"}]	Buscapé was raised in a very violent environment. Despite the feeling that all odds were against him, he finds out that life can be seen with other eyes...	City of God	https://image.tmdb.org/t/p/w780/k7eYdWvhYQyRQoU2TB2A2Xu2TfD.jpg	https://image.tmdb.org/t/p/w1280/194dso1hBwQEgIU3fgS7mXHtFAj.jpg	2020-12-19 18:58:36.835726
539	109	[{"id": 27, "name": "Horror"}, {"id": 18, "name": "Drama"}, {"id": 53, "name": "Thriller"}]	When larcenous real estate clerk Marion Crane goes on the lam with a wad of cash and hopes of starting a new life, she ends up at the notorious Bates Motel, where manager Norman Bates cares for his housebound mother.	Psycho	https://image.tmdb.org/t/p/w780/nR4LD4ZJg2n6LZQpcOrLFdMq0cD.jpg	https://image.tmdb.org/t/p/w1280/kZGaVeXSkkvrpMYvD97sxHj291k.jpg	2020-12-19 18:59:24.464888
324857	117	[{"id": 28, "name": "Action"}, {"id": 12, "name": "Adventure"}, {"id": 16, "name": "Animation"}, {"id": 878, "name": "Science Fiction"}, {"id": 35, "name": "Comedy"}]	Miles Morales is juggling his life between being a high school student and being a spider-man. When Wilson "Kingpin" Fisk uses a super collider, others from across the Spider-Verse are transported to this dimension.	Spider-Man: Into the Spider-Verse	https://image.tmdb.org/t/p/w780/iiZZdoQBEYBv6id8su7ImL0oCbD.jpg	https://image.tmdb.org/t/p/w1280/aUVCJ0HkcJIBrTJYPnTXta8h9Co.jpg	2020-12-19 19:00:38.712206
618344	90	[{"id": 16, "name": "Animation"}, {"id": 28, "name": "Action"}, {"id": 12, "name": "Adventure"}, {"id": 14, "name": "Fantasy"}, {"id": 878, "name": "Science Fiction"}]	Earth is decimated after intergalactic tyrant Darkseid has devastated the Justice League in a poorly executed war by the DC Super Heroes. Now the remaining bastions of good – the Justice League, Teen Titans, Suicide Squad and assorted others – must regroup, strategize and take the war to Darkseid in order to save the planet and its surviving inhabitants.	Justice League Dark: Apokolips War	https://image.tmdb.org/t/p/w780/c01Y4suApJ1Wic2xLmaq1QYcfoZ.jpg	https://image.tmdb.org/t/p/w1280/sQkRiQo3nLrQYMXZodDjNUJKHZV.jpg	2020-12-19 19:01:25.116051
40096	104	[{"id": 12, "name": "Adventure"}, {"id": 35, "name": "Comedy"}]	The lively Jack the Cricket and the sly Chicó are poor guys living in the hinterland who cheat a bunch of people in a small in Northeastern Brazil. When they die, they have to be judged by Christ, the Devil and the Virgin Mary before they are admitted to paradise.	A Dog's Will	https://image.tmdb.org/t/p/w780/m8eFedsS7vQCZCS8WGp5n1bVD0q.jpg	https://image.tmdb.org/t/p/w1280/alQqTpmEkxSLgajfEYTsTH6nAKB.jpg	2020-12-19 19:01:56.037571
4935	119	[{"id": 14, "name": "Fantasy"}, {"id": 16, "name": "Animation"}, {"id": 12, "name": "Adventure"}]	When Sophie, a shy young woman, is cursed with an old body by a spiteful witch, her only chance of breaking the spell lies with a self-indulgent yet insecure young wizard and his companions in his legged, walking castle.	Howl's Moving Castle	https://image.tmdb.org/t/p/w780/TkTPELv4kC3u1lkloush8skOjE.jpg	https://image.tmdb.org/t/p/w1280/vwBa7djy1oxfxUjc7YtVgGNsjrT.jpg	2020-12-19 19:02:19.792695
378064	130	[{"id": 16, "name": "Animation"}, {"id": 18, "name": "Drama"}, {"id": 10749, "name": "Romance"}]	Shouya Ishida starts bullying the new girl in class, Shouko Nishimiya, because she is deaf. But as the teasing continues, the rest of the class starts to turn on Shouya for his lack of compassion. When they leave elementary school, Shouko and Shouya do not speak to each other again... until an older, wiser Shouya, tormented by his past behaviour, decides he must see Shouko once more. He wants to atone for his sins, but is it already too late...?	A Silent Voice	https://image.tmdb.org/t/p/w780/drlyoSKDOPnxzJFrRWGqzDsyJvR.jpg	https://image.tmdb.org/t/p/w1280/q5HZvtyqG8Vz39Ee9uTQbLeEml.jpg	2020-12-19 19:03:09.098442
599	110	[{"id": 18, "name": "Drama"}]	A hack screenwriter writes a screenplay for a former silent film star who has faded into Hollywood obscurity.	Sunset Boulevard	https://image.tmdb.org/t/p/w780/zt8aQ6ksqK6p1AopC5zVTDS9pKT.jpg	https://image.tmdb.org/t/p/w1280/vljrgvuOILOqycL3YRzcjQRxPOm.jpg	2020-12-19 19:03:37.37476
914	125	[{"id": 35, "name": "Comedy"}]	Dictator Adenoid Hynkel tries to expand his empire while a poor Jewish barber tries to avoid persecution from Hynkel's regime.	The Great Dictator	https://image.tmdb.org/t/p/w780/1QpO9wo7JWecZ4NiBuu625FiY1j.jpg	https://image.tmdb.org/t/p/w1280/7jTgJ24UPkWeb5zzH7ihs554xVy.jpg	2020-12-19 19:04:16.108649
12477	89	[{"id": 16, "name": "Animation"}, {"id": 18, "name": "Drama"}, {"id": 10752, "name": "War"}]	In the final months of World War II, 14-year-old Seita and his sister Setsuko are orphaned when their mother is killed during an air raid in Kobe, Japan. After a falling out with their aunt, they move into an abandoned bomb shelter. With no surviving relatives and their emergency rations depleted, Seita and Setsuko struggle to survive.	Grave of the Fireflies	https://image.tmdb.org/t/p/w780/wcNkHDbyc290hcWk7KXbBZUuXpq.jpg	https://image.tmdb.org/t/p/w1280/tDFvXn4tane9lUvFAFAUkMylwSr.jpg	2020-12-19 19:04:39.041368
244786	107	[{"id": 18, "name": "Drama"}, {"id": 10402, "name": "Music"}]	Under the direction of a ruthless instructor, a talented young drummer begins to pursue perfection at any cost, even his humanity.	Whiplash	https://image.tmdb.org/t/p/w780/6uSPcdGNA2A6vJmCagXkvnutegs.jpg	https://image.tmdb.org/t/p/w1280/fRGxZuo7jJUWQsVg9PREb98Aclp.jpg	2020-12-19 19:05:43.336777
164558	92	[{"id": 99, "name": "Documentary"}, {"id": 10402, "name": "Music"}]	Go behind the scenes during One Directions sell out "Take Me Home" tour and experience life on the road.	One Direction: This Is Us	https://image.tmdb.org/t/p/w780/b720e7DW3nqRJaUH9xpTtvYhnUj.jpg	https://image.tmdb.org/t/p/w1280/azAkT1jCMwh4FgzDPJzYCsqnGil.jpg	2020-12-19 19:06:42.071835
73	119	[{"id": 18, "name": "Drama"}]	Derek Vineyard is paroled after serving 3 years in prison for killing two African-American men. Through his brother, Danny Vineyard's narration, we learn that before going to prison, Derek was a skinhead and the leader of a violent white supremacist gang that committed acts of racial crime throughout L.A. and his actions greatly influenced Danny. Reformed and fresh out of prison, Derek severs contact with the gang and becomes determined to keep Danny from going down the same violent path as he did.	American History X	https://image.tmdb.org/t/p/w780/c2gsmSQ2Cqv8zosqKOCwRS0GFBS.jpg	https://image.tmdb.org/t/p/w1280/nOO83QWfbRxMdru0vtQ7jGNT5Bq.jpg	2020-12-19 19:07:52.997316
423	150	[{"id": 18, "name": "Drama"}, {"id": 10752, "name": "War"}]	The true story of pianist Władysław Szpilman's experiences in Warsaw during the Nazi occupation. When the Jews of the city find themselves forced into a ghetto, Szpilman finds work playing in a café; and when his family is deported in 1942, he stays behind, works for a while as a laborer, and eventually goes into hiding in the ruins of the war-torn city.	The Pianist	https://image.tmdb.org/t/p/w780/3DzePKMbLMIM636S6syCy3cLPqj.jpg	https://image.tmdb.org/t/p/w1280/A7r8GRpvOojI2Vl5EEJfAIfzCg9.jpg	2020-12-19 19:09:02.306626
476292	115	[{"id": 16, "name": "Animation"}, {"id": 14, "name": "Fantasy"}, {"id": 10749, "name": "Romance"}, {"id": 18, "name": "Drama"}]	A story of encounters and partings interwoven between people; this is a human drama with feelings that touch one's heart gradually, which everyone has experienced at least once.	Maquia: When the Promised Flower Blooms	https://image.tmdb.org/t/p/w780/hL3NqRE2ccR4Y2sYSJTrmalRjrz.jpg	https://image.tmdb.org/t/p/w1280/yjfwNSDljAKsuHwwE34xjlY3tQj.jpg	2020-12-19 19:09:24.513228
3782	143	[{"id": 18, "name": "Drama"}]	Kanji Watanabe is a middle-aged man who has worked in the same monotonous bureaucratic position for decades. Learning he has cancer, he starts to look for the meaning of his life.	Ikiru	https://image.tmdb.org/t/p/w780/dgNTS4EQDDVfkzJI5msKuHu2Ei3.jpg	https://image.tmdb.org/t/p/w1280/5qtOVAcBFogwktkseoZSfZVq6bx.jpg	2020-12-19 19:09:55.465964
1891	124	[{"id": 12, "name": "Adventure"}, {"id": 28, "name": "Action"}, {"id": 878, "name": "Science Fiction"}]	The epic saga continues as Luke Skywalker, in hopes of defeating the evil Galactic Empire, learns the ways of the Jedi from aging master Yoda. But Darth Vader is more determined than ever to capture Luke. Meanwhile, rebel leader Princess Leia, cocky Han Solo, Chewbacca, and droids C-3PO and R2-D2 are thrown into various stages of capture, betrayal and despair.	The Empire Strikes Back	https://image.tmdb.org/t/p/w780/7BuH8itoSrLExs2YZSsM01Qk2no.jpg	https://image.tmdb.org/t/p/w1280/dMZxEdrWIzUmUoOz2zvmFuutbj7.jpg	2020-12-19 19:10:19.751665
18491	87	[{"id": 18, "name": "Drama"}, {"id": 878, "name": "Science Fiction"}, {"id": 16, "name": "Animation"}, {"id": 14, "name": "Fantasy"}, {"id": 28, "name": "Action"}]	The second of two theatrically released follow-ups to the Neon Genesis Evangelion series. Comprising of two alternate episodes which were first intended to take the place of episodes 25 and 26, this finale answers many of the questions surrounding the series, while also opening up some new possibilities.	Neon Genesis Evangelion: The End of Evangelion	https://image.tmdb.org/t/p/w780/m9PTii0XWCIKZBBrCrOn8RLTK0w.jpg	https://image.tmdb.org/t/p/w1280/hyaLMOol8xju70zr5glK6JaprER.jpg	2020-12-19 19:11:03.481173
567	112	[{"id": 53, "name": "Thriller"}, {"id": 9648, "name": "Mystery"}, {"id": 18, "name": "Drama"}]	A wheelchair-bound photographer spies on his neighbors from his apartment window and becomes convinced one of them has committed murder.	Rear Window	https://image.tmdb.org/t/p/w780/qitnZcLP7C9DLRuPpmvZ7GiEjJN.jpg	https://image.tmdb.org/t/p/w1280/zGs5tZOlvc9cprdcU6kDOVNpujf.jpg	2020-12-19 19:11:23.229249
14537	135	[{"id": 28, "name": "Action"}, {"id": 18, "name": "Drama"}, {"id": 36, "name": "History"}]	An unusual request for ritual suicide on a feudal lord's property leads to the unwinding of a greater mystery that challenges the clan's integrity.	Harakiri	https://image.tmdb.org/t/p/w780/fRqVjso3rdEcxZHXWE2xazDAtjI.jpg	https://image.tmdb.org/t/p/w1280/wen5hK2dMgBtFcCrtcn85mDcVAS.jpg	2020-12-19 19:11:46.507888
901	87	[{"id": 35, "name": "Comedy"}, {"id": 18, "name": "Drama"}, {"id": 10749, "name": "Romance"}]	In this sound-era silent film, a tramp falls in love with a beautiful blind flower seller.	City Lights	https://image.tmdb.org/t/p/w780/bXNvzjULc9jrOVhGfjcc64uKZmZ.jpg	https://image.tmdb.org/t/p/w1280/ps82zgSDimvlYps6otcMYshrVyS.jpg	2020-12-19 19:12:09.341134
88013	4	[{"id": 35, "name": "Comedy"}, {"id": 16, "name": "Animation"}]	One night, Arlequin come to see his lover Colombine. But then Pierrot knocks at the door and Colombine and Arlequin hide. Pierrot starts singing but Arlequin scares him and the poor man goes away.	Poor Pierrot	https://image.tmdb.org/t/p/w780/g3uS4J3CGZaO2qgydcsE8iIxZXl.jpg	https://image.tmdb.org/t/p/w1280/ebHWKjdp3VG25mXq0LIVZIu30tZ.jpg	2020-12-20 17:47:27.858741
159896	2	[{"id": 16, "name": "Animation"}]	The film consists of a series of animations on a beach containing two beach huts and a diving board. Two characters play at diving into the water from the diving board and then appear on the beach. The woman begins to play with a small dog and is then joined by a gentleman. The two play around on the beach before getting changed into bathing costumes and going into the water. They bob up and down in the water before swimming out of the scene. Once the couple have gone a man sails out in a boat.	Autour d’une cabine ou Mésaventures d’un copurchic aux bains de mer	https://image.tmdb.org/t/p/w780/AisaWEwgmwy5FyxQbZhl7JQlroz.jpg	https://image.tmdb.org/t/p/w1280/sK6DcIjTloAxIUN86wvPkCVrBzF.jpg	2020-12-20 17:56:09.589312
722396	1	[{"id": 99, "name": "Documentary"}]	The film was about a group of Polish ice skaters at the slide of the Warsaw Ice Skating Society. The film was filmed using a pleograph which was an early type of the movie camera invented by Kazimierz Prószyński.	Skating-rink in the Royal Baths	https://image.tmdb.org/t/p/w780/jwXX00JCo7kiVNZEvj35SSNh6xm.jpg	https://image.tmdb.org/t/p/w1280/tnHVgbEBvz8SB8FWRhTTxSshAFr.jpg	2020-12-20 17:56:50.370492
774	1	[{"id": 99, "name": "Documentary"}]	Working men and women leave through the main gate of the Lumière factory in Lyon, France. Filmed on 22 March 1895, it is often referred to as the first real motion picture ever made, although Louis Le Prince's 1888 Roundhay Garden Scene pre-dated it by seven years.  Three separate versions of this film exist, which differ from one another in numerous ways. The first version features a carriage drawn by one horse, while in the second version the carriage is drawn by two horses, and there is no carriage at all in the third version. The clothing style is also different between the three versions, demonstrating the different seasons in which each was filmed. This film was made in the 35 mm format with an aspect ratio of 1.33:1, and at a speed of 16 frames per second. At that rate, the 17 meters of film length provided a duration of 46 seconds, holding a total of 800 frames.	Workers Leaving the Lumière Factory	https://image.tmdb.org/t/p/w780/zwaMUm6cxmbMIUziIhkqyIoi2LO.jpg	https://image.tmdb.org/t/p/w1280/PikJWvblmySeD8Hq3ITayWDQ68.jpg	2020-12-20 18:00:24.063591
82120	1	[{"id": 35, "name": "Comedy"}]	A gardener is watering his flowers, when a mischievous boy sneaks up behind his back, and puts a foot on the water hose. The gardener is surprised and looks into the nozzle to find out why the water has stopped coming. The boy then lifts his foot from the hose, whereby the water squirts up in the gardener's face. The gardener chases the boy, grips his ear and slaps him in his buttocks. The boy then runs away and the gardener continues his watering. Three separate versions of this film exist, this is the original, filmed by Louis Lumière.	The Sprinkler Sprinkled	https://image.tmdb.org/t/p/w780/5UsXVtEbaL88lxLy9AbfvLlki9T.jpg	https://image.tmdb.org/t/p/w1280/A0hONP6cxTthAsw6IvPMX4Aowkr.jpg	2020-12-20 18:02:29.250264
49278	9	[{"id": 35, "name": "Comedy"}, {"id": 14, "name": "Fantasy"}, {"id": 10749, "name": "Romance"}]	In this film, Méliès concocts a combination fairy- and morality tale about the foolishness of trying to look too deeply into the workings of an unstable and inscrutable universe. At a medieval school, an old astronomer begins to teach a class of young men, all armed with telescopes, about the art of scrutinising an imminent eclipse. When a mechanical clock strikes twelve, all the young men rush to the windows and fix their telescopes on the heavens.	The Eclipse: Courtship of the Sun and Moon	https://image.tmdb.org/t/p/w780/5iOi4ZGBYzfVfkwIEdHHC2eQK8z.jpg	https://image.tmdb.org/t/p/w1280/cchxL8AdKKGGvGgu7YeIiHRHkFF.jpg	2020-12-20 18:20:52.694203
192301	16	[{"id": 10749, "name": "Romance"}, {"id": 18, "name": "Drama"}]	A young woman who works mending fishermen's nets is engaged to be married. But her fiancé has an old love who refuses to let him go. Further, his former girlfriend has a brother who is willing to use violence to protect his sister's honor.	The Mender of Nets	https://image.tmdb.org/t/p/w780/uXR9GEZxeyP59xdXmuqqnyxIZfb.jpg	https://image.tmdb.org/t/p/w1280/rCU9qqP7GzapWMtn8od6gVcmYES.jpg	2020-12-20 18:25:47.837771
671583	96	[{"id": 10751, "name": "Family"}, {"id": 14, "name": "Fantasy"}, {"id": 10770, "name": "TV Movie"}]	Nory and her best friend Reina enter the Sage Academy for Magical Studies, where Nory’s unconventional powers land her in a class for those with wonky, or “upside-down,” magic. Undaunted, Nory sets out to prove that that upside-down magic can be just as powerful as right-side-up.	Upside-Down Magic	https://image.tmdb.org/t/p/w780/h9vTJ78h0SASYUxg4jV0AQ00oF2.jpg	https://image.tmdb.org/t/p/w1280/vam9VHLZl8tqNwkp1zjEAxIOrkk.jpg	2020-12-20 18:30:24.988287
734280	87	[{"id": 10749, "name": "Romance"}, {"id": 35, "name": "Comedy"}, {"id": 10770, "name": "TV Movie"}]	Longtime friends and local radio hosts Maggie and Jack fake it as a couple for their families and listeners in hopes of getting their show syndicated.	Midnight at the Magnolia	https://image.tmdb.org/t/p/w780/fxMdefiLKvapV58pdXYEH6CIBti.jpg	https://image.tmdb.org/t/p/w1280/cIGPPTfxKvoezGB4yxmIqa33ROn.jpg	2020-12-20 18:31:00.165552
677638	69	[{"id": 10751, "name": "Family"}, {"id": 16, "name": "Animation"}, {"id": 12, "name": "Adventure"}, {"id": 35, "name": "Comedy"}, {"id": 10770, "name": "TV Movie"}]	When Grizz, Panda, and Ice Bear's love of food trucks and viral videos get out of hand, the brothers are chased away from their home and embark on a trip to Canada, where they can live in peace.	We Bare Bears: The Movie	https://image.tmdb.org/t/p/w780/kPzcvxBwt7kEISB9O4jJEuBn72t.jpg	https://image.tmdb.org/t/p/w1280/pO1SnM5a1fEsYrFaVZW78Wb0zRJ.jpg	2020-12-20 18:31:56.917968
359983	44	[{"id": 10770, "name": "TV Movie"}, {"id": 16, "name": "Animation"}, {"id": 10751, "name": "Family"}]	Set in the African savannah, the film follows Kion as he assembles the members of the 'Lion Guard'. Throughout the film, the diverse team of young animals will learn how to utilize each of their unique abilities to solve problems and accomplish tasks to maintain balance within the Circle of Life, while also introducing viewers to the vast array of animals that populate the prodigious African landscape.	The Lion Guard: Return of the Roar	https://image.tmdb.org/t/p/w780/duqg6CiSik02nSXjiQHo8TcwY4b.jpg	https://image.tmdb.org/t/p/w1280/poRKW1DNzNXfZQPPSGDVaRcwN7a.jpg	2020-12-20 18:34:32.410935
441168	87	[{"id": 18, "name": "Drama"}, {"id": 10770, "name": "TV Movie"}]	When a change of circumstances leaves Miriam unable to pay her college tuition, she makes a surprising decision: to start performing in adult films, using the pseudonym Belle Knox. Miriam lies to her family and her friends at school, keeping her double life a secret. But soon rumours spread and Miriam becomes the subject of vicious online attacks and unwanted attention. Miriam fights back: she talks to the media, saying her new line of work empowers her as a feminist. But her confident stand has unintended consequences. Miriam is shunned by her conservative family and her colleagues in the adult film world. One impulsive decision has quickly spiralled out of control - and Miriam's problems are just beginning.	From Straight A's to XXX	https://image.tmdb.org/t/p/w780/lm3kQfoyxK1ly4qhGAOyOrCMx6F.jpg	https://image.tmdb.org/t/p/w1280/3uaD05vhpsjiZ9KHpF2TI2GrXON.jpg	2020-12-20 18:36:44.671582
7342	132	[{"id": 10770, "name": "TV Movie"}, {"id": 18, "name": "Drama"}, {"id": 27, "name": "Horror"}]	Carrie White is a lonely and painfully shy teenage girl with telekinetic powers who is slowly pushed to the edge of insanity by frequent bullying from both classmates at her school, and her own religious, but abusive, mother.	Carrie	https://image.tmdb.org/t/p/w780/knjeEeeyIwDkUtZwDfJOcUIuNdB.jpg	https://image.tmdb.org/t/p/w1280/8z5qtVE2N3AuA3bmvIQsI10Wjg8.jpg	2020-12-20 18:37:18.273425
506574	106	[{"id": 10751, "name": "Family"}, {"id": 10770, "name": "TV Movie"}, {"id": 10402, "name": "Music"}, {"id": 12, "name": "Adventure"}, {"id": 14, "name": "Fantasy"}]	The teenagers of Disney's most infamous villains return to the Isle of the Lost to recruit a new batch of villainous offspring to join them at Auradon Prep.	Descendants 3	https://image.tmdb.org/t/p/w780/7IRy0iHdaS0JI3ng4ZYlk5gLSFn.jpg	https://image.tmdb.org/t/p/w1280/iBJCHz6wWgyxbDmUD2Wk5huxbwS.jpg	2020-12-20 18:37:55.124145
523931	90	[{"id": 28, "name": "Action"}, {"id": 878, "name": "Science Fiction"}, {"id": 27, "name": "Horror"}, {"id": 10770, "name": "TV Movie"}]	A military vessel on the search for an unidentified submersible finds themselves face to face with a giant shark, forced to use only what they have on board to defend themselves from the monstrous beast.	Megalodon	https://image.tmdb.org/t/p/w780/hES2eVAbVt08JJTqgu3jmI34Yxx.jpg	https://image.tmdb.org/t/p/w1280/fXFQnOSbybaU9h2kJ3jtRUU4OpA.jpg	2020-12-20 18:38:21.3076
37211	91	[{"id": 16, "name": "Animation"}, {"id": 35, "name": "Comedy"}, {"id": 10751, "name": "Family"}, {"id": 9648, "name": "Mystery"}, {"id": 10770, "name": "TV Movie"}]	Shaggy is turned into a werewolf, and it's up to Scooby, Scrappy and Shaggy's girlfriend to help him win a race against other monsters, and become human again.	Scooby-Doo! and the Reluctant Werewolf	https://image.tmdb.org/t/p/w780/cXUQuHnNBxFSZAmYfogMfrcvMk7.jpg	https://image.tmdb.org/t/p/w1280/yB32nYB9WfXye681xtx3t3aQ6AD.jpg	2020-12-20 18:39:23.108381
134375	87	[{"id": 35, "name": "Comedy"}, {"id": 80, "name": "Crime"}, {"id": 10751, "name": "Family"}, {"id": 10770, "name": "TV Movie"}]	8-year-old Finn is terrified to learn his family is relocating from sunny California to Maine in the scariest house he has ever seen! Convinced that his new house is haunted, Finn sets up a series of elaborate traps to catch the “ghost” in action. Left home alone with his sister while their parents are stranded across town, Finn’s traps catch a new target – a group of thieves who have targeted Finn’s house.	Home Alone: The Holiday Heist	https://image.tmdb.org/t/p/w780/z9hjtl4Phl2n1l4y1IiLUVJtZsz.jpg	https://image.tmdb.org/t/p/w1280/3mO7fimik20gwkVNXNxbi0RY3wg.jpg	2020-12-20 18:40:05.735442
635780	103	[{"id": 10752, "name": "War"}, {"id": 28, "name": "Action"}]	After rescuing Daniel from the terrorist Black Mask Organization, the team uncovers plans for a deadly bomb set to detonate in 36 hours that threatens world order. With no time to recover, Daniel must throw his life back on the line as he and his elite team of soldiers race against time to find the bomb and defeat their enemy once and for all. Outnumbered and overmatched, each soldier must find their inner strength and skill to overcome insurmountable odds.	Rogue Warfare: Death of a Nation	https://image.tmdb.org/t/p/w780/8GVpIEBqlRBvx28G0LfEX0U8D2k.jpg	https://image.tmdb.org/t/p/w1280/iQxJuPqCGOO4Iy3uFbMWCIGHkwE.jpg	2020-12-20 18:48:31.702866
744955	80	[{"id": 10749, "name": "Romance"}, {"id": 10770, "name": "TV Movie"}]	Josie Jennings a celebrated, romantic, 35-year old chef in the city heads home to spend the holidays at the quaint, magical bed and breakfast where she grew up, and where her mother Shannon has just opened a new restaurant. Famous food critic Tanner Rhodes, who has given Josie harsh reviews in the past, comes to town to review the new restaurant and Josie’s Christmas Cuisine. As the holidays unfold, Josie and Tanner get to know each other better, and a romance soon begins to blossom but will Tanner find a way to right his wrongs, write a rave review for the bistro’s delicious cuisine, and win Josie’s heart by Christmas Eve?	Christmas on the Menu	https://image.tmdb.org/t/p/w780/998E0DvDcK3kGO3IJT4WmUVA1Rt.jpg	https://image.tmdb.org/t/p/w1280/dBJqxmM8GOyLfb3I0A1Vry0S81W.jpg	2020-12-20 18:40:32.622375
737780	80	[{"id": 10770, "name": "TV Movie"}, {"id": 10749, "name": "Romance"}]	Former classmates Lina and Max are traveling home for the holidays, until a storm hits and they have to work together to make it home in time, no matter the mode of transportation.	Cross Country Christmas	https://image.tmdb.org/t/p/w780/vy7gKfBQLdVFKtV3cGwQ5rBm5IH.jpg	https://image.tmdb.org/t/p/w1280/xwtacQbIAbeRmTFjFZyTRCAXJVu.jpg	2020-12-20 18:40:59.319056
721656	76	[{"id": 16, "name": "Animation"}, {"id": 10751, "name": "Family"}, {"id": 9648, "name": "Mystery"}, {"id": 35, "name": "Comedy"}, {"id": 80, "name": "Crime"}]	Scooby-Doo and the gang team up with their pals, Bill Nye The Science Guy and Elvira Mistress of the Dark, to solve this mystery of gigantic proportions and save Crystal Cove!	Happy Halloween, Scooby-Doo!	https://image.tmdb.org/t/p/w780/5aL71e0XBgHZ6zdWcWeuEhwD2Gw.jpg	https://image.tmdb.org/t/p/w1280/5gTQmnGYKxDfmUWJ9GUWqrszRxN.jpg	2020-12-20 18:42:59.342286
571384	96	[{"id": 27, "name": "Horror"}, {"id": 9648, "name": "Mystery"}]	A lonely young boy feels different from everyone else. Desperate for a friend, he seeks solace and refuge in his ever-present cell phone and tablet. When a mysterious creature uses the boy’s devices against him to break into our world, his parents must fight to save their son from the monster beyond the screen.	Come Play	https://image.tmdb.org/t/p/w780/e98dJUitAoKLwmzjQ0Yxp1VQrnU.jpg	https://image.tmdb.org/t/p/w1280/gkvOmVXdukAwpG8LjTaHo2l2cWU.jpg	2020-12-20 18:43:19.740771
497582	124	[{"id": 80, "name": "Crime"}, {"id": 18, "name": "Drama"}, {"id": 9648, "name": "Mystery"}]	While searching for her missing mother, intrepid teen Enola Holmes uses her sleuthing skills to outsmart big brother Sherlock and help a runaway lord.	Enola Holmes	https://image.tmdb.org/t/p/w780/riYInlsq2kf1AWoGm80JQW5dLKp.jpg	https://image.tmdb.org/t/p/w1280/kMe4TKMDNXTKptQPAdOF0oZHq3V.jpg	2020-12-20 18:43:41.428675
635237	91	[{"id": 36, "name": "History"}, {"id": 28, "name": "Action"}, {"id": 12, "name": "Adventure"}]	King Arthur returns home after fighting the Roman Empire. His illegitimate son has corrupted the throne of Camelot and King Arthur must reunite with the wizard Merlin and the Knights of the Round Table to fight to get back his crown.	Arthur & Merlin: Knights of Camelot	https://image.tmdb.org/t/p/w780/chGTXsvn53XvEnvsJ9ZD9eiYKx9.jpg	https://image.tmdb.org/t/p/w1280/sFLgXQGrSWxnjmPOpGKPApWNOUH.jpg	2020-12-20 18:45:28.507929
16052	127	[{"id": 10402, "name": "Music"}, {"id": 18, "name": "Drama"}, {"id": 36, "name": "History"}]	In this biographical drama, Selena Quintanilla is born into a musical Mexican-American family in Texas. Her father, Abraham, realizes that his young daughter is talented and begins performing with her at small venues. She finds success and falls for her guitarist, Chris Perez, who draws the ire of her father. Seeking mainstream stardom, Selena begins recording an English-language album which, tragically, she would never complete.	Selena	https://image.tmdb.org/t/p/w780/j8xX3yBAFOayfSaImgLZPnAcdWz.jpg	https://image.tmdb.org/t/p/w1280/kcBlY5FasH8ti150aYExULw53ui.jpg	2020-12-20 18:46:25.534575
554022	110	[{"id": 28, "name": "Action"}, {"id": 12, "name": "Adventure"}, {"id": 10752, "name": "War"}, {"id": 18, "name": "Drama"}]	World War II: Resistance fighters accept a suicide mission to deliver a stolen Nazi submarine carrying atomic uranium. Hunted by Hitler’s army, the crew must outwit the German Navy to bring the cargo safely to America.	Torpedo: U-235	https://image.tmdb.org/t/p/w780/wHuhFcsii1GkKPHVC1wpdvJ9Djs.jpg	https://image.tmdb.org/t/p/w1280/7xiYjuoa5cAjkbJrF7fpfKKYqcf.jpg	2020-12-20 18:48:16.572577
768141	106	[{"id": 10402, "name": "Music"}, {"id": 99, "name": "Documentary"}]	An intimate concert film, in which Taylor Swift performs each song from her album 'folklore' in order, as she reveals the meaning and the stories behind all 17 tracks for the very first time.	Folklore: The Long Pond Studio Sessions	https://image.tmdb.org/t/p/w780/4iroJUn8YuQBekDwGy7r61YHXiu.jpg	https://image.tmdb.org/t/p/w1280/xndolqiw6jMhDDkkw1UPuD1xfrT.jpg	2020-12-20 18:50:27.656676
689249	57	[{"id": 99, "name": "Documentary"}]	A documentary on why and how 'Money Heist' sparked a wave of enthusiasm around the world for a lovable group of thieves and their professor.	Money Heist: The Phenomenon	https://image.tmdb.org/t/p/w780/AboUXTrDWEi0PuZUqaft0iwBTm7.jpg	https://image.tmdb.org/t/p/w1280/ociI5MGQXaJ2u1Fhc6WKNYy9pbn.jpg	2020-12-20 18:50:45.121979
5698	12	[{"id": 80, "name": "Crime"}, {"id": 28, "name": "Action"}, {"id": 37, "name": "Western"}]	The clerk at the train station is assaulted and left tied by four men, then they rob the train threatening the operator. (They) take all the money and shoot a passenger when trying to run away. A little girl discovers the clerk tied and gives notice to the sheriff, who at once goes along with his men hunting the bandits.	The Great Train Robbery	https://image.tmdb.org/t/p/w780/uf7Hr1wuUh4T83Ifg5pVpwTqRdI.jpg	https://image.tmdb.org/t/p/w1280/99uGRUGS2qxNvPARiM8dkuTrUnW.jpg	2020-12-20 18:52:53.598562
167250	14	[{"id": 37, "name": "Western"}]	An Indian village is forced to leave its land by white settlers, and must make a long and weary journey to find a new home. The settlers make one young Indian woman stay behind. This woman is thus separated from her sweetheart, whose elderly father needs his help on the journey ahead	The Redman's View	https://image.tmdb.org/t/p/w780/bkS2O2cn2zjhr58etRV92lju9Ww.jpg	https://image.tmdb.org/t/p/w1280/jYfCSxUGYN9vYiOqAPuIwPjovAv.jpg	2020-12-20 18:55:30.873656
8	5	[{"id": 18, "name": "Drama"}, {"id": 53, "name": "Thriller"}, {"id": 9648, "name": "Mystery"}]	Adipisicing accusamus lorem recusandae perspiciatis neque sequi? Totam nisi obcaecati porro nisi reiciendis, quis Perspiciatis quam reiciendis fuga quisquam unde. Iure quidem quas saepe perferendis adipisci Excepturi in doloribus vitae?	Abc	https://image.tmdb.org/t/p/w780/iiZZdoQBEYBv6id8su7ImL0oCbD.jpg	https://image.tmdb.org/t/p/w1280/aUVCJ0HkcJIBrTJYPnTXta8h9Co.jpg	2020-12-23 02:06:11.460196
\.


--
-- Data for Name: schedules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schedules (id, movie, theater, room, nrow, ncolumn, price, "time", reserved, created_at) FROM stdin;
1	335984	1	10	5	12	50000	2020-11-27 22:20:00	0	2020-12-18 16:13:16.307269
3	335984	1	10	5	12	50000	2020-11-19 17:03:00	0	2020-12-18 17:03:23.736419
4	335984	1	10	5	12	50000	2020-11-18 17:03:00	0	2020-12-18 17:03:51.987713
5	335984	1	10	5	12	50000	2020-12-19 09:08:00	0	2020-12-18 17:08:48.58727
6	646593	1	10	5	12	50000	2020-12-20 08:25:00	0	2020-12-19 16:22:01.981229
14	324857	1	8	6	13	60000	2020-12-23 18:06:00	23	2020-12-20 18:07:01.196815
15	680	1	10	5	10	100000	2021-01-09 02:10:00	0	2020-12-21 02:10:42.307862
16	680	1	10	5	12	50000	2020-12-21 02:13:00	0	2020-12-21 02:12:06.777617
17	680	1	10	5	11	50000	2020-12-21 02:13:00	0	2020-12-21 02:12:06.950838
18	680	1	10	5	12	50000	2020-12-21 02:13:00	0	2020-12-21 02:12:07.763984
19	680	1	10	5	12	50000	2020-12-21 02:13:00	0	2020-12-21 02:12:07.781159
20	680	1	10	5	12	50000	2020-12-21 02:13:00	0	2020-12-21 02:12:07.792312
21	680	1	10	5	12	50000	2020-12-21 02:13:00	0	2020-12-21 02:12:07.826283
22	680	1	10	5	11	50000	2020-12-21 02:13:00	0	2020-12-21 02:12:07.91477
23	680	1	10	5	12	50000	2020-12-21 02:13:00	0	2020-12-21 02:12:08.439198
24	680	1	10	5	11	50000	2020-12-21 02:13:00	0	2020-12-21 02:12:09.216706
25	680	1	10	5	11	50000	2020-12-21 02:13:00	0	2020-12-21 02:12:09.274758
26	680	1	10	5	11	50000	2020-12-21 02:13:00	0	2020-12-21 02:12:09.283868
9	155	1	10	5	12	50000	2020-12-20 09:50:00	6	2020-12-20 07:50:05.991047
27	680	1	10	5	11	50000	2020-12-21 02:13:00	0	2020-12-21 02:12:09.285361
28	680	1	10	5	12	50000	2020-12-21 02:13:00	0	2020-12-21 02:12:09.434767
29	680	1	10	5	12	50000	2020-12-21 02:13:00	0	2020-12-21 02:12:09.496109
30	680	1	10	5	12	50000	2020-12-21 02:13:00	0	2020-12-21 02:12:09.967632
12	335984	1	10	8	15	50000	2020-12-21 04:40:00	1	2020-12-20 16:40:59.641828
7	577922	1	10	5	12	50000	2020-12-19 10:23:00	6	2020-12-19 16:23:20.75665
31	13	1	10	6	12	50000	2020-12-21 03:24:00	0	2020-12-21 03:24:13.060765
2	335984	1	10	5	12	50000	2020-11-30 16:14:00	4	2020-12-18 16:14:40.483734
13	335984	1	10	6	12	40000	2020-12-21 17:42:00	0	2020-12-20 17:43:07.750721
10	680	1	10	5	12	50000	2020-12-24 08:04:00	10	2020-12-20 08:04:31.675459
11	335984	1	10	5	15	50000	2020-12-23 16:36:00	9	2020-12-20 16:36:44.684399
\.


--
-- Data for Name: theaters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.theaters (id, name, address, created_at) FROM stdin;
3	CineStart Cinemad	In the star	2020-12-19 20:17:44.745109
4	cineBOXer	In the box	2020-12-19 20:34:13.938592
2	Megastart Cinemask	In the space	2020-12-19 20:06:12.705417
7	Galaxy Cinemax	In the galaxy	2020-12-19 21:07:13.359914
6	CGVistar	CGV Saigonres Nguyễn Xí, Tầng 4-5, Saigonres Plaza 188, 79-81 Nguyễn Xí, P26, Bình Thạnh, TP HCM	2020-12-19 21:05:08.891026
5	DongDac Cinemaster	Rạp phim DDCINE, Số 890, Trần Hưng Đạo, P7, Q5, TP HCM	2020-12-19 20:43:12.853249
8	BHD Starred CineFlex	BHD Star Cineplex, Tầng 3-4 Tòa nhà tài chính Bitexco, 2 Hải Triều, Bến Nghé, Q1, TP HCM	2020-12-19 21:16:49.419619
1	LOTTEry Cinemars	In the cloud	2020-12-18 16:11:43.69634
\.


--
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tickets (invoice, seat, seat_name, price, created_at) FROM stdin;
2	20	B8	50000	2020-12-20 14:32:12.585017
2	18	B6	50000	2020-12-20 14:32:12.623652
2	29	C5	50000	2020-12-20 14:32:12.648439
2	32	C8	50000	2020-12-20 14:32:12.672695
3	41	D5	50000	2020-12-20 15:05:45.911007
3	12	A12	50000	2020-12-20 15:05:45.933786
3	22	B10	50000	2020-12-20 15:05:45.958183
4	29	C5	50000	2020-12-20 15:39:38.708718
4	18	B6	50000	2020-12-20 15:39:38.732255
4	8	A8	50000	2020-12-20 15:39:38.756359
4	9	A9	50000	2020-12-20 15:39:38.78083
4	21	B9	50000	2020-12-20 15:39:38.804603
4	32	C8	50000	2020-12-20 15:39:38.827878
5	28	C4	50000	2020-12-20 15:43:46.380712
5	10	A10	50000	2020-12-20 15:43:46.405534
5	22	B10	50000	2020-12-20 15:43:46.429991
5	16	B4	50000	2020-12-20 15:43:46.454505
5	14	B2	50000	2020-12-20 15:43:46.477781
5	25	C1	50000	2020-12-20 15:43:46.501254
6	28	C4	50000	2020-12-20 16:07:54.475978
6	17	B5	50000	2020-12-20 16:07:54.500253
6	7	A7	50000	2020-12-20 16:07:54.522909
6	20	B8	50000	2020-12-20 16:07:54.545425
7	14	B2	50000	2020-12-20 17:47:42.598064
7	2	A2	50000	2020-12-20 17:47:42.621276
7	9	A9	50000	2020-12-20 17:47:42.644584
8	23	B8	50000	2020-12-20 17:48:18.00544
8	25	B10	50000	2020-12-20 17:48:18.02898
8	13	A13	50000	2020-12-20 17:48:18.052332
9	12	A12	50000	2020-12-20 17:49:17.496484
9	14	A14	50000	2020-12-20 17:49:17.519923
9	28	B13	50000	2020-12-20 17:49:17.544919
10	52	D7	50000	2020-12-20 17:53:50.065112
10	38	C8	50000	2020-12-20 17:53:50.088229
10	39	C9	50000	2020-12-20 17:53:50.114327
11	17	B4	60000	2020-12-20 18:13:55.236641
11	30	C4	60000	2020-12-20 18:13:55.269837
11	33	C7	60000	2020-12-20 18:13:55.292863
11	22	B9	60000	2020-12-20 18:13:55.315318
11	23	B10	60000	2020-12-20 18:13:55.337633
11	24	B11	60000	2020-12-20 18:13:55.362296
11	59	E7	60000	2020-12-20 18:13:55.384909
11	57	E5	60000	2020-12-20 18:13:55.406731
11	58	E6	60000	2020-12-20 18:13:55.429022
12	36	C10	60000	2020-12-21 02:06:36.933137
12	37	C11	60000	2020-12-21 02:06:36.956446
12	50	D11	60000	2020-12-21 02:06:36.979586
12	49	D10	60000	2020-12-21 02:06:37.002521
12	75	F10	60000	2020-12-21 02:06:37.03206
12	48	D9	60000	2020-12-21 02:06:37.058393
12	34	C8	60000	2020-12-21 02:06:37.082704
12	29	C3	60000	2020-12-21 02:06:37.105633
12	20	B7	60000	2020-12-21 02:06:37.130642
12	19	B6	60000	2020-12-21 02:06:37.153147
12	18	B5	60000	2020-12-21 02:06:37.175517
12	31	C5	60000	2020-12-21 02:06:37.198197
12	44	D5	60000	2020-12-21 02:06:37.224979
12	3	A3	60000	2020-12-21 02:06:37.248246
13	9	A9	50000	2020-12-21 02:23:52.503667
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, fullname, dob, username, password, mail, created_at) FROM stdin;
2	John Doe	1970-01-01 00:00:00	johndoe	bcrypt+sha512$0a5a81b2585484264bb7954e097db435$12$3bfe2482f592285fc5d4808e09f722546ab7ba70d0fd3736	john@doe.com	2020-12-20 14:16:53.049131
3	long cinemart	2011-10-05 14:48:00	long	bcrypt+sha512$45d67dad873acb390adc06c86870a061$12$0cbf1af4b313fed4dd4c99394f55196a3292c3f66b6b2994	long@cinemar.com	2020-12-21 02:22:13.880946
\.


--
-- Name: admins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admins_id_seq', 1, true);


--
-- Name: invoices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.invoices_id_seq', 13, true);


--
-- Name: invoices_schedule_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.invoices_schedule_seq', 1, false);


--
-- Name: invoices_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.invoices_user_id_seq', 1, false);


--
-- Name: management_manager_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.management_manager_seq', 1, false);


--
-- Name: management_theater_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.management_theater_seq', 1, false);


--
-- Name: managers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.managers_id_seq', 9, true);


--
-- Name: movies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.movies_id_seq', 8, true);


--
-- Name: schedules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.schedules_id_seq', 31, true);


--
-- Name: schedules_movie_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.schedules_movie_seq', 1, false);


--
-- Name: schedules_theater_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.schedules_theater_seq', 1, false);


--
-- Name: theaters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.theaters_id_seq', 9, true);


--
-- Name: tickets_invoice_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tickets_invoice_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 3, true);


--
-- Name: admins admins_mail_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_mail_key UNIQUE (mail);


--
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: auth auth_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth
    ADD CONSTRAINT auth_pkey PRIMARY KEY (token, refresh_token);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: management management_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.management
    ADD CONSTRAINT management_pkey PRIMARY KEY (manager, theater);


--
-- Name: managers managers_mail_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.managers
    ADD CONSTRAINT managers_mail_key UNIQUE (mail);


--
-- Name: managers managers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.managers
    ADD CONSTRAINT managers_pkey PRIMARY KEY (id);


--
-- Name: movies movies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movies
    ADD CONSTRAINT movies_pkey PRIMARY KEY (id);


--
-- Name: schedules schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (id);


--
-- Name: theaters theaters_address_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.theaters
    ADD CONSTRAINT theaters_address_key UNIQUE (address);


--
-- Name: theaters theaters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.theaters
    ADD CONSTRAINT theaters_pkey PRIMARY KEY (id);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (invoice, seat);


--
-- Name: users users_mail_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_mail_key UNIQUE (mail);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: invoices tg_delete_invoices; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_delete_invoices AFTER DELETE ON public.invoices FOR EACH ROW EXECUTE FUNCTION public.delete_invoices_trigger();


--
-- Name: tickets tg_delete_tickets; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_delete_tickets AFTER DELETE ON public.tickets FOR EACH ROW EXECUTE FUNCTION public.delete_tickets_trigger();


--
-- Name: tickets tg_insert_tickets; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_insert_tickets AFTER INSERT ON public.tickets FOR EACH ROW EXECUTE FUNCTION public.insert_tickets_trigger();


--
-- Name: invoices tg_update_invoices; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_update_invoices AFTER UPDATE ON public.invoices FOR EACH ROW EXECUTE FUNCTION public.update_invoices_trigger();


--
-- Name: tickets fk_invoice; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_invoice FOREIGN KEY (invoice) REFERENCES public.invoices(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: management fk_manager; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.management
    ADD CONSTRAINT fk_manager FOREIGN KEY (manager) REFERENCES public.managers(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: schedules fk_movie; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT fk_movie FOREIGN KEY (movie) REFERENCES public.movies(id) ON UPDATE CASCADE;


--
-- Name: invoices fk_schedule; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT fk_schedule FOREIGN KEY (schedule) REFERENCES public.schedules(id) ON UPDATE CASCADE;


--
-- Name: schedules fk_theater; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT fk_theater FOREIGN KEY (theater) REFERENCES public.theaters(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: management fk_theater; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.management
    ADD CONSTRAINT fk_theater FOREIGN KEY (theater) REFERENCES public.theaters(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: invoices fk_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

--
-- Database "postgres" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.1 (Debian 13.1-1.pgdg100+1)
-- Dumped by pg_dump version 13.1 (Debian 13.1-1.pgdg100+1)

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

CREATE DATABASE postgres WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.utf8';


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
-- Database "test" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.1 (Debian 13.1-1.pgdg100+1)
-- Dumped by pg_dump version 13.1 (Debian 13.1-1.pgdg100+1)

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
-- Name: test; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE test WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.utf8';


ALTER DATABASE test OWNER TO postgres;

\connect test

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
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

