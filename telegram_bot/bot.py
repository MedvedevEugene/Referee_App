#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Телеграмм бот для Referee App
"""

import logging
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import Application, CommandHandler, CallbackQueryHandler, ContextTypes
from telegram.request import HTTPXRequest
from config import TOKEN, PROXY_URL

# Настройка логирования
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)
logger = logging.getLogger(__name__)


async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Обработчик команды /start - главное меню"""
    try:
        keyboard = [
            [InlineKeyboardButton("📖 Правила футбола", callback_data="menu_rules")],
            [InlineKeyboardButton("📝 Тесты", callback_data="menu_tests")],
            [InlineKeyboardButton("🎥 Видео-тесты", callback_data="menu_video_tests")],
            [InlineKeyboardButton("🏃 Марафон", callback_data="menu_marathon")],
            [InlineKeyboardButton("⭐️ Избранное", callback_data="menu_favorites")],
            [InlineKeyboardButton("📊 История тестов", callback_data="menu_history")],
            [InlineKeyboardButton("ℹ️ Помощь", callback_data="menu_help")]
        ]
        reply_markup = InlineKeyboardMarkup(keyboard)
        
        message_text = (
            "⚽️ *Добро пожаловать в бота для подготовки футбольных судей!*\n\n"
            "Выберите раздел:"
        )
        
        if update.message:
            await update.message.reply_text(message_text, reply_markup=reply_markup, parse_mode='Markdown')
        elif update.callback_query:
            await update.callback_query.edit_message_text(message_text, reply_markup=reply_markup, parse_mode='Markdown')
            
        user = update.effective_user
        logger.info(f"Главное меню для пользователя {user.id}")
    except Exception as e:
        logger.error(f"Ошибка в start: {e}")


