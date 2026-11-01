#!/bin/bash

SCRIPT_SOURCE_DIR=$(dirname "$(realpath "$0")")
INSTALL_DIR="$HOME/.local/bin/aczg"
ALIASES_FILE="$HOME/.bash_aliases"
BASHRC_FILE="$HOME/.bashrc"

echo "=== Iniciando configuração do ambiente ACZG ==="

for pkg in git:git notify-send:libnotify-bin crontab:cron; do
    cmd="${pkg%%:*}"
    apt_pkg="${pkg##*:}"
    if ! command -v "$cmd" &> /dev/null; then
        sudo apt update && sudo apt install -y "$apt_pkg"
    fi
done

mkdir -p "$INSTALL_DIR"

SCRIPTS=("initialize_aczg.sh" "aczg_init.sh" "aczg_finish.sh" "ci_cron.sh" "commit_cron.sh" "get_logs.sh")

for script in "${SCRIPTS[@]}"; do
    if [ -f "$SCRIPT_SOURCE_DIR/$script" ]; then
        cp "$SCRIPT_SOURCE_DIR/$script" "$INSTALL_DIR/$script"
        chmod +x "$INSTALL_DIR/$script"
        echo "Instalado: $INSTALL_DIR/$script"
    fi
done

touch "$ALIASES_FILE"
sed -i '/# === ACZG ALIASES ===/,/# === END ACZG ===/d' "$ALIASES_FILE"

cat << EOF >> "$ALIASES_FILE"
alias init_aczg='$INSTALL_DIR/initialize_aczg.sh'
alias aczginit='$INSTALL_DIR/aczg_init.sh'
alias aczgfinish='$INSTALL_DIR/aczg_finish.sh'
alias aczgci='$INSTALL_DIR/ci_cron.sh'
alias aczgcommit='$INSTALL_DIR/commit_cron.sh'
alias aczglogs='$INSTALL_DIR/get_logs.sh'
EOF

if ! grep -q ".bash_aliases" "$BASHRC_FILE" 2>/dev/null; then
    echo "[ -f ~/.bash_aliases ] && . ~/.bash_aliases" >> "$BASHRC_FILE"
fi

if [ -n "$1" ] && [ -d "$1" ]; then
    "$INSTALL_DIR/ci_cron.sh" "$1"
    "$INSTALL_DIR/commit_cron.sh" "$1"
fi

echo "=== Ambiente configurado com sucesso! ==="
echo "Execute 'source ~/.bashrc' para carregar os aliases na sessão atual."
