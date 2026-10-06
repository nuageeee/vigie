# Changelog

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