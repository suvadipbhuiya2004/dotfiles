#!/bin/bash

# This script installs rustup, neovim, paru, LazyVim, and other tools
# on an Arch-based system.
# It requires 'sudo' privileges for installing packages.

# --- Define colors for output ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Helper functions for logging ---
info() {
  echo -e "${BLUE}[INFO] $1${NC}"
}

success() {
  echo -e "${GREEN}[SUCCESS] $1${NC}"
}

warn() {
  echo -e "${YELLOW}[WARN] $1${NC}"
}

error() {
  echo -e "${RED}[ERROR] $1${NC}" >&2
  exit 1
}

# --- Function to check for Arch-based distro ---
check_distro() {
  info "Checking operating system..."
  if ! command -v pacman &>/dev/null; then
    error "This script is intended for Arch-based distributions (uses pacman and AUR)."
  fi
  success "Arch-based system detected."
}

# --- Function to install Rustup ---
install_rustup() {
  info "--- Starting Rustup Installation ---"
  if command -v rustup &>/dev/null; then
    warn "Rustup is already installed. Skipping..."
  else
    info "Installing rustup using pacman..."
    sudo pacman -S --needed rustup -y --noconfirm
    if [ $? -ne 0 ]; then
      error "Rustup installation failed."
    fi
  fi

  info "Setting default Rust toolchain to 'stable'..."
  rustup default stable
  if [ $? -ne 0 ]; then
    error "Failed to set default Rust toolchain to stable."
  fi
  success "--- Rustup installation and configuration complete. ---"
}

# --- Function to install Neovim & LazyVim ---
install_neovim_and_lazyvim() {
  info "--- Starting Neovim & LazyVim Installation ---"

  # 1. Install Neovim
  if command -v nvim &>/dev/null; then
    warn "Neovim is already installed. Skipping pacman install..."
  else
    info "Installing Neovim using pacman..."
    sudo pacman -S --needed neovim -y --noconfirm
    if [ $? -ne 0 ]; then
      error "Neovim installation failed."
    fi
    success "Neovim installation complete."
  fi

  # 2. Install LazyVim
  info "Backing up any existing Neovim configuration..."
  CONFIG_DIR="$HOME/.config/nvim"
  SHARE_DIR="$HOME/.local/share/nvim"
  STATE_DIR="$HOME/.local/state/nvim"
  CACHE_DIR="$HOME/.cache/nvim"

  [ -d "$CONFIG_DIR" ] && mv "$CONFIG_DIR" "${CONFIG_DIR}.bak"
  [ -d "$SHARE_DIR" ] && mv "$SHARE_DIR" "${SHARE_DIR}.bak"
  [ -d "$STATE_DIR" ] && mv "$STATE_DIR" "${STATE_DIR}.bak"
  [ -d "$CACHE_DIR" ] && mv "$CACHE_DIR" "${CACHE_DIR}.bak"

  info "Cloning LazyVim starter repository..."
  git clone https://github.com/LazyVim/starter "$CONFIG_DIR"
  if [ $? -ne 0 ]; then
    error "Failed to clone LazyVim starter."
  fi

  success "--- Neovim & LazyVim installation complete. ---"
  info "Run 'nvim' to complete the setup (plugins will be installed on first run)."
}

# --- Function to install paru (AUR helper) ---
install_paru() {
  info "--- Starting paru (AUR Helper) Installation ---"
  if command -v paru &>/dev/null; then
    warn "paru is already installed. Skipping..."
  else
    # Install dependencies to build packages
    info "Installing paru dependencies (base-devel, git)..."
    sudo pacman -S --needed base-devel git -y --noconfirm
    if [ $? -ne 0 ]; then
      error "Failed to install paru dependencies."
    fi

    # Clone and build paru from the AUR
    info "Cloning and building paru from AUR..."
    BUILD_DIR="/tmp/paru-build"
    [ -d "$BUILD_DIR" ] && rm -rf "$BUILD_DIR" # Clean up old build dir

    git clone https://aur.archlinux.org/paru.git "$BUILD_DIR"
    if [ $? -ne 0 ]; then
      error "Failed to clone paru repository."
    fi

    cd "$BUILD_DIR"
    # Build and install, pausing for user confirmation
    makepkg -si
    if [ $? -ne 0 ]; then
      error "Failed to build or install paru."
    fi

    # Cleanup
    cd - >/dev/null
    rm -rf "$BUILD_DIR"
    success "--- paru installation complete. ---"
  fi
}

