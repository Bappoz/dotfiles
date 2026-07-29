#!/usr/bin/env bash
# Configura as ferramentas depois de instaladas. Idempotente — pode rodar quantas vezes quiser.
# Pacotes: sudo pacman -S --needed gitleaks atuin git-delta just ollama
#          yay -S --needed trufflehog lazysql greptile-cli
#          uv tool install aider-chat && uv tool install posting
set -uo pipefail

ok()   { printf '\033[32m  ok\033[0m   %s\n' "$1"; }
skip() { printf '\033[90m  --\033[0m   %s\n' "$1"; }
warn() { printf '\033[33m  !!\033[0m   %s\n' "$1"; }

have() { command -v "$1" >/dev/null 2>&1; }

echo
echo "── delta ────────────────────────────────────────────"
if have delta; then
  # Só escreve se ainda não estiver configurado, pra não duplicar entrada.
  if [ "$(git config --global --get core.pager)" = "delta" ]; then
    skip "já configurado no gitconfig"
  else
    git config --global core.pager delta
    git config --global interactive.diffFilter 'delta --color-only'
    git config --global delta.navigate true       # n / N salta entre arquivos do diff
    git config --global delta.line-numbers true
    git config --global delta.side-by-side true
    git config --global delta.hyperlinks true
    git config --global merge.conflictstyle zdiff3  # marcador de conflito mais informativo
    ok "gitconfig apontando para delta (lado-a-lado, numeração, navegação)"
  fi
else
  warn "delta ausente — pulei. sudo pacman -S git-delta"
fi

echo
echo "── atuin ────────────────────────────────────────────"
if have atuin; then
  if grep -q 'atuin init zsh' "$HOME/.zshrc" 2>/dev/null; then
    ok "init já presente no .zshrc"
  else
    warn ".zshrc sem o init do atuin — adicione: eval \"\$(atuin init zsh --disable-up-arrow)\""
  fi
  # Importa o histórico existente do zsh uma única vez.
  if [ -f "$HOME/.atuin-imported" ]; then
    skip "histórico já importado"
  else
    atuin import zsh >/dev/null 2>&1 && touch "$HOME/.atuin-imported" \
      && ok "histórico do zsh importado ($(atuin history list 2>/dev/null | wc -l) entradas)" \
      || warn "import falhou — rode manualmente: atuin import zsh"
  fi
  echo "       sync entre máquinas (opcional, e2e): atuin register -u <user> -e <email>"
  echo "       depois, no outro notebook:            atuin login -u <user> && atuin sync"
else
  warn "atuin ausente — pulei. sudo pacman -S atuin"
fi

echo
echo "── gitleaks ─────────────────────────────────────────"
if have gitleaks; then
  git config --global init.templateDir "$HOME/.config/git/template"
  ok "init.templateDir ativo — repo novo já nasce com o pre-commit"
  if [ -x "$HOME/.config/git/template/hooks/pre-commit" ]; then
    ok "hook presente e executável"
  else
    warn "hook faltando em ~/.config/git/template/hooks/pre-commit"
  fi
  echo "       instalar em repo JÁ existente:  git init   (reaplica o template, não destrói nada)"
else
  warn "gitleaks ausente — pulei. sudo pacman -S gitleaks"
fi

echo
echo "── ollama ───────────────────────────────────────────"
if have ollama; then
  if systemctl is-active --quiet ollama 2>/dev/null; then
    ok "serviço ativo"
  else
    warn "serviço parado — habilite: sudo systemctl enable --now ollama"
  fi
  echo "       máquina sem GPU dedicada: use modelo pequeno."
  echo "       ollama pull qwen2.5-coder:3b   # ~2 GB, interativo de verdade"
  echo "       ollama pull qwen2.5-coder:7b   # ~4.7 GB, melhor qualidade, mais lento"
else
  warn "ollama ausente — pulei. sudo pacman -S ollama"
fi

echo
echo "── resto ────────────────────────────────────────────"
for t in just lazysql posting aider trufflehog greptile; do
  have "$t" && ok "$t $("$t" --version 2>/dev/null | head -1 | cut -c1-40)" || warn "$t ausente"
done
have greptile && echo "       greptile precisa de login do usuário: greptile login"

echo
echo "── MCP ──────────────────────────────────────────────"
if have claude; then
  claude mcp list 2>/dev/null | grep -q context7 && ok "context7 configurado" \
    || warn "context7 ausente: claude mcp add --transport http --scope user context7 https://mcp.context7.com/mcp"
fi

echo
echo "Vibe Kanban não precisa instalação: npx vibe-kanban  (abre UI local)"
echo
