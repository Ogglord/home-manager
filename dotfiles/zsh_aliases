# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='clear'

# Filesystem
alias ls='$(command -v eza &> /dev/null && echo eza || echo ls)'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias mkdir='mkdir -p'

# Editing
alias nano='$(command -v micro &> /dev/null && echo micro || echo nano)'
alias e='nano'
alias ee='nano -w'

# System
alias ssc='sudo systemctl'
alias sscu='sudo systemctl --user'

# Networking
alias ip='ip addr show'
alias ips='ip addr show | grep inet'
alias p='ping google.com'

# Miscellaneous
alias cdc='cd ~/.config'
alias cdh='cd ~/.config/home-manager'
alias neofetch='$(command -v macchina &> /dev/null && echo macchina || echo neofetch)'
alias just="just -g"

# Nix Home Manager
alias switch='~/.nix-profile/bin/home-manager switch && echo "Reloading Zsh..." && source ~/.zshrc'
alias build='~/.nix-profile/bin/home-manager build'
