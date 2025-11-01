#!/bin/bash
# Утилиты

# Проверка зависимости
is_package_installed() {
    dpkg -l "$1" &>/dev/null
}

# Генерация .env
generate_env_file() {
    local config="$1"
    local env_file="$2"
    if [[ ! -f "$config" ]]; then
        error "Конфиг $config не найден."
        return 1
    fi

    # Читаем IP
    local ip=$(hostname -I | awk '{print $1}')
    echo "SERVER_IP=$ip" > "$env_file"

    # Запрашиваем пароль
    echo "Введите пароль по умолчанию для сервисов:"
    read -s pwd
    echo "DEFAULT_PASSWORD=$pwd" >> "$env_file"

    success "✅ .env обновлён"
}
