#!/bin/bash

PROJECT_PATH=$(realpath "${1:-.}")
CRON_SCHEDULE=${2:-"*/15 * * * *"}
LOG_FILE=${3:-"$PROJECT_PATH/ci_tests.log"}
RUNNER_SCRIPT="$PROJECT_PATH/.ci_test_runner.sh"

if ! command -v notify-send &> /dev/null; then
    echo "notify-send não encontrado. Instalando libnotify-bin..."
    sudo apt update
    sudo apt install -y libnotify-bin
fi

cat <<EOF > "$RUNNER_SCRIPT"
#!/bin/bash
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/\$(id -u)/bus

source "\$HOME/.sdkman/bin/sdkman-init.sh" 2>/dev/null

cd "$PROJECT_PATH" || exit 1

if (./gradlew test || gradle test) >> "$LOG_FILE" 2>&1; then
    echo "[CI-PIPELINE] \$(date): Testes passaram!" >> "$LOG_FILE"
    echo "PASS" > "$PROJECT_PATH/.last_test_status"
    notify-send "CI ACZG" "Testes passaram!"
else
    echo "[CI-PIPELINE] \$(date): Testes falharam!" >> "$LOG_FILE"
    echo "FAIL" > "$PROJECT_PATH/.last_test_status"
    notify-send -u critical "CI ACZG" "Testes falharam!"
fi
EOF

chmod +x "$RUNNER_SCRIPT"

CRON_COMMAND="$CRON_SCHEDULE \"$RUNNER_SCRIPT\""

crontab -l 2>/dev/null | grep -v -F "$RUNNER_SCRIPT" | crontab -

(
    crontab -l 2>/dev/null
    echo "$CRON_COMMAND"
) | crontab -

echo "Cron de testes configurada com sucesso!"
echo "Projeto: $PROJECT_PATH"
echo "Agendamento: $CRON_SCHEDULE"
echo "Log: $LOG_FILE"

