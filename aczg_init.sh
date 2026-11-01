#!/bin/bash

NEW_FEAT=$1

if [ -z "$NEW_FEAT" ]; then
    echo "Erro: informe o nome da feature. Uso: aczginit <nomeFeature>"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo "Git não encontrado. Inicializando instalação."

    sudo apt update
    sudo apt install -y git

    if ! command -v git &> /dev/null; then
        echo "Erro: não foi possível instalar o Git."
        exit 1
    fi
fi

git status 
git switch -c "feat-$NEW_FEAT"
git branch -a
