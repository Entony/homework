-- Создание пользователя для репликации
CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'replicator_password';

-- Создание тестовой базы данных и таблицы для проверки репликации
CREATE DATABASE testdb;

\c testdb;

CREATE TABLE test_table (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO test_table (name) VALUES 
    ('Test Record 1'),
    ('Test Record 2'),
    ('Test Record 3');

-- Вернемся к базе postgres для завершения
\c postgres;

-- Создание слота репликации (опционально)
SELECT pg_create_physical_replication_slot('replica_slot'); 