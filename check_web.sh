#!/bin/bash

if ! nc -z -w 2 127.0.0.1 80; then
    exit 1
fi

if [ ! -f "/usr/share/nginx/html/index.html" ]; then
    exit 1
fi

exit 0