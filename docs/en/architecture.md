# Architecture

[Documentation home](index.md)

## Code layout

```
bin/vigie.dart                Entry point: options, root detection, full-screen launch, terminal restore
lib/src/session.dart          Supervisor: relaunches Vigie after the integrated terminal
lib/src/state.dart            All application state (section, data, samplers, confirmation, input, language)
lib/src/event.dart            Keyboard and mouse handling → updates the state
lib/src/ui/                   Rendering only, never runs a command
  layout.dart                 Tabs, system panel, status bar, buttons
  dashboard.dart              Dashboard layout
  components/                 Reusable panels (shared bars, formatters)
  tables.dart                 Users / processes / services tables
  strings.dart                All interface texts, in French and English
lib/src/system/               System access only → returns plain Dart objects, never user-facing text
  shell.dart                  Running commands, reading files
  overview.dart               CPU, memory, disks, network, uptime, OS
  users.dart                  /etc/passwd, /etc/group, /etc/shadow, useradd, usermod…
  processes.dart              /proc/<pid>, kill
  services.dart               systemctl
```

## Principles

- **Immediate-mode rendering**: `render` redraws **the whole** screen from the state, via [commander_ui](https://pub.dev/packages/commander_ui). The screen is redrawn on every tick (2 s) and after every action.
- **Rendering never touches the system**: the interface only reads the state. Everything that reads or changes the system goes through `lib/src/system/`.
- **The system layer never writes user-facing text**: it returns raw facts (exit code, raw output, error). The interface writes the message, in the right language.
- **Measurements by difference** (CPU, network) are kept by *samplers* created once in the state: they remember the previous reading.
- **Shared components**: CPU, disks and memory bars are drawn by a single function that only receives names and percentages (0–100).

## Where the data comes from

| Data | Source |
|---|---|
| CPU (total and per core) | `/proc/stat` (difference between two readings) |
| Memory and swap | `/proc/meminfo` (`MemTotal`, `MemAvailable`, `SwapTotal`, `SwapFree`) |
| Disks | `df -P -k`, excluding virtual file systems |
| Network | `/proc/net/dev` (difference between two readings, virtual interfaces excluded) |
| Uptime | `/proc/uptime` |
| OS | `/etc/os-release` |
| IP address | network interfaces, virtual ones excluded |
| Users | `/etc/passwd`, `/etc/group`, `/etc/shadow` (root) |
| Processes | `/proc/<pid>/stat`, `/proc/<pid>/status` |
| Services | `systemctl list-units` + `systemctl list-unit-files` |

Previous: [Development](development.md) · [Documentation home](index.md)
