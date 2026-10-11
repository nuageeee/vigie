# Installation

**English** | [Français](../fr/installation.md) · [Documentation home](index.md)

## Requirements

- Linux with **systemd**
- [Dart SDK](https://dart.dev/get-dart) ≥ 3.3, only to build from source

## Debian / Ubuntu (APT repository)

```bash
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://vigie.elnuagee.fr/nuage-apt.gpg | sudo tee /etc/apt/keyrings/nuage-apt.gpg >/dev/null
echo "deb [signed-by=/etc/apt/keyrings/nuage-apt.gpg] https://vigie.elnuagee.fr stable main" \
  | sudo tee /etc/apt/sources.list.d/nuage.list
sudo apt update && sudo apt install vigie
```

Updates:

```bash
sudo apt update && sudo apt upgrade
```

The repository is signed with GPG: `apt` refuses packages that were not signed with the published key.

## Any distribution (prebuilt binary)

```bash
curl -L -o vigie https://github.com/nuageeee/vigie/releases/latest/download/vigie-linux-x64
sudo install -m 755 vigie /usr/local/bin/vigie
```

The binary targets **x86_64** Linux with glibc (Debian, Ubuntu, Arch, Fedora…).

## Build from source

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

## Uninstall

```bash
sudo apt remove vigie                 # installed with APT
sudo rm /usr/local/bin/vigie          # installed manually
```

Next: [Usage](usage.md)
