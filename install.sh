#!/bin/bash

# =============================================================================
# ULTIMATE BOOTSTRAP & DOTFILES INSTALLATION SCRIPT
# =============================================================================

set -e # Exit on error

# Warna untuk output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}==> Memulai Ultimate Bootstrap Setup...${NC}"

# 1. Update & Install Nala First
echo -e "${YELLOW}[1/10] Menginstall Nala untuk manajemen paket yang lebih baik...${NC}"
sudo apt update && sudo apt install -y nala

# 2. Install System Packages via Nala
echo -e "${YELLOW}[2/10] Menginstall paket sistem (Dev, Productivity, Entertainment)...${NC}"
sudo nala install -y \
    zsh tmux neovim stow curl git wget build-essential cmake jq fzf ripgrep fd-find lsd bat btop fastfetch \
    python3 nodejs npm docker-ce gh nmap aircrack-ng gobuster \
    gimp inkscape blender kdenlive ffmpeg \
    gnome-tweaks gnome-shell-extension-manager \
    cmatrix graphviz doxygen lazygit flatpak

# 3. Setup Snap Packages
echo -e "${YELLOW}[3/10] Menginstall Snap packages...${NC}"
sudo snap install code --classic
sudo snap install bitwarden
sudo snap install termius-app
sudo snap install ascii-image-converter

# 4. Setup Flatpak Packages
echo -e "${YELLOW}[4/10] Menginstall Flatpak packages...${NC}"
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub org.upscayl.Upscayl
flatpak install -y flathub org.vinegarhq.Sober
flatpak install -y flathub io.github.jeffshee.Hidamari

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

# 9. Setup Tmux Plugins (Catppuccin)
echo -e "${YELLOW}[9/10] Mengatur Tmux Plugins...${NC}"
mkdir -p ~/.config/tmux/plugins
if [ ! -d "$HOME/.config/tmux/plugins/catppuccin" ]; then
    git clone https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin
fi

# 10. Symlink Configurations with Stow
echo -e "${YELLOW}[10/10] Menjalankan Stow untuk symlink konfigurasi...${NC}"
# Hapus file bawaan jika ada agar tidak konflik dengan stow
rm -f ~/.zshrc ~/.p10k.zsh ~/.tmux.conf
rm -rf ~/.config/nvim ~/.config/fastfetch

# Pindah ke direktori repository
DOTFILES_DIR=$(pwd)
cd "$DOTFILES_DIR"

# Pastikan folder target .config ada
mkdir -p ~/.config

stow zsh
stow tmux
stow nvim
stow fastfetch

# Finalize
echo -e "${BLUE}==> Mengganti default shell ke Zsh...${NC}"
if [ "$SHELL" != "$(which zsh)" ]; then
    sudo chsh -s $(which zsh) $USER
fi

echo -e "${GREEN}Selesai! Semua paket dan konfigurasi telah terpasang.${NC}"
echo -e "${GREEN}Silakan restart terminal Anda atau jalankan 'zsh'.${NC}"
