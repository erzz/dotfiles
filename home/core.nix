{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nnn          # terminal file manager
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep      # recursively searches directories for a regex pattern
    jq           # A lightweight and flexible command-line JSON processor
    yq-go        # yaml processer https://github.com/mikefarah/yq
    fzf          # A command-line fuzzy finder

    aria2        # A lightweight multi-protocol & multi-source command-line download utility
    socat        # replacement of openbsd-netcat
    nmap         # A utility for network discovery and security auditing

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    caddy
    gnupg

    glow         # markdown previewer in terminal
  ];

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
    };

    # A modern replacement for ‘ls’
    exa = {
      enable = true;
      enableAliases = true;
      git = true;
      icons = true;
    };

    # skim - anywhere you would want to use grep, try sk instead.
    skim = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}