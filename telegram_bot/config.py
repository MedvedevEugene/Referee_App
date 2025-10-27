"""
Конфигурация бота
"""

import os
from dotenv import load_dotenv

# Загрузка переменных окружения
load_dotenv()

# Токен бота
TOKEN = os.getenv('TELEGRAM_BOT_TOKEN')

# Прокси (если нужен для обхода блокировки Telegram)
# Формат: socks5://user:pass@host:port или http://host:port
PROXY_URL = os.getenv('PROXY_URL', None)

# Пути к ресурсам
ASSETS_PATH = '../assets'
JSON_PATH = os.path.join(ASSETS_PATH, 'json')
PDF_PATH = os.path.join(ASSETS_PATH, 'pdf')
RULES_PATH = os.path.join(ASSETS_PATH, 'rules')

# Настройки бота
MAX_QUESTIONS_PER_TEST = 10
PASSING_SCORE = 70  # процент правильных ответов для прохождения

