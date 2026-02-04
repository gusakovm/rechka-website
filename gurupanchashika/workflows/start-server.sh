#!/bin/bash

# Получаем путь к корню проекта rechka-website (два уровня вверх от workflows)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

echo "🚀 Запуск локального сервера для всего проекта"
echo "📂 Корневая директория: rechka-website"
echo ""
echo "🌐 Доступные URL:"
echo "   http://localhost:8000/"
echo "   http://localhost:8000/gurupanchashika/"
echo "   http://localhost:8000/gurupanchashika/index.html"
echo ""
echo "Нажмите Ctrl+C для остановки"
echo ""

# Переходим в корень проекта и запускаем сервер
cd "$PROJECT_ROOT" && python3 -m http.server 8000
