# Changelog

## [0.7.0] - 2026-10-12

### Added
- **Network sparklines**: the Network panel now shows a live history graph next to the download (↓) and upload (↑) rates, covering about the last 3 minutes. Both curves are aligned and adapt to the panel width.
- **Automated tests** (`dart test`) for every system parser: disks (`df`), memory (`/proc/meminfo`), network (`/proc/net/dev`) and CPU (`/proc/stat`), plus the sparkline renderer. Edge cases covered: empty input, missing keys, short or malformed lines, virtual interfaces and non-CPU lines.
- **Continuous integration**: a GitHub Actions workflow runs `dart analyze` and `dart test` on every push to `main` and `feat/**` branches, and on pull requests.

### Changed
- System samplers now separate reading, parsing and computing. Parsing lives in pure functions (`parseDisks`, `parseMemory`, `parseNetwork`, `parseCpu`) that can be tested without touching the real machine.
- The network sampler keeps a bounded history of recent rates (90 samples).

### Fixed
- Removed an unused import reported by the analyzer.

## [0.6.1] - 2026-10-10

### Fixed
- The global buttons now stay visible when the terminal is resized; action buttons switch to a compact layout when space runs out.
- The error message shown when a command fails to launch now fits on a single line.
- The input prompt now updates instantly (it previously waited up to 2 seconds for the next redraw).

## [0.6.0] - 2026-10-09

### Added
- **French and English interface**: the language follows the system locale (`LANG`): French if it starts with `fr`, English otherwise.
- `--lang fr|en` option to force the language; it is passed on to the session restarted after the built-in terminal (`!`).

### Changed
- All interface texts are grouped in `lib/src/ui/strings.dart`.
- Units follow the language: `o`/`Ko`/`Mo`/`Go` and `j` in French, `B`/`KB`/`MB`/`GB` and `d` in English.
- Texts that were still in English in the French interface (tabs, startup status, read-only mode…) are now translated.

### Fixed
- Actions (services, processes, users) ran successfully but were always reported as failed ("Impossible to launch … : Bad state: Stream has already been listened to"): the commands' error output was read from `stdout` instead of `stderr`.

## [0.5.0] - 2026-10-09

### Added
- **Dashboard** fully redesigned:
  - **CPU per core**: one bar per core, with its percentage and a colour based on load (green, yellow ≥ 50 %, red ≥ 90 %). Bars are precise to one eighth of a cell. Automatically switches to several columns when the cores don't fit vertically.
  - **Disks**: every real partition (via `df`), with its usage and the total space used. Virtual filesystems (`tmpfs`, Docker `overlay`, `squashfs`…) are ignored.
  - **Memory**: RAM and swap, computed like `free` (`MemAvailable`), with used and total.
  - **Network**: live received (↓) and sent (↑) rates across all physical interfaces (`lo`, Docker, `veth`, bridges and VPNs excluded).
- Side-by-side panel layout: Disks | Memory and Services | Network.

### Changed
- A single shared bar component for CPU, disks and memory: identical alignment everywhere, label width fitted to the longest name.
- Display formatters (sizes, rates, uptime) grouped on the interface side.
- Removed the old disk gauge, which only covered `/`.

### Fixed
- No more crash when a system output contains an unexpected line (tolerant parsing, length guards).
- No more division by zero on a server without swap or on an empty partition.

## [0.4.0] - 2026-10-06

### Added
- Live per-process CPU: measured between two reads of `/proc`, like htop (the `%CPU` from `ps` was an average over the whole process lifetime).
- IP address in the system bar.
- Signed APT repository: install and update with `apt`.

### Changed
- The process list reads `/proc` directly (`ps` is no longer needed).
- Kernel threads are hidden, like in htop.

## [0.3.0] - 2026-10-05

### Added
- `!` key (and "terminal" button): opens a real bash shell; `exit` brings you back to Vigie.
- Built-in shell: the binary handles the Vigie ↔ bash round trip on its own.
- Automatic launch at login via `~/.bash_profile` (see README).
- Clean shutdown on SIGTERM / SIGHUP (the terminal is always restored).

## [0.2.0] - 2026-10-04

### Added
- Mouse support, btop-style:
  - click a tab to switch section
  - click a row to select it, scroll with the wheel
  - clickable action buttons (bottom bar, Yes / No confirmation)
- `--no-mouse` option to disable the mouse.

### Fixed
- Display offset caused by the variable width of emojis (logo replaced with `◉`).
- The terminal is always restored on exit (mouse mode, cursor), even after a crash or an SSH disconnection.

## [0.1.0] - 2026-10-04

First public release.

- Dashboard: CPU, memory and disk gauges, failed services
- System panel: host, OS, kernel, uptime
- Users: create, set password, lock, admin rights, delete
- Processes: list sorted by CPU, graceful / forced kill
- systemd services: start, stop, restart, enable / disable at boot
- Confirmation before every action, read-only mode when not root