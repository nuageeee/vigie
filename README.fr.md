# ◉ Vigie

[English](README.md) | **Français**

**Gérer un serveur Linux depuis une seule fenêtre de terminal.**

Vigie est une interface en mode texte (TUI) qui regroupe au même endroit ce qu'on fait habituellement avec une dizaine de commandes : surveiller la machine, gérer les comptes utilisateurs, surveiller les processus et piloter les services systemd. Pas de navigateur, pas d'agent à installer, pas de port à ouvrir : un seul binaire, lancé en SSH.

L'interface est disponible en **français** et en **anglais**, selon la langue du système (`LANG`) ou forcée avec `--lang`.

![Vigie](screen.png)

---

## Fonctionnalités

### Tableau de bord
- **CPU par cœur** : une barre par cœur avec son pourcentage, colorée selon la charge (vert, jaune ≥ 50 %, rouge ≥ 90 %), répartie sur plusieurs colonnes sur les machines à nombreux cœurs
- **Disques** : toutes les partitions réelles avec leur occupation, et l'espace total utilisé (les systèmes de fichiers virtuels comme `tmpfs`, `overlay` de Docker ou `squashfs` sont ignorés)
- **Mémoire** : RAM et swap, calculées comme `free` (`MemAvailable`)
- **Réseau** : débits reçus (↓) et envoyés (↑) en direct, toutes interfaces physiques confondues
- Nombre de services actifs et liste des **services en échec**

### Utilisateurs
- Liste des comptes humains (root et UID ≥ 1000) : UID, shell, groupes, droits admin, état verrouillé ou actif
- **Créer** un utilisateur (avec son dossier personnel)
- **Changer le mot de passe**
- **Verrouiller / déverrouiller** un compte
- **Donner / retirer les droits admin** (groupe `sudo` ou `wheel`, détecté automatiquement selon la distribution)
- **Supprimer** un utilisateur et son dossier

### Processus
- Processus triés par consommation CPU : PID, utilisateur, CPU %, RAM %, mémoire
- CPU instantané par processus (lu dans `/proc/<pid>/stat`, contrairement à `ps`, qui donne une moyenne sur toute la vie du processus)
- **Arrêt propre** (SIGTERM) ou **arrêt forcé** (SIGKILL)

### Services
- Tous les services systemd, ceux en échec en premier
- État actuel et état au démarrage
- **Démarrer / arrêter / redémarrer**
- **Activer / désactiver au démarrage**

### Pour tous les écrans
- Rafraîchissement automatique toutes les 2 secondes, **sans bloquer le clavier**
- **Souris** : onglets, lignes et boutons cliquables, molette
- **Terminal intégré** (`!`) : ouvre un shell, et revient dans Vigie quand on le quitte
- **Confirmation obligatoire** (`o` / `n`) avant toute action qui modifie le système
- **Mode lecture seule** automatique quand Vigie n'est pas lancé en root
- Panneau système permanent : hôte, OS, noyau, durée de fonctionnement, adresse IP
- Boutons adaptés à la largeur du terminal : quand la place manque, les boutons de la section passent en forme compacte, et les boutons généraux (terminal, rafraîchir, quitter) restent toujours visibles

---

## Installation

