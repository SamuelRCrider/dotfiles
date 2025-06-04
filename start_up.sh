#!/bin/bash

# Track success
installed=()
failed=()

function mark_success() {
  installed+=("$1")
}

function mark_failure() {
  failed+=("$1")
}

function final_report() {
  echo ""
  echo "📋 ---------- Setup Summary ----------"
  if [ "${#installed[@]}" -gt 0 ]; then
    echo "✅ Installed successfully:"
    for item in "${installed[@]}"; do
      echo "   - $item"
    done
  fi
  if [ "${#failed[@]}" -gt 0 ]; then
    echo "❌ Failed to install or configure:"
    for item in "${failed[@]}"; do
      echo "   - $item"
    done
  fi
  echo "--------------------------------------"
  if [ "${#failed[@]}" -gt 0 ]; then
    echo "⚠️ Some steps failed. Please review and rerun this script or fix manually."
    exit 1
  else
    echo "🎉 All steps completed successfully!"
    echo "➡️ Open Kitty (set JetBrainsMono Nerd Font if needed), then run 'nvim' to let LazyVim sync plugins."
  fi
}

trap final_report EXIT
set -eo pipefail

# --- Prerequisite Checks ---
echo "🔍 Checking prerequisites..."
if [ ! -d "$HOME/dotfiles" ]; then
  echo "❌ ~/dotfiles directory not found. Please clone your dotfiles repo there first."
  mark_failure "dotfiles directory"
  exit 1
fi

for item in nvim .tmux.conf kitty; do
  if [ ! -e "$HOME/dotfiles/$item" ]; then
    echo "❌ Missing ~/dotfiles/$item."
    mark_failure "$item config"
    exit 1
  fi
done

# --- Homebrew ---
echo "🔧 Installing Homebrew..."
if ! command -v brew >/dev/null; then
  if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    mark_success "Homebrew"
  else
    mark_failure "Homebrew"
  fi
else
  mark_success "Homebrew (already installed)"
fi

# --- Package Installs ---
echo "🍺 Installing packages..."
for pkg in kitty tmux neovim lazygit fzf ripgrep fd; do
  if brew list "$pkg" &>/dev/null; then
    mark_success "$pkg (already installed)"
  elif brew install "$pkg"; then
    mark_success "$pkg"
  else
    mark_failure "$pkg"
  fi
done

# --- Fonts ---
echo "🔤 Installing JetBrainsMono Nerd Font..."
brew tap homebrew/cask-fonts || true
if brew install --cask font-jetbrains-mono-nerd-font; then
  mark_success "JetBrainsMono Nerd Font"
else
  mark_failure "JetBrainsMono Nerd Font"
fi

# --- Cleanup ---
echo "🧹 Removing old Neovim config..."
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
mark_success "Neovim config cleanup"

echo "📦 Backing up existing Kitty and Tmux configs..."
timestamp=$(date +%s)
if [ -d ~/.config/kitty ]; then
  mv ~/.config/kitty ~/.config/kitty.bak.$timestamp
  echo "  - Backed up ~/.config/kitty to ~/.config/kitty.bak.$timestamp"
fi
if [ -f ~/.tmux.conf ]; then
  mv ~/.tmux.conf ~/.tmux.conf.bak.$timestamp
  echo "  - Backed up ~/.tmux.conf to ~/.tmux.conf.bak.$timestamp"
fi
mark_success "Backed up Kitty and Tmux configs"

# --- Symlinking Configs ---
echo "🔗 Linking your config files..."
mkdir -p ~/.config
if ln -s ~/dotfiles/nvim ~/.config/nvim &&
  ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf &&
  ln -s ~/dotfiles/kitty ~/.config/kitty; then
  mark_success "Symlinked dotfiles"
else
  mark_failure "Symlinking dotfiles"
fi

# --- Validate Symlinks ---
echo "✅ Verifying symlink integrity..."
if [ -L ~/.config/nvim ] && [ -e ~/.config/nvim ]; then
  mark_success "Verified nvim symlink"
else
  mark_failure "nvim symlink broken"
fi
if [ -L ~/.tmux.conf ] && [ -e ~/.tmux.conf ]; then
  mark_success "Verified tmux.conf symlink"
else
  mark_failure "tmux.conf symlink broken"
fi
if [ -L ~/.config/kitty ] && [ -e ~/.config/kitty ]; then
  mark_success "Verified kitty symlink"
else
  mark_failure "kitty symlink broken"
fi
