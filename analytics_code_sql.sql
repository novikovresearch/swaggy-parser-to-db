-- ИНДЕКСЫ

CREATE INDEX IF NOT EXISTS idx_tg_posts_author_id
ON tg_posts(author_id);

CREATE INDEX IF NOT EXISTS idx_tg_posts_chat_id
ON tg_posts(chat_id);

CREATE INDEX IF NOT EXISTS idx_tg_comments_author_id
ON tg_comments(author_id);

CREATE INDEX IF NOT EXISTS idx_tg_reactions_reaction
ON tg_reactions(reaction);

-- ФУНКЦИЯ 1. Количество постов по названию канала/чата

CREATE OR REPLACE FUNCTION get_posts_count_by_chat(p_chat_title TEXT)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    result_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO result_count
    FROM tg_posts p
    JOIN tg_chats c ON p.chat_id = c.chat_id
    WHERE c.title = p_chat_title;

    RETURN COALESCE(result_count, 0);
END;
$$;

-- ФУНКЦИЯ 2. Среднее число комментариев на пост по названию канала/чата

CREATE OR REPLACE FUNCTION get_avg_comments_per_post_by_chat(p_chat_title TEXT)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    result_avg NUMERIC;
BEGIN
    SELECT ROUND(AVG(comment_per_post::NUMERIC), 2)
    INTO result_avg
    FROM (
        SELECT p.post_id, COUNT(cm.comment_id) AS comment_per_post
        FROM tg_posts p
        JOIN tg_chats c ON p.chat_id = c.chat_id
        LEFT JOIN tg_comments cm ON cm.post_id = p.post_id
        WHERE c.title = p_chat_title
        GROUP BY p.post_id
    ) sub;

    RETURN COALESCE(result_avg, 0);
END;
$$;

-- Функция 3. Общее число реакций по конкретному посту

CREATE OR REPLACE FUNCTION get_total_reactions_for_post(p_post_id INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    result_sum INTEGER;
BEGIN
    SELECT SUM(reaction_count)
    INTO result_sum
    FROM tg_reactions
    WHERE post_id = p_post_id
      AND entity_type = 'post';

    RETURN COALESCE(result_sum, 0);
END;
$$;

-- ОПЕРАЦИИ С БАЗОЙ ДАННЫХ
-- Операция 1. Количество постов по чатам и каналам
SELECT c.title, COUNT(*) AS posts_count
FROM tg_posts p
JOIN tg_chats c ON p.chat_id = c.chat_id
GROUP BY c.title
ORDER BY posts_count DESC;
-- Операция 2. Количество комментариев по чатам и каналам
SELECT c.title, COUNT(cm.comment_id) AS comments_count
FROM tg_comments cm
JOIN tg_posts p ON cm.post_id = p.post_id
JOIN tg_chats c ON p.chat_id = c.chat_id
GROUP BY c.title
ORDER BY comments_count DESC;
-- Операция 3. Топ-10 постов по числу реакций
SELECT
    c.title,
    p.post_id,
    p.tg_message_id,
    p.reaction_count,
    LEFT(p.text, 150) AS post_preview
FROM tg_posts p
JOIN tg_chats c ON p.chat_id = c.chat_id
ORDER BY p.reaction_count DESC
LIMIT 10;
-- Операция 4. Топ пользователей по числу комментариев
SELECT
    u.display_name,
    u.username,
    COUNT(*) AS comments_count
FROM tg_comments cm
JOIN tg_users u ON cm.author_id = u.user_id
GROUP BY u.display_name, u.username
ORDER BY comments_count DESC
LIMIT 10;
-- Операция 5. Самые популярные реакции
SELECT reaction, SUM(reaction_count) AS total_reactions
FROM tg_reactions
GROUP BY reaction
ORDER BY total_reactions DESC;

-- АНАЛИЗ ДАННЫХ ПРОЕКТА
-- 1. Анализ активности источников
SELECT c.title, COUNT(*) AS posts_count
FROM tg_posts p
JOIN tg_chats c ON p.chat_id = c.chat_id
GROUP BY c.title
ORDER BY posts_count DESC;
-- 2. Анализ вовлеченности аудитории по комментариям
SELECT c.title, COUNT(cm.comment_id) AS comments_count
FROM tg_comments cm
JOIN tg_posts p ON cm.post_id = p.post_id
JOIN tg_chats c ON p.chat_id = c.chat_id
GROUP BY c.title
ORDER BY comments_count DESC;
-- 3. Анализ вовлеченности аудитории по реакциям
SELECT reaction, SUM(reaction_count) AS total_reactions
FROM tg_reactions
GROUP BY reaction
ORDER BY total_reactions DESC;
-- 4. Выявление популярных постов
SELECT
    c.title,
    p.post_id,
    p.tg_message_id,
    p.reaction_count,
    LEFT(p.text, 150) AS post_preview
FROM tg_posts p
JOIN tg_chats c ON p.chat_id = c.chat_id
ORDER BY p.reaction_count DESC
LIMIT 10;
-- 5. Определение количества реакций по посту
SELECT get_total_reactions_for_post(1);
-- 6. Определение количества комментариев в сообществе
SELECT get_avg_comments_per_post_by_chat('Moloday | Активное долголетие');