# --- Function to install Zoxide ---
install_zoxide() {
  info "--- Starting Zoxide Installation ---"
  if command -v zoxide &>/dev/null; then
    warn "Zoxide is already installed. Skipping..."
  else
    info "Installing Zoxide using pacman..."
    sudo pacman -S --needed zoxide -y --noconfirm
    if [ $? -ne 0 ]; then
      error "Zoxide installation failed."
    fi
    success "Zoxide installation complete."
    info "Add 'zoxide init bash' (or zsh/fish) to your shell config to use it."
  fi
}

# --- Function to install Eza ---
install_eza() {
  info "--- Starting Eza Installation ---"
  if command -v eza &>/dev/null; then
    warn "Eza is already installed. Skipping..."
  else
    info "Installing Eza using pacman..."
    sudo pacman -S --needed eza -y --noconfirm
    if [ $? -ne 0 ]; then
      error "Eza installation failed."
    fi
    success "Eza installation complete."
  fi
}

# --- Function to install fzf ---
install_fzf() {
  info "--- Starting fzf Installation ---"
  if command -v fzf &>/dev/null; then
    warn "fzf is already installed. Skipping..."
  else
    info "Installing fzf using pacman..."
    sudo pacman -S --needed fzf -y --noconfirm
    if [ $? -ne 0 ]; then
      error "fzf installation failed."
    fi
    success "fzf installation complete."
  fi
}

# --- Function to install Zed ---
install_zed() {
  info "--- Starting Zed Editor Installation ---"
  if command -v zed &>/dev/null; then
    warn "Zed is already installed. Skipping..."
  else
    info "Installing Zed using pacman..."
    sudo pacman -S --needed zed -y --noconfirm
    if [ $? -ne 0 ]; then
      error "Zed installation failed."
    fi
    success "Zed installation complete."
  fi
}

# --- Function to install vivaldi ---
install_vivaldi() {
  info "--- Starting vivaldi Editor Installation ---"
  if command -v vivaldi &>/dev/null; then
    warn "vivaldi is already installed. Skipping..."
  else
    info "Installing vivaldi using pacman..."
    sudo pacman -S --needed vivaldi -y --noconfirm
    if [ $? -ne 0 ]; then
      error "vivaldi installation failed."
    fi
    success "vivaldi installation complete."
  fi
}

# --- Function to install VS Code (AUR) ---
install_vscode() {
  info "--- Starting VS Code (AUR) Installation ---"
  if ! command -v paru &>/dev/null; then
    error "paru is not installed. Cannot install VS Code from AUR."
    return 1
  fi

  if command -v code &>/dev/null; then
    warn "VS Code (visual-studio-code-bin) is already installed. Skipping..."
  else
    info "Installing visual-studio-code-bin using paru (will ask for confirmation)..."
    paru -S visual-studio-code-bin
    if [ $? -ne 0 ]; then
      error "VS Code installation failed."
    fi
    success "VS Code installation complete."
  fi
}

# --- Function to install arch-update (AUR) ---
install_arch_update() {
  info "--- Starting arch-update (AUR) Installation ---"
  if ! command -v paru &>/dev/null; then
    error "paru is not installed. Cannot install arch-update from AUR."
    return 1
  fi

  if command -v arch-update &>/dev/null; then
    warn "arch-update is already installed. Skipping..."
  else
    info "Installing arch-update using paru (will ask for confirmation)..."
    paru -S arch-update
    if [ $? -ne 0 ]; then
      error "arch-update installation failed."
    fi
    success "arch-update installation complete."
  fi
}

