PGDMP     )                    {           psychoemotional    13.11    13.11 *    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    16394    psychoemotional    DATABASE     m   CREATE DATABASE psychoemotional WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'Russian_Ukraine.1251';
    DROP DATABASE psychoemotional;
                postgres    false            �            1255    25493 C   get_best_workers(integer, time with time zone, time with time zone)    FUNCTION     �  CREATE FUNCTION public.get_best_workers(p_owner_id integer, p_start_work_time time with time zone, p_end_work_time time with time zone) RETURNS TABLE(worker_id integer, name character varying, rating double precision, last_comment text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_current_date TIMESTAMP;
    v_seven_days_ago TIMESTAMP;
BEGIN
    v_current_date := CURRENT_DATE;
    v_seven_days_ago := v_current_date - INTERVAL '7 days';

    RETURN QUERY
    WITH worker_last_seven_days_data AS (
        SELECT 
            wd.id_worker,
            wd.stress_level,
            wd.sleep_quality,
            wd.energy_level,
            wd.sleep_start_time,
            wd.sleep_end_time,
            wd.comment,
            wd.record_date
        FROM 
            worker_data wd
        WHERE 
            wd.record_date BETWEEN v_seven_days_ago AND v_current_date
    ), worker_avg_data AS (
        SELECT
            w.id_worker,
            w.name_worker,
            w.usually_sleep_start_time,
            w.usually_sleep_end_time,
            w.usually_peak_productivity_time,
            w.usually_lowest_productivity_time,
            AVG(wd.stress_level) as avg_stress_level,
            AVG(wd.sleep_quality) as avg_sleep_quality,
            AVG(wd.energy_level) as avg_energy_level,
            MAX(wd.comment) as last_comment
        FROM
            worker w
            JOIN worker_last_seven_days_data wd ON w.id_worker = wd.id_worker
        WHERE
            w.id_owner = p_owner_id
        GROUP BY 
            w.id_worker, w.name_worker, w.usually_sleep_start_time, w.usually_sleep_end_time, w.usually_peak_productivity_time, w.usually_lowest_productivity_time
    )
    SELECT
        w.id_worker,
        w.name_worker as name,
        (1 - ABS(EXTRACT(EPOCH FROM (p_start_work_time::TEXT::TIME - w.usually_peak_productivity_time::TEXT::TIME))/3600)/24 +
         1 - ABS(EXTRACT(EPOCH FROM (p_end_work_time::TEXT::TIME - w.usually_lowest_productivity_time::TEXT::TIME))/3600)/24 +
         w.avg_sleep_quality/100 - 
         w.avg_stress_level/100 + 
         w.avg_energy_level/100)/5 as rating,
        w.last_comment
    FROM
        worker_avg_data w
    ORDER BY 
        rating DESC;
END;
$$;
 �   DROP FUNCTION public.get_best_workers(p_owner_id integer, p_start_work_time time with time zone, p_end_work_time time with time zone);
       public          postgres    false            �            1259    16988    iot    TABLE     O   CREATE TABLE public.iot (
    id_iot integer NOT NULL,
    id_owner integer
);
    DROP TABLE public.iot;
       public         heap    postgres    false            �            1259    16986    iot_id_iot_seq    SEQUENCE     �   CREATE SEQUENCE public.iot_id_iot_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.iot_id_iot_seq;
       public          postgres    false    201            �           0    0    iot_id_iot_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.iot_id_iot_seq OWNED BY public.iot.id_iot;
          public          postgres    false    200            �            1259    16996    owner    TABLE       CREATE TABLE public.owner (
    id_owner integer NOT NULL,
    name_owner character varying(255),
    mail_owner character varying(255),
    password_owner character varying(255),
    id_iot integer,
    availability_iot boolean,
    role text DEFAULT 'owner'::text
);
    DROP TABLE public.owner;
       public         heap    postgres    false            �            1259    16994    owner_id_owner_seq    SEQUENCE     �   CREATE SEQUENCE public.owner_id_owner_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.owner_id_owner_seq;
       public          postgres    false    203            �           0    0    owner_id_owner_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.owner_id_owner_seq OWNED BY public.owner.id_owner;
          public          postgres    false    202            �            1259    17015    sensor_data    TABLE     �   CREATE TABLE public.sensor_data (
    id_sensor integer NOT NULL,
    humidity double precision,
    temperature double precision,
    noise double precision,
    illumination double precision,
    id_iot integer,
    date time without time zone
);
    DROP TABLE public.sensor_data;
       public         heap    postgres    false            �            1259    17013    sensor_data_id_sensor_seq    SEQUENCE     �   CREATE SEQUENCE public.sensor_data_id_sensor_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.sensor_data_id_sensor_seq;
       public          postgres    false    207            �           0    0    sensor_data_id_sensor_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.sensor_data_id_sensor_seq OWNED BY public.sensor_data.id_sensor;
          public          postgres    false    206            �            1259    17007    worker    TABLE     y  CREATE TABLE public.worker (
    id_worker integer NOT NULL,
    mail_worker character varying(255),
    usually_sleep_start_time time with time zone,
    usually_sleep_end_time time with time zone,
    usually_peak_productivity_time time with time zone,
    usually_lowest_productivity_time time with time zone,
    id_owner integer,
    name_worker character varying(255)
);
    DROP TABLE public.worker;
       public         heap    postgres    false            �            1259    17151    worker_data    TABLE     �  CREATE TABLE public.worker_data (
    id_worker_data integer NOT NULL,
    id_worker integer NOT NULL,
    id_sensor integer NOT NULL,
    stress_level integer,
    sleep_quality integer,
    energy_level integer,
    sleep_start_time time with time zone,
    sleep_end_time time with time zone,
    comment text,
    record_date timestamp without time zone,
    record_time timestamp without time zone[]
);
    DROP TABLE public.worker_data;
       public         heap    postgres    false            �            1259    17149    worker_data_id_worker_data_seq    SEQUENCE     �   ALTER TABLE public.worker_data ALTER COLUMN id_worker_data ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.worker_data_id_worker_data_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
    CYCLE
);
            public          postgres    false    209            �            1259    17005    worker_id_worker_seq    SEQUENCE     �   CREATE SEQUENCE public.worker_id_worker_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.worker_id_worker_seq;
       public          postgres    false    205            �           0    0    worker_id_worker_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.worker_id_worker_seq OWNED BY public.worker.id_worker;
          public          postgres    false    204            ?           2604    16991 
   iot id_iot    DEFAULT     h   ALTER TABLE ONLY public.iot ALTER COLUMN id_iot SET DEFAULT nextval('public.iot_id_iot_seq'::regclass);
 9   ALTER TABLE public.iot ALTER COLUMN id_iot DROP DEFAULT;
       public          postgres    false    200    201    201            @           2604    16999    owner id_owner    DEFAULT     p   ALTER TABLE ONLY public.owner ALTER COLUMN id_owner SET DEFAULT nextval('public.owner_id_owner_seq'::regclass);
 =   ALTER TABLE public.owner ALTER COLUMN id_owner DROP DEFAULT;
       public          postgres    false    203    202    203            C           2604    17018    sensor_data id_sensor    DEFAULT     ~   ALTER TABLE ONLY public.sensor_data ALTER COLUMN id_sensor SET DEFAULT nextval('public.sensor_data_id_sensor_seq'::regclass);
 D   ALTER TABLE public.sensor_data ALTER COLUMN id_sensor DROP DEFAULT;
       public          postgres    false    206    207    207            B           2604    17010    worker id_worker    DEFAULT     t   ALTER TABLE ONLY public.worker ALTER COLUMN id_worker SET DEFAULT nextval('public.worker_id_worker_seq'::regclass);
 ?   ALTER TABLE public.worker ALTER COLUMN id_worker DROP DEFAULT;
       public          postgres    false    204    205    205            �          0    16988    iot 
   TABLE DATA                 public          postgres    false    201   e8       �          0    16996    owner 
   TABLE DATA                 public          postgres    false    203   �8       �          0    17015    sensor_data 
   TABLE DATA                 public          postgres    false    207   �9       �          0    17007    worker 
   TABLE DATA                 public          postgres    false    205   �:       �          0    17151    worker_data 
   TABLE DATA                 public          postgres    false    209   �;       �           0    0    iot_id_iot_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.iot_id_iot_seq', 4, true);
          public          postgres    false    200            �           0    0    owner_id_owner_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.owner_id_owner_seq', 12, true);
          public          postgres    false    202            �           0    0    sensor_data_id_sensor_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.sensor_data_id_sensor_seq', 129, true);
          public          postgres    false    206            �           0    0    worker_data_id_worker_data_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.worker_data_id_worker_data_seq', 66, true);
          public          postgres    false    208            �           0    0    worker_id_worker_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.worker_id_worker_seq', 15, true);
          public          postgres    false    204            E           2606    16993    iot iot_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.iot
    ADD CONSTRAINT iot_pkey PRIMARY KEY (id_iot);
 6   ALTER TABLE ONLY public.iot DROP CONSTRAINT iot_pkey;
       public            postgres    false    201            G           2606    17004    owner owner_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.owner
    ADD CONSTRAINT owner_pkey PRIMARY KEY (id_owner);
 :   ALTER TABLE ONLY public.owner DROP CONSTRAINT owner_pkey;
       public            postgres    false    203            K           2606    17023    sensor_data sensor_data_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.sensor_data
    ADD CONSTRAINT sensor_data_pkey PRIMARY KEY (id_sensor);
 F   ALTER TABLE ONLY public.sensor_data DROP CONSTRAINT sensor_data_pkey;
       public            postgres    false    207            M           2606    17158    worker_data worker_data_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.worker_data
    ADD CONSTRAINT worker_data_pkey PRIMARY KEY (id_worker_data);
 F   ALTER TABLE ONLY public.worker_data DROP CONSTRAINT worker_data_pkey;
       public            postgres    false    209            I           2606    17012    worker worker_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.worker
    ADD CONSTRAINT worker_pkey PRIMARY KEY (id_worker);
 <   ALTER TABLE ONLY public.worker DROP CONSTRAINT worker_pkey;
       public            postgres    false    205            N           2606    17059    iot iot_id_owner_fkey    FK CONSTRAINT     {   ALTER TABLE ONLY public.iot
    ADD CONSTRAINT iot_id_owner_fkey FOREIGN KEY (id_owner) REFERENCES public.owner(id_owner);
 ?   ALTER TABLE ONLY public.iot DROP CONSTRAINT iot_id_owner_fkey;
       public          postgres    false    203    201    2887            O           2606    17044    owner owner_id_iot_fkey    FK CONSTRAINT     w   ALTER TABLE ONLY public.owner
    ADD CONSTRAINT owner_id_iot_fkey FOREIGN KEY (id_iot) REFERENCES public.iot(id_iot);
 A   ALTER TABLE ONLY public.owner DROP CONSTRAINT owner_id_iot_fkey;
       public          postgres    false    203    201    2885            Q           2606    17024 #   sensor_data sensor_data_id_iot_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sensor_data
    ADD CONSTRAINT sensor_data_id_iot_fkey FOREIGN KEY (id_iot) REFERENCES public.iot(id_iot);
 M   ALTER TABLE ONLY public.sensor_data DROP CONSTRAINT sensor_data_id_iot_fkey;
       public          postgres    false    207    2885    201            P           2606    17049    worker worker_id_owner_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.worker
    ADD CONSTRAINT worker_id_owner_fkey FOREIGN KEY (id_owner) REFERENCES public.owner(id_owner);
 E   ALTER TABLE ONLY public.worker DROP CONSTRAINT worker_id_owner_fkey;
       public          postgres    false    203    2887    205            �   L   x���v
Q���W((M��L���/Qs�	uV�0�Q���Ѵ��į�\G���*3�T�(�Ve��`
T�� c�6N      �     x����J�0����(DA��Z-xSe�]7�͡w��X�6YҬn����g�#�9�2ax���/�w%Y��A�����gR�mk���u<	3pb�(���*TK��̐-�3���Q��X�5��+#���R��]�Շڀ���j��/���@�ܪq�rJ��d�G=M�R����~C#��i�?_�5]D��%��CӼżY)�д~����ɇ�A�}n&�c��i���0��2MhKw�s�[�Ń�7��߿���{4�������T�      �   �   x����
�@ �O�7d��5;u� �Ajװ�CY�ߌlt�peAfa>fv���|Ӑ�j����_�ڟ����;vώlWe��d��tB��5�� ��,�˨�W,!#ǧ �b���_F�b�7ѮXa/v� H�{��f�+��0lEh*qe&Jݪbf3i3nbR�'aH��0#f#�2��f��7�Z{�ixr���Z�����+G��c~!v4EoʦO�      �   �   x���v
Q���W((M��L�+�/�N-Rs�	uV�0�QP��/.�,Ỉ��:�V$���%���,��H�� �54C�Z�p����@��
���5��<	���eF�.32B��ex��eFĹ��e�.C����kN�ˌ�s�	PkIQi2PWd����%�Q��f@���$ƥ)��0�����$ E���      �   �  x�͖Ok�@��~��[�f7�G{l�U0V詤&Q	j+�߽qӤ��k�[����!?ޛ�x]������l�<����d%Oa0Po���ލ�� ����hؾ{p���Ιm!f!����Ң���%���y��I�`��`�>Lh���ie�|��.l�]�Y����~�/�k�ql�c![UJ�Z��*[�؉�p��BK/�6D�6!��&�R"��d���*h�����*���$��yF�F�7	V���`"��D���m�U��G�}M���a�9 	Un�O�X�����<��ϭBP��ɉJ��Z�R7'��0�+f;�5�� ]�]+V ��
h/�$x����.:	n	niv�bR�2�nyC�iРI)�I)Oʦ±�^�6NK�8'�U���8`{p{�ۛ��9��DJ�M�l�0�P�$�8a{Sy�(@�$��x�O��	ș]l�3S7�T���)?���TѸB���j�/ԩ'M     