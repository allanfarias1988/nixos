# ============================================================
# NEOVIM / LAZYVIM - CONFIGURAÇÃO
# ============================================================
# Neovim configurado como LazyVim com efeitos modernos.
# Esta configuração usa o Nixvim para gerenciar plugins via Nix.
#
# Autor: Allan Farias

{ config, pkgs, lib, inputs, ... }:

{
  # ============================================================
  # NEOVIM BASE
  # ============================================================
  
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    
    # Dependências extras
    extraPackages = with pkgs; [
      # ----------------------
      # LSPs
      # ----------------------
      # JavaScript/TypeScript
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted  # HTML, CSS, JSON
      
      # Python
      pyright
      ruff
      black
      
      # Lua
      lua-language-server
      stylua
      
      # Nix
      nil
      nixpkgs-fmt
      
      # Rust
      rust-analyzer
      
      # Go
      gopls
      
      # C/C++
      clang-tools
      
      # Shell
      shellcheck
      shfmt
      
      # Markdown
      marksman
      
      # YAML
      nodePackages.yaml-language-server
      
      # Docker
      dockerfile-language-server-nodejs
      docker-compose-language-service
      
      # ----------------------
      # Formatters
      # ----------------------
      prettierd
      eslint_d
      
      # ----------------------
      # Outras ferramentas
      # ----------------------
      tree-sitter
      ripgrep
      fd
      lazygit
      
      # Clipboard
      wl-clipboard
      xclip
    ];
  };

  # ============================================================
  # LAZYVIM CONFIGURATION
  # ============================================================
  
  # Criar estrutura de diretórios para LazyVim
  xdg.configFile = {
    # ----------------------
    # Init principal
    # ----------------------
    "nvim/init.lua".text = ''
      -- ========================================================
      -- LAZYVIM CONFIGURATION
      -- ========================================================
      -- Bootstrap LazyVim
      
      -- Leader key (antes de lazy)
      vim.g.mapleader = " "
      vim.g.maplocalleader = "\\"
      
      -- Disable built-in plugins
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      
      -- Bootstrap lazy.nvim
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
          "git",
          "clone",
          "--filter=blob:none",
          "https://github.com/folke/lazy.nvim.git",
          "--branch=stable",
          lazypath,
        })
      end
      vim.opt.rtp:prepend(lazypath)
      
      -- Setup lazy.nvim com LazyVim
      require("lazy").setup({
        spec = {
          -- LazyVim e seus plugins
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },
          
          -- Extras do LazyVim
          { import = "lazyvim.plugins.extras.lang.typescript" },
          { import = "lazyvim.plugins.extras.lang.python" },
          { import = "lazyvim.plugins.extras.lang.rust" },
          { import = "lazyvim.plugins.extras.lang.go" },
          { import = "lazyvim.plugins.extras.lang.json" },
          { import = "lazyvim.plugins.extras.lang.yaml" },
          { import = "lazyvim.plugins.extras.lang.markdown" },
          { import = "lazyvim.plugins.extras.lang.docker" },
          { import = "lazyvim.plugins.extras.lang.nix" },
          
          -- Formatação e linting
          { import = "lazyvim.plugins.extras.formatting.prettier" },
          { import = "lazyvim.plugins.extras.linting.eslint" },
          
          -- Git
          { import = "lazyvim.plugins.extras.editor.mini-files" },
          
          -- Copilot (opcional)
          -- { import = "lazyvim.plugins.extras.coding.copilot" },
          
          -- Plugins customizados
          { import = "plugins" },
        },
        defaults = {
          lazy = false,
          version = false,
        },
        install = { colorscheme = { "catppuccin", "tokyonight", "habamax" } },
        checker = { enabled = true },
        performance = {
          rtp = {
            disabled_plugins = {
              "gzip",
              "tarPlugin",
              "tohtml",
              "tutor",
              "zipPlugin",
            },
          },
        },
      })
    '';

    # ----------------------
    # Plugins customizados
    # ----------------------
    "nvim/lua/plugins/init.lua".text = ''
      return {
        -- ========================================================
        -- TEMA E VISUAL
        -- ========================================================
        
        -- Catppuccin como tema principal
        {
          "catppuccin/nvim",
          name = "catppuccin",
          priority = 1000,
          opts = {
            flavour = "mocha",
            transparent_background = true,
            term_colors = true,
            integrations = {
              cmp = true,
              gitsigns = true,
              nvimtree = true,
              treesitter = true,
              notify = true,
              mini = true,
              native_lsp = {
                enabled = true,
                virtual_text = {
                  errors = { "italic" },
                  hints = { "italic" },
                  warnings = { "italic" },
                  information = { "italic" },
                },
              },
            },
          },
        },
        
        -- Configurar LazyVim para usar Catppuccin
        {
          "LazyVim/LazyVim",
          opts = {
            colorscheme = "catppuccin",
          },
        },
        
        -- ========================================================
        -- ANIMAÇÕES E EFEITOS
        -- ========================================================
        
        -- Animações de scroll
        {
          "karb94/neoscroll.nvim",
          event = "VeryLazy",
          opts = {
            mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
            hide_cursor = true,
            stop_eof = true,
            respect_scrolloff = false,
            cursor_scrolls_alone = true,
            easing_function = "sine",
          },
        },
        
        -- Animações de cursor e janelas
        {
          "echasnovski/mini.animate",
          event = "VeryLazy",
          opts = function()
            local animate = require("mini.animate")
            return {
              scroll = {
                enable = false, -- deixa neoscroll cuidar
              },
              resize = {
                timing = animate.gen_timing.linear({ duration = 100, unit = "total" }),
              },
              open = {
                timing = animate.gen_timing.linear({ duration = 150, unit = "total" }),
              },
              close = {
                timing = animate.gen_timing.linear({ duration = 150, unit = "total" }),
              },
            }
          end,
        },
        
        -- Rainbow delimiters
        {
          "HiPhish/rainbow-delimiters.nvim",
          event = "BufRead",
          config = function()
            require("rainbow-delimiters.setup").setup({})
          end,
        },
        
        -- Indent animation
        {
          "echasnovski/mini.indentscope",
          opts = {
            symbol = "│",
            options = { try_as_border = true },
            draw = {
              delay = 100,
              animation = require("mini.indentscope").gen_animation.cubic({
                easing = "out",
                duration = 100,
                unit = "total",
              }),
            },
          },
        },
        
        -- ========================================================
        -- PRODUTIVIDADE
        -- ========================================================
        
        -- Dashboard aprimorado
        {
          "nvimdev/dashboard-nvim",
          opts = function()
            local logo = [[
      ███╗   ██╗██╗██╗  ██╗ ██████╗ ███████╗
      ████╗  ██║██║╚██╗██╔╝██╔═══██╗██╔════╝
      ██╔██╗ ██║██║ ╚███╔╝ ██║   ██║███████╗
      ██║╚██╗██║██║ ██╔██╗ ██║   ██║╚════██║
      ██║ ╚████║██║██╔╝ ██╗╚██████╔╝███████║
      ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝
            ]]
            logo = string.rep("\n", 8) .. logo .. "\n\n"
            return {
              theme = "doom",
              config = {
                header = vim.split(logo, "\n"),
                center = {
                  { action = "Telescope find_files", desc = " Find file", icon = " ", key = "f" },
                  { action = "ene | startinsert", desc = " New file", icon = " ", key = "n" },
                  { action = "Telescope oldfiles", desc = " Recent files", icon = " ", key = "r" },
                  { action = "Telescope live_grep", desc = " Find text", icon = " ", key = "g" },
                  { action = "lua require('persistence').load()", desc = " Restore Session", icon = " ", key = "s" },
                  { action = "LazyExtras", desc = " Lazy Extras", icon = " ", key = "x" },
                  { action = "Lazy", desc = " Lazy", icon = "󰒲 ", key = "l" },
                  { action = "qa", desc = " Quit", icon = " ", key = "q" },
                },
                footer = function()
                  local stats = require("lazy").stats()
                  local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                  return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
                end,
              },
            }
          end,
        },
        
        -- ========================================================
        -- UTILIDADES
        -- ========================================================
        
        -- Wakatime (opcional - tracking de tempo)
        -- { "wakatime/vim-wakatime", event = "VeryLazy" },
        
        -- Hardtime - ajuda a criar bons hábitos (opcional)
        -- { "m4xshen/hardtime.nvim", opts = {} },
      }
    '';

    # ----------------------
    # Opções do Neovim
    # ----------------------
    "nvim/lua/config/options.lua".text = ''
      -- Opções gerais
      local opt = vim.opt
      
      -- Visual
      opt.termguicolors = true
      opt.number = true
      opt.relativenumber = true
      opt.cursorline = true
      opt.signcolumn = "yes"
      opt.showmode = false
      opt.conceallevel = 2
      
      -- Indentação
      opt.tabstop = 2
      opt.shiftwidth = 2
      opt.expandtab = true
      opt.smartindent = true
      
      -- Busca
      opt.ignorecase = true
      opt.smartcase = true
      opt.hlsearch = true
      opt.incsearch = true
      
      -- Interface
      opt.splitright = true
      opt.splitbelow = true
      opt.scrolloff = 8
      opt.sidescrolloff = 8
      
      -- Performance
      opt.updatetime = 200
      opt.timeoutlen = 300
      
      -- Arquivos
      opt.swapfile = false
      opt.backup = false
      opt.undofile = true
      
      -- Clipboard
      opt.clipboard = "unnamedplus"
      
      -- Mouse
      opt.mouse = "a"
      
      -- Wrap
      opt.wrap = false
      opt.linebreak = true
    '';

    # ----------------------
    # Keymaps
    # ----------------------
    "nvim/lua/config/keymaps.lua".text = ''
      -- Keymaps seguindo padrões do sistema
      local map = vim.keymap.set
      
      -- LazyVim já define a maioria dos keymaps padrão
      -- Aqui apenas ajustes específicos
      
      -- Salvar com Ctrl+S (padrão comum)
      map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Salvar arquivo" })
      
      -- Copiar tudo com Ctrl+A (modo normal)
      map("n", "<C-a>", "ggVG", { desc = "Selecionar tudo" })
      
      -- Melhor navegação em janelas
      map("n", "<C-h>", "<C-w>h", { desc = "Ir para janela esquerda" })
      map("n", "<C-l>", "<C-w>l", { desc = "Ir para janela direita" })
      map("n", "<C-j>", "<C-w>j", { desc = "Ir para janela abaixo" })
      map("n", "<C-k>", "<C-w>k", { desc = "Ir para janela acima" })
      
      -- Mover linhas (Alt+j/k)
      map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Mover linha para baixo" })
      map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Mover linha para cima" })
      map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Mover seleção para baixo" })
      map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Mover seleção para cima" })
      
      -- Redimensionar janelas
      map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Aumentar altura" })
      map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Diminuir altura" })
      map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Diminuir largura" })
      map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Aumentar largura" })
      
      -- Buffer navigation
      map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Buffer anterior" })
      map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Próximo buffer" })
      
      -- Escape no terminal
      map("t", "<Esc><Esc>", "<c-\\><c-n>", { desc = "Sair do modo terminal" })
    '';
  };
}
