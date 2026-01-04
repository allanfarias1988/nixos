#!/usr/bin/env bash

# ============================================================
# NixOS Configuration Install Script
# ============================================================
# Script para automatizar a instalação e configuração do NixOS
# usando os arquivos de configuração deste repositório.
#
# Autor: Allan Farias
# Uso: ./install.sh [opções]
#
# Opções:
#   --check     Apenas verifica o ambiente, sem instalar
#   --update    Atualiza a configuração existente
#   --help      Mostra esta ajuda
# ============================================================

set -euo pipefail

# ============================================================
# CORES E FORMATAÇÃO
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# ============================================================
# VARIÁVEIS
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR"
HOSTNAME="nixos-workstation"
USERNAME="allan"
BACKUP_DIR="$HOME/.nixos-backup-$(date +%Y%m%d-%H%M%S)"

# Flags para habilitar flakes temporariamente
NIX_FLAGS="--extra-experimental-features nix-command --extra-experimental-features flakes"

# ============================================================
# FUNÇÕES UTILITÁRIAS
# ============================================================

print_banner() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║     ███╗   ██╗██╗██╗  ██╗ ██████╗ ███████╗                  ║"
    echo "║     ████╗  ██║██║╚██╗██╔╝██╔═══██╗██╔════╝                  ║"
    echo "║     ██╔██╗ ██║██║ ╚███╔╝ ██║   ██║███████╗                  ║"
    echo "║     ██║╚██╗██║██║ ██╔██╗ ██║   ██║╚════██║                  ║"
    echo "║     ██║ ╚████║██║██╔╝ ██╗╚██████╔╝███████║                  ║"
    echo "║     ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝                  ║"
    echo "║                                                              ║"
    echo "║       Instalador de Configuração NixOS 25.11                ║"
    echo "║                   \"Xantusia\"                                ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_step() {
    echo -e "\n${CYAN}${BOLD}==> $1${NC}\n"
}

confirm() {
    local message="$1"
    local default="${2:-n}"
    
    if [[ "$default" == "y" ]]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi
    
    read -rp "$(echo -e "${YELLOW}$message $prompt: ${NC}")" answer
    answer="${answer:-$default}"
    
    [[ "$answer" =~ ^[Yy]$ ]]
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Não execute este script como root!"
        log_info "O script pedirá sudo quando necessário."
        exit 1
    fi
}

check_nixos() {
    if [[ ! -f /etc/NIXOS ]]; then
        log_error "Este script deve ser executado no NixOS!"
        exit 1
    fi
    log_success "Sistema NixOS detectado"
}

check_flakes() {
    if nix $NIX_FLAGS flake --version &>/dev/null; then
        log_success "Flakes disponível"
        return 0
    else
        log_warning "Flakes não está disponível - usando flags temporárias"
        return 1
    fi
}

# ============================================================
# FUNÇÕES PRINCIPAIS
# ============================================================

show_help() {
    echo "Uso: $0 [opções]"
    echo ""
    echo "Opções:"
    echo "  --check     Apenas verifica o ambiente, sem instalar"
    echo "  --update    Atualiza a configuração existente (rebuild interativo)"
    echo "  --quick     Atualização rápida sem prompts (flake update + rebuild)"
    echo "  --rollback  Volta para a configuração anterior"
    echo "  --clean     Limpa gerações antigas (garbage collect)"
    echo "  --help      Mostra esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0              # Instalação completa (wizard interativo)"
    echo "  $0 --check      # Verificar ambiente"
    echo "  $0 --update     # Atualizar sistema (interativo)"
    echo "  $0 --quick      # Atualizar sistema (sem prompts)"
}

