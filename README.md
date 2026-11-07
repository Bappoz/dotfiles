# dotfiles

Snapshot das configurações locais do Omarchy 4.5.0-3, atualizado em 7 de novembro de 2026. Usa GNU Stow. Os arquivos Lua de Hyprland são a configuração ativa; os arquivos antigos ainda presentes foram conservados como estão na máquina.

## Ambiente atual

- Hyprland: modo dwindle por padrão; Super+T alterna apenas a janela atual entre encaixada e flutuante.
- Terminal: Super+Enter abre centralizado e flutuante.
- Janelas flutuantes: barra de vidro com botões vermelho (fechar), amarelo (minimizar) e verde (maximizar). Super+M minimiza para o Dock.
- Dock local: aparece ao passar o ponteiro embaixo, inclusive em tela cheia; fundo de vidro e nenhuma faixa reservada. Clique no aplicativo para restaurar.
- Barra superior, notificações, menus e plugins rodam no omarchy-shell/Quickshell. Waybar não é usado nesta instalação.
- Tema: `my-neighbor-totoro-sunflowers-01-palette`; a cópia do tema ativo está incluída.

## Conteúdo

| Pacote | Conteúdo |
|---|---|
| `hypr` | Configuração completa do usuário, módulos Lua, monitores e atalhos |
| `omarchy` | Shell, barra, Dock, Notchi, plugins instalados, temas, fundos, hooks e layouts persistidos |
| `desktop-scripts` | Minimização para o Dock e auxiliares do calendário |
| `hyprmoncfg` | Perfis de monitores desta máquina |
| `kitty`, `tmux`, `starship`, `zsh`, `bash` | Terminal, prompt e shells; inclui os plugins customizados do Oh My Zsh |
| `btop`, `fastfetch`, `git`, `aider` | Configurações das ferramentas; git e aider conservados do repositório anterior |
| `nvim` | Submodule existente para Bappoz/.config |

Os plugins do Omarchy são copiados com o código e os assets instalados, sem seus diretórios Git. Isso preserva as alterações locais. `plugin-sources.json` registra as origens, revisões e a presença de alterações locais nos plugins que possuem repositório. Plugins locais `bappoz.*` estão incluídos integralmente. As licenças dos plugins foram mantidas.

`snapshot.json` identifica a versão e o tema. `packages-explicit.txt` lista os pacotes explicitamente instalados para consulta; não é uma lista para instalar cegamente.

## Restaurar

Use uma instalação compatível do Omarchy 4.5 com o plugin de título `omarchy-hyprland-titlebars`, Kitty, Quickshell e Oh My Zsh instalados.

```bash
git clone --recurse-submodules https://github.com/Bappoz/dotfiles.git ~/Work/dotfiles
cd ~/Work/dotfiles
./install.sh
# Ou somente os componentes desejados:
./install.sh hypr omarchy desktop-scripts kitty
omarchy theme set my-neighbor-totoro-sunflowers-01-palette
hyprctl reload
hyprctl configerrors
omarchy restart shell
```

O instalador cria links; não sobrescreve arquivos existentes. Em outra máquina, faça backup e resolva os conflitos antes de aplicar. Não rode a instalação sobre o ambiente atual apenas para fazer backup. Perfis de monitores e caminhos `/home/bappoz` são específicos desta máquina e precisam ser ajustados para outro usuário. O cursor CursorNovo e aplicativos externos referenciados precisam estar instalados à parte.

## Dados locais e privacidade

A cópia pública exclui históricos, credenciais, chaves, caches, backups, diretórios Git dos plugins e estado de sessões. A URL privada de calendário (`icsUrl`) e o avatar pessoal (`avatar`) em shell.json ficam vazios; preencha-os localmente depois de restaurar. O tema e o layout estão incluídos, mas estado de notificações, clipboard, contas e dados internos dos aplicativos não faz parte dos dotfiles.

Configurações em uso no computador não são alteradas pelo snapshot.

Configurações adicionais presentes na máquina: `alacritty`, `foot`, `ghostty`, `uwsm`, `fontconfig`, `environment.d`.
