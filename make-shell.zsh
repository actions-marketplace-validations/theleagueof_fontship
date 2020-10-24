#!/usr/bin/env zsh

set -o nomatch
set -o pipefail

local status() {
  echo -e "$@"
}

local pre_hook() {
  status "FONTSHIPPRE$target"
}

local post_hook() {
  status "FONTSHIPPOST$2$target"
}

local report_stdout() {
  cat - |
    while read line; do
      echo -e "FONTSHIPSTDOUT$target$line"
    done
}

local report_stderr() {
  cat - |
    while read line; do
      echo -e "FONTSHIPSTDERR$target$line" >&2
    done
}

local process_recipe() {
  pre_hook $target
  {
    (
      set -e
      eval $@ >(report_stdout) 2>(report_stdout)
    )
  } always {
    post_hook $target $?
  }
}

local process_shell() {
  ( set -e; eval $@ )
}

eval $1
shift
if [[ -n $target && -v MAKELEVEL ]]; then
  process_recipe $@
else
  process_shell $@
fi
