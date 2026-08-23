# dotfiles

Configs do meu [Omarchy](https://omarchy.org/) (Hyprland) + terminal e ferramentas de linha de comando. Gerenciado com [GNU Stow](https://www.gnu.org/software/stow/).

**Omarchy 4.0 "Quattro"** substituiu waybar/walker/swayosd/mako por um shell integrado (`omarchy-shell`, QML) com sistema de plugins próprio. Este repo foi atualizado para refletir isso — veja a seção de plugins abaixo.

## Conteúdo

| Pacote | O que é |
|---|---|
| `hypr` | Hyprland — binds, monitors, looknfeel, idle, lock, autostart. Inclui `*.lua` soltos (`bindings.lua`, `hyprland.lua` etc.) que espelham o novo formato stock do Quattro mas **não estão em uso** — `hyprland.conf` ainda é o entrypoint real, os `.lua` ficaram de um experimento não finalizado |
| `omarchy` | Hooks, branding, templates de tema e config do `omarchy-shell` (`shell.toml`/`shell.json`) — o tema ativo em si é gerenciado pelo Omarchy, não versionado aqui. Inclui também `plugins/bappoz.workspaces`, plugin próprio do bar (ver abaixo) |
| `hyprmoncfg` | Perfil de monitores do plugin `crmne.hyprmoncfg` (`profile-home.*`) — específico desta máquina |
| `kitty` | Terminal |
| `tmux` | Multiplexador de terminal |
| `btop` | Monitor de sistema |
| `fastfetch` | System info fetcher |
| `git` | Aliases e config globais do git (usa `gh auth git-credential` como credential helper — nenhum token fica em disco) + `template/hooks/pre-commit` com varredura de segredo via `gitleaks` |
| `starship` | Prompt |
| `zsh` / `bash` | Shell rc files |
| `aider` | Config global do [aider](https://aider.chat) — auto-commit por mudança, lint automático |
| `nvim` | Submodule apontando para [Bappoz/.config](https://github.com/Bappoz/.config) (repo próprio do neovim) |

**Não incluído de propósito:** histórico de shell, chaves SSH/GPG, tokens, `~/.config/omarchy/current/` (cache regenerado pelo `omarchy theme set`, não existe mais como tal no Quattro — o estado atual vive em `~/.local/state/omarchy/current/`, também não versionado), `hypr/shaders/` (pacote stock de shaders do Hyprland, ~550K, sem customização), `lazygit` e `hyprland-preview-share-picker` (configs idênticas ao stock, zero valor de replicação), `~/.gitmessage` (trailer `Co-authored-by` de um colaborador real — dado de terceiro, não é meu pra publicar), e qualquer app com estado/cache pesado (navegadores, Discord, Obsidian, etc). O `icsUrl` de calendário privado em `omarchy/.config/omarchy/shell.json` (plugin `tobiasz-p.next-event`) foi substituído por um placeholder — é uma URL-segredo (dá leitura da agenda pra quem tiver o link), preencha a sua localmente antes de instalar. Nada neste repo contém segredo, token ou credencial — todo o histórico foi revisado antes do primeiro commit.

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

## Plugins do omarchy-shell

`omarchy/.config/omarchy/shell.json` referencia estes plugins de terceiros — instalados via `omarchy plugin install <fonte>`, **não vendorizados aqui** (cada um é seu próprio clone git em `~/.config/omarchy/plugins/`, análogo a `node_modules`):

| Plugin | O que é | Fonte |
|---|---|---|
| `crmne.hyprmoncfg` | Gerenciador de múltiplos monitores no bar | github.com/crmne/omarchy-hyprmoncfg |
| `shavanced.notification-center` | Central de notificações | github.com/Shavanced/omarchy-notification-center-plugin |
| `shmall.lock` | Tela de bloqueio customizada | github.com/shmall03/omarchy-shmall.lock-plugin |
| `io.github.cempack.omaspotify` | Widget do Spotify no bar | github.com/cempack/omaspotify |
| `crmne.lyrics` | Letra sincronizada com a música | github.com/crmne/omarchy-lyrics |
| `tobiasz-p.next-event` | Próximo evento da agenda no bar | github.com/tobiasz-p/next-event |

`plugins/bappoz.workspaces` é meu (indicador de workspace no bar) — esse sim está no pacote `omarchy` deste repo.

## Tema atual

Tema ativo: **Solitude**. Para restaurar:

```bash
omarchy theme set "Solitude"
```

## Cursor customizado

O cursor "CursorNovo" referenciado em `hypr/.config/hypr/envs.conf` precisa estar instalado em `~/.local/share/icons/` (ou XDG equivalente) — não incluído aqui por ser um asset binário grande.
