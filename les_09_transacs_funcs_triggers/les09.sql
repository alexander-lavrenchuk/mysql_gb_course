/*
Практическое задание по теме “Транзакции, переменные, представления”
*/

/*
1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.
*/
ALTER TABLE sample.users ADD birthday_at DATE;
ALTER TABLE sample.users ADD created_at DATETIME;
ALTER TABLE sample.users ADD updated_at DATETIME;

START TRANSACTION;
INSERT INTO sample.users (SELECT * FROM shop.users WHERE id = 1);
DELETE FROM shop.users WHERE id = 1;
COMMIT;

/*
2. Создайте представление, которое выводит название name товарной позиции из таблицы products и соответствующее название каталога name из таблицы catalogs.
*/
USE shop;
CREATE VIEW prod_cat (product, catalog) AS SELECT p.name, c.name FROM products p JOIN catalogs c ON p.catalog_id = c.id;

/*
3. по желанию) Пусть имеется таблица с календарным полем created_at. В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1, если дата присутствует в исходном таблице и 0, если она отсутствует.
*/
CREATE TABLE tbl (created_at DATE);
INSERT INTO tbl SELECT '2018-08-01';
INSERT INTO tbl SELECT '2018-08-04';
INSERT INTO tbl SELECT '2018-08-16';
INSERT INTO tbl SELECT '2018-08-17';

/CREATE TEMPORARY TABLE dates (`date` DATE);
INSERT dates (`date`) VALUES
('2018-08-01'),
('2018-08-02'),
('2018-08-03'),
('2018-08-04'),
('2018-08-05'),
('2018-08-06'),
('2018-08-07'),
('2018-08-08'),
('2018-08-09'),
('2018-08-10'),
('2018-08-11'),
('2018-08-12'),
('2018-08-13'),
('2018-08-14'),
('2018-08-15'),
('2018-08-16'),
('2018-08-17'),
('2018-08-18'),
('2018-08-19'),
('2018-08-20'),
('2018-08-21'),
('2018-08-22'),
('2018-08-23'),
('2018-08-24'),
('2018-08-25'),
('2018-08-26'),
('2018-08-27'),
('2018-08-28'),
('2018-08-29'),
('2018-08-30'),
('2018-08-31')
;
SELECT date, IF(date IN (SELECT created_at FROM tbl), 1, 0) AS date_exists FROM dates;

/*
4.(по желанию) Пусть имеется любая таблица с календарным полем created_at. Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.
*/
INSERT INTO tbl SELECT '2019-08-01';
INSERT INTO tbl SELECT '2020-08-04';
INSERT INTO tbl SELECT '2020-08-16';
INSERT INTO tbl SELECT '2020-08-17';

CREATE VIEW last_five AS SELECT * FROM tbl GROUP BY created_at ORDER BY created_at DESC LIMIT 5;
DELETE FROM tbl WHERE created_at NOT IN (SELECT created_at FROM last_five);

/*
Практическое задание по теме “Администрирование MySQL” (эта тема изучается по вашему желанию)
*/

/*
1. Создайте двух пользователей которые имеют доступ к базе данных shop. Первому пользователю shop_read должны быть доступны только запросы на чтение данных, второму пользователю shop — любые операции в пределах базы данных shop.
*/

USE mysql;
CREATE USER 'user1'@'localhost' IDENTIFIED BY 'User___1';
CREATE USER 'user2'@'localhost' IDENTIFIED BY 'User___2';
GRANT SELECT ON shop.* TO 'user1'@'localhost';
GRANT ALL PRIVILEGES ON shop.* TO 'user2'@'localhost' WITH GRANT OPTION;

/*
2. (по желанию) Пусть имеется таблица accounts содержащая три столбца id, name, password, содержащие первичный ключ, имя пользователя и его пароль. Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name. Создайте пользователя user_read, который бы не имел доступа к таблице accounts, однако, мог бы извлекать записи из представления username.
*/

CREATE DATABASE lesson9;
USE lesson9;
CREATE TABLE accounts (id SERIAL, name VARCHAR(255), password VARCHAR(255));
INSERT INTO accounts (name, password) VALUES ('alex', 'alex'), ('maria', 'maria'), ('levon', 'levon');
CREATE VIEW username AS SELECT id, name FROM accounts;
USE mysql;
CREATE USER 'user_read'@'localhost' IDENTIFIED BY 'User_read_777';
GRANT SELECT ON lesson9.username TO 'user_read'@'localhost';

/*
Практическое задание по теме “Хранимые процедуры и функции, триггеры"
*/

/*
1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".
*/
DROP FUNCTION IF EXISTS hello;

DELIMiTER //

CREATE FUNCTION hello ()
RETURNS TEXT DETERMINISTIC
BEGIN
	SET @h := HOUR(NOW());
	RETURN
	CASE
        WHEN @h BETWEEN 6 AND 11
            THEN 'Доброе утро'
        WHEN @h BETWEEN 12 AND 17
            THEN 'Добрый день'
        WHEN @h BETWEEN 18 AND 23
            THEN 'Добрый вечер'
        WHEN @h BETWEEN 0 AND 5
        	THEN 'Доброй ночи'
        ELSE 'Неизвестное время'
    END;
END//

DELIMITER ;
SELECT hello();

/*
2. В таблице products есть два текстовых поля: name с названием товара и description с его описанием. Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. При попытке присвоить полям NULL-значение необходимо отменить операцию.
*/
USE shop;

DELIMITER //

CREATE TRIGGER cr_trg_name_or_desc_is_specified BEFORE INSERT ON products
FOR EACH ROW BEGIN
    IF NEW.name IS NULL AND NEW.description IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Необходимо указать значение хотя бы для одного из полей name или description';
    END IF;
END//

CREATE TRIGGER upd_trg_name_or_desc_is_specified BEFORE UPDATE ON products
FOR EACH ROW BEGIN
    IF NEW.name IS NULL AND NEW.description IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Необходимо указать значение хотя бы для одного из полей name или description';
    END IF;
END//

DELIMITER ;

/*
3. (по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел. Вызов функции FIBONACCI(10) должен возвращать число 55.
0	1	2	3	4	5	6	7	8	9	10
0	1	1	2	3	5	8	13	21	34	55
*/
USE lesson9;

DROP TABLE IF EXISTS fib_nums;
SET SESSION sql_mode='NO_AUTO_VALUE_ON_ZERO';
CREATE TABLE IF NOT EXISTS fib_nums (id INT PRIMARY KEY AUTO_INCREMENT, fib_num INT NOT NULL);
INSERT INTO fib_nums (id, fib_num) VALUES (0, 0);
INSERT INTO fib_nums (fib_num) VALUES (1);

DROP FUNCTION IF EXISTS fib;

DELIMITER //
CREATE FUNCTION fib(p INT)
RETURNS INT DETERMINISTIC
BEGIN
-- 	SELECT MAX(id) INTO @r FROM fib_nums;
    SELECT `AUTO_INCREMENT` INTO @r FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'lesson9' AND TABLE_NAME = 'fib_nums';
    SET @r := @r - 1;
	WHILE (@r < p) DO
		SELECT fib_num INTO @a FROM fib_nums WHERE id = @r;
		SELECT fib_num INTO @b FROM fib_nums WHERE id = @r - 1;
		INSERT INTO fib_nums (fib_num) VALUES (@a + @b);
		SET @r := @r + 1;
	END WHILE;
	RETURN (SELECT fib_num FROM fib_nums WHERE id = p);
END//
DELIMITER ;

SELECT fib(10) AS 'fib_num';
