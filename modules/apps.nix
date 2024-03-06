{ pkgs, ...}: {

  ##########################################################################
  # 
  #  Install all apps and packages here.
  #
  #  NOTE: Your can find all available options in:
  #    https://daiderd.com/nix-darwin/manual/index.html
  # 
  ##########################################################################

  # Install packages from nix's official package repository.
  #
  # The packages installed here are available to all users, and are reproducible across machines,
  # and are rollbackable. But on macOS, it's less stable than homebrew so prefer homebrew if
  # possible.
  #
  # Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
  
  environment.systemPackages = with pkgs; [
    git
  ];

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
    };

    taps = [
      "buo/cask-upgrade"
      "homebrew/cask-fonts"
      "homebrew/services"
      "homebrew/cask-versions"
    ];

    brews = [
      "adr-tools"
      "aspell"
      "bash"
      "bash-completion"
      "bat"
      "binutils"
      "btop"
      "ccache"
      "colima"
      "coreutils"
      "curl"
      "docker"
      "docker-compose"
      "flac"
      "git"
      "gh"
      "git-extras"
      "gitleaks"
      "gnupg2"
      "gnuplot"
      "go"
      "goenv"
      "graphviz"
      "hcl2json"
      "helm"
      "hostess"
      "htop"
      "httpie"
      "hub"
      "imagemagick"
      "imapsync"
      "inframap"
      "jq"
      "k9s"
      "kubectl"
      "lame"
      "mas"
      "mongosh"
      "moreutils"
      "nodeenv"
      "openjdk@11"
      "openssl"
      "p7zip"
      "pstree"
      "pyenv"
      "python"
      "rbenv"
      "rsync"
      "ruby-build"
      "shellcheck"
      "spaceship"
      "stow"
      "terraform"
      "terraformer"
      "tfenv"
      "the_silver_searcher"
      "tree"
      "trivy"
      "vim"
      "wget"
      "xz"
      "yarn"
      "zsh"
      "zsh-completion"
      "zsh-syntax-highlighting"
    ];

    casks = [
      "1password"
      "appcleaner"
      "authy"
      "bbedit"
      "disk-inventory-x"
      "displaylink"
      "elgato-camera-hub"
      "fig"
      "firefox"
      "garmin-express"
      "google-chrome"
      "google-cloud-sdk"
      "hyper"
      "iterm2"
      "microsoft-office"
      "microsoft-teams"
      "notion"
      "postman"
      "remarkable"
      "spotify"
      "the-unarchiver"
      "slack"
      "webex"
      "whatsapp"
      "via"
      "visual-studio-code"
      "vlc"
      "font-awesome-terminal-fonts"
      "font-cousine"
      "font-fira-code"
      "font-fontawesome"
      "font-hack"
      "font-handlee"
      "font-hasklig"
      "font-inconsolata"
      "font-montserrat"
      "font-noto-sans"
      "font-noto-emoji"
      "font-noto-color-emoji"
      "font-noto-serif"
      "font-open-sans"
      "font-pt-mono"
      "font-pt-sans"
      "font-pt-serif"
      "font-roboto"
      "font-roboto-mono"
      "font-source-code-pro"
      "font-source-sans-pro"
      "font-source-serif-pro"
      "font-ubuntu"
    ];
  };
}