### Prérequis
- Linux avec **systemd**
- [Dart SDK](https://dart.dev/get-dart) ≥ 3.3, uniquement pour compiler

### Debian / Ubuntu (dépôt APT)

```bash
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://vigie.elnuagee.fr/nuage-apt.gpg | sudo tee /etc/apt/keyrings/nuage-apt.gpg >/dev/null
echo "deb [signed-by=/etc/apt/keyrings/nuage-apt.gpg] https://vigie.elnuagee.fr stable main" \
  | sudo tee /etc/apt/sources.list.d/nuage.list
sudo apt update && sudo apt install vigie
```

Mises à jour : `sudo apt update && sudo apt upgrade`.

### Toutes distributions (binaire précompilé)

```bash
curl -L -o vigie https://github.com/nuageeee/vigie/releases/latest/download/vigie-linux-x64
sudo install -m 755 vigie /usr/local/bin/vigie
```

### Compiler depuis les sources

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

---

## Utilisation

```bash
vigie                  # consultation seule
sudo vigie             # consultation + actions (créer un compte, redémarrer un service…)
sudo vigie --no-mouse  # consultation + actions, sans la souris
vigie --lang en        # interface en anglais
```

### Raccourcis clavier

| Où | Touche | Action |
|---|---|---|
| Partout | `1` à `4` | Changer de section |
| | `↑` `↓` / `j` `k` | Naviguer dans la liste |
| | `!` | Ouvrir le terminal intégré |
| | `F5` | Tout rafraîchir |
| | `q` | Quitter |
| Confirmation | `o` ou `y` / `n` (ou `Échap`) | Valider / annuler |
| Saisie | `Entrée` / `Échap` | Valider / annuler |
| **Utilisateurs** | `a` | Ajouter un utilisateur |
| | `p` | Changer le mot de passe |
| | `v` | Verrouiller / déverrouiller |
| | `g` | Donner / retirer les droits admin |
| | `D` | Supprimer (avec son dossier) |
| **Processus** | `t` | Arrêt propre (SIGTERM) |
| | `K` | Arrêt forcé (SIGKILL) |
| **Services** | `s` | Démarrer |
| | `x` | Arrêter |
| | `r` | Redémarrer |
| | `e` | Activer au démarrage |
| | `d` | Désactiver au démarrage |

> ⚠️ Connecté en SSH, évitez d'arrêter `ssh.service` : vous perdriez l'accès au serveur.

### Options

| Option | Effet |
|---|---|
| `--no-mouse` | Désactive la souris (utile dans tmux sans `mouse on`, ou pour sélectionner du texte) |
| `--lang fr\|en` | Langue de l'interface. Par défaut, celle du système (`LANG`) : français si elle commence par `fr`, sinon anglais |

> 💡 Souris active : maintenez `Maj` pour sélectionner du texte dans le terminal.

---

## Développement

### Lancer depuis les sources

```bash
dart pub get                              # sans sudo
dart run bin/vigie.dart                   # lecture seule
sudo "$(which dart)" run bin/vigie.dart   # avec les droits root
```

`sudo dart` seul ne fonctionne pas : `sudo` utilise son propre `PATH` (`secure_path`), qui ne contient pas Dart. Ne lancez pas non plus `dart pub get` avec `sudo`, sinon `.dart_tool/` appartiendra à root.

### Hot reload

Avec le package [`hotreloader`](https://pub.dev/packages/hotreloader) (en dev dependency), les modifications dans `lib/` s'appliquent sans relancer Vigie :

```bash
dart run --enable-vm-service bin/vigie.dart --no-session
```

> ⚠️ L'option `--no-session` est obligatoire en développement et en hot reload.

Se recharge à chaud : l'interface, les raccourcis, les commandes système.
Demande de relancer : `bin/vigie.dart`, les paramètres de `runTerminal`, un nouveau champ dans l'état, une modification de l'`enum` des sections, une nouvelle classe ou un déplacement de fichier.

### Architecture

```
bin/vigie.dart                Point d'entrée : options, détection root, lancement plein écran, restauration du terminal
lib/src/session.dart          Superviseur : relance Vigie après le terminal intégré
lib/src/state.dart            Tout l'état de l'application (section, données, samplers, confirmation, saisie, langue)
lib/src/event.dart            Gestion du clavier et de la souris → modifie l'état
lib/src/ui/                   Rendu uniquement, ne lance jamais de commande
  layout.dart                 Onglets, panneau système, barre d'état, boutons
  dashboard.dart              Disposition du tableau de bord
  components/                 Panneaux réutilisables (barres partagées, formateurs)
  tables.dart                 Tableaux utilisateurs / processus / services
  strings.dart                Tous les textes de l'interface, en français et en anglais
lib/src/system/               Accès au système uniquement → renvoie des objets Dart simples, jamais de texte pour l'utilisateur
  shell.dart                  Lancement de commandes, lecture de fichiers
  overview.dart               CPU, mémoire, disques, réseau, uptime, OS
  users.dart                  /etc/passwd, /etc/group, /etc/shadow, useradd, usermod…
  processes.dart              /proc/<pid>, kill
  services.dart               systemctl
```

Le principe : `render` redessine **tout** l'écran à partir de l'état (rendu en mode immédiat, via [commander_ui](https://pub.dev/packages/commander_ui)). L'interface ne parle jamais directement au système : tout passe par `lib/src/system/`.

### D'où viennent les données

| Donnée | Source |
|---|---|
| CPU (total et par cœur) | `/proc/stat` (écart entre deux lectures) |
| Mémoire et swap | `/proc/meminfo` (`MemTotal`, `MemAvailable`, `SwapTotal`, `SwapFree`) |
| Disques | `df -P -k`, sans les systèmes de fichiers virtuels |
| Réseau | `/proc/net/dev` (écart entre deux lectures) |
| Uptime | `/proc/uptime` |
| OS | `/etc/os-release` |
| Utilisateurs | `/etc/passwd`, `/etc/group`, `/etc/shadow` (root) |
| Processus | `/proc/<pid>/stat`, `/proc/<pid>/status` |
| Services | `systemctl list-units` + `systemctl list-unit-files` |

---

## Feuille de route

- [x] Support de la souris (onglets, lignes et boutons cliquables, molette)
- [x] Lancement au démarrage : se lance à l'ouverture d'une session (si activé)
- [x] Terminal intégré
- [x] CPU instantané par processus via `/proc/<pid>/stat` (le `%CPU` de `ps` est une moyenne sur la vie du processus)
- [x] Tableau de bord complet : CPU par cœur, disques, mémoire et swap, réseau
- [x] Interface en français et en anglais
- [ ] Recherche / filtre avec `/`
- [ ] Journal d'un service (`journalctl -u`)
- [ ] Mode distant : gérer plusieurs serveurs via SSH

---

## Construit avec

- [Dart](https://dart.dev)
- [commander_ui](https://pub.dev/packages/commander_ui) pour l'interface terminal

## Licence

Distribué sous licence [MIT](LICENSE).