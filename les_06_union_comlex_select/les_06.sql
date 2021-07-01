/*
1. Проанализировать запросы, которые выполнялись на занятии, определить возможные корректировки и/или улучшения (JOIN пока не применять).
*/
/* Ввести переменную для пользователя, чтобы в запросах использовать не константу, а переменную, что позволит не изменять запрос при необходимость его выполнения для другого пользователя.
Тогда запрос к 8-му заданию можно записать в следующем виде: */

SET @user := 1;

SELECT from_user_id, to_user_id, txt, (from_user_id = @user) FROM messages WHERE (from_user_id = @user OR to_user_id = @user) AND is_delivered  = false ORDER BY (from_user_id = @user), created_at DESC;

/*
2. Пусть задан некоторый пользователь.
Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.
*/
SELECT CONCAT(firstname, ' ', lastname)
FROM users
WHERE id = (
  SELECT IF(from_user_id = @user, to_user_id, from_user_id) AS friend
  FROM messages
  WHERE is_delivered
  AND from_user_id != to_user_id
  AND (
    from_user_id = @user
    AND to_user_id IN (
      SELECT DISTINCT IF(from_user_id = @user, to_user_id, from_user_id)
      FROM friend_requests 
      WHERE request_type = (
        SELECT id
	FROM friend_requests_types
	WHERE name = 'accepted')
        AND (from_user_id = @user OR to_user_id = @user))
    OR to_user_id = @user
    AND from_user_id IN (
      SELECT DISTINCT IF(from_user_id = @user, to_user_id, from_user_id)
      FROM friend_requests
      WHERE request_type = (
	SELECT id 
	FROM friend_requests_types 
	WHERE name = 'accepted') 
        AND (from_user_id = @user OR to_user_id = @user))) 
  GROUP BY friend
  ORDER BY count(*) DESC
  LIMIT 1);

/*
3. Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.
*/
-- Этот запрос не срабатывает, т.к. в версии 8.0.25 ещё не поддерживатся LIMIT во вложенном запросе
SELECT COUNT(*) FROM posts_likes WHERE user_id IN (SELECT user_id FROM posts_likes GROUP BY user_id ORDER BY (SELECT TIMESTAMPDIFF(YEAR, birthday, NOW()) FROM profiles WHERE user_id = posts_likes.user_id) LIMIT 10);

-- Решил задание через построение временной таблицы с id выбранных 10 самых молодых пользователей, которые получали лайки.




CREATE TABLE youngest_users (user_id BIGINT NOT NULL);
INSERT INTO youngest_users (user_id) SELECT user_id FROM posts WHERE id IN (SELECT post_id FROM posts_likes) GROUP BY posts.user_id ORDER BY (SELECT TIMESTAMPDIFF(YEAR, birthday, NOW()) FROM profiles WHERE user_id = posts.user_id) LIMIT 10;

CREATE TABLE posts_likes_users (post_id BIGINT, user_id BIGINT);
INSERT INTO posts_likes_users SELECT post_id, (SELECT user_id FROM posts WHERE id = posts_likes.post_id) user FROM posts_likes;

SELECT COUNT(*) FROM posts_likes_users WHERE user_id IN (SELECT user_id FROM youngest_users);

DROP TABLE youngest_users;
DROP TABLE posts_likes_users;

/*
4. Определить кто больше поставил лайков (всего) - мужчины или женщины?
*/
SELECT COUNT(*) AS cnt, (SELECT gender FROM profiles WHERE user_id = (SELECT user_id FROM posts WHERE id = posts_likes.post_id)) AS gender FROM posts_likes GROUP
BY gender HAVING gender IN('m', 'f') ORDER BY cnt DESC LIMIT 1;

/*
5. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.
*/
--Реализовал решение через построение временной таблицы, в которую заносится информация о количестве активностей пользователей
CREATE TABLE users_actions (user_id BIGINT, actions_count BIGINT);
INSERT INTO users_actions (user_id, actions_count) SELECT from_user_id, COUNT(*) FROM friend_requests GROUP BY from_user_id UNION SELECT from_user_id, COUNT(*) FROM messages GROUP BY from_user_id UNION SELECT user_id, COUNT(*) FROM posts GROUP BY user_id UNION SELECT user_id, COUNT(*) FROM posts_likes GROUP BY user_id;
SELECT (SELECT CONCAT(firstname, ' ', lastname) FROM users WHERE id = user_id) as fullname, SUM(actions_count) AS act_cnt FROM users_actions GROUP BY user_id ORDE
R BY act_cnt LIMIT 10;
DROP TABLE users_actions;

