#!/bin/bash
set -e

for app in apps/*; do
  if [ -d "$app" ] && [ -f "$app/go.mod" ]; then
    echo "Testing $app"
    (cd "$app" && go test -v ./...)
  fi
  if [ -d "$app/internal" ]; then
    for pkg in "$app"/internal/*; do
      if [ -d "$pkg" ] && [ -f "$pkg/go.mod" ]; then
        echo "Testing $pkg"
        (cd "$pkg" && go test -v ./...)
      fi
    done
  fi
done 