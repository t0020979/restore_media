#!/bin/bash
# Диалоговые функции

info() { echo -e "\033[0;36mℹ️  $1\033[0m"; }
success() { echo -e "\033[0;32m✅ $1\033[0m"; }
warning() { echo -e "\033[0;33m⚠️  $1\033[0m"; }
error() { echo -e "\033[0;31m❌ $1\033[0m"; }

pause() {
    read -n1 -s -p "Нажмите любую клавишу..."
    echo
}
