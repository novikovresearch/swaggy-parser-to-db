# Telegram Data Analysis Project

## Описание
Проект по сбору и анализу данных из Telegram-каналов и чатов.
Подготовлен командой полной свэга SWAG. Худ. рук. - Новиков А.К. Артисты - Крюков А.А., Жыргалбек Ж.

## Используемые технологии
- Python (Telethon)
- PostgreSQL
- SQL

## Функциональность
- сбор данных (посты, комментарии, реакции)
- сохранение в CSV
- загрузка в PostgreSQL
- аналитические SQL-запросы

## Структура БД
- tg_users
- tg_chats
- tg_posts
- tg_comments
- tg_reactions

## Запуск проекта

1. Установить зависимости:
pip install -r requirements.txt
2. Указать свои данные:
- API_ID
- API_HASH
- DB_PASSWORD
3. Запустить:
python telegram_parser.py
