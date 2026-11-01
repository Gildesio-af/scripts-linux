#!/bin/bash

PROJECT_PATH=$(realpath "${1:-.}")
CRON_SCHEDULE=${2:-"59 23 * * *"}
LOG_FILE=${3:-"$PROJECT_PATH/ci_tests.log"}
COMMIT_RUNNER="$PROJECT_PATH/.ci_commit_runner.sh"

if ! command -v git &> /dev/null; then
    sudo apt update && sudo apt install -y git
fi

cat <<EOF > "$COMMIT_RUNNER"
#!/bin/bash
cd "$PROJECT_PATH" || exit 1

if [ -f "$PROJECT_PATH/.last_test_status" ] && [ "\$(cat "$PROJECT_PATH/.last_test_status")" != "PASS" ]; then
    echo "[CI-PIPELINE] \$(date): Commit diário cancelado pois os testes falharam!" >> "$LOG_FILE"
    exit 1
fi

if [ -n "\$(git status --porcelain)" ]; then
    git add .
    git commit -m "chore: automated daily commit - \$(date +'%Y-%m-%d %H:%M')"
    echo "[CI-PIPELINE] \$(date): Commit diário automático realizado com sucesso!" >> "$LOG_FILE"
else
    echo "[CI-PIPELINE] \$(date): Nenhuma alteração pendente para o commit diário." >> "$LOG_FILE"
fi
EOF

chmod +x "$COMMIT_RUNNER"

CRON_COMMAND="$CRON_SCHEDULE \"$COMMIT_RUNNER\""

crontab -l 2>/dev/null | grep -v -F "$COMMIT_RUNNER" | crontab -

(
    crontab -l 2>/dev/null
    echo "$CRON_COMMAND"
) | crontab -

echo "Cron de commit diário configurada com sucesso!"
echo "Projeto: $PROJECT_PATH"
echo "Agendamento: $CRON_SCHEDULE"
