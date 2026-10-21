# Installation

[Accueil de la documentation](index.md)

## Prérequis

- Linux. **systemd** est nécessaire pour l'onglet Services ; sans lui (Unraid, Slackware…), Vigie fonctionne et indique que la gestion des services est indisponible.
- [Dart SDK](https://dart.dev/get-dart) ≥ 3.3, uniquement pour compiler

## Debian / Ubuntu (dépôt APT)

```bash
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://vigie.elnuagee.fr/nuage-apt.gpg | sudo tee /etc/apt/keyrings/nuage-apt.gpg >/dev/null
echo "deb [signed-by=/etc/apt/keyrings/nuage-apt.gpg] https://vigie.elnuagee.fr stable main" \
  | sudo tee /etc/apt/sources.list.d/nuage.list
sudo apt update && sudo apt install vigie
```

Mises à jour :

```bash
sudo apt update && sudo apt upgrade
```

Le dépôt est signé avec GPG : `apt` refuse tout paquet qui n'a pas été signé avec la clé publiée.

## Toutes distributions (binaire précompilé)

```bash
curl -L -o vigie https://github.com/nuageeee/vigie/releases/latest/download/vigie-linux-x64
sudo install -m 755 vigie /usr/local/bin/vigie
```

Le binaire vise Linux **x86_64** avec glibc (Debian, Ubuntu, Arch, Fedora…).

## Compiler depuis les sources

```bash
git clone https://github.com/nuageeee/vigie.git
cd vigie
dart pub get
dart compile exe bin/vigie.dart -o vigie
sudo install -m 755 vigie /usr/local/bin/vigie
```

Le binaire obtenu est **autonome** : vous pouvez le copier sur n'importe quel serveur Linux de même architecture, sans installer Dart dessus.

```bash
scp vigie mon-serveur:/tmp/ && ssh mon-serveur 'sudo install -m 755 /tmp/vigie /usr/local/bin/'
```

## Désinstaller

```bash
sudo apt remove vigie                 # installé avec APT
sudo rm /usr/local/bin/vigie          # installé à la main
```

Suite : [Utilisation](usage.md)
