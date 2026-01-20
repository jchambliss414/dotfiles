#!/bin/bash
# /shared/dotfiles/install.sh

set -e

DOTFILES="/shared/dotfiles"

echo "=== Creating symlinks ==="
mkdir -p ~/.config

ln -sf "$DOTFILES/config/nvim" ~/.config/nvim
ln -sf "$DOTFILES/config/tmux" ~/.config/tmux
ln -sf "$DOTFILES/.taskrc" ~/.taskrc

echo "=== Installing TPM ==="
if [ ! -d ~/.config/tmux/plugins/tpm ]; then
   git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
fi

echo "=== Adding bash_aliases to .bashrc ==="
if ! grep -q "source.*dotfiles/bash_aliases" ~/.bashrc; then
   echo 'source /shared/dotfiles/bash_aliases' >>~/.bashrc
fi

echo "=== Done! ==="
echo "Next steps:"
echo "  1. source ~/.bashrc"
echo "  2. Open tmux and press prefix + I to install plugins"
echo "  3. Open nvim (plugins install automatically)"
