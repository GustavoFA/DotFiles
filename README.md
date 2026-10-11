# dotfiles

My Bash setup for Ubuntu: aliases, helper functions, a git-aware prompt,
and a global [`just`](https://github.com/casey/just) task list for everyday
system chores. Includes a few shortcuts for embedded work (serial ports,
STM32 and Raspberry Pi Pico toolchains).

## Layout

```
bash/
  bashrc                 entry point, linked to ~/.bashrc
  path.sh                PATH, toolchains (STM32 GCC, Pico SDK, conda)
  functions.sh           mkcd, extract, bak, upd, cleanup, serial, myip, helpme
  prompt.sh              user@host:~/dir (branch)$  — red $ on error
  aliases.sh             short names for common commands
  bashrc.local.example   template for private settings (not committed)
justfile                 global tasks, linked to ~/.config/just/justfile
install.sh               creates the symlinks, backs up existing files
```

## Install

```bash
git clone https://github.com/<your-user>/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --dry      # preview
./install.sh
source ~/.bashrc
j bootstrap             # optional: installs just, picocom, shellcheck...
```

Your previous `~/.bashrc` is kept as `~/.bashrc.backup.<date>`.

## Everyday use

| Command | What it does |
|---|---|
| `helpme` | list all aliases and functions |
| `j` | list global tasks (`j update`, `j disk`, `j lint`) |
| `upd` | apt + snap + flatpak upgrade |
| `cleanup` | clear apt cache, old logs, old snap revisions |
| `bak file` | timestamped copy before editing |
| `extract file` | unpack any archive |
| `serial [port] [baud]` | picocom on the first USB serial device |
| `ttyusb` / `dmesgw` | list serial devices / watch kernel log |
| `reload` | re-source `~/.bashrc` |

## Private settings

Anything machine-specific or secret goes in `~/.bashrc.local`, which is
loaded last and ignored by git.

## Dependencies

* just
* picocom
* shellcheck

To install all the above dependencies, run `j bootstrap`.