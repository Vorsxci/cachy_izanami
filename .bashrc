# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
alias vim="nvim"

if [ -f ~/.aliases ]; then
  source ~/.aliases
fi

eval "$(/usr/bin/starship init bash)"
eval "$(/usr/bin/zoxide init --cmd cd bash)"
# Set up fzf key bindings and fuzzy completion
eval "$(/usr/bin/fzf --bash)"

# Add your own exports, aliases, and functions here.
export PATH="$HOME/.config/customscripts:$PATH"
export PATH="$HOME/.local/bin:$PATH"

#export GTK_IM_MODULE=fcitx5
#export QT_IM_MODULE=fcitx5
export XMODIFIERS="@im=fcitx5"

fastfetch

# Make an alias for invoking commands you use constantly
# alias p='python'
