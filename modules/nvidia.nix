# ============================================================
# NVIDIA - CONFIGURAÇÃO DE DRIVERS
# ============================================================
# Configuração completa para GPUs Nvidia com suporte a:
# - Wayland/Hyprland
# - CUDA para IA/ML
# - Optimus para laptops híbridos
#
# Autor: Allan Farias

{ config, pkgs, lib, ... }:

{
  # ============================================================
  # DRIVERS NVIDIA
  # ============================================================
  
  # Carregar módulos Nvidia
  boot.initrd.kernelModules = [ "nvidia" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  # Habilitar driver Nvidia
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Modesetting é OBRIGATÓRIO para Wayland
    modesetting.enable = true;
    
    # Nvidia power management - experimental
    # Pode causar problemas de suspensão em alguns sistemas
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    
    # Usar driver open source (Turing+)
    # - true: drivers open source (RTX 20xx e mais recentes)
    # - false: drivers proprietários (mais estável)
    open = false;  # Mantenha false para melhor compatibilidade
    
    # Nvidia Settings GUI
    nvidiaSettings = true;
    
    # Versão do driver
    # Use 'stable' para produção, 'beta' para features mais recentes
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    
    # Alternativas de pacotes:
    # package = config.boot.kernelPackages.nvidiaPackages.beta;
    # package = config.boot.kernelPackages.nvidiaPackages.production;
    # package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
    
    # ============================================================
    # OPTIMUS / PRIME (LAPTOPS HÍBRIDOS)
    # ============================================================
    # Descomente esta seção se você tem um laptop com GPU
    # integrada Intel/AMD + Nvidia dedicada
    
    # prime = {
    #   # Modo de sincronização - ambas GPUs ativas
    #   sync.enable = true;
    #   
    #   # OU modo offload - Nvidia ativa sob demanda
    #   # offload = {
    #   #   enable = true;
    #   #   enableOffloadCmd = true;  # Adiciona comando nvidia-offload
    #   # };
    #   
    #   # OU modo reverse sync - para monitores externos
    #   # reverseSync.enable = true;
    #   
    #   # IDs dos barramentos PCI (encontre com: lspci | grep -E "VGA|3D")
    #   # Formato: "PCI:X:Y:Z" onde X:Y:Z são do lspci
    #   intelBusId = "PCI:0:2:0";    # GPU Intel integrada
    #   nvidiaBusId = "PCI:1:0:0";   # GPU Nvidia dedicada
    #   
    #   # Para AMD integrada:
    #   # amdgpuBusId = "PCI:6:0:0";
    # };
  };

  # ============================================================
  # VARIÁVEIS DE AMBIENTE PARA WAYLAND + NVIDIA
  # ============================================================
  
  environment.sessionVariables = {
    # Essencial para Wayland com Nvidia
    LIBVA_DRIVER_NAME = "nvidia";
    
    # Hardware cursors podem causar problemas
    WLR_NO_HARDWARE_CURSORS = "1";
    
    # GBM backend para Nvidia
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    
    # VSync e tearing
    __GL_GSYNC_ALLOWED = "1";
    __GL_VRR_ALLOWED = "1";
    
    # Electron apps em Wayland
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

  # ============================================================
  # PACOTES NVIDIA
  # ============================================================
  
  environment.systemPackages = with pkgs; [
    # Ferramentas de monitoramento
    nvtopPackages.nvidia   # Monitor de GPU no terminal
    
    # Vulkan
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
    
    # CUDA toolkit (para desenvolvimento)
    cudaPackages.cudatoolkit
    cudaPackages.cudnn
    
    # Video encode/decode
    nvidia-vaapi-driver
  ];

  # ============================================================
  # HARDWARE VIDEO ACCELERATION
  # ============================================================
  
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # ============================================================
  # NOTAS E TROUBLESHOOTING
  # ============================================================
  #
  # 1. TELA PRETA APÓS BOOT:
  #    - Adicione "nvidia-drm.fbdev=1" aos boot.kernelParams
  #    - Verifique se modesetting está habilitado
  #
  # 2. FLICKERING EM APPS ELECTRON:
  #    - Verifique se NIXOS_OZONE_WL=1 está definido
  #    - Pode ser necessário desabilitar VSync
  #
  # 3. SUSPENSÃO NÃO FUNCIONA:
  #    - Tente habilitar powerManagement.enable = true
  #    - Verifique se não há conflitos com TLP
  #
  # 4. CURSOR INVISÍVEL:
  #    - WLR_NO_HARDWARE_CURSORS=1 resolve
  #
  # 5. PERFORMANCE RUIM EM JOGOS:
  #    - Verifique se VSync está configurado corretamente
  #    - Use mangohud para monitorar FPS
}
