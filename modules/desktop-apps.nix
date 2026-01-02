# ============================================================
# DESKTOP APPS - APLICATIVOS DE USO GERAL
# ============================================================
# Navegadores, comunicação, produtividade e utilitários.
#
# Autor: Allan Farias

{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # ============================================================
    # NAVEGADORES
    # ============================================================
    
    # ----------------------
    # Firefox
    # ----------------------
    firefox
    
    # ----------------------
    # Chromium
    # ----------------------
    chromium
    
    # ----------------------
    # Brave
    # ----------------------
    # brave
    
    # ----------------------
    # Vivaldi
    # ----------------------
    # vivaldi
    
    # ============================================================
    # COMUNICAÇÃO
    # ============================================================
    
    # ----------------------
    # Discord
    # ----------------------
    discord
    # vesktop           # Cliente Discord alternativo (melhor Wayland)
    
    # ----------------------
    # Telegram
    # ----------------------
    telegram-desktop
    
    # ----------------------
    # Slack
    # ----------------------
    # slack
    
    # ----------------------
    # Signal
    # ----------------------
    signal-desktop
    
    # ----------------------
    # Email
    # ----------------------
    thunderbird       # Cliente de email
    # mailspring
    
    # ============================================================
    # PRODUTIVIDADE
    # ============================================================
    
    # ----------------------
    # LibreOffice
    # ----------------------
    libreoffice-fresh
    
    # ----------------------
    # OnlyOffice
    # ----------------------
    onlyoffice-bin   # Edição de documentos
    
    # ----------------------
    # Obsidian
    # ----------------------
    obsidian         # Notes / Second brain
    
    # ----------------------
    # Notion (via Flatpak)
    # ----------------------
    # flatpak install flathub so.notion.Notion
    
    # ----------------------
    # Zotero
    # ----------------------
    # zotero          # Gerenciador de referências
    
    # ============================================================
    # GERENCIADOR DE ARQUIVOS
    # ============================================================
    
    # ----------------------
    # Nautilus (GNOME Files)
    # ----------------------
    # Preferência GTK - boa integração desktop
    gnome.nautilus
    
    # Extensões Nautilus
    gnome.nautilus-python
    gnome.sushi      # Preview de arquivos
    
    # ----------------------
    # Thunar (alternativa XFCE)
    # ----------------------
    # xfce.thunar
    # xfce.thunar-archive-plugin
    # xfce.thunar-volman
    
    # ----------------------
    # Dolphin (alternativa KDE)
    # ----------------------
    # dolphin
    # kio-extras
    
    # ============================================================
    # UTILITÁRIOS
    # ============================================================
    
    # ----------------------
    # Terminal
    # ----------------------
    kitty             # GPU-accelerated
    alacritty         # Alternativa leve
    
    # ----------------------
    # System Monitor
    # ----------------------
    btop              # Monitor recursos (bonito)
    htop              # Clássico
    gnome.gnome-system-monitor
    
    # ----------------------
    # Disk Usage
    # ----------------------
    baobab            # GNOME disk analyzer
    duf               # CLI disk usage
    ncdu              # ncurses disk usage
    
    # ----------------------
    # Archive Manager
    # ----------------------
    gnome.file-roller # GUI para arquivos
    p7zip
    unrar
    unzip
    zip
    
    # ----------------------
    # Calculator
    # ----------------------
    gnome.gnome-calculator
    qalculate-gtk     # Calculadora avançada
    
    # ----------------------
    # Screenshots
    # ----------------------
    flameshot         # Screenshots com anotação
    
    # ----------------------
    # Screen Recording
    # ----------------------
    kooha             # Simples
    
    # ----------------------
    # Password Manager
    # ----------------------
    bitwarden-desktop
    # keepassxc
    
    # ----------------------
    # Remote Desktop
    # ----------------------
    remmina           # RDP, VNC, SSH
    
    # ----------------------
    # Torrent
    # ----------------------
    qbittorrent
    
    # ============================================================
    # MÍDIA
    # ============================================================
    
    # ----------------------
    # Music Player
    # ----------------------
    spotify           # Streaming
    # spotifyd        # Daemon Spotify
    
    # ----------------------
    # Local Music
    # ----------------------
    rhythmbox         # GTK music player
    # lollypop        # Modern GTK player
    
    # ----------------------
    # Video Player
    # ----------------------
    vlc
    mpv
    celluloid         # GTK frontend for mpv
    
    # ----------------------
    # Podcasts
    # ----------------------
    gnome.gnome-podcasts
    
    # ============================================================
    # LEITORES
    # ============================================================
    
    # ----------------------
    # PDF
    # ----------------------
    evince            # GNOME PDF viewer
    # okular          # KDE PDF viewer (mais features)
    
    # ----------------------
    # E-books
    # ----------------------
    calibre           # Gerenciador de e-books
    foliate           # E-book reader GTK
    
    # ============================================================
    # OUTROS
    # ============================================================
    
    # ----------------------
    # Fonts Manager
    # ----------------------
    font-manager
    
    # ----------------------
    # Color Picker
    # ----------------------
    eyedropper        # GTK color picker
    
    # ----------------------
    # Clipboard Manager
    # ----------------------
    # Já incluído no hyprland.nix (cliphist)
    
    # ----------------------
    # App Image Support
    # ----------------------
    appimage-run
  ];

  # ============================================================
  # FLATPAK (PARA APPS ADICIONAIS)
  # ============================================================
  
  services.flatpak.enable = true;
  
  # Adicionar Flathub automaticamente (requer rebuild + reboot)
  # systemd.services.flatpak-repo = {
  #   wantedBy = [ "multi-user.target" ];
  #   path = [ pkgs.flatpak ];
  #   script = ''
  #     flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  #   '';
  # };

  # ============================================================
  # XDG MIME TYPES
  # ============================================================
  
  xdg.mime = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "application/pdf" = "org.gnome.Evince.desktop";
      "image/png" = "org.gnome.Loupe.desktop";
      "image/jpeg" = "org.gnome.Loupe.desktop";
      "video/mp4" = "vlc.desktop";
      "audio/mpeg" = "vlc.desktop";
      "inode/directory" = "org.gnome.Nautilus.desktop";
    };
  };

  # ============================================================
  # GNOME SERVICES (PARA NAUTILUS)
  # ============================================================
  
  # GVfs para montagem de dispositivos
  services.gvfs.enable = true;
  
  # Tumbler para thumbnails
  services.tumbler.enable = true;

  # ============================================================
  # NOTAS DESKTOP APPS
  # ============================================================
  #
  # 1. FLATPAK:
  #    Após instalação, adicione Flathub:
  #    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  #
  # 2. APPS NÃO DISPONÍVEIS:
  #    - Notion: flatpak install flathub so.notion.Notion
  #    - Figma: flatpak install flathub io.github.nickvision_Figma
  #    - Postman: flatpak install flathub com.getpostman.Postman
  #
  # 3. DISCORD + WAYLAND:
  #    Vesktop tem melhor suporte a Wayland e screen sharing
  #
  # 4. NAUTILUS:
  #    Para funcionar bem, precisa de gvfs e serviços GNOME
}