check_environment() {
    log_step "Verificando Ambiente"
    
    check_nixos
    
    # Verificar se está no NixOS
    local nixos_version
    nixos_version=$(nixos-version 2>/dev/null || echo "desconhecida")
    log_info "Versão do NixOS: $nixos_version"
    
    # Verificar flakes
    if ! check_flakes; then
        log_info "Habilitando flakes temporariamente..."
    fi
    
    # Verificar GPU
    log_step "Detectando Hardware"
    
    if lspci | grep -qi nvidia; then
        log_success "GPU Nvidia detectada"
        GPU_TYPE="nvidia"
    elif lspci | grep -qi amd; then
        log_success "GPU AMD detectada"
        GPU_TYPE="amd"
    elif lspci | grep -qi intel; then
        log_success "GPU Intel detectada"
        GPU_TYPE="intel"
    else
        log_warning "GPU não detectada claramente"
        GPU_TYPE="unknown"
    fi
    
    # Verificar memória
    local total_mem
    total_mem=$(free -h | awk '/^Mem:/ {print $2}')
    log_info "Memória total: $total_mem"
    
    # Verificar espaço em disco
    local disk_free
    disk_free=$(df -h / | awk 'NR==2 {print $4}')
    log_info "Espaço livre em /: $disk_free"
    
    # Verificar arquivos de configuração
    log_step "Verificando Arquivos de Configuração"
    
    local files=(
        "flake.nix"
        "configuration.nix"
        "hardware-configuration.nix"
        "modules/nvidia.nix"
        "modules/hyprland.nix"
        "home/default.nix"
    )
    
    local missing=0
    for file in "${files[@]}"; do
        if [[ -f "$CONFIG_DIR/$file" ]]; then
            log_success "$file encontrado"
        else
            log_error "$file não encontrado!"
            missing=$((missing + 1))
        fi
    done
    
    if [[ $missing -gt 0 ]]; then
        log_error "$missing arquivo(s) faltando!"
        return 1
    fi
    
    log_success "Todos os arquivos de configuração encontrados"
    return 0
}

generate_hardware_config() {
    log_step "Gerando Configuração de Hardware"
    
    local hw_config="$CONFIG_DIR/hardware-configuration.nix"
    local hw_backup="$BACKUP_DIR/hardware-configuration.nix.bak"
    
    # Backup do arquivo atual
    if [[ -f "$hw_config" ]]; then
        mkdir -p "$BACKUP_DIR"
        cp "$hw_config" "$hw_backup"
        log_info "Backup do hardware-configuration.nix criado em $BACKUP_DIR"
    fi
    
    # Gerar nova configuração
    log_info "Gerando nova configuração de hardware..."
    
    if sudo nixos-generate-config --show-hardware-config > "$hw_config" 2>/dev/null; then
        log_success "hardware-configuration.nix gerado com sucesso"
        log_info "Configurações adicionais (bluetooth, graphics) já estão nos outros módulos"
    else
        log_error "Falha ao gerar configuração de hardware"
        log_info "Mantendo arquivo template existente"
        log_warning "Você precisará editar hardware-configuration.nix manualmente"
    fi
}

configure_user_settings() {
    log_step "Configurando Dados do Usuário"
    
    # Obter nome de usuário atual
    local current_user
    current_user=$(whoami)
    
    read -rp "$(echo -e "${CYAN}Nome de usuário [$current_user]: ${NC}")" input_user
    USERNAME="${input_user:-$current_user}"
    
    # Email para Git
    read -rp "$(echo -e "${CYAN}Email para Git: ${NC}")" git_email
    
    # Nome completo para Git
    read -rp "$(echo -e "${CYAN}Nome completo para Git: ${NC}")" git_name
    
    # Hostname
    read -rp "$(echo -e "${CYAN}Hostname [$HOSTNAME]: ${NC}")" input_hostname
    HOSTNAME="${input_hostname:-$HOSTNAME}"
    
    # Atualizar flake.nix com username
    log_info "Atualizando configurações..."
    
    sed -i "s/username = \"allan\"/username = \"$USERNAME\"/" "$CONFIG_DIR/flake.nix"
    sed -i "s/nixos-workstation/$HOSTNAME/g" "$CONFIG_DIR/flake.nix"
    sed -i "s/nixos-workstation/$HOSTNAME/g" "$CONFIG_DIR/configuration.nix"
    
    # Atualizar git.nix
    if [[ -n "$git_email" ]]; then
        sed -i "s/seu-email@exemplo.com/$git_email/" "$CONFIG_DIR/home/git.nix"
    fi
    
    if [[ -n "$git_name" ]]; then
        sed -i "s/userName = \"Allan Farias\"/userName = \"$git_name\"/" "$CONFIG_DIR/home/git.nix"
    fi
    
    log_success "Configurações de usuário atualizadas"
}

