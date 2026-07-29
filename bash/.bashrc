# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Main browser 
export BROWSER=brave

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

# Para Bash: Título da janela do Kitty
set_window_title() {
  echo -ne "\033]2;${USER}@${HOSTNAME}: ${PWD/#$HOME/~}\007"
}
export PROMPT_COMMAND="set_window_title; $PROMPT_COMMAND"
. "$HOME/.cargo/env"

. "$HOME/.local/share/../bin/env"
