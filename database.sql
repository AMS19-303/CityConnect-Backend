--
-- PostgreSQL database dump
--

-- Dumped from database version 12.0
-- Dumped by pg_dump version 12.0

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

DROP DATABASE cityconnect_db;
--
-- Name: cityconnect_db; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE cityconnect_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'pt_PT.UTF-8' LC_CTYPE = 'pt_PT.UTF-8';


ALTER DATABASE cityconnect_db OWNER TO postgres;

\connect cityconnect_db

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
--
-- Name: business_hours; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.business_hours (
    business_hours_id integer NOT NULL,
    day_of_week integer NOT NULL,
    open time without time zone NOT NULL,
    close time without time zone NOT NULL,
    store_id integer NOT NULL,
    CONSTRAINT business_hours_day_of_week_check CHECK (((day_of_week >= 0) AND (day_of_week <= 6)))
);


ALTER TABLE public.business_hours OWNER TO postgres;

--
-- Name: business_hours_business_hours_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.business_hours_business_hours_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.business_hours_business_hours_id_seq OWNER TO postgres;

--
-- Name: business_hours_business_hours_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.business_hours_business_hours_id_seq OWNED BY public.business_hours.business_hours_id;


--
-- Name: category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.category (
    category_id integer NOT NULL,
    name character varying(100),
    food boolean DEFAULT true NOT NULL
);


ALTER TABLE public.category OWNER TO postgres;

--
-- Name: category_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.category_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.category_category_id_seq OWNER TO postgres;

--
-- Name: category_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.category_category_id_seq OWNED BY public.category.category_id;


--
-- Name: category_store; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.category_store (
    category_id integer,
    store_id integer
);


ALTER TABLE public.category_store OWNER TO postgres;

--
-- Name: courier; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.courier (
    courier_id integer NOT NULL,
    user_id integer,
    avg_rating double precision DEFAULT 0.00,
    nr_deliveries integer DEFAULT 0,
    CONSTRAINT courier_nr_deliveries_check CHECK ((nr_deliveries >= 0))
);


ALTER TABLE public.courier OWNER TO postgres;

--
-- Name: courier_courier_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.courier_courier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.courier_courier_id_seq OWNER TO postgres;

--
-- Name: courier_courier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.courier_courier_id_seq OWNED BY public.courier.courier_id;


--
-- Name: order; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."order" (
    order_id character varying(12) NOT NULL,
    user_id integer NOT NULL,
    active boolean DEFAULT true NOT NULL,
    courier_id integer,
    star_rating integer,
    total_price double precision DEFAULT 0.00 NOT NULL
);


ALTER TABLE public."order" OWNER TO postgres;

--
-- Name: order_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_item (
    order_item_id integer NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    cumul_price double precision DEFAULT 0.00,
    discount numeric(3,2),
    product_id integer NOT NULL,
    order_id character varying(12) NOT NULL,
    CONSTRAINT order_item_discount_check CHECK ((discount <= (100)::numeric))
);


ALTER TABLE public.order_item OWNER TO postgres;

--
-- Name: order_item_order_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_item_order_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_item_order_item_id_seq OWNER TO postgres;

--
-- Name: order_item_order_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_item_order_item_id_seq OWNED BY public.order_item.order_item_id;


--
-- Name: product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product (
    product_id integer NOT NULL,
    name character varying(60) NOT NULL,
    type character varying(48),
    description character varying(300),
    store_id integer NOT NULL,
    unit_price double precision DEFAULT 0.00 NOT NULL,
    base_unit integer DEFAULT 1 NOT NULL,
    unit character varying(48) DEFAULT 'unidade'::character varying NOT NULL
);


ALTER TABLE public.product OWNER TO postgres;

--
-- Name: store; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.store (
    store_id integer NOT NULL,
    name character varying(128) NOT NULL,
    type character varying(48) NOT NULL,
    gps point,
    photo character varying(300)
);


ALTER TABLE public.store OWNER TO postgres;

