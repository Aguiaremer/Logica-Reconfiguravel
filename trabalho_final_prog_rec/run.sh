#!/bin/bash

# Sair imediatamente se algum comando falhar
set -e

echo "=== Configurando o Ambiente Python (Linux/macOS) ==="

# 1. Verifica se o Python 3 está instalado
if ! command -v python3 &> /dev/null; then
    echo "Erro: Python 3 não foi encontrado no sistema."
    exit 1
fi

# 2. Cria o ambiente virtual (.venv) se ele não existir
if [ ! -d ".venv" ]; then
    echo "Criando ambiente virtual (.venv)..."
    python3 -m venv .venv
else
    echo "Ambiente virtual (.venv) já existe."
fi

# 3. Ativa o ambiente virtual
echo "Ativando o ambiente virtual..."
source .venv/bin/activate

# 4. Atualiza o pip e instala os requisitos
echo "Instalando/Atualizando dependências..."
python -m pip install --upgrade pip
if [ -f "requirements.txt" ]; then
    python -m pip install -r requirements.txt
else
    echo "Aviso: requirements.txt não encontrado. Tentando instalar dependências manualmente..."
    python -m pip install customtkinter pygame
fi

# 5. Executa o app
echo "Iniciando a aplicação..."
python app.py
