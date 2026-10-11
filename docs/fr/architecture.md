# Architecture

[Accueil de la documentation](index.md)

## Organisation du code

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

## Principes

- **Rendu en mode immédiat** : `render` redessine **tout** l'écran à partir de l'état, via [commander_ui](https://pub.dev/packages/commander_ui). L'écran est redessiné à chaque tick (2 s) et après chaque action.
- **Le rendu ne touche jamais au système** : l'interface ne fait que lire l'état. Tout ce qui lit ou modifie le système passe par `lib/src/system/`.
- **La couche système n'écrit jamais de texte pour l'utilisateur** : elle renvoie des faits bruts (code de sortie, sortie brute, erreur). C'est l'interface qui rédige le message, dans la bonne langue.
- **Les mesures par écart** (CPU, réseau) sont gardées par des *samplers* créés une seule fois dans l'état : ils mémorisent la lecture précédente.
- **Composants partagés** : les barres du CPU, des disques et de la mémoire sont dessinées par une seule fonction, qui ne reçoit que des noms et des pourcentages (0–100).

## D'où viennent les données

| Donnée | Source |
|---|---|
| CPU (total et par cœur) | `/proc/stat` (écart entre deux lectures) |
| Mémoire et swap | `/proc/meminfo` (`MemTotal`, `MemAvailable`, `SwapTotal`, `SwapFree`) |
| Disques | `df -P -k`, sans les systèmes de fichiers virtuels |
| Réseau | `/proc/net/dev` (écart entre deux lectures, interfaces virtuelles exclues) |
| Uptime | `/proc/uptime` |
| OS | `/etc/os-release` |
| Adresse IP | interfaces réseau, virtuelles exclues |
| Utilisateurs | `/etc/passwd`, `/etc/group`, `/etc/shadow` (root) |
| Processus | `/proc/<pid>/stat`, `/proc/<pid>/status` |
| Services | `systemctl list-units` + `systemctl list-unit-files` |

Précédent : [Développement](development.md) · [Accueil de la documentation](index.md)
