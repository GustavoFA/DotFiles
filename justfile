# Global task list, linked to ~/.config/just/justfile by install.sh.
# Run from anywhere with `just -g <recipe>` (alias: j <recipe>).
# `j` alone lists everything below with its comment.

set shell := ["bash", "-uc"]

# List the recipes
default:
    @just -g --list

# Update apt, snap and flatpak packages
update:
    sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove --purge -y
    -command -v snap >/dev/null && sudo snap refresh
    -command -v flatpak >/dev/null && flatpak update -y
    @[ ! -f /var/run/reboot-required ] || echo ">>> Reboot required."

# Install the tools these dotfiles use
bootstrap:
    sudo apt install -y git just picocom curl unzip p7zip-full shellcheck
    sudo usermod -aG dialout "$USER"
    @echo "Log out and back in for the dialout group (serial ports) to apply."

# Show disk usage, biggest folders in $HOME
disk:
    df -h -x tmpfs -x squashfs -x devtmpfs
    du -h --max-depth=1 ~ 2>/dev/null | sort -h | tail -15

# Pull the latest dotfiles and reinstall the links
dotfiles-update:
    cd "$(dirname "$(readlink -f ~/.bashrc)")/.." && git pull --ff-only && ./install.sh

# Lint every shell file in the dotfiles repo
lint:
    cd "$(dirname "$(readlink -f ~/.bashrc)")/.." && shellcheck -S warning -s bash install.sh bash/*
