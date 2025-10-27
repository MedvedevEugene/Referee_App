#!/usr/bin/env python3
import asyncio
from telegram import Bot
from config import TOKEN

async def test():
    bot = Bot(token=TOKEN)
    try:
        me = await bot.get_me()
        print(f"✅ Подключение успешно!")
        print(f"Бот: @{me.username}")
        print(f"ID: {me.id}")
        print(f"Имя: {me.first_name}")
    except Exception as e:
        print(f"❌ Ошибка: {e}")
    finally:
        await bot.shutdown()

if __name__ == '__main__':
    asyncio.run(test())

