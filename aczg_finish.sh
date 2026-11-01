#!/bin/bash

if ! command -v git &> /dev/null; then
    echo "Git não encontrado. Inicializando instalação."

    sudo apt update
    sudo apt install -y git

    if ! command -v git &> /dev/null; then
        echo "Erro: não foi possível instalar o Git."
        exit 1
    fi
fi

BRANCH_FEATURE=$(git branch --show-current)

git checkout master || git checkout main
git merge "$BRANCH_FEATURE"
git branch -d "$BRANCH_FEATURE"
git push -d origin "$BRANCH_FEATURE"
