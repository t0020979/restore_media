#!/bin/bash
# ~/cherdak_tv/0.sh — единая точка входа

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/tools/colors.sh"
source "$ROOT_DIR/tools/dialog.sh"
source "$ROOT_DIR/tools/utils.sh"

# === Обнаружение модулей ===
discover_modules() {
    local modules=()
    for mod in [0-9][0-9]_*; do
        if [[ -d "$mod" && -f "$mod/module.conf" ]]; then
            modules+=("$mod")
        fi
    done
    echo "${modules[@]}"
}

# === Загрузка метаданных модуля ===
load_module_config() {
    local mod="$1"
    local conf="$mod/module.conf"
    if [[ ! -f "$conf" ]]; then
        echo "error: $mod/module.conf не найден" >&2
        return 1
    fi

    # Читаем параметры
    name=$(grep "^name=" "$conf" | cut -d'=' -f2)
    icon=$(grep "^icon=" "$conf" | cut -d'=' -f2)
    short_status=$(grep "^short_status=" "$conf" | cut -d'=' -f2)
    manage=$(grep "^manage=" "$conf" | cut -d'=' -f2)
    install=$(grep "^install=" "$conf" | cut -d'=' -f2)
    default=$(grep "^default=" "$conf" | cut -d'=' -f2)
    config=$(grep "^config=" "$conf" | cut -d'=' -f2)
}

# === Главный экран ===
show_overview() {
    echo -e "${BOLD}🏠 Чердак-ТВ: управление${NC}"
    echo "=================================================="
    local modules=($(discover_modules))
    local i=1
    for mod in "${modules[@]}"; do
        load_module_config "$mod"
        echo -n "$i) $icon $name "
        if [[ -n "$short_status" && -f "$short_status" ]]; then
            "$ROOT_DIR/$short_status"
        else
            echo "(нет state_short.sh)"
        fi
        ((i++))
    done
    echo ""
    echo "u) 🔧 Системное обслуживание (apt, Ubuntu Pro)"
    echo "r) 🔄 Пересоздать .env"
    echo "i) 📦 Установить ВСЁ по умолчанию"
    echo "q) ❌ Выход"
    echo "=================================================="
}

# === Системное обслуживание ===
system_maintenance() {
    echo "1) apt update   2) apt upgrade   3) apt autoremove   4) Ubuntu Pro   q) Назад"
    read -rp "Выбор: " c
    case "$c" in
        1) sudo apt update ;;
        2) sudo apt upgrade ;;
        3) sudo apt autoremove ;;
        4) sudo pro attach || echo "Ubuntu Pro: уже активирован или требуется токен" ;;
        q|Q) return ;;
        *) echo "Неверный выбор."; sleep 1 ;;
    esac
}

# === Генерация .env ===
generate_env() {
    local ip=$(hostname -I | awk '{print $1}')
    echo "SERVER_IP=$ip" > .env
    echo "Введите пароль по умолчанию для сервисов:"
    read -s pwd
    echo "DEFAULT_PASSWORD=$pwd" >> .env
    echo "✅ .env обновлён"
    sleep 1
}

# === Главный цикл ===
main() {
    while true; do
        clear
        show_overview
        read -rp "Ваш выбор: " choice

        local modules=($(discover_modules))
        case "$choice" in
            [1-${#modules[@]}])
                mod="${modules[$((choice-1))]}"
                load_module_config "$mod"
                if [[ -n "$manage" && -f "$manage" ]]; then
                    "$ROOT_DIR/$manage"
                else
                    echo "⚠️ Нет manage.sh в $mod"
                    sleep 1
                fi
                ;;
            u|U) system_maintenance ;;
            r|R) generate_env ;;
            i|I)
                for mod in "${modules[@]}"; do
                    load_module_config "$mod"
                    if [[ -n "$default" && -f "$default" ]]; then
                        "$ROOT_DIR/$default"
                    fi
                done
                echo "✅ Все модули настроены по умолчанию."
                sleep 2
                ;;
            q|Q) echo "Выход."; exit 0 ;;
            *) echo "Неверный выбор."; sleep 1 ;;
        esac
    done
}

main
