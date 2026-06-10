#!/bin/bash
# Скрипт восстановления из резервной копии
# Задание 4*

BACKUP_DIR="/home/andrei/backups"
RESTORE_DIR="/home/andrei/restored"

echo "=== Доступные резервные копии ==="
BACKUPS=$(ls -1 ${BACKUP_DIR} | grep backup_ | sort)
if [ -z "$BACKUPS" ]; then
    echo "Нет доступных резервных копий!"
    exit 1
fi

echo "$BACKUPS"
echo ""

echo -n "Введите имя резервной копии для восстановления: "
read SELECTED_BACKUP

if [ ! -d "${BACKUP_DIR}/${SELECTED_BACKUP}" ]; then
    echo "Ошибка: резервная копия ${SELECTED_BACKUP} не найдена!"
    exit 1
fi

echo "Восстановление из ${SELECTED_BACKUP} в ${RESTORE_DIR}..."
mkdir -p ${RESTORE_DIR}

rsync -av --delete "${BACKUP_DIR}/${SELECTED_BACKUP}/" "${RESTORE_DIR}/"

if [ $? -eq 0 ]; then
    echo "=== Восстановление завершено успешно! ==="
    echo "Данные восстановлены в: ${RESTORE_DIR}"
    echo "Содержимое:"
    ls -la ${RESTORE_DIR}
else
    echo "=== Ошибка при восстановлении! ==="
    exit 1
fi
