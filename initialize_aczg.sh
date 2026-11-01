#!/bin/bash

PROJECT_PATH=$1
PROJECT_NAME=$2

if [ ! -d "$PROJECT_PATH" ]; then
    echo "O caminho '$PROJECT_PATH' não existe. Criando diretório..."
    mkdir -p "$PROJECT_PATH"
fi
cd "$PROJECT_PATH"
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"
touch README.md
echo "projeto $PROJECT_NAME inicilizando...." >> README.md
if ! command -v git &> /dev/null; then
    echo "Git não encontrado. Inicializando instalação."

    sudo apt update
    sudo apt install -y git

    if ! command -v git &> /dev/null; then
        echo "Erro: não foi possível instalar o Git."
        exit 1
    fi
fi

git init
git add README.md
git commit -m "first commit - repositório configurado"



