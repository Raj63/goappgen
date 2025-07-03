#!/bin/bash
set -e

for dir in $(find . -type d -name 'internal' -prune -o -type d -name 'app*' -print); do
  if [ -f "$dir/go.mod" ]; then
    echo "Testing $dir"
    (cd "$dir" && go test -v ./...)
  fi
done 