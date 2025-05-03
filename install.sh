#!/bin/bash

set -e

log() {
    echo -e "\e[1;32m$1\e[0m"
}

confirm() {
    read -rp "$1 [y/N]: " response
    [[ "$response" =~ ^[Yy]$ ]]
}

log "Fedora Setup Script with Confirmation Prompts"

if confirm "Update system packages?"; then
    sudo dnf update -y
fi

if confirm "Install essential packages (git, fzf, go, podman, docker, fastfetch)?"; then
    sudo dnf install -y git fzf go podman docker fastfetch
fi

if confirm "Enable Iosevka font COPR repository?"; then
    sudo dnf copr enable -y peterwu/iosevka
fi

if confirm "Install Iosevka fonts?"; then
    sudo dnf install -y iosevka iosevka-term iosevka-term-fonts.noarch iosevka-ss01-fonts.noarch
    fc-cache -f -v
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"

if confirm "Install zsh-syntax-highlighting plugin?"; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if confirm "Install zsh-autosuggestions plugin?"; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if confirm "Install fzf-tab plugin?"; then
    git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
fi

if confirm "Update .zshrc with plugin list?"; then
    ZSHRC="$HOME/.zshrc"
    if grep -q '^plugins=' "$ZSHRC"; then
        sed -i '/^plugins=/c\plugins=(git zsh-syntax-highlighting zsh-autosuggestions fzf-tab)' "$ZSHRC"
    else
        echo 'plugins=(git zsh-syntax-highlighting zsh-autosuggestions fzf-tab)' >> "$ZSHRC"
    fi

    if confirm "Source .zshrc now?"; then
        source "$ZSHRC"
    fi
fi

if confirm "Install Homebrew?"; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if confirm "Install Ollama?"; then
    curl -fsSL https://ollama.com/install.sh | sh
fi

log "Done! Your custom Fedora setup is complete."
