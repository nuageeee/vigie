<div align="center">

# ◉ Vigie

**Gérer un serveur Linux depuis une seule fenêtre de terminal.**

Surveiller la machine, gérer les utilisateurs, les processus et les services systemd :<br>
tout dans une seule interface, en SSH, sans retenir une dizaine de commandes.

[![CI](https://github.com/nuageeee/vigie/actions/workflows/ci.yml/badge.svg)](https://github.com/nuageeee/vigie/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/nuageeee/vigie)](https://github.com/nuageeee/vigie/releases/latest)
[![Licence : MIT](https://img.shields.io/badge/licence-MIT-blue.svg)](LICENSE)

[English](README.md) | **Français**

![Tableau de bord de Vigie](screen.png)

</div>

## Pourquoi Vigie ?

Des outils comme `htop` ou `btop` sont excellents pour **montrer** ce que fait un serveur. Vigie permet aussi d'**agir** dessus, depuis le même écran :

|                                         | htop / btop | Cockpit / Webmin  | **Vigie** |
|-----------------------------------------|:-----------:|:-----------------:|:---------:|
| Surveillance en direct                  | ✅          | ✅                | ✅        |
| Gestion des utilisateurs et des services systemd | ❌ | ✅           | ✅        |
| Fonctionne dans une simple session SSH  | ✅          | ❌ (navigateur)   | ✅        |
| Rien à exposer sur le réseau            | ✅          | ❌ (port web)     | ✅        |

Un seul binaire, pas d'agent, pas de serveur web, pas de port ouvert. Disponible en **français et en anglais**.

## Fonctionnalités

- 📊 **Tableau de bord** : CPU par cœur, disques, mémoire et swap, débits réseau en direct avec leur historique, services en échec
- 👤 **Utilisateurs** : créer, changer le mot de passe, verrouiller / déverrouiller, donner / retirer les droits admin, supprimer
- ⚙️ **Processus** : triés par CPU instantané, arrêt propre ou forcé
- 🔧 **Services** : démarrer, arrêter, redémarrer, activer / désactiver au démarrage
- 🖱️ **Partout** : souris, terminal intégré (`!`), raccourcis clavier

## Prudent par conception

Vigie peut modifier votre système, alors il est conçu pour être prudent :

- **Lecture seule par défaut** : sans `sudo`, Vigie se contente d'afficher, toutes les actions sont désactivées.
- **Confirmation avant chaque modification** : rien ne se passe sur une simple touche.
- **Rien d'exposé** : pas de service en arrière-plan, pas de port réseau, Vigie ne tourne que pendant que vous l'utilisez.
- **Code ouvert** : chaque commande lancée par Vigie est visible dans le code ([licence MIT](LICENSE)).

## Démarrage rapide

Sur **Debian / Ubuntu** (x86_64), installation depuis le dépôt APT signé :

```bash
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://vigie.elnuagee.fr/nuage-apt.gpg | sudo tee /etc/apt/keyrings/nuage-apt.gpg >/dev/null
echo "deb [signed-by=/etc/apt/keyrings/nuage-apt.gpg] https://vigie.elnuagee.fr stable main" \
  | sudo tee /etc/apt/sources.list.d/nuage.list
sudo apt update && sudo apt install vigie
```

Puis lancez-le :

```bash
vigie            # consultation seule
sudo vigie       # consultation + actions
vigie --lang en  # interface en anglais
```

Autres distributions et compilation depuis les sources : voir [Installation](docs/fr/installation.md).
Raccourcis clavier et options : voir [Utilisation](docs/fr/usage.md).

## Documentation

📖 **[Documentation complète](https://nuageeee.github.io/vigie/fr/)** : installation, utilisation, développement, architecture.

## Vos retours sont les bienvenus !

Vigie est un jeune projet, et les retours d'utilisation réelle sont ce qui l'aide le plus.

- 💬 **Une question, une idée, ou envie de raconter comment vous l'utilisez ?** Rendez-vous dans les [Discussions](https://github.com/nuageeee/vigie/discussions).
- 🐛 **Un bug ?** Ouvrez une [issue](https://github.com/nuageeee/vigie/issues), en précisant votre distribution, votre version de Vigie et votre terminal.
- ⭐ **Vigie vous plaît ?** Une étoile aide d'autres personnes à découvrir le projet.

**À venir :** versions ARM (Raspberry Pi), paquet AUR, activité disque et températures sur le tableau de bord.

## Contribuer

Les contributions sont les bienvenues ! Le [guide de développement](docs/fr/development.md) explique comment compiler Vigie, lancer les tests (`dart test`) et comment le code est organisé.

## Licence

Distribué sous licence [MIT](LICENSE). Construit avec [Dart](https://dart.dev) et [commander_ui](https://pub.dev/packages/commander_ui).