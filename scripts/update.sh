#!/usr/bin/env bash
# Pins bun.json to the given Bun version and refreshes its release hashes.
set -euo pipefail

version=$1
file="$(dirname "$0")/../bun.json"

jq --arg v "$version" '.version = $v' "$file" >"$file.tmp"
mv "$file.tmp" "$file"

for system in $(jq -r '.sources | keys[]' "$file"); do
  asset=$(jq -r --arg s "$system" '.sources[$s].asset' "$file")
  url="https://github.com/oven-sh/bun/releases/download/bun-v$version/$asset.zip"
  hash=$(nix store prefetch-file --json "$url" | jq -r .hash)
  jq --arg s "$system" --arg h "$hash" '.sources[$s].hash = $h' "$file" >"$file.tmp"
  mv "$file.tmp" "$file"
done