--
-- Name: TABLE store; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.store IS 'Table containing information on each store';


--
-- Name: store_store_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.store_store_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.store_store_id_seq OWNER TO postgres;

--
-- Name: store_store_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.store_store_id_seq OWNED BY public.store.store_id;


--
-- Name: user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."user" (
    user_id integer NOT NULL,
    email character varying(96) NOT NULL,
    password character varying(256) NOT NULL,
    first_name character varying(48),
    last_name character varying(48),
    nif integer NOT NULL,
    photo character varying(256) DEFAULT NULL::character varying
);


ALTER TABLE public."user" OWNER TO postgres;

--
-- Name: TABLE "user"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."user" IS 'User table';


--
-- Name: user_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_user_id_seq OWNER TO postgres;

--
-- Name: user_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_user_id_seq OWNED BY public."user".user_id;


--
-- Name: business_hours business_hours_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_hours ALTER COLUMN business_hours_id SET DEFAULT nextval('public.business_hours_business_hours_id_seq'::regclass);


--
-- Name: category category_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category ALTER COLUMN category_id SET DEFAULT nextval('public.category_category_id_seq'::regclass);


--
-- Name: courier courier_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.courier ALTER COLUMN courier_id SET DEFAULT nextval('public.courier_courier_id_seq'::regclass);


--
-- Name: order_item order_item_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item ALTER COLUMN order_item_id SET DEFAULT nextval('public.order_item_order_item_id_seq'::regclass);


--
-- Name: store store_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.store ALTER COLUMN store_id SET DEFAULT nextval('public.store_store_id_seq'::regclass);


--
-- Name: user user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user" ALTER COLUMN user_id SET DEFAULT nextval('public.user_user_id_seq'::regclass);


--
-- Data for Name: business_hours; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.business_hours (business_hours_id, day_of_week, open, close, store_id) FROM stdin;
3	2	10:30:00	19:30:00	1
4	2	10:30:00	19:30:00	2
5	2	10:30:00	19:30:00	3
6	2	10:30:00	19:30:00	4
7	2	10:30:00	19:30:00	5
8	2	10:30:00	19:30:00	6
9	2	10:30:00	19:30:00	7
10	2	10:30:00	19:30:00	8
\.


--
-- Data for Name: category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.category (category_id, name, food) FROM stdin;
1	Doces & Pastéis	t
2	Laticínios	t
3	Fruta & Legumes	t
4	Carne & Enchidos	t
5	Peixe	t
6	Indumentária	f
7	Artesanato	f
8	Outros	f
9	Restaurante	t
\.


--
-- Data for Name: category_store; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.category_store (category_id, store_id) FROM stdin;
9	1
2	3
1	4
2	4
3	4
4	4
5	4
8	4
6	5
4	6
5	7
1	8
1	2
\.


--
-- Data for Name: courier; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.courier (courier_id, user_id, avg_rating, nr_deliveries) FROM stdin;
\.


--
-- Data for Name: order; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."order" (order_id, user_id, active, courier_id, star_rating, total_price) FROM stdin;
\.


--
-- Data for Name: order_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_item (order_item_id, quantity, cumul_price, discount, product_id, order_id) FROM stdin;
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product (product_id, name, type, description, store_id, unit_price, base_unit, unit) FROM stdin;
1	Leite Agros Meio Gordo 1L	Laticínios	UHT Ultrapasteurizado	4	0.5	1	unidade
2	Carne de Vaca Picada	Carnes	Feita na hora	4	5.99	500	gramas
\.


--
-- Data for Name: store; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.store (store_id, name, type, gps, photo) FROM stdin;
1	Ramona	Hamburgueria	(40.6381073,-8.6513571)	https://i.ibb.co/WNCvCQz/ramona.jpg
2	Ria Pão	Padaria	(40.64163,-8.6572227)	https://i.ibb.co/RcYc5M5/riapao.png
3	Tripas da Praça	Confeitaria	(40.6422777,-8.6548049)	https://i.ibb.co/HnTG92V/tripaspra-a.jpg
4	Mini Mercado Farol	Mercearia	(40.6422653,-8.656447)	https://i.ibb.co/L55cWtz/mercearia.jpg
5	Azuleto	Sapataria	(40.6421325,-8.6513097)	https://i.ibb.co/GQK1bG0/sapataria.jpg
6	Flor de Aveiro	Talho	(40.6433839,-8.6506286)	https://i.ibb.co/wK3jcZB/talho.jpg
7	Mar Aberto	Peixaria	(40.6468266,-8.6437491)	https://i.ibb.co/bXMmrpM/peixaria.png
8	Oita	Croissanteria	(40.6430422,-8.6495785)	https://i.ibb.co/vk3VfWb/oita.png
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."user" (user_id, email, password, first_name, last_name, nif, photo) FROM stdin;
\.


--
-- Name: business_hours_business_hours_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.business_hours_business_hours_id_seq', 10, true);


--
-- Name: category_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.category_category_id_seq', 9, true);


--
-- Name: courier_courier_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.courier_courier_id_seq', 1, false);


--
-- Name: order_item_order_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_item_order_item_id_seq', 1, false);


--
-- Name: store_store_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.store_store_id_seq', 8, true);


--
-- Name: user_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_user_id_seq', 1, false);


--
-- Name: business_hours business_hours_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_hours
    ADD CONSTRAINT business_hours_pk PRIMARY KEY (business_hours_id);


--
-- Name: category category_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_pk PRIMARY KEY (category_id);


--
-- Name: courier courier_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.courier
    ADD CONSTRAINT courier_pk PRIMARY KEY (courier_id);


--
-- Name: order_item order_item_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_pk PRIMARY KEY (order_item_id);


--
-- Name: order order_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_pk PRIMARY KEY (order_id);


--
-- Name: product product_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pk PRIMARY KEY (product_id);


--
-- Name: store store_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.store
    ADD CONSTRAINT store_pk PRIMARY KEY (store_id);


--
-- Name: user user_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pk PRIMARY KEY (user_id);


--
-- Name: business_hours_business_hours_id_uindex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX business_hours_business_hours_id_uindex ON public.business_hours USING btree (business_hours_id);


--
-- Name: category_category_id_uindex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX category_category_id_uindex ON public.category USING btree (category_id);


--
-- Name: courier_courier_id_uindex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX courier_courier_id_uindex ON public.courier USING btree (courier_id);


--
-- Name: order_order_id_uindex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX order_order_id_uindex ON public."order" USING btree (order_id);


--
-- Name: user_email_uindex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX user_email_uindex ON public."user" USING btree (email);


--
-- Name: business_hours business_hours_store_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_hours
    ADD CONSTRAINT business_hours_store_fk FOREIGN KEY (store_id) REFERENCES public.store(store_id);


--
-- Name: category_store category_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category_store
    ADD CONSTRAINT category_fk FOREIGN KEY (category_id) REFERENCES public.category(category_id);


--
-- Name: courier courier_user_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.courier
    ADD CONSTRAINT courier_user_fk FOREIGN KEY (user_id) REFERENCES public."user"(user_id);


--
-- Name: order order_courier_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_courier_fk FOREIGN KEY (courier_id) REFERENCES public.courier(courier_id);


--
-- Name: order_item order_item_order_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_order_fk FOREIGN KEY (order_id) REFERENCES public."order"(order_id);


--
-- Name: order_item order_item_product_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_product_fk FOREIGN KEY (product_id) REFERENCES public.product(product_id);


--
-- Name: order order_user_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_user_fk FOREIGN KEY (user_id) REFERENCES public."user"(user_id);


--
-- Name: product product_store_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_store_fkey FOREIGN KEY (store_id) REFERENCES public.store(store_id);


--
-- Name: category_store store_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.category_store
    ADD CONSTRAINT store_fk FOREIGN KEY (store_id) REFERENCES public.store(store_id);


--
-- PostgreSQL database dump complete
--

