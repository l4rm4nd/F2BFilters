#!/bin/bash
# Version 1.0
# Send Fail2ban notifications using a Telegram Bot

# Telegram BOT Token 
telegramBotToken='<BOT-TOKEN>'
# Telegram Chat ID
telegramChatID='<CHAT-ID>'

function talkToBot() {
    message=$1
    curl -s -X POST https://api.telegram.org/bot${telegramBotToken}/sendMessage -d text="${message}" -d chat_id=${telegramChatID} > /dev/null 2>&1
}
if [ $# -eq 0 ]; then
    echo "Usage $0 -a ( start || stop ) || -b $IP || -u $IP || -r $REASON"
    exit 1;
fi
while getopts "a:b:u:r:" opt; do
    case "$opt" in
        a)
            action=$OPTARG
        ;;
        b)
            ban=y
            ip_add_ban=$OPTARG
        ;;
        u)
            unban=y
            ip_add_unban=$OPTARG
        ;;
        r)
            reason=$OPTARG
        ;;
        ?) 
            echo "Invalid option. -$OPTARG"
            exit 1
        ;;
    esac
done
if [[ ! -z ${action} ]]; then
    case "${action}" in
        start)
            talkToBot "Fail2ban has been started"
        ;;
        stop)
            talkToBot "Fail2ban has been stopped"
        ;;
        *)
            echo "Incorrect option"
            exit 1;
        ;;
    esac
elif [[ ${ban} == "y" ]]; then
    talkToBot "The IP ${ip_add_ban} has been banned due to ${reason}. https://ipinfo.io/${ip_add_ban}"
    exit 0;
elif [[ ${unban} == "y" ]]; then
    talkToBot "The IP: ${ip_add_unban} has been unbanned."
    exit 0;
else
    info
fi
