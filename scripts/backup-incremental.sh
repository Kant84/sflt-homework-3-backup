#!/bin/bash
# Инкрементное резервное копирование с хранением 5 последних копий
# Задание 4*

SOURCE="/home/andrei/"
REMOTE_USER="andrei"
REMOTE_HOST="192.168.101.50"
REMOTE_DIR="/home/andrei/backups"
MAX_BACKUPS=5
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="backup_${DATE}"
LOG_TAG="backup-incremental"

# Создаём директорию для текущего бэкапа на удалённом сервере
ssh ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${REMOTE_DIR}/${BACKUP_NAME}"

# Инкрементный бэкап через rsync (с hard links для экономии места)
PREVIOUS_BACKUP=$(ssh ${REMOTE_USER}@${REMOTE_HOST} "ls -1 ${REMOTE_DIR} | grep backup_ | sort | tail -1")

if [ -n "$PREVIOUS_BACKUP" ] && [ "$PREVIOUS_BACKUP" != "$BACKUP_NAME" ]; then
    rsync -av --delete --checksum --exclude='.*/' --exclude='Загрузки/' \
        --link-dest="${REMOTE_DIR}/${PREVIOUS_BACKUP}" \
        "${SOURCE}" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/${BACKUP_NAME}/"
else
    rsync -av --delete --checksum --exclude='.*/' --exclude='Загрузки/' \
        "${SOURCE}" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/${BACKUP_NAME}/"
fi

if [ $? -eq 0 ]; then
    logger -t "$LOG_TAG" "SUCCESS: Incremental backup completed: ${BACKUP_NAME}"
    echo "$(date): Backup ${BACKUP_NAME} SUCCESS"
else
    logger -t "$LOG_TAG" "ERROR: Incremental backup failed: ${BACKUP_NAME}"
    echo "$(date): Backup ${BACKUP_NAME} FAILED"
    exit 1
fi

# Удаляем старые бэкапы (оставляем только MAX_BACKUPS последних)
OLD_BACKUPS=$(ssh ${REMOTE_USER}@${REMOTE_HOST} "ls -1 ${REMOTE_DIR} | grep backup_ | sort -r | tail -n +$((${MAX_BACKUPS}+1))")
if [ -n "$OLD_BACKUPS" ]; then
    for old in $OLD_BACKUPS; do
        ssh ${REMOTE_USER}@${REMOTE_HOST} "rm -rf ${REMOTE_DIR}/${old}"
        logger -t "$LOG_TAG" "Removed old backup: ${old}"
    done
fi
