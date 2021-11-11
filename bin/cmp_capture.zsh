#!/usr/bin/env zsh

zmodload zsh/zpty || { echo 'error: missing module zsh/zpty' >&2; exit 1 }

# spawn shell
zpty z zsh -f -i

source ${0:h}/cmp_capture_shared.zsh
