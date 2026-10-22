# Changelog

## [0.10.0] - 2026-10-22

### Added
- CPU model name in the CPU panel, above the total history (falls back to the `Model` line on Raspberry Pi).
- CPU temperature in the CPU panel title, read from `hwmon` (Intel `coretemp`, AMD `k10temp`) or thermal zones (Intel `x86_pkg_temp`, Raspberry Pi `cpu-thermal`). Hidden when no sensor exists (VPS, WSL).

### Tests
- `parseCpuModel` (5 cases), `parseTemperature` (5 cases), `pickCpuTemperature` (5 cases).

## [0.9.0] - 2026-10-21

### Added
- Side navigation menu: all sections are now listed in the left column, under the System panel (keys `1`–`4` and mouse clicks work as before). This makes room for upcoming sections.
- Memory history: a RAM sparkline under the memory bars.
- systemd detection: on systems without systemd (Unraid, Slackware…), the Services tab and the dashboard now say "systemd not detected" instead of showing an empty list, and Vigie no longer calls `systemctl` in the background.

### Changed
- The top bar now only shows the Vigie logo; section tabs moved to the side menu.
- Long values in the System panel (hostname, OS, kernel) wrap onto several lines instead of being cut off.

### Fixed
- Ctrl+C no longer leaves Vigie's last screen behind the shell prompt: SIGINT now restores the terminal like `q`.
- If Vigie is killed by any signal (even `kill -9`), the session restores the terminal itself before exiting.
- Percentage sparklines (CPU total, RAM) now use a fixed 0–100 % scale instead of stretching small variations to full height.
- The English refusal message for system processes: "proccess" → "process".

### Tests
- `wrapText` (5 cases) and fixed-ceiling sparklines (3 cases).
- `detectServiceManager` (3 cases).

## [0.8.1] - 2026-10-19

### Added
- ARM64 builds (Raspberry Pi, ARM servers): a `.deb` package for `apt` and a standalone binary are now published with every release.

## [0.8.0] - 2026-10-17

### Added
- **Disk activity**: live read and write rates for all disks together, with history graphs, under the disk bars. Only whole disks are counted (no double counting of partitions, LVM or loop devices).
- **Top processes** panel on the dashboard: the most CPU-hungry processes, with the same columns as the Processes tab.
- **CPU history**: the total CPU usage graph, next to the per-core bars.

### Changed
- Redesigned dashboard with less empty space: CPU cores on two columns, compact Services and Network panels, and the remaining height given to the top processes.
- Bars now show their full scale with a dimmed background track, have a maximum width with the percentage right next to them, and use solid blocks (no more vertical stripes).
- Network and disk activity share the same layout: label, history graph, value aligned with the percentages.
- Disks are now detected with a whitelist of real block devices (`/dev/…`, no `loop`) and listed once each, which fixes duplicates and virtual drives showing up under WSL (`C:\`, `snapfuse`).
- Line endings are now enforced as LF in the repository (`.gitattributes`).
- Removed unused dependencies (`path`, `hotreloader`) and enabled stricter lints.

### Fixed
- Vigie no longer crashes when the terminal is too small for the top processes panel.

### Tests
- Tests for the disk list (whitelist and deduplication), the `/proc/diskstats` parser, the total CPU usage formula and the history buffer.

## [0.7.6] - 2026-10-16

### Security
- Killing PID 1 (the system's init process) is now refused, for both terminate (`t`) and kill (`K`).
- Vigie now refuses to kill its own process.
- The last member of the administrator group can no longer be deleted, locked or have admin rights removed, so the server always keeps at least one account able to use `sudo`.

### Changed
- User actions passed to the guards are now a typed `UserAction` enum instead of plain strings, so a translated label can no longer be passed by mistake.
- The process actions share a single code path for confirmation and refusal, like the service actions.

### Tests
- Tests for the process guard: PID 1 refused, Vigie's own process refused, other processes allowed.
- Tests for the last-administrator guard, including the priority between root, last-admin and self-targeting refusals.

## [0.7.5] - 2026-10-15

### Security
- Deleting the `root` account is now refused by the same guard as the other lockout protections. Locking `root` is still allowed, since it is a common hardening step.

### Changed
- All refusal rules now live in a single module (`guards.dart`) with one shared reason type, and all refusal messages go through one translated function. A new refusal cannot be added without its message in both languages.
- Refusal messages now name the exact action that was blocked (delete, lock, remove admin rights, stop, disable, restart).

### Tests
- Tests for the user guard: root deletion refused, root lock and admin change allowed, self-targeting refused for every action, and normal actions on other users allowed.
- Test folders reorganized into `parsers/`, `compute/` and `guards/`.

## [0.7.4] - 2026-10-14

### Changed
- Lower refresh cost: Vigie no longer launches system commands on every tick.
  - The kernel version (`uname`) and OS name (`/etc/os-release`) are read once at startup.
  - Disks (`df`) are refreshed every 30 seconds.
  - Services (`systemctl`) are refreshed every 10 seconds, and immediately after any action taken from Vigie (start, stop, restart, enable, disable).
- Code style: identifiers now follow Dart naming conventions, and the `non_constant_identifier_names` lint is enabled again.

### Fixed
- Per-process CPU usage could show `NaN` and break the process sorting when no time had elapsed between two readings.
- The `issue_tracker` link in `pubspec.yaml` was empty.

### Tests
- Tests for per-process CPU usage (`processCpuPercent`): no previous reading, zero or negative elapsed time, normal case, and usage above 100% on several cores.

## [0.7.3] - 2026-10-14

### Security
- The SSH lockout guard now also works under `sudo`: since `sudo` removes `SSH_CONNECTION`, Vigie now walks its parent processes in `/proc` to detect an SSH session.
- Fixed the guard refusing actions on every service during an SSH session: only `ssh`/`sshd` services and sockets are now protected (stop, disable, restart).

### Changed
- Releases are now built by GitHub Actions from the version tag, after `dart analyze` and `dart test`, instead of on a personal machine.
- Each release ships a `SHA256SUMS` file to verify the downloaded `.deb` and binary (`sha256sum -c SHA256SUMS --ignore-missing`).
- `pubspec.lock` is now committed, and builds fail if dependencies don't match it exactly.
- The Debian package description is now in English.

### Fixed
- The build script no longer depends on a hardcoded local path.

### Tests
- Tests for the SSH guard (`checkServiceTarget`, `hasSshAncestor`, `parsePpid`), including regression cases for detecting SSH with or without `SSH_CONNECTION`.

## [0.7.2] - 2026-10-13

### Security
- **Fixed a predictable temporary file used by the built-in shell (`!`).** When Vigie ran as root, the shell startup file was written to `/tmp/vigie-bashrc-<pid>`, a name another local user could guess and create in advance, potentially leading to code execution as root. The file now lives in a private, randomly named directory (mode `700`) and is removed on every exit path, including SIGTERM and SIGHUP.
- **Added safeguards against locking yourself out.** Vigie now refuses, before asking for confirmation, to delete, lock, or revoke the admin rights of the account you are logged in with (detected through `SUDO_USER`).

### Fixed
- The session now forwards Vigie's real exit code instead of always returning 0.
- `Ctrl-C` inside the built-in shell only interrupts the running command, not the whole session.

### Thanks
- Thanks to fraustiz for the security review that reported these issues.

## [0.7.1] - 2026-10-12

### Changed
- License changed from GPL-3.0 to MIT.

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
