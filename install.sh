#!/usr/bin/env bash
# Link the files in this repo into $HOME.
# Safe to run more than once: existing real files are backed up first,
# links that already point here are left alone.
#
#   ./install.sh          install
#   ./install.sh --dry    show what would happen, change nothing
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY=0
case "${1:-}" in
    "")          ;;
    --dry|-n)    DRY=1 ;;
    -h|--help)   sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)           echo "unknown option: $1 (try --help)" >&2; exit 2 ;;
esac

run() { if [ "$DRY" -eq 1 ]; then echo "  would run: $*"; else "$@"; fi; }

# source (in repo)  ->  target (in $HOME)
link() {
    local src="$REPO/$1" dst="$HOME/$2"
    if [ "$(readlink -f "$dst" 2>/dev/null)" = "$src" ]; then
        echo "ok      $dst"
        return
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        local backup
        backup="$dst.backup.$(date +%Y%m%d%H%M%S)"
        echo "backup  $dst -> $backup"
        run mv "$dst" "$backup"
    fi
    echo "link    $dst -> $src"
    run mkdir -p "$(dirname "$dst")"
    run ln -s "$src" "$dst"
}

link bash/bashrc  .bashrc
link justfile     .config/just/justfile

# Private settings file, created once from the example, never overwritten.
if [ ! -e "$HOME/.bashrc.local" ]; then
    echo "create  $HOME/.bashrc.local (from bashrc.local.example)"
    run cp "$REPO/bash/bashrc.local.example" "$HOME/.bashrc.local"
fi

# `just` runs the global task list (alias `j`); install it if missing.
if ! command -v just >/dev/null; then
    if command -v apt-get >/dev/null; then
        echo "install just (needs sudo)"
        run sudo apt-get install -y just || echo "WARNING: could not install just; please run: sudo apt install just"
    else
        echo "NOTE: 'just' not found. Please install it manually: https://github.com/casey/just"
    fi
fi

echo
echo "Done. Open a new terminal or run:  source ~/.bashrc"
