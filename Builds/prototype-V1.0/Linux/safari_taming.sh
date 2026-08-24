#!/bin/sh
printf '\033c\033]0;%s\a' safari_taming
base_path="$(dirname "$(realpath "$0")")"
"$base_path/safari_taming.x86_64" "$@"
