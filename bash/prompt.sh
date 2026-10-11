# Prompt:  user@host:~/project (main)$
# Green user@host, blue path, yellow git branch, and a red $ when the last
# command failed.

# Prints " (branch)" when inside a git repo, nothing otherwise.
__git_branch() {
    local b
    b=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null) || return
    printf ' (%s)' "$b"
}

__set_prompt() {
    local status=$?          # must be read first: exit code of the last command
    local green='\[\e[01;32m\]' blue='\[\e[01;34m\]' yellow='\[\e[33m\]'
    local red='\[\e[01;31m\]' reset='\[\e[0m\]'
    local mark="${reset}\$"
    [ "$status" -ne 0 ] && mark="${red}\$${reset}"

    # Window title: user@host: dir
    local title='\[\e]0;\u@\h: \w\a\]'
    # Active conda env, if any, e.g. "(base) "
    local env="${CONDA_DEFAULT_ENV:+($CONDA_DEFAULT_ENV) }"

    PS1="${title}${env}${green}\u@\h${reset}:${blue}\w${yellow}\$(__git_branch)${reset}${mark} "
}

PROMPT_COMMAND="__set_prompt${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
