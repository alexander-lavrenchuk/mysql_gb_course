/*
1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders в
интернет магазине.
*/

SELECT name FROM users WHERE EXISTS (SELECT 1 FROM orders WHERE orders.user_id = users.id);


/*
2. Выведите список товаров products и разделов catalogs, который соответствует товару.
*/

SELECT p.name, c.name FROM products AS p JOIN catalogs AS c ON c.id = p.catalog_id;


/*
3. (по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label,
name). Поля from, to и label содержат английские названия городов, поле name — русское.
Выведите список рейсов flights с русскими названиями городов.
*/

SELECT id, 
       (SELECT name FROM cities WHERE cities.label = flights.from) AS 'Откуда', 
       (SELECT name FROM cities WHERE cities.label = flights.to) AS 'Куда' 
FROM flights 
ORDER BY id;