select_gpu_module() {
    log_step "Configurando GPU"
    
    echo -e "${CYAN}GPU detectada: $GPU_TYPE${NC}"
    echo ""
    echo "Módulos disponíveis:"
    echo "  1) Nvidia (drivers proprietários + CUDA)"
    echo "  2) AMD (drivers open source + ROCm)"
    echo "  3) Intel (integrada)"
    echo "  4) Nenhum (VM ou outro)"
    echo ""
    
    read -rp "$(echo -e "${CYAN}Selecione [1-4]: ${NC}")" gpu_choice
    
    case "$gpu_choice" in
        1)
            log_info "Configurando para Nvidia..."
            # Nvidia já está habilitado por padrão
            ;;
        2)
            log_info "Configurando para AMD..."
            # Trocar nvidia por amd no flake.nix
            sed -i 's/\.\/modules\/nvidia\.nix/# .\/modules\/nvidia.nix  # Desabilitado/' "$CONFIG_DIR/flake.nix"
            sed -i 's/# \.\/modules\/amd\.nix/.\/modules\/amd.nix/' "$CONFIG_DIR/flake.nix"
            # Remover kernel params nvidia
            sed -i 's/"nvidia_drm.modeset=1"/# "nvidia_drm.modeset=1"/' "$CONFIG_DIR/configuration.nix"
            ;;
        3)
            log_info "Configurando para Intel..."
            sed -i 's/\.\/modules\/nvidia\.nix/# .\/modules\/nvidia.nix  # Desabilitado/' "$CONFIG_DIR/flake.nix"
            sed -i 's/"nvidia_drm.modeset=1"/# "nvidia_drm.modeset=1"/' "$CONFIG_DIR/configuration.nix"
            ;;
        4)
            log_info "Desabilitando módulos de GPU..."
            sed -i 's/\.\/modules\/nvidia\.nix/# .\/modules\/nvidia.nix  # Desabilitado/' "$CONFIG_DIR/flake.nix"
            sed -i 's/"nvidia_drm.modeset=1"/# "nvidia_drm.modeset=1"/' "$CONFIG_DIR/configuration.nix"
            ;;
        *)
            log_warning "Opção inválida, mantendo Nvidia como padrão"
            ;;
    esac
    
    log_success "Configuração de GPU aplicada"
}

select_optional_modules() {
    log_step "Módulos Opcionais"
    
    echo -e "${CYAN}Deseja habilitar módulos opcionais?${NC}"
    echo ""
    
    # Gaming
    if confirm "Habilitar módulo de Gaming (Steam, Lutris)?"; then
        sed -i 's/# \.\/modules\/gaming\.nix/.\/modules\/gaming.nix/' "$CONFIG_DIR/flake.nix"
        log_success "Módulo Gaming habilitado"
    fi
    
    echo ""
}

setup_flathub() {
    log_step "Configurando Flatpak"
    
    if confirm "Adicionar repositório Flathub?"; then
        if command -v flatpak &>/dev/null; then
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            log_success "Flathub adicionado"
        else
            log_warning "Flatpak será configurado após o rebuild"
        fi
    fi
}

verify_config() {
    log_step "Verificando Configuração"
    
    log_info "Executando nix flake check..."
    
    cd "$CONFIG_DIR"
    
    # Usar flags para habilitar flakes temporariamente
    if nix $NIX_FLAGS flake check --no-build 2>&1 | tee /tmp/flake-check.log; then
        log_success "Configuração válida!"
        return 0
    else
        log_error "Erros encontrados na configuração"
        log_info "Verifique /tmp/flake-check.log para detalhes"
        return 1
    fi
}

