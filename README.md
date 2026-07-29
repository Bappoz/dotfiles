# dotfiles

Configs do meu [Omarchy](https://omarchy.org/) (Hyprland) + terminal e ferramentas de linha de comando. Gerenciado com [GNU Stow](https://www.gnu.org/software/stow/).

## Conteúdo

| Pacote | O que é |
|---|---|
| `hypr` | Hyprland — binds, monitors, looknfeel, idle, lock, autostart |
| `omarchy` | Hooks, branding e templates customizados (o tema ativo em si é gerenciado pelo Omarchy, não versionado aqui — veja abaixo) |
| `waybar` | Barra de status |
| `walker` | Launcher de apps |
| `swayosd` | OSD de volume/brilho |
| `kitty` | Terminal |
| `tmux` | Multiplexador de terminal |
| `btop` | Monitor de sistema |
| `fastfetch` | System info fetcher |
| `git` | Aliases e config globais do git (usa `gh auth git-credential` como credential helper — nenhum token fica em disco) + `template/hooks/pre-commit` com varredura de segredo via `gitleaks` |
| `starship` | Prompt |
| `zsh` / `bash` | Shell rc files |
| `aider` | Config global do [aider](https://aider.chat) — auto-commit por mudança, lint automático |
| `nvim` | Submodule apontando para [Bappoz/.config](https://github.com/Bappoz/.config) (repo próprio do neovim) |

**Não incluído de propósito:** histórico de shell, chaves SSH/GPG, tokens, `~/.config/omarchy/current/` (é um cache regenerado pelo `omarchy theme set`, não uma customização), e qualquer app com estado/cache pesado (navegadores, Discord, Obsidian, etc). Nada neste repo contém segredo, token ou credencial — todo o histórico foi revisado antes do primeiro commit.

## Instalação em máquina nova

```bash
git clone https://github.com/Bappoz/dotfiles.git ~/Work/dotfiles
cd ~/Work/dotfiles
./install.sh              # symlinks de tudo
./install.sh kitty tmux   # ou só pacotes específicos
```

O script instala o `stow` se faltar (Arch/pacman), inicializa o submodule do nvim e cria os symlinks em `$HOME`. Se um arquivo já existir no destino, o `stow` recusa o link — faça backup do arquivo local e rode de novo.

## Ferramentas de linha de comando

As configs acima assumem um conjunto de ferramentas instalado. Em máquina nova:

```bash
sudo pacman -S --needed gitleaks atuin git-delta just ollama
yay -S --needed trufflehog lazysql greptile-cli
uv tool install aider-chat && uv tool install posting

./setup-tools.sh          # configura o que precisa dos binários presentes
```

`setup-tools.sh` é idempotente e só age no que encontra: aponta o git para o `delta`, ativa o `init.templateDir` do hook de segredo, importa o histórico do zsh para o `atuin` e reporta o que ficou faltando. Rodar de novo não duplica nada.

| Ferramenta | Para quê |
|---|---|
| `gitleaks` | Varredura de segredo no diff staged — roda como pre-commit em todo repo novo |
| `trufflehog` | Auditoria do histórico completo; valida se a credencial encontrada ainda está viva |
| `atuin` | Histórico de shell em SQLite, com busca e sync criptografado entre máquinas |
| `delta` | Paginador de diff do git com syntax highlighting e modo lado-a-lado |
| `just` | Task runner por projeto (`justfile`) |
| `aider` | Agente de código com auto-commit por mudança |
| `lazysql` | Cliente de banco em terminal |
| `posting` | Cliente de API em terminal; coleções em YAML versionável |
| `greptile` | Revisão de PR com o repositório inteiro como contexto (requer `greptile login`) |
| `ollama` | Servidor de modelo local — **esta máquina não tem GPU dedicada**, então só modelo pequeno é prático (ver abaixo) |

### Ollama sem GPU

O notebook é i7-1255U com Iris Xe integrada: inferência é CPU-only. `qwen2.5-coder:3b` (~2 GB) é o maior que roda em velocidade interativa; `:7b` funciona mas é lento. Serve para trabalho offline e teste de prompt, **não** para loop agêntico.

## Tema atual

Tema ativo: **Matte Black** (stock do Omarchy). Para restaurar:

```bash
omarchy theme set "Matte Black"
```

## Cursor customizado

O cursor "CursorNovo" referenciado em `hypr/.config/hypr/envs.conf` precisa estar instalado em `~/.local/share/icons/` (ou XDG equivalente) — não incluído aqui por ser um asset binário grande.
