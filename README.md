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
| `git` | Aliases e config globais do git (usa `gh auth git-credential` como credential helper — nenhum token fica em disco) |
| `starship` | Prompt |
| `zsh` / `bash` | Shell rc files |
| `nvim` | Submodule apontando para [Bappoz/.config](https://github.com/Bappoz/.config) (repo próprio do neovim) |

**Não incluído de propósito:** histórico de shell, chaves SSH/GPG, tokens, `~/.config/omarchy/current/` (é um cache regenerado pelo `omarchy theme set`, não uma customização), e qualquer app com estado/cache pesado (navegadores, Discord, Obsidian, etc). Nada neste repo contém segredo, token ou credencial — todo o histórico foi revisado antes do primeiro commit.

## Instalação em máquina nova

```bash
git clone https://github.com/Bappoz/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh              # instala tudo
./install.sh kitty tmux   # ou só pacotes específicos
```

O script instala o `stow` se faltar (Arch/pacman), inicializa o submodule do nvim e cria os symlinks em `$HOME`. Se um arquivo já existir no destino, o `stow` recusa o link — faça backup do arquivo local e rode de novo.

## Tema atual

Tema ativo: **Matte Black** (stock do Omarchy). Para restaurar:

```bash
omarchy theme set "Matte Black"
```

## Cursor customizado

O cursor "CursorNovo" referenciado em `hypr/.config/hypr/envs.conf` precisa estar instalado em `~/.local/share/icons/` (ou XDG equivalente) — não incluído aqui por ser um asset binário grande.
