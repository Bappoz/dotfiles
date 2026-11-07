#!/usr/bin/env bash
# Instala os dotfiles na máquina atual via GNU Stow (symlinks).
# Uso: ./install.sh [pacote1 pacote2 ...]   (sem args = instala tudo)
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

PACKAGES=(alacritty foot ghostty uwsm fontconfig environment.d desktop-scripts hypr omarchy hyprmoncfg kitty tmux btop fastfetch git starship zsh bash aider nvim)

if ! command -v stow >/dev/null 2>&1; then
  echo "GNU Stow não encontrado. Instalando..."
  if command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed stow
  else
    echo "Instale o 'stow' manualmente e rode este script de novo." >&2
    exit 1
  fi
fi

echo "Inicializando submodules (nvim)..."
git submodule update --init --recursive

TARGETS=("$@")
[ ${#TARGETS[@]} -eq 0 ] && TARGETS=("${PACKAGES[@]}")

for pkg in "${TARGETS[@]}"; do
  if [ ! -d "$pkg" ]; then
    echo "Pacote desconhecido: $pkg" >&2
    continue
  fi
  echo "==> stow $pkg"
  stow --no-folding -v -t "$HOME" "$pkg"
done

echo
echo "Pronto. Se algum symlink foi rejeitado por conflito com um arquivo já existente,"
echo "faça backup do arquivo original e rode 'stow -v -t \$HOME <pacote>' de novo."
