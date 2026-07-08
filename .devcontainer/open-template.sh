#!/bin/bash
# Turnkey open-on-attach with clean saves.
#
# Opening a REAL file (not piped stdin) means Ctrl+S saves normally to disk --
# no Save As dance, no /tmp temp-file trap that `code -` creates. The file is
# scaffolded once from the template if missing, then persists as the working
# file. postAttachCommand lacks VSCODE_IPC_HOOK_CLI (the var the `code` CLI uses
# to find the window), so we discover the IPC socket in /tmp and set it here.
WORKSPACE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="$WORKSPACE/CAD/test_shape.py"
TEMPLATE="$(dirname "${BASH_SOURCE[0]}")/test_shape_template.py"

# Scaffold once if missing (idempotent -- edits survive future attaches).
mkdir -p "$WORKSPACE/CAD"
if [ ! -f "$TARGET" ] && [ -f "$TEMPLATE" ]; then
  cp "$TEMPLATE" "$TARGET"
fi

CODE_BIN=$(ls -d "$HOME"/.vscode-server/bin/*/bin/remote-cli/code 2>/dev/null | head -n1)
[ -z "$CODE_BIN" ] && CODE_BIN=$(command -v code || true)
[ -z "$CODE_BIN" ] && { echo "code CLI not found; skipping open" >&2; exit 0; }

# The window's IPC socket may not exist the instant postAttach fires, so retry.
for i in $(seq 1 15); do
  SOCK=$(ls -t /tmp/vscode-ipc-*.sock 2>/dev/null | head -n1)
  if [ -n "$SOCK" ]; then
    if VSCODE_IPC_HOOK_CLI="$SOCK" "$CODE_BIN" "$TARGET" 2>/dev/null; then
      exit 0
    fi
  fi
  sleep 1
done

echo "VS Code IPC socket not available during postAttach; skipped open" >&2
exit 0