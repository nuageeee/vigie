# TODO

Défauts d'affichage relevés pendant l'internationalisation (branche `feat/i18n`).
Ils existaient déjà avant ; ils ne sont pas corrigés dans cette branche.
Largeurs en colonnes de terminal, mesurées dans tmux sauf mention « calculé »
(déduit des longueurs de libellés et du code de mise en page).

## Barre d'actions

- **Boutons généraux masqués** (`! terminal`, `F5 rafraîchir`, `q quitter`) : ils ne
  s'affichent que s'ils tiennent entièrement à droite des boutons de la section, sinon
  ils disparaissent sans remplacement. Il n'y a alors plus de bouton pour quitter à la souris.
  | Section | FR : visibles à partir de | EN : visibles à partir de |
  |---|---|---|
  | Utilisateurs | 112 | 88 |
  | Services | 120 | 101 |
  | Processus | 64 (calculé) | 55 (calculé) |
- **Bouton de section coupé** : sous 78 colonnes en FR (calculé ; absent à 75, présent à 80), `d désactiver boot` (Services)
  n'est pas affiché ; en dessous, les derniers boutons disparaissent un à un. En EN, tous
  les boutons de Services tiennent jusqu'à 70 colonnes.

## Onglets

- **Premier onglet masqué** : l'onglet qui chevaucherait le logo n'est pas dessiné.
  FR : `1 Aperçu` disparaît sous 66 colonnes ; EN : `1 Dashboard` sous 62 (calculé).
- **Zone cliquable invisible** : l'onglet masqué garde sa zone cliquable, posée
  par-dessus le logo `◉ Vigie`.

## Tableau de bord

- **Titres de panneaux tronqués** : le titre est coupé sans `…` quand il dépasse la
  largeur du panneau. La longueur dépend des valeurs affichées ; mesures avec
  « 24.3 Go » de disque et « 8.8 Go / 22.9 Go » de mémoire :
  | Panneau | FR : complet à partir de | EN : complet à partir de |
  |---|---|---|
  | Disques / Disks | 88 | 88 |
  | Mémoires / Memory | 120 | 112 |

## Barre d'état

- **Erreur de lancement sur deux lignes** : quand une commande ne peut pas être lancée,
  le message contient le `toString()` de `ProcessException`, qui ajoute une ligne
  `  Command: …`. La barre d'état ne fait qu'une ligne (toutes largeurs).
