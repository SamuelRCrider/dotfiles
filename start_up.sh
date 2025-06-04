#!/bin/bash

set -e

# --- Prerequisite Checks ---
echo "🔍 Checking prerequisites..."

if [ ! -d "$HOME/dotfiles" ]; then
  echo "❌ ~/dotfiles directory not found. Please clone your dotfiles repo there first."
  exit 1
fi

for item in nvim .tmux.conf kitty; do
  if [ ! -e "$HOME/dotfiles/$item" ]; then
    echo "❌ Missing ~/dotfiles/$item. Please ensure your config is there."
    exit 1
  fi
done

# --- Homebrew ---
echo "🔧 Installing Homebrew..."
if ! command -v brew >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# --- Package Installs ---
echo "🍺 Installing packages via Homebrew..."
brew install kitty tmux neovim lazygit fzf ripgrep fd

# --- Fonts ---
echo "🔤 Installing JetBrainsMono Nerd Font..."
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font

# --- Neovim Cleanup ---
echo "🧹 Removing old Neovim state..."
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
echo "🧹 Removing old Kitty and Tmux configs..."
rm -rf ~/.config/kitty
rm -f ~/.tmux.conf

# --- Symlinking Configs ---
echo "🔗 Linking your config files..."
ln -sf ~/dotfiles/nvim ~/.config/nvim
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/kitty ~/.config/kitty

echo "🎉 All done!"
echo "➡️ Open Kitty (set JetBrainsMono Nerd Font if needed), then run 'nvim' to let LazyVim sync plugins."
