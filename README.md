# Домашнее задание к занятию "Индексы" - Карпов Антон Юрьевич

## Задание 1

Напишите запрос к учебной базе данных, который вернёт процентное отношение общего размера всех индексов к общему размеру всех таблиц.

## Решение 1

```
SELECT 
    ROUND(
        SUM(INDEX_LENGTH) * 100.0 / SUM(DATA_LENGTH), 2
    ) AS index_and_tables
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'sakila'
  AND TABLE_TYPE = 'BASE TABLE';
```

![alt text](image.png)

## Задание 2

Выполните explain analyze следующего запроса:

```
select distinct concat(c.last_name, ' ', c.first_name), sum(p.amount) over (partition by c.customer_id, f.title)
from payment p, rental r, customer c, inventory i, film f
where date(p.payment_date) = '2005-07-30' and p.payment_date = r.rental_date and r.customer_id = c.customer_id and i.inventory_id = r.inventory_id
```

* перечислите узкие места;
* оптимизируйте запрос: внесите корректировки по использованию операторов, при необходимости добавьте индексы.

## Решение 2

1. Отсутствует связь inventory.film_id = film.film_id

2. Некорректное соединение payment и rental через даты

p.payment_date = r.rental_date  
→ В реальной структуре Sakila связь должна быть через p.rental_id = r.rental_id. С
3. Функция DATE() в условии фильтрации. Блокирует использование индекса, приводит к полному сканированию таблицы payment.
4. Устаревший синтаксис соединений (через запятую)
5. Избыточное использование DISTINCT
→ При правильной группировке DISTINCT не требуется и лишь добавляет накладные расходы.

Оптимизированный запрос:

```
SELECT 
    CONCAT(c.last_name, ' ', c.first_name) AS customer_name,
    f.title,
    SUM(p.amount) AS total_amount
FROM payment p
JOIN rental r 
  ON p.rental_id = r.rental_id  -- ✅ Корректная связь
JOIN customer c 
  ON r.customer_id = c.customer_id
JOIN inventory i 
  ON r.inventory_id = i.inventory_id
JOIN film f 
  ON i.film_id = f.film_id  -- ✅ Добавлена недостающая связь
WHERE p.payment_date >= '2005-07-30' 
  AND p.payment_date < '2005-07-31'  -- ✅ Диапазон вместо DATE()
GROUP BY c.customer_id, c.last_name, c.first_name, f.title  -- ✅ Чёткая группировка
ORDER BY customer_name, f.title;
```

## Задание 3*

Самостоятельно изучите, какие типы индексов используются в PostgreSQL. Перечислите те индексы, которые используются в PostgreSQL, а в MySQL — нет.

Приведите ответ в свободной форме.

## Решение 3

В PostgreSQL используются индексы:
- B-дерево
- Хеш
- GiST
- SP-GiST
- GIN
- BRIN

В MySQL:
- B-Tree
- Hash 
- Full-text
- Spatial

Соответственно, в PG используются GiST, SP-GiST, GIN, BRIN, но не используются в MySQL.





















