# ============================================================
# CONFIGURAÇÃO DE HARDWARE - TEMPLATE
# ============================================================
# Este arquivo é um TEMPLATE. Na instalação real, NixOS gera
# este arquivo automaticamente com:
#   sudo nixos-generate-config
#
# Copie o arquivo gerado para cá e ajuste conforme necessário.
# O arquivo abaixo é um exemplo genérico.

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # ============================================================
  # MÓDULOS DO KERNEL
  # ============================================================
  
  boot.initrd.availableKernelModules = [ 
    "xhci_pci" 
    "ahci" 
    "nvme" 
    "usb_storage" 
    "sd_mod" 
    "rtsx_pci_sdmmc" 
  ];
  
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];  # Use kvm-amd para AMD
  boot.extraModulePackages = [ ];

  # ============================================================
  # SISTEMA DE ARQUIVOS
  # ============================================================
  # IMPORTANTE: Ajuste os UUIDs/labels para seu sistema!
  # Use: lsblk -f para ver seus dispositivos
  
  # Partição raiz (/)
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";  # ou by-uuid
    fsType = "ext4";  # ou btrfs, xfs
    # Opções para btrfs:
    # options = [ "subvol=@" "compress=zstd" "noatime" ];
  };

  # Partição boot EFI
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  # Partição home (opcional - pode estar na raiz)
  # fileSystems."/home" = {
  #   device = "/dev/disk/by-label/home";
  #   fsType = "ext4";
  # };

  # Swap (partição ou arquivo)
  swapDevices = [
    # { device = "/dev/disk/by-label/swap"; }
    # ou swap file:
    # { device = "/swapfile"; size = 8192; }  # 8GB
  ];

  # ============================================================
  # HARDWARE ESPECÍFICO
  # ============================================================
  
  # Detectar automaticamente novos dispositivos
  hardware.enableRedistributableFirmware = true;
  
  # CPU Microcode (descomente o apropriado)
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # ============================================================
  # GRÁFICOS BASE
  # ============================================================
  
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # ============================================================
  # BLUETOOTH
  # ============================================================
  
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };
  
  services.blueman.enable = true;

  # ============================================================
  # ENERGY / POWER
  # ============================================================
  
  # Para laptops
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "powersave";
  };

  # ============================================================
  # NOTA IMPORTANTE
  # ============================================================
  # Após gerar sua configuração real com nixos-generate-config,
  # substitua este arquivo pelo gerado. Mantenha apenas as
  # customizações que você adicionou (bluetooth, graphics, etc.)
}
