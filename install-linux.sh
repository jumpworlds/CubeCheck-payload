#!/bin/sh
# CubeCheck 1.1 beta — тонкий установщик Linux (те же шаги, что и мастер).
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PRODUCT=CubeCheck
VERSION="1.1 beta"
AUTHORS="AuraStudio, AnProject"

die() { echo "CubeCheck: $*" >&2; exit 1; }

if [ "$(uname -s)" != "Linux" ]; then
  die "Этот скрипт для Linux. На macOS запустите install-macos.sh"
fi

arch=$(uname -m 2>/dev/null || echo unknown)
case "$arch" in
  x86_64|amd64) KEY=linux-x64 ;;
  i386|i686)    KEY=linux-x86 ;;
  *)            KEY=linux-x64 ;;
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
printf "Файл .desktop в меню приложений? [да/нет]: "
read -r menu
case "${desk:-да}" in нет|Нет|no|NO|n|N) DESK=0 ;; *) DESK=1 ;; esac
case "${menu:-да}" in нет|Нет|no|NO|n|N) MENU=0 ;; *) MENU=1 ;; esac

if [ "$(id -u)" -eq 0 ] || [ -w /opt ] || [ -w /opt/CubeCheck ] 2>/dev/null; then
  DEF=/opt/CubeCheck
else
  DEF="${XDG_DATA_HOME:-$HOME/.local/share}/CubeCheck"
fi

echo
echo "=== 3. Папка установки ==="
printf "Каталог [%s]: " "$DEF"
read -r dest
dest=${dest:-$DEF}
printf "Запустить после установки? [да/нет]: "
read -r launch
case "${launch:-да}" in нет|Нет|no|NO|n|N) LAUNCH=0 ;; *) LAUNCH=1 ;; esac

SRC=""
if [ -d "$ROOT/$KEY" ] && [ -f "$ROOT/$KEY/cubecheck" ]; then
  SRC="$ROOT/$KEY"
elif [ -d "$ROOT/payload/$KEY" ] && [ -f "$ROOT/payload/$KEY/cubecheck" ]; then
  SRC="$ROOT/payload/$KEY"
elif [ -f "$ROOT/cubecheck" ]; then
  SRC="$ROOT"
fi
[ -n "$SRC" ] || die "Нет payload $KEY рядом со скриптом"

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

ICON="$dest/assets/cubecheck.ico"
BIN="$dest/cubecheck.sh"
[ -x "$dest/cubecheck" ] && BIN="$dest/cubecheck"
DESKTOP_BODY="[Desktop Entry]
Type=Application
Name=CubeCheck
Comment=CubeCheck $VERSION
Exec=\"$BIN\"
Path=$dest
Icon=${ICON}
Terminal=false
Categories=Utility;
"

if [ "$MENU" -eq 1 ]; then
  apps="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
  mkdir -p "$apps"
  printf '%s\n' "$DESKTOP_BODY" > "$apps/cubecheck.desktop"
  chmod +x "$apps/cubecheck.desktop" 2>/dev/null || true
fi
if [ "$DESK" -eq 1 ]; then
  deskdir="${XDG_DESKTOP_DIR:-$HOME/Desktop}"
  mkdir -p "$deskdir"
  printf '%s\n' "$DESKTOP_BODY" > "$deskdir/CubeCheck.desktop"
  chmod +x "$deskdir/CubeCheck.desktop" 2>/dev/null || true
fi

echo
echo "=== 5. Установка завершена ==="
echo "CubeCheck $VERSION — $AUTHORS"
if [ "$LAUNCH" -eq 1 ]; then
  (cd "$dest" && exec "$BIN") || true
fi
