#!/usr/bin/env sh
set -e

rm -rf ./*.vsix

vsce package "$1" --no-git-tag-version --out ./supergreatmonokai.vsix
