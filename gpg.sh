set -e

log() {
    echo -e "\e[1;32m$1\e[0m"
}

confirm() {
    read -rp "$1 [y/N]: " response
    [[ "$response" =~ ^[Yy]$ ]]
}

if confirm "Set up GPG signing for GitHub?"; then
    # Check for existing GPG keys
    if gpg --list-secret-keys --keyid-format=long | grep -q sec; then
        log "GPG keys found:"
        gpg --list-secret-keys --keyid-format=long
        read -rp "Enter the GPG key ID you want to use (e.g. 3AA5C34371567BD2): " gpg_key_id
    else
        log "No GPG key found. Creating a new one..."

        read -rp "Enter your name for the GPG key: " gpg_name
        read -rp "Enter your email for the GPG key: " gpg_email

        cat > gpg_batch <<EOF
        %no-protection
        Key-Type: RSA
        Key-Length: 4096
        Subkey-Type: RSA
        Subkey-Length: 4096
        Name-Real: $gpg_name
        Name-Email: $gpg_email
        Expire-Date: 0
        %commit
EOF

        gpg --batch --gen-key gpg_batch
        rm -f gpg_batch

        gpg_key_id=$(gpg --list-secret-keys --keyid-format=long "$gpg_email" | grep '^sec' | awk '{print $2}' | cut -d'/' -f2)
    fi

    log "Your public GPG key:"
    gpg --armor --export "$gpg_key_id"

    echo -e "\n🔗 Copy the above GPG key to GitHub: https://github.com/settings/keys\n"
    read -rp "Press Enter once you've added the key to GitHub..."

    log "Configuring Git to sign commits with your GPG key..."
    git config --global user.signingkey "$gpg_key_id"
    git config --global commit.gpgsign true

    log "✅ GPG signing is now enabled for Git!"
fi
