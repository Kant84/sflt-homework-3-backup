#!/bin/bash
# Скрипт зеркального резервного копирования домашней директории
# Задание 2: Резервное копирование с помощью rsync и cron

SOURCE="/home/andrei/"
DEST="/tmp/backup/"
LOG_TAG="backup-home"

# Создаём директорию назначения, если её нет
mkdir -p "$DEST"

# Выполняем rsync
# -a: архивный режим
# -v: подробный вывод
# --delete: зеркальная копия (удалять лишнее)
# --checksum: проверять хэш-суммы
# --exclude='.*/': исключить скрытые директории
# --exclude='Загрузки/': исключить загрузки (большие файлы)
if rsync -av --delete --checksum --exclude='.*/' --exclude='Загрузки/' "$SOURCE" "$DEST" >> /var/log/backup-home.log 2>&1; then
    logger -t "$LOG_TAG" "SUCCESS: Backup completed successfully. Source: $SOURCE -> Dest: $DEST"
    echo "$(date): Backup SUCCESS" >> /var/log/backup-home.log
else
    logger -t "$LOG_TAG" "ERROR: Backup failed! Source: $SOURCE -> Dest: $DEST"
    echo "$(date): Backup FAILED" >> /var/log/backup-home.log
    exit 1
fi
