#!/bin/bash
# Install droid-hardcore as a Factory Droid plugin
# Works on: Linux, macOS, Windows (Git Bash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$HOME/.factory/plugins/droid-hardcore"

echo "=== droid-hardcore installer ==="
echo ""

# Prerequisites
for cmd in python3 bash git; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: $cmd is required but not found. Please install it first."
    exit 1
  fi
done

# Check if already installed
if [ -d "$PLUGIN_DIR" ]; then
  echo "Updating existing installation..."
  rm -rf "$PLUGIN_DIR"
fi

# Install plugin
mkdir -p "$PLUGIN_DIR"
cp -r "$SCRIPT_DIR/.factory-plugin" "$PLUGIN_DIR/"
cp -r "$SCRIPT_DIR/hooks" "$PLUGIN_DIR/"
chmod +x "$PLUGIN_DIR/hooks/"*.sh 2>/dev/null || true

echo "Plugin installed to: $PLUGIN_DIR"

# Install rules (optional, to user config)
read -p "Also install rules to ~/.factory/rules/? (y/N) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  mkdir -p "$HOME/.factory/rules"
  cp "$SCRIPT_DIR/rules/"*.md "$HOME/.factory/rules/"
  echo "Rules installed to: $HOME/.factory/rules/"
fi

# Install AGENTS.md (optional)
read -p "Install AGENTS.md to ~/.factory/? (y/N) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  if [ -f "$HOME/.factory/AGENTS.md" ]; then
    cp "$HOME/.factory/AGENTS.md" "$HOME/.factory/AGENTS.md.backup"
    echo "Existing AGENTS.md backed up to AGENTS.md.backup"
  fi
  cp "$SCRIPT_DIR/AGENTS.md" "$HOME/.factory/AGENTS.md"
  echo "AGENTS.md installed."
fi

echo ""
echo "=== Installation complete ==="
echo "Restart Droid for changes to take effect."
echo "Use /plugins in Droid to verify the plugin is loaded."
