# Config file for Air live reload
root = "."
tmp_dir = "tmp"

[build]
  cmd = "go build -o ./tmp/main"
  bin = "tmp/main"
  full_bin = "tmp/main"

[log]
  level = "debug"