async def rules_menu(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Меню правил футбола"""
    keyboard = []
    
    # Добавляем правила 1-17
    for i in range(1, 18, 2):
        row = [InlineKeyboardButton(f"Правило {i}", callback_data=f"rule_{i}")]
        if i + 1 <= 17:
            row.append(InlineKeyboardButton(f"Правило {i+1}", callback_data=f"rule_{i+1}"))
        keyboard.append(row)
    
    keyboard.append([InlineKeyboardButton("🔙 Главное меню", callback_data="menu_main")])
    reply_markup = InlineKeyboardMarkup(keyboard)
    
    await update.callback_query.answer()
    await update.callback_query.edit_message_text(
        "📖 *Правила футбола (Laws of the Game)*\n\nВыберите правило:",
        reply_markup=reply_markup,
        parse_mode='Markdown'
    )


async def show_rule(update: Update, context: ContextTypes.DEFAULT_TYPE, rule_number: int) -> None:
    """Показать конкретное правило"""
    import json
    import os
    from config import JSON_PATH
    
    try:
        file_path = os.path.join(JSON_PATH, f"{rule_number}_football_rule.json")
        
        with open(file_path, 'r', encoding='utf-8') as f:
            rule_data = json.load(f)
        
        # Формируем текст правила
        if isinstance(rule_data, list) and len(rule_data) > 0:
            message = f"📖 *Правило {rule_number}*\n\n"
            
            # Берем первые несколько пунктов
            for idx, item in enumerate(rule_data[:5]):
                if 'title' in item:
                    message += f"*{item['title']}*\n"
                if 'content' in item:
                    content = item['content'][:300]  # Ограничение на длину
                    message += f"{content}...\n\n"
                    
                if len(message) > 3000:  # Telegram limit
                    break
        
        keyboard = [
            [InlineKeyboardButton("🔙 К списку правил", callback_data="menu_rules")],
            [InlineKeyboardButton("🏠 Главное меню", callback_data="menu_main")]
        ]
        reply_markup = InlineKeyboardMarkup(keyboard)
        
        await update.callback_query.answer()
        await update.callback_query.edit_message_text(
            message,
            reply_markup=reply_markup,
            parse_mode='Markdown'
        )
    except Exception as e:
        logger.error(f"Ошибка при загрузке правила {rule_number}: {e}")
        await update.callback_query.answer("Ошибка загрузки правила")


async def tests_menu(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Меню тестов"""
    keyboard = [
        [InlineKeyboardButton("📝 Быстрый тест (10 вопросов)", callback_data="test_quick")],
        [InlineKeyboardButton("📚 Тест по правилам", callback_data="test_chapters")],
        [InlineKeyboardButton("🎓 Экзамен (50 вопросов)", callback_data="test_exam")],
        [InlineKeyboardButton("🔙 Главное меню", callback_data="menu_main")]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    
    await update.callback_query.answer()
    await update.callback_query.edit_message_text(
        "📝 *Тесты*\n\nВыберите тип теста:",
        reply_markup=reply_markup,
        parse_mode='Markdown'
    )


async def video_tests_menu(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Меню видео-тестов"""
    keyboard = [
        [InlineKeyboardButton("🎥 Видео-тест 1", callback_data="vtest_1")],
        [InlineKeyboardButton("🎥 Видео-тест 2", callback_data="vtest_2")],
        [InlineKeyboardButton("🎥 Видео-тест 3", callback_data="vtest_3")],
        [InlineKeyboardButton("🔙 Главное меню", callback_data="menu_main")]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    
    await update.callback_query.answer()
    await update.callback_query.edit_message_text(
        "🎥 *Видео-тесты*\n\nВыберите видео-тест:",
        reply_markup=reply_markup,
        parse_mode='Markdown'
    )


async def marathon_menu(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Меню марафона"""
    keyboard = [
        [InlineKeyboardButton("🏃 Начать марафон", callback_data="marathon_start")],
        [InlineKeyboardButton("📊 Статистика марафона", callback_data="marathon_stats")],
        [InlineKeyboardButton("🔙 Главное меню", callback_data="menu_main")]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    
    await update.callback_query.answer()
    await update.callback_query.edit_message_text(
        "🏃 *Марафон*\n\nПройдите все вопросы подряд!\n\nКаждый день - 10 новых вопросов.",
        reply_markup=reply_markup,
        parse_mode='Markdown'
    )


async def favorites_menu(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Меню избранного"""
    keyboard = [
        [InlineKeyboardButton("⭐️ Избранные вопросы", callback_data="fav_questions")],
        [InlineKeyboardButton("📝 Тест из избранного", callback_data="fav_test")],
        [InlineKeyboardButton("🔙 Главное меню", callback_data="menu_main")]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    
    await update.callback_query.answer()
    await update.callback_query.edit_message_text(
        "⭐️ *Избранное*\n\nУправляйте избранными вопросами:",
        reply_markup=reply_markup,
        parse_mode='Markdown'
    )


async def history_menu(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Меню истории тестов"""
    keyboard = [
        [InlineKeyboardButton("📊 Моя статистика", callback_data="history_stats")],
        [InlineKeyboardButton("📜 История тестов", callback_data="history_list")],
        [InlineKeyboardButton("🔙 Главное меню", callback_data="menu_main")]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    
    await update.callback_query.answer()
    await update.callback_query.edit_message_text(
        "📊 *История тестов*\n\nПросмотрите свою статистику:",
        reply_markup=reply_markup,
        parse_mode='Markdown'
    )


async def help_menu(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Меню помощи"""
    help_text = """
ℹ️ *Помощь*

*Разделы бота:*

📖 *Правила футбола* - изучайте 17 правил IFAB
📝 *Тесты* - проверьте свои знания
🎥 *Видео-тесты* - анализ игровых ситуаций
🏃 *Марафон* - ежедневные вопросы
⭐️ *Избранное* - сохраняйте важные вопросы
📊 *История* - отслеживайте прогресс

*Команды:*
/start - главное меню
/help - эта справка
    """
    
    keyboard = [[InlineKeyboardButton("🔙 Главное меню", callback_data="menu_main")]]
    reply_markup = InlineKeyboardMarkup(keyboard)
    
    await update.callback_query.answer()
    await update.callback_query.edit_message_text(
        help_text,
        reply_markup=reply_markup,
        parse_mode='Markdown'
    )


async def button_handler(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Обработчик нажатий на кнопки"""
    query = update.callback_query
    
    try:
        # Маршрутизация по callback_data
        if query.data == "menu_main":
            await start(update, context)
        elif query.data == "menu_rules":
            await rules_menu(update, context)
        elif query.data.startswith("rule_"):
            rule_num = int(query.data.split("_")[1])
            await show_rule(update, context, rule_num)
        elif query.data == "menu_tests":
            await tests_menu(update, context)
        elif query.data == "menu_video_tests":
            await video_tests_menu(update, context)
        elif query.data == "menu_marathon":
            await marathon_menu(update, context)
        elif query.data == "menu_favorites":
            await favorites_menu(update, context)
        elif query.data == "menu_history":
            await history_menu(update, context)
        elif query.data == "menu_help":
            await help_menu(update, context)
        else:
            await query.answer("Функция в разработке 🚧")
    except Exception as e:
        logger.error(f"Ошибка в button_handler: {e}")
        await query.answer("Произошла ошибка")


async def error_handler(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Обработчик ошибок"""
    logger.error(f"Ошибка при обработке обновления: {context.error}")
    if update and update.effective_message:
        try:
            await update.effective_message.reply_text(
                "Извините, произошла ошибка. Попробуйте еще раз."
            )
        except:
            pass


def main() -> None:
    """Запуск бота"""
    if not TOKEN:
        logger.error("TOKEN не установлен в config.py")
        return

    # Создание приложения с прокси (если указан)
    builder = Application.builder().token(TOKEN)
    
    if PROXY_URL:
        logger.info(f"Использование прокси: {PROXY_URL}")
        request = HTTPXRequest(proxy=PROXY_URL, connection_pool_size=8, read_timeout=120, write_timeout=120, connect_timeout=120, pool_timeout=120)
        builder = builder.request(request)
    else:
        # Увеличенные таймауты для стабильной работы
        request = HTTPXRequest(connection_pool_size=8, read_timeout=120, write_timeout=120, connect_timeout=120, pool_timeout=120)
        builder = builder.request(request)
    
    application = builder.build()

    # Регистрация обработчиков
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("help", start))
    application.add_handler(CallbackQueryHandler(button_handler))
    
    # Регистрация обработчика ошибок
    application.add_error_handler(error_handler)

    # Запуск бота
    logger.info("Бот запущен")
    application.run_polling(drop_pending_updates=True)


if __name__ == '__main__':
    main()
