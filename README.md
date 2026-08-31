# CubeCheck payload

**CubeCheck** — детектор читов Minecraft, не чит. Этот репозиторий — готовый payload для онлайн-установщика (версия **1.1 beta** / **1.1.0-beta**), а не исходный код.

English: installer payload for CubeCheck 1.1 beta, a Minecraft cheat **detector** (not a cheat). The thin Windows setup downloads this zip; offline setup does not use GitHub.

Авторы: **AuraStudio**, **AnProject**. Лицензия: [MIT](LICENSE.md). Канал: [@cubecheck](https://telegram.me/cubecheck). HolyCheck: [mods.holyworld.me](https://mods.holyworld.me/).

## Что это

Онлайн-установщик CubeCheck скачивает архив ветки `main`:

`https://github.com/jumpworlds/CubeCheck-payload/archive/refs/heads/main.zip`

GitHub распаковывает его как `CubeCheck-payload-main/`. Установщик снимает этот префикс и копирует дерево своей ОС (`windows-x64`, `linux-x64` или `linux-x86`).

Офлайн-установщик этот репозиторий **не** использует: пакет уже внутри setup.

Исходный код — отдельный репозиторий. Сюда не входят сторонние Windows-утилиты (`Everything.exe`, Process Monitor, Autoruns, Process Explorer, System Informer и т.п.): программа качает их с официальных адресов при работе.

## Состав

| Путь | Назначение |
|------|------------|
| `LICENSE.md` | MIT, © 2026 AuraStudio, AnProject |
| `SHA256SUMS` | SHA-256 файлов этого payload |
| `install-linux.sh` | установщик Linux (онлайн: этот zip; офлайн: только локальные файлы) |
| `install-macos.sh` | установщик macOS (скрипт есть; Mach-O `cubecheck` / `osx-*` в этой сборке **нет**) |
| `windows-x64/` | Windows 10/11 x64 |
| `linux-x64/` | Linux x86_64 (ELF `cubecheck`) |
| `linux-x86/` | Linux i686 (ELF `cubecheck`) |

### Windows (`windows-x64/`)

После установки эти файлы лежат в каталоге программы:

```
cubecheck.exe
UnInstall.url
.portable
assets/
  cubecheck_api.dll
  cubecheck_native.dll
  UnInstall.ico
  UnInstall.cmd
  cubecheck.ico
  tools.json
  settings.default.json
  Everything.ini
```

`Everything.ini` — конфиг Everything, не сам `Everything.exe`.

### Linux (`linux-x64/`, `linux-x86/`)

```
cubecheck
cubecheck.sh
.portable
assets/
  cubecheck.ico
  tools.json
  settings.default.json
```

## Как пользоваться после распаковки

Обычный путь — тонкий установщик CubeCheck, не ручное копирование.

- Windows: `windows-x64\cubecheck.exe`
- Linux: `chmod +x cubecheck cubecheck.sh && ./cubecheck.sh` в `linux-x64` или `linux-x86`, либо `./install-linux.sh`

Файл `.portable` включает портативный режим.

## Удаление

- `cubecheck.exe -uninstall`
- ярлык `UnInstall.url` (вызывает `assets\UnInstall.cmd` → `cubecheck.exe -uninstall`)

## Важно

CubeCheck проверяет компьютер на известные читы Minecraft. Не выдавайте его за чит и не подменяйте сборками из непроверенных источников.
