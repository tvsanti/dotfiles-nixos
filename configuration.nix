# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ./fonts.nix ./bluetooth.nix ./java.nix <home-manager/nixos> ];
 
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
 
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Select internationalisation properties.
  i18n.defaultLocale = "es_ES.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
  };

  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw
  services.xserver = {
    enable = true;
    libinput = {
      enable = true;
      touchpad.scrollMethod = "edge";
    };
    displayManager = {
      lightdm.enable = true;
      startx.enable = true;
      defaultSession = "xsession";
      session = [{
          manage = "desktop";
          name = "xsession";
          start = ''exec $HOME/.xsession'';
      }];
    };

    desktopManager = {
      xterm.enable = false;
    };
    xrandrHeads = [
      {
        output = "HDMI-1";
        primary = true;
      }
      {
        output = "HDMI-2";
        primary = false;
      }
    ];
    layout = "es";
    xkbOptions = "eurosign:e";
  };

  # Enable the X11 windowing system.
  #services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  #services.xserver.xkb = {
    #layout = "es";
    #variant = "";
  #};  

  # Configure console keymap
  console.keyMap = "es";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.santiago = {
    isNormalUser = true;
    description = "Santiago";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
    #  thunderbird
    ];
  };
 
  programs.zsh.enable = true;  


  home-manager.users.santiago = { pkgs, ... }: {
    imports = [./alacritty.nix];
    # Allow unfree packages
    xsession = {
      enable = true;
      windowManager.i3 = {
        enable = true;
        config = {
          modifier = "Mod4";
          window.titlebar = false;
          terminal = "alacritty";
          menu = "rofi -show run";
        };
      };
    };
  programs.i3status = {
     enable = true;

      general = {
        colors = true;
        interval = 5;
      };

      modules = {
        ipv6 = { position = 1; };

        "wireless _first_" = {
          position = 2;
          settings = {
            format_up = "W: (%quality at %essid) %ip";
            format_down = "W: down";
          };
        };

        "ethernet _first_" = {
          position = 3;
          settings = {
            format_up = "E: %ip (%speed)";
            format_down = "E: down";
          };
        };

        "battery all" = {
          position = 4;
          settings = { format = "%status %percentage %remaining"; };
        };

        "volume master" = {
            position = 5;
            settings = {
              format = "♪ %volume";
              format_muted = "♪ muted (%volume)";
              device = "pulse:0";
            };
        };

        "disk /" = {
          position = 6;
          settings = { format = "%avail"; };
        };

        load = {
          position = 7;
          settings = { format = "%1min"; };
        };

        memory = {
          position = 8;
          settings = {
            format = "%used | %available";
            threshold_degraded = "1G";
            format_degraded = "MEMORY < %available";
          };
        };

        "tztime local" = {
          position = 9;
          settings = { format = "%Y-%m-%d %H:%M:%S"; };
        };
      };
  };

  programs.rofi = {
    enable = true;
    theme = ./rofi-dmenu-theme.rasi;
  };
  

    nixpkgs.config.allowUnfree = true;
    home.packages = with pkgs; [
      pkgs.nixfmt-classic
      xsel # managing Xorg clipboard
      cachix
      anki
      zathura # pdf reader
      scrot # making screenshots
      cloc # count lines of code
      pavucontrol
      python3 # TODO: In nixos config?
      ntfs3g # TODO: In nixos config?
      gnupg
      _1password
      deluge
      slack
      inetutils # for telnet (TODO: In cli-essentials.nix?)
      krew
      jetbrains.idea-community
      feh # image viewer
      # TODO: Maybe these all in kubernetes-something
      kubernetes-helm
      kubectl
      kubectx
      helmfile
      kustomize
      # TODO: Maybe in virtualization
      vagrant
      podman-compose

      spotify
      discord

      clang # I just need it to build tree-sitter grammars in emacs

      # TODO: Maybe put this somewhere else
      (google-cloud-sdk.withExtraComponents ([
        google-cloud-sdk.components.app-engine-go
      ]))

      pgcli
      jrnl
    ]  ++ import ./cli-essentials.nix { inherit pkgs; } ;

    services.sxhkd.enable = true;
    services.sxhkd.keybindings = {
      "super + o" = "firefox";
    };
    programs.fzf.enable = true;
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      autocd = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
          ll = "ls -l";
          update = "sudo nixos-rebuild switch";
        };
      defaultKeymap = "emacs";

      # Move across words with Ctrl + Left/Right
      initExtra = ''
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word
      '';
    };

    programs.starship = {
      enable = true;
      settings = { add_newline = false; };
    };

    programs.vscode = {
      enable = true;
      # prevents manually installing extensions, but also prevents nix-installed versions
     # from randomly breaking
      mutableExtensionsDir = false;
    };

    programs.bash.enable = true;
   
    programs.direnv.enable = true;

    programs.git = {
          enable = true;
          userName = "tvsanti";
          userEmail = "santithevenetvalles@gmail.com";
          aliases = {
            co = "checkout";
            ss = "status";
            cm = "commit -m";
          };
        };
    programs.mpv = {
      enable = true;
      config = {
        save-position-on-quit = true;
      };
    };
    # Install firefox.
    programs.firefox.enable = true;

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "24.05";
  };
 


  # Install Docker
  virtualisation.docker.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    lxappearance
    discord
    slack
    jetbrains.idea-community
    postman
    git
  ];




  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
 
  system.stateVersion = "24.05"; # Did you read the comment?

}

