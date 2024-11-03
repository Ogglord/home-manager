# load our custom justfile completions

if [ -e "~/.config/zsh/just.zsh" ]; then
  . ~/.config/zsh/just.zsh
  export ZSH_JUST_COMPLOAD=1
else
  export ZSH_JUST_COMPLOAD=0
fi
