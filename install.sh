#!/bin/bash
# AIPulse installer
# Usage: curl -fsSL https://raw.githubusercontent.com/kami/aipulse/main/install.sh | bash

set -e

PLUGIN_DIR="${SWIFTBAR_PLUGIN_DIR:-$HOME/.swiftbar-plugins}"
CONFIG_DIR="$HOME/.config/aipulse"
REPO_RAW="${AIPULSE_REPO_RAW:-https://raw.githubusercontent.com/kami/aipulse/main}"

bold() { printf "\033[1m%s\033[0m\n" "$1"; }
ok()   { printf "  \033[32m✓\033[0m %s\n" "$1"; }
info() { printf "  \033[36mℹ\033[0m %s\n" "$1"; }
warn() { printf "  \033[33m⚠\033[0m %s\n" "$1"; }

bold "AIPulse installer"

# --- deps ---
if ! command -v node >/dev/null 2>&1; then
  warn "node not found — install via: brew install node"
  exit 1
fi
ok "node detected: $(node -v)"

if ! command -v brew >/dev/null 2>&1; then
  warn "Homebrew not found — required for SwiftBar"
  exit 1
fi

# --- SwiftBar ---
if [ ! -d "/Applications/SwiftBar.app" ]; then
  info "Installing SwiftBar via Homebrew..."
  brew install --cask swiftbar
  ok "SwiftBar installed"
else
  ok "SwiftBar already installed"
fi

# --- plugin dir ---
mkdir -p "$PLUGIN_DIR"
ok "Plugin directory: $PLUGIN_DIR"

# --- plugin file ---
PLUGIN_FILE="$PLUGIN_DIR/aipulse.1m.sh"
if [ -f "./aipulse.1m.sh" ]; then
  cp ./aipulse.1m.sh "$PLUGIN_FILE"
  ok "Copied local aipulse.1m.sh"
else
  curl -fsSL "$REPO_RAW/aipulse.1m.sh" -o "$PLUGIN_FILE"
  ok "Downloaded aipulse.1m.sh"
fi
chmod +x "$PLUGIN_FILE"

# --- config ---
mkdir -p "$CONFIG_DIR"
if [ ! -f "$CONFIG_DIR/config.sh" ]; then
  if [ -f "./config.example.sh" ]; then
    cp ./config.example.sh "$CONFIG_DIR/config.sh"
  else
    curl -fsSL "$REPO_RAW/config.example.sh" -o "$CONFIG_DIR/config.sh"
  fi
  ok "Config created: $CONFIG_DIR/config.sh"
else
  info "Config exists, not overwriting: $CONFIG_DIR/config.sh"
fi

# --- SwiftBar setup ---
defaults write com.ameba.SwiftBar PluginDirectory -string "$PLUGIN_DIR" 2>/dev/null || true
ok "SwiftBar plugin directory configured"

# --- launch ---
open -a SwiftBar 2>/dev/null || true

bold ""
bold "Done. Look for ✦ / 🤖 in your menu bar."
info "Config: $CONFIG_DIR/config.sh"
info "Plugin: $PLUGIN_FILE"
info "Repo:   https://github.com/kami/aipulse"
