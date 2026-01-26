# PostgreSQL Master-Slave Репликация с Docker Compose

Этот проект настраивает асинхронную master-slave репликацию PostgreSQL с использованием Docker Compose.

## Структура проекта

```
.
├── docker-compose.yml          # Основная конфигурация Docker Compose
├── master/                     # Конфигурация master сервера
│   ├── postgresql.conf         # Настройки PostgreSQL для master
│   ├── pg_hba.conf            # Правила аутентификации
│   └── init.sql               # Скрипт инициализации
├── slave/                      # Конфигурация slave сервера
│   ├── postgresql.conf         # Настройки PostgreSQL для slave
│   └── recovery.conf          # Настройки восстановления
└── README.md
```

## Запуск

1. Запустите контейнеры:
```bash
docker-compose up -d
```

2. Проверьте статус контейнеров:
```bash
docker-compose ps
```

## Подключение к серверам

### Master сервер:
- **Хост:** localhost
- **Порт:** 5432
- **Пользователь:** postgres
- **Пароль:** postgres

```bash
psql -h localhost -p 5432 -U postgres -d postgres
```

### Slave сервер:
- **Хост:** localhost
- **Порт:** 5433
- **Пользователь:** postgres
- **Пароль:** postgres

```bash
psql -h localhost -p 5433 -U postgres -d postgres
```

## Тестирование репликации

1. Подключитесь к master серверу и создайте тестовые данные:
```sql
\c testdb;
INSERT INTO test_table (name) VALUES ('Новая запись ' || NOW());
SELECT * FROM test_table;
```

2. Подключитесь к slave серверу и проверьте репликацию:
```sql
\c testdb;
SELECT * FROM test_table;
```

## Проверка статуса репликации

### На master сервере:
```sql
-- Проверка активных подключений репликации
SELECT * FROM pg_stat_replication;

-- Проверка слотов репликации
SELECT * FROM pg_replication_slots;
```

### На slave сервере:
```sql
-- Проверка статуса восстановления
SELECT pg_is_in_recovery();

-- Информация о последнем полученном WAL
SELECT pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn();
```

## Полезные команды

### Просмотр логов:
```bash
# Логи master сервера
docker-compose logs postgres-master

# Логи slave сервера
docker-compose logs postgres-slave
```

### Остановка и удаление:
```bash
# Остановка
docker-compose down

# Удаление с данными
docker-compose down -v
```

### Перезапуск отдельного сервера:
```bash
docker-compose restart postgres-master
docker-compose restart postgres-slave
```

## Важные замечания

1. **Асинхронная репликация:** Slave сервер может отставать от master на несколько транзакций
2. **Только чтение на slave:** Slave сервер работает в режиме hot standby (только чтение)
3. **Автоматическое восстановление:** При перезапуске slave автоматически восстанавливает соединение с master
4. **Пароли:** В production окружении используйте более безопасные пароли
5. **Сеть:** Контейнеры используют внутреннюю Docker сеть для связи

## Мониторинг

Для мониторинга репликации можно использовать следующие запросы:

```sql
-- Задержка репликации в байтах
SELECT 
    client_addr,
    application_name,
    state,
    sent_lsn,
    write_lsn,
    flush_lsn,
    replay_lsn,
    (sent_lsn - replay_lsn) AS lag_bytes
FROM pg_stat_replication;
``` 