# --- Function to install Nerd Fonts ---
install_nerd_fonts() {
  info "--- Starting Fira Code Nerd Font Installation ---"
  if pacman -Qq ttf-firacode-nerd &>/dev/null; then
    warn "ttf-firacode-nerd is already installed. Skipping..."
  else
    info "Installing ttf-firacode-nerd using pacman..."
    sudo pacman -S --needed ttf-firacode-nerd ttf-jetbrains-mono-nerd -y --noconfirm
    if [ $? -ne 0 ]; then
      error "Nerd Font installation failed."
    fi
    success "Nerd Font installation complete."
    info "Run 'fc-cache -fv' to update font cache if needed."
  fi
}

# --- Function to install Kitty ---
install_kitty() {
  info "--- Starting Kitty Terminal Installation ---"
  if command -v kitty &>/dev/null; then
    warn "Kitty is already installed. Skipping..."
  else
    info "Installing kitty using pacman..."
    sudo pacman -S --needed kitty -y --noconfirm
    if [ $? -ne 0 ]; then
      error "Kitty installation failed."
    fi
    success "Kitty installation complete."
  fi
}

# --- Function to install Steam ---
install_steam() {
  info "--- Starting Steam Installation ---"

  info "Enabling multilib repository in /etc/pacman.conf..."
  # Uncomment [multilib] and the line below it
  sudo sed -i '/^#\[multilib\]$/,/^#Include = \/etc\/pacman.d\/mirrorlist$/s/^#//' /etc/pacman.conf

  info "Synchronizing pacman databases (required for multilib)..."
  sudo pacman -Sy

  if pacman -Qq steam &>/dev/null; then
    warn "Steam is already installed. Skipping..."
  else
    info "Installing steam using pacman (will ask for confirmation)..."
    sudo pacman -S steam
    if [ $? -ne 0 ]; then
      error "Steam installation failed."
    fi
    success "Steam installation complete."
  fi
}

# --- Function to install Flatpak ---
install_flatpak() {
  info "--- Starting Flatpak Installation ---"
  if command -v flatpak &>/dev/null; then
    warn "Flatpak is already installed. Skipping..."
  else
    info "Installing flatpak using pacman..."
    sudo pacman -S --needed flatpak -y --noconfirm
    if [ $? -ne 0 ]; then
      error "Flatpak installation failed."
    fi
    success "Flatpak installation complete."
  fi
}

# --- Function to install starship ---
install_starship() {
  info "--- Starting starship Installation ---"
  if command -v starship &>/dev/null; then
    warn "starship is already installed. Skipping..."
  else
    info "Installing starship using pacman..."
    sudo pacman -S --needed starship -y --noconfirm
    if [ $? -ne 0 ]; then
      error "starship installation failed."
    fi
    success "starship installation complete."
    info "Add 'eval \"\$(starship init bash)\"' (or zsh/fish) to your shell config to use it."
  fi
}

# --- Function to install ML4W Wallpapers ---
install_ml4w_wallpapers() {
  info "--- Starting ML4W Wallpapers Installation ---"
  WALLPAPER_DIR="$HOME/Pictures/wallpaper"

  if [ -d "$WALLPAPER_DIR" ]; then
    warn "Wallpaper directory $WALLPAPER_DIR already exists."
    info "Pulling latest changes..."
    cd "$WALLPAPER_DIR"
    git pull
    cd - >/dev/null
  else
    info "Cloning wallpaper repository into $HOME/Pictures..."
    mkdir -p "$HOME/Pictures"
    cd "$HOME/Pictures"
    git clone --depth=1 https://github.com/mylinuxforwork/wallpaper.git
    cd - >/dev/null
  fi
  success "--- ML4W Wallpapers installation/update complete. ---"
}

