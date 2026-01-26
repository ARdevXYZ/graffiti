#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if command -v cmake >/dev/null 2>&1; then
  CMAKE_BIN="cmake"
elif [[ -x "/opt/homebrew/bin/cmake" ]]; then
  CMAKE_BIN="/opt/homebrew/bin/cmake"
elif [[ -x "/usr/local/bin/cmake" ]]; then
  CMAKE_BIN="/usr/local/bin/cmake"
else
  echo "CMake not found. Install it (e.g. 'brew install cmake') and re-run." >&2
  exit 1
fi

"$CMAKE_BIN" -S "$ROOT_DIR/core" -B "$ROOT_DIR/build/core" -DCMAKE_BUILD_TYPE=Release
"$CMAKE_BIN" --build "$ROOT_DIR/build/core" --config Release
