#!/bin/bash

PROJECT_PATH=$(realpath "${1:-.}")
LOG_FILE=${2:-"$PROJECT_PATH/ci_tests.log"}

if [ ! -f "$LOG_FILE" ]; then
    echo "Erro: Arquivo de log não encontrado em '$LOG_FILE'."
    exit 1
fi

echo "=== Logs demarcados do pipeline CI ($PROJECT_PATH) ==="
grep --color=always -E "\[CI-PIPELINE\]|Testes (passaram|falharam)!" "$LOG_FILE"
