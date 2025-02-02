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

# Вызов функции анимации
animate_loading
echo ""

# Функция для установки ноды
install_node() {
    echo -e "${BLUE}Начинаем установку ноды...${NC}"

    # Обновление и установка зависимостей
    install_dependencies

    # Создание директории для кэша и переход в неё
    mkdir -p ~/pipe/download_cache
    cd ~/pipe

    # Скачиваем файл pop
    wget https://dl.pipecdn.app/v0.2.0/pop

    # Делаем файл исполнимым
    chmod +x pop

    # Создание новой сессии в screen
    screen -S pipe2 -dm

    # Запуск файла в screen с нужными параметрами
    echo -e "${YELLOW}Введите ваш публичный адрес Solana:${NC}"
    read SOLANA_PUB_KEY

    # Запуск команды с параметрами, с указанием публичного ключа Solana
    screen -S pipe2 -X stuff "./pop --ram 8 --max-disk 500 --cache-dir ~/pipe/download_cache --pubKey $SOLANA_PUB_KEY\n"

    echo -e "${GREEN}Процесс установки и запуска завершён!${NC}"
    echo -e "${GREEN}Для выхода из сессии screen нажмите 'Ctrl + A' затем 'D'.${NC}"
}

# Функция для проверки статуса ноды
check_status() {
    echo -e "${BLUE}Проверка статуса ноды...${NC}"
    
    screen -x pipe2
    
    ./pop --status

    echo -e "${GREEN}ДЛЯ ЗАПУСКА СКРИПТА НАЖМИТЕ CTRL + A+ D И ВВЕДИТЕ ./pipe.sh${NC}"
}

# Функция для проверки поинтов ноды
check_points() {
    echo -e "${BLUE}Проверка поинтов ноды...${NC}"
    
    screen -x pipe2
    
    ./pop --points-route

    echo -e "${GREEN}ДЛЯ ЗАПУСКА СКРИПТА НАЖМИТЕ CTRL + A+ D И ВВЕДИТЕ ./pipe.sh${NC}"
}

# Функция для удаления ноды
remove_node() {
    echo -e "${BLUE}Удаляем ноду...${NC}"

    # Остановка процесса
    pkill -f pop

    # Удаление файлов ноды
    sudo rm -rf ~/pipe

    echo -e "${GREEN}Нода успешно удалена!${NC}"
}

# Основное меню
CHOICE=$(whiptail --title "Меню действий" \
    --menu "Выберите действие:" 15 50 6 \
    "1" "Установка ноды" \
    "2" "Проверка статуса ноды" \
    "3" "Проверка поинтов ноды" \
    "4" "Удаление ноды" \
    "5" "Выход" \
    3>&1 1>&2 2>&3)

case $CHOICE in
    1) 
        install_node
        ;;
    2) 
        check_status
        ;;
    3) 
        check_points
        ;;
    4) 
        remove_node
        ;;
    5)
        echo -e "${CYAN}Выход из программы.${NC}"
        ;;
    *)
        echo -e "${RED}Неверный выбор. Завершение программы.${NC}"
        ;;
esac
