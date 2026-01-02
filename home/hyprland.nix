# ============================================================
# HYPRLAND - CONFIGURAÇÃO DO USUÁRIO
# ============================================================
# Keybindings, animações e configuração visual do Hyprland.
# Os atalhos respeitam padrões de sistema e aplicações.
#
# Autor: Allan Farias

{ config, pkgs, lib, ... }:

{
  # ============================================================
  # HYPRLAND CONFIG
  # ============================================================
  
  wayland.windowManager.hyprland = {
    enable = true;
    
    settings = {
      # ========================================================
      # MONITORES
      # ========================================================
      # Ajuste para seus monitores
      # Use: hyprctl monitors para ver IDs
      
      monitor = [
        # Formato: name,resolution@fps,position,scale
        ",preferred,auto,1"  # Auto-detect
        # "DP-1,1920x1080@144,0x0,1"
        # "HDMI-A-1,1920x1080@60,1920x0,1"
      ];

      # ========================================================
      # AUTOSTART
      # ========================================================
      
      exec-once = [
        # Wallpaper
        "swww init"
        "swww img ~/Imagens/wallpaper.jpg"
        
        # Status bar
        "waybar"
        
        # Notifications
        "dunst"
        
        # Polkit agent
        "${pkgs.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1"
        
        # Clipboard
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        
        # Idle/Lock (opcional)
        # "hypridle"
        
        # Cursor
        "hyprctl setcursor Adwaita 24"
      ];

      # ========================================================
      # VARIÁVEIS DE INPUT
      # ========================================================
      
      input = {
        kb_layout = "br";
        kb_variant = "abnt2";
        kb_options = "";
        
        follow_mouse = 1;
        sensitivity = 0;
        
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          tap-to-click = true;
        };
      };

      # ========================================================
      # APARÊNCIA GERAL
      # ========================================================
      
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        
        "col.active_border" = "rgba(89b4faee) rgba(cba6f7ee) 45deg";
        "col.inactive_border" = "rgba(585b70aa)";
        
        layout = "dwindle";
        resize_on_border = true;
      };

      # ========================================================
      # DECORAÇÃO
      # ========================================================
      
      decoration = {
        rounding = 10;
        
        # Blur
        blur = {
          enabled = true;
          size = 8;
          passes = 3;
          new_optimizations = true;
          xray = true;
          ignore_opacity = false;
        };
        
        # Sombras
        drop_shadow = true;
        shadow_range = 15;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
        
        # Opacidade
        active_opacity = 1.0;
        inactive_opacity = 0.95;
        fullscreen_opacity = 1.0;
      };

      # ========================================================
      # ANIMAÇÕES
      # ========================================================
      
      animations = {
        enabled = true;
        
        # Curvas de bezier para animações suaves
        bezier = [
          "overshot, 0.05, 0.9, 0.1, 1.05"
          "smoothOut, 0.36, 0, 0.66, -0.56"
          "smoothIn, 0.25, 1, 0.5, 1"
          "easeInOut, 0.4, 0, 0.2, 1"
          "easeOut, 0, 0, 0.2, 1"
        ];
        
        animation = [
          "windows, 1, 5, overshot, slide"
          "windowsOut, 1, 4, smoothOut, slide"
          "windowsMove, 1, 4, easeInOut"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 5, smoothIn"
          "fadeDim, 1, 5, smoothIn"
          "workspaces, 1, 6, easeInOut, slide"
        ];
      };

      # ========================================================
      # LAYOUTS
      # ========================================================
      
      dwindle = {
        pseudotile = true;
        preserve_split = true;
        smart_split = true;
        smart_resizing = true;
      };
      
      master = {
        new_status = "master";
        new_on_top = true;
      };

      # ========================================================
      # GESTOS (TOUCHPAD)
      # ========================================================
      
      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
        workspace_swipe_distance = 300;
        workspace_swipe_invert = true;
        workspace_swipe_cancel_ratio = 0.5;
      };

      # ========================================================
      # MISCELÂNEA
      # ========================================================
      
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
        vrr = 1;  # Variable refresh rate
        enable_swallow = true;
        swallow_regex = "^(kitty|alacritty)$";
      };

      # ========================================================
      # REGRAS DE JANELAS
      # ========================================================
      
      windowrulev2 = [
        # Float windows
        "float, class:^(pavucontrol)$"
        "float, class:^(nm-connection-editor)$"
        "float, class:^(blueman-manager)$"
        "float, class:^(file-roller)$"
        "float, class:^(nwg-look)$"
        "float, class:^(qt5ct)$"
        "float, title:^(btop)$"
        "float, title:^(Volume Control)$"
        
        # Picture in Picture
        "float, title:^(Picture-in-Picture)$"
        "pin, title:^(Picture-in-Picture)$"
        "size 30% 30%, title:^(Picture-in-Picture)$"
        
        # File dialogs
        "float, title:^(Open File)$"
        "float, title:^(Save File)$"
        "float, title:^(Confirm to replace files)$"
        "float, title:^(File Operation Progress)$"
        
        # Opacity para terminais
        "opacity 0.95, class:^(kitty)$"
        "opacity 0.95, class:^(Alacritty)$"
      ];

      # ========================================================
      # KEYBINDINGS
      # ========================================================
      # Usando padrões de sistema:
      # - Super como modificador principal
      # - Combinações intuitivas similares a outros DEs
      
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$fileManager" = "nautilus";
      "$menu" = "wofi --show drun";
      "$browser" = "firefox";

      bind = [
        # ----------------------
        # Aplicações
        # ----------------------
        "$mod, Return, exec, $terminal"           # Terminal
        "$mod, E, exec, $fileManager"             # File manager
        "$mod, B, exec, $browser"                 # Browser
        "$mod, Space, exec, $menu"                # App launcher
        "$mod, D, exec, $menu"                    # App launcher (alt)
        
        # ----------------------
        # Janelas
        # ----------------------
        "$mod, Q, killactive"                     # Fechar janela
        "$mod, F, fullscreen, 1"                  # Fullscreen
        "$mod SHIFT, F, fullscreen, 0"            # True fullscreen
        "$mod, V, togglefloating"                 # Toggle floating
        "$mod, P, pseudo"                         # Pseudo tiling
        "$mod, J, togglesplit"                    # Toggle split
        
        # ----------------------
        # Foco (vim-like)
        # ----------------------
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"
        
        # ----------------------
        # Mover janelas
        # ----------------------
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"
        "$mod SHIFT, h, movewindow, l"
        "$mod SHIFT, l, movewindow, r"
        "$mod SHIFT, k, movewindow, u"
        "$mod SHIFT, j, movewindow, d"
        
        # ----------------------
        # Workspaces
        # ----------------------
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"
        
        # Mover janela para workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"
        
        # Navegar workspaces
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"
        "$mod, Tab, workspace, previous"
        
        # ----------------------
        # Screenshots (padrão PrintScreen)
        # ----------------------
        ", Print, exec, grimblast copy area"                        # Área
        "SHIFT, Print, exec, grimblast copy screen"                  # Tela toda
        "CTRL, Print, exec, grimblast save area ~/Imagens/$(date +%Y%m%d-%H%M%S).png"
        
        # ----------------------
        # Mídia (teclas de mídia)
        # ----------------------
        ", XF86AudioMute, exec, pamixer -t"
        ", XF86AudioMicMute, exec, pamixer --default-source -t"
        
        # ----------------------
        # Brilho
        # ----------------------
        ", XF86MonBrightnessUp, exec, brightnessctl s +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
        
        # ----------------------
        # Clipboard
        # ----------------------
        "$mod, C, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"
        
        # ----------------------
        # Sistema
        # ----------------------
        "$mod SHIFT, Q, exit"                     # Sair do Hyprland
        "$mod, M, exec, hyprlock"                 # Lock screen
        "$mod SHIFT, R, exec, hyprctl reload"     # Reload config
      ];

      # Binds com repeat (volume, etc)
      binde = [
        ", XF86AudioRaiseVolume, exec, pamixer -i 5"
        ", XF86AudioLowerVolume, exec, pamixer -d 5"
      ];

      # Binds de mouse
      bindm = [
        "$mod, mouse:272, movewindow"     # Super + Left click
        "$mod, mouse:273, resizewindow"   # Super + Right click
      ];
    };
  };

  # ============================================================
  # WAYBAR CONFIG
  # ============================================================
  
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 35;
        spacing = 4;
        
        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];
        
        modules-center = [
          "clock"
        ];
        
        modules-right = [
          "tray"
          "pulseaudio"
          "network"
          "battery"
        ];
        
        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "10";
          };
          on-click = "activate";
          sort-by-number = true;
        };
        
        "clock" = {
          format = " {:%H:%M}";
          format-alt = " {:%A, %d de %B de %Y}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };
        
        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = "󰖁 Mudo";
          format-icons = {
            default = ["" "" ""];
          };
          on-click = "pavucontrol";
        };
        
        "network" = {
          format-wifi = "󰤨 {signalStrength}%";
          format-ethernet = "󰈀";
          format-disconnected = "󰤭";
          tooltip-format = "{ifname}: {ipaddr}";
          on-click = "nm-connection-editor";
        };
        
        "battery" = {
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰚥 {capacity}%";
          format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
          states = {
            warning = 30;
            critical = 15;
          };
        };
        
        "tray" = {
          spacing = 10;
        };
      };
    };
    
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free";
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(30, 30, 46, 0.9);
        color: #cdd6f4;
      }

      #workspaces button {
        padding: 0 8px;
        color: #cdd6f4;
        background: transparent;
        border-radius: 5px;
        margin: 3px;
      }

      #workspaces button.active {
        background: #89b4fa;
        color: #1e1e2e;
      }

      #workspaces button:hover {
        background: #585b70;
      }

      #clock, #battery, #pulseaudio, #network, #tray {
        padding: 0 10px;
        margin: 3px 0;
        border-radius: 5px;
        background: #313244;
      }

      #battery.warning {
        background: #f9e2af;
        color: #1e1e2e;
      }

      #battery.critical {
        background: #f38ba8;
        color: #1e1e2e;
      }
    '';
  };

  # ============================================================
  # WOFI CONFIG
  # ============================================================
  
  programs.wofi = {
    enable = true;
    settings = {
      width = 500;
      height = 400;
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 24;
    };
    
    style = ''
      window {
        margin: 0px;
        border: 2px solid #89b4fa;
        border-radius: 15px;
        background-color: #1e1e2e;
      }

      #input {
        margin: 5px;
        border: none;
        color: #cdd6f4;
        background-color: #313244;
        border-radius: 10px;
        padding: 10px;
      }

      #inner-box {
        margin: 5px;
        border: none;
        background-color: transparent;
      }

      #outer-box {
        margin: 5px;
        border: none;
        background-color: transparent;
      }

      #scroll {
        margin: 0px;
        border: none;
      }

      #entry {
        margin: 3px;
        border-radius: 10px;
        padding: 10px;
      }

      #entry:selected {
        background-color: #89b4fa;
        color: #1e1e2e;
      }

      #text {
        margin: 5px;
        border: none;
      }
    '';
  };
}
