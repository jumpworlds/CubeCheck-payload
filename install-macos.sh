#!/bin/sh
# CubeCheck 1.1 beta — тонкий установщик macOS (те же шаги, что и мастер).
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PRODUCT=CubeCheck
VERSION="1.1 beta"
AUTHORS="AuraStudio, AnProject"

die() { echo "CubeCheck: $*" >&2; exit 1; }

if [ "$(uname -s)" != "Darwin" ]; then
  die "Этот скрипт для macOS. На Linux запустите install-linux.sh"
fi

arch=$(uname -m 2>/dev/null || echo unknown)
case "$arch" in
  arm64) KEY=osx-arm64; ALT=osx-x64 ;;
  *)     KEY=osx-x64; ALT=osx-arm64 ;;
esac

LICENSE=""
for c in "$ROOT/LICENSE.md" "$ROOT/../LICENSE.md"; do
  if [ -f "$c" ]; then LICENSE=$c; break; fi
done
[ -n "$LICENSE" ] || die "Нет LICENSE.md"

echo "CubeCheck $VERSION — $AUTHORS"
echo
echo "=== 1. Лицензия (MIT) ==="
cat "$LICENSE"
echo
printf "Принять лицензию? [нет/да]: "
read -r accept
case "$accept" in
  да|Да|yes|YES|y|Y) ;;
  *) die "Нужно принять лицензию, чтобы продолжить." ;;
esac

echo
echo "=== 2. Ярлыки ==="
printf "Ярлык на рабочем столе? [да/нет]: "
read -r desk
printf "Псевдоним в Applications? [да/нет]: "
read -r menu
case "${desk:-да}" in нет|Нет|no|NO|n|N) DESK=0 ;; *) DESK=1 ;; esac
case "${menu:-да}" in нет|Нет|no|NO|n|N) MENU=0 ;; *) MENU=1 ;; esac

DEF=/Applications/CubeCheck
echo
echo "=== 3. Папка установки ==="
printf "Каталог [%s]: " "$DEF"
read -r dest
dest=${dest:-$DEF}
printf "Запустить после установки? [да/нет]: "
read -r launch
case "${launch:-да}" in нет|Нет|no|NO|n|N) LAUNCH=0 ;; *) LAUNCH=1 ;; esac

pick() {
  for k in "$1" "$2"; do
    if [ -d "$ROOT/$k" ] && [ -f "$ROOT/$k/cubecheck" ]; then echo "$ROOT/$k"; return; fi
    if [ -d "$ROOT/payload/$k" ] && [ -f "$ROOT/payload/$k/cubecheck" ]; then echo "$ROOT/payload/$k"; return; fi
  done
  if [ -f "$ROOT/cubecheck" ]; then echo "$ROOT"; return; fi
  echo ""
}

SRC=$(pick "$KEY" "$ALT")
[ -n "$SRC" ] || die "Нет macOS payload (osx-arm64 / osx-x64) с бинарником cubecheck"

echo
echo "=== 4. Установка ==="
mkdir -p "$dest"
echo "Копирование в $dest …"
cp -a "$SRC/." "$dest/"
chmod +x "$dest/cubecheck" "$dest/cubecheck.sh" 2>/dev/null || true
mkdir -p "$dest/reports"
if [ ! -f "$dest/settings.json" ] && [ -f "$dest/assets/settings.default.json" ]; then
  cp "$dest/assets/settings.default.json" "$dest/settings.json"
fi

BIN="$dest/cubecheck"
[ -x "$BIN" ] || BIN="$dest/cubecheck.sh"

if [ "$MENU" -eq 1 ]; then
  if [ "$(cd "$dest" && pwd)" != "/Applications/CubeCheck" ]; then
    ln -sfn "$dest" /Applications/CubeCheck 2>/dev/null || true
  fi
fi
if [ "$DESK" -eq 1 ]; then
  ln -sfn "$dest" "$HOME/Desktop/CubeCheck" 2>/dev/null || true
fi

echo
echo "=== 5. Установка завершена ==="
echo "CubeCheck $VERSION — $AUTHORS"
if [ "$LAUNCH" -eq 1 ]; then
  (cd "$dest" && exec "$BIN") || true
fi
