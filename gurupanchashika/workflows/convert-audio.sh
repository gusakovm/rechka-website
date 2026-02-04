#!/bin/bash

# Скрипт конвертации аудио файлов OGG -> MP3 для веб-совместимости
# Использует ffmpeg для конвертации с хорошим качеством

set -e

# Цвета для вывода
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🎵 Конвертация аудио файлов OGG → MP3${NC}"
echo ""

# Проверка наличия ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo -e "${RED}❌ Ошибка: ffmpeg не установлен${NC}"
    echo ""
    echo "Установите ffmpeg:"
    echo "  macOS:   brew install ffmpeg"
    echo "  Ubuntu:  sudo apt install ffmpeg"
    echo "  Windows: скачайте с https://ffmpeg.org/download.html"
    exit 1
fi

# Получаем путь к корневой директории проекта (два уровня вверх от workflows)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Директории для исходных и конвертированных файлов
INPUT_DIR="${PROJECT_ROOT}/audio-source"
OUTPUT_DIR="${PROJECT_ROOT}/audio-mp3"

# Создаем директории если их нет
mkdir -p "$INPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Проверяем наличие OGG файлов
shopt -s nullglob  # Чтобы пустой glob не возвращал сам паттерн
OGG_FILES=("$INPUT_DIR"/*.ogg)
shopt -u nullglob

if [ ${#OGG_FILES[@]} -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Нет OGG файлов в директории: $INPUT_DIR${NC}"
    echo ""
    echo "Поместите ваши .ogg файлы в директорию:"
    echo "  $INPUT_DIR"
    echo ""
    exit 0
fi

# Счетчик обработанных файлов
CONVERTED=0
SKIPPED=0
TOTAL=0

echo -e "${BLUE}📊 Анализ файлов...${NC}"
echo ""

# Конвертация всех OGG файлов
for input_file in "${OGG_FILES[@]}"; do
    filename=$(basename "$input_file" .ogg)
    output_file="$OUTPUT_DIR/${filename}.mp3"
    TOTAL=$((TOTAL + 1))

    # Проверяем, существует ли уже MP3 файл с таким же именем
    if [ -f "$output_file" ]; then
        echo -e "${YELLOW}⏭️  Пропуск: ${filename}.ogg → ${filename}.mp3 (уже существует)${NC}"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    echo -e "${BLUE}🔄 Конвертация: ${filename}.ogg → ${filename}.mp3${NC}"

    # Конвертация для речи/аудиокниг (96 kbps - отличное качество, малый размер)
    # Для музыки замените на: -q:a 2 (VBR ~190 kbps)
    ffmpeg -i "$input_file" \
        -codec:a libmp3lame \
        -b:a 96k \
        -loglevel error \
        "$output_file"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Готово: ${filename}.mp3${NC}"
        CONVERTED=$((CONVERTED + 1))
    else
        echo -e "${RED}❌ Ошибка при конвертации: ${filename}.ogg${NC}"
    fi
    echo ""
done

# Итоговая статистика
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Конвертация завершена!${NC}"
echo ""
echo -e "   Всего файлов:      ${TOTAL}"
echo -e "   Сконвертировано:   ${CONVERTED}"
echo -e "   Пропущено:         ${SKIPPED} (уже существуют)"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "📂 Исходные OGG:         ${INPUT_DIR}"
echo -e "📂 Конвертированные MP3: ${OUTPUT_DIR}"
