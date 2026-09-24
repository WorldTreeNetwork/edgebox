#!/usr/bin/env bash

log() { printf '[edgebox] %s\n' "$*" >&2; }
warn() { printf '[edgebox] WARNING: %s\n' "$*" >&2; }
die() { printf '[edgebox] ERROR: %s\n' "$*" >&2; exit 1; }

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

require_root() {
  [[ ${EUID:-$(id -u)} -eq 0 ]] || die "this phase must run as root"
}

is_true() {
  case "${1:-}" in true|TRUE|yes|YES|1) return 0 ;; *) return 1 ;; esac
}

safe_remove_dir() {
  local target=${1:?target required}
  [[ -n "$target" && "$target" != / && "$target" != "$HOME" ]] || die "refusing unsafe directory removal: $target"
  rm -rf -- "$target"
}
