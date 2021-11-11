#!/bin/zsh

zmodload zsh/zpty || { echo 'error: missing module zsh/zpty' >&2; exit 1 }

# spawn shell
zpty z zsh -i

# line buffer for pty output
local line

# swallow input of zshrc, disable hooks and disable PROMPT
# the prompt should be disabled here (before init) in case a prompt theme has
# a verbose prompt
zpty -w z "autoload add-zsh-hook"
zpty -w z "add-zsh-hook -D precmd '*'"
zpty -w z "add-zsh-hook -D preexec '*'"
zpty -w z "PROMPT="
zpty -w z "echo thisisalonganduniquestringtomarktheendoftheinit >/dev/null"
zpty -r z line
while [[ $line != *'thisisalonganduniquestringtomarktheendoftheinit'* ]]; do
    zpty -r z line
done

source ${0:h}/cmp_capture_shared.zsh