build_system() {
    log_step "Construindo Sistema"
    
    cd "$CONFIG_DIR"
    
    # Verificar se é primeira instalação ou atualização
    local is_first_install=false
    if [[ ! -f "$CONFIG_DIR/flake.lock" ]]; then
        is_first_install=true
        log_info "Primeira instalação detectada - gerando flake.lock..."
    fi
    
    # Atualizar flake.lock se necessário ou se solicitado
    if $is_first_install || confirm "Atualizar dependências (nix flake update)?"; then
        log_info "Atualizando flake.lock..."
        if nix $NIX_FLAGS flake update 2>&1 | tee /tmp/flake-update.log; then
            log_success "flake.lock atualizado!"
        else
            log_error "Falha ao atualizar flake.lock"
            log_info "Verifique /tmp/flake-update.log para detalhes"
            if ! $is_first_install; then
                log_warning "Continuando com flake.lock existente..."
            else
                return 1
            fi
        fi
    fi
    
    log_info "Isso pode demorar alguns minutos na primeira vez..."
    log_info "Os caches de Hyprland e CUDA serão usados se disponíveis."
    echo ""
    
    # Build primeiro (sem switch)
    if confirm "Fazer build de teste primeiro (recomendado)?"; then
        log_info "Executando nixos-rebuild build..."
        if sudo nixos-rebuild build --flake ".#$HOSTNAME" $NIX_FLAGS; then
            log_success "Build concluído com sucesso!"
        else
            log_error "Falha no build"
            return 1
        fi
    fi
    
    # Switch
    if confirm "Aplicar configuração agora (switch)?"; then
        log_info "Executando nixos-rebuild switch..."
        if sudo nixos-rebuild switch --flake ".#$HOSTNAME" $NIX_FLAGS; then
            log_success "Sistema configurado com sucesso!"
        else
            log_error "Falha ao aplicar configuração"
            log_info "Tente: sudo nixos-rebuild switch --flake .#$HOSTNAME $NIX_FLAGS --show-trace"
            return 1
        fi
    fi
    
    return 0
}

post_install() {
    log_step "Pós-instalação"
    
    # Lembrar de reiniciar
    log_warning "Recomendado reiniciar o sistema para aplicar todas as mudanças"
    
    # Dicas
    echo ""
    echo -e "${CYAN}${BOLD}Próximos passos:${NC}"
    echo ""
    echo "  1. Reinicie o sistema"
    echo "  2. No login, selecione 'Hyprland' como sessão"
    echo "  3. Abra o terminal com Super+Return"
    echo "  4. Configure o Ollama: ollama pull llama2"
    echo "  5. Configure impressoras: http://localhost:631"
    echo ""
    echo -e "${CYAN}${BOLD}Comandos úteis:${NC}"
    echo ""
    echo "  sudo nixos-rebuild switch --flake .    # Atualizar sistema"
    echo "  nix flake update                       # Atualizar dependências"
    echo "  sudo nix-collect-garbage -d            # Limpar gerações antigas"
    echo ""
    
    if confirm "Reiniciar agora?"; then
        log_info "Reiniciando..."
        sleep 2
        sudo reboot
    fi
}

update_system() {
    log_step "Atualizando Sistema"
    
    cd "$CONFIG_DIR"
    
    # Verificar se existe flake.lock
    if [[ ! -f "$CONFIG_DIR/flake.lock" ]]; then
        log_warning "flake.lock não encontrado - será criado"
    fi
    
    # Sempre atualizar flake.lock por padrão
    if confirm "Atualizar flake.lock (dependências)?" "y"; then
        log_info "Executando nix flake update..."
        if nix $NIX_FLAGS flake update 2>&1 | tee /tmp/flake-update.log; then
            log_success "Dependências atualizadas!"
        else
            log_error "Falha ao atualizar dependências"
            log_info "Verifique /tmp/flake-update.log para detalhes"
            if ! confirm "Continuar mesmo assim?"; then
                return 1
            fi
        fi
    fi
    
    log_info "Aplicando configuração..."
    log_info "Executando: sudo nixos-rebuild switch --flake .#$HOSTNAME"
    echo ""
    
    if sudo nixos-rebuild switch --flake ".#$HOSTNAME" $NIX_FLAGS; then
        log_success "Sistema atualizado com sucesso!"
        echo ""
        log_info "Dica: Para verificar as mudanças, execute:"
        echo "      sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -5"
    else
        log_error "Falha na atualização"
        log_info "Tente: sudo nixos-rebuild switch --flake .#$HOSTNAME $NIX_FLAGS --show-trace"
        return 1
    fi
}

