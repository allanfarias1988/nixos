# ============================================================
# CONTENT CREATION - VÍDEO, ÁUDIO, IMAGEM
# ============================================================
# Ferramentas profissionais para criação de conteúdo.
#
# Autor: Allan Farias

{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # ============================================================
    # EDIÇÃO DE VÍDEO
    # ============================================================
    
    # ----------------------
    # DaVinci Resolve
    # ----------------------
    # NOTA: Versão gratuita tem limitações de codec
    # Para H.264/H.265, converta antes com FFmpeg
    davinci-resolve
    # davinci-resolve-studio  # Versão paga (precisa de licença)
    
    # ----------------------
    # Kdenlive
    # ----------------------
    # Editor open source completo
    kdenlive
    
    # ----------------------
    # Shotcut
    # ----------------------
    # Alternativa mais leve
    shotcut
    
    # ----------------------
    # OpenShot
    # ----------------------
    # Simples e intuitivo
    # openshot-qt
    
    # ============================================================
    # STREAMING E GRAVAÇÃO
    # ============================================================
    
    # ----------------------
    # OBS Studio
    # ----------------------
    (wrapOBS {
      plugins = with obs-studio-plugins; [
        wlrobs                    # Captura Wayland
        obs-pipewire-audio-capture  # Captura áudio PipeWire
        obs-vkcapture             # Captura Vulkan/OpenGL
        obs-backgroundremoval     # Remoção de fundo
        obs-move-transition       # Transições animadas
        # obs-ndi                  # NDI streaming
      ];
    })
    
    # ============================================================
    # EDIÇÃO DE ÁUDIO
    # ============================================================
    
    # ----------------------
    # Ardour
    # ----------------------
    # DAW profissional open source
    ardour
    
    # ----------------------
    # Audacity
    # ----------------------
    # Editor simples e poderoso
    audacity
    
    # ----------------------
    # REAPER (pago)
    # ----------------------
    # DAW profissional (trial gratuito)
    reaper
    
    # ----------------------
    # LMMS
    # ----------------------
    # Produção musical (gratuito)
    lmms
    
    # ----------------------
    # Carla
    # ----------------------
    # Host de plugins (VST, LV2, etc)
    carla
    
    # ----------------------
    # Plugins de Áudio
    # ----------------------
    # LV2 plugins
    calf                      # Suite de plugins
    lsp-plugins               # Plugins profissionais
    x42-plugins               # Meters e analyzers
    
    # Sintetizadores
    surge-XT                  # Synth poderoso
    vital                     # Wavetable synth
    
    # Efeitos
    dragonfly-reverb
    guitarix                  # Amp simulation
    
    # ============================================================
    # EDIÇÃO DE IMAGEM
    # ============================================================
    
    # ----------------------
    # GIMP
    # ----------------------
    # Equivalente ao Photoshop
    gimp
    
    # ----------------------
    # Krita
    # ----------------------
    # Pintura digital
    krita
    
    # ----------------------
    # Inkscape
    # ----------------------
    # Editor vetorial (SVG)
    inkscape
    
    # ----------------------
    # Darktable
    # ----------------------
    # Revelação RAW / Lightroom alternative
    darktable
    
    # ----------------------
    # RawTherapee
    # ----------------------
    # Alternativa para RAW
    rawtherapee
    
    # ============================================================
    # 3D E ANIMAÇÃO
    # ============================================================
    
    # ----------------------
    # Blender
    # ----------------------
    # Suite completa de 3D
    blender
    
    # ----------------------
    # FreeCAD
    # ----------------------
    # CAD paramétrico
    # freecad
    
    # ----------------------
    # OpenSCAD
    # ----------------------
    # CAD programático
    # openscad
    
    # ============================================================
    # FERRAMENTAS DE MÍDIA
    # ============================================================
    
    # ----------------------
    # FFmpeg
    # ----------------------
    # Conversão e processamento
    ffmpeg-full
    
    # ----------------------
    # Handbrake
    # ----------------------
    # Transcoding com GUI
    handbrake
    
    # ----------------------
    # VLC
    # ----------------------
    # Player universal
    vlc
    
    # ----------------------
    # mpv
    # ----------------------
    # Player minimalista
    mpv
    
    # ----------------------
    # ImageMagick
    # ----------------------
    # Processamento de imagens CLI
    imagemagick
    
    # ----------------------
    # Upscayl
    # ----------------------
    # AI upscaling de imagens
    upscayl
    
    # ============================================================
    # UTILITÁRIOS
    # ============================================================
    
    # Gerenciamento de cores
    displaycal
    
    # Gravação de tela simples
    kooha
    
    # Captura de screenshots avançada
    flameshot
    
    # Visualizador de imagens
    loupe            # GNOME viewer
    imv              # Minimal viewer
    
    # Metadata
    exiftool
    mat2             # Remover metadata
  ];

  # ============================================================
  # SERVIÇOS DE ÁUDIO
  # ============================================================
  
  # Já configurado no configuration.nix, mas garantindo:
  services.pipewire = {
    enable = true;
    jack.enable = true;  # Para DAWs
  };

  # ============================================================
  # VARIÁVEIS PARA PLUGINS DE ÁUDIO
  # ============================================================
  
  environment.sessionVariables = {
    # Caminhos para plugins
    LV2_PATH = "$HOME/.lv2:/run/current-system/sw/lib/lv2";
    VST_PATH = "$HOME/.vst:/run/current-system/sw/lib/vst";
    VST3_PATH = "$HOME/.vst3:/run/current-system/sw/lib/vst3";
    LADSPA_PATH = "$HOME/.ladspa:/run/current-system/sw/lib/ladspa";
  };

  # ============================================================
  # NOTAS CONTENT CREATION
  # ============================================================
  #
  # 1. DAVINCI RESOLVE:
  #    - Versão gratuita não suporta H.264/H.265 nativamente
  #    - Converta vídeos antes:
  #      ffmpeg -i input.mp4 -c:v dnxhd -profile:v dnxhr_hq -pix_fmt yuv422p output.mov
  #
  # 2. OBS + WAYLAND:
  #    - Use wlrobs para captura de tela
  #    - PipeWire capture para áudio
  #
  # 3. PLUGINS VST WINDOWS:
  #    - Use yabridge para rodar VSTs Windows via Wine
  #    - yabridgectl sync após adicionar plugins
  #
  # 4. BLENDER + CUDA:
  #    - Certifique-se que cudaSupport está habilitado
  #    - Nas preferências, habilite CUDA em System > Cycles Render Devices
}
