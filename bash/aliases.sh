# Short names for commands I type often.
# Rule of thumb: an alias is a pure text substitution. Anything that needs
# arguments in the middle, logic, or more than one line goes in functions.sh.

# --- listing & navigation ---
alias ls='ls --color=auto --group-directories-first'
alias ll='ls -alFh'          # long list, hidden files, human sizes
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -alFht'         # newest first
alias ..='cd ..'
alias ...='cd ../..'
alias -- -='cd -'            # `-` jumps back to the previous directory

# --- safety: ask before overwriting/deleting ---
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I'             # asks once when deleting >3 files or recursively
alias mkdir='mkdir -pv'

# --- grep (fgrep/egrep are deprecated; use grep -F / grep -E) ---
alias grep='grep --color=auto'

# --- system info ---
alias df='df -h -x tmpfs -x squashfs -x devtmpfs'   # real disks only, no snap loops
alias du1='du -h --max-depth=1 | sort -h'           # size of each subfolder
alias free='free -h'
alias ports='ss -tulpn'                             # listening TCP/UDP ports
alias psg='ps aux | grep -v grep | grep -i'         # psg firefox
alias h='history | grep -i'                         # h esptool
alias path='tr ":" "\n" <<< "$PATH"'                # one PATH entry per line
alias reload='source ~/.bashrc && echo "bashrc reloaded"'

# --- git ---
alias gs='git status -sb'
alias gl='git log --oneline --graph --decorate -20'
alias gd='git diff'

# --- task runner: global justfile (~/.config/just/justfile) ---
alias j='just -g'

# --- embedded ---
alias ttyusb='ls -l /dev/ttyUSB* /dev/ttyACM* 2>/dev/null || echo "no serial devices"'
alias dmesgw='sudo dmesg -wT'                       # watch kernel log live (plug a board in)

# Desktop notification when a long command ends:   make -j8; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
