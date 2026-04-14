#!/bin/bash

REPORT="result.txt"

echo -n > "$REPORT"

echo "Информация о среде запуска" | tee -a "$REPORT"


echo " - ОС: " | tee -a "$REPORT"
uname -a | tee -a "$REPORT"
if command -v lsb_release >/dev/null 2>&1; then
    lsb_release -a 2>/dev/null | tee -a "$REPORT"
fi
echo | tee -a "$REPORT"

echo " - ФС: " | tee -a "$REPORT"
df -Th $(pwd) | tee -a "$REPORT"
echo | tee -a "$REPORT"

echo "- Виртуализация: " | tee -a "$REPORT"
if command -v systemd-detect-virt >/dev/null 2>&1; then
    systemd-detect-virt | tee -a "$REPORT"
else
    echo "Не удалось определить (systemd-detect-virt отсутствует)" | tee -a "$REPORT"
fi
echo | tee -a "$REPORT"


rm -f A B C D A.gz B.gz

make clean && make build

if [ $? -ne 0 ]; then
    echo "Ошибка сборки программы" | tee -a "$REPORT"
    exit 1
fi
echo "Сборка завершена успешно." | tee -a "$REPORT"
echo >> "$REPORT"

echo "Создание файла A." | tee -a "$REPORT"
echo "> ./create_A.sh"
./create_A.sh
echo >> "$REPORT"

echo "Сжатие файлов A и B gzip'ом." | tee -a "$REPORT"
echo "> gzip -k A B" >> "$REPORT"
gzip -k A B
echo >> "$REPORT"

echo "Тест 1: Копирование A -> B (sparse)" | tee -a "$REPORT"
echo "Ожидаемый результат: B - разреженный файл, занимающий меньше места на диске." | tee -a "$REPORT"
echo "> ./sparcify A B" >> "$REPORT"
./sparcify A B

stat A | head -n 2 | tee -a "$REPORT"
stat B | head -n 2 | tee -a "$REPORT"

md5sum A B | tee -a "$REPORT"

echo >> "$REPORT"

echo "Тест 2: Распаковка B.gz и разрежение" | tee -a "$REPORT"
echo "Ожидаемый результат: C логически идентичен A и также разрежен." | tee -a "$REPORT"
echo "> gzip -cd B.gz | ./sparcify C" >> "$REPORT"
gzip -cd B.gz | ./sparcify C

stat C | head -n 2 | tee -a "$REPORT"

md5sum C | tee -a "$REPORT"

echo >> "$REPORT"

echo "Тест 3: Копирование A -> D с размером блока 100 байт" | tee -a "$REPORT"
echo "Ожидаемый результат: D - разреженный файл, но эффективность хранения может быть ниже." | tee -a "$REPORT"
echo "> ./sparcify -b 100 A D" >> "$REPORT"
./sparcify -b 100 A D

stat D | head -n 2 | tee -a "$REPORT"

md5sum D | tee -a "$REPORT"

echo >> "$REPORT"
