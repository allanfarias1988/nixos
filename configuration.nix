# ============================================================
# CONFIGURAÇÃO BASE DO NIXOS
# ============================================================
# Esta é a configuração principal do sistema. Módulos específicos
# são importados separadamente para melhor organização.
#
# Autor: Allan Farias
# Atualizado: Janeiro 2026

{ config, pkgs, lib, inputs, username, ... }:

{
  # ============================================================
  # SISTEMA BÁSICO
  # ============================================================
  
  # Versão do NixOS (não altere após instalação)
  system.stateVersion = "24.11";
  
  # Habilitar flakes e novo comando nix
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      
      # Substituters/Caches para builds mais rápidos
      substituters = [
        "https://cache.nixos.org"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
        "https://cuda-maintainers.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+ voices8YEuZJpMApMXJOViDk9GM9yN3uvTo="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
      
      # Permitir usuários trusted
      trusted-users = [ "root" "@wheel" ];
    };
    
    # Limpeza automática do store
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # ============================================================
  # BOOTLOADER
  # ============================================================
  
  # SystemD-Boot (recomendado para UEFI)
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;  # Limitar gerações no menu
    };
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };  

  # GRUB (alternativa - descomente se preferir)
  # boot.loader = {
  #   grub = {
  #     enable = true;
  #     device = "nodev";       # Para UEFI
  #     efiSupport = true;
  #     useOSProber = true;     # Detectar outros SOs
  #   };
  #   efi.canTouchEfiVariables = true;
  # };

  # Kernel - linux_latest é mais estável com Nvidia
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  # Parâmetros do kernel para melhor compatibilidade
  boot.kernelParams = [
    "quiet"
    "splash"
    "nvidia_drm.modeset=1"  # Necessário para Wayland/Nvidia
  ];

  # ============================================================
  # REDE
  # ============================================================
  
  networking = {
    hostName = "nixos-workstation";
    networkmanager.enable = true;
    
    # Firewall básico
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
      # allowedUDPPorts = [ ... ];
    };
  };

  # ============================================================
  # LOCALIZAÇÃO E IDIOMA
  # ============================================================
  
  # Timezone Brasil
  time.timeZone = "America/Sao_Paulo";
  
  # Locale pt_BR
  i18n = {
    defaultLocale = "pt_BR.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
    };
  };

  # Teclado - ABNT2
  console.keyMap = "br-abnt2";

  # ============================================================
  # ÁUDIO - PIPEWIRE
  # ============================================================
  
  # Desabilitar PulseAudio (substituído por PipeWire)
  hardware.pulseaudio.enable = false;
  
  # Habilitar PipeWire com suporte completo
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;        # Para produção de áudio
    
    # Wireplumber para gerenciamento de sessão
    wireplumber.enable = true;
  };

  # Tempo real para áudio de baixa latência
  security.rtkit.enable = true;

  # ============================================================
  # DISPLAY E GRÁFICOS
  # ============================================================
  
  # XDG Portal para integração com Flatpak e capturas de tela
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };

  # Polkit para autenticação de aplicativos
  security.polkit.enable = true;

  # DBus
  services.dbus.enable = true;

  # GVfs para montagem de dispositivos
  services.gvfs.enable = true;

  # ============================================================
  # FONTES
  # ============================================================
  
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      # Nerd Fonts (ícones para terminal e editores)
      (nerdfonts.override { fonts = [ 
        "JetBrainsMono" 
        "FiraCode" 
        "Iosevka"
        "CascadiaCode"
      ]; })
      
      # Fontes de UI
      inter
      roboto
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      
      # Fontes Microsoft (opcional - para compatibilidade)
      corefonts
      vistafonts
      
      # Fontes para código
      jetbrains-mono
      fira-code
      
      # Outras
      liberation_ttf
      ubuntu_font_family
    ];
    
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Inter" "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" "Fira Code" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # ============================================================
  # USUÁRIO
  # ============================================================
  
  users.users.${username} = {
    isNormalUser = true;
    description = "Allan Farias";
    extraGroups = [ 
      "wheel"           # sudo
      "networkmanager"  # Gerenciar rede
      "video"           # Acesso a dispositivos de vídeo
      "audio"           # Acesso a áudio
      "input"           # Dispositivos de entrada
      "docker"          # Docker (se habilitado)
      "podman"          # Podman
      "libvirtd"        # VMs
      "scanner"         # Scanners
      "lp"              # Impressoras
    ];
    shell = pkgs.zsh;
  };

  # Habilitar Zsh globalmente
  programs.zsh.enable = true;

  # ============================================================
  # SERVIÇOS BÁSICOS
  # ============================================================
  
  # SSH Server (desabilitado por padrão - descomente se necessário)
  # services.openssh = {
  #   enable = true;
  #   settings = {
  #     PasswordAuthentication = false;
  #     PermitRootLogin = "no";
  #   };
  # };

  # Flatpak (para aplicativos adicionais)
  services.flatpak.enable = true;

  # Fwupd para atualizações de firmware
  services.fwupd.enable = true;

  # Thermald para gerenciamento térmico (laptops)
  services.thermald.enable = true;

  # TLP para economia de energia (laptops)
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };
  };

  # ============================================================
  # SEGURANÇA
  # ============================================================
  
  # Sudo sem senha para comandos específicos (opcional)
  # security.sudo.extraRules = [{
  #   users = [ username ];
  #   commands = [{
  #     command = "/run/current-system/sw/bin/nixos-rebuild";
  #     options = [ "NOPASSWD" ];
  #   }];
  # }];

  # Gnome Keyring para senhas
  services.gnome.gnome-keyring.enable = true;

  # ============================================================
  # PACOTES DO SISTEMA
  # ============================================================
  
  environment.systemPackages = with pkgs; [
    # Utilitários básicos
    wget
    curl
    git
    vim
    htop
    btop
    tree
    unzip
    zip
    p7zip
    file
    which
    gnumake
    
    # Gerenciamento de arquivos
    fd
    ripgrep
    fzf
    bat
    eza          # ls moderno
    
    # Rede
    networkmanagerapplet
    
    # Sistema
    lsof
    pciutils
    usbutils
    dmidecode
    inxi
  ];

  # ============================================================
  # VARIÁVEIS DE AMBIENTE
  # ============================================================
  
  environment.sessionVariables = {
    # Editor padrão
    EDITOR = "nvim";
    VISUAL = "nvim";
    
    # Wayland
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    
    # XDG
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    
    # Qt no Wayland
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    
    # GTK
    GDK_BACKEND = "wayland,x11";
  };

  # ============================================================
  # VIRTUALIZAÇÃO
  # ============================================================
  
  # Podman (preferido em Silverblue/Fedora)
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;      # Alias docker -> podman
    defaultNetwork.settings.dns_enabled = true;
  };

  # Docker (alternativa - descomente se preferir)
  # virtualisation.docker = {
  #   enable = true;
  #   enableOnBoot = false;   # Não iniciar automaticamente
  # };

  # Libvirt para VMs
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
}
