"""
Вспомогательные функции
"""

import json
import os
import random
from typing import List, Dict, Any
from config import JSON_PATH


def load_json_file(filename: str) -> Any:
    """Загрузить JSON файл"""
    try:
        file_path = os.path.join(JSON_PATH, filename)
        with open(file_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"Ошибка загрузки {filename}: {e}")
        return None


def load_test_questions() -> List[Dict]:
    """Загрузить вопросы для теста"""
    tests_data = load_json_file('tests.json')
    if tests_data and isinstance(tests_data, list):
        return tests_data
    return []


def load_exam_questions() -> List[Dict]:
    """Загрузить вопросы для экзамена"""
    exam_data = load_json_file('exam.json')
    if exam_data and isinstance(exam_data, list):
        return exam_data
    return []


def get_random_questions(questions: List[Dict], count: int) -> List[Dict]:
    """Получить случайные вопросы"""
    if len(questions) <= count:
        return questions
    return random.sample(questions, count)


def calculate_score(correct_answers: int, total_questions: int) -> float:
    """Рассчитать процент правильных ответов"""
    if total_questions == 0:
        return 0.0
    return (correct_answers / total_questions) * 100


def format_score_message(correct: int, total: int) -> str:
    """Форматировать сообщение с результатами"""
    score = calculate_score(correct, total)
    
    if score >= 90:
        emoji = "🏆"
        message = "Отлично!"
    elif score >= 70:
        emoji = "👍"
        message = "Хорошо!"
    elif score >= 50:
        emoji = "📚"
        message = "Неплохо, но можно лучше"
    else:
        emoji = "📖"
        message = "Нужно больше практики"
    
    return f"{emoji} {message}\n\nПравильных ответов: {correct}/{total} ({score:.1f}%)"

