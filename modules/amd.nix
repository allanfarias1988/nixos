# ============================================================
# AMD - CONFIGURAÇÃO DE DRIVERS (ALTERNATIVA)
# ============================================================
# Configuração para GPUs AMD com suporte a:
# - AMDGPU (open source)
# - Vulkan
# - ROCm para compute
#
# Autor: Allan Farias
#
# NOTA: Este módulo NÃO deve ser usado junto com nvidia.nix

{ config, pkgs, lib, ... }:

{
  # ============================================================
  # DRIVERS AMD
  # ============================================================
  
  # Driver AMDGPU
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Carregar módulos
  boot.initrd.kernelModules = [ "amdgpu" ];

  # ============================================================
  # HARDWARE VIDEO ACCELERATION
  # ============================================================
  
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      # AMD VA-API
      amdvlk
      rocmPackages.clr.icd
      
      # Decode de vídeo
      libvdpau-va-gl
      vaapiVdpau
    ];
    extraPackages32 = with pkgs.driversi686Linux; [
      amdvlk
    ];
  };

  # ============================================================
  # VARIÁVEIS DE AMBIENTE
  # ============================================================
  
  environment.sessionVariables = {
    # AMD Vulkan driver
    AMD_VULKAN_ICD = "RADV";
    
    # VA-API driver
    LIBVA_DRIVER_NAME = "radeonsi";
  };

  # ============================================================
  # PACOTES AMD
  # ============================================================
  
  environment.systemPackages = with pkgs; [
    # Ferramentas de monitoramento
    nvtopPackages.amd   # Monitor de GPU
    radeontop            # Top específico AMD
    
    # Vulkan
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
    
    # ROCm para compute (equivalente CUDA)
    # rocmPackages.rocm-runtime
    # rocmPackages.rocm-smi
  ];

  # ============================================================
  # ROCm (COMPUTE - OPCIONAL)
  # ============================================================
  # Descomente para suporte a ROCm (PyTorch, TensorFlow com AMD)
  
  # hardware.amdgpu = {
  #   opencl.enable = true;
  #   amdvlk = {
  #     enable = true;
  #     support32Bit.enable = true;
  #   };
  # };
  
  # systemd.tmpfiles.rules = [
  #   "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  # ];

  # ============================================================
  # OVERCLOCKING AMD (OPCIONAL)
  # ============================================================
  # Descomente para permitir controle de performance
  
  # boot.kernelParams = [
  #   "amdgpu.ppfeaturemask=0xffffffff"
  # ];

  # ============================================================
  # NOTAS AMD
  # ============================================================
  #
  # 1. FAMÍLIA DE GPU:
  #    - GCN 1-4: amdgpu suportado mas limitado
  #    - RDNA 1+: suporte completo
  #    - RDNA 2+: ray tracing via Vulkan
  #
  # 2. ROCM:
  #    - Suportado em GPUs Vega e mais recentes
  #    - Verifique compatibilidade: https://rocm.docs.amd.com
  #
  # 3. WAYLAND:
  #    - AMD tem melhor suporte a Wayland que Nvidia
  #    - Geralmente funciona sem configuração extra
}
