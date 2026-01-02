# ============================================================
# GAMING - JOGOS (OPCIONAL)
# ============================================================
# Steam, Lutris, Wine, e otimizações para jogos.
# Descomente este módulo no flake.nix se quiser usar.
#
# Autor: Allan Farias

{ config, pkgs, lib, ... }:

{
  # ============================================================
  # STEAM
  # ============================================================
  
  programs.steam = {
    enable = true;
    
    # Gamemode para otimização
    gamescopeSession.enable = true;
    
    # Pacotes adicionais no ambiente Steam
    extraPackages = with pkgs; [
      # Compatibilidade de áudio
      pipewire
    ];
    
    # Hardware remoto
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # ============================================================
  # GAMEMODE
  # ============================================================
  
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        # Nvidia
        nv_powermizer_mode = 1;  # Prefer maximum performance
      };
    };
  };

  # ============================================================
  # GAMESCOPE
  # ============================================================
  
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # ============================================================
  # PACOTES DE GAMING
  # ============================================================
  
  environment.systemPackages = with pkgs; [
    # ----------------------
    # Launchers
    # ----------------------
    lutris              # Gerenciador de jogos
    heroic              # Epic Games, GOG
    bottles             # Wine simplificado
    
    # ----------------------
    # Wine
    # ----------------------
    wineWowPackages.staging
    winetricks
    
    # ----------------------
    # Proton
    # ----------------------
    protonup-qt         # Gerenciador de versões Proton
    
    # ----------------------
    # Otimização
    # ----------------------
    mangohud            # Overlay de FPS/stats
    goverlay            # GUI para MangoHud
    
    # ----------------------
    # Controllers
    # ----------------------
    antimicrox          # Mapear controle para teclado
    
    # ----------------------
    # Emuladores (opcional)
    # ----------------------
    # retroarch          # Multi-emulador
    # dolphin-emu        # GameCube/Wii
    # pcsx2              # PS2
    # rpcs3              # PS3
    # yuzu               # Switch
  ];

  # ============================================================
  # VARIÁVEIS PARA GAMING
  # ============================================================
  
  environment.sessionVariables = {
    # Steam Proton
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
    
    # Mangohud por padrão (opcional)
    # MANGOHUD = "1";
  };

  # ============================================================
  # KERNEL PARA GAMING
  # ============================================================
  
  # O kernel zen é melhor para gaming (opcional)
  # boot.kernelPackages = pkgs.linuxPackages_zen;

  # ============================================================
  # XPADNEO (CONTROLE XBOX)
  # ============================================================
  
  # Driver melhorado para controles Xbox
  # hardware.xpadneo.enable = true;

  # ============================================================
  # NOTAS GAMING
  # ============================================================
  #
  # 1. PROTON-GE:
  #    - Use protonup-qt para instalar versões GE
  #    - Geralmente tem melhor compatibilidade
  #
  # 2. MANGOHUD:
  #    - Ativar: mangohud %command% no Steam
  #    - Ou: MANGOHUD=1 game
  #
  # 3. GAMEMODE:
  #    - No Steam: gamemoderun %command%
  #    - Otimiza CPU e GPU durante jogo
  #
  # 4. GAMESCOPE:
  #    - Compositor para jogos
  #    - Melhora compatibilidade e permite upscaling
  #
  # 5. NVIDIA + GAMING:
  #    - Verifique VSync nas configurações
  #    - Use nvidia-settings para ajustes finos
  #
  # 6. ANTI-CHEAT:
  #    - Alguns anti-cheats não funcionam no Linux
  #    - Verifique protondb.com antes de comprar
}
