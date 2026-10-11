# PATH and toolchain environment.
# Every entry is optional: if the folder does not exist on this machine,
# it is simply skipped, so the same file works on any computer.

# Add a directory to the front of PATH only if it exists and is not there yet
# (re-sourcing ~/.bashrc would otherwise keep growing PATH).
path_prepend() {
    [ -d "$1" ] || return 0
    case ":$PATH:" in
        *":$1:"*) ;;
        *) PATH="$1:$PATH" ;;
    esac
}

# My own scripts
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"

# --- STM32: arm-none-eabi-gcc bundled with STM32CubeIDE --------------------
# The folder name changes with every CubeIDE update, so find it with a glob
# instead of hard-coding the version. The last match (newest) wins.
for d in "$HOME"/st/stm32cubeide_*/plugins/com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.*/tools/bin; do
    [ -d "$d" ] && STM32_GCC_BIN="$d"
done
[ -n "${STM32_GCC_BIN:-}" ] && path_prepend "$STM32_GCC_BIN"
unset d

# --- Raspberry Pi Pico SDK ------------------------------------------------
[ -d "$HOME/pico/pico-sdk" ] && export PICO_SDK_PATH="$HOME/pico/pico-sdk"

# --- Miniconda ------------------------------------------------------------
# Same logic `conda init` writes, but using $HOME instead of a hard-coded
# /home/<user> path. Tip: `conda config --set auto_activate_base false`
# keeps the system Python as default until you run `conda activate`.
# First existing install wins (miniconda3/anaconda3 are the installers' defaults).
for CONDA_HOME in "$HOME/miniconda" "$HOME/miniconda3" "$HOME/anaconda3"; do
    [ -x "$CONDA_HOME/bin/conda" ] && break
done
export CONDA_CHANGEPS1=false   # prompt.sh shows the env itself

if [ -x "$CONDA_HOME/bin/conda" ]; then
    if __conda_setup="$("$CONDA_HOME/bin/conda" shell.bash hook 2>/dev/null)"; then
        eval "$__conda_setup"
    elif [ -f "$CONDA_HOME/etc/profile.d/conda.sh" ]; then
        . "$CONDA_HOME/etc/profile.d/conda.sh"
    else
        path_prepend "$CONDA_HOME/bin"
    fi
    unset __conda_setup
fi

export PATH
export EDITOR="${EDITOR:-nano}"
