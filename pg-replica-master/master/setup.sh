#!/bin/bash
set -e

# Настройка PostgreSQL для master сервера
echo "Настройка master сервера для репликации..."

# Обновляем postgresql.conf
cat >> ${PGDATA}/postgresql.conf <<EOF

# Настройки репликации
wal_level = replica
max_wal_senders = 3
max_replication_slots = 3
wal_keep_size = 1GB
hot_standby = on
EOF

# Добавляем правило для репликации в pg_hba.conf
echo "host replication replicator 0.0.0.0/0 trust" >> ${PGDATA}/pg_hba.conf

# Перезагружаем конфигурацию
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    SELECT pg_reload_conf();
EOSQL

echo "Master сервер настроен для репликации." 