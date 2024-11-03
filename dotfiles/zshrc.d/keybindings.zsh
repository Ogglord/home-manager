# for partial history search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
#HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

# this was the mappings in ptyxis at least
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5D' backward-word # required for iterm2 macos
bindkey '^[[1;5C' forward-word # required for iterm2 macos