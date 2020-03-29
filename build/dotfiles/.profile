function _update_ps1() {
    PS1="$(powerline-go -error $? -condensed -numeric-exit-codes -theme low-contrast -modules "cwd,docker,kube,git,exit")"
}
export -f _update_ps1

PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
export PROMPT_COMMAND
