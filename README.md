# ◉ Vigie

**English** | [Français](README.fr.md)

**Manage a Linux server from a single terminal window.**

Vigie is a text-based user interface (TUI) that brings together what you usually do with a dozen commands: monitor the machine, manage user accounts, watch processes and control systemd services. No browser, no agent to install, no port to open: a single binary, run over SSH.

The interface is available in **English** and **French**, detected from the system language (`LANG`) or forced with `--lang`.

![Vigie](screen.png)

---

## Features

### Dashboard
- **CPU per core**: one bar per core with its percentage, colored by load (green, yellow ≥ 50 %, red ≥ 90 %), spread over several columns on machines with many cores
- **Disks**: every real partition with its usage, and the total space used (virtual file systems such as `tmpfs`, Docker `overlay` or `squashfs` are ignored)
- **Memory**: RAM and swap, computed like `free` (`MemAvailable`)
- **Network**: live download (↓) and upload (↑) rates across all physical interfaces
- Number of active services and list of **failed services**

### Users
- List of human accounts (root and UID ≥ 1000): UID, shell, groups, admin rights, locked or active
- **Create** a user (with a home directory)
- **Change the password**
- **Lock / unlock** an account
- **Grant / revoke admin rights** (`sudo` or `wheel` group, detected automatically depending on the distribution)
- **Delete** a user and their home directory

### Processes
- Processes sorted by CPU usage: PID, user, CPU %, RAM %, memory
- Live CPU usage per process (read from `/proc/<pid>/stat`, unlike `ps`, which shows an average over the process lifetime)
- **Graceful stop** (SIGTERM) or **forced stop** (SIGKILL)

### Services
- All systemd services, failed ones first
- Current state and boot state
- **Start / stop / restart**
- **Enable / disable at boot**

### Everywhere
- Automatic refresh every 2 seconds, **without blocking the keyboard**
- **Mouse support**: clickable tabs, rows and buttons, scroll wheel
- **Integrated terminal** (`!`): drops you into a shell, and back to Vigie when you exit it
- **Mandatory confirmation** (`y` / `n`) before any action that changes the system
- Automatic **read-only mode** when Vigie is not run as root
- Permanent system panel: host, OS, kernel, uptime, IP address
- Buttons adapt to the terminal width: when space runs short, section buttons switch to a compact form, and the general buttons (terminal, refresh, quit) always stay visible

---

## Installation

