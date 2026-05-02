#!/bin/bash

# =============================================================================
# ULTIMATE BOOTSTRAP - SERVER EDITION (TUI & CLI ONLY)
# =============================================================================

set -e # Exit on error

# Warna untuk output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}==> Memulai Ultimate Bootstrap Setup (Server Edition)...${NC}"

# Detect OS and Package Manager
get_package_manager() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "brew"
  elif command -v apt &>/dev/null; then
    echo "apt"
  elif command -v dnf &>/dev/null; then
    echo "dnf"
  elif command -v pacman &>/dev/null; then
    echo "pacman"
  else
    echo "unknown"
  fi
}

PKG_MANAGER=$(get_package_manager)

# Install Homebrew if on macOS and missing
if [ "$PKG_MANAGER" = "brew" ] && ! command -v brew &>/dev/null; then
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
    if command -v nala &>/dev/null; then
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
if [ "$PKG_MANAGER" = "apt" ] && ! command -v nala &>/dev/null; then
  echo -e "${YELLOW}[1/7] Menginstall Nala...${NC}"
  sudo apt install -y nala
fi

# 2. Install System Packages (TUI & CLI Tools Only)
echo -e "${YELLOW}[2/7] Menginstall paket sistem (Terminal Tools)...${NC}"
CORE_PACKAGES="zsh tmux neovim stow curl git wget build-essential cmake jq fzf ripgrep fd-find lsd bat btop"
for pkg in $CORE_PACKAGES; do
  install_package "$pkg"
done

# Extra CLI Tools
EXTRA_CLI="python3 nodejs gh nmap aircrack-ng gobuster ffmpeg cmatrix graphviz doxygen"
for pkg in $EXTRA_CLI; do
  install_package "$pkg"
done

# 3. Setup Snap Packages (Linux Only)
if [ "$PKG_MANAGER" != "brew" ] && command -v snap &>/dev/null; then
  echo -e "${YELLOW}[3/7] Menginstall Snap packages...${NC}"
  sudo snap install ascii-image-converter || true
fi

# 4. Install Oh My Zsh & Plugins
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo -e "${YELLOW}[4/7] Menginstall Oh My Zsh...${NC}"
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

# 5. Install Zoxide, NVM, Bun
echo -e "${YELLOW}[5/7] Menginstall Zoxide, NVM, dan Bun...${NC}"
if ! command -v zoxide &>/dev/null; then
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

if ! command -v bun &>/dev/null; then
  curl -fsSL https://bun.sh/install | bash
fi

# 6. Setup Tmux Plugins (Catppuccin)
echo -e "${YELLOW}[6/7] Mengatur Tmux Plugins...${NC}"
mkdir -p ~/.config/tmux/plugins
if [ ! -d "$HOME/.config/tmux/plugins/catppuccin" ]; then
  git clone https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin
fi

# 7. Symlink Configurations with Stow
echo -e "${YELLOW}[7/7] Menjalankan Stow...${NC}"
rm -f ~/.zshrc ~/.p10k.zsh ~/.tmux.conf
rm -rf ~/.config/nvim ~/.config/fastfetch
mkdir -p ~/.config

# Pindah ke direktori repository
DOTFILES_DIR=$(pwd)
stow zsh
stow tmux
stow nvim
stow fastfetch

# Finalize
echo -e "${BLUE}==> Mengganti default shell ke Zsh...${NC}"
if [ "$SHELL" != "$(which zsh)" ]; then
  sudo chsh -s $(which zsh) $USER
fi

echo -e "${GREEN}Selesai! Paket server dan konfigurasi telah terpasang.${NC}"
echo -e "${GREEN}Silakan restart terminal Anda atau jalankan 'zsh'.${NC}"
