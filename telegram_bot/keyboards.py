"""
Клавиатуры для бота
"""

from telegram import InlineKeyboardButton, InlineKeyboardMarkup


def main_menu_keyboard():
    """Главное меню"""
    keyboard = [
        [InlineKeyboardButton("📖 Правила футбола", callback_data="menu_rules")],
        [InlineKeyboardButton("📝 Тесты", callback_data="menu_tests")],
        [InlineKeyboardButton("🎥 Видео-тесты", callback_data="menu_video_tests")],
        [InlineKeyboardButton("🏃 Марафон", callback_data="menu_marathon")],
        [InlineKeyboardButton("⭐️ Избранное", callback_data="menu_favorites")],
        [InlineKeyboardButton("📊 История тестов", callback_data="menu_history")],
        [InlineKeyboardButton("ℹ️ Помощь", callback_data="menu_help")]
    ]
    return InlineKeyboardMarkup(keyboard)


def rules_keyboard():
    """Клавиатура выбора правил"""
    keyboard = []
    
    for i in range(1, 18, 2):
        row = [InlineKeyboardButton(f"Правило {i}", callback_data=f"rule_{i}")]
        if i + 1 <= 17:
            row.append(InlineKeyboardButton(f"Правило {i+1}", callback_data=f"rule_{i+1}"))
        keyboard.append(row)
    
    keyboard.append([InlineKeyboardButton("🔙 Главное меню", callback_data="menu_main")])
    return InlineKeyboardMarkup(keyboard)


def back_to_rules_keyboard():
    """Кнопка возврата к правилам"""
    keyboard = [
        [InlineKeyboardButton("🔙 К списку правил", callback_data="menu_rules")],
        [InlineKeyboardButton("🏠 Главное меню", callback_data="menu_main")]
    ]
    return InlineKeyboardMarkup(keyboard)


def back_to_main_keyboard():
    """Кнопка возврата в главное меню"""
    keyboard = [[InlineKeyboardButton("🔙 Главное меню", callback_data="menu_main")]]
    return InlineKeyboardMarkup(keyboard)


def tests_keyboard():
    """Клавиатура тестов"""
    keyboard = [
        [InlineKeyboardButton("📝 Быстрый тест (10 вопросов)", callback_data="test_quick")],
        [InlineKeyboardButton("📚 Тест по правилам", callback_data="test_chapters")],
        [InlineKeyboardButton("🎓 Экзамен (50 вопросов)", callback_data="test_exam")],
        [InlineKeyboardButton("🔙 Главное меню", callback_data="menu_main")]
    ]
    return InlineKeyboardMarkup(keyboard)


def chapters_test_keyboard():
    """Клавиатура выбора правила для теста"""
    keyboard = []
    
    for i in range(1, 18, 3):
        row = []
        for j in range(3):
            if i + j <= 17:
                row.append(InlineKeyboardButton(f"Правило {i+j}", callback_data=f"test_chapter_{i+j}"))
        keyboard.append(row)
    
    keyboard.append([InlineKeyboardButton("🔙 К тестам", callback_data="menu_tests")])
    return InlineKeyboardMarkup(keyboard)


def video_tests_keyboard():
    """Клавиатура видео-тестов"""
    keyboard = [
        [InlineKeyboardButton("🎥 Видео-тест 1", callback_data="vtest_1")],
        [InlineKeyboardButton("🎥 Видео-тест 2", callback_data="vtest_2")],
        [InlineKeyboardButton("🎥 Видео-тест 3", callback_data="vtest_3")],
        [InlineKeyboardButton("🔙 Главное меню", callback_data="menu_main")]
    ]
    return InlineKeyboardMarkup(keyboard)


def marathon_keyboard():
    """Клавиатура марафона"""
    keyboard = [
        [InlineKeyboardButton("🏃 Начать марафон", callback_data="marathon_start")],
        [InlineKeyboardButton("📊 Статистика марафона", callback_data="marathon_stats")],
        [InlineKeyboardButton("🔙 Главное меню", callback_data="menu_main")]
    ]
    return InlineKeyboardMarkup(keyboard)


def favorites_keyboard():
    """Клавиатура избранного"""
    keyboard = [
        [InlineKeyboardButton("⭐️ Избранные вопросы", callback_data="fav_questions")],
        [InlineKeyboardButton("📝 Тест из избранного", callback_data="fav_test")],
        [InlineKeyboardButton("🔙 Главное меню", callback_data="menu_main")]
    ]
    return InlineKeyboardMarkup(keyboard)


def history_keyboard():
    """Клавиатура истории"""
    keyboard = [
        [InlineKeyboardButton("📊 Моя статистика", callback_data="history_stats")],
        [InlineKeyboardButton("📜 История тестов", callback_data="history_list")],
        [InlineKeyboardButton("🔙 Главное меню", callback_data="menu_main")]
    ]
    return InlineKeyboardMarkup(keyboard)

