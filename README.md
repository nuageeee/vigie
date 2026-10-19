<div align="center">

# ◉ Vigie

**Manage a Linux server from a single terminal window.**

Monitor the machine, manage users, processes and systemd services:<br>
all in one TUI, over SSH, without remembering a dozen commands.

[![CI](https://github.com/nuageeee/vigie/actions/workflows/ci.yml/badge.svg)](https://github.com/nuageeee/vigie/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/nuageeee/vigie)](https://github.com/nuageeee/vigie/releases/latest)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**English** | [Français](README.fr.md)

![Vigie dashboard](https://raw.githubusercontent.com/nuageeee/vigie/refs/heads/main/docs/demo.gif)

</div>

## Why Vigie?

Tools like `htop` or `btop` are great at **showing** what a server does. Vigie also lets you **act** on it, from the same screen:

|                                  | htop / btop | Cockpit / Webmin | **Vigie** |
|----------------------------------|:-----------:|:----------------:|:---------:|
| Live monitoring                  | ✅          | ✅               | ✅        |
| Manage users and systemd services | ❌          | ✅               | ✅        |
| Works in a plain SSH session     | ✅          | ❌ (web browser) | ✅        |
| Nothing to expose on the network | ✅          | ❌ (web port)    | ✅        |

One binary, no agent, no web server, no open port. Available in **English and French**.

## Features

- 📊 **Dashboard**: CPU per core, disks, memory and swap, live network rates with history graphs, failed services
- 👤 **Users**: create, change password, lock / unlock, grant / revoke admin rights, delete
- ⚙️ **Processes**: sorted by live CPU usage, graceful or forced stop
- 🔧 **Services**: start, stop, restart, enable / disable at boot
- 🖱️ **Everywhere**: mouse support, built-in terminal (`!`), keyboard shortcuts

## Safe by design

Vigie can change your system, so it is built to be careful:

- **Read-only by default**: without `sudo`, Vigie only shows information, every action is disabled.
- **Confirmation before every change**: nothing happens on a single keypress.
- **Nothing exposed**: no daemon, no network port, it runs only while you use it.
- **Open source**: every command Vigie runs is in the code ([MIT license](LICENSE)).

## Quick start

On **Debian / Ubuntu** (x86_64), install from the signed APT repository:

```bash
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://vigie.elnuagee.fr/nuage-apt.gpg | sudo tee /etc/apt/keyrings/nuage-apt.gpg >/dev/null
echo "deb [signed-by=/etc/apt/keyrings/nuage-apt.gpg] https://vigie.elnuagee.fr stable main" \
  | sudo tee /etc/apt/sources.list.d/nuage.list
sudo apt update && sudo apt install vigie
```

Then run it:

```bash
vigie            # view only
sudo vigie       # view + actions
vigie --lang fr  # French interface
```

Other distributions and building from source: see [Installation](docs/en/installation.md).
Keyboard shortcuts and options: see [Usage](docs/en/usage.md).

## Documentation

📖 **[Full documentation](https://nuageeee.github.io/vigie/)**: installation, usage, development, architecture.

## Feedback welcome!

Vigie is a young project, and real-world feedback is what helps it most.

- 💬 **Questions, ideas, or just want to share how you use it?** Join the [Discussions](https://github.com/nuageeee/vigie/discussions).
- 🐛 **Found a bug?** Open an [issue](https://github.com/nuageeee/vigie/issues), with your distribution, your Vigie version and your terminal.
- ⭐ **Like it?** A star helps other people find the project.

**Coming next:** ARM builds (Raspberry Pi), an AUR package, disk activity and temperatures on the dashboard.

## Support

Vigie is free and open source, built on evenings and weekends.
If it saves you time, you can support its development:

[![Sponsor](https://img.shields.io/github/sponsors/nuageeee?label=Sponsor&logo=GitHub)](https://github.com/sponsors/nuageeee)

Starring the repo ⭐ and sharing it also helps a lot.

## Contributing

Contributions are welcome! The [development guide](docs/en/development.md) explains how to build Vigie, run the tests (`dart test`) and how the code is organised.

## License

Distributed under the [MIT](LICENSE) license. Built with [Dart](https://dart.dev) and [commander_ui](https://pub.dev/packages/commander_ui).
