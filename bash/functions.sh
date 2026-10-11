# Small shell functions. Unlike aliases, these take arguments, can run in
# the current shell (needed for `cd`), and can contain logic.

# Create a directory and enter it:   mkcd ~/projects/new-board
mkcd() {
    mkdir -p -- "$1" && cd -- "$1" || return
}

# Extract almost any archive:   extract firmware.tar.gz
extract() {
    [ -f "$1" ] || { echo "extract: '$1' is not a file" >&2; return 1; }
    case "$1" in
        *.tar.gz|*.tgz)   tar xzf "$1" ;;
        *.tar.bz2|*.tbz2) tar xjf "$1" ;;
        *.tar.xz|*.txz)   tar xJf "$1" ;;
        *.tar.zst)        tar --zstd -xf "$1" ;;
        *.tar)            tar xf "$1" ;;
        *.zip)            unzip "$1" ;;
        *.gz)             gunzip "$1" ;;
        *.bz2)            bunzip2 "$1" ;;
        *.xz)             unxz "$1" ;;
        *.zst)            unzstd "$1" ;;
        *.7z)             7z x "$1" ;;
        *.rar)            unrar x "$1" ;;
        *) echo "extract: don't know how to extract '$1'" >&2; return 1 ;;
    esac
}

# Timestamped backup copy before editing a config:   bak /etc/fstab
#   -> /etc/fstab.2026-10-11_0951.bak
bak() {
    local f stamp
    stamp=$(date +%F_%H%M)
    for f in "$@"; do
        cp -a -- "$f" "$f.$stamp.bak" && echo "saved $f.$stamp.bak"
    done
}

# Update everything: apt, snap, flatpak (only the ones installed).
upd() {
    sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove --purge -y
    command -v snap    >/dev/null && sudo snap refresh
    command -v flatpak >/dev/null && flatpak update -y
    [ -f /var/run/reboot-required ] && echo ">>> Reboot required."
    return 0
}

# Free disk space: apt cache, old journal logs, disabled snap revisions.
cleanup() {
    sudo apt autoremove --purge -y && sudo apt clean
    sudo journalctl --vacuum-time=14d
    if command -v snap >/dev/null; then
        snap list --all | awk '/disabled/{print $1, $3}' |
            while read -r name rev; do sudo snap remove "$name" --revision="$rev"; done
    fi
    df -h /
}

# Open a serial monitor:   serial            -> first ttyUSB/ttyACM, 115200
#                          serial /dev/ttyACM0 9600
# Exit picocom with Ctrl-A Ctrl-X. Needs: sudo apt install picocom
# (and your user in the dialout group: sudo usermod -aG dialout "$USER")
serial() {
    local port="${1:-}" baud="${2:-115200}"
    command -v picocom >/dev/null || { echo "serial: picocom not installed (run: j bootstrap)" >&2; return 1; }
    if [ -z "$port" ]; then
        # first existing device; the trailing "" leaves port empty if none match
        for port in /dev/ttyUSB* /dev/ttyACM* ""; do [ -e "$port" ] && break; done
        [ -n "$port" ] || { echo "serial: no /dev/ttyUSB* or /dev/ttyACM* found" >&2; return 1; }
    fi
    echo "Opening $port @ $baud (Ctrl-A Ctrl-X to quit)"
    picocom -b "$baud" "$port"
}

# Local and public IP addresses
myip() {
    echo "local : $(hostname -I | awk '{print $1}')"
    echo "public: $(curl -s --max-time 3 https://ifconfig.me || echo unavailable)"
}

# List my own aliases and functions with their one-line description.
# The description is the trailing `# comment` of an alias, or the first line
# of the comment block right above it (text after ":   " is dropped).
# Functions starting with "_" are treated as private and skipped.
helpme() {
    local f
    for f in "$DOTFILES_BASH"/aliases.sh "$DOTFILES_BASH"/functions.sh; do
        echo "== $(basename "$f")"
        awk '
            /^#/ {
                if (!incomment) { above = $0; sub(/^#[ \t]*/, "", above); sub(/:[ \t][ \t]+.*/, "", above); sub(/\.$/, "", above) }
                if (above ~ /^---/) above = ""     # section headers are not descriptions
                incomment = 1; next
            }
            { hasabove = incomment; incomment = 0 }
            /^alias / {
                line = $0; sub(/^alias (-- )?/, "", line)
                name = line; sub(/=.*/, "", name)
                if (match(line, /[ \t]#[ \t]/)) desc = substr(line, RSTART + 3)
                else if (hasabove && above != "") desc = above
                else { desc = line; sub(/^[^=]*=/, "", desc); gsub(/^'\''|'\''$/, "", desc); if (length(desc) > 50) desc = substr(desc, 1, 47) "..." }
                printf "  %-10s %s\n", name, desc
            }
            /^[a-z][a-z0-9_]*\(\) \{/ {
                name = $0; sub(/\(.*/, "", name)
                printf "  %-10s %s\n", name, (hasabove ? above : "")
            }
        ' "$f"
    done
}
