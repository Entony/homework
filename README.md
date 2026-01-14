# Домашнее задание к занятию 3 "ELK" - Карпов Антон Юрьевич

## Задание 1. Elasticsearch

Установите и запустите Elasticsearch, после чего поменяйте параметр cluster_name на случайный.

Приведите скриншот команды 'curl -X GET 'localhost:9200/_cluster/health?pretty', сделанной на сервере с установленным Elasticsearch. Где будет виден нестандартный cluster_name.

## Решение 1

Скриншот команды curl после установки и замены cluster_name:

![alt text](image.png)


## Задание 2. Kibana

Установите и запустите Kibana.

Приведите скриншот интерфейса Kibana на странице http://<ip вашего сервера>:5601/app/dev_tools#/console, где будет выполнен запрос GET /_cluster/health?pretty.

## Решение 2

Скриншот с запросом GET:

![alt text](image-1.png)


## Задание 3. Logstash

Установите и запустите Logstash и Nginx. С помощью Logstash отправьте access-лог Nginx в Elasticsearch.

Приведите скриншот интерфейса Kibana, на котором видны логи Nginx.

## Решение 3

Скриншот с логами nginx:

![alt text](image-2.png)


## Задание 4. Filebeat

Установите и запустите Filebeat. Переключите поставку логов Nginx с Logstash на Filebeat.

Приведите скриншот интерфейса Kibana, на котором видны логи Nginx, которые были отправлены через Filebeat.

## Решение 4

Скриншот с логами Nginx через Filebeat:

![alt text](image-3.png)










 




