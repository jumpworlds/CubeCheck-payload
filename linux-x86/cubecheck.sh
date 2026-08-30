#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
chmod +x "$ROOT/cubecheck" "$ROOT/assets/bin/"* 2>/dev/null || true
export CUBECHECK_PORTABLE=1
export APPIMAGE_EXTRACT_AND_RUN=1
if [ -f "$ROOT/.offline" ] || [ -f "$ROOT/assets/.offline" ]; then
  export CUBECHECK_OFFLINE=1
fi
export PATH="$ROOT/assets/bin:$PATH"
cd "$ROOT"
exec "$ROOT/cubecheck" "$@"