rollback_system() {
    log_step "Rollback do Sistema"
    
    log_warning "Isso irá reverter para a configuração anterior"
    
    if confirm "Continuar com rollback?"; then
        if sudo nixos-rebuild switch --rollback; then
            log_success "Rollback concluído"
        else
            log_error "Falha no rollback"
            return 1
        fi
    fi
}

clean_system() {
    log_step "Limpando Sistema"
    
    # Mostrar gerações
    log_info "Gerações atuais:"
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -10
    echo ""
    
    if confirm "Remover gerações antigas (mais de 7 dias)?"; then
        log_info "Limpando gerações antigas..."
        sudo nix-collect-garbage --delete-older-than 7d
        log_success "Limpeza concluída"
    fi
    
    if confirm "Otimizar store (pode demorar)?"; then
        log_info "Otimizando..."
        sudo nix-store --optimise
        log_success "Store otimizado"
    fi
}

quick_update() {
    log_step "Atualização Rápida"
    
    cd "$CONFIG_DIR"
    
    # Verificar se existe flake.nix
    if [[ ! -f "$CONFIG_DIR/flake.nix" ]]; then
        log_error "flake.nix não encontrado em $CONFIG_DIR"
        log_info "Execute o script sem argumentos para instalação completa."
        return 1
    fi
    
    # 1. Atualizar flake.lock
    log_info "Passo 1/2: Atualizando flake.lock..."
    log_info "Executando: nix flake update"
    echo ""
    
    if nix $NIX_FLAGS flake update; then
        log_success "flake.lock atualizado!"
    else
        log_error "Falha ao atualizar flake.lock"
        return 1
    fi
    
    echo ""
    
    # 2. Rebuild e switch
    log_info "Passo 2/2: Aplicando configuração..."
    log_info "Executando: sudo nixos-rebuild switch --flake .#$HOSTNAME"
    echo ""
    
    if sudo nixos-rebuild switch --flake ".#$HOSTNAME" $NIX_FLAGS; then
        log_success "Sistema atualizado com sucesso!"
        echo ""
        log_info "Gerações recentes:"
        sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -3
    else
        log_error "Falha na atualização"
        log_info "Tente: sudo nixos-rebuild switch --flake .#$HOSTNAME $NIX_FLAGS --show-trace"
        return 1
    fi
}

# ============================================================
# MAIN
# ============================================================

main() {
    print_banner
    check_root
    
    # Parse argumentos
    case "${1:-}" in
        --help|-h)
            show_help
            exit 0
            ;;
        --check)
            check_environment
            exit $?
            ;;
        --update)
            check_environment
            update_system
            exit $?
            ;;
        --quick|-q)
            check_nixos
            quick_update
            exit $?
            ;;
        --rollback)
            rollback_system
            exit $?
            ;;
        --clean)
            clean_system
            exit $?
            ;;
        "")
            # Instalação completa
            ;;
        *)
            log_error "Opção desconhecida: $1"
            show_help
            exit 1
            ;;
    esac
    
    # Instalação completa
    log_step "Iniciando Instalação"
    
    if ! check_environment; then
        log_error "Ambiente não está pronto para instalação"
        exit 1
    fi
    
    echo ""
    if ! confirm "Continuar com a instalação?" "y"; then
        log_info "Instalação cancelada"
        exit 0
    fi
    
    # Etapas de instalação
    generate_hardware_config
    configure_user_settings
    select_gpu_module
    select_optional_modules
    setup_flathub
    
    if ! verify_config; then
        log_error "Configuração inválida. Corrija os erros e tente novamente."
        exit 1
    fi
    
    build_system
    post_install
    
    log_success "Instalação concluída!"
}

main "$@"
