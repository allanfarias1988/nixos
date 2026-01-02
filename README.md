# 🚀 NixOS Configuration - Allan Farias

Configuração NixOS completa e reproduzível usando Flakes. Este setup inclui:

- 🖥️ **Hyprland** - Compositor Wayland moderno com animações
- 🎨 **Catppuccin Mocha** - Tema consistente em todo o sistema
- ⌨️ **LazyVim** - Neovim pré-configurado com efeitos modernos
- 🎬 **Content Creation** - DaVinci Resolve, OBS, Blender, Audacity
- 🤖 **AI/ML** - CUDA, PyTorch, Ollama para modelos locais
- 🖨️ **Impressoras** - Drivers para Epson, HP, Brother

## 📋 Pré-requisitos

1. Instalação limpa do NixOS ou sistema existente com Flakes habilitado
2. GPU Nvidia (ou AMD - ajuste o flake.nix)
3. Hardware configuration gerado (`sudo nixos-generate-config`)

## 🛠️ Instalação

### 1. Clone a configuração

```bash
# Clone para sua home
git clone <seu-repo> ~/nixos-config
cd ~/nixos-config
```

### 2. Gere o hardware-configuration.nix

```bash
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

### 3. Ajustes necessários

Edite os seguintes arquivos conforme seu hardware e preferências:

| Arquivo | O que ajustar |
|---------|---------------|
| `flake.nix` | Nome do host, módulos de GPU |
| `hardware-configuration.nix` | UUIDs das partições (gerado acima) |
| `configuration.nix` | Hostname, kernel params |
| `home/git.nix` | Seu email e nome |
| `home/hyprland.nix` | Monitores, wallpaper |

### 4. Build e ative

```bash
# Primeira instalação
sudo nixos-rebuild switch --flake .#nixos-workstation

# Atualizações futuras
sudo nixos-rebuild switch --flake .
```

## 📁 Estrutura

```
.
├── flake.nix                 # Entrada do flake
├── configuration.nix         # Config base do sistema
├── hardware-configuration.nix # Hardware específico
├── modules/
│   ├── nvidia.nix            # Drivers Nvidia + CUDA
│   ├── amd.nix               # Drivers AMD (alternativa)
│   ├── hyprland.nix          # Compositor + componentes
│   ├── development.nix       # Linguagens, editores, DevOps
│   ├── content-creation.nix  # Vídeo, áudio, 3D
│   ├── ai-ml.nix             # IA, PyTorch, Ollama
│   ├── desktop-apps.nix      # Apps gerais
│   ├── printing.nix          # Impressoras e scanners
│   └── gaming.nix            # Gaming (opcional)
└── home/
    ├── default.nix           # Home Manager principal
    ├── neovim.nix            # LazyVim config
    ├── hyprland.nix          # Hyprland do usuário
    ├── shell.nix             # Zsh + Starship
    └── git.nix               # Git config
```

## ⌨️ Atalhos Principais

### Hyprland

| Atalho | Ação |
|--------|------|
| `Super + Return` | Terminal (Kitty) |
| `Super + Space` | Launcher (Wofi) |
| `Super + E` | Gerenciador de arquivos |
| `Super + B` | Navegador |
| `Super + Q` | Fechar janela |
| `Super + F` | Fullscreen |
| `Super + V` | Toggle Floating |
| `Super + 1-9` | Mudar workspace |
| `Super + Shift + 1-9` | Mover janela para workspace |
| `Print` | Screenshot (área) |
| `Shift + Print` | Screenshot (tela) |

### Neovim (LazyVim)

| Atalho | Ação |
|--------|------|
| `Space` | Leader key |
| `Space + e` | File explorer |
| `Space + ff` | Find files |
| `Space + fg` | Live grep |
| `Space + gg` | Lazygit |
| `Ctrl + S` | Salvar |

## 🔧 Customização

### Trocar GPU

Para AMD, edite `flake.nix`:
```nix
modules = [
  # ./modules/nvidia.nix   # Comentar
  ./modules/amd.nix        # Descomentar
  ...
];
```

### Adicionar novo host

1. Copie o bloco `nixos-workstation` em `flake.nix`
2. Renomeie para seu novo hostname
3. Ajuste os módulos conforme necessário
4. Crie `hosts/<hostname>/hardware-configuration.nix`

### Gaming

Descomente `./modules/gaming.nix` no `flake.nix` para Steam, Lutris, etc.

## 🔄 Comandos Úteis

```bash
# Rebuild e switch
sudo nixos-rebuild switch --flake .

# Rebuild sem switch (teste)
sudo nixos-rebuild test --flake .

# Atualizar flake.lock
nix flake update

# Limpar gerações antigas
sudo nix-collect-garbage -d

# Ver gerações
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback
sudo nixos-rebuild switch --rollback
```

## 🆘 Troubleshooting

### Hyprland + Nvidia

Se tiver problemas com cursor ou flickering:
```nix
# Em configuration.nix
boot.kernelParams = [ "nvidia_drm.modeset=1" "nvidia_drm.fbdev=1" ];
```

### CUDA não funciona

Verifique com:
```bash
python -c "import torch; print(torch.cuda.is_available())"
```

### LazyVim plugins não instalam

Na primeira execução, aguarde o download. Se falhar:
```bash
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
nvim
```

## 📝 Notas

- **Flatpak**: Adicione Flathub manualmente:
  ```bash
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  ```

- **Ollama**: Baixar modelos:
  ```bash
  ollama pull llama2
  ollama run llama2
  ```

- **Impressoras**: Configure via `http://localhost:631`

## 📄 Licença

MIT - Use e modifique como quiser!
