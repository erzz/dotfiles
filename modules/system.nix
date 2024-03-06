{ pkgs, ... }:

  ###################################################################################
  #
  #  macOS's System configuration
  #
  #  All the configuration options are documented here:
  #    https://daiderd.com/nix-darwin/manual/index.html#sec-options
  #  Incomplete list of macOS `defaults` commands :
  #    https://github.com/yannbertrand/macos-defaults
  #
  ###################################################################################
{
  system = {
    # executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
    activationScripts.postUserActivation.text = ''
      # reloads the settings from the database and applies them to the current session
      # means that we do not need to logout and login again to make the changes take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    defaults = {
      # menuExtraClock.Show24Hour = true;  # show 24 hour clock
      
      # customize dock
      dock = {
        autohide = false;

        # customize Hot Corners
        wvous-tl-corner = 2;    # top-left - Mission Control
        wvous-tr-corner = 13;   # top-right - Lock Screen
        wvous-bl-corner = 3;    # bottom-left - Application Windows
        wvous-br-corner = 4;    # bottom-right - Desktop
      };

      # customize finder
      finder = {
        _FXShowPosixPathInTitle = true;          # show full path in finder title
        AppleShowAllExtensions = true;           # show all file extensions
        FXEnableExtensionChangeWarning = false;  # disable warning when changing file extension
        QuitMenuItem = true;                     # enable quit menu item
        ShowPathbar = true;                      # show path bar
        ShowStatusBar = true;                    # show status bar
        AppleShowAllFiles = true;                # show hidden files
      };

      # customize trackpad
      trackpad = {
        Clicking = true;                 # enable tap to click
        TrackpadRightClick = true;       # enable two finger right click
        TrackpadThreeFingerDrag = true;  # enable three finger drag
      };

      # customize settings that not supported by nix-darwin directly
      NSGlobalDomain = {
        "com.apple.swipescrolldirection" = false;  # enable natural scrolling(default to true)
        "com.apple.sound.beep.feedback" = 0;       # disable beep when pressing volume up/down key
        # AppleInterfaceStyle = "Dark";              # dark mode
        AppleKeyboardUIMode = 3;                   # Mode 3 enables full keyboard control.
        ApplePressAndHoldEnabled = true;           # enable press and hold
        InitialKeyRepeat = 15;                     # normal is 15 (225 ms), max is 120 (1800 ms)
        KeyRepeat = 3;                             # normal is 2 (30 ms), max is 120 (1800 ms)

        NSAutomaticCapitalizationEnabled = false;      # disable auto capitalization
        NSAutomaticDashSubstitutionEnabled = false;    # disable auto dash substitution
        NSAutomaticPeriodSubstitutionEnabled = false;  # disable auto period substitution
        NSAutomaticQuoteSubstitutionEnabled = false;   # disable auto quote substitution
        NSAutomaticSpellingCorrectionEnabled = false;  # disable auto spelling correction
        NSNavPanelExpandedStateForSaveMode = true;     # expand save panel by default
        NSNavPanelExpandedStateForSaveMode2 = true;
      };

      # Customize settings that not supported by nix-darwin directly
      # see the source code of this project to get more undocumented options:
      #    https://github.com/rgcr/m-cli
      # 
      # All custom entries can be found by running `defaults read` command.
      # or `defaults read xxx` to read a specific domain.
      CustomUserPreferences = {
        ".GlobalPreferences" = {
          # automatically switch to a new space when switching to the application
          # AppleSpacesSwitchOnActivate = true;
        };
        NSGlobalDomain = {
          # Add a context menu item for showing the Web Inspector in web views
          WebKitDeveloperExtras = true;
        };
        "com.apple.finder" = {
          ShowExternalHardDrivesOnDesktop = true;
          ShowHardDrivesOnDesktop = true;
          ShowMountedServersOnDesktop = true;
          ShowRemovableMediaOnDesktop = true;
          _FXSortFoldersFirst = true;
          # When performing a search, search the current folder by default
          FXDefaultSearchScope = "SCcf";
        };
        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.spaces" = {
          "spans-displays" = 0; # Display have separate spaces
        };
        "com.apple.WindowManager" = {
          EnableStandardClickToShowDesktop = 0; # Click wallpaper to reveal desktop
          StandardHideDesktopIcons = 0;         # Show items on desktop
          HideDesktop = 0;                      # Do not hide items on desktop & stage manager
          StageManagerHideWidgets = 0;
          StandardHideWidgets = 0;
        };
        "com.apple.screensaver" = {
          # Require password immediately after sleep or screen saver begins
          askForPassword = 1;
          askForPasswordDelay = 0;
        };
        "com.apple.screencapture" = {
          location = "~/Desktop";
          type = "png";
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        # Prevent Photos from opening automatically when devices are plugged in
        "com.apple.ImageCapture".disableHotPlug = true;
      };

      loginwindow = {
        GuestEnabled = false;  # disable guest user
        SHOWFULLNAME = true;   # show full name in login window
      };
    };
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh.enable = true;
  environment.shells = [
    pkgs.zsh
  ];

  # Set your time zone.
  # comment this due to the issue:
  #   https://github.com/LnL7/nix-darwin/issues/359
  time.timeZone = "Europe/stockholm";

  # Fonts
  fonts = {
    # will be removed after this PR is merged:
    #   https://github.com/LnL7/nix-darwin/pull/754
    fontDir.enable = true;

    # will change to `fonts.packages` after this PR is merged:
    #   https://github.com/LnL7/nix-darwin/pull/754
    fonts = with pkgs; [
    # packages = with pkgs; [
      # icon fonts
      material-design-icons
      font-awesome

      # nerdfonts
      # https://github.com/NixOS/nixpkgs/blob/nixos-23.11/pkgs/data/fonts/nerdfonts/shas.nix
      (nerdfonts.override {
        fonts = [
          # symbols icon only
          "NerdFontsSymbolsOnly"
          # Characters
          "FiraCode"
          "JetBrainsMono"
          "Iosevka"
        ];
      })
    ];
  };
}