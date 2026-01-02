# ============================================================
# HOME MANAGER - CONFIGURAÇÃO DO USUÁRIO
# ============================================================
# Módulo principal do Home Manager que importa todos os outros.
#
# Autor: Allan Farias

{ config, pkgs, lib, inputs, username, nix-colors, ... }:

{
  imports = [
    ./neovim.nix
    ./hyprland.nix
    ./shell.nix
    ./git.nix
  ];

  # ============================================================
  # HOME MANAGER BASE
  # ============================================================
  
  home = {
    username = username;
    homeDirectory = "/home/${username}";
    
    # Versão do Home Manager (não alterar após setup)
    stateVersion = "25.11";
  };

  # Permitir Home Manager gerenciar a si mesmo
  programs.home-manager.enable = true;

  # ============================================================
  # XDG DIRECTORIES
  # ============================================================
  
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      
      # Diretórios em português
      desktop = "${config.home.homeDirectory}/Área de Trabalho";
      documents = "${config.home.homeDirectory}/Documentos";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/Músicas";
      pictures = "${config.home.homeDirectory}/Imagens";
      publicShare = "${config.home.homeDirectory}/Público";
      templates = "${config.home.homeDirectory}/Modelos";
      videos = "${config.home.homeDirectory}/Vídeos";
    };
    
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "application/pdf" = "org.gnome.Evince.desktop";
        "image/*" = "org.gnome.Loupe.desktop";
        "video/*" = "vlc.desktop";
        "audio/*" = "vlc.desktop";
        "inode/directory" = "org.gnome.Nautilus.desktop";
      };
    };
  };

  # ============================================================
  # TEMAS GTK
  # ============================================================
  
  gtk = {
    enable = true;
    
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };
    
    font = {
      name = "Inter";
      size = 11;
    };
    
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # ============================================================
  # TEMAS QT
  # ============================================================
  
  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  # ============================================================
  # CURSOR
  # ============================================================
  
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # ============================================================
  # FONTES DO USUÁRIO
  # ============================================================
  
  fonts.fontconfig.enable = true;

  # ============================================================
  # PACOTES DO USUÁRIO
  # ============================================================
  
  home.packages = with pkgs; [
    # Ferramentas de tema
    adw-gtk3
    papirus-icon-theme
    
    # Fontes extras
    inter
    
    # CLI utils
    lsd               # ls com ícones
    bat               # cat com syntax highlighting
    eza               # ls moderno
    zoxide            # cd inteligente
    
    # Fun
    neofetch
    fastfetch
  ];

  # ============================================================
  # VARIÁVEIS DE AMBIENTE DO USUÁRIO
  # ============================================================
  
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "firefox";
    TERMINAL = "kitty";
  };

  # ============================================================
  # DCONF (CONFIGURAÇÕES GNOME)
  # ============================================================
  
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        enable-animations = true;
      };
    };
  };

  # ============================================================
  # NOTIFICAÇÕES
  # ============================================================
  
  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        follow = "mouse";
        width = 300;
        height = 300;
        origin = "top-right";
        offset = "10x50";
        scale = 0;
        notification_limit = 5;
        
        # Visual
        progress_bar = true;
        progress_bar_height = 10;
        progress_bar_frame_width = 1;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;
        
        indicate_hidden = true;
        separator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        text_icon_padding = 0;
        frame_width = 2;
        frame_color = "#89b4fa";
        separator_color = "frame";
        
        sort = true;
        idle_threshold = 120;
        
        # Text
        font = "JetBrainsMono Nerd Font 10";
        line_height = 0;
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        ellipsize = "middle";
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = true;
        
        # Icons
        icon_position = "left";
        min_icon_size = 0;
        max_icon_size = 32;
        
        # Mouse
        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
        
        # Corners
        corner_radius = 10;
      };
      
      urgency_low = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        timeout = 5;
      };
      
      urgency_normal = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        timeout = 10;
      };
      
      urgency_critical = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        frame_color = "#f38ba8";
        timeout = 0;
      };
    };
  };
}
