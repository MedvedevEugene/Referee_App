"""
Обработчики команд и сообщений
"""

import json
import os
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import ContextTypes
from config import JSON_PATH


async def show_rules_list(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Показать список правил"""
    keyboard = []
    
    # Создаем кнопки для каждого правила (1-17)
    for i in range(1, 18):
        keyboard.append([
            InlineKeyboardButton(f"Правило {i}", callback_data=f"rule_{i}")
        ])
    
    reply_markup = InlineKeyboardMarkup(keyboard)
    await update.message.reply_text(
        "Выберите правило:",
        reply_markup=reply_markup
    )


async def show_rule(rule_number: int, update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Показать конкретное правило"""
    try:
        file_path = os.path.join(JSON_PATH, f"{rule_number}_football_rule.json")
        
        with open(file_path, 'r', encoding='utf-8') as f:
            rule_data = json.load(f)
        
        # Формируем сообщение с информацией о правиле
        message = f"📖 Правило {rule_number}\n\n"
        
        if isinstance(rule_data, list) and len(rule_data) > 0:
            first_item = rule_data[0]
            if 'title' in first_item:
                message += f"{first_item['title']}\n\n"
            if 'content' in first_item:
                message += first_item['content']
        
        await update.callback_query.answer()
        await update.callback_query.edit_message_text(message[:4000])  # Telegram limit
        
    except Exception as e:
        await update.callback_query.answer()
        await update.callback_query.edit_message_text(
            f"Ошибка при загрузке правила {rule_number}: {str(e)}"
        )


async def start_test(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Начать тестирование"""
    keyboard = [
        [InlineKeyboardButton("Быстрый тест (10 вопросов)", callback_data="test_quick")],
        [InlineKeyboardButton("Полный тест (все вопросы)", callback_data="test_full")],
        [InlineKeyboardButton("Тест по правилам", callback_data="test_rules")],
    ]
    
    reply_markup = InlineKeyboardMarkup(keyboard)
    await update.message.reply_text(
        "Выберите тип теста:",
        reply_markup=reply_markup
    )

