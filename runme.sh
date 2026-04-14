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

