#!/usr/bin/env bash

log() { printf '[edgebox-first-boot] %s\n' "$*"; }
die() { printf '[edgebox-first-boot] ERROR: %s\n' "$*" >&2; exit 1; }

step_done() { [[ -f "/var/lib/edgebox/steps/$1.done" ]]; }
mark_step_done() { install -D -m 0600 /dev/null "/var/lib/edgebox/steps/$1.done"; }

run_step() {
  local name=${1:?name required}
  shift
  if step_done "$name"; then log "step already complete: $name"; return 0; fi
  log "starting step: $name"
  "$@"
  mark_step_done "$name"
  log "completed step: $name"
}

profile_enabled() {
  local wanted=${1:?profile required}
  local profiles=",${EDGEBOX_PROFILES// /},"
  [[ "$profiles" == *",$wanted,"* ]]
}

load_env_file() {
  local file=${1:?configuration file required}
  [[ -r "$file" ]] || die "configuration file is not readable: $file"
  while IFS='=' read -r key value; do
    [[ -z "$key" || "$key" == \#* ]] && continue
    [[ "$key" =~ ^[A-Z][A-Z0-9_]*$ ]] || die "invalid configuration key in $file: $key"
    printf -v "$key" '%s' "$value"
    # shellcheck disable=SC2163 # Export the validated dynamic key.
    export "$key"
  done < "$file"
}
