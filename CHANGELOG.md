# Changelog

## [Non publié]

### Ajouté
- **Interface en français et en anglais** : la langue suit celle du système (`LANG`), français si elle commence par `fr`, anglais sinon.
- Option `--lang fr|en` pour forcer la langue ; elle est transmise à la session relancée après le terminal intégré (`!`).

### Modifié
- Tous les textes de l'interface sont regroupés dans `lib/src/ui/strings.dart`.
- Les unités suivent la langue : `o`/`Ko`/`Mo`/`Go` et `j` en français, `B`/`KB`/`MB`/`GB` et `d` en anglais.
- Les textes qui restaient en anglais dans l'interface française (onglets, statut au démarrage, mode lecture seule…) sont traduits.

### Corrigé
- Les actions (services, processus, utilisateurs) s'exécutaient mais étaient toujours signalées en échec (« Impossible to launch … : Bad state: Stream has already been listened to ») : la sortie d'erreur des commandes était lue sur `stdout` au lieu de `stderr`.

## [0.5.0] - 2026-10-09

### Ajouté
- **Tableau de bord** entièrement revu :
  - **CPU par cœur** : une barre par cœur, avec le pourcentage et une couleur selon la charge (vert, jaune ≥ 50 %, rouge ≥ 90 %). Barres précises au huitième de case. Passage automatique sur plusieurs colonnes si les cœurs ne tiennent pas en hauteur.
  - **Disques** : toutes les partitions réelles (via `df`), avec leur taux d'occupation et l'espace total utilisé. Les systèmes de fichiers virtuels (`tmpfs`, `overlay` de Docker, `squashfs`…) sont ignorés.
  - **Mémoire** : RAM et swap, calculées comme `free` (`MemAvailable`), avec l'utilisé et le total.
  - **Réseau** : débits reçus (↓) et envoyés (↑) en direct, toutes interfaces physiques confondues (`lo`, Docker, `veth`, ponts et VPN exclus).
- Disposition en panneaux côte à côte : Disques | Mémoire et Services | Réseau.

### Modifié
- Un seul composant de barres partagé par le CPU, les disques et la mémoire : alignement identique partout, largeur des libellés adaptée au nom le plus long.
- Formateurs d'affichage (tailles, débits, uptime) regroupés côté interface.
- Suppression de l'ancienne jauge disque, limitée à `/`.

### Corrigé
- Plus de plantage si une sortie système contient une ligne inattendue (lectures tolérantes, gardes de longueur).
- Plus de division par zéro sur un serveur sans swap ou sur une partition vide.

## 0.4.0 — 2026-10-06

### Ajouté
- CPU en direct par processus : mesuré entre deux lectures de `/proc`, comme htop
  (le `%CPU` de `ps` était une moyenne sur toute la vie du processus)
- Adresse IP dans la barre système
- Dépôt APT signé : installation et mises à jour avec `apt`

### Modifié
- La liste des processus lit directement `/proc` (plus besoin de `ps`)
- Les threads du noyau sont masqués, comme dans htop

## 0.3.0 — 2026-10-05

### Ajouté
- Touche `!` (et bouton « terminal ») : ouvre un vrai bash, `exit` ramène dans Vigie
- Shell intégré : le binaire gère seul l'aller-retour Vigie ↔ bash
- Lancement automatique à la connexion via `~/.bash_profile` (voir README)
- Arrêt propre sur SIGTERM / SIGHUP (terminal toujours restauré)

## 0.2.0 — 2026-10-04

### Ajouté
- Support de la souris, façon btop :
  - clic sur les onglets pour changer de section
  - clic sur une ligne pour la sélectionner, molette pour défiler
  - boutons d'action cliquables (barre du bas, confirmation Oui / Non)
- Option `--no-mouse` pour désactiver la souris

### Corrigé
- Décalage d'affichage causé par la largeur variable des emojis (logo remplacé par `◉`)
- Le terminal est toujours restauré à la sortie (mode souris, curseur), même après un plantage ou une coupure SSH

## 0.1.0 — 2026-10-04

Première version publique.

- Tableau de bord : jauges CPU, mémoire, disque, services en échec
- Panneau système : hôte, OS, noyau, uptime
- Utilisateurs : créer, mot de passe, verrouiller, droits admin, supprimer
- Processus : liste triée par CPU, arrêt propre / forcé
- Services systemd : démarrer, arrêter, redémarrer, activer / désactiver au boot
- Confirmation avant chaque action, mode lecture seule hors root