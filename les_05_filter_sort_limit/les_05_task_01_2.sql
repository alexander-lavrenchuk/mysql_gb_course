#
# 1.Подсчитайте средний возраст пользователей в таблице users.
#
SELECT AVG(TIMESTAMPDIFF(YEAR, birthday_at, NOW())) FROM users;

#
# 2. Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. Следует учесть, что необходимы дни недели текущего года, а не года рождения.
#
SELECT DAYOFWEEK(STR_TO_DATE(CONCAT('2021-', MONTH(birthday_at),'-', DAY(birthday_at)), '%Y-%m-%d')) AS day_of_week, COUNT(*) AS birthdays_num FROM users GROUP BY day_of_week ORDER BY day_of_week;

#
# 3. (по желанию) Подсчитайте произведение чисел в столбце таблицы.
#
SELECT EXP(SUM(LN(value))) FROM tbl;

