# ============================================================
# DEVELOPMENT - FERRAMENTAS DE DESENVOLVIMENTO
# ============================================================
# Linguagens, editores, ferramentas DevOps e mais.
#
# Autor: Allan Farias

{ config, pkgs, lib, ... }:

{
  # ============================================================
  # LINGUAGENS DE PROGRAMAÇÃO
  # ============================================================
  
  environment.systemPackages = with pkgs; [
    # ----------------------
    # Node.js / JavaScript
    # ----------------------
    nodejs_22         # Node.js LTS
    bun               # Runtime moderno (Bun)
    pnpm              # Gerenciador de pacotes
    yarn              # Alternativa
    deno              # Runtime seguro
    
    # TypeScript
    typescript
    nodePackages.ts-node
    
    # ----------------------
    # Python
    # ----------------------
    (python312.withPackages (ps: with ps; [
      pip
      virtualenv
      ipython
      jupyter
      numpy
      pandas
      matplotlib
      requests
      black          # Formatter
      pylint         # Linter
      pytest         # Testing
    ]))
    poetry           # Gerenciador de dependências
    uv               # Gerenciador moderno ultra-rápido
    
    # ----------------------
    # Rust
    # ----------------------
    rustup           # Toolchain manager
    # cargo
    # rustc
    # rustfmt
    # clippy
    
    # ----------------------
    # Go
    # ----------------------
    go
    gopls            # LSP
    golangci-lint    # Linter
    
    # ----------------------
    # C/C++
    # ----------------------
    gcc
    clang
    cmake
    gnumake
    ninja
    gdb              # Debugger
    valgrind         # Memory debugging
    
    # ----------------------
    # Java / Kotlin
    # ----------------------
    # jdk21
    # kotlin
    # gradle
    # maven
    
    # ----------------------
    # Outras Linguagens
    # ----------------------
    # lua
    # ruby
    # php
    # elixir
    # haskell

    # ============================================================
    # EDITORES E IDEs
    # ============================================================
    
    # ----------------------
    # Neovim (base para LazyVim)
    # ----------------------
    neovim
    
    # Dependências para Neovim/LazyVim
    tree-sitter
    luajit
    luajitPackages.luarocks
    
    # ----------------------
    # Zed Editor
    # ----------------------
    zed-editor
    
    # ----------------------
    # VSCode (opcional)
    # ----------------------
    # vscode
    # vscode-fhs      # Para extensões que precisam de FHS
    
    # ----------------------
    # Antigravity (Google)
    # ----------------------
    # NOTA: Antigravity não está disponível no nixpkgs ainda
    # Use Flatpak se disponível, ou aguarde inclusão
    # flatpak install flathub com.google.antigravity
    
    # ============================================================
    # FERRAMENTAS DE DESENVOLVIMENTO
    # ============================================================
    
    # ----------------------
    # Git
    # ----------------------
    git
    git-lfs
    gh               # GitHub CLI
    lazygit          # Git TUI
    delta            # Diff viewer
    
    # ----------------------
    # LSPs e Formatters
    # ----------------------
    # JavaScript/TypeScript
    nodePackages.typescript-language-server
    nodePackages.prettier
    nodePackages.eslint
    
    # Python
    pyright
    ruff             # Linter rápido
    
    # Lua
    lua-language-server
    stylua
    
    # Nix
    nil              # LSP Nix
    nixpkgs-fmt      # Formatter
    statix           # Linter
    
    # JSON/YAML
    nodePackages.yaml-language-server
    nodePackages.vscode-json-languageserver
    
    # Shell
    shellcheck
    shfmt
    
    # Markdown
    marksman
    
    # Docker/Compose
    docker-compose-language-service
    dockerfile-language-server-nodejs
    
    # ----------------------
    # Debugging
    # ----------------------
    lldb
    gef              # GDB Enhanced
    
    # ============================================================
    # CONTAINERS E ORQUESTRAÇÃO
    # ============================================================
    
    # ----------------------
    # Podman (preferido)
    # ----------------------
    podman
    podman-compose
    podman-tui
    
    # Docker CLI (para compatibilidade)
    docker-client
    docker-compose
    
    # Container tools
    dive             # Inspecionar imagens
    skopeo           # Gerenciar imagens
    buildah          # Build de imagens
    
    # ----------------------
    # Kubernetes
    # ----------------------
    kubectl
    kubernetes-helm
    k9s              # TUI para K8s
    minikube
    kind             # K8s in Docker
    
    # ============================================================
    # DATABASES
    # ============================================================
    
    # CLI clients
    postgresql_16
    sqlite
    redis
    
    # GUI clients
    dbeaver-bin      # Universal database GUI
    
    # ============================================================
    # CLOUD E INFRA
    # ============================================================
    
    # AWS
    awscli2
    
    # Terraform/OpenTofu
    opentofu
    terraform
    
    # Ansible
    ansible
    ansible-lint
    
    # ============================================================
    # APIs E NETWORKING
    # ============================================================
    
    httpie           # HTTP client moderno
    curl
    wget
    jq               # JSON processor
    yq               # YAML processor
    websocat         # WebSocket client
    grpcurl          # gRPC client
    
    # API GUI
    insomnia         # REST client
    # postman        # Usar Flatpak

    # ============================================================
    # FERRAMENTAS ÚTEIS
    # ============================================================
    
    direnv           # Ambiente por diretório
    nix-direnv       # Integração Nix
    watchexec        # Watch files and run commands
    just             # Command runner
    hyperfine        # Benchmarking
    tokei            # Count lines of code
    difftastic       # Structural diff
    tealdeer         # tldr pages
  ];

  # ============================================================
  # PROGRAMAS ESPECIAIS
  # ============================================================
  
  # Direnv para carregar .envrc automaticamente
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # ============================================================
  # SERVIÇOS DE DESENVOLVIMENTO
  # ============================================================
  
  # Docker (alternativa ao Podman - escolha um)
  # virtualisation.docker = {
  #   enable = true;
  #   enableOnBoot = false;
  # };

  # ============================================================
  # VARIÁVEIS DE AMBIENTE
  # ============================================================
  
  environment.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    
    # Rust
    RUSTUP_HOME = "$HOME/.rustup";
    CARGO_HOME = "$HOME/.cargo";
    
    # Go
    GOPATH = "$HOME/go";
    
    # Bun
    BUN_INSTALL = "$HOME/.bun";
  };

  # Path adicional
  environment.extraInit = ''
    export PATH="$HOME/.cargo/bin:$HOME/go/bin:$HOME/.bun/bin:$PATH"
  '';
}
