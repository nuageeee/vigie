# Développement

[English](../en/development.md) | **Français** · [Accueil de la documentation](index.md)

## Lancer depuis les sources

```bash
dart pub get                              # sans sudo
dart run bin/vigie.dart                   # lecture seule
sudo "$(which dart)" run bin/vigie.dart   # avec les droits root
```

`sudo dart` seul ne fonctionne pas : `sudo` utilise son propre `PATH` (`secure_path`), qui ne contient pas Dart. Ne lancez pas non plus `dart pub get` avec `sudo`, sinon `.dart_tool/` appartiendra à root.

## Hot reload

Avec le package [`hotreloader`](https://pub.dev/packages/hotreloader) (en dev dependency), les modifications dans `lib/` s'appliquent sans relancer Vigie :

```bash
dart run --enable-vm-service bin/vigie.dart --no-session
```

> ⚠️ L'option `--no-session` est obligatoire en développement et en hot reload.

| Se recharge à chaud | Demande de relancer |
|---|---|
| L'interface, les raccourcis, les commandes système | `bin/vigie.dart`, les paramètres de `runTerminal`, un nouveau champ dans l'état, une modification de l'`enum` des sections, une nouvelle classe, un déplacement de fichier |

## Déboguer un écran vide

Une exception pendant le rendu laisse l'écran vide, et l'écran alternatif cache le message. Redirigez les erreurs vers un fichier :

```bash
dart run bin/vigie.dart --no-session 2> erreurs.log
cat erreurs.log
```

## Avant de commiter

```bash
dart analyze
```

Testez les deux langues (`--lang fr`, `--lang en`) et plusieurs largeurs de terminal. Testez les actions root (utilisateurs, services, processus) sur une **machine de test**, jamais sur un serveur de production.

## Compiler

```bash
dart compile exe bin/vigie.dart -o vigie
```

Le paquet Debian est construit avec `scripts/build-deb.sh`.

Précédent : [Utilisation](usage.md) · Suite : [Architecture](architecture.md)
