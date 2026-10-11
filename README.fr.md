# ◉ Vigie

[English](README.md) | **Français**

**Gérer un serveur Linux depuis une seule fenêtre de terminal.**

Vigie est une interface en mode texte (TUI) qui regroupe au même endroit ce qu'on fait habituellement avec une dizaine de commandes : surveiller la machine, gérer les comptes utilisateurs, surveiller les processus et piloter les services systemd. Pas de navigateur, pas d'agent à installer, pas de port à ouvrir : un seul binaire, lancé en SSH. Disponible en français et en anglais.

![Vigie](screen.png)

## Fonctionnalités

- **Tableau de bord** : CPU par cœur, disques, mémoire et swap, débits réseau en direct, services en échec
- **Utilisateurs** : créer, changer le mot de passe, verrouiller / déverrouiller, donner / retirer les droits admin, supprimer
- **Processus** : triés par CPU instantané, arrêt propre ou forcé
- **Services** : démarrer, arrêter, redémarrer, activer / désactiver au démarrage
- **Partout** : souris, terminal intégré, confirmation avant chaque modification, mode lecture seule automatique sans root

## Installation (Debian / Ubuntu)

```bash
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://vigie.elnuagee.fr/nuage-apt.gpg | sudo tee /etc/apt/keyrings/nuage-apt.gpg >/dev/null
echo "deb [signed-by=/etc/apt/keyrings/nuage-apt.gpg] https://vigie.elnuagee.fr stable main" \
  | sudo tee /etc/apt/sources.list.d/nuage.list
sudo apt update && sudo apt install vigie
```

Autres distributions et compilation depuis les sources : voir [Installation](docs/fr/installation.md).

## Utilisation

```bash
vigie            # consultation seule
sudo vigie       # consultation + actions
vigie --lang en  # interface en anglais
```

Raccourcis clavier et options : voir [Utilisation](docs/fr/usage.md).

## Documentation

📖 **[Documentation complète](docs/fr/index.md)** : installation, utilisation, développement, architecture.

## Licence

Distribué sous licence [MIT](LICENSE). Construit avec [Dart](https://dart.dev) et [commander_ui](https://pub.dev/packages/commander_ui).
