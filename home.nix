{ config, pkgs, lib, ... }:
let
  inherit (pkgs.stdenv) isLinux isDarwin;
  homeDir = if isDarwin then "/Users/" else "/home/";
  username = if isDarwin then "oscaragren" else "ogge";
  email = "oag@proton.me";
  linuxOnlyPackages = with pkgs; [
    kmon # kernel module TUI
    sysz # systemctl TUI
    powertop
  ];

in
{

  home = {
    homeDirectory = homeDir + username;
    inherit username;
    stateVersion = "24.05";
  };

  home.packages = with pkgs; [

    (nerdfonts.override { fonts = [ "Hack" "Meslo" ]; })

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
  ]
  ++ (if pkgs.stdenv.isLinux then linuxOnlyPackages else [ ]);


  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/zshrc' in
    # # the Nix store. Activating the configuration will then make '~/.zshrc' a symlink to the Nix store copy.
    ".zshrc".source = dotfiles/zshrc;
    ".zsh_aliases".source = dotfiles/zsh_aliases;
    ".justfile".source = dotfiles/justfile;
    ".config/topgrade/topgrade.toml".source = dotfiles/topgrade.toml;
    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

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
          export PATH="${pkgs.git}/bin:''$PATH"
          ${pkgs.gh}/bin/gh auth setup-git
          ${pkgs.just}/bin/just --completions zsh > ~/.config/zsh/just.zsh
      '';
    };
}
