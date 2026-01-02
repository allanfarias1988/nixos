# ============================================================
# PRINTING - IMPRESSORAS E SCANNERS
# ============================================================
# Suporte completo para impressoras e scanners Epson, HP, Brother.
#
# Autor: Allan Farias

{ config, pkgs, lib, ... }:

{
  # ============================================================
  # CUPS - SERVIÇO DE IMPRESSÃO
  # ============================================================
  
  services.printing = {
    enable = true;
    
    # Drivers de impressora
    drivers = with pkgs; [
      # ----------------------
      # Drivers Genéricos
      # ----------------------
      gutenprint          # Drivers open source para muitas marcas
      gutenprintBin       # Binários adicionais
      
      # ----------------------
      # HP
      # ----------------------
      hplip               # HP Linux Imaging and Printing
      hplipWithPlugin     # Com plugin proprietário (mais impressoras)
      
      # ----------------------
      # Epson
      # ----------------------
      epson-escpr         # Driver ESC/P-R (jato de tinta)
      epson-escpr2        # Driver ESC/P-R2 (modelos mais novos)
      
      # ----------------------
      # Brother
      # ----------------------
      # Binários proprietários
      brlaser             # Driver laser Brother genérico
      brgenml1lpr         # Brother laser printers
      brgenml1cupswrapper
      
      # ----------------------
      # Canon (opcional)
      # ----------------------
      # cnijfilter2
      
      # ----------------------
      # Samsung/Xerox (opcional)
      # ----------------------
      # splix
    ];
    
    # Descoberta automática de impressoras
    browsing = true;
    
    # Interface web do CUPS
    # Acesse http://localhost:631
    listenAddresses = [ "localhost:631" ];
    allowFrom = [ "all" ];
    defaultShared = false;
  };

  # ============================================================
  # AVAHI - DESCOBERTA DE REDE
  # ============================================================
  
  services.avahi = {
    enable = true;
    nssmdns4 = true;         # Resolução .local
    
    # Descoberta de impressoras na rede
    publish = {
      enable = true;
      userServices = true;
    };
    
    openFirewall = true;
  };

  # ============================================================
  # SCANNERS - SANE
  # ============================================================
  
  hardware.sane = {
    enable = true;
    
    extraBackends = with pkgs; [
      # ----------------------
      # Epson
      # ----------------------
      epkowa              # Epson scanners (iscan)
      utsushi             # Epson scanners modernos
      
      # ----------------------
      # HP
      # ----------------------
      hplipWithPlugin     # HP scanners
      
      # ----------------------
      # Genérico
      # ----------------------
      sane-airscan        # Scanning via rede (IPP, eSCL, WSD)
    ];
    
    # Backends desabilitados (se causar lentidão)
    # disabledDefaultBackends = [ "escl" ];
  };

  # ============================================================
  # PACOTES DE SCANNER
  # ============================================================
  
  environment.systemPackages = with pkgs; [
    # ----------------------
    # GUI para Scanner
    # ----------------------
    gnome.simple-scan       # GNOME Scanner (simples)
    xsane                   # Avançado
    
    # ----------------------
    # CLI
    # ----------------------
    sane-backends
    
    # ----------------------
    # Ferramentas HP
    # ----------------------
    hplip                   # hp-setup, hp-scan, etc.
    
    # ----------------------
    # OCR
    # ----------------------
    tesseract               # OCR engine
    gimagereader            # GUI para OCR
  ];

  # ============================================================
  # GRUPOS DE USUÁRIO
  # ============================================================
  # Adicionados no configuration.nix, mas garantindo:
  
  # O usuário precisa estar nos grupos:
  # - lp: Para impressão
  # - scanner: Para digitalização
  
  # Já configurado em configuration.nix:
  # users.users.allan.extraGroups = [ ... "scanner" "lp" ... ];

  # ============================================================
  # UDEV RULES
  # ============================================================
  
  # Regras para scanners USB
  services.udev.packages = with pkgs; [
    sane-backends
  ];

  # ============================================================
  # NOTAS IMPRESSÃO/SCANNER
  # ============================================================
  #
  # 1. CONFIGURAR IMPRESSORA:
  #    - Acesse: http://localhost:631
  #    - Administration > Add Printer
  #    - Ou use o utilitário da marca (hp-setup, etc.)
  #
  # 2. HP COM PLUGIN:
  #    - Execute: sudo hp-setup -i
  #    - O plugin será baixado automaticamente
  #
  # 3. IMPRESSORA NA REDE:
  #    - Deve ser descoberta automaticamente via Avahi
  #    - Ou adicione manualmente com IP: ipp://192.168.x.x/ipp
  #
  # 4. TESTAR SCANNER:
  #    - Liste scanners: scanimage -L
  #    - Scan teste: scanimage --test
  #    - GUI: simple-scan
  #
  # 5. SCANNER NA REDE:
  #    - sane-airscan descobre automaticamente
  #    - Configure em /etc/sane.d/airscan.conf se necessário
  #
  # 6. BROTHER:
  #    - Alguns modelos precisam de drivers do site oficial
  #    - https://support.brother.com/g/b/downloadtop.aspx
  #    - Use nix-shell -p dpkg para extrair e instalar
  #
  # 7. TROUBLESHOOTING:
  #    - Logs CUPS: journalctl -u cups
  #    - Status: systemctl status cups
  #    - Reiniciar: sudo systemctl restart cups
}
