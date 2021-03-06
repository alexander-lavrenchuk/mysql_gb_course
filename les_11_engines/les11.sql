/*
Практическое задание по теме “Оптимизация запросов”
*/

/*
1. Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, catalogs и products в таблицу logs помещается время и дата создания записи, название таблицы, идентификатор первичного ключа и содержимое поля name.
*/

USE shop;

CREATE TABLE IF NOT EXISTS logs (
id SERIAL,
source_table VARCHAR(255) NOT NULL,
source_id BIGINT NOT NULL,
source_name VARCHAR (255) NOT NULL,
created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP)
ENGINE ARCHIVE;

DELIMITER //
CREATE TRIGGER tr_log_users
AFTER INSERT ON users
FOR EACH ROW BEGIN 
	INSERT INTO logs (source_table, source_id, source_name)
	VALUES ('users', NEW.id, NEW.name);
END//

CREATE TRIGGER tr_log_catalogs
AFTER INSERT ON catalogs
FOR EACH ROW BEGIN
	INSERT INTO logs (source_table, source_id, source_name)
	VALUES ('catalogs', NEW.id, NEW.name);
END//

CREATE TRIGGER tr_log_products
AFTER INSERT ON products
FOR EACH ROW BEGIN
	INSERT INTO logs (source_table, source_id, source_name)
	VALUES ('products', NEW.id, NEW.name);
END//

DELIMITER ;

/*
2. (по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.
*/

DROP PROCEDURE IF EXISTS ins_mln_usrs;

DELIMITER //

CREATE PROCEDURE ins_mln_usrs ()
BEGIN
    SET @i := 0;
    WHILE (@i < 1000000) DO
        SET @i := @i + 1;
        INSERT INTO users (name)
            VALUES (CONCAT('user_', @i));
    END WHILE;
END//

DELIMITER ;

CALL ins_mln_usrs(); 

/*
Практическое задание по теме “NoSQL”
*/

/*
1. В базе данных Redis подберите коллекцию для подсчета посещений с определенных IP-адресов.
*/
127.0.0.1:6379> HINCRBY ip_counts '127.0.0.1' 1
(integer) 1
127.0.0.1:6379> HINCRBY ip_counts '192.168.10.1' 1
(integer) 1
127.0.0.1:6379> HINCRBY ip_counts '127.0.0.1' 1
(integer) 2
127.0.0.1:6379> HINCRBY ip_counts '127.0.0.1' 1
(integer) 3
127.0.0.1:6379> HINCRBY ip_counts '127.0.0.1' 1
(integer) 4
127.0.0.1:6379> HINCRBY ip_counts '127.0.0.1' 1
(integer) 5
127.0.0.1:6379> HINCRBY ip_counts '192.168.10.1' 1
(integer) 2
127.0.0.1:6379> HINCRBY ip_counts '192.168.10.1' 1
(integer) 3
127.0.0.1:6379> HGETALL ip_counts
1) "127.0.0.1"
2) "5"
3) "192.168.10.1"
4) "3"
127.0.0.1:6379>

/*
2. При помощи базы данных Redis решите задачу поиска имени пользователя по электронному адресу и наоборот, поиск электронного адреса пользователя по его имени.
*/
-- Создаём хэш для каждого пользователя с полями email и name, а также создаём индексы для поиска ключей хэшей по значению полей
127.0.0.1:6379> HSET users:prof1 email user1@mail.ru name alex
(integer) 2
127.0.0.1:6379> SADD user1@mail.ru users:prof1
(integer) 1
127.0.0.1:6379> SADD alex users:prof1
(integer) 1

127.0.0.1:6379> HSET users:prof2 email user2@mail.ru name maria
(integer) 2
127.0.0.1:6379> SADD user2@mail.ru users:prof2
(integer) 1
127.0.0.1:6379> SADD maria users:prof2
(integer) 1

127.0.0.1:6379> HSET users:prof3 email user3@mail.ru name alex
(integer) 2
127.0.0.1:6379> SADD user3@mail.ru users:prof3
(integer) 1
127.0.0.1:6379> SADD alex users:prof3
(integer) 1

