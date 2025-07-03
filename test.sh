#!/bin/bash
set -e

echo "Testing all Go packages in goappgen repo..."
go test -v ./...
