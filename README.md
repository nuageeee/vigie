# ◉ Vigie

**English** | [Français](README.fr.md)

**Manage a Linux server from a single terminal window.**

Vigie is a text-based user interface (TUI) that brings together what you usually do with a dozen commands: monitor the machine, manage user accounts, watch processes and control systemd services. No browser, no agent to install, no port to open: a single binary, run over SSH. Available in English and French.

![Vigie](screen.png)

## Features

- **Dashboard**: CPU per core, disks, memory and swap, live network rates, failed services
- **Users**: create, change password, lock / unlock, grant / revoke admin rights, delete
- **Processes**: sorted by live CPU usage, graceful or forced stop
- **Services**: start, stop, restart, enable / disable at boot
- **Everywhere**: mouse support, integrated terminal, confirmation before every change, automatic read-only mode without root

## Install (Debian / Ubuntu)

```bash
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://vigie.elnuagee.fr/nuage-apt.gpg | sudo tee /etc/apt/keyrings/nuage-apt.gpg >/dev/null
echo "deb [signed-by=/etc/apt/keyrings/nuage-apt.gpg] https://vigie.elnuagee.fr stable main" \
  | sudo tee /etc/apt/sources.list.d/nuage.list
sudo apt update && sudo apt install vigie
```

Other distributions and building from source: see [Installation](docs/en/installation.md).

## Usage

```bash
vigie            # view only
sudo vigie       # view + actions
vigie --lang fr  # French interface
```

Keyboard shortcuts and options: see [Usage](docs/en/usage.md).

## Documentation

📖 **[Full documentation](docs/en/index.md)**: installation, usage, development, architecture.

## License

Distributed under the [MIT](LICENSE) license. Built with [Dart](https://dart.dev) and [commander_ui](https://pub.dev/packages/commander_ui).