### Requirements
- Linux with **systemd**
- [Dart SDK](https://dart.dev/get-dart) ≥ 3.3, only to build from source

### Debian / Ubuntu (APT repository)

```bash
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://vigie.elnuagee.fr/nuage-apt.gpg | sudo tee /etc/apt/keyrings/nuage-apt.gpg >/dev/null
echo "deb [signed-by=/etc/apt/keyrings/nuage-apt.gpg] https://vigie.elnuagee.fr stable main" \
  | sudo tee /etc/apt/sources.list.d/nuage.list
sudo apt update && sudo apt install vigie
```

Updates: `sudo apt update && sudo apt upgrade`.

### Any distribution (prebuilt binary)

```bash
curl -L -o vigie https://github.com/nuageeee/vigie/releases/latest/download/vigie-linux-x64
sudo install -m 755 vigie /usr/local/bin/vigie
```

### Build from source

```bash
git clone https://github.com/nuageeee/vigie.git
cd vigie
dart pub get
dart compile exe bin/vigie.dart -o vigie
sudo install -m 755 vigie /usr/local/bin/vigie
```

The resulting binary is **self-contained**: you can copy it to any Linux server with the same architecture, without installing Dart there.

```bash
scp vigie my-server:/tmp/ && ssh my-server 'sudo install -m 755 /tmp/vigie /usr/local/bin/'
```

---

## Usage

```bash
vigie                  # view only
sudo vigie             # view + actions (create an account, restart a service…)
sudo vigie --no-mouse  # view + actions, without mouse support
vigie --lang fr        # French interface
```

### Keyboard shortcuts

| Where | Key | Action |
|---|---|---|
| Everywhere | `1` to `4` | Switch section |
| | `↑` `↓` / `j` `k` | Move through the list |
| | `!` | Open the integrated terminal |
| | `F5` | Refresh everything |
| | `q` | Quit |
| Confirmation | `y` or `o` / `n` (or `Esc`) | Confirm / cancel |
| Text input | `Enter` / `Esc` | Confirm / cancel |
| **Users** | `a` | Add a user |
| | `p` | Change the password |
| | `v` | Lock / unlock |
| | `g` | Grant / revoke admin rights |
| | `D` | Delete (with home directory) |
| **Processes** | `t` | Graceful stop (SIGTERM) |
| | `K` | Forced stop (SIGKILL) |
| **Services** | `s` | Start |
| | `x` | Stop |
| | `r` | Restart |
| | `e` | Enable at boot |
| | `d` | Disable at boot |

> ⚠️ When connected over SSH, avoid stopping `ssh.service`: you would lose access to the server.

### Options

| Option | Effect |
|---|---|
| `--no-mouse` | Disables the mouse (useful in tmux without `mouse on`, or to select text) |
| `--lang fr\|en` | Interface language. Defaults to the system language (`LANG`): French if it starts with `fr`, English otherwise |

> 💡 With the mouse enabled, hold `Shift` to select text in the terminal.

---

## Development

### Run from source

```bash
dart pub get                              # without sudo
dart run bin/vigie.dart                   # read-only
sudo "$(which dart)" run bin/vigie.dart   # with root privileges
```

`sudo dart` alone does not work: `sudo` uses its own `PATH` (`secure_path`), which does not include Dart. Do not run `dart pub get` with `sudo` either, otherwise `.dart_tool/` will belong to root.

### Hot reload

With the [`hotreloader`](https://pub.dev/packages/hotreloader) package (a dev dependency), changes in `lib/` apply without restarting Vigie:

```bash
dart run --enable-vm-service bin/vigie.dart --no-session
```

> ⚠️ The `--no-session` option is required in development and hot-reload mode.

Reloaded on the fly: the interface, shortcuts, system commands.
Requires a restart: `bin/vigie.dart`, the `runTerminal` parameters, a new field in the state, a change to the sections `enum`, a new class or a file move.

### Architecture

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

The principle: `render` redraws **the whole** screen from the state (immediate-mode rendering, via [commander_ui](https://pub.dev/packages/commander_ui)). The interface never talks to the system directly: everything goes through `lib/src/system/`.

### Where the data comes from

| Data | Source |
|---|---|
| CPU (total and per core) | `/proc/stat` (difference between two readings) |
| Memory and swap | `/proc/meminfo` (`MemTotal`, `MemAvailable`, `SwapTotal`, `SwapFree`) |
| Disks | `df -P -k`, excluding virtual file systems |
| Network | `/proc/net/dev` (difference between two readings) |
| Uptime | `/proc/uptime` |
| OS | `/etc/os-release` |
| Users | `/etc/passwd`, `/etc/group`, `/etc/shadow` (root) |
| Processes | `/proc/<pid>/stat`, `/proc/<pid>/status` |
| Services | `systemctl list-units` + `systemctl list-unit-files` |

---

## Roadmap

- [x] Mouse support (clickable tabs, rows and buttons, scroll wheel)
- [x] Launch at login: starts when a session opens (if enabled)
- [x] Integrated terminal
- [x] Live CPU per process via `/proc/<pid>/stat` (`ps`'s `%CPU` is an average over the process lifetime)
- [x] Full dashboard: CPU per core, disks, memory and swap, network
- [x] English and French interface
- [ ] Search / filter with `/`
- [ ] Service logs (`journalctl -u`)
- [ ] Remote mode: manage several servers over SSH

---

## Built with

- [Dart](https://dart.dev)
- [commander_ui](https://pub.dev/packages/commander_ui) for the terminal interface

## License

Distributed under the [MIT](LICENSE) license.