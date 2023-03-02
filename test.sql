--
-- PostgreSQL database dump
--

-- Dumped from database version 12.12 (Ubuntu 12.12-0ubuntu0.20.04.1)
-- Dumped by pg_dump version 12.12 (Ubuntu 12.12-0ubuntu0.20.04.1)

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
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: create_content(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_content() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE  category_id int;
BEGIN

for category_id in select id from categories loop
 INSERT INTO consents(worker_id,category_id)
         VALUES(NEW.id,category_id);
 end loop;
    
    RETURN new;
END;
$$;


ALTER FUNCTION public.create_content() OWNER TO postgres;

--
-- Name: get_domestic_transport_cost_1(uuid, uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_domestic_transport_cost_1(fc_id uuid, tc_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    tt int;
BEGIN
          SELECT value into tt FROM direction_values WHERE direction_id = (SELECT id From directions WHERE from_city_id = fc_id AND to_city_id = tc_id ) 
                and column_id = (SELECT id FROM direction_cost_columns WHERE name = 'Тягач' 
                                AND direction_cost_id in (SELECT id FROM direction_costs WHERE name = 'Цена за' AND route_id in 
                                                         (SELECT id from routes where transport_type_id = (select id from transport_types WHERE name = 'Внутренние перевозки') 
                                                          and id = (SELECT route_id From directions WHERE from_city_id = fc_id AND to_city_id = tc_id)
                                                          ) 
                                                         )
                                );
        RETURN tt;
END;
$$;


ALTER FUNCTION public.get_domestic_transport_cost_1(fc_id uuid, tc_id uuid) OWNER TO postgres;

--
-- Name: get_domestic_transport_cost_2(uuid, uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_domestic_transport_cost_2(fc_id uuid, tc_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    tt int;
BEGIN
          SELECT value into tt FROM direction_values WHERE direction_id = (SELECT id From directions WHERE from_city_id = fc_id AND to_city_id = tc_id ) 
                and column_id = (SELECT id FROM direction_cost_columns WHERE name = 'Прицеп' 
                                AND direction_cost_id in (SELECT id FROM direction_costs WHERE name = 'Цена за' AND route_id in 
                                                         (SELECT id from routes where transport_type_id = (select id from transport_types WHERE name = 'Внутренние перевозки') 
                                                          and id = (SELECT route_id From directions WHERE from_city_id = fc_id AND to_city_id = tc_id)
                                                          ) 
                                                         )
                                );
        RETURN tt;
END;
$$;


ALTER FUNCTION public.get_domestic_transport_cost_2(fc_id uuid, tc_id uuid) OWNER TO postgres;

--
-- Name: get_trailer_tm(uuid, uuid, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_trailer_tm(fc_id uuid, tc_id uuid, tt_id integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    tt int;
BEGIN
          SELECT value into tt FROM direction_values WHERE direction_id = (SELECT id From directions WHERE from_city_id = fc_id AND to_city_id = tc_id ) 
                and column_id = (SELECT id FROM direction_cost_columns WHERE name = 'Прицеп TM' 
                                AND direction_cost_id in (SELECT id FROM direction_costs WHERE name = 'Цена за' AND route_id in 
                                                         (SELECT id from routes where transport_type_id = tt_id 
                                                          and id = (SELECT route_id From directions WHERE from_city_id = fc_id AND to_city_id = tc_id)
                                                          ) 
                                                         )
                                );
        RETURN tt;
END;
$$;


ALTER FUNCTION public.get_trailer_tm(fc_id uuid, tc_id uuid, tt_id integer) OWNER TO postgres;

--
-- Name: get_trailer_tm_import(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_trailer_tm_import(od_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    tt int;
BEGIN
        SELECT trailer_tm into tt FROM import_trailer_tm WHERE order_id = od_id;
        RETURN tt;
END;
$$;


ALTER FUNCTION public.get_trailer_tm_import(od_id integer) OWNER TO postgres;

--
-- Name: trgg_car_dec(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trgg_car_dec() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
        INSERT INTO exes("car_dec_id","pay_type") 
        VALUES 
        (NEW.id, "Gumruk"),
        (NEW.id, "Serhet"),
        (NEW.id, "Ses"),
        (NEW.id, "Transport"),
        (NEW.id, "Askada"),
        (NEW.id, "Karantin"),
        (NEW.id, "Bank");
        RETURN NEW;
END;
$$;


ALTER FUNCTION public.trgg_car_dec() OWNER TO postgres;

--
-- Name: trgg_card_dec(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trgg_card_dec() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN   
        IF ( ( SELECT mission FROM declarant_orders WHERE id = (SELECT dec_order_id FROM card_dec WHERE card_dec.id = NEW.id and NEW.type = 'input') ) = 'Представитель' )
        THEN
            INSERT INTO exes("card_dec_id", "type", "pay_type") 
            VALUES 
            (NEW.id, 'type', 'Avans');
        ELSEIF ( ( SELECT mission FROM declarant_orders WHERE id = (SELECT dec_order_id FROM card_dec WHERE card_dec.id = NEW.id and NEW.type = 'output') ) = 'Представитель' )
        THEN
            INSERT INTO exes("card_dec_id", "type", "pay_type") 
            VALUES 
            (NEW.id, 'type', 'Doly toleg');
        ELSE
            INSERT INTO exes("card_dec_id", "type", "pay_type") 
            VALUES 
            (NEW.id, 'type', 'Gumruk'),
            (NEW.id, 'type', 'Serhet'),
            (NEW.id, 'type', 'Ses'),
            (NEW.id, 'type', 'Transport'),
            (NEW.id, 'type', 'Askuda'),
            (NEW.id, 'type', 'Karantin'),
            (NEW.id, 'type', 'Bank');
        END IF;

        RETURN NEW;
END;
$$;


ALTER FUNCTION public.trgg_card_dec() OWNER TO postgres;

--
-- Name: trgg_declarant_orders(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trgg_declarant_orders() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
        INSERT INTO card_dec("dec_order_id", "type") 
        VALUES 
        (NEW.id,'input'),
        (NEW.id,'output');
        RETURN NEW;

END;
$$;


ALTER FUNCTION public.trgg_declarant_orders() OWNER TO postgres;

--
-- Name: trgg_direction_cost_columns(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trgg_direction_cost_columns() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    direc RECORD;
BEGIN
        FOR direc IN SELECT * FROM directions WHERE route_id = (SELECT route_id FROM direction_costs WHERE id = (SELECT direction_cost_id FROM direction_cost_columns WHERE id = NEW.id) ) LOOP
        INSERT INTO direction_values(direction_id, column_id, value) 
        VALUES(direc.id, NEW.id, '0');
        END LOOP;
        RETURN NEW;
END;
$$;


ALTER FUNCTION public.trgg_direction_cost_columns() OWNER TO postgres;

--
-- Name: trgg_direction_costs(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trgg_direction_costs() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
        IF (NEW.name = 'Направление') THEN
            INSERT INTO direction_cost_columns("direction_cost_id", "name") 
            VALUES (NEW.id, 'Откуда'), (NEW.id, 'Куда');
        END IF;
        
        IF (NEW.name = 'Цена за' AND ( NEW.route_id not in (select id from routes where transport_type_id in (select id from transport_types where name = 'Импорт' OR name = 'Внутренние перевозки' )))) 
        THEN
            INSERT INTO direction_cost_columns("direction_cost_id", "name") 
            VALUES (NEW.id, 'Прицеп TM');
        END IF;

          IF (NEW.name = 'Цена за' AND ( NEW.route_id in (select id from routes where transport_type_id = (select id from transport_types where name = 'Внутренние перевозки' )))) 
        THEN
            INSERT INTO direction_cost_columns("direction_cost_id", "name") 
            VALUES (NEW.id, 'Тягач'),(NEW.id, 'Прицеп');
        END IF;

        IF (NEW.name = 'Суммарные затраты') 
        THEN
            INSERT INTO direction_cost_columns("direction_cost_id", "name") 
            VALUES (NEW.id, 'Других компаний'), (NEW.id, 'Суммарные затраты'), (NEW.id, 'Общая стоимость предложения'), (NEW.id, 'Выгода');
        END IF;

        RETURN NEW;
END;
$$;


ALTER FUNCTION public.trgg_direction_costs() OWNER TO postgres;

--
-- Name: trgg_direction_val_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trgg_direction_val_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    direc RECORD;
BEGIN
        FOR direc IN SELECT direction_id, value FROM direction_values WHERE column_id = OLD.id LOOP
        UPDATE direction_values SET value = 
                (select 
                cast( ( 
                    (select cast(value as float)) - 
                    (select cast( 
                        (select 
                            case 
                                when value = ' ' 
                                    then '0' 
                                    else value 
                                end as value 
                        from direction_values WHERE column_id = OLD.id and direction_id = direc.direction_id
                        ) as float)
                    ) ) as CHARACTER VARYING(25) ) 
                ) 
        where direction_id = direc.direction_id and column_id = 
        ( select id from direction_cost_columns where name = 'Суммарные затраты' and direction_cost_id in 
            ( select id from direction_costs where route_id = 
                (select route_id from direction_costs where id = (select direction_cost_id from direction_cost_columns where id = OLD.id )
                )
            )
        );

         UPDATE direction_values SET value = 
                (select 
                cast( ( 
                    (select cast(value as float)) + 
                    (select cast( 
                        (select 
                            case 
                                when value = ' ' 
                                    then '0' 
                                    else value 
                                end as value 
                        from direction_values WHERE column_id = OLD.id and direction_id = direc.direction_id
                        ) as float)
                    ) ) as CHARACTER VARYING(25) ) 
                ) 
        where direction_id = direc.direction_id and column_id = 
        ( select id from direction_cost_columns where name = 'Выгода' and direction_cost_id in 
            ( select id from direction_costs where route_id = 
                (select route_id from direction_costs where id = (select direction_cost_id from direction_cost_columns where id = OLD.id )
                )
            )
        );
        END LOOP;
        RETURN OLD;
END;
$$;


ALTER FUNCTION public.trgg_direction_val_update() OWNER TO postgres;

--
-- Name: trgg_routes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trgg_routes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
        INSERT INTO direction_costs("name","route_id") 
        VALUES ('Направление',NEW.id),('Регистрация',NEW.id),('Цена за',NEW.id),('Суммарные затраты',NEW.id);
        RETURN NEW;
END;
$$;


ALTER FUNCTION public.trgg_routes() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admins (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    first_name character varying(20) NOT NULL,
    last_name character varying(20) NOT NULL,
    middle_name character varying(20) NOT NULL,
    role character varying(20) NOT NULL,
    phone_number character varying(15) NOT NULL,
    login character varying(20) NOT NULL,
    password character varying(75) NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.admins OWNER TO postgres;

--
-- Name: border_workers; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.border_workers (
    id integer NOT NULL,
    worker_id uuid NOT NULL,
    border_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.border_workers OWNER TO crm_db_user;

--
-- Name: border_workers_id_seq; Type: SEQUENCE; Schema: public; Owner: crm_db_user
--

CREATE SEQUENCE public.border_workers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.border_workers_id_seq OWNER TO crm_db_user;

--
-- Name: border_workers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crm_db_user
--

ALTER SEQUENCE public.border_workers_id_seq OWNED BY public.border_workers.id;


--
-- Name: borders; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.borders (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.borders OWNER TO crm_db_user;

--
-- Name: borders_id_seq; Type: SEQUENCE; Schema: public; Owner: crm_db_user
--

CREATE SEQUENCE public.borders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.borders_id_seq OWNER TO crm_db_user;

--
-- Name: borders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crm_db_user
--

ALTER SEQUENCE public.borders_id_seq OWNED BY public.borders.id;


--
-- Name: card_dec; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.card_dec (
    id integer NOT NULL,
    dec_order_id integer NOT NULL,
    cmr character varying(100) DEFAULT ''::character varying,
    total_dol numeric(12,0) DEFAULT 0 NOT NULL,
    total_tmt numeric(12,0) DEFAULT 0 NOT NULL,
    type character varying(25),
    yedek_2 numeric(12,0),
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.card_dec OWNER TO crm_db_user;

--
-- Name: card_dec_id_seq; Type: SEQUENCE; Schema: public; Owner: crm_db_user
--

CREATE SEQUENCE public.card_dec_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.card_dec_id_seq OWNER TO crm_db_user;

--
-- Name: card_dec_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crm_db_user
--

ALTER SEQUENCE public.card_dec_id_seq OWNED BY public.card_dec.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    event character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.categories OWNER TO crm_db_user;

--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: crm_db_user
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.categories_id_seq OWNER TO crm_db_user;

--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crm_db_user
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: category; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.category (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.category OWNER TO crm_db_user;

--
-- Name: category_id_seq; Type: SEQUENCE; Schema: public; Owner: crm_db_user
--

CREATE SEQUENCE public.category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.category_id_seq OWNER TO crm_db_user;

--
-- Name: category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crm_db_user
--

ALTER SEQUENCE public.category_id_seq OWNED BY public.category.id;


--
-- Name: cities; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.cities (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(50) NOT NULL,
    country_id uuid NOT NULL,
    is_border boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.cities OWNER TO crm_db_user;

--
-- Name: client_payment_history; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.client_payment_history (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    client_id integer,
    order_id integer,
    before_payment numeric(8,0),
    payment_date date,
    paid numeric(8,0),
    who_paid character varying(150),
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.client_payment_history OWNER TO crm_db_user;

--
-- Name: clients; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.clients (
    id integer NOT NULL,
    f_name character varying(25) NOT NULL,
    l_name character varying(25) NOT NULL,
    phone character varying(25) NOT NULL,
    email character varying(25) NOT NULL,
    company character varying(25) NOT NULL,
    rating integer DEFAULT 0 NOT NULL,
    is_vip boolean DEFAULT false NOT NULL,
    payment numeric(8,0) DEFAULT 0,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.clients OWNER TO crm_db_user;

--
-- Name: clients_id_seq; Type: SEQUENCE; Schema: public; Owner: crm_db_user
--

CREATE SEQUENCE public.clients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.clients_id_seq OWNER TO crm_db_user;

--
-- Name: clients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crm_db_user
--

ALTER SEQUENCE public.clients_id_seq OWNED BY public.clients.id;


--
-- Name: consents; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.consents (
    id integer NOT NULL,
    worker_id uuid NOT NULL,
    category_id integer NOT NULL,
    is_view boolean DEFAULT false NOT NULL,
    is_edit boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.consents OWNER TO crm_db_user;

--
-- Name: consents_id_seq; Type: SEQUENCE; Schema: public; Owner: crm_db_user
--

CREATE SEQUENCE public.consents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.consents_id_seq OWNER TO crm_db_user;

--
-- Name: consents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crm_db_user
--

ALTER SEQUENCE public.consents_id_seq OWNED BY public.consents.id;


--
-- Name: countries; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.countries (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.countries OWNER TO crm_db_user;

--
-- Name: cover_types; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.cover_types (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(25) NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.cover_types OWNER TO crm_db_user;

--
-- Name: dec_balans; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.dec_balans (
    id integer NOT NULL,
    border_id integer NOT NULL,
    why character varying(250) NOT NULL,
    dol numeric(12,0) NOT NULL,
    tmt numeric(12,0) NOT NULL,
    balanc_dol numeric(12,0) DEFAULT 0 NOT NULL,
    balanc_tmt numeric(12,0) DEFAULT 0 NOT NULL,
    type character varying(250) NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    card_id integer DEFAULT 0,
    is_view boolean DEFAULT true,
    is_dec_dop_ras boolean DEFAULT false
);


ALTER TABLE public.dec_balans OWNER TO crm_db_user;

--
-- Name: dec_balans_id_seq; Type: SEQUENCE; Schema: public; Owner: crm_db_user
--

CREATE SEQUENCE public.dec_balans_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dec_balans_id_seq OWNER TO crm_db_user;

--
-- Name: dec_balans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crm_db_user
--

ALTER SEQUENCE public.dec_balans_id_seq OWNED BY public.dec_balans.id;


--
-- Name: dec_ord_images; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.dec_ord_images (
    id integer NOT NULL,
    card_dec_id integer NOT NULL,
    type character varying(100) NOT NULL,
    image_path character varying(250) NOT NULL,
    yedek_1 character varying(250),
    yedek_2 character varying(250),
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.dec_ord_images OWNER TO crm_db_user;

--
-- Name: dec_ord_images_id_seq; Type: SEQUENCE; Schema: public; Owner: crm_db_user
--

CREATE SEQUENCE public.dec_ord_images_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dec_ord_images_id_seq OWNER TO crm_db_user;

--
-- Name: dec_ord_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crm_db_user
--

ALTER SEQUENCE public.dec_ord_images_id_seq OWNED BY public.dec_ord_images.id;


--
-- Name: declarant_orders; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.declarant_orders (
    id integer NOT NULL,
    type_id integer,
    border_id integer DEFAULT 0,
    trailer_number character varying(100) NOT NULL,
    direction character varying(100),
    status boolean DEFAULT false NOT NULL,
    driver_name character varying(100),
    driver_phone character varying(100),
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    b_status boolean DEFAULT false,
    cmr character varying(25) DEFAULT ''::character varying,
    order_type character varying(100),
    mission character varying(25) DEFAULT ''::character varying,
    conten_num character varying(50) DEFAULT ''::character varying
);


ALTER TABLE public.declarant_orders OWNER TO crm_db_user;

--
-- Name: declarant_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: crm_db_user
--

CREATE SEQUENCE public.declarant_orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.declarant_orders_id_seq OWNER TO crm_db_user;

--
-- Name: declarant_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crm_db_user
--

ALTER SEQUENCE public.declarant_orders_id_seq OWNED BY public.declarant_orders.id;


--
-- Name: direction_cost_columns; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.direction_cost_columns (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    direction_cost_id integer NOT NULL,
    name character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.direction_cost_columns OWNER TO crm_db_user;

--
-- Name: direction_costs; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.direction_costs (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    route_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.direction_costs OWNER TO crm_db_user;

--
-- Name: direction_costs_id_seq; Type: SEQUENCE; Schema: public; Owner: crm_db_user
--

CREATE SEQUENCE public.direction_costs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.direction_costs_id_seq OWNER TO crm_db_user;

--
-- Name: direction_costs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crm_db_user
--

ALTER SEQUENCE public.direction_costs_id_seq OWNED BY public.direction_costs.id;


--
-- Name: direction_values; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.direction_values (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    direction_id uuid NOT NULL,
    column_id uuid NOT NULL,
    value character varying(25) NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.direction_values OWNER TO crm_db_user;

--
-- Name: directions; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.directions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    from_city_id uuid NOT NULL,
    to_city_id uuid NOT NULL,
    route_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.directions OWNER TO crm_db_user;

--
-- Name: drivers; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.drivers (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    rent_type_id integer NOT NULL,
    f_name character varying(25) NOT NULL,
    l_name character varying(25) NOT NULL,
    phone character varying(25) NOT NULL,
    truck_brand character varying(25) NOT NULL,
    truck_number character varying(25) NOT NULL,
    rating integer DEFAULT 0 NOT NULL,
    status numeric(1,0) DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.drivers OWNER TO crm_db_user;

--
-- Name: exes; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.exes (
    id integer NOT NULL,
    card_dec_id integer NOT NULL,
    type character varying(100) NOT NULL,
    pay_type character varying(100) NOT NULL,
    dol numeric(12,0) DEFAULT 0 NOT NULL,
    tmt numeric(12,0) DEFAULT 0 NOT NULL,
    yedek_1 numeric(12,0),
    yedek_2 numeric(12,0),
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.exes OWNER TO crm_db_user;

--
-- Name: exes_id_seq; Type: SEQUENCE; Schema: public; Owner: crm_db_user
--

CREATE SEQUENCE public.exes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.exes_id_seq OWNER TO crm_db_user;

--
-- Name: exes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crm_db_user
--

ALTER SEQUENCE public.exes_id_seq OWNED BY public.exes.id;


--
-- Name: images; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.images (
    id integer NOT NULL,
    order_detail_id integer NOT NULL,
    image_path character varying(150) NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.images OWNER TO crm_db_user;

--
-- Name: images_id_seq; Type: SEQUENCE; Schema: public; Owner: crm_db_user
--

CREATE SEQUENCE public.images_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.images_id_seq OWNER TO crm_db_user;

--
-- Name: images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crm_db_user
--

ALTER SEQUENCE public.images_id_seq OWNED BY public.images.id;


--
-- Name: import_trailer_tm; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.import_trailer_tm (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    trailer_tm numeric(8,0),
    order_id integer,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.import_trailer_tm OWNER TO crm_db_user;

--
-- Name: item_types; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.item_types (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(50) NOT NULL,
    is_danger boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.item_types OWNER TO crm_db_user;

--
-- Name: missions; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.missions (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.missions OWNER TO crm_db_user;

--
-- Name: missions_id_seq; Type: SEQUENCE; Schema: public; Owner: crm_db_user
--

CREATE SEQUENCE public.missions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.missions_id_seq OWNER TO crm_db_user;

--
-- Name: missions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crm_db_user
--

ALTER SEQUENCE public.missions_id_seq OWNED BY public.missions.id;


--
-- Name: order_details; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.order_details (
    id integer NOT NULL,
    order_id integer NOT NULL,
    trailer_id uuid,
    driver_id uuid,
    border_id integer,
    gps_tracker_number integer,
    placed_neutral_zone date,
    departure_neutral_zone date,
    cmr character varying(50),
    invoice character varying(50),
    container_number character varying(50),
    invoice_file_path character varying(150),
    transport_cost_tmt character varying(150),
    transport_cost_dol character varying(150),
    additional_cost_tmt character varying(150),
    additional_cost_dol character varying(150),
    fine character varying(150),
    status numeric(1,0) DEFAULT 1 NOT NULL,
    logist_status numeric(1,0) DEFAULT 0 NOT NULL,
    client_notified_date date,
    client_notified_clock time without time zone,
    re_notification_date date,
    re_notification_clock time without time zone,
    arrived_for_unloading date,
    unloaded date,
    downtime_in_day character varying(10),
    total_downtime character varying(10),
    arrived_for_loading date,
    sent date,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.order_details OWNER TO crm_db_user;

--
-- Name: order_details_id_seq; Type: SEQUENCE; Schema: public; Owner: crm_db_user
--

CREATE SEQUENCE public.order_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_details_id_seq OWNER TO crm_db_user;

--
-- Name: order_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crm_db_user
--

ALTER SEQUENCE public.order_details_id_seq OWNED BY public.order_details.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    client_id integer,
    item_type_id uuid,
    cover_type_id uuid,
    from_city_id uuid,
    to_city_id uuid,
    trailer_type_id uuid,
    logist_id uuid,
    transport_type_id integer,
    weight numeric(8,0),
    trailer_count numeric(2,0),
    order_data timestamp with time zone NOT NULL,
    is_security boolean DEFAULT false NOT NULL,
    price numeric(8,0),
    total_price numeric(8,0),
    status numeric(1,0) DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.orders OWNER TO crm_db_user;

--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: crm_db_user
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orders_id_seq OWNER TO crm_db_user;

--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crm_db_user
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- Name: pay_money; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.pay_money (
    id integer NOT NULL,
    total_dol numeric(8,0),
    total_tmt numeric(8,0),
    border_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.pay_money OWNER TO crm_db_user;

--
-- Name: pay_money_id_seq; Type: SEQUENCE; Schema: public; Owner: crm_db_user
--

CREATE SEQUENCE public.pay_money_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pay_money_id_seq OWNER TO crm_db_user;

--
-- Name: pay_money_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crm_db_user
--

ALTER SEQUENCE public.pay_money_id_seq OWNED BY public.pay_money.id;


--
-- Name: rent_types; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.rent_types (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.rent_types OWNER TO crm_db_user;

--
-- Name: rent_types_id_seq; Type: SEQUENCE; Schema: public; Owner: crm_db_user
--

CREATE SEQUENCE public.rent_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rent_types_id_seq OWNER TO crm_db_user;

--
-- Name: rent_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crm_db_user
--

ALTER SEQUENCE public.rent_types_id_seq OWNED BY public.rent_types.id;


--
-- Name: routes; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.routes (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(50) NOT NULL,
    transport_type_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.routes OWNER TO crm_db_user;

--
-- Name: routes_transport_type_id_seq; Type: SEQUENCE; Schema: public; Owner: crm_db_user
--

CREATE SEQUENCE public.routes_transport_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.routes_transport_type_id_seq OWNER TO crm_db_user;

--
-- Name: routes_transport_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crm_db_user
--

ALTER SEQUENCE public.routes_transport_type_id_seq OWNED BY public.routes.transport_type_id;


--
-- Name: sub_category; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.sub_category (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    category_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.sub_category OWNER TO crm_db_user;

--
-- Name: sub_category_id_seq; Type: SEQUENCE; Schema: public; Owner: crm_db_user
--

CREATE SEQUENCE public.sub_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sub_category_id_seq OWNER TO crm_db_user;

--
-- Name: sub_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crm_db_user
--

ALTER SEQUENCE public.sub_category_id_seq OWNED BY public.sub_category.id;


--
-- Name: sub_sub; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.sub_sub (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    scategory_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.sub_sub OWNER TO crm_db_user;

--
-- Name: sub_sub_id_seq; Type: SEQUENCE; Schema: public; Owner: crm_db_user
--

CREATE SEQUENCE public.sub_sub_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sub_sub_id_seq OWNER TO crm_db_user;

--
-- Name: sub_sub_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crm_db_user
--

ALTER SEQUENCE public.sub_sub_id_seq OWNED BY public.sub_sub.id;


--
-- Name: test; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.test (
    id integer NOT NULL,
    value numeric(4,0)
);


ALTER TABLE public.test OWNER TO postgres;

--
-- Name: test_1; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.test_1 (
    id integer NOT NULL,
    val integer
);


ALTER TABLE public.test_1 OWNER TO postgres;

--
-- Name: test_1_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.test_1_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.test_1_id_seq OWNER TO postgres;

--
-- Name: test_1_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.test_1_id_seq OWNED BY public.test_1.id;


--
-- Name: test_2; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.test_2 (
    id integer NOT NULL,
    val integer
);


ALTER TABLE public.test_2 OWNER TO postgres;

--
-- Name: test_2_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.test_2_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.test_2_id_seq OWNER TO postgres;

--
-- Name: test_2_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.test_2_id_seq OWNED BY public.test_2.id;


--
-- Name: test_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.test_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.test_id_seq OWNER TO postgres;

--
-- Name: test_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.test_id_seq OWNED BY public.test.id;


--
-- Name: trailer_types; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.trailer_types (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.trailer_types OWNER TO crm_db_user;

--
-- Name: trailers; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.trailers (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    number character varying(100) NOT NULL,
    type_id uuid NOT NULL,
    rent_type_id integer NOT NULL,
    status numeric(1,0) DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.trailers OWNER TO crm_db_user;

--
-- Name: trans_tp_workers; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.trans_tp_workers (
    id integer NOT NULL,
    worker_id uuid NOT NULL,
    transport_type_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.trans_tp_workers OWNER TO crm_db_user;

--
-- Name: trans_tp_workers_id_seq; Type: SEQUENCE; Schema: public; Owner: crm_db_user
--

CREATE SEQUENCE public.trans_tp_workers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trans_tp_workers_id_seq OWNER TO crm_db_user;

--
-- Name: trans_tp_workers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crm_db_user
--

ALTER SEQUENCE public.trans_tp_workers_id_seq OWNED BY public.trans_tp_workers.id;


--
-- Name: transport_types; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.transport_types (
    id integer NOT NULL,
    name character varying(25) NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.transport_types OWNER TO crm_db_user;

--
-- Name: transport_types_id_seq; Type: SEQUENCE; Schema: public; Owner: crm_db_user
--

CREATE SEQUENCE public.transport_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.transport_types_id_seq OWNER TO crm_db_user;

--
-- Name: transport_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: crm_db_user
--

ALTER SEQUENCE public.transport_types_id_seq OWNED BY public.transport_types.id;


--
-- Name: weights; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.weights (
    weight numeric(8,0) NOT NULL
);


ALTER TABLE public.weights OWNER TO crm_db_user;

--
-- Name: workers; Type: TABLE; Schema: public; Owner: crm_db_user
--

CREATE TABLE public.workers (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    first_name character varying(20) NOT NULL,
    last_name character varying(20) NOT NULL,
    middle_name character varying(20) NOT NULL,
    mission_id integer NOT NULL,
    phone_number character varying(15) NOT NULL,
    login character varying(20) NOT NULL,
    password character varying(75) NOT NULL,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL
);


ALTER TABLE public.workers OWNER TO crm_db_user;

--
-- Name: border_workers id; Type: DEFAULT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.border_workers ALTER COLUMN id SET DEFAULT nextval('public.border_workers_id_seq'::regclass);


--
-- Name: borders id; Type: DEFAULT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.borders ALTER COLUMN id SET DEFAULT nextval('public.borders_id_seq'::regclass);


--
-- Name: card_dec id; Type: DEFAULT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.card_dec ALTER COLUMN id SET DEFAULT nextval('public.card_dec_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: category id; Type: DEFAULT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.category ALTER COLUMN id SET DEFAULT nextval('public.category_id_seq'::regclass);


--
-- Name: clients id; Type: DEFAULT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.clients ALTER COLUMN id SET DEFAULT nextval('public.clients_id_seq'::regclass);


--
-- Name: consents id; Type: DEFAULT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.consents ALTER COLUMN id SET DEFAULT nextval('public.consents_id_seq'::regclass);


--
-- Name: dec_balans id; Type: DEFAULT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.dec_balans ALTER COLUMN id SET DEFAULT nextval('public.dec_balans_id_seq'::regclass);


--
-- Name: dec_ord_images id; Type: DEFAULT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.dec_ord_images ALTER COLUMN id SET DEFAULT nextval('public.dec_ord_images_id_seq'::regclass);


--
-- Name: declarant_orders id; Type: DEFAULT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.declarant_orders ALTER COLUMN id SET DEFAULT nextval('public.declarant_orders_id_seq'::regclass);


--
-- Name: direction_costs id; Type: DEFAULT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.direction_costs ALTER COLUMN id SET DEFAULT nextval('public.direction_costs_id_seq'::regclass);


--
-- Name: exes id; Type: DEFAULT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.exes ALTER COLUMN id SET DEFAULT nextval('public.exes_id_seq'::regclass);


--
-- Name: images id; Type: DEFAULT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.images ALTER COLUMN id SET DEFAULT nextval('public.images_id_seq'::regclass);


--
-- Name: missions id; Type: DEFAULT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.missions ALTER COLUMN id SET DEFAULT nextval('public.missions_id_seq'::regclass);


--
-- Name: order_details id; Type: DEFAULT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.order_details ALTER COLUMN id SET DEFAULT nextval('public.order_details_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Name: pay_money id; Type: DEFAULT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.pay_money ALTER COLUMN id SET DEFAULT nextval('public.pay_money_id_seq'::regclass);


--
-- Name: rent_types id; Type: DEFAULT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.rent_types ALTER COLUMN id SET DEFAULT nextval('public.rent_types_id_seq'::regclass);


--
-- Name: routes transport_type_id; Type: DEFAULT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.routes ALTER COLUMN transport_type_id SET DEFAULT nextval('public.routes_transport_type_id_seq'::regclass);


--
-- Name: sub_category id; Type: DEFAULT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.sub_category ALTER COLUMN id SET DEFAULT nextval('public.sub_category_id_seq'::regclass);


--
-- Name: sub_sub id; Type: DEFAULT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.sub_sub ALTER COLUMN id SET DEFAULT nextval('public.sub_sub_id_seq'::regclass);


--
-- Name: test id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test ALTER COLUMN id SET DEFAULT nextval('public.test_id_seq'::regclass);


--
-- Name: test_1 id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_1 ALTER COLUMN id SET DEFAULT nextval('public.test_1_id_seq'::regclass);


--
-- Name: test_2 id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_2 ALTER COLUMN id SET DEFAULT nextval('public.test_2_id_seq'::regclass);


--
-- Name: trans_tp_workers id; Type: DEFAULT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.trans_tp_workers ALTER COLUMN id SET DEFAULT nextval('public.trans_tp_workers_id_seq'::regclass);


--
-- Name: transport_types id; Type: DEFAULT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.transport_types ALTER COLUMN id SET DEFAULT nextval('public.transport_types_id_seq'::regclass);


--
-- Data for Name: admins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admins (id, first_name, last_name, middle_name, role, phone_number, login, password, created_at) FROM stdin;
c93b68a0-570e-4a00-996b-4eeb014e3195	Akmuhammet	Akmyradow	Akmyradowic	superadmin	+99361394459	polat	$2a$09$CTRgPf544eobhC2XpiQun.rh0yrcWWfQv7y57CpcxGgGF7bp/8NpC	2022-06-04 21:02:42.335138+05
e6ca3197-8007-4105-9580-86abd725c329	Akmuhammet	Akmyradow	Akmyradowic	superadmin	+99361394459	polat	$2a$09$CTRgPf544eobhC2XpiQun.rh0yrcWWfQv7y57CpcxGgGF7bp/8NpC	2022-06-04 21:03:57.059418+05
\.


--
-- Data for Name: border_workers; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.border_workers (id, worker_id, border_id, created_at) FROM stdin;
1	063e42a6-1274-4d4d-9575-3dec8045c823	1	2022-06-04 22:25:40.68582+05
3	2f5b8d6d-4dcc-41d4-b659-92d8e00ddd88	2	2022-06-06 15:03:50.608606+05
4	0d5998ee-f4c3-413d-bd6a-3d631895720a	3	2022-06-13 10:05:35.842728+05
5	02cd0980-b433-4c35-8b58-433c1bc5a4e9	4	2022-06-15 15:47:03.474838+05
6	4437c04a-2137-4fbf-aea8-22a481a1a24a	1	2022-08-01 10:08:45.163807+05
7	09f6bf9a-d5e2-4a9b-b6cd-3f8b489ca5ce	3	2022-08-08 13:15:09.977382+05
8	a24e3c7d-b03b-4c66-b17e-1823de626d64	7	2022-08-08 13:16:04.518012+05
9	80987747-3411-4700-9dde-7fc93a0ac2b8	4	2022-08-08 16:59:56.010835+05
\.


--
-- Data for Name: borders; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.borders (id, name, created_at) FROM stdin;
1	Артык	2022-06-04 22:23:51.782024+05
2	Сарахс	2022-06-04 22:24:25.865617+05
3	Фарап	2022-06-04 22:24:38.503407+05
4	Гушгы	2022-06-04 22:24:50.291282+05
5	Тахтабазар	2022-06-04 22:25:06.271481+05
7	ozbek	2022-08-08 13:15:50.63635+05
10	Perestavitel	2022-08-17 17:12:36.175829+05
\.


--
-- Data for Name: card_dec; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.card_dec (id, dec_order_id, cmr, total_dol, total_tmt, type, yedek_2, created_at) FROM stdin;
207	211		0	0	input	\N	2022-08-23 17:35:48.552051+05
208	211		0	0	output	\N	2022-08-23 17:35:48.564945+05
210	212		0	0	output	\N	2022-08-23 17:36:42.099302+05
209	212	1487	0	0	input	\N	2022-08-23 17:36:42.099269+05
212	213		0	0	output	\N	2022-08-23 17:40:47.130594+05
211	213	2783	0	0	input	\N	2022-08-23 17:40:47.130575+05
213	214		50	50	input	\N	2022-08-23 17:40:59.212023+05
214	214		30	700	output	\N	2022-08-23 17:40:59.21205+05
215	215		0	0	input	\N	2022-08-24 16:35:12.148376+05
216	215		0	0	output	\N	2022-08-24 16:35:12.148408+05
217	216	2790	0	0	input	\N	2022-08-24 16:36:22.27807+05
218	216	2790	0	0	output	\N	2022-08-24 16:36:22.278114+05
220	217		0	0	output	\N	2022-08-26 17:22:39.480719+05
219	217	1487	0	0	input	\N	2022-08-26 17:22:39.467904+05
221	220		0	0	input	\N	2022-09-03 11:28:54.337721+05
222	220		0	0	output	\N	2022-09-03 11:28:54.367962+05
224	221		105	1110	output	\N	2022-09-03 11:33:38.286603+05
225	222		0	0	input	\N	2022-09-03 11:35:58.732202+05
226	222		0	0	output	\N	2022-09-03 11:35:58.732354+05
227	223		0	0	input	\N	2022-09-03 11:37:50.654145+05
228	223		0	0	output	\N	2022-09-03 11:37:50.654267+05
229	224		0	0	input	\N	2022-09-03 11:41:11.622467+05
230	224		0	0	output	\N	2022-09-03 11:41:11.622523+05
223	221	12345	50	50	input	\N	2022-09-03 11:33:38.286571+05
231	225		0	0	input	\N	2022-09-03 11:41:58.009849+05
232	225		0	0	output	\N	2022-09-03 11:41:58.009977+05
233	226		0	0	input	\N	2022-09-03 11:42:42.849795+05
234	226		0	0	output	\N	2022-09-03 11:42:42.849922+05
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.categories (id, name, event, created_at) FROM stdin;
1	Бухгалтерия	accountant	2022-06-04 21:02:42.597386+05
2	Менеджеры	manager	2022-06-04 21:02:42.597895+05
3	Логисты	logist	2022-06-04 21:02:42.597925+05
4	Диспечеры	dispatcher	2022-06-04 21:02:42.59794+05
5	Дикларанты	declarant	2022-06-04 21:02:42.597951+05
6	Представители	representative	2022-06-04 21:02:42.597963+05
\.


--
-- Data for Name: category; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.category (id, name, created_at) FROM stdin;
1	A	2022-07-04 15:48:53.927306+05
2	B	2022-07-04 15:48:53.927788+05
3	C	2022-07-04 15:48:53.927818+05
4	D	2022-07-04 15:48:53.927826+05
\.


--
-- Data for Name: cities; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.cities (id, name, country_id, is_border, created_at) FROM stdin;
dfcc13f8-d2e8-4479-ba10-abd680656721	Lotfabat	9874281c-cac5-4355-8bfa-971630e659f6	f	2022-07-21 12:33:06.118396+05
2b3f7bcc-9b24-4cdf-a063-7e2a089ea230	Mary	081db579-cb20-40cf-a32f-6aaac5e2894e	f	2022-07-21 12:35:47.066356+05
efd9373e-940f-4baf-90cb-854458a556c7	Tejen	081db579-cb20-40cf-a32f-6aaac5e2894e	f	2022-07-21 12:45:03.944978+05
29928035-700e-42d9-ae4f-504e1e3c1b69	kmsdklf	9874281c-cac5-4355-8bfa-971630e659f6	f	2022-07-21 12:46:16.130179+05
ab5aa81b-5b6c-478b-bd91-d58a78b23639	Farap	efe7171c-0404-4ab6-98a2-8e904b283a74	f	2022-07-21 12:46:58.420468+05
f19d0cee-c482-4d08-a6f2-23da68acfbee	fkln34lk	9874281c-cac5-4355-8bfa-971630e659f6	f	2022-07-21 12:47:35.831622+05
fa1b85ca-3f00-42df-b5ad-dd1131c50314	wedkln24	081db579-cb20-40cf-a32f-6aaac5e2894e	f	2022-07-21 12:48:54.963172+05
11a24246-0502-4070-849c-9b6f04df12ce	Hmmm	efe7171c-0404-4ab6-98a2-8e904b283a74	f	2022-07-21 12:49:29.111522+05
eddaad1b-d562-45b2-b0d6-dc0e63d47b39	daaaaaa	9874281c-cac5-4355-8bfa-971630e659f6	f	2022-07-21 12:51:44.217026+05
729ffec2-0c24-4e12-9df1-9464b07d2028	dzsfxgchjbkm	081db579-cb20-40cf-a32f-6aaac5e2894e	f	2022-07-21 12:52:33.056838+05
ff20a8d7-1b2c-4c62-9974-fe1ea4fc0e4a	Hawa	efe7171c-0404-4ab6-98a2-8e904b283a74	f	2022-07-21 12:53:08.583864+05
eceb3e7e-d97b-4019-90cb-90d73205a053	Goooraaayyydaaa	081db579-cb20-40cf-a32f-6aaac5e2894e	f	2022-07-21 12:53:34.907551+05
57a29918-d191-49a5-a484-f7d199fff7a1	Gadam	081db579-cb20-40cf-a32f-6aaac5e2894e	f	2022-07-21 12:57:33.745978+05
bfbd77ff-c53c-4c62-a6b2-0bc02ac0b627	gaaadaaammmm	efe7171c-0404-4ab6-98a2-8e904b283a74	f	2022-07-21 13:10:40.529568+05
cb6323f0-55c0-4927-b9a2-bffe6b5d80c3	Sarakhs Iran	9874281c-cac5-4355-8bfa-971630e659f6	f	2022-07-24 15:43:45.150407+05
55b75a53-e5dd-42f6-b320-63015897b1e7	Ashgabat	081db579-cb20-40cf-a32f-6aaac5e2894e	f	2022-07-24 15:44:11.800842+05
\.


--
-- Data for Name: client_payment_history; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.client_payment_history (id, client_id, order_id, before_payment, payment_date, paid, who_paid, created_at) FROM stdin;
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.clients (id, f_name, l_name, phone, email, company, rating, is_vip, payment, created_at) FROM stdin;
2	Annaoraz	Orazov	993111111	oraz	salam	5	t	6500	2022-06-04 22:29:43.445424+05
4	Cary	Hanjay	+99356565656	cary@salam.tm	salam	4	f	2000	2022-06-07 13:38:14.277822+05
3	Hemra	Rejep	99354545454	rejep	music	3	f	2340	2022-06-04 22:30:26.464232+05
1	Merdan	Nuryyev	99385858585	merdan	turkmenportal	5	f	3650	2022-06-04 22:29:06.126295+05
\.


--
-- Data for Name: consents; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.consents (id, worker_id, category_id, is_view, is_edit, created_at) FROM stdin;
91	bdfbaf91-c951-4995-8e06-808c8a145f1f	1	f	f	2022-06-06 23:28:44.629763+05
92	bdfbaf91-c951-4995-8e06-808c8a145f1f	2	f	f	2022-06-06 23:28:44.629924+05
93	bdfbaf91-c951-4995-8e06-808c8a145f1f	3	f	f	2022-06-06 23:28:44.630003+05
94	bdfbaf91-c951-4995-8e06-808c8a145f1f	4	f	f	2022-06-06 23:28:44.630075+05
95	bdfbaf91-c951-4995-8e06-808c8a145f1f	5	f	f	2022-06-06 23:28:44.630145+05
96	bdfbaf91-c951-4995-8e06-808c8a145f1f	6	f	f	2022-06-06 23:28:44.630216+05
7	24e89def-06fe-40d5-b695-1663b7397b06	1	f	f	2022-06-04 22:19:19.717916+05
8	24e89def-06fe-40d5-b695-1663b7397b06	2	f	f	2022-06-04 22:19:19.718183+05
9	24e89def-06fe-40d5-b695-1663b7397b06	3	f	f	2022-06-04 22:19:19.718266+05
10	24e89def-06fe-40d5-b695-1663b7397b06	4	f	f	2022-06-04 22:19:19.718339+05
11	24e89def-06fe-40d5-b695-1663b7397b06	5	f	f	2022-06-04 22:19:19.718409+05
12	24e89def-06fe-40d5-b695-1663b7397b06	6	f	f	2022-06-04 22:19:19.71848+05
19	063e42a6-1274-4d4d-9575-3dec8045c823	1	f	f	2022-06-04 22:25:40.646082+05
20	063e42a6-1274-4d4d-9575-3dec8045c823	2	f	f	2022-06-04 22:25:40.646351+05
21	063e42a6-1274-4d4d-9575-3dec8045c823	3	f	f	2022-06-04 22:25:40.646436+05
22	063e42a6-1274-4d4d-9575-3dec8045c823	4	f	f	2022-06-04 22:25:40.646509+05
23	063e42a6-1274-4d4d-9575-3dec8045c823	5	f	f	2022-06-04 22:25:40.64658+05
24	063e42a6-1274-4d4d-9575-3dec8045c823	6	f	f	2022-06-04 22:25:40.646651+05
145	80987747-3411-4700-9dde-7fc93a0ac2b8	1	f	f	2022-08-08 16:59:55.977035+05
146	80987747-3411-4700-9dde-7fc93a0ac2b8	2	f	f	2022-08-08 16:59:55.992088+05
147	80987747-3411-4700-9dde-7fc93a0ac2b8	3	f	f	2022-08-08 16:59:55.992234+05
99	2c3f130e-c267-4282-bd6b-5f1c66bed953	3	t	t	2022-06-07 13:34:24.626283+05
148	80987747-3411-4700-9dde-7fc93a0ac2b8	4	f	f	2022-08-08 16:59:55.992358+05
31	884bdb74-46a8-41a3-9be7-b04de6b41b59	1	f	f	2022-06-04 23:09:00.479038+05
32	884bdb74-46a8-41a3-9be7-b04de6b41b59	2	f	f	2022-06-04 23:09:00.479311+05
34	884bdb74-46a8-41a3-9be7-b04de6b41b59	4	f	f	2022-06-04 23:09:00.479467+05
35	884bdb74-46a8-41a3-9be7-b04de6b41b59	5	f	f	2022-06-04 23:09:00.479537+05
36	884bdb74-46a8-41a3-9be7-b04de6b41b59	6	f	f	2022-06-04 23:09:00.479608+05
150	80987747-3411-4700-9dde-7fc93a0ac2b8	6	f	f	2022-08-08 16:59:55.992594+05
149	80987747-3411-4700-9dde-7fc93a0ac2b8	5	t	t	2022-08-08 16:59:55.992476+05
97	2c3f130e-c267-4282-bd6b-5f1c66bed953	1	t	t	2022-06-07 13:34:24.582774+05
98	2c3f130e-c267-4282-bd6b-5f1c66bed953	2	t	t	2022-06-07 13:34:24.625794+05
100	2c3f130e-c267-4282-bd6b-5f1c66bed953	4	t	t	2022-06-07 13:34:24.626616+05
33	884bdb74-46a8-41a3-9be7-b04de6b41b59	3	f	f	2022-06-04 23:09:00.479395+05
44	2261bfe6-7dad-4f5e-aa81-e3a657c8a54e	2	f	f	2022-06-04 23:20:11.792179+05
45	2261bfe6-7dad-4f5e-aa81-e3a657c8a54e	3	f	f	2022-06-04 23:20:11.792285+05
46	2261bfe6-7dad-4f5e-aa81-e3a657c8a54e	4	f	f	2022-06-04 23:20:11.792361+05
47	2261bfe6-7dad-4f5e-aa81-e3a657c8a54e	5	f	f	2022-06-04 23:20:11.792432+05
48	2261bfe6-7dad-4f5e-aa81-e3a657c8a54e	6	f	f	2022-06-04 23:20:11.792502+05
101	2c3f130e-c267-4282-bd6b-5f1c66bed953	5	t	t	2022-06-07 13:34:24.626918+05
102	2c3f130e-c267-4282-bd6b-5f1c66bed953	6	t	t	2022-06-07 13:34:24.627205+05
103	0d5998ee-f4c3-413d-bd6a-3d631895720a	6	f	f	2022-06-13 10:05:35.776274+05
104	0d5998ee-f4c3-413d-bd6a-3d631895720a	1	f	f	2022-06-13 10:05:35.831089+05
105	0d5998ee-f4c3-413d-bd6a-3d631895720a	2	f	f	2022-06-13 10:05:35.831188+05
106	0d5998ee-f4c3-413d-bd6a-3d631895720a	3	f	f	2022-06-13 10:05:35.831265+05
56	2f5b8d6d-4dcc-41d4-b659-92d8e00ddd88	2	f	f	2022-06-06 15:03:50.590657+05
57	2f5b8d6d-4dcc-41d4-b659-92d8e00ddd88	3	f	f	2022-06-06 15:03:50.591259+05
58	2f5b8d6d-4dcc-41d4-b659-92d8e00ddd88	4	f	f	2022-06-06 15:03:50.591783+05
59	2f5b8d6d-4dcc-41d4-b659-92d8e00ddd88	5	f	f	2022-06-06 15:03:50.592287+05
60	2f5b8d6d-4dcc-41d4-b659-92d8e00ddd88	6	f	f	2022-06-06 15:03:50.592943+05
55	2f5b8d6d-4dcc-41d4-b659-92d8e00ddd88	1	t	f	2022-06-06 15:03:50.588229+05
107	0d5998ee-f4c3-413d-bd6a-3d631895720a	4	f	f	2022-06-13 10:05:35.831339+05
108	0d5998ee-f4c3-413d-bd6a-3d631895720a	5	t	t	2022-06-13 10:05:35.831413+05
109	02cd0980-b433-4c35-8b58-433c1bc5a4e9	1	f	f	2022-06-15 15:47:03.425871+05
110	02cd0980-b433-4c35-8b58-433c1bc5a4e9	2	f	f	2022-06-15 15:47:03.44791+05
111	02cd0980-b433-4c35-8b58-433c1bc5a4e9	3	f	f	2022-06-15 15:47:03.448002+05
112	02cd0980-b433-4c35-8b58-433c1bc5a4e9	4	f	f	2022-06-15 15:47:03.448084+05
113	02cd0980-b433-4c35-8b58-433c1bc5a4e9	5	f	f	2022-06-15 15:47:03.448163+05
114	02cd0980-b433-4c35-8b58-433c1bc5a4e9	6	f	f	2022-06-15 15:47:03.448242+05
115	4437c04a-2137-4fbf-aea8-22a481a1a24a	1	f	f	2022-08-01 10:08:45.108087+05
116	4437c04a-2137-4fbf-aea8-22a481a1a24a	2	f	f	2022-08-01 10:08:45.129698+05
117	4437c04a-2137-4fbf-aea8-22a481a1a24a	3	f	f	2022-08-01 10:08:45.12983+05
118	4437c04a-2137-4fbf-aea8-22a481a1a24a	4	f	f	2022-08-01 10:08:45.129927+05
120	4437c04a-2137-4fbf-aea8-22a481a1a24a	6	f	f	2022-08-01 10:08:45.130109+05
119	4437c04a-2137-4fbf-aea8-22a481a1a24a	5	t	t	2022-08-01 10:08:45.130018+05
124	25317cdb-61cf-44bf-9fa7-10e12992a739	2	f	f	2022-08-08 12:27:00.754582+05
127	25317cdb-61cf-44bf-9fa7-10e12992a739	3	f	f	2022-08-08 12:27:00.754683+05
129	25317cdb-61cf-44bf-9fa7-10e12992a739	4	f	f	2022-08-08 12:27:00.75476+05
131	25317cdb-61cf-44bf-9fa7-10e12992a739	5	f	f	2022-08-08 12:27:00.754832+05
132	25317cdb-61cf-44bf-9fa7-10e12992a739	6	f	f	2022-08-08 12:27:00.754906+05
43	2261bfe6-7dad-4f5e-aa81-e3a657c8a54e	1	t	f	2022-06-04 23:20:11.791891+05
121	25317cdb-61cf-44bf-9fa7-10e12992a739	1	t	t	2022-08-08 12:27:00.732835+05
133	09f6bf9a-d5e2-4a9b-b6cd-3f8b489ca5ce	1	f	f	2022-08-08 13:15:09.936617+05
134	09f6bf9a-d5e2-4a9b-b6cd-3f8b489ca5ce	2	f	f	2022-08-08 13:15:09.937044+05
135	09f6bf9a-d5e2-4a9b-b6cd-3f8b489ca5ce	3	f	f	2022-08-08 13:15:09.93713+05
136	09f6bf9a-d5e2-4a9b-b6cd-3f8b489ca5ce	4	f	f	2022-08-08 13:15:09.937203+05
138	09f6bf9a-d5e2-4a9b-b6cd-3f8b489ca5ce	6	f	f	2022-08-08 13:15:09.937345+05
137	09f6bf9a-d5e2-4a9b-b6cd-3f8b489ca5ce	5	t	t	2022-08-08 13:15:09.937274+05
139	a24e3c7d-b03b-4c66-b17e-1823de626d64	1	f	f	2022-08-08 13:16:04.479201+05
140	a24e3c7d-b03b-4c66-b17e-1823de626d64	2	f	f	2022-08-08 13:16:04.479625+05
141	a24e3c7d-b03b-4c66-b17e-1823de626d64	3	f	f	2022-08-08 13:16:04.479741+05
142	a24e3c7d-b03b-4c66-b17e-1823de626d64	4	f	f	2022-08-08 13:16:04.479818+05
143	a24e3c7d-b03b-4c66-b17e-1823de626d64	5	f	f	2022-08-08 13:16:04.47989+05
144	a24e3c7d-b03b-4c66-b17e-1823de626d64	6	f	f	2022-08-08 13:16:04.479965+05
\.


--
-- Data for Name: countries; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.countries (id, name, created_at) FROM stdin;
9874281c-cac5-4355-8bfa-971630e659f6	Iran	2022-06-04 21:02:42.0277+05
081db579-cb20-40cf-a32f-6aaac5e2894e	Turkmenistan	2022-06-04 21:02:42.028192+05
efe7171c-0404-4ab6-98a2-8e904b283a74	Uzbekistan	2022-06-04 21:02:42.028241+05
\.


--
-- Data for Name: cover_types; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.cover_types (id, name, created_at) FROM stdin;
4264fa1a-0fe7-4b1c-ab01-bb1f5b1eb8d0	testttttt	2022-07-25 17:21:23.786189+05
06ba2509-a7be-4756-beea-edeb7e3c9196	bbbb	2022-07-25 17:28:56.004911+05
350e7bdf-05ba-4c1b-ae21-3a383619bc12	Tip	2022-07-25 17:57:04.791544+05
\.


--
-- Data for Name: dec_balans; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.dec_balans (id, border_id, why, dol, tmt, balanc_dol, balanc_tmt, type, created_at, card_id, is_view, is_dec_dop_ras) FROM stdin;
570	10	mary	1500	0	0	0	in	2022-08-18 16:55:26.128883+05	0	t	f
603	10	Zakaz ucin tolendi	2000	0	0	0	in	2022-08-18 17:02:10.240756+05	202	f	f
563	10	Zakaz ucin tolendi	100	0	0	0	out	2022-08-18 16:52:30.717735+05	202	f	f
585	10	Zakaz ucin tolendi	100	0	0	0	in	2022-08-18 16:58:37.838476+05	202	f	f
586	10	Zakaz ucin tolendi	0	0	0	0	out	2022-08-18 16:58:37.860066+05	202	f	f
604	10	Zakaz ucin tolendi	0	0	0	0	out	2022-08-18 17:02:10.278736+05	202	t	f
555	10	Delete edileni ucin yzyna gaytarlan toleg	650	0	0	0	in	2022-08-18 16:48:53.476551+05	206	f	f
575	10	Zakaz ucin tolendi	500	0	0	0	in	2022-08-18 16:56:13.426814+05	203	f	f
611	1	test	2000	1000	0	0	in	2022-08-23 17:31:04.36849+05	0	t	f
564	10	Zakaz ucin tolendi	500	0	0	0	out	2022-08-18 16:53:16.861947+05	203	f	f
576	10	Zakaz ucin tolendi	1500	0	0	0	out	2022-08-18 16:56:13.448293+05	203	f	f
577	10	Zakaz ucin tolendi	1500	0	0	0	in	2022-08-18 16:57:24.861168+05	203	f	f
578	10	Zakaz ucin tolendi	1500	0	0	0	out	2022-08-18 16:57:24.893392+05	203	f	f
579	10	Zakaz ucin tolendi	1500	0	0	0	in	2022-08-18 16:57:35.836732+05	203	f	f
580	10	Zakaz ucin tolendi	0	0	0	0	out	2022-08-18 16:57:35.858141+05	203	f	f
613	1	CMR : 1487 zakaz ucin tolendi	0	0	0	0	out	2022-08-23 17:38:26.126+05	209	t	f
615	1	Zakaz ucin tolendi	50	50	0	0	out	2022-08-24 16:33:56.299593+05	213	t	f
617	1	CMR : 2790 zakaz ucin tolendi	0	0	0	0	out	2022-08-24 17:42:12.192984+05	217	t	f
618	1	CMR : 2790 zakaz ucin tolendi	0	0	0	0	out	2022-08-26 15:24:55.06062+05	218	t	f
620	4	CMR : 1487 zakaz ucin tolendi	0	0	0	0	out	2022-08-26 17:22:58.415118+05	219	t	f
621	4	mary kassadan	1000	20000	0	0	in	2022-09-03 11:30:07.069142+05	0	t	f
623	4	Zakaz ucin tolendi	105	1110	0	0	out	2022-09-03 11:34:45.127149+05	224	f	f
624	4	Zakaz ucin tolendi	105	1110	0	0	in	2022-09-03 11:35:03.739302+05	224	f	f
625	4	Zakaz ucin tolendi	105	1110	0	0	out	2022-09-03 11:35:04.23313+05	224	t	f
627	4	taxi toleg	0	100	0	0	out	2022-09-03 11:45:50.352315+05	0	t	t
556	10	Delete edileni ucin yzyna gaytarlan toleg	275	0	0	0	in	2022-08-18 16:48:55.3207+05	207	f	f
557	10	test 111111	925	0	0	0	out	2022-08-18 16:49:47.003701+05	0	t	f
581	10	Zakaz ucin tolendi	500	0	0	0	in	2022-08-18 16:57:46.057209+05	204	f	f
569	10	Zakaz ucin tolendi	500	0	0	0	out	2022-08-18 16:54:32.521946+05	204	f	f
582	10	Zakaz ucin tolendi	0	0	0	0	out	2022-08-18 16:57:46.077744+05	204	t	f
565	10	mary kassa	1500	0	0	0	in	2022-08-18 16:53:30.700403+05	0	t	f
566	10	klient	1000	0	0	0	in	2022-08-18 16:53:44.773575+05	0	t	f
571	10	Zakaz ucin tolendi	2900	0	0	0	in	2022-08-18 16:55:48.876432+05	201	f	f
558	10	Zakaz ucin tolendi	400	0	0	0	out	2022-08-18 16:51:29.00046+05	201	f	f
559	10	Zakaz ucin tolendi	400	0	0	0	in	2022-08-18 16:51:49.739512+05	201	f	f
560	10	Zakaz ucin tolendi	1400	0	0	0	out	2022-08-18 16:51:49.759304+05	201	f	f
561	10	Zakaz ucin tolendi	1400	0	0	0	in	2022-08-18 16:52:07.799859+05	201	f	f
562	10	Zakaz ucin tolendi	1900	0	0	0	out	2022-08-18 16:52:07.820614+05	201	f	f
567	10	Zakaz ucin tolendi	1900	0	0	0	in	2022-08-18 16:54:04.910582+05	201	f	f
568	10	Zakaz ucin tolendi	2900	0	0	0	out	2022-08-18 16:54:04.936057+05	201	f	f
572	10	Zakaz ucin tolendi	1900	0	0	0	out	2022-08-18 16:55:48.897423+05	201	f	f
595	10	Zakaz ucin tolendi	0	0	0	0	in	2022-08-18 17:00:42.232956+05	202	f	f
589	10	Zakaz ucin tolendi	0	0	0	0	in	2022-08-18 16:59:08.702906+05	203	f	f
590	10	Zakaz ucin tolendi	2000	0	0	0	out	2022-08-18 16:59:08.723263+05	203	f	f
591	10	Zakaz ucin tolendi	2000	0	0	0	in	2022-08-18 16:59:51.043877+05	203	f	f
592	10	Zakaz ucin tolendi	0	0	0	0	out	2022-08-18 16:59:51.065216+05	203	t	f
596	10	Zakaz ucin tolendi	4000	0	0	0	out	2022-08-18 17:00:42.24982+05	202	f	f
597	10	Zakaz ucin tolendi	4000	0	0	0	in	2022-08-18 17:00:59.043521+05	202	f	f
598	10	Zakaz ucin tolendi	2000	0	0	0	out	2022-08-18 17:00:59.064695+05	202	f	f
605	10	Zakaz ucin tolendi	2000	0	0	0	out	2022-08-18 17:03:05.76618+05	205	f	f
607	10	Zakaz ucin tolendi	2000	0	0	0	in	2022-08-18 17:03:25.087162+05	205	f	f
608	10	Zakaz ucin tolendi	0	0	0	0	out	2022-08-18 17:03:25.108455+05	205	t	f
606	10	Zakaz ucin tolendi	3000	0	0	0	out	2022-08-18 17:03:14.901982+05	206	f	f
609	10	Zakaz ucin tolendi	3000	0	0	0	in	2022-08-18 17:03:38.969005+05	206	f	f
610	10	Zakaz ucin tolendi	4000	0	0	0	out	2022-08-18 17:03:38.991651+05	206	t	f
612	1	sjjssj	200	500	0	0	in	2022-08-23 17:31:22.51181+05	0	t	f
614	1	CMR : 2783 zakaz ucin tolendi	0	0	0	0	out	2022-08-23 17:41:07.320642+05	211	t	f
616	1	Zakaz ucin tolendi	30	700	0	0	out	2022-08-24 16:34:28.75492+05	214	t	f
619	4	test	1000	1000	0	0	in	2022-08-26 17:22:17.536177+05	0	t	f
573	10	Zakaz ucin tolendi	1900	0	0	0	in	2022-08-18 16:56:03.246044+05	201	f	f
574	10	Zakaz ucin tolendi	2900	0	0	0	out	2022-08-18 16:56:03.267436+05	201	f	f
583	10	Zakaz ucin tolendi	2900	0	0	0	in	2022-08-18 16:58:20.727556+05	201	f	f
584	10	Zakaz ucin tolendi	0	0	0	0	out	2022-08-18 16:58:20.748515+05	201	f	f
587	10	Zakaz ucin tolendi	0	0	0	0	in	2022-08-18 16:58:55.515083+05	201	f	f
588	10	Zakaz ucin tolendi	4000	0	0	0	out	2022-08-18 16:58:55.535481+05	201	f	f
593	10	Zakaz ucin tolendi	4000	0	0	0	in	2022-08-18 17:00:15.927206+05	201	f	f
594	10	Zakaz ucin tolendi	0	0	0	0	out	2022-08-18 17:00:15.948457+05	201	f	f
599	10	Zakaz ucin tolendi	0	0	0	0	in	2022-08-18 17:01:11.114709+05	201	f	f
600	10	Zakaz ucin tolendi	2000	0	0	0	out	2022-08-18 17:01:11.134722+05	201	f	f
601	10	Zakaz ucin tolendi	2000	0	0	0	in	2022-08-18 17:01:29.082385+05	201	f	f
602	10	Zakaz ucin tolendi	0	0	0	0	out	2022-08-18 17:01:29.122888+05	201	t	f
622	4	kwartira toleg gayry cykdayjy	0	5000	0	0	out	2022-09-03 11:30:35.402257+05	0	t	t
626	4	CMR : 12345 zakaz ucin tolendi	50	50	0	0	out	2022-09-03 11:41:21.800296+05	223	t	f
628	4	test	0	40	0	0	out	2022-09-03 11:47:23.329194+05	0	t	t
\.


--
-- Data for Name: dec_ord_images; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.dec_ord_images (id, card_dec_id, type, image_path, yedek_1, yedek_2, created_at) FROM stdin;
84	224	output	Uploads/files-224/1662186903239.jpg	\N	\N	2022-09-03 11:35:03.298953+05
85	223	input	Uploads/files-223/1662187281776.jpg	\N	\N	2022-09-03 11:41:21.777333+05
\.


--
-- Data for Name: declarant_orders; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.declarant_orders (id, type_id, border_id, trailer_number, direction, status, driver_name, driver_phone, created_at, b_status, cmr, order_type, mission, conten_num) FROM stdin;
222	\N	3	5590		f	gadam	+99367686970	2022-09-03 11:35:58.725543+05	f				
221	1	4	MR1212TM	artyk-buhara	t	aman	+99365656565	2022-09-03 11:33:38.285019+05	f	12345			
225	\N	3	7820		f	meret	78207681	2022-09-03 11:41:58.003943+05	f				
226	1	4	000TMR		f	aman	484959939	2022-09-03 11:42:42.844375+05	f				
224	\N	3	berdi		f	merdan	893429	2022-09-03 11:41:11.619667+05	f				
223	\N	3	kerim		f	mekan	+993567280	2022-09-03 11:37:50.647298+05	f				
211	1	1	fff	dhj	f	adgb	dghy	2022-08-23 17:35:48.333003+05	f		dfh		tghj
212	1	1	jkyi	rfhyt	f	tctc	dddd	2022-08-23 17:36:42.097414+05	f	1487	dghjj		sfgh
214	2	1	zjznz	djdnd	f	djejen	dhdnd	2022-08-23 17:40:59.210169+05	f				dhsnsdbs
213	1	1	sjjss	hdbsnss	f	hxbdb	hdbn	2022-08-23 17:40:47.129352+05	f	2783			hxbdbd
215	1	1	ccccc	hhhhh	f	mmmmm	ttttt	2022-08-24 16:35:12.095762+05	f		dddff		nnnn
216	1	1	eeee	www	f	nnnn	kkkk	2022-08-24 16:36:22.275494+05	f	2790	ssa		ggggg
217	2	4	sggchc	abababa	f	weqewew	hjjhb	2022-08-26 17:22:39.119047+05	f	1487	ttttxhufgijc		bsbsbs
220	2	4	2020TMR		f	aman	+99365000000	2022-09-03 11:28:54.123648+05	f				
\.


--
-- Data for Name: direction_cost_columns; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.direction_cost_columns (id, direction_cost_id, name, created_at) FROM stdin;
4ed544c6-1745-4305-ab3d-362d341f745c	1	From	2022-06-04 22:57:18.56253+05
93f0e55d-8dd6-4215-b643-3f8f40a51692	1	To	2022-06-04 22:57:18.562628+05
aec4bf3a-c19e-4642-b71f-bbb1fbef6b8f	4	Other expenses	2022-06-04 22:57:18.563224+05
0f237a33-bc95-4fe7-a26b-2f5d88f58d2f	4	Total costs	2022-06-04 22:57:18.563237+05
97402aed-c386-49c6-bd0a-44bf24415a1e	4	Total for offer	2022-06-04 22:57:18.563243+05
4b3e4671-7482-4135-a290-ba8c1300600c	4	Profit	2022-06-04 22:57:18.563249+05
a88d1ef3-e9f9-4d7c-8a6c-444faf870a1b	17	From	2022-06-09 20:51:46.115452+05
fb66931f-6d2c-4cfd-b64d-26d96765e8a5	17	To	2022-06-09 20:51:46.11557+05
4a1d50ff-4397-4a51-a0db-04e4d7d04938	20	Other expenses	2022-06-09 20:51:46.119085+05
30f02a81-ac5b-452b-822c-d44814ec500a	20	Total costs	2022-06-09 20:51:46.11913+05
7da69ae4-fd30-4514-9b1b-8624aaadfb03	20	Total for offer	2022-06-09 20:51:46.119157+05
cfde793d-e721-418b-b525-5a1dcd0c8fda	20	Profit	2022-06-09 20:51:46.11918+05
d34a305e-e809-4ab2-a7c5-717b130f56d8	2	wqdwe	2022-06-09 22:11:49.244734+05
e76d528b-7079-4ad9-8fed-17ec5f216cc9	2	hjgj	2022-06-09 22:12:23.560153+05
4e667ad9-7c25-496b-bd85-096e5cbbedbf	19	Kelle baha	2022-06-10 10:14:55.373916+05
3f67523e-3026-44ca-9b14-dbfc0d6dba7c	9	From	2022-06-04 23:06:51.38941+05
337290d6-3916-4f12-9fdb-70ddf16e4266	9	To	2022-06-04 23:06:51.389457+05
1c0ffbbe-b5a0-4370-aa31-e6e365be1803	12	Other expenses	2022-06-04 23:06:51.39118+05
90a95263-8c84-4d15-928d-82980fcfe19b	12	Total costs	2022-06-04 23:06:51.391202+05
601251df-575c-4294-9375-59cffda0bd7c	12	Total for offer	2022-06-04 23:06:51.391216+05
e410dd6d-6cc7-4109-bbf3-603fbcbc5447	12	Profit	2022-06-04 23:06:51.391229+05
ee25f607-1d5b-4ce4-92e4-832a22517557	10	Sarahs	2022-06-04 23:14:56.947232+05
debc3de0-e486-4a36-af07-cac27ae50b41	19	Prsep baha	2022-06-10 10:15:06.723796+05
7d61667b-8bc2-4bb1-8e59-e3eabda1c5b7	13	From	2022-06-06 15:52:28.981766+05
eea05edd-d988-474e-96f4-2efa98f8cadd	13	To	2022-06-06 15:52:29.002274+05
6802acfb-ba0c-4a26-8c00-d07f04563bb2	16	Other expenses	2022-06-06 15:52:29.004824+05
d9afb8ca-1ad5-4c07-bf36-a5433085c050	16	Total costs	2022-06-06 15:52:29.004869+05
3735d609-2abe-49cb-8601-e5d6db40b930	16	Total for offer	2022-06-06 15:52:29.004897+05
acd4de68-f00f-46ba-a916-3e2123901520	16	Profit	2022-06-06 15:52:29.004921+05
ce76e41d-2070-4b22-bce7-be46b74aa0ff	21	From	2022-06-10 16:04:54.060539+05
39a5965f-7391-4a59-95b2-96da5822f5e9	21	To	2022-06-10 16:04:54.060592+05
5cd23f2a-c208-477d-afe0-42a9b777f1d6	24	Other expenses	2022-06-10 16:04:54.062154+05
9b2d2116-a709-4073-a3ca-83ad20c66469	24	Total costs	2022-06-10 16:04:54.062171+05
ee530380-5bde-4848-86c9-e6bc24bf5321	24	Total for offer	2022-06-10 16:04:54.062181+05
e64db1c8-f677-417b-b378-fbe436b3eab1	24	Profit	2022-06-10 16:04:54.062189+05
d87fe68b-41aa-464f-9339-c852fb6fa831	3	a	2022-06-11 16:30:45.475789+05
a208cb62-fb68-4ee6-b4e7-f7901874bcbd	3	b	2022-06-11 16:30:54.090241+05
d0def9ae-09c7-497d-9ec2-8647c7574043	3	c	2022-06-11 16:31:01.450306+05
33ec2bf5-d6d3-4466-b16d-2c271eac632e	3	d	2022-06-11 16:31:31.242648+05
7c8a8b71-0cac-49f3-bd6f-cabf1e063d35	3	e	2022-06-11 16:31:35.933572+05
24f1640f-9b22-4d3b-a06e-c01033257d2d	25	From	2022-06-11 16:50:13.094856+05
200e6a50-defa-4e67-a0b1-baa3afd7a661	25	To	2022-06-11 16:50:13.094895+05
c3a3360b-c37f-4506-80f1-e1935924a379	28	Other expenses	2022-06-11 16:50:13.095807+05
1b4b8bc6-1a59-455f-afda-1bc86b39fca8	28	Total costs	2022-06-11 16:50:13.095822+05
3bb3a80c-7ec4-444a-af9b-859b4bbb8020	28	Total for offer	2022-06-11 16:50:13.09583+05
81f9d987-ee08-472a-8082-a0296c59540e	28	Profit	2022-06-11 16:50:13.095839+05
862a8b3d-5a02-4828-9d00-6a7d60b1a820	14	aaa	2022-06-11 16:50:20.752412+05
d8079bde-42cc-449e-8f8f-5adc1c59dae0	15	bbbbb	2022-06-11 16:50:29.474479+05
e9cd37ef-3011-4d5e-bf01-8baa68b0ab79	14	cccc	2022-06-11 16:50:34.724831+05
ceb33870-4009-47e3-9007-9899bd4ee429	14	eeee	2022-06-11 16:50:46.309483+05
3cc5f29c-33c7-45c6-a8a5-92ce0ee27d4f	26	asas	2022-06-11 16:51:06.065254+05
85f84f5c-8487-4901-9425-e96d8522b998	26	bvbvb	2022-06-11 16:51:11.836259+05
ffaf1ded-669c-4b8a-8e89-9e6215edf98b	27	ererer	2022-06-11 16:51:17.322561+05
4a094fd2-8ac7-4d13-8850-d58c9c67da71	27	trtrt	2022-06-11 16:51:22.353823+05
84f12eb7-5d78-4916-b56a-1125aaee6439	11	salam	2022-06-09 17:39:19.420476+05
4fada8c9-3784-4641-952d-14f6a9700145	487	Откуда	2022-07-25 15:23:37.045337+05
d06700eb-118a-4773-8bdd-6e03cb284b88	487	Куда	2022-07-25 15:23:37.04549+05
b5a6be64-b7c6-4513-931f-d0e4d41bc128	490	Других компаний	2022-07-25 15:23:37.051014+05
0cac319c-ac07-4bab-90af-994c4ee4c3d7	490	Суммарные затраты	2022-07-25 15:23:37.051067+05
3cdf4f53-03bd-4402-a3df-4a79c71c88b3	490	Общая стоимость предложения	2022-07-25 15:23:37.0511+05
e87861c4-50a8-453d-8c6a-1d1b9d88a54d	490	Выгода	2022-07-25 15:23:37.05113+05
\.


--
-- Data for Name: direction_costs; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.direction_costs (id, name, route_id, created_at) FROM stdin;
487	Направление	ce56b461-bd60-4f73-af14-a7c3023099d6	2022-07-25 15:23:37.032164+05
488	Регистрация	ce56b461-bd60-4f73-af14-a7c3023099d6	2022-07-25 15:23:37.043687+05
489	Цена за	ce56b461-bd60-4f73-af14-a7c3023099d6	2022-07-25 15:23:37.043706+05
490	Суммарные затраты	ce56b461-bd60-4f73-af14-a7c3023099d6	2022-07-25 15:23:37.043715+05
\.


--
-- Data for Name: direction_values; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.direction_values (id, direction_id, column_id, value, created_at) FROM stdin;
938898f5-23a2-4e4e-9f95-0b835175cb41	1e39f0a9-4e5d-4e0c-b86f-5977f9ecc2b1	0cac319c-ac07-4bab-90af-994c4ee4c3d7	0	2022-07-25 16:25:06.013921+05
349caf48-5be9-4f58-95bf-2bc81f82e280	1e39f0a9-4e5d-4e0c-b86f-5977f9ecc2b1	e87861c4-50a8-453d-8c6a-1d1b9d88a54d	160	2022-07-25 16:25:06.036203+05
9a748614-1d8c-495a-b1b0-bb7eac597879	ab4de928-8896-4358-8cbf-9cb21bf5c4db	0cac319c-ac07-4bab-90af-994c4ee4c3d7	0	2022-07-25 15:24:11.879822+05
72aada70-ecea-40e7-9d5f-8bb499f71e4c	ab4de928-8896-4358-8cbf-9cb21bf5c4db	e87861c4-50a8-453d-8c6a-1d1b9d88a54d	500	2022-07-25 15:24:11.902241+05
25877ed0-ad6d-4b44-b788-9a2b79d613f6	31042d98-cfbe-4233-b908-0e5c1d566577	0cac319c-ac07-4bab-90af-994c4ee4c3d7	0	2022-07-25 16:26:38.283756+05
b28c77c0-e5d8-4985-baba-bea31b7f149b	31042d98-cfbe-4233-b908-0e5c1d566577	e87861c4-50a8-453d-8c6a-1d1b9d88a54d	490	2022-07-25 16:26:38.306222+05
bc309367-6ddd-4a41-acd2-178680dae64d	1e39f0a9-4e5d-4e0c-b86f-5977f9ecc2b1	4fada8c9-3784-4641-952d-14f6a9700145	Ashgabat	2022-07-25 16:25:05.957606+05
7107866c-7598-4471-a7ff-ffa2eb56bf66	1e39f0a9-4e5d-4e0c-b86f-5977f9ecc2b1	d06700eb-118a-4773-8bdd-6e03cb284b88	gaaadaaammmm	2022-07-25 16:25:05.968821+05
1fe4ae64-8318-4a60-ab7a-459d941319b8	1e39f0a9-4e5d-4e0c-b86f-5977f9ecc2b1	b5a6be64-b7c6-4513-931f-d0e4d41bc128	 	2022-07-25 16:25:06.002511+05
3db1039a-42a1-403c-a581-07b5d5f80923	1e39f0a9-4e5d-4e0c-b86f-5977f9ecc2b1	3cdf4f53-03bd-4402-a3df-4a79c71c88b3	160	2022-07-25 16:25:06.025059+05
fd440560-2153-4d08-8189-e84a49c8239b	ab4de928-8896-4358-8cbf-9cb21bf5c4db	4fada8c9-3784-4641-952d-14f6a9700145	Farap	2022-07-25 15:24:11.823882+05
2c6e0106-6b3f-49a2-8837-ddc8493b5555	ab4de928-8896-4358-8cbf-9cb21bf5c4db	d06700eb-118a-4773-8bdd-6e03cb284b88	Lotfabat	2022-07-25 15:24:11.835486+05
99f6fa84-9b68-4ecc-baa3-409a2284610b	ab4de928-8896-4358-8cbf-9cb21bf5c4db	b5a6be64-b7c6-4513-931f-d0e4d41bc128	123	2022-07-25 15:24:11.868482+05
94eec2df-08dd-445a-8d54-0ea4ee946b97	ab4de928-8896-4358-8cbf-9cb21bf5c4db	3cdf4f53-03bd-4402-a3df-4a79c71c88b3	500	2022-07-25 15:24:11.891162+05
48b072d1-5a44-45d5-b53b-43cc067a8348	31042d98-cfbe-4233-b908-0e5c1d566577	4fada8c9-3784-4641-952d-14f6a9700145	dzsfxgchjbkm	2022-07-25 16:26:38.227958+05
faefa5ef-71f9-4d36-a156-3b33de65b482	31042d98-cfbe-4233-b908-0e5c1d566577	d06700eb-118a-4773-8bdd-6e03cb284b88	kmsdklf	2022-07-25 16:26:38.238951+05
53dbb5a2-e33e-4794-8c6a-e28bd2a290d9	31042d98-cfbe-4233-b908-0e5c1d566577	b5a6be64-b7c6-4513-931f-d0e4d41bc128	 	2022-07-25 16:26:38.27252+05
a14cc304-0b87-4de3-a887-4d3dad668625	31042d98-cfbe-4233-b908-0e5c1d566577	3cdf4f53-03bd-4402-a3df-4a79c71c88b3	490	2022-07-25 16:26:38.295074+05
\.


--
-- Data for Name: directions; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.directions (id, from_city_id, to_city_id, route_id, created_at) FROM stdin;
1e39f0a9-4e5d-4e0c-b86f-5977f9ecc2b1	55b75a53-e5dd-42f6-b320-63015897b1e7	bfbd77ff-c53c-4c62-a6b2-0bc02ac0b627	ce56b461-bd60-4f73-af14-a7c3023099d6	2022-07-25 16:25:05.932078+05
ab4de928-8896-4358-8cbf-9cb21bf5c4db	ab5aa81b-5b6c-478b-bd91-d58a78b23639	dfcc13f8-d2e8-4479-ba10-abd680656721	ce56b461-bd60-4f73-af14-a7c3023099d6	2022-07-25 15:24:11.811805+05
31042d98-cfbe-4233-b908-0e5c1d566577	729ffec2-0c24-4e12-9df1-9464b07d2028	29928035-700e-42d9-ae4f-504e1e3c1b69	ce56b461-bd60-4f73-af14-a7c3023099d6	2022-07-25 16:26:38.186452+05
\.


--
-- Data for Name: drivers; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.drivers (id, rent_type_id, f_name, l_name, phone, truck_brand, truck_number, rating, status, created_at) FROM stdin;
22984a88-42a2-4850-86bd-a5840192f3b7	1	aman	meret	993626262	tesla	4562	4	2	2022-06-17 20:16:00.979439+05
ecb835a3-52a6-434b-90a3-7c768bad36ab	1	fhjk	guio5	56789	hjkl	6544	3	1	2022-06-23 13:06:03.170453+05
dff9200b-2f5f-4b64-a9ea-965868de1bc7	1	ghujik	yguhj	74856	yghuj	45\\78	3	1	2022-06-17 20:21:50.24528+05
29fc6307-e6d1-4279-b756-3cf747c19a22	1	Myrat	Molla	99365656565	Tesla	4587 TR	4	1	2022-06-17 18:28:09.592297+05
c1cf76e5-0f13-427a-8678-13c7192e2912	1	meret	salamov	99368686868	tesla	3467	5	1	2022-06-17 20:16:25.254085+05
233e0a42-4a4d-470e-8a1d-c19835f94f50	1	Guwanc	Atayew	99323452	Pols	123	3	2	2022-06-17 20:34:48.189175+05
a6af7175-ebbd-49ee-8078-0a8b4a78ee9c	1	asdc	qwer	65432	sdfg	6543	5	1	2022-06-20 14:58:50.407646+05
c4132b85-54e1-4322-bc06-a2af6e5aca4c	1	salam	news	1234567	asdfg	1234	4	2	2022-06-20 20:41:44.269105+05
\.


--
-- Data for Name: exes; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.exes (id, card_dec_id, type, pay_type, dol, tmt, yedek_1, yedek_2, created_at) FROM stdin;
2004	213	type	Karantin	0	0	\N	\N	2022-08-23 17:40:59.213218+05
2005	213	type	Bank	0	0	\N	\N	2022-08-23 17:40:59.21322+05
2006	214	type	Gumruk	0	0	\N	\N	2022-08-23 17:40:59.213716+05
2007	214	type	Serhet	0	0	\N	\N	2022-08-23 17:40:59.213729+05
2008	214	type	Ses	0	0	\N	\N	2022-08-23 17:40:59.213732+05
2009	214	type	Transport	0	700	\N	\N	2022-08-23 17:40:59.213735+05
2010	214	type	Askuda	0	0	\N	\N	2022-08-23 17:40:59.213737+05
2011	214	type	Karantin	0	0	\N	\N	2022-08-23 17:40:59.21374+05
2039	218	type	Karantin	0	0	\N	\N	2022-08-24 16:36:22.280517+05
2040	218	type	Bank	0	0	\N	\N	2022-08-24 16:36:22.280521+05
2012	214	type	Bank	30	0	\N	\N	2022-08-23 17:40:59.213742+05
2013	215	type	Gumruk	0	0	\N	\N	2022-08-24 16:35:12.149323+05
1957	207	type	Gumruk	0	0	\N	\N	2022-08-23 17:35:48.569345+05
1958	207	type	Serhet	0	0	\N	\N	2022-08-23 17:35:48.605824+05
1959	207	type	Ses	0	0	\N	\N	2022-08-23 17:35:48.605845+05
1960	207	type	Transport	0	0	\N	\N	2022-08-23 17:35:48.605855+05
1961	207	type	Askuda	0	0	\N	\N	2022-08-23 17:35:48.605863+05
1962	207	type	Karantin	0	0	\N	\N	2022-08-23 17:35:48.60587+05
1963	207	type	Bank	0	0	\N	\N	2022-08-23 17:35:48.605877+05
1964	208	type	Gumruk	0	0	\N	\N	2022-08-23 17:35:48.607599+05
1965	208	type	Serhet	0	0	\N	\N	2022-08-23 17:35:48.607622+05
1966	208	type	Ses	0	0	\N	\N	2022-08-23 17:35:48.607632+05
1967	208	type	Transport	0	0	\N	\N	2022-08-23 17:35:48.60764+05
1968	208	type	Askuda	0	0	\N	\N	2022-08-23 17:35:48.607648+05
1969	208	type	Karantin	0	0	\N	\N	2022-08-23 17:35:48.607655+05
1970	208	type	Bank	0	0	\N	\N	2022-08-23 17:35:48.607663+05
1978	210	type	Gumruk	0	0	\N	\N	2022-08-23 17:36:42.101133+05
1979	210	type	Serhet	0	0	\N	\N	2022-08-23 17:36:42.10114+05
1980	210	type	Ses	0	0	\N	\N	2022-08-23 17:36:42.101144+05
1981	210	type	Transport	0	0	\N	\N	2022-08-23 17:36:42.101146+05
1982	210	type	Askuda	0	0	\N	\N	2022-08-23 17:36:42.101149+05
1983	210	type	Karantin	0	0	\N	\N	2022-08-23 17:36:42.101152+05
1984	210	type	Bank	0	0	\N	\N	2022-08-23 17:36:42.101155+05
1971	209	type	Gumruk	0	0	\N	\N	2022-08-23 17:36:42.100558+05
2014	215	type	Serhet	0	0	\N	\N	2022-08-24 16:35:12.149356+05
2015	215	type	Ses	0	0	\N	\N	2022-08-24 16:35:12.149359+05
2016	215	type	Transport	0	0	\N	\N	2022-08-24 16:35:12.149361+05
2017	215	type	Askuda	0	0	\N	\N	2022-08-24 16:35:12.149363+05
1972	209	type	Serhet	0	0	\N	\N	2022-08-23 17:36:42.100585+05
1973	209	type	Ses	0	0	\N	\N	2022-08-23 17:36:42.100592+05
1974	209	type	Transport	0	0	\N	\N	2022-08-23 17:36:42.100595+05
1975	209	type	Askuda	0	0	\N	\N	2022-08-23 17:36:42.100598+05
1976	209	type	Karantin	0	0	\N	\N	2022-08-23 17:36:42.100601+05
1977	209	type	Bank	0	0	\N	\N	2022-08-23 17:36:42.100603+05
1992	212	type	Gumruk	0	0	\N	\N	2022-08-23 17:40:47.131641+05
1993	212	type	Serhet	0	0	\N	\N	2022-08-23 17:40:47.131648+05
1994	212	type	Ses	0	0	\N	\N	2022-08-23 17:40:47.13165+05
1995	212	type	Transport	0	0	\N	\N	2022-08-23 17:40:47.131653+05
1996	212	type	Askuda	0	0	\N	\N	2022-08-23 17:40:47.131655+05
1997	212	type	Karantin	0	0	\N	\N	2022-08-23 17:40:47.131657+05
1998	212	type	Bank	0	0	\N	\N	2022-08-23 17:40:47.131659+05
1985	211	type	Gumruk	0	0	\N	\N	2022-08-23 17:40:47.131209+05
1986	211	type	Serhet	0	0	\N	\N	2022-08-23 17:40:47.131229+05
1987	211	type	Ses	0	0	\N	\N	2022-08-23 17:40:47.131233+05
1988	211	type	Transport	0	0	\N	\N	2022-08-23 17:40:47.131237+05
1989	211	type	Askuda	0	0	\N	\N	2022-08-23 17:40:47.131239+05
1990	211	type	Karantin	0	0	\N	\N	2022-08-23 17:40:47.131241+05
1991	211	type	Bank	0	0	\N	\N	2022-08-23 17:40:47.131243+05
1999	213	type	Gumruk	0	50	\N	\N	2022-08-23 17:40:59.213179+05
2000	213	type	Serhet	0	0	\N	\N	2022-08-23 17:40:59.213207+05
2001	213	type	Ses	0	0	\N	\N	2022-08-23 17:40:59.21321+05
2002	213	type	Transport	0	0	\N	\N	2022-08-23 17:40:59.213213+05
2003	213	type	Askuda	50	0	\N	\N	2022-08-23 17:40:59.213216+05
2018	215	type	Karantin	0	0	\N	\N	2022-08-24 16:35:12.149365+05
2019	215	type	Bank	0	0	\N	\N	2022-08-24 16:35:12.14937+05
2020	216	type	Gumruk	0	0	\N	\N	2022-08-24 16:35:12.149764+05
2021	216	type	Serhet	0	0	\N	\N	2022-08-24 16:35:12.14977+05
2022	216	type	Ses	0	0	\N	\N	2022-08-24 16:35:12.149772+05
2023	216	type	Transport	0	0	\N	\N	2022-08-24 16:35:12.149775+05
2024	216	type	Askuda	0	0	\N	\N	2022-08-24 16:35:12.149777+05
2025	216	type	Karantin	0	0	\N	\N	2022-08-24 16:35:12.149779+05
2026	216	type	Bank	0	0	\N	\N	2022-08-24 16:35:12.14978+05
2027	217	type	Gumruk	0	0	\N	\N	2022-08-24 16:36:22.279648+05
2028	217	type	Serhet	0	0	\N	\N	2022-08-24 16:36:22.279684+05
2029	217	type	Ses	0	0	\N	\N	2022-08-24 16:36:22.279688+05
2030	217	type	Transport	0	0	\N	\N	2022-08-24 16:36:22.279692+05
2031	217	type	Askuda	0	0	\N	\N	2022-08-24 16:36:22.279694+05
2032	217	type	Karantin	0	0	\N	\N	2022-08-24 16:36:22.279697+05
2033	217	type	Bank	0	0	\N	\N	2022-08-24 16:36:22.2797+05
2034	218	type	Gumruk	0	0	\N	\N	2022-08-24 16:36:22.280473+05
2035	218	type	Serhet	0	0	\N	\N	2022-08-24 16:36:22.280485+05
2036	218	type	Ses	0	0	\N	\N	2022-08-24 16:36:22.280491+05
2037	218	type	Transport	0	0	\N	\N	2022-08-24 16:36:22.280509+05
2038	218	type	Askuda	0	0	\N	\N	2022-08-24 16:36:22.280513+05
2048	220	type	Gumruk	0	0	\N	\N	2022-08-26 17:22:39.503397+05
2049	220	type	Serhet	0	0	\N	\N	2022-08-26 17:22:39.503423+05
2050	220	type	Ses	0	0	\N	\N	2022-08-26 17:22:39.503432+05
2051	220	type	Transport	0	0	\N	\N	2022-08-26 17:22:39.50344+05
2052	220	type	Askuda	0	0	\N	\N	2022-08-26 17:22:39.503447+05
2053	220	type	Karantin	0	0	\N	\N	2022-08-26 17:22:39.503455+05
2054	220	type	Bank	0	0	\N	\N	2022-08-26 17:22:39.503462+05
2041	219	type	Gumruk	0	0	\N	\N	2022-08-26 17:22:39.484989+05
2042	219	type	Serhet	0	0	\N	\N	2022-08-26 17:22:39.501391+05
2043	219	type	Ses	0	0	\N	\N	2022-08-26 17:22:39.501421+05
2044	219	type	Transport	0	0	\N	\N	2022-08-26 17:22:39.501431+05
2045	219	type	Askuda	0	0	\N	\N	2022-08-26 17:22:39.501439+05
2046	219	type	Karantin	0	0	\N	\N	2022-08-26 17:22:39.501447+05
2047	219	type	Bank	0	0	\N	\N	2022-08-26 17:22:39.501454+05
2055	221	type	Gumruk	0	0	\N	\N	2022-09-03 11:28:54.370057+05
2056	221	type	Serhet	0	0	\N	\N	2022-09-03 11:28:54.454223+05
2057	221	type	Ses	0	0	\N	\N	2022-09-03 11:28:54.454255+05
2058	221	type	Transport	0	0	\N	\N	2022-09-03 11:28:54.454266+05
2059	221	type	Askuda	0	0	\N	\N	2022-09-03 11:28:54.454275+05
2060	221	type	Karantin	0	0	\N	\N	2022-09-03 11:28:54.454284+05
2061	221	type	Bank	0	0	\N	\N	2022-09-03 11:28:54.454292+05
2062	222	type	Gumruk	0	0	\N	\N	2022-09-03 11:28:54.456365+05
2063	222	type	Serhet	0	0	\N	\N	2022-09-03 11:28:54.456391+05
2064	222	type	Ses	0	0	\N	\N	2022-09-03 11:28:54.456402+05
2065	222	type	Transport	0	0	\N	\N	2022-09-03 11:28:54.456554+05
2066	222	type	Askuda	0	0	\N	\N	2022-09-03 11:28:54.456565+05
2067	222	type	Karantin	0	0	\N	\N	2022-09-03 11:28:54.456574+05
2068	222	type	Bank	0	0	\N	\N	2022-09-03 11:28:54.456582+05
2076	224	type	Gumruk	0	50	\N	\N	2022-09-03 11:33:38.288641+05
2077	224	type	Serhet	0	10	\N	\N	2022-09-03 11:33:38.288648+05
2078	224	type	Ses	5	0	\N	\N	2022-09-03 11:33:38.28865+05
2079	224	type	Transport	100	0	\N	\N	2022-09-03 11:33:38.288652+05
2080	224	type	Askuda	0	0	\N	\N	2022-09-03 11:33:38.288654+05
2081	224	type	Karantin	0	0	\N	\N	2022-09-03 11:33:38.288656+05
2082	224	type	Bank	0	1000	\N	\N	2022-09-03 11:33:38.288658+05
2083	224	output	gayrat çykdajy	0	50	\N	\N	2022-09-03 11:34:44.347071+05
2084	225	type	Gumruk	0	0	\N	\N	2022-09-03 11:35:58.737132+05
2085	225	type	Serhet	0	0	\N	\N	2022-09-03 11:35:58.737257+05
2086	225	type	Ses	0	0	\N	\N	2022-09-03 11:35:58.737273+05
2087	225	type	Transport	0	0	\N	\N	2022-09-03 11:35:58.737284+05
2088	225	type	Askuda	0	0	\N	\N	2022-09-03 11:35:58.737294+05
2089	225	type	Karantin	0	0	\N	\N	2022-09-03 11:35:58.737303+05
2090	225	type	Bank	0	0	\N	\N	2022-09-03 11:35:58.737313+05
2091	226	type	Gumruk	0	0	\N	\N	2022-09-03 11:35:58.739475+05
2092	226	type	Serhet	0	0	\N	\N	2022-09-03 11:35:58.739506+05
2093	226	type	Ses	0	0	\N	\N	2022-09-03 11:35:58.739519+05
2094	226	type	Transport	0	0	\N	\N	2022-09-03 11:35:58.739529+05
2095	226	type	Askuda	0	0	\N	\N	2022-09-03 11:35:58.739539+05
2096	226	type	Karantin	0	0	\N	\N	2022-09-03 11:35:58.739549+05
2097	226	type	Bank	0	0	\N	\N	2022-09-03 11:35:58.739558+05
2098	227	type	Gumruk	0	0	\N	\N	2022-09-03 11:37:50.659962+05
2099	227	type	Serhet	0	0	\N	\N	2022-09-03 11:37:50.660088+05
2100	227	type	Ses	0	0	\N	\N	2022-09-03 11:37:50.660104+05
2101	227	type	Transport	0	0	\N	\N	2022-09-03 11:37:50.660115+05
2102	227	type	Askuda	0	0	\N	\N	2022-09-03 11:37:50.660126+05
2103	227	type	Karantin	0	0	\N	\N	2022-09-03 11:37:50.660136+05
2104	227	type	Bank	0	0	\N	\N	2022-09-03 11:37:50.660145+05
2105	228	type	Gumruk	0	0	\N	\N	2022-09-03 11:37:50.662991+05
2106	228	type	Serhet	0	0	\N	\N	2022-09-03 11:37:50.663026+05
2107	228	type	Ses	0	0	\N	\N	2022-09-03 11:37:50.663039+05
2108	228	type	Transport	0	0	\N	\N	2022-09-03 11:37:50.663049+05
2109	228	type	Askuda	0	0	\N	\N	2022-09-03 11:37:50.663059+05
2110	228	type	Karantin	0	0	\N	\N	2022-09-03 11:37:50.663069+05
2111	228	type	Bank	0	0	\N	\N	2022-09-03 11:37:50.663078+05
2112	229	type	Gumruk	0	0	\N	\N	2022-09-03 11:41:11.624405+05
2113	229	type	Serhet	0	0	\N	\N	2022-09-03 11:41:11.624451+05
2114	229	type	Ses	0	0	\N	\N	2022-09-03 11:41:11.624457+05
2115	229	type	Transport	0	0	\N	\N	2022-09-03 11:41:11.624461+05
2116	229	type	Askuda	0	0	\N	\N	2022-09-03 11:41:11.624465+05
2117	229	type	Karantin	0	0	\N	\N	2022-09-03 11:41:11.624469+05
2118	229	type	Bank	0	0	\N	\N	2022-09-03 11:41:11.624472+05
2119	230	type	Gumruk	0	0	\N	\N	2022-09-03 11:41:11.625167+05
2120	230	type	Serhet	0	0	\N	\N	2022-09-03 11:41:11.625177+05
2121	230	type	Ses	0	0	\N	\N	2022-09-03 11:41:11.625181+05
2122	230	type	Transport	0	0	\N	\N	2022-09-03 11:41:11.625185+05
2123	230	type	Askuda	0	0	\N	\N	2022-09-03 11:41:11.625188+05
2124	230	type	Karantin	0	0	\N	\N	2022-09-03 11:41:11.625192+05
2125	230	type	Bank	0	0	\N	\N	2022-09-03 11:41:11.625198+05
2069	223	type	Gumruk	0	0	\N	\N	2022-09-03 11:33:38.288119+05
2070	223	type	Serhet	0	50	\N	\N	2022-09-03 11:33:38.288149+05
2071	223	type	Ses	50	0	\N	\N	2022-09-03 11:33:38.288153+05
2072	223	type	Transport	0	0	\N	\N	2022-09-03 11:33:38.288155+05
2073	223	type	Askuda	0	0	\N	\N	2022-09-03 11:33:38.288157+05
2074	223	type	Karantin	0	0	\N	\N	2022-09-03 11:33:38.288161+05
2075	223	type	Bank	0	0	\N	\N	2022-09-03 11:33:38.288163+05
2126	231	type	Gumruk	0	0	\N	\N	2022-09-03 11:41:58.013144+05
2127	231	type	Serhet	0	0	\N	\N	2022-09-03 11:41:58.013242+05
2128	231	type	Ses	0	0	\N	\N	2022-09-03 11:41:58.013259+05
2129	231	type	Transport	0	0	\N	\N	2022-09-03 11:41:58.013272+05
2130	231	type	Askuda	0	0	\N	\N	2022-09-03 11:41:58.013283+05
2131	231	type	Karantin	0	0	\N	\N	2022-09-03 11:41:58.013295+05
2132	231	type	Bank	0	0	\N	\N	2022-09-03 11:41:58.013323+05
2133	232	type	Gumruk	0	0	\N	\N	2022-09-03 11:41:58.015781+05
2134	232	type	Serhet	0	0	\N	\N	2022-09-03 11:41:58.015818+05
2135	232	type	Ses	0	0	\N	\N	2022-09-03 11:41:58.015834+05
2136	232	type	Transport	0	0	\N	\N	2022-09-03 11:41:58.015846+05
2137	232	type	Askuda	0	0	\N	\N	2022-09-03 11:41:58.015858+05
2138	232	type	Karantin	0	0	\N	\N	2022-09-03 11:41:58.015869+05
2139	232	type	Bank	0	0	\N	\N	2022-09-03 11:41:58.01588+05
2140	233	type	Gumruk	0	0	\N	\N	2022-09-03 11:42:42.854274+05
2141	233	type	Serhet	0	0	\N	\N	2022-09-03 11:42:42.854396+05
2142	233	type	Ses	0	0	\N	\N	2022-09-03 11:42:42.854449+05
2143	233	type	Transport	0	0	\N	\N	2022-09-03 11:42:42.854473+05
2144	233	type	Askuda	0	0	\N	\N	2022-09-03 11:42:42.854493+05
2145	233	type	Karantin	0	0	\N	\N	2022-09-03 11:42:42.854507+05
2146	233	type	Bank	0	0	\N	\N	2022-09-03 11:42:42.854517+05
2147	234	type	Gumruk	0	0	\N	\N	2022-09-03 11:42:42.85669+05
2148	234	type	Serhet	0	0	\N	\N	2022-09-03 11:42:42.856724+05
2149	234	type	Ses	0	0	\N	\N	2022-09-03 11:42:42.856736+05
2150	234	type	Transport	0	0	\N	\N	2022-09-03 11:42:42.856747+05
2151	234	type	Askuda	0	0	\N	\N	2022-09-03 11:42:42.856757+05
2152	234	type	Karantin	0	0	\N	\N	2022-09-03 11:42:42.856766+05
2153	234	type	Bank	0	0	\N	\N	2022-09-03 11:42:42.857039+05
\.


--
-- Data for Name: images; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.images (id, order_detail_id, image_path, created_at) FROM stdin;
2	1	Uploads/files-6/1658901703557.jpg	2022-07-27 11:01:43.558116+05
3	2	Uploads/files-6/1658904207296.jpg	2022-07-27 11:43:27.298265+05
\.


--
-- Data for Name: import_trailer_tm; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.import_trailer_tm (id, trailer_tm, order_id, created_at) FROM stdin;
\.


--
-- Data for Name: item_types; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.item_types (id, name, is_danger, created_at) FROM stdin;
1d539099-5572-4176-9ef0-3e5594450df8	test	f	2022-07-25 17:21:23.827581+05
2230d789-8a6d-4195-9fe9-1cb3998c6c6a	aaaa	f	2022-07-25 17:28:56.036543+05
1f40578a-cfc9-4e13-9083-18c1eca92f53	type	f	2022-07-26 14:25:40.338255+05
45edf1e0-9de1-4639-9acc-3579e72c567d	Salam_12	f	2022-07-25 17:57:04.822723+05
9bd1041c-7b15-407c-b854-aec00b6a2014	Halta	f	2022-07-27 10:55:24.140209+05
de5ba54e-f634-4e3f-b9ae-ad51d817e433	false	f	2022-08-07 18:11:05.36849+05
3c9b0c4e-02b6-45c3-aa8a-1a05cbf9b586	false	f	2022-08-07 18:11:32.359316+05
\.


--
-- Data for Name: missions; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.missions (id, name, created_at) FROM stdin;
1	Генениральный директор	2022-06-04 22:14:23.273016+05
2	Бухгалтер	2022-06-04 22:15:36.007867+05
3	Старший менеджер	2022-06-04 22:15:51.818727+05
4	Менеджер	2022-06-04 22:16:12.326291+05
5	Логист	2022-06-04 22:16:29.583424+05
6	Дисперчер	2022-06-04 22:16:47.573233+05
7	Дикларант	2022-06-04 22:17:08.536211+05
8	Представитель	2022-06-04 22:19:53.386982+05
\.


--
-- Data for Name: order_details; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.order_details (id, order_id, trailer_id, driver_id, border_id, gps_tracker_number, placed_neutral_zone, departure_neutral_zone, cmr, invoice, container_number, invoice_file_path, transport_cost_tmt, transport_cost_dol, additional_cost_tmt, additional_cost_dol, fine, status, logist_status, client_notified_date, client_notified_clock, re_notification_date, re_notification_clock, arrived_for_unloading, unloaded, downtime_in_day, total_downtime, arrived_for_loading, sent, created_at) FROM stdin;
1	6	0b5f1988-10ad-4caa-bce5-178677a49a0b	22984a88-42a2-4850-86bd-a5840192f3b7	1	\N	2022-07-27	2022-07-27	152	326	65	\N	2000	1500	3000	1600	50	3	4	2022-07-27	11:31:00	2022-07-27	16:32:00	\N	\N	3	25	\N	\N	2022-07-27 10:58:26.661994+05
2	6	0b5f1988-10ad-4caa-bce5-178677a49a0b	22984a88-42a2-4850-86bd-a5840192f3b7	3	\N	2022-07-27	\N	152	326	65	\N	3000	1200	2300	\N	\N	3	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2022-07-27 11:36:07.315388+05
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.orders (id, client_id, item_type_id, cover_type_id, from_city_id, to_city_id, trailer_type_id, logist_id, transport_type_id, weight, trailer_count, order_data, is_security, price, total_price, status, created_at) FROM stdin;
5	2	9bd1041c-7b15-407c-b854-aec00b6a2014	\N	55b75a53-e5dd-42f6-b320-63015897b1e7	bfbd77ff-c53c-4c62-a6b2-0bc02ac0b627	fca673c2-d9a5-49a1-aae4-4a256617387e	24e89def-06fe-40d5-b695-1663b7397b06	1	20	1	2022-07-27 00:00:00+05	f	160	160	3	2022-07-27 10:57:21.713298+05
6	2	9bd1041c-7b15-407c-b854-aec00b6a2014	\N	55b75a53-e5dd-42f6-b320-63015897b1e7	bfbd77ff-c53c-4c62-a6b2-0bc02ac0b627	fca673c2-d9a5-49a1-aae4-4a256617387e	24e89def-06fe-40d5-b695-1663b7397b06	1	20	1	2022-07-27 00:00:00+05	f	160	160	4	2022-07-27 10:57:21.827076+05
\.


--
-- Data for Name: pay_money; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.pay_money (id, total_dol, total_tmt, border_id, created_at) FROM stdin;
\.


--
-- Data for Name: rent_types; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.rent_types (id, name, created_at) FROM stdin;
1	Хазар логистика	2022-06-04 21:02:42.151978+05
2	Пост. аренда	2022-06-04 21:02:42.152472+05
3	Врем. аренда	2022-06-04 21:02:42.152512+05
\.


--
-- Data for Name: routes; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.routes (id, name, transport_type_id, created_at) FROM stdin;
ce56b461-bd60-4f73-af14-a7c3023099d6	Iran-Uzbek	1	2022-07-25 15:23:36.791572+05
\.


--
-- Data for Name: sub_category; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.sub_category (id, name, category_id, created_at) FROM stdin;
1	aa	1	2022-07-04 15:54:16.108862+05
2	aa	1	2022-07-04 15:54:16.109308+05
3	aa	1	2022-07-04 15:54:16.10934+05
4	aa	1	2022-07-04 15:54:16.109356+05
5	aa	1	2022-07-04 15:54:16.109369+05
6	aa	1	2022-07-04 15:54:16.109382+05
7	bb	2	2022-07-04 15:54:16.109395+05
8	bb	2	2022-07-04 15:54:16.109425+05
9	bb	2	2022-07-04 15:54:16.109436+05
10	bb	2	2022-07-04 15:54:16.109449+05
11	cc	3	2022-07-04 15:54:16.10946+05
12	cc	3	2022-07-04 15:54:16.109472+05
13	cc	3	2022-07-04 15:54:16.109485+05
14	cc	3	2022-07-04 15:54:16.109498+05
15	cc	3	2022-07-04 15:54:16.109506+05
16	dd	4	2022-07-04 15:54:16.109513+05
17	dd	4	2022-07-04 15:54:16.10952+05
18	dd	4	2022-07-04 15:54:16.109528+05
19	dd	4	2022-07-04 15:54:16.109535+05
20	test	1	2022-07-04 16:47:28.386133+05
25	test	1	2022-07-04 16:47:34.402149+05
\.


--
-- Data for Name: sub_sub; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.sub_sub (id, name, scategory_id, created_at) FROM stdin;
\.


--
-- Data for Name: test; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.test (id, value) FROM stdin;
2	2
3	3
1	2
\.


--
-- Data for Name: test_1; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.test_1 (id, val) FROM stdin;
1	1
2	2
3	3
4	4
5	5
\.


--
-- Data for Name: test_2; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.test_2 (id, val) FROM stdin;
1	6
2	7
3	8
4	9
5	10
\.


--
-- Data for Name: trailer_types; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.trailer_types (id, name, created_at) FROM stdin;
232d2eb4-c027-4c3a-a354-d1dbd1e35890	trailer type 1	2022-06-04 22:32:48.262847+05
fca673c2-d9a5-49a1-aae4-4a256617387e	trailer type 2	2022-06-04 22:32:48.263355+05
9385724c-619d-4a53-8881-ccd0b39c33dd	trailer type 3	2022-06-04 22:32:48.263404+05
\.


--
-- Data for Name: trailers; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.trailers (id, number, type_id, rent_type_id, status, created_at) FROM stdin;
f3b5dbb1-6b1f-4c05-8654-a6e19455e8c0	TM 1232 LB	fca673c2-d9a5-49a1-aae4-4a256617387e	1	2	2022-06-06 16:26:55.680037+05
c747a753-982c-452e-8058-94bf17b17ea9	65463	fca673c2-d9a5-49a1-aae4-4a256617387e	1	2	2022-06-16 14:52:56.968253+05
d7d3c27a-057b-4519-ae20-35814e938ed6	7895	232d2eb4-c027-4c3a-a354-d1dbd1e35890	1	1	2022-06-14 16:10:22.080538+05
3588a499-4d68-4f2f-a4eb-b8110e55c383	TM 1213 LB	232d2eb4-c027-4c3a-a354-d1dbd1e35890	1	2	2022-06-05 01:40:31.914363+05
a8c8cb4d-063a-4037-857c-61a5c27a1d0e	TM 3434 AG	9385724c-619d-4a53-8881-ccd0b39c33dd	1	2	2022-06-05 01:39:44.244328+05
d03cf664-4bd9-4873-911a-a41d0679af47	TM 6789 DZ	232d2eb4-c027-4c3a-a354-d1dbd1e35890	1	2	2022-06-05 01:39:18.36867+05
67a2205a-fbb1-4ef2-92c8-930657f0c285	4598	fca673c2-d9a5-49a1-aae4-4a256617387e	1	2	2022-06-13 17:05:31.872774+05
0b5f1988-10ad-4caa-bce5-178677a49a0b	4587	232d2eb4-c027-4c3a-a354-d1dbd1e35890	1	2	2022-06-16 14:53:03.282316+05
60f4ab5c-a536-4285-8ac6-c6d16194b987	5426	fca673c2-d9a5-49a1-aae4-4a256617387e	1	2	2022-06-14 19:14:19.243755+05
987ff5fb-3927-48d2-b36f-c85b615b006e	7854	232d2eb4-c027-4c3a-a354-d1dbd1e35890	1	2	2022-06-14 19:14:12.253387+05
73f6663c-8451-45c4-8aad-775dfd8fd67c	8759	fca673c2-d9a5-49a1-aae4-4a256617387e	1	2	2022-06-14 19:14:24.953265+05
5ef40865-e074-4f3c-a0fb-3f5339fda755	3265	232d2eb4-c027-4c3a-a354-d1dbd1e35890	1	2	2022-06-14 19:14:31.557117+05
a40fb463-c577-455a-8760-d3edab3bdeec	TM 4545 MR	fca673c2-d9a5-49a1-aae4-4a256617387e	1	2	2022-06-05 01:39:29.810546+05
7a00b6dc-fa1f-4703-95fe-5939ce307d4d	TM 6767 MR	9385724c-619d-4a53-8881-ccd0b39c33dd	1	2	2022-06-06 18:13:08.620528+05
\.


--
-- Data for Name: trans_tp_workers; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.trans_tp_workers (id, worker_id, transport_type_id, created_at) FROM stdin;
11	bdfbaf91-c951-4995-8e06-808c8a145f1f	1	2022-06-06 23:28:44.637572+05
12	bdfbaf91-c951-4995-8e06-808c8a145f1f	2	2022-06-06 23:28:44.640198+05
13	2261bfe6-7dad-4f5e-aa81-e3a657c8a54e	1	2022-06-09 17:41:15.03473+05
14	2261bfe6-7dad-4f5e-aa81-e3a657c8a54e	2	2022-06-09 17:41:15.037298+05
15	2261bfe6-7dad-4f5e-aa81-e3a657c8a54e	3	2022-06-09 17:41:15.037474+05
16	24e89def-06fe-40d5-b695-1663b7397b06	1	2022-06-20 20:37:09.425826+05
17	24e89def-06fe-40d5-b695-1663b7397b06	2	2022-06-20 20:37:09.425982+05
18	24e89def-06fe-40d5-b695-1663b7397b06	4	2022-06-20 20:37:09.425995+05
\.


--
-- Data for Name: transport_types; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.transport_types (id, name, created_at) FROM stdin;
1	Транзит	2022-06-04 21:02:42.527922+05
2	Экспорт	2022-06-04 21:02:42.528461+05
3	Импорт	2022-06-04 21:02:42.528492+05
4	Внутренние перевозки	2022-06-04 21:02:42.528505+05
\.


--
-- Data for Name: weights; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.weights (weight) FROM stdin;
2
6
10
20
\.


--
-- Data for Name: workers; Type: TABLE DATA; Schema: public; Owner: crm_db_user
--

COPY public.workers (id, first_name, last_name, middle_name, mission_id, phone_number, login, password, created_at) FROM stdin;
063e42a6-1274-4d4d-9575-3dec8045c823	Oraz	Durdyyev	aga	7	+99355555555	oraz	$2b$10$WsZ8Np.iPzlC1n9TzUApWemMOnOgxqoe6R1S87dJEsRG9GhP0ceD6	2022-06-04 22:25:40.644835+05
884bdb74-46a8-41a3-9be7-b04de6b41b59	Grisha	Georgiy	Guseinov	8	56168510	dfgfhj	$2b$10$b3HiGRs288qdZZ.rgqzh7.uDFm2QnSE6Uem.YWcLYRerV8xFx1YCy	2022-06-04 23:09:00.477795+05
2f5b8d6d-4dcc-41d4-b659-92d8e00ddd88	Batyr	Muhammet	Agaa	7	+99595959	batyr	$2b$10$9Ewi8c4UhtLmXSydCQhI9OPKpXS6ipHlfMFEq0JpD6iUs2Y8yr7Q.	2022-06-06 15:03:50.368811+05
bdfbaf91-c951-4995-8e06-808c8a145f1f	szfgrtfguj	rtfyuhil	dgrtfguhj	5	fxcghjk	fcgvhbjnk	$2b$10$cW3TGXu6/y2l69Spu6mCfeudUHkPMYbNbOGKVZSXsK8tRw9puXqDO	2022-06-06 23:28:44.628919+05
2261bfe6-7dad-4f5e-aa81-e3a657c8a54e	Akmuhammet	Akmyrat	aga	5	+99361616161	akmuhammet	$2b$10$9eOIwLMZybotsmsyFSqA/ugkddWgglaIBXVmAmmt6PXrxkx60/adq	2022-06-04 23:20:11.790508+05
0d5998ee-f4c3-413d-bd6a-3d631895720a	Berdi	Saparov	Aga	7	+993878787	berdi	$2a$10$vvei9d0MUu16mivGYtdEZ.82QCSdoAfvhSs0UhugqygrYtNLfRlXO	2022-06-13 10:05:35.665218+05
02cd0980-b433-4c35-8b58-433c1bc5a4e9	Meret	Meredov	Aga	7	6598787	meret	$2a$10$ZKBZHdnDyAxE.j7Y4Cz77eb21xaA.VPYP0oMBu56DOKkt/oO4jSFy	2022-06-15 15:47:03.316526+05
24e89def-06fe-40d5-b695-1663b7397b06	Muhammet	Bayram	aga	5	+99398989898	muhammet	$2b$10$MfDkjDcFSE3V2cfxCVmnr.8NlEUIO8STmc7iWC2zEQHK5OChYNWAm	2022-06-04 22:19:19.716669+05
4437c04a-2137-4fbf-aea8-22a481a1a24a	Declarant	Declarantow	Declarantowic	7	+99364499762	declarant	$2a$10$u.3jJg7LPhAzrbme0T3ocOTsg3v8qFUDb1zsSGrfP14uktRyqCaaO	2022-08-01 10:08:44.887006+05
25317cdb-61cf-44bf-9fa7-10e12992a739	Бухгалтер	Бухгалтер	Бухгалтер	2	+99364499762	buhgalter	$2a$10$8CPBqEzSxKYynlEK6oxDxenJkmPRL6VlIpQ4ymSJVeHZHmL7YsIIm	2022-08-08 12:27:00.537753+05
09f6bf9a-d5e2-4a9b-b6cd-3f8b489ca5ce	farap	SubMenu	SubMenu	7	+99364499762	farap	$2a$10$VagVxqw/Q/z1/WW7KRZMkuzRQnAlWanjBbMLv9EEa1YPibfHgY5ti	2022-08-08 13:15:09.935396+05
a24e3c7d-b03b-4c66-b17e-1823de626d64	presdowitel	presdowitel	presdowitel	7	+99364499762	presdowitel	$2a$10$/xO47VezK4unhoClVwkW..pntyWiS9WLjey.fdkP38ID4c4e38e3q	2022-08-08 13:16:04.477179+05
80987747-3411-4700-9dde-7fc93a0ac2b8	Kerim	Kerim	Kerim	7	+99364499762	kerim	$2a$10$3AiL5wYbE4d8eIXBAArYse8fUUygeD/c.91Yv6wCjb1BEF6fJjZ/6	2022-08-08 16:59:55.975379+05
2c3f130e-c267-4282-bd6b-5f1c66bed953	Gadam	Gurban	Aga	8	+9936565656	gadam	$2b$10$61i/ZHOP1BKV3c2zfm1St.w28j9ljMUM0Bpb10xhG.gPlL2rdf8V.	2022-06-07 13:34:24.423866+05
\.


--
-- Name: border_workers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crm_db_user
--

SELECT pg_catalog.setval('public.border_workers_id_seq', 9, true);


--
-- Name: borders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crm_db_user
--

SELECT pg_catalog.setval('public.borders_id_seq', 7, true);


--
-- Name: card_dec_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crm_db_user
--

SELECT pg_catalog.setval('public.card_dec_id_seq', 234, true);


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crm_db_user
--

SELECT pg_catalog.setval('public.categories_id_seq', 7, true);


--
-- Name: category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crm_db_user
--

SELECT pg_catalog.setval('public.category_id_seq', 4, true);


--
-- Name: clients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crm_db_user
--

SELECT pg_catalog.setval('public.clients_id_seq', 5, true);


--
-- Name: consents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crm_db_user
--

SELECT pg_catalog.setval('public.consents_id_seq', 150, true);


--
-- Name: dec_balans_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crm_db_user
--

SELECT pg_catalog.setval('public.dec_balans_id_seq', 628, true);


--
-- Name: dec_ord_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crm_db_user
--

SELECT pg_catalog.setval('public.dec_ord_images_id_seq', 85, true);


--
-- Name: declarant_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crm_db_user
--

SELECT pg_catalog.setval('public.declarant_orders_id_seq', 226, true);


--
-- Name: direction_costs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crm_db_user
--

SELECT pg_catalog.setval('public.direction_costs_id_seq', 490, true);


--
-- Name: exes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crm_db_user
--

SELECT pg_catalog.setval('public.exes_id_seq', 2153, true);


--
-- Name: images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crm_db_user
--

SELECT pg_catalog.setval('public.images_id_seq', 3, true);


--
-- Name: missions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crm_db_user
--

SELECT pg_catalog.setval('public.missions_id_seq', 16, true);


--
-- Name: order_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crm_db_user
--

SELECT pg_catalog.setval('public.order_details_id_seq', 2, true);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crm_db_user
--

SELECT pg_catalog.setval('public.orders_id_seq', 6, true);


--
-- Name: pay_money_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crm_db_user
--

SELECT pg_catalog.setval('public.pay_money_id_seq', 3, true);


--
-- Name: rent_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crm_db_user
--

SELECT pg_catalog.setval('public.rent_types_id_seq', 4, true);


--
-- Name: routes_transport_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crm_db_user
--

SELECT pg_catalog.setval('public.routes_transport_type_id_seq', 1, false);


--
-- Name: sub_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crm_db_user
--

SELECT pg_catalog.setval('public.sub_category_id_seq', 19, true);


--
-- Name: sub_sub_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crm_db_user
--

SELECT pg_catalog.setval('public.sub_sub_id_seq', 1, false);


--
-- Name: test_1_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.test_1_id_seq', 5, true);


--
-- Name: test_2_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.test_2_id_seq', 5, true);


--
-- Name: test_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.test_id_seq', 3, true);


--
-- Name: trans_tp_workers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crm_db_user
--

SELECT pg_catalog.setval('public.trans_tp_workers_id_seq', 18, true);


--
-- Name: transport_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: crm_db_user
--

SELECT pg_catalog.setval('public.transport_types_id_seq', 5, true);


--
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: border_workers border_workers_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.border_workers
    ADD CONSTRAINT border_workers_pkey PRIMARY KEY (id);


--
-- Name: border_workers border_workers_worker_id_key; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.border_workers
    ADD CONSTRAINT border_workers_worker_id_key UNIQUE (worker_id);


--
-- Name: borders borders_name_key; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.borders
    ADD CONSTRAINT borders_name_key UNIQUE (name);


--
-- Name: borders borders_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.borders
    ADD CONSTRAINT borders_pkey PRIMARY KEY (id);


--
-- Name: card_dec card_dec_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.card_dec
    ADD CONSTRAINT card_dec_pkey PRIMARY KEY (id);


--
-- Name: categories categories_name_key; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: category category_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (id);


--
-- Name: cities cities_name_key; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_name_key UNIQUE (name);


--
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- Name: client_payment_history client_payment_history_order_id_key; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.client_payment_history
    ADD CONSTRAINT client_payment_history_order_id_key UNIQUE (order_id);


--
-- Name: client_payment_history client_payment_history_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.client_payment_history
    ADD CONSTRAINT client_payment_history_pkey PRIMARY KEY (id);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: consents consents_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.consents
    ADD CONSTRAINT consents_pkey PRIMARY KEY (id);


--
-- Name: consents consents_worker_id_category_id_key; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.consents
    ADD CONSTRAINT consents_worker_id_category_id_key UNIQUE (worker_id, category_id);


--
-- Name: countries countries_name_key; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_name_key UNIQUE (name);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: cover_types cover_types_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.cover_types
    ADD CONSTRAINT cover_types_pkey PRIMARY KEY (id);


--
-- Name: dec_balans dec_balans_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.dec_balans
    ADD CONSTRAINT dec_balans_pkey PRIMARY KEY (id);


--
-- Name: dec_ord_images dec_ord_images_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.dec_ord_images
    ADD CONSTRAINT dec_ord_images_pkey PRIMARY KEY (id);


--
-- Name: declarant_orders declarant_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.declarant_orders
    ADD CONSTRAINT declarant_orders_pkey PRIMARY KEY (id);


--
-- Name: direction_cost_columns direction_cost_columns_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.direction_cost_columns
    ADD CONSTRAINT direction_cost_columns_pkey PRIMARY KEY (id);


--
-- Name: direction_costs direction_costs_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.direction_costs
    ADD CONSTRAINT direction_costs_pkey PRIMARY KEY (id);


--
-- Name: direction_values direction_values_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.direction_values
    ADD CONSTRAINT direction_values_pkey PRIMARY KEY (id);


--
-- Name: directions directions_from_city_id_to_city_id_key; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.directions
    ADD CONSTRAINT directions_from_city_id_to_city_id_key UNIQUE (from_city_id, to_city_id);


--
-- Name: directions directions_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.directions
    ADD CONSTRAINT directions_pkey PRIMARY KEY (id);


--
-- Name: drivers drivers_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_pkey PRIMARY KEY (id);


--
-- Name: drivers drivers_truck_number_key; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_truck_number_key UNIQUE (truck_number);


--
-- Name: exes exes_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.exes
    ADD CONSTRAINT exes_pkey PRIMARY KEY (id);


--
-- Name: images images_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT images_pkey PRIMARY KEY (id);


--
-- Name: import_trailer_tm import_trailer_tm_order_id_key; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.import_trailer_tm
    ADD CONSTRAINT import_trailer_tm_order_id_key UNIQUE (order_id);


--
-- Name: import_trailer_tm import_trailer_tm_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.import_trailer_tm
    ADD CONSTRAINT import_trailer_tm_pkey PRIMARY KEY (id);


--
-- Name: item_types item_types_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.item_types
    ADD CONSTRAINT item_types_pkey PRIMARY KEY (id);


--
-- Name: missions missions_name_key; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.missions
    ADD CONSTRAINT missions_name_key UNIQUE (name);


--
-- Name: missions missions_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.missions
    ADD CONSTRAINT missions_pkey PRIMARY KEY (id);


--
-- Name: order_details order_details_order_id_border_id_key; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT order_details_order_id_border_id_key UNIQUE (order_id, border_id);


--
-- Name: order_details order_details_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT order_details_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: pay_money pay_money_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.pay_money
    ADD CONSTRAINT pay_money_pkey PRIMARY KEY (id);


--
-- Name: rent_types rent_types_name_key; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.rent_types
    ADD CONSTRAINT rent_types_name_key UNIQUE (name);


--
-- Name: rent_types rent_types_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.rent_types
    ADD CONSTRAINT rent_types_pkey PRIMARY KEY (id);


--
-- Name: routes routes_name_key; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_name_key UNIQUE (name);


--
-- Name: routes routes_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_pkey PRIMARY KEY (id);


--
-- Name: sub_category sub_category_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.sub_category
    ADD CONSTRAINT sub_category_pkey PRIMARY KEY (id);


--
-- Name: sub_sub sub_sub_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.sub_sub
    ADD CONSTRAINT sub_sub_pkey PRIMARY KEY (id);


--
-- Name: test_1 test_1_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_1
    ADD CONSTRAINT test_1_pkey PRIMARY KEY (id);


--
-- Name: test_2 test_2_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_2
    ADD CONSTRAINT test_2_pkey PRIMARY KEY (id);


--
-- Name: test test_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test
    ADD CONSTRAINT test_pkey PRIMARY KEY (id);


--
-- Name: trailer_types trailer_types_name_key; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.trailer_types
    ADD CONSTRAINT trailer_types_name_key UNIQUE (name);


--
-- Name: trailer_types trailer_types_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.trailer_types
    ADD CONSTRAINT trailer_types_pkey PRIMARY KEY (id);


--
-- Name: trailers trailers_number_key; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.trailers
    ADD CONSTRAINT trailers_number_key UNIQUE (number);


--
-- Name: trailers trailers_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.trailers
    ADD CONSTRAINT trailers_pkey PRIMARY KEY (id);


--
-- Name: trans_tp_workers trans_tp_workers_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.trans_tp_workers
    ADD CONSTRAINT trans_tp_workers_pkey PRIMARY KEY (id);


--
-- Name: trans_tp_workers trans_tp_workers_worker_id_transport_type_id_key; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.trans_tp_workers
    ADD CONSTRAINT trans_tp_workers_worker_id_transport_type_id_key UNIQUE (worker_id, transport_type_id);


--
-- Name: transport_types transport_types_name_key; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.transport_types
    ADD CONSTRAINT transport_types_name_key UNIQUE (name);


--
-- Name: transport_types transport_types_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.transport_types
    ADD CONSTRAINT transport_types_pkey PRIMARY KEY (id);


--
-- Name: weights weights_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.weights
    ADD CONSTRAINT weights_pkey PRIMARY KEY (weight);


--
-- Name: workers workers_pkey; Type: CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.workers
    ADD CONSTRAINT workers_pkey PRIMARY KEY (id);


--
-- Name: card_dec card_dec_insert; Type: TRIGGER; Schema: public; Owner: crm_db_user
--

CREATE TRIGGER card_dec_insert AFTER INSERT ON public.card_dec FOR EACH ROW EXECUTE FUNCTION public.trgg_card_dec();


--
-- Name: workers content_trigger; Type: TRIGGER; Schema: public; Owner: crm_db_user
--

CREATE TRIGGER content_trigger AFTER INSERT ON public.workers FOR EACH ROW EXECUTE FUNCTION public.create_content();


--
-- Name: declarant_orders declarant_orders_insert; Type: TRIGGER; Schema: public; Owner: crm_db_user
--

CREATE TRIGGER declarant_orders_insert AFTER INSERT ON public.declarant_orders FOR EACH ROW EXECUTE FUNCTION public.trgg_declarant_orders();


--
-- Name: direction_costs direction_costs_insert; Type: TRIGGER; Schema: public; Owner: crm_db_user
--

CREATE TRIGGER direction_costs_insert AFTER INSERT ON public.direction_costs FOR EACH ROW EXECUTE FUNCTION public.trgg_direction_costs();


--
-- Name: direction_cost_columns direction_values_insert; Type: TRIGGER; Schema: public; Owner: crm_db_user
--

CREATE TRIGGER direction_values_insert AFTER INSERT ON public.direction_cost_columns FOR EACH ROW EXECUTE FUNCTION public.trgg_direction_cost_columns();


--
-- Name: direction_cost_columns direction_values_update; Type: TRIGGER; Schema: public; Owner: crm_db_user
--

CREATE TRIGGER direction_values_update BEFORE DELETE ON public.direction_cost_columns FOR EACH ROW EXECUTE FUNCTION public.trgg_direction_val_update();


--
-- Name: routes routes_insert; Type: TRIGGER; Schema: public; Owner: crm_db_user
--

CREATE TRIGGER routes_insert AFTER INSERT ON public.routes FOR EACH ROW EXECUTE FUNCTION public.trgg_routes();


--
-- Name: border_workers border_workers_borders_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.border_workers
    ADD CONSTRAINT border_workers_borders_id_fk FOREIGN KEY (border_id) REFERENCES public.borders(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: border_workers border_workers_worker_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.border_workers
    ADD CONSTRAINT border_workers_worker_id_fk FOREIGN KEY (worker_id) REFERENCES public.workers(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: card_dec card_dec_dec_order_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.card_dec
    ADD CONSTRAINT card_dec_dec_order_id_fk FOREIGN KEY (dec_order_id) REFERENCES public.declarant_orders(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cities cities_country_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_country_id_fk FOREIGN KEY (country_id) REFERENCES public.countries(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: client_payment_history client_payment_history_client_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.client_payment_history
    ADD CONSTRAINT client_payment_history_client_id_fk FOREIGN KEY (client_id) REFERENCES public.clients(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: client_payment_history client_payment_history_order_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.client_payment_history
    ADD CONSTRAINT client_payment_history_order_id_fk FOREIGN KEY (order_id) REFERENCES public.orders(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: consents consents_category_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.consents
    ADD CONSTRAINT consents_category_id_fk FOREIGN KEY (category_id) REFERENCES public.categories(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: consents consents_worker_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.consents
    ADD CONSTRAINT consents_worker_id_fk FOREIGN KEY (worker_id) REFERENCES public.workers(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: dec_balans dec_balans_border_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.dec_balans
    ADD CONSTRAINT dec_balans_border_id_fk FOREIGN KEY (border_id) REFERENCES public.borders(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: dec_ord_images dec_ord_images_card_dec_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.dec_ord_images
    ADD CONSTRAINT dec_ord_images_card_dec_id_fk FOREIGN KEY (card_dec_id) REFERENCES public.card_dec(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: declarant_orders declarant_orders_border_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.declarant_orders
    ADD CONSTRAINT declarant_orders_border_id_fk FOREIGN KEY (border_id) REFERENCES public.borders(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: declarant_orders declarant_orders_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.declarant_orders
    ADD CONSTRAINT declarant_orders_type_id_fk FOREIGN KEY (type_id) REFERENCES public.transport_types(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: direction_cost_columns direction_cost_columns_direction_cost_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.direction_cost_columns
    ADD CONSTRAINT direction_cost_columns_direction_cost_id_fk FOREIGN KEY (direction_cost_id) REFERENCES public.direction_costs(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: direction_costs direction_costs_route_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.direction_costs
    ADD CONSTRAINT direction_costs_route_id_fk FOREIGN KEY (route_id) REFERENCES public.routes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: direction_values direction_values_column_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.direction_values
    ADD CONSTRAINT direction_values_column_id_fk FOREIGN KEY (column_id) REFERENCES public.direction_cost_columns(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: direction_values direction_values_direction_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.direction_values
    ADD CONSTRAINT direction_values_direction_id_fk FOREIGN KEY (direction_id) REFERENCES public.directions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: directions directions_from_city_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.directions
    ADD CONSTRAINT directions_from_city_id_fk FOREIGN KEY (from_city_id) REFERENCES public.cities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: directions directions_route_id_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.directions
    ADD CONSTRAINT directions_route_id_id_fk FOREIGN KEY (route_id) REFERENCES public.routes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: directions directions_to_city_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.directions
    ADD CONSTRAINT directions_to_city_id_fk FOREIGN KEY (to_city_id) REFERENCES public.cities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: exes exes_card_dec_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.exes
    ADD CONSTRAINT exes_card_dec_id_fk FOREIGN KEY (card_dec_id) REFERENCES public.card_dec(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: images images_order_detail_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT images_order_detail_id_fk FOREIGN KEY (order_detail_id) REFERENCES public.order_details(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: import_trailer_tm import_trailer_tm_order_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.import_trailer_tm
    ADD CONSTRAINT import_trailer_tm_order_id_fk FOREIGN KEY (order_id) REFERENCES public.orders(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_details order_details_border_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT order_details_border_id_fk FOREIGN KEY (border_id) REFERENCES public.borders(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: order_details order_details_driver_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT order_details_driver_id_fk FOREIGN KEY (driver_id) REFERENCES public.drivers(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: order_details order_details_order_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT order_details_order_id_fk FOREIGN KEY (order_id) REFERENCES public.orders(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_details order_details_trailer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT order_details_trailer_id_fk FOREIGN KEY (trailer_id) REFERENCES public.trailers(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: orders orders_client_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_client_id_fk FOREIGN KEY (client_id) REFERENCES public.clients(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: orders orders_cover_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_cover_type_id_fk FOREIGN KEY (cover_type_id) REFERENCES public.cover_types(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: orders orders_from_city_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_from_city_id_fk FOREIGN KEY (from_city_id) REFERENCES public.cities(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: orders orders_item_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_item_type_id_fk FOREIGN KEY (item_type_id) REFERENCES public.item_types(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: orders orders_logist_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_logist_id_fk FOREIGN KEY (logist_id) REFERENCES public.workers(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: orders orders_to_city_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_to_city_id_fk FOREIGN KEY (to_city_id) REFERENCES public.cities(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: orders orders_trailer_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_trailer_type_id_fk FOREIGN KEY (trailer_type_id) REFERENCES public.trailer_types(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: orders orders_transport_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_transport_type_id_fk FOREIGN KEY (transport_type_id) REFERENCES public.transport_types(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: pay_money pay_money_borders_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.pay_money
    ADD CONSTRAINT pay_money_borders_id_fk FOREIGN KEY (border_id) REFERENCES public.borders(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: routes routes_transport_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_transport_type_id_fk FOREIGN KEY (transport_type_id) REFERENCES public.transport_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sub_category sub_category_category_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.sub_category
    ADD CONSTRAINT sub_category_category_id_fk FOREIGN KEY (category_id) REFERENCES public.category(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sub_sub sub_sub_scategory_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.sub_sub
    ADD CONSTRAINT sub_sub_scategory_id_fk FOREIGN KEY (scategory_id) REFERENCES public.sub_category(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: trailers trailers_rent_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.trailers
    ADD CONSTRAINT trailers_rent_type_id_fk FOREIGN KEY (rent_type_id) REFERENCES public.rent_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: trailers trailers_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.trailers
    ADD CONSTRAINT trailers_type_id_fk FOREIGN KEY (type_id) REFERENCES public.trailer_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: trans_tp_workers trans_tp_workers_borders_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.trans_tp_workers
    ADD CONSTRAINT trans_tp_workers_borders_id_fk FOREIGN KEY (transport_type_id) REFERENCES public.transport_types(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: trans_tp_workers trans_tp_workers_worker_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.trans_tp_workers
    ADD CONSTRAINT trans_tp_workers_worker_id_fk FOREIGN KEY (worker_id) REFERENCES public.workers(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: workers workers_mission_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: crm_db_user
--

ALTER TABLE ONLY public.workers
    ADD CONSTRAINT workers_mission_id_fk FOREIGN KEY (mission_id) REFERENCES public.missions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

