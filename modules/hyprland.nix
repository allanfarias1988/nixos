# ============================================================
# HYPRLAND - COMPOSITOR WAYLAND
# ============================================================
# Configuração do Hyprland com todos os componentes necessários
# para um ambiente desktop completo.
#
# Autor: Allan Farias

{ config, pkgs, lib, inputs, ... }:

{
  # ============================================================
  # HYPRLAND CORE
  # ============================================================
  
  programs.hyprland = {
    enable = true;
    
    # Universal Wayland Session Manager
    # Melhor integração com systemd
    withUWSM = true;
    
    # Xwayland para compatibilidade com apps X11
    xwayland.enable = true;
    
    # Usar pacote do flake (versão mais recente)
    # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  # ============================================================
  # XDG PORTAL
  # ============================================================
  
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk  # Para apps GTK
    ];
  };

  # ============================================================
  # COMPONENTES ESSENCIAIS
  # ============================================================
  
  environment.systemPackages = with pkgs; [
    # ----------------------
    # Barra de status
    # ----------------------
    waybar            # Barra personalizável
    
    # ----------------------
    # Launcher / Menu
    # ----------------------
    wofi              # Launcher (compatível Wayland)
    rofi-wayland      # Alternativa mais customizável
    
    # ----------------------
    # Notificações
    # ----------------------
    dunst             # Daemon de notificações
    libnotify         # CLI para notificações
    
    # ----------------------
    # Wallpaper
    # ----------------------
    swww              # Wallpaper animated
    hyprpaper         # Wallpaper estático (mais leve)
    
    # ----------------------
    # Lockscreen
    # ----------------------
    hyprlock          # Lock screen para Hyprland
    hypridle          # Idle manager
    
    # ----------------------
    # Screenshots
    # ----------------------
    grim              # Screenshot
    slurp             # Seleção de área
    grimblast         # Wrapper conveniente
    swappy            # Editor de screenshots
    
    # ----------------------
    # Clipboard
    # ----------------------
    wl-clipboard      # CLI clipboard
    cliphist          # Histórico de clipboard
    
    # ----------------------
    # Outros utilitários
    # ----------------------
    brightnessctl     # Controle de brilho
    playerctl         # Controle de mídia
    pamixer           # Controle de volume
    wlsunset          # Filtro de luz azul
    
    # ----------------------
    # Autenticação
    # ----------------------
    polkit-kde-agent  # Agente Polkit (ou usar gnome)
    
    # ----------------------
    # Terminal
    # ----------------------
    kitty             # Terminal rápido com GPU
    alacritty         # Alternativa leve
    
    # ----------------------
    # Temas
    # ----------------------
    gtk3              # Para theming
    gtk4
    adwaita-icon-theme
    papirus-icon-theme
    
    # Cursor
    hyprcursor
  ];

  # ============================================================
  # SERVIÇOS DE SUPORTE
  # ============================================================
  
  # Polkit para autenticação
  security.polkit.enable = true;
  
  # Agente de autenticação
  systemd.user.services.polkit-kde-authentication-agent-1 = {
    description = "polkit-kde-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # ============================================================
  # GREETD - DISPLAY MANAGER
  # ============================================================
  
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };
  
  # Alternativa: SDDM com tema moderno
  # services.displayManager.sddm = {
  #   enable = true;
  #   wayland.enable = true;
  #   theme = "breeze";
  # };

  # ============================================================
  # VARIÁVEIS HYPRLAND
  # ============================================================
  
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    
    # Melhora renderização de apps GTK
    GDK_BACKEND = "wayland,x11";
    
    # Qt em Wayland
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    
    # SDL
    SDL_VIDEODRIVER = "wayland";
    
    # Clutter
    CLUTTER_BACKEND = "wayland";
  };

  # ============================================================
  # FONTES E ÍCONES
  # ============================================================
  
  fonts.packages = with pkgs; [
    # Ícones para Waybar
    font-awesome
    material-design-icons
  ];

  # ============================================================
  # DCONF (PARA CONFIGURAÇÕES GTK)
  # ============================================================
  
  programs.dconf.enable = true;

  # ============================================================
  # NOTAS HYPRLAND
  # ============================================================
  #
  # 1. CONFIGURAÇÃO DO USUÁRIO:
  #    A configuração Hyprland vai em ~/.config/hypr/hyprland.conf
  #    Usamos Home Manager para gerenciar isso (ver home/hyprland.nix)
  #
  # 2. NVIDIA:
  #    Se usando Nvidia, certifique-se que nvidia-drm.modeset=1
  #    está nos kernelParams
  #
  # 3. MONITOR CONFIG:
  #    Configure monitores no hyprland.conf:
  #    monitor=DP-1,1920x1080@144,0x0,1
  #
  # 4. PROBLEMAS DE CURSOR:
  #    Use WLR_NO_HARDWARE_CURSORS=1 se o cursor sumir
}
