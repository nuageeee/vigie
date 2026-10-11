# Utilisation

[English](../en/usage.md) | **Français** · [Accueil de la documentation](index.md)

## Lancer Vigie

```bash
vigie                  # consultation seule
sudo vigie             # consultation + actions (créer un compte, redémarrer un service…)
sudo vigie --no-mouse  # consultation + actions, sans la souris
vigie --lang en        # interface en anglais
```

Sans les droits root, Vigie démarre en **mode lecture seule** : tout est visible, mais les actions qui modifient le système sont refusées.

## Options

| Option | Effet |
|---|---|
| `--no-mouse` | Désactive la souris (utile dans tmux sans `mouse on`, ou pour sélectionner du texte) |
| `--lang fr\|en` | Langue de l'interface. Par défaut, celle du système (`LANG`) : français si elle commence par `fr`, sinon anglais |

> 💡 En SSH, la langue est celle du **serveur**, pas celle de votre ordinateur. Beaucoup de serveurs sont en `C.UTF-8` ou `en_US` : utilisez `--lang` pour choisir.

## Sections

| Touche | Section | Contenu |
|---|---|---|
| `1` | Aperçu | CPU par cœur, disques, mémoire et swap, réseau, résumé des services |
| `2` | Utilisateurs | Comptes humains (root et UID ≥ 1000) |
| `3` | Processus | Processus triés par consommation CPU |
| `4` | Services | Services systemd, ceux en échec en premier |

## Raccourcis clavier

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
| | `g` | Donner / retirer les droits admin (groupe `sudo` ou `wheel`) |
| | `D` | Supprimer (avec son dossier) |
| **Processus** | `t` | Arrêt propre (SIGTERM) |
| | `K` | Arrêt forcé (SIGKILL) |
| **Services** | `s` | Démarrer |
| | `x` | Arrêter |
| | `r` | Redémarrer |
| | `e` | Activer au démarrage |
| | `d` | Désactiver au démarrage |

Toute action qui modifie le système demande d'abord une **confirmation**.

> ⚠️ Connecté en SSH, évitez d'arrêter `ssh.service` : vous perdriez l'accès au serveur.

## Souris

- Cliquez sur un onglet pour changer de section, sur une ligne pour la sélectionner, sur un bouton pour lancer son action.
- La molette fait défiler le tableau sous le pointeur.
- Souris active : maintenez `Maj` pour sélectionner du texte dans le terminal.

Quand le terminal est étroit, les boutons de la section passent en forme compacte (la touche seule, par exemple `[s][x][r]`). Les boutons généraux (terminal, rafraîchir, quitter) restent toujours visibles.

## Terminal intégré

`!` ouvre un shell (`bash`) directement depuis Vigie. Son invite commence par `(vigie)` pour savoir où l'on est. Tapez `exit` pour revenir dans Vigie, dans la section que vous aviez quittée.

Précédent : [Installation](installation.md) · Suite : [Développement](development.md)
