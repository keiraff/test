#!/bin/bash

# Проверка наличия необходимых утилит, установка если отсутствуют
if ! command -v figlet &> /dev/null; then
    echo "figlet не найден. Устанавливаем..."
    sudo apt update && sudo apt install -y figlet
fi

if ! command -v whiptail &> /dev/null; then
    echo "whiptail не найден. Устанавливаем..."
    sudo apt update && sudo apt install -y whiptail
fi

# Определяем цвета для удобства
YELLOW="\e[33m"
CYAN="\e[36m"
BLUE="\e[34m"
GREEN="\e[32m"
RED="\e[31m"
PINK="\e[35m"
NC="\e[0m"

install_dependencies() {
    echo -e "${GREEN}Устанавливаем необходимые пакеты...${NC}"
    sudo apt update && sudo apt install -y curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip screen
}

# Вывод приветственного текста с помощью figlet
echo -e "${PINK}$(figlet -w 150 -f standard "Softs by Gentleman")${NC}"
echo -e "${PINK}$(figlet -w 150 -f standard "x WESNA")${NC}"

echo "===================================================================================================================================="
echo "Добро пожаловать! Начинаем установку необходимых библиотек, пока подпишись на наши Telegram-каналы для обновлений и поддержки: "
echo ""
echo "Gentleman - https://t.me/GentleChron"
echo "Wesna - https://t.me/softs_by_wesna"
echo "===================================================================================================================================="

echo ""

# Определение функции анимации
animate_loading() {
    for ((i = 1; i <= 5; i++)); do
        printf "\r${GREEN}Подгружаем меню${NC}."
        sleep 0.3
        printf "\r${GREEN}Подгружаем меню${NC}.."
        sleep 0.3
        printf "\r${GREEN}Подгружаем меню${NC}..."
        sleep 0.3
        printf "\r${GREEN}Подгружаем меню${NC}"
        sleep 0.3
    done
    echo ""
}

# Функция для установки ноды
install_node() {
    echo -e "${BLUE}Начинаем установку ноды...${NC}"

    # Обновление и установка зависимостей
    install_dependencies

    # Создание директории для кэша и переход в неё
    mkdir -p ~/pipe/download_cache
    cd ~/pipe

    # Скачиваем файл pop
    wget https://dl.pipecdn.app/v0.2.2/pop

    # Делаем файл исполнимым
    chmod +x pop

    # Создание новой сессии в screen
    screen -S pipe2 -dm

    # Запуск файла в screen с нужными параметрами
    echo -e "${YELLOW}Введите ваш публичный адрес Solana:${NC}"
    read SOLANA_PUB_KEY

    # Регистрация и ввод реферального кода
    echo -e "${YELLOW}Введите реферальный код: 1111${NC}"

    # Запуск команды с параметрами, с указанием публичного ключа Solana
    screen -S pipe2 -X stuff "./pop --ram 8 --max-disk 500 --cache-dir ~/pipe/download_cache --pubKey $SOLANA_PUB_KEY\n"

    echo -e "${GREEN}Процесс установки и запуска завершён!${NC}"
    echo -e "${GREEN}Для выхода из сессии screen нажмите 'Ctrl + A' затем 'D'.${NC}"
}

# Функция для получения статуса ноды
get_status() {
    STATUS=$(screen -S pipe2 -X stuff "./pop --status\n")
    echo "$STATUS"
}

# Функция для получения поинтов ноды
get_points() {
    POINTS=$(screen -S pipe2 -X stuff "./pop --points-route\n")
    echo "$POINTS"
}

# Функция для удаления ноды
remove_node() {
    echo -e "${BLUE}Удаляем ноду...${NC}"

    pkill -f pop

    # Завершаем сеанс screen с именем 'pipe2' и удаляем его
    screen -S pipe2 -X quit

    # Удаление файлов ноды
    sudo rm -rf ~/pipe

    echo -e "${GREEN}Нода успешно удалена!${NC}"
}

# Основное меню
while true; do
    STATUS=$(get_status)
    POINTS=$(get_points)

    CHOICE=$(whiptail --title "Меню действий" \
        --menu "Выберите действие:" 15 50 6 \
        "1" "Установка ноды" \
        "2" "Проверка статуса ноды: $STATUS" \
        "3" "Проверка поинтов ноды: $POINTS" \
        "4" "Удаление ноды" \
        "5" "Выход" \
        3>&1 1>&2 2>&3)

    case $CHOICE in
        1) 
            install_node
            ;;
        2) 
            echo -e "${BLUE}Статус ноды:${NC} $STATUS"
            ;;
        3) 
            echo -e "${BLUE}Поинты ноды:${NC} $POINTS"
            ;;
        4) 
            remove_node
            ;;
        5)
            echo -e "${CYAN}Выход из программы.${NC}"
            break
            ;;
        *)
            echo -e "${RED}Неверный выбор. Завершение программы.${NC}"
            break
            ;;
    esac
done
