#!/bin/bash

echo "🔍 Тестирование PostgreSQL Master-Slave репликации..."
echo

# Цвета для вывода
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Проверка, что контейнеры запущены
echo -e "${BLUE}📦 Проверка статуса контейнеров...${NC}"
if ! docker-compose ps | grep -q "postgres-master.*running" || ! docker-compose ps | grep -q "postgres-slave.*running"; then
    echo -e "${RED}❌ Контейнеры не запущены. Запустите их командой: docker-compose up -d${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Контейнеры запущены${NC}"
echo

# Ожидание готовности серверов
echo -e "${BLUE}⏳ Ожидание готовности серверов...${NC}"
sleep 5

# Проверка подключения к master
echo -e "${BLUE}🔌 Проверка подключения к master серверу...${NC}"
if docker exec postgres-master pg_isready -U postgres > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Master сервер готов${NC}"
else
    echo -e "${RED}❌ Master сервер не готов${NC}"
    exit 1
fi

# Проверка подключения к slave
echo -e "${BLUE}🔌 Проверка подключения к slave серверу...${NC}"
if docker exec postgres-slave pg_isready -U postgres > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Slave сервер готов${NC}"
else
    echo -e "${RED}❌ Slave сервер не готов${NC}"
    exit 1
fi
echo

# Проверка статуса репликации на master
echo -e "${BLUE}📊 Проверка статуса репликации на master...${NC}"
REPLICATION_STATUS=$(docker exec postgres-master psql -U postgres -t -c "SELECT count(*) FROM pg_stat_replication;" 2>/dev/null | tr -d ' ')
if [ "$REPLICATION_STATUS" -gt 0 ]; then
    echo -e "${GREEN}✅ Репликация активна ($REPLICATION_STATUS подключение(й))${NC}"
    docker exec postgres-master psql -U postgres -c "SELECT application_name, state, sync_state FROM pg_stat_replication;"
else
    echo -e "${YELLOW}⚠️  Репликация не активна${NC}"
fi
echo

# Проверка, что slave в режиме восстановления
echo -e "${BLUE}🔄 Проверка режима восстановления на slave...${NC}"
IN_RECOVERY=$(docker exec postgres-slave psql -U postgres -t -c "SELECT pg_is_in_recovery();" 2>/dev/null | tr -d ' ')
if [ "$IN_RECOVERY" = "t" ]; then
    echo -e "${GREEN}✅ Slave в режиме восстановления${NC}"
else
    echo -e "${RED}❌ Slave НЕ в режиме восстановления${NC}"
fi
echo

# Создание тестовых данных на master
echo -e "${BLUE}📝 Создание тестовых данных на master...${NC}"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
docker exec postgres-master psql -U postgres -d testdb -c "INSERT INTO test_table (name) VALUES ('Тест репликации $TIMESTAMP');"
echo -e "${GREEN}✅ Данные добавлены на master${NC}"
echo

# Ожидание репликации
echo -e "${BLUE}⏳ Ожидание репликации (5 секунд)...${NC}"
sleep 5

# Проверка данных на slave
echo -e "${BLUE}🔍 Проверка данных на slave...${NC}"
MASTER_COUNT=$(docker exec postgres-master psql -U postgres -d testdb -t -c "SELECT count(*) FROM test_table;" | tr -d ' ')
SLAVE_COUNT=$(docker exec postgres-slave psql -U postgres -d testdb -t -c "SELECT count(*) FROM test_table;" | tr -d ' ')

echo "📊 Количество записей на master: $MASTER_COUNT"
echo "📊 Количество записей на slave: $SLAVE_COUNT"

if [ "$MASTER_COUNT" = "$SLAVE_COUNT" ]; then
    echo -e "${GREEN}✅ Репликация работает корректно!${NC}"
else
    echo -e "${YELLOW}⚠️  Возможна задержка репликации${NC}"
fi
echo

# Показать последние записи
echo -e "${BLUE}📋 Последние записи в таблице:${NC}"
echo -e "${YELLOW}Master:${NC}"
docker exec postgres-master psql -U postgres -d testdb -c "SELECT * FROM test_table ORDER BY id DESC LIMIT 3;"
echo
echo -e "${YELLOW}Slave:${NC}"
docker exec postgres-slave psql -U postgres -d testdb -c "SELECT * FROM test_table ORDER BY id DESC LIMIT 3;"
echo

echo -e "${GREEN}🎉 Тестирование завершено!${NC}" 