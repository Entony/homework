#!/bin/bash

LOG_FILE="/var/log/backup.log"
DATE=$(date +"%Y-%m-%d %H:%M:%S")

rsync -av --delete "/home/karpov/" "/tmp/backup" >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
    echo "$DATE - Бэкап успешен" >> "$LOG_FILE"
else
    echo "$DATE - Бэкап завершен с ошибкой $?" >> "$LOG_FILE"
fi
