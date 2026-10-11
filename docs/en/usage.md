# Usage

**English** | [Français](../fr/usage.md) · [Documentation home](index.md)

## Starting Vigie

```bash
vigie                  # view only
sudo vigie             # view + actions (create an account, restart a service…)
sudo vigie --no-mouse  # view + actions, without mouse support
vigie --lang fr        # French interface
```

Without root privileges, Vigie starts in **read-only mode**: everything is visible, but actions that change the system are refused.

## Options

| Option | Effect |
|---|---|
| `--no-mouse` | Disables the mouse (useful in tmux without `mouse on`, or to select text) |
| `--lang fr\|en` | Interface language. Defaults to the system language (`LANG`): French if it starts with `fr`, English otherwise |

> 💡 Over SSH, the language is the **server's**, not your computer's. Many servers use `C.UTF-8` or `en_US`: use `--lang` to choose.

## Sections

| Key | Section | Contents |
|---|---|---|
| `1` | Overview | CPU per core, disks, memory and swap, network, services summary |
| `2` | Users | Human accounts (root and UID ≥ 1000) |
| `3` | Processes | Processes sorted by CPU usage |
| `4` | Services | systemd services, failed ones first |

## Keyboard shortcuts

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
| | `g` | Grant / revoke admin rights (`sudo` or `wheel` group) |
| | `D` | Delete (with home directory) |
| **Processes** | `t` | Graceful stop (SIGTERM) |
| | `K` | Forced stop (SIGKILL) |
| **Services** | `s` | Start |
| | `x` | Stop |
| | `r` | Restart |
| | `e` | Enable at boot |
| | `d` | Disable at boot |

Every action that changes the system asks for **confirmation** first.

> ⚠️ When connected over SSH, avoid stopping `ssh.service`: you would lose access to the server.

## Mouse

- Click a tab to switch section, a row to select it, a button to trigger its action.
- The scroll wheel scrolls the table under the pointer.
- With the mouse enabled, hold `Shift` to select text in the terminal.

When the terminal is narrow, section buttons switch to a compact form (key only, for example `[s][x][r]`). The general buttons (terminal, refresh, quit) always stay visible.

## Integrated terminal

`!` opens a shell (`bash`) directly from Vigie. Its prompt starts with `(vigie)` so you know where you are. Type `exit` to come back to Vigie, in the section you left.

Previous: [Installation](installation.md) · Next: [Development](development.md)