127.0.0.1:6379> HSET users:prof4 email user4@mail.ru name olga
(integer) 2
127.0.0.1:6379> SADD user4@mail.ru users:prof4
(integer) 1
127.0.0.1:6379> SADD olga users:prof4
(integer) 1

-- Поиск по имени
127.0.0.1:6379> SMEMBERS alex
1) "users:prof3"
2) "users:prof1"
127.0.0.1:6379> HGET users:prof1 email
"user1@mail.ru"
127.0.0.1:6379> HGET users:prof3 email
"user3@mail.ru"

-- Поиск по email
127.0.0.1:6379> SMEMBERS user2@mail.ru
1) "users:prof2"
127.0.0.1:6379> HGET users:prof2 name
"maria"

/*
3. Организуйте хранение категорий и товарных позиций учебной базы данных shop в СУБД MongoDB.
*/
> use shop

> db.createCollection('catalogs')
> show collections
catalogs

> db.catalogs.insertMany([
	{name: 'Процессоры'},
	{name: 'Материнские платы'},
	{name: 'Видеокарты'},
	{name: 'Жесткие диски'},
	{name: 'Оперативная память'}
])

> db.catalogs.find()
{ "_id" : ObjectId("60f7235e31961b195057956e"), "name" : "Процессоры" }
{ "_id" : ObjectId("60f7235e31961b195057956f"), "name" : "Материнские платы" }
{ "_id" : ObjectId("60f7235e31961b1950579570"), "name" : "Видеокарты" }
{ "_id" : ObjectId("60f7235e31961b1950579571"), "name" : "Жесткие диски" }
{ "_id" : ObjectId("60f7235e31961b1950579572"), "name" : "Оперативная память" }




> db.createCollection('products')
> show collections
catalogs
products

> db. products.insertMany([
	{name: 'Intel Core i3-8100',
	 description: 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.',
	 price: 7890.00,
	 catalog_id: ObjectId("60f7235e31961b195057956e"),
	 created_at: '2021-07-07 19:06:41',
	 updated_at: '2021-07-07 19:06:41'
	},
	{name: 'Intel Core i5-7400',
	 description: 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.',
	 price: 12700.00,
	 catalog_id: ObjectId("60f7235e31961b195057956e"),
	 created_at: '2021-07-07 19:06:41',
	 updated_at: '2021-07-07 19:06:41'
	},
	{name: 'AMD FX-8320E',
	 description: 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.',
	 price: 4780.00,
	 catalog_id: ObjectId("60f7235e31961b195057956e"),
	 created_at: '2021-07-07 19:06:41',
	 updated_at: '2021-07-07 19:06:41'
	},
	{name: 'AMD FX-8320',
	 description: 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.',
	 price: 7120.00,
	 catalog_id: ObjectId("60f7235e31961b195057956e"),
	 created_at: '2021-07-07 19:06:41',
	 updated_at: '2021-07-07 19:06:41'
	},
	{name: 'ASUS ROG MAXIMUS X HERO',
	 description: 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX',
	 price: 19310.00,
	 catalog_id: ObjectId("60f7235e31961b195057956f"),
	 created_at: '2021-07-07 19:06:41',
	 updated_at: '2021-07-07 19:06:41'
	},
	{name: 'Gigabyte H310M S2H',
	 description: 'Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX',
	 price: 4790.00,
	 catalog_id: ObjectId("60f7235e31961b195057956f"),
	 created_at: '2021-07-07 19:06:41',
	 updated_at: '2021-07-07 19:06:41'
	},
	{name: 'MSI B250M GAMING PRO',
	 description: 'Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX',
	 price: 5060.00,
	 catalog_id: ObjectId("60f7235e31961b195057956f"),
	 created_at: '2021-07-07 19:06:41',
	 updated_at: '2021-07-07 19:06:41'
	}
])

