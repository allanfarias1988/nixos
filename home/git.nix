# ============================================================
# GIT - CONFIGURAÇÃO
# ============================================================
# Configuração do Git com delta para diffs bonitos.
#
# Autor: Allan Farias

{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;
    
    # Identidade
    userName = "Allan Farias";
    userEmail = "allan.digitaltec@gmail.com"; # TODO: Altere para seu email
    
    # Configurações globais
    extraConfig = {
      # Core
      core = {
        editor = "nvim";
        autocrlf = "input";
        whitespace = "fix";
      };
      
      # Init
      init = {
        defaultBranch = "main";
      };
      
      # Pull
      pull = {
        rebase = true;
      };
      
      # Merge
      merge = {
        conflictstyle = "diff3";
      };
      
      # Diff
      diff = {
        colorMoved = "default";
      };
      
      # Fetch
      fetch = {
        prune = true;
      };
      
      # Rebase
      rebase = {
        autoStash = true;
      };
      
      # Push
      push = {
        autoSetupRemote = true;
        default = "current";
      };
      
      # Credential
      credential = {
        helper = "store";
      };
      
      # URL shortcuts
      url = {
        "git@github.com:" = {
          insteadOf = "gh:";
        };
        "git@gitlab.com:" = {
          insteadOf = "gl:";
        };
      };
    };
    
    # Aliases
    aliases = {
      # Status
      s = "status -sb";
      st = "status";
      
      # Branches
      br = "branch";
      co = "checkout";
      sw = "switch";
      nb = "checkout -b";
      
      # Commits
      c = "commit";
      cm = "commit -m";
      ca = "commit --amend";
      can = "commit --amend --no-edit";
      
      # Add
      a = "add";
      aa = "add -A";
      ap = "add -p";
      
      # Push/Pull
      p = "push";
      pf = "push --force-with-lease";
      pl = "pull";
      
      # Log
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      ll = "log --oneline -20";
      last = "log -1 HEAD --stat";
      
      # Diff
      d = "diff";
      ds = "diff --staged";
      
      # Reset
      unstage = "reset HEAD --";
      undo = "reset --soft HEAD~1";
      
      # Stash
      ss = "stash save";
      sp = "stash pop";
      sl = "stash list";
      
      # Others
      aliases = "config --get-regexp alias";
      cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master' | xargs -n 1 git branch -d";
      
      # Worktree
      wt = "worktree";
    };
    
    # Ignorar globalmente
    ignores = [
      # Sistema
      ".DS_Store"
      "Thumbs.db"
      "Desktop.ini"
      
      # IDE
      ".idea/"
      ".vscode/"
      "*.swp"
      "*.swo"
      "*~"
      
      # Node
      "node_modules/"
      
      # Python
      "__pycache__/"
      "*.pyc"
      ".env"
      "venv/"
      
      # Build
      "dist/"
      "build/"
      "target/"
      
      # Logs
      "*.log"
      "logs/"
      
      # Temp
      "tmp/"
      ".tmp/"
    ];
    
    # Delta para diffs bonitos
    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
        side-by-side = true;
        syntax-theme = "Catppuccin-mocha";
        
        # Catppuccin colors
        minus-style = "syntax #3B2C37";
        minus-emph-style = "syntax #513540";
        plus-style = "syntax #2B3A37";
        plus-emph-style = "syntax #3D5045";
        
        hunk-header-style = "file line-number syntax";
        hunk-header-decoration-style = "blue box";
        
        file-style = "bold yellow ul";
        file-decoration-style = "none";
        file-added-label = "[+]";
        file-removed-label = "[-]";
        file-modified-label = "[~]";
        
        line-numbers-minus-style = "#F38BA8";
        line-numbers-plus-style = "#A6E3A1";
        line-numbers-zero-style = "#6C7086";
        
        line-numbers-left-format = "{nm:>4}│";
        line-numbers-right-format = "{np:>4}│";
      };
    };
  };

  # ============================================================
  # GITHUB CLI
  # ============================================================
  
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };
  
  # ============================================================
  # LAZYGIT
  # ============================================================
  
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        theme = {
          activeBorderColor = ["#89b4fa" "bold"];
          inactiveBorderColor = ["#a6adc8"];
          optionsTextColor = ["#89b4fa"];
          selectedLineBgColor = ["#313244"];
          cherryPickedCommitBgColor = ["#45475a"];
          cherryPickedCommitFgColor = ["#89b4fa"];
          unstagedChangesColor = ["#f38ba8"];
          defaultFgColor = ["#cdd6f4"];
          searchingActiveBorderColor = ["#f9e2af"];
        };
        nerdFontsVersion = "3";
        showIcons = true;
        mouseEvents = true;
        border = "rounded";
      };
      git = {
        paging = {
          colorArg = "always";
          pager = "delta --dark --paging=never";
        };
      };
      os = {
        edit = "nvim";
        editAtLine = "nvim +{{line}} {{filename}}";
      };
    };
  };
}
