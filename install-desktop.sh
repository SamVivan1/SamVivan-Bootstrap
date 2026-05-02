#!/bin/bash

# =============================================================================
# ULTIMATE BOOTSTRAP - DESKTOP EDITION
# =============================================================================

set -e # Exit on error

# Warna untuk output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}==> Memulai Ultimate Bootstrap Setup (Desktop Edition)...${NC}"

# Detect OS and Package Manager
get_package_manager() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "brew"
    elif command -v apt &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

PKG_MANAGER=$(get_package_manager)

# Install Homebrew if on macOS and missing
if [ "$PKG_MANAGER" = "brew" ] && ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Update system
update_system() {
    echo -e "${YELLOW}Updating system packages...${NC}"
    case $PKG_MANAGER in
        "brew") brew update && brew upgrade ;;
        "apt") sudo apt update && sudo apt upgrade -y ;;
        "dnf") sudo dnf update -y ;;
        "pacman") sudo pacman -Syu --noconfirm ;;
    esac
}

update_system

# Install packages helper
install_package() {
    local package=$1
    echo -e "${YELLOW}Installing $package...${NC}"
    case $PKG_MANAGER in
        "brew") brew install "$package" ;;
        "apt") 
            if command -v nala &> /dev/null; then
                sudo nala install -y "$package"
            else
                sudo apt install -y "$package"
            fi
            ;;
        "dnf") sudo dnf install -y "$package" ;;
        "pacman") sudo pacman -S --noconfirm "$package" ;;
    esac
}

# 1. Install Nala for Debian/Ubuntu
if [ "$PKG_MANAGER" = "apt" ] && ! command -v nala &> /dev/null; then
    echo -e "${YELLOW}[1/10] Menginstall Nala...${NC}"
    sudo apt install -y nala
fi

# 2. Install System Packages
echo -e "${YELLOW}[2/10] Menginstall paket sistem...${NC}"
CORE_PACKAGES="zsh tmux neovim stow curl git wget build-essential cmake jq fzf ripgrep fd-find lsd bat btop fastfetch"
for pkg in $CORE_PACKAGES; do
    install_package "$pkg"
done

# OS-specific packages
if [ "$PKG_MANAGER" != "brew" ]; then
    # Linux Desktop Packages
    LINUX_DEKTOP_PKG="python3 nodejs npm docker-ce gh nmap aircrack-ng gobuster gimp inkscape blender kdenlive ffmpeg gnome-tweaks gnome-shell-extension-manager cmatrix graphviz doxygen lazygit flatpak"
    for pkg in $LINUX_DEKTOP_PKG; do
        install_package "$pkg"
    done
else
    # macOS Desktop Packages (Casks)
    echo -e "${YELLOW}Installing macOS Casks...${NC}"
    brew install --cask visual-studio-code bitwarden gimp inkscape blender kdenlive ghostty
    # macOS CLI extras
    brew install node python lazygit gh
fi

# 3. Setup Snap Packages (Linux Only)
if [ "$PKG_MANAGER" != "brew" ] && command -v snap &> /dev/null; then
    echo -e "${YELLOW}[3/10] Menginstall Snap packages...${NC}"
    sudo snap install code --classic || true
    sudo snap install bitwarden || true
    sudo snap install termius-app || true
    sudo snap install ascii-image-converter || true
fi

# 4. Setup Flatpak Packages (Linux Only)
if [ "$PKG_MANAGER" != "brew" ] && command -v flatpak &> /dev/null; then
    echo -e "${YELLOW}[4/10] Menginstall Flatpak packages...${NC}"
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install -y flathub org.upscayl.Upscayl || true
    flatpak install -y flathub org.vinegarhq.Sober || true
    flatpak install -y flathub io.github.jeffshee.Hidamari || true
fi

# 5. Install Oh My Zsh & Plugins
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${YELLOW}[5/10] Menginstall Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
echo -e "${YELLOW}Mengunduh ZSH Plugins & Themes...${NC}"
[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
[ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
[ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ] && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM}/themes/powerlevel10k

# Install zsh-autocomplete
if [ ! -d "${ZDOTDIR:-$HOME}/.zsh/zsh-autocomplete" ]; then
    echo -e "${YELLOW}Installing zsh-autocomplete...${NC}"
    git clone --depth 1 --config core.autocrlf=false https://github.com/marlonrichert/zsh-autocomplete.git ${ZDOTDIR:-$HOME}/.zsh/zsh-autocomplete
fi

# 6. Install Zoxide
if ! command -v zoxide &> /dev/null; then
    echo -e "${YELLOW}[6/10] Menginstall Zoxide...${NC}"
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# 7. Install NVM (Node Version Manager)
if [ ! -d "$HOME/.nvm" ]; then
    echo -e "${YELLOW}[7/10] Menginstall NVM...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

# 8. Install Bun
if ! command -v bun &> /dev/null; then
    echo -e "${YELLOW}[8/10] Menginstall Bun...${NC}"
    curl -fsSL https://bun.sh/install | bash
fi

# 9. Install Fonts
echo -e "${YELLOW}[9/10] Menginstall font MesloLGS NF...${NC}"
if [[ "$OSTYPE" == "darwin"* ]]; then
    FONT_DIR="$HOME/Library/Fonts"
else
    FONT_DIR="$HOME/.local/share/fonts"
fi
mkdir -p "$FONT_DIR"
for font in "Regular" "Bold" "Italic" "Bold%20Italic"; do
    if [ ! -f "$FONT_DIR/MesloLGS NF ${font//%20/ }.ttf" ]; then
        wget -q -P "$FONT_DIR" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20$font.ttf"
    fi
done
[ "$PKG_MANAGER" != "brew" ] && fc-cache -f -v > /dev/null 2>&1 || true

# 10. Symlink Configurations with Stow
echo -e "${YELLOW}[10/10] Menjalankan Stow...${NC}"

# Dapatkan direktori repository (tempat script ini berada)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Hapus file lama agar stow bisa membuat symlink baru tanpa konflik
echo -e "${YELLOW}Membersihkan konfigurasi lama di $HOME...${NC}"
rm -f ~/.zshrc ~/.p10k.zsh ~/.tmux.conf
rm -rf ~/.config/nvim ~/.config/fastfetch
mkdir -p ~/.config

# Jalankan stow dengan target ke HOME directory
stow -v -R -t "$HOME" zsh
stow -v -R -t "$HOME" tmux
stow -v -R -t "$HOME" nvim
stow -v -R -t "$HOME" fastfetch

# Finalize
echo -e "${BLUE}==> Mengganti default shell ke Zsh...${NC}"
if [ "$SHELL" != "$(which zsh)" ]; then
    sudo chsh -s $(which zsh) $USER
fi

echo -e "${GREEN}Selesai! Semua paket dan konfigurasi telah terpasang.${NC}"
echo -e "${GREEN}Silakan restart terminal Anda atau jalankan 'zsh'.${NC}"