> db.products.find()
{ "_id" : ObjectId("60f72d0831961b1950579573"), "name" : "Intel Core i3-8100", "description" : "Процессор для настольных персональных компьютеров, основанных на платформе Intel.", "price" : 7890, "catalog_id" : ObjectId("60f7235e31961b195057956e"), "created_at" : "2021-07-07 19:06:41", "updated_at" : "2021-07-07 19:06:41" }
{ "_id" : ObjectId("60f72d0831961b1950579574"), "name" : "Intel Core i5-7400", "description" : "Процессор для настольных персональных компьютеров, основанных на платформе Intel.", "price" : 12700, "catalog_id" : ObjectId("60f7235e31961b195057956e"), "created_at" : "2021-07-07 19:06:41", "updated_at" : "2021-07-07 19:06:41" }
{ "_id" : ObjectId("60f72d0831961b1950579575"), "name" : "AMD FX-8320E", "description" : "Процессор для настольных персональных компьютеров, основанных на платформе AMD.", "price" : 4780, "catalog_id" : ObjectId("60f7235e31961b195057956e"), "created_at" : "2021-07-07 19:06:41", "updated_at" : "2021-07-07 19:06:41" }
{ "_id" : ObjectId("60f72d0831961b1950579576"), "name" : "AMD FX-8320", "description" : "Процессор для настольных персональных компьютеров, основанных на платформе AMD.", "price" : 7120, "catalog_id" : ObjectId("60f7235e31961b195057956e"), "created_at" : "2021-07-07 19:06:41", "updated_at" : "2021-07-07 19:06:41" }
{ "_id" : ObjectId("60f72d0831961b1950579577"), "name" : "ASUS ROG MAXIMUS X HERO", "description" : "Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX", "price" : 19310, "catalog_id" : ObjectId("60f7235e31961b195057956f"), "created_at" : "2021-07-07 19:06:41", "updated_at" : "2021-07-07 19:06:41" }
{ "_id" : ObjectId("60f72d0831961b1950579578"), "name" : "Gigabyte H310M S2H", "description" : "Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX", "price" : 4790, "catalog_id" : ObjectId("60f7235e31961b195057956f"), "created_at" : "2021-07-07 19:06:41", "updated_at" : "2021-07-07 19:06:41" }
{ "_id" : ObjectId("60f72d0831961b1950579579"), "name" : "MSI B250M GAMING PRO", "description" : "Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX", "price" : 5060, "catalog_id" : ObjectId("60f7235e31961b195057956f"), "created_at" : "2021-07-07 19:06:41", "updated_at" : "2021-07-07 19:06:41" }
>

> db.catalogs.find({name: 'Процессоры'},{'catalog_id':1})
{ "_id" : ObjectId("60f7235e31961b195057956e") }

> db.products.find({catalog_id:ObjectId("60f7235e31961b195057956e")})
{ "_id" : ObjectId("60f72d0831961b1950579573"), "name" : "Intel Core i3-8100", "description" : "Процессор для настольных персональных компьютеров, основанных на платформе Intel.", "price" : 7890, "catalog_id" : ObjectId("60f7235e31961b195057956e"), "created_at" : "2021-07-07 19:06:41", "updated_at" : "2021-07-07 19:06:41" }
{ "_id" : ObjectId("60f72d0831961b1950579574"), "name" : "Intel Core i5-7400", "description" : "Процессор для настольных персональных компьютеров, основанных на платформе Intel.", "price" : 12700, "catalog_id" : ObjectId("60f7235e31961b195057956e"), "created_at" : "2021-07-07 19:06:41", "updated_at" : "2021-07-07 19:06:41" }
{ "_id" : ObjectId("60f72d0831961b1950579575"), "name" : "AMD FX-8320E", "description" : "Процессор для настольных персональных компьютеров, основанных на платформе AMD.", "price" : 4780, "catalog_id" : ObjectId("60f7235e31961b195057956e"), "created_at" : "2021-07-07 19:06:41", "updated_at" : "2021-07-07 19:06:41" }
{ "_id" : ObjectId("60f72d0831961b1950579576"), "name" : "AMD FX-8320", "description" : "Процессор для настольных персональных компьютеров, основанных на платформе AMD.", "price" : 7120, "catalog_id" : ObjectId("60f7235e31961b195057956e"), "created_at" : "2021-07-07 19:06:41", "updated_at" : "2021-07-07 19:06:41" }

