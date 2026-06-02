autoload -Uz vcs_info
setopt prompt_subst

typeset -U path
path=("$HOME/.local/bin" "$HOME/bin" $path)

precmd() {
  vcs_info
}

zstyle ':vcs_info:git:*' formats ' (%b)'
zstyle ':vcs_info:git:*' actionformats ' (%b|%a)'

PROMPT='%F{#a9b665}%1~%f%F{#7daea3}${vcs_info_msg_0_}%f %(!.#.$) '

if [ -S "$XDG_RUNTIME_DIR/keyring/ssh" ]; then
  export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/keyring/ssh"
fi
