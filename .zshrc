autoload -Uz vcs_info
setopt prompt_subst

typeset -U path
path=("$HOME/.local/bin" "$HOME/bin" $path)

codex() {
  case "${1:-}" in
    login|logout|plugin|mcp-server|app-server|remote-control|completion|update|doctor|apply|a|cloud|exec-server|features|help|-h|--help|-V|--version)
      command codex "$@"
      ;;
    *)
      command codex --profile statusline "$@"
      ;;
  esac
}

precmd() {
  vcs_info
}

zstyle ':vcs_info:git:*' formats ' (%b)'
zstyle ':vcs_info:git:*' actionformats ' (%b|%a)'

PROMPT='%F{#a9b665}%1~%f%F{#7daea3}${vcs_info_msg_0_}%f %(!.#.$) '

if [ -S "$XDG_RUNTIME_DIR/keyring/ssh" ]; then
  export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/keyring/ssh"
fi

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


# Load Angular CLI autocompletion.
if (( $+commands[ng] )); then
  source <(ng completion script)
fi
