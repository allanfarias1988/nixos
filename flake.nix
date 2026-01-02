{
  description = "Configuração NixOS Completa - Allan Farias";

  inputs = {
    # Nixpkgs - canal principal
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Home Manager - configuração do usuário
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland - compositor Wayland
    hyprland.url = "github:hyprwm/Hyprland";

    # Hyprland plugins
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    # Nixvim - Neovim gerenciado por Nix
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Stylix - temas consistentes (opcional)
    stylix.url = "github:danth/stylix";

    # Nix-colors - paletas de cores
    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, nixvim, stylix, nix-colors, ... }@inputs:
  let
    system = "x86_64-linux";
    
    # Configurações globais do nixpkgs
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;         # Permitir pacotes proprietários (Nvidia, etc.)
        cudaSupport = true;          # Habilitar suporte CUDA
        permittedInsecurePackages = [
          # Adicione aqui pacotes inseguros se necessário
        ];
      };
    };

    # Usuário padrão
    username = "allan";
    
  in {
    # ============================================================
    # CONFIGURAÇÕES NIXOS POR HOST
    # ============================================================
    # Para adicionar um novo host, copie o bloco abaixo e ajuste:
    # 1. O nome do host (ex: "nixos-desktop")
    # 2. Os módulos importados (ex: remover nvidia.nix para AMD)
    # 3. O hardware-configuration.nix específico da máquina
    
    nixosConfigurations = {
      # Host principal - Notebook com Nvidia
      "nixos-workstation" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username; };
        modules = [
          # Configuração base do sistema
          ./configuration.nix
          
          # Hardware específico (gerado por nixos-generate-config)
          ./hardware-configuration.nix
          
          # Módulos do sistema
          ./modules/nvidia.nix
          # ./modules/amd.nix         # Descomente para AMD
          ./modules/hyprland.nix
          ./modules/development.nix
          ./modules/content-creation.nix
          ./modules/ai-ml.nix
          ./modules/desktop-apps.nix
          ./modules/printing.nix
          # ./modules/gaming.nix      # Descomente para gaming

          # Home Manager como módulo NixOS
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs username nix-colors; };
              users.${username} = import ./home;
            };
          }

          # Stylix para temas (opcional)
          # stylix.nixosModules.stylix
        ];
      };

      # ============================================================
      # EXEMPLO: Desktop com AMD (descomente e ajuste)
      # ============================================================
      # "nixos-desktop" = nixpkgs.lib.nixosSystem {
      #   inherit system;
      #   specialArgs = { inherit inputs username; };
      #   modules = [
      #     ./configuration.nix
      #     ./hosts/desktop/hardware-configuration.nix
      #     ./modules/amd.nix
      #     ./modules/hyprland.nix
      #     ./modules/development.nix
      #     ./modules/content-creation.nix
      #     ./modules/ai-ml.nix
      #     ./modules/desktop-apps.nix
      #     ./modules/printing.nix
      #     ./modules/gaming.nix
      #     home-manager.nixosModules.home-manager
      #     {
      #       home-manager = {
      #         useGlobalPkgs = true;
      #         useUserPackages = true;
      #         extraSpecialArgs = { inherit inputs username nix-colors; };
      #         users.${username} = import ./home;
      #       };
      #     }
      #   ];
      # };
    };

    # ============================================================
    # CONFIGURAÇÕES HOME-MANAGER STANDALONE
    # ============================================================
    # Útil para usar em outras distros Linux ou macOS
    
    homeConfigurations = {
      "${username}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs username nix-colors; };
        modules = [
          ./home
          nixvim.homeManagerModules.nixvim
        ];
      };
    };
  };
}