# --- Function to copy local dotfiles ---
copy_dotfiles() {
  info "--- Starting Dotfile Copy ---"

  # Define source and destination files
  BASHRC_SRC=".bashrc"
  INPUTRC_SRC=".inputrc"
  STARSHIP_SRC="starship.toml"

  BASHRC_DEST="$HOME/.bashrc"
  INPUTRC_DEST="$HOME/.inputrc"
  STARSHIP_DEST_DIR="$HOME/.config"
  STARSHIP_DEST_FILE="$STARSHIP_DEST_DIR/starship.toml"

  # --- Copy .bashrc ---
  if [ -f "$BASHRC_SRC" ]; then
    info "Found $BASHRC_SRC."
    # info "Backing up existing $BASHRC_DEST..."
    # [ -f "$BASHRC_DEST" ] && mv "$BASHRC_DEST" "${BASHRC_DEST}.bak"
    info "Copying $BASHRC_SRC to $HOME (overwriting if present)..."
    cp "$BASHRC_SRC" "$BASHRC_DEST"
    success "$BASHRC_SRC copied."
  else
    warn "$BASHRC_SRC not found in the current directory. Skipping."
  fi

  # --- Copy .inputrc ---
  if [ -f "$INPUTRC_SRC" ]; then
    info "Found $INPUTRC_SRC."
    info "Copying $INPUTRC_SRC to $HOME (overwriting if present)..."
    cp "$INPUTRC_SRC" "$INPUTRC_DEST"
    success "$INPUTRC_SRC copied."
  else
    warn "$INPUTRC_SRC not found in the current directory. Skipping."
  fi

  # --- Copy starship.toml ---
  if [ -f "$STARSHIP_SRC" ]; then
    info "Found $STARSHIP_SRC."
    info "Ensuring $STARSHIP_DEST_DIR exists..."
    mkdir -p "$STARSHIP_DEST_DIR"

    # info "Backing up existing $STARSHIP_DEST_FILE..."
    # [ -f "$STARSHIP_DEST_FILE" ] && mv "$STARSHIP_DEST_FILE" "${STARSHIP_DEST_FILE}.bak"

    info "Copying $STARSHIP_SRC to $STARSHIP_DEST_DIR (overwriting if present)..."
    cp "$STARSHIP_SRC" "$STARSHIP_DEST_FILE"
    success "$STARSHIP_SRC copied."
  else
    warn "$STARSHIP_SRC not found in the current directory. Skipping."
  fi

  success "--- Dotfile copy complete. ---"
}

# --- Main function to run all installations ---
main() {
  check_distro

  # --- Core Package Installations (pacman) ---
  info "--- Starting Core Package Installations (pacman) ---"
  install_rustup
  install_neovim_and_lazyvim
  install_zoxide
  install_eza
  install_fzf
  install_zed
  install_nerd_fonts
  install_kitty
  install_steam
  install_flatpak
  install_starship
  install_vivaldi

  # --- AUR Installations ---
  info "--- Starting AUR Installations (paru) ---"
  install_paru # Must be run before other AUR packages
  install_vscode
  install_arch_update

  # --- Other Installations ---
  info "--- Starting Other Installations ---"
  install_ml4w_wallpapers
  copy_dotfiles

  echo -e "\n${GREEN}--- All installations are complete! ---${NC}"
  info "Please close and reopen your terminal or run 'source ~/.bashrc' (or ~/.zshrc) to ensure all environment variables are loaded."
  info "Remember to run 'nvim' to complete the LazyVim plugin setup."
  info "For zoxide, add 'zoxide init <your_shell>' to your shell's config file."
  info "For starship, add 'eval \"\$(starship init <your_shell>)\"' to your shell's config file."
}

# Run the main function
main
