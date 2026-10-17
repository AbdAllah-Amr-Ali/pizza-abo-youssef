#!/usr/bin/env bash
# One-time setup for the WitAnime watcher inside the Codespace container.
# Usage (inside the container):  bash /mnt/repo/witanime/setup_codespace.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ ! -d "$REPO_DIR/witanime" ]; then
    echo "[!] $REPO_DIR/witanime not found."
    echo "    Is the repo mounted at /mnt/repo? Recreate the container with:"
    echo "    -v /workspaces/pizza-abo-youssef:/mnt/repo"
    exit 1
fi

if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
elif command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
else
    echo "[!] Not root and sudo is not available - cannot install packages."
    exit 1
fi

echo "==> Installing system packages (python3-pip, unzip, zip, git)"
export DEBIAN_FRONTEND=noninteractive
$SUDO apt-get update -y
$SUDO apt-get install -y python3-pip unzip zip git

echo "==> Installing curl_cffi"
pip3 install --break-system-packages curl_cffi || pip3 install curl_cffi

echo "==> Marking repo as safe for git"
git config --global --add safe.directory "$REPO_DIR"

echo "==> Verifying"
python3 -c "import curl_cffi; print('    curl_cffi OK:', curl_cffi.__version__)"
git -C "$REPO_DIR" rev-parse --short HEAD >/dev/null && echo "    git OK"

echo
echo "Setup complete. Start the watcher with:"
echo "    bash $REPO_DIR/witanime/start_bot.sh"
