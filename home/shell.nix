# ============================================================
# SHELL - ZSH + STARSHIP
# ============================================================
# Configuração de shell com Zsh, Starship prompt e plugins.
#
# Autor: Allan Farias

{ config, pkgs, lib, ... }:

{
  # ============================================================
  # ZSH
  # ============================================================
  
  programs.zsh = {
    enable = true;
    
    # Diretório de configuração
    dotDir = ".config/zsh";
    
    # Histórico
    history = {
      size = 50000;
      save = 50000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      share = true;
    };
    
    # Auto-complete
    enableCompletion = true;
    
    # Syntax highlighting
    syntaxHighlighting.enable = true;
    
    # Auto-suggestions
    autosuggestion.enable = true;
    
    # Opções do shell
    initExtraFirst = ''
      # Emacs-style keybindings
      bindkey -e
      
      # Melhor navegação por palavras
      bindkey '^[[1;5C' forward-word     # Ctrl+Right
      bindkey '^[[1;5D' backward-word    # Ctrl+Left
      bindkey '^H' backward-kill-word    # Ctrl+Backspace
      bindkey '^[[3;5~' kill-word        # Ctrl+Delete
    '';
    
    initExtra = ''
      # ========================================================
      # ALIASES
      # ========================================================
      
      # Navegação
      alias ..='cd ..'
      alias ...='cd ../..'
      alias ....='cd ../../..'
      
      # Listagem (usando eza)
      alias ls='eza --icons --group-directories-first'
      alias ll='eza -la --icons --group-directories-first'
      alias la='eza -a --icons --group-directories-first'
      alias lt='eza --tree --icons --level=2'
      alias l='eza -l --icons --group-directories-first'
      
      # Git
      alias g='git'
      alias gs='git status'
      alias ga='git add'
      alias gc='git commit'
      alias gp='git push'
      alias gl='git pull'
      alias gd='git diff'
      alias gco='git checkout'
      alias gb='git branch'
      alias lg='lazygit'
      
      # Editor
      alias v='nvim'
      alias vim='nvim'
      
      # NixOS
      alias nrs='sudo nixos-rebuild switch --flake .'
      alias nrb='sudo nixos-rebuild boot --flake .'
      alias nrt='sudo nixos-rebuild test --flake .'
      alias nu='nix flake update'
      alias nc='nix-collect-garbage -d'
      alias nsc='sudo nix-collect-garbage -d'
      
      # Sistema
      alias cat='bat'
      alias grep='grep --color=auto'
      alias df='df -h'
      alias du='du -h'
      alias free='free -h'
      
      # Docker/Podman
      alias d='podman'
      alias dc='podman-compose'
      alias dps='podman ps'
      alias dpsa='podman ps -a'
      
      # Python
      alias py='python3'
      alias pip='pip3'
      alias venv='python3 -m venv'
      
      # Misc
      alias c='clear'
      alias h='history'
      alias reload='source ~/.config/zsh/.zshrc'
      
      # ========================================================
      # FUNÇÕES
      # ========================================================
      
      # Criar diretório e entrar
      mkcd() {
        mkdir -p "$1" && cd "$1"
      }
      
      # Extrair arquivos
      extract() {
        if [ -f "$1" ]; then
          case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "Não sei extrair '$1'" ;;
          esac
        else
          echo "'$1' não é um arquivo válido"
        fi
      }
      
      # ========================================================
      # INICIALIZAÇÃO
      # ========================================================
      
      # Zoxide (cd inteligente)
      eval "$(zoxide init zsh)"
      
      # Direnv
      eval "$(direnv hook zsh)"
      
      # Bun
      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"
      
      # Cargo
      export PATH="$HOME/.cargo/bin:$PATH"
      
      # Local bin
      export PATH="$HOME/.local/bin:$PATH"
    '';

    # Plugins via oh-my-zsh
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "docker"
        "kubectl"
        "command-not-found"
        "colored-man-pages"
      ];
    };
  };

  # ============================================================
  # STARSHIP PROMPT
  # ============================================================
  
  programs.starship = {
    enable = true;
    
    settings = {
      # Formato geral
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_status"
        "$git_state"
        "$nodejs"
        "$python"
        "$rust"
        "$golang"
        "$lua"
        "$nix_shell"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];
      
      # Prompt à direita
      right_format = "$time";
      
      add_newline = true;
      
      # Caractere do prompt
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold green)";
      };
      
      # Diretório
      directory = {
        style = "bold cyan";
        truncation_length = 4;
        truncate_to_repo = true;
        read_only = " 󰌾";
      };
      
      # Git
      git_branch = {
        symbol = " ";
        style = "bold purple";
      };
      
      git_status = {
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
        style = "bold red";
        conflicted = "⚔";
        ahead = "⇡$count";
        behind = "⇣$count";
        diverged = "⇕";
        untracked = "?$count";
        stashed = "📦";
        modified = "!$count";
        staged = "+$count";
        deleted = "✗$count";
      };
      
      # Linguagens
      nodejs = {
        symbol = " ";
        style = "bold green";
      };
      
      python = {
        symbol = " ";
        style = "bold yellow";
        pyenv_version_name = true;
      };
      
      rust = {
        symbol = " ";
        style = "bold orange";
      };
      
      golang = {
        symbol = " ";
        style = "bold cyan";
      };
      
      lua = {
        symbol = " ";
        style = "bold blue";
      };
      
      nix_shell = {
        symbol = " ";
        style = "bold blue";
        format = "via [$symbol$state( \\($name\\))]($style) ";
      };
      
      # Tempo de comando
      cmd_duration = {
        min_time = 2000;
        format = "took [$duration](bold yellow) ";
      };
      
      # Hora
      time = {
        disabled = false;
        format = "[$time](dimmed white)";
        time_format = "%H:%M";
      };
      
      # Username (mostra apenas se necessário)
      username = {
        show_always = false;
        format = "[$user]($style)@";
        style_user = "bold blue";
        style_root = "bold red";
      };
      
      hostname = {
        ssh_only = true;
        format = "[$hostname]($style) in ";
        style = "bold green";
      };
    };
  };

  # ============================================================
  # FZF - FUZZY FINDER
  # ============================================================
  
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
      "--preview 'bat --style=numbers --color=always --line-range :500 {}'"
    ];
    
    # Catppuccin theme
    colors = {
      "bg+" = "#313244";
      "bg" = "#1e1e2e";
      "spinner" = "#f5e0dc";
      "hl" = "#f38ba8";
      "fg" = "#cdd6f4";
      "header" = "#f38ba8";
      "info" = "#cba6f7";
      "pointer" = "#f5e0dc";
      "marker" = "#f5e0dc";
      "fg+" = "#cdd6f4";
      "prompt" = "#cba6f7";
      "hl+" = "#f38ba8";
    };
  };

  # ============================================================
  # KITTY TERMINAL
  # ============================================================
  
  programs.kitty = {
    enable = true;
    
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };
    
    settings = {
      # Visual
      background_opacity = "0.95";
      window_padding_width = 10;
      confirm_os_window_close = 0;
      
      # Cursor
      cursor_shape = "beam";
      cursor_blink_interval = 0.5;
      
      # URLs
      url_style = "curly";
      open_url_with = "default";
      
      # Bell
      enable_audio_bell = false;
      visual_bell_duration = "0.0";
      
      # Tabs
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      
      # Catppuccin Mocha theme
      foreground = "#CDD6F4";
      background = "#1E1E2E";
      selection_foreground = "#1E1E2E";
      selection_background = "#F5E0DC";
      cursor = "#F5E0DC";
      cursor_text_color = "#1E1E2E";
      url_color = "#F5E0DC";
      active_border_color = "#B4BEFE";
      inactive_border_color = "#6C7086";
      bell_border_color = "#F9E2AF";
      active_tab_foreground = "#11111B";
      active_tab_background = "#CBA6F7";
      inactive_tab_foreground = "#CDD6F4";
      inactive_tab_background = "#181825";
      tab_bar_background = "#11111B";
      
      # Colors
      color0 = "#45475A";
      color1 = "#F38BA8";
      color2 = "#A6E3A1";
      color3 = "#F9E2AF";
      color4 = "#89B4FA";
      color5 = "#F5C2E7";
      color6 = "#94E2D5";
      color7 = "#BAC2DE";
      color8 = "#585B70";
      color9 = "#F38BA8";
      color10 = "#A6E3A1";
      color11 = "#F9E2AF";
      color12 = "#89B4FA";
      color13 = "#F5C2E7";
      color14 = "#94E2D5";
      color15 = "#A6ADC8";
    };

    keybindings = {
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+w" = "close_tab";
      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+left" = "previous_tab";
      "ctrl+shift+plus" = "change_font_size all +2.0";
      "ctrl+shift+minus" = "change_font_size all -2.0";
      "ctrl+shift+0" = "change_font_size all 0";
    };
  };

  # ============================================================
  # PACOTES DE SHELL
  # ============================================================
  
  home.packages = with pkgs; [
    # Utilitários de shell
    zoxide            # cd inteligente
    fzf               # Fuzzy finder
    bat               # cat melhorado
    eza               # ls melhorado
    ripgrep           # grep rápido
    fd                # find rápido
    delta             # diff melhorado
    
    # Ferramentas
    htop
    btop
    neofetch
    fastfetch
  ];
}
