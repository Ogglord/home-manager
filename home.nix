{ config, pkgs, lib, ... }:
let
  inherit (pkgs.stdenv) isLinux isDarwin;
  homeDir = if isDarwin then "/Users/" else "/home/";
  username = if isDarwin then "oscaragren" else "ogge";
  homedir = homeDir + username;
  email = "oag@proton.me";
  linuxOnlyPackages = with pkgs; [
    kmon # kernel module TUI
    sysz # systemctl TUI
    powertop
  ];

in
{

  home = {
    homeDirectory = homedir;
    inherit username;
    stateVersion = "24.05";
  };

  home.packages = with pkgs; [

    #(nerdfonts.override { fonts = [ "Hack" "Meslo" ]; })
    font-awesome
    hack-font
    noto-fonts
    noto-fonts-emoji
    meslo-lgs-nf
    bat
    btop
    byobu
    comma # run any app without installing, prefix it with ","
    eza
    gh
    fortune
    just
    less
    macchina # neofetch alternative in rust
    micro
    ncdu
    nil # nix language interpreter
    nixpkgs-fmt
    rclone
    rsync
    smartmontools
    tmux
    topgrade
    tree
    zsh-powerlevel10k
  ]
  ++ (if pkgs.stdenv.isLinux then linuxOnlyPackages else [ ]);

  programs.zsh = {
    enable = true;
    autocd = false;
    plugins = [
      {
        name = "antidote";
        src = pkgs.antidote;
        file = "share/antidote/antidote.zsh";
      }
      # {
      #   name = "powerlevel10k";
      #   src = pkgs.zsh-powerlevel10k;
      #   file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      # }
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource ./dotfiles;
        file = "p10k.zsh";
      }
    ];

    initExtraFirst = ''
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi

      # Define variables for directories
      #export PATH=$HOME/.pnpm-packages/bin:$HOME/.pnpm-packages:$PATH
      #export PATH=$HOME/.npm-packages/bin:$HOME/bin:$PATH
      export PATH=$HOME/.local/share/bin:$PATH
      export XDG_CONFIG_HOME=''${XDG_CONFIG_HOME:-$HOME/.config}
      export XDG_DATA_HOME=''${XDG_DATA_HOME:-$HOME/.local/share}
      export XDG_CACHE_HOME=''${XDG_CACHE_HOME:-$HOME/.cache}
      export ZDOTDIR=''${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}

      # Remove history data we don't want to see
      export HISTIGNORE="pwd:ls:cd"

      # Emacs is my editor
      export ALTERNATE_EDITOR=""
      export EDITOR="nano"
      export VISUAL="nano"

      e() {
          nano "$@"
      }

      # nix shortcuts
      shell() {
          nix-shell '<nixpkgs>' -A "$1"
      }

      # Use difftastic, syntax-aware diffing
      alias diff=difft
      alias nix="noglob nix"

      # Always color ls and group directories
      alias ls='ls --color=auto'
    '';

    initExtra = ''
      antidote load
      #
      # source local zsrc.d/* files if they exist
      #


      typeset -ga _zshrcd=(
        ''$ZSHRCD
        ''${ZDOTDIR:-/dev/null}/zshrc.d(N)
        ''${HOME}/.zshrc.d(N)
        ''${ZDOTDIR:-$HOME}/.config/zsh/zshrc.d(N)
      )
      if [[ ! -e "''$_zshrcd[1]" ]]; then
        echo >&2 "zshrc.d: dir not found HOME or ZDOTDIR path!"
        return 1
      fi

      typeset -ga _zshrcd=("''$_zshrcd[1]"/*.{sh,zsh}(N))
      typeset -g _zshrcd_file
      for _zshrcd_file in ''${(o)_zshrcd}; do
        [[ ''${_zshrcd_file:t} != '~'* ]] || continue  # ignore tilde files
        source "''$_zshrcd_file"
      done
      unset _zshrcd{,_file}
    '';
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".justfile".source = dotfiles/justfile;
    ".config/topgrade/topgrade.toml".source = dotfiles/topgrade.toml;
    ".config/zsh/.zsh_plugins.txt".source = dotfiles/zsh_plugins.txt;
    # ".zshrc".source = dotfiles/zshrc;
    ".config/zsh/zshrc.d" = {
      source = dotfiles/zshrc.d;
      recursive = true;
    };

    ".config/macchina/themes/birdie.toml".source = dotfiles/macchina_birdie.toml;
    ".config/macchina/themes/birdie.ascii".source = dotfiles/macchina_birdie.ascii;
    ".config/macchina/macchina.toml".source = dotfiles/macchina.toml;
  };

  programs.git = {
    enable = true;
    # Additional options for the git program
    package = pkgs.gitAndTools.gitFull; # Install git wiith all the optional extras
    userName = "Ogglord";
    userEmail = email;
    extraConfig = {
      core.editor = "nano";
      credential.helper = "cache";
    };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/ogge/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "micro";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.activation =
    {
      setupGitAuth = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        	echo "Configuring git to use gh cli auth..."
          export PATH="${pkgs.git}/bin:/opt/homebrew/bin:/usr/bin:''$PATH"
          ${pkgs.gh}/bin/gh auth setup-git
          echo "Loading justfile completions to:${homedir}/.config/zsh/zshrc.d/just.zsh..."
          ${pkgs.just}/bin/just --completions zsh > ${homedir}/.config/zsh/zshrc.d/just.zsh
          echo "Loading docker completions to  :${homedir}/.config/zsh/zshrc.d/docker.zsh..."
          docker completion zsh > ${homedir}/.config/zsh/zshrc.d/docker.zsh
      '';
    };
}
