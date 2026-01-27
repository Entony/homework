CREATE EXTENSION postgres_fdw;
/* SHARD 1 */
/* регистрируем сервер с шардом*/
CREATE SERVER server1
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'postgres_b1', port '5432', dbname 'commerce');
/* настраиваем маппинг*/
CREATE USER MAPPING FOR "postgres"
SERVER server1
OPTIONS (user 'postgres', password 'postgres');
/* создаём таблицу*/
CREATE FOREIGN TABLE users1
(
user_id bigint not null ,
name varchar(50) not null ,
email varchar(50) not null

) SERVER server1
OPTIONS (schema_name 'public', table_name 'users')

CREATE FOREIGN TABLE books1
(
book_id bigint not null ,
title varchar(50) not null ,
author varchar(50) not null,
genre varchar(50) not null,
price decimal(10, 2) not null

) SERVER server1
OPTIONS (schema_name 'public', table_name 'books')

CREATE FOREIGN TABLE stores1
(
store_id bigint not null ,
name varchar(50) not null ,
address varchar(50) not null,
city varchar(50) not null

)
SERVER server1
OPTIONS (schema_name 'public', table_name 'stores');

/* SHARD 2 */
/* регистрируем сервер с шардом*/
CREATE SERVER server2
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'postgres_b2', port '5432', dbname 'commerce');
/* настраиваем маппинг*/
CREATE USER MAPPING FOR "postgres"
SERVER server2
OPTIONS (user 'postgres', password 'postgres');
/* создаём таблицу*/
CREATE FOREIGN TABLE users2
(
user_id bigint not null ,
name varchar(50) not null ,
email varchar(50) not null

) SERVER server2
OPTIONS (schema_name 'public', table_name 'users')

CREATE FOREIGN TABLE books2
(
book_id bigint not null ,
title varchar(50) not null ,
author varchar(50) not null,
genre varchar(50) not null,
price decimal(10, 2) not null

) SERVER server2
OPTIONS (schema_name 'public', table_name 'books')

CREATE FOREIGN TABLE stores2
(
store_id bigint not null ,
name varchar(50) not null ,
address varchar(50) not null,
city varchar(50) not null

)
SERVER server2
OPTIONS (schema_name 'public', table_name 'stores');

/* SHARD 3 */
/* регистрируем сервер с шардом*/
CREATE SERVER server3
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'postgres_b3', port '5432', dbname 'commerce');
/* настраиваем маппинг*/
CREATE USER MAPPING FOR "postgres"
SERVER server3
OPTIONS (user 'postgres', password 'postgres');
/* создаём таблицу*/
CREATE FOREIGN TABLE users3
(
user_id bigint not null ,
name varchar(50) not null ,
email varchar(50) not null

) SERVER server3
OPTIONS (schema_name 'public', table_name 'users')

CREATE FOREIGN TABLE books3
(
book_id bigint not null ,
title varchar(50) not null ,
author varchar(50) not null,
genre varchar(50) not null,
price decimal(10, 2) not null

) SERVER server3
OPTIONS (schema_name 'public', table_name 'books')

CREATE FOREIGN TABLE stores3
(
store_id bigint not null ,
name varchar(50) not null ,
address varchar(50) not null,
city varchar(50) not null

)
SERVER server3
OPTIONS (schema_name 'public', table_name 'stores');

/* создаём представления*/
CREATE VIEW users AS
SELECT *
FROM users1
UNION ALL
SELECT *
FROM users2
UNION ALL
SELECT *
FROM users3

CREATE VIEW books AS
SELECT *
FROM books1
UNION ALL
SELECT *
FROM books1
UNION ALL
SELECT *
FROM books3

CREATE VIEW stores AS
SELECT *
FROM stores1
UNION ALL
SELECT *
FROM stores2
UNION ALL
SELECT *
FROM stores3

/* критерии*/
CREATE RULE users_insert AS ON INSERT TO users
DO INSTEAD NOTHING;
CREATE RULE users_update AS ON UPDATE TO users
DO INSTEAD NOTHING;
CREATE RULE users_delete AS ON DELETE TO users
DO INSTEAD NOTHING;
CREATE RULE users_insert_to_1 AS ON INSERT TO users
WHERE (user_id <= 9999)
DO INSTEAD INSERT INTO users1
VALUES (NEW.*);
CREATE RULE users_insert_to_2 AS ON INSERT TO users
WHERE (users_id >= 10000 and users_id <= 19999)
DO INSTEAD INSERT INTO users2
VALUES (NEW.*);
CREATE RULE users_insert_to_3 AS ON INSERT TO users
WHERE (users_id >= 20000 and users_id <= 30000)
DO INSTEAD INSERT INTO users3
VALUES (NEW.*);

CREATE RULE books_insert AS ON INSERT TO books
DO INSTEAD NOTHING;
CREATE RULE books_update AS ON UPDATE TO books
DO INSTEAD NOTHING;
CREATE RULE books_delete AS ON DELETE TO books
DO INSTEAD NOTHING;
CREATE RULE books_insert_to_1 AS ON INSERT TO books
WHERE (genre = 'fantastic')
DO INSTEAD INSERT INTO books1
VALUES (NEW.*);
CREATE RULE books_insert_to_2 AS ON INSERT TO books
WHERE (genre = 'detective')
DO INSTEAD INSERT INTO books2
VALUES (NEW.*);
CREATE RULE books_insert_to_3 AS ON INSERT TO books
WHERE (genre = 'history')
DO INSTEAD INSERT INTO books3
VALUES (NEW.*);

CREATE RULE stores_insert AS ON INSERT TO stores
DO INSTEAD NOTHING;
CREATE RULE stores_update AS ON UPDATE TO stores
DO INSTEAD NOTHING;
CREATE RULE stores_delete AS ON DELETE TO stores
DO INSTEAD NOTHING;
CREATE RULE stores_insert_to_1 AS ON INSERT TO stores
WHERE (city = 'Moscow')
DO INSTEAD INSERT INTO stores1
VALUES (NEW.*);
CREATE RULE stores_insert_to_2 AS ON INSERT TO stores
WHERE (genre = 'Voronezh')
DO INSTEAD INSERT INTO stores2
VALUES (NEW.*);
CREATE RULE stores_insert_to_3 AS ON INSERT TO stores
WHERE (genre = 'Vladivostok')
DO INSTEAD INSERT INTO stores3
VALUES (NEW.*);