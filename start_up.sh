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

set -e

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
  if brew install "$pkg"; then
    mark_success "$pkg"
  else
    mark_failure "$pkg"
  fi
done

# --- Fonts ---
echo "🔤 Installing JetBrainsMono Nerd Font..."
if brew tap homebrew/cask-fonts && brew install --cask font-jetbrains-mono-nerd-font; then
  mark_success "JetBrainsMono Nerd Font"
else
  mark_failure "JetBrainsMono Nerd Font"
fi

# --- Neovim + Kitty + Tmux Cleanup ---
echo "🧹 Removing old Neovim, Kitty, and Tmux configs..."
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
rm -rf ~/.config/kitty
rm -f ~/.tmux.conf
mark_success "Cleaned up old configs"

# --- Symlinking Configs ---
echo "🔗 Linking your config files..."
if ln -sf ~/dotfiles/nvim ~/.config/nvim &&
  ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf &&
  ln -sf ~/dotfiles/kitty ~/.config/kitty; then
  mark_success "Symlinked dotfiles"
else
  mark_failure "Symlinking dotfiles"
fi
