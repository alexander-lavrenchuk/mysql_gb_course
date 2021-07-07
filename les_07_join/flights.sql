CREATE DATABASE flights;
USE flights;

CREATE TABLE flights (id SERIAL PRIMARY KEY, `from` VARCHAR(255), `to` VARCHAR(255));
INSERT INTO flights SET `from` = 'moscow', `to` = 'omsk';
INSERT INTO flights SET `from` = 'novgorod', `to` = 'kazan';
INSERT INTO flights SET `from` = 'irkutsk', `to` = 'moscow';
INSERT INTO flights SET `from` = 'omsk', `to` = 'irkutsk';
INSERT INTO flights SET `from` = 'moscow', `to` = 'kazan';

CREATE TABLE cities (label VARCHAR(255), name VARCHAR(255));
INSERT INTO cities SET label = 'moscow', name = 'Москва';
INSERT INTO cities SET label = 'irkutsk', name = 'Иркутск';
INSERT INTO cities SET label = 'novgorod', name = 'Новгород';
INSERT INTO cities SET label = 'kazan', name = 'Казань';
INSERT INTO cities SET label = 'omsk', name = 'Омск';
