#!/usr/bin/env bash

export PWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)" cd $PWD
export ME="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"

while true; do
  "$@"
  if [ $? -eq 0 ]; then
    echo OK
  else
    echo "[ $@ ] failed  to watch"
    sleep 2
    $ME "$@"
  fi
  sleep 10
done

main "$@"
