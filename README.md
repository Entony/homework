# Домашнее задание к занятию "SQL. Часть 2" - Карпов Антон Юрьевич

## Задание 1

Одним запросом получите информацию о магазине, в котором обслуживается более 300 покупателей, и выведите в результат следующую информацию:

фамилия и имя сотрудника из этого магазина;
город нахождения магазина;
количество пользователей, закреплённых в этом магазине.

## Решение 1

Запрос
```
select concat(s.first_name, ' ', s.last_name) AS staff_name, c.city, count(cu.customer_id) AS count_of_customers 
from staff s
inner join store st ON st.store_id = s.store_id
inner join address a ON st.address_id = a.address_id
inner join city c ON c.city_id = a.city_id 
inner join customer cu ON st.store_id = cu.store_id
group by staff_name, c.city
having count_of_customers > 300; 
```

Результат:

![alt text](image.png)


## Задание 2

Получите количество фильмов, продолжительность которых больше средней продолжительности всех фильмов.

## Решение 2

Запрос:
```
select count(film_id)
from film
where length > (select avg(length) from film);
```

Результат:

![alt text](image-1.png)


## Задание 3

Получите информацию, за какой месяц была получена наибольшая сумма платежей, и добавьте информацию по количеству аренд за этот месяц.

## Решение 3

Запрос:
```
select month(payment_date), sum(amount) as sum, count(r.rental_id) as rental_count
from payment p
left join rental r on r.rental_id = p.rental_id
group by month(p.payment_date)
order by sum desc
limit 1;
```

Результат:

![alt text](image-2.png)


## Задание 4*

Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку «Премия». Если количество продаж превышает 8000, то значение в колонке будет «Да», иначе должно быть значение «Нет».

## Решение 4

Запрос:
```
select concat(s.first_name, ' ', s.last_name) as name, count(payment_id) as count_sales,
case 
	when count(payment_id) > 8000 then 'Yes'
	else 'No'
end as Bonus
from payment p
inner join staff s ON s.staff_id = p.staff_id
GROUP BY name;
```
Результат:

![alt text](image-3.png)


## Задание 5*

Найдите фильмы, которые ни разу не брали в аренду.

## Решение 5

Запрос:
```
select f.title
from film f
left join inventory i on i.film_id = f.film_id
left join rental r on i.inventory_id = r.inventory_id 
where r.rental_id IS NULL;
```

Результат:

![alt text](image-4.png)
![alt text](image-5.png)







