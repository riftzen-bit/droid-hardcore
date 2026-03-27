#!/bin/bash
# Uninstall droid-hardcore plugin

PLUGIN_DIR="$HOME/.factory/plugins/droid-hardcore"

echo "=== droid-hardcore uninstaller ==="

if [ -d "$PLUGIN_DIR" ]; then
  rm -rf "$PLUGIN_DIR"
  echo "Plugin removed from: $PLUGIN_DIR"
else
  echo "Plugin not found at $PLUGIN_DIR"
fi

echo ""
echo "Note: Rules in ~/.factory/rules/ and AGENTS.md were NOT removed."
echo "Remove them manually if desired."
echo "Restart Droid for changes to take effect."
