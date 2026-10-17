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
  components/                 Panneaux réutilisables (barres partagées, lignes de débit, sparklines, formateurs)
  tables.dart                 Tableaux utilisateurs / processus / services, et le top processus du tableau de bord
  strings.dart                Tous les textes de l'interface, en français et en anglais
lib/src/system/               Accès au système uniquement → renvoie des objets Dart simples, jamais de texte pour l'utilisateur
  shell.dart                  Lancement de commandes, lecture de fichiers
  overview.dart               CPU, mémoire, disques, activité disque, réseau, uptime, OS ; samplers et historique
  guards.dart                 Règles de refus (se verrouiller soi-même, SSH, root, dernier admin, PID 1, Vigie lui-même)
  users.dart                  /etc/passwd, /etc/group, /etc/shadow, useradd, usermod…
  processes.dart              /proc/<pid>, kill
  services.dart               systemctl
```

## Principes

- **Rendu en mode immédiat** : `render` redessine **tout** l'écran à partir de l'état, via [commander_ui](https://pub.dev/packages/commander_ui). L'écran est redessiné à chaque tick (2 s) et après chaque action.
- **Le rendu ne touche jamais au système** : l'interface ne fait que lire l'état. Tout ce qui lit ou modifie le système passe par `lib/src/system/`.
- **La couche système n'écrit jamais de texte pour l'utilisateur** : elle renvoie des faits bruts (code de sortie, sortie brute, erreur). C'est l'interface qui rédige le message, dans la bonne langue.
- **Les mesures par écart** (CPU, réseau, activité disque, CPU par processus) sont gardées par des *samplers* créés une seule fois dans l'état : ils mémorisent la lecture précédente. Les compteurs qui ne font qu'augmenter (octets réseau, secteurs disque) partagent un `RateSampler` générique, et les valeurs récentes sont gardées dans un `History` borné (90 mesures) pour les sparklines.
- **Coût du rafraîchissement** : ce qui ne change jamais est lu une seule fois (`uname`, `/etc/os-release`), les disques toutes les 30 s, les services toutes les 10 s et tout de suite après une action ; le reste à chaque tick.
- **Garde-fous avant les actions** : chaque action risquée interroge d'abord `guards.dart`. Les garde-fous sont des fonctions pures (des faits en entrée, une raison de refus en sortie), donc entièrement testées ; l'interface transforme la raison en message traduit.
- **Composants partagés** : les barres du CPU, des disques et de la mémoire sont dessinées par une seule fonction, qui ne reçoit que des noms et des pourcentages (0–100).

## D'où viennent les données

| Donnée | Source |
|---|---|
| CPU (total et par cœur) | `/proc/stat` (écart entre deux lectures) |
| Mémoire et swap | `/proc/meminfo` (`MemTotal`, `MemAvailable`, `SwapTotal`, `SwapFree`) |
| Disques | `df -P -k`, vrais périphériques uniquement (`/dev/…`, sans `loop`), chacun une seule fois |
| Activité disque | `/proc/diskstats` (disques entiers uniquement, sans partitions/LVM/loop, secteurs × 512, écart entre deux lectures) |
| Réseau | `/proc/net/dev` (écart entre deux lectures, interfaces virtuelles exclues) |
| Uptime | `/proc/uptime` |
| OS | `/etc/os-release` |
| Adresse IP | interfaces réseau, virtuelles exclues |
| Utilisateurs | `/etc/passwd`, `/etc/group`, `/etc/shadow` (root) |
| Processus | `/proc/<pid>/stat`, `/proc/<pid>/status` |
| Services | `systemctl list-units` + `systemctl list-unit-files` |

Précédent : [Développement](development.md) · [Accueil de la documentation](index.md)
