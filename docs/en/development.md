# Development

**English** | [Français](../fr/development.md) · [Documentation home](index.md)

## Run from source

```bash
dart pub get                              # without sudo
dart run bin/vigie.dart                   # read-only
sudo "$(which dart)" run bin/vigie.dart   # with root privileges
```

`sudo dart` alone does not work: `sudo` uses its own `PATH` (`secure_path`), which does not include Dart. Do not run `dart pub get` with `sudo` either, otherwise `.dart_tool/` will belong to root.

## Hot reload

With the [`hotreloader`](https://pub.dev/packages/hotreloader) package (a dev dependency), changes in `lib/` apply without restarting Vigie:

```bash
dart run --enable-vm-service bin/vigie.dart --no-session
```

> ⚠️ The `--no-session` option is required in development and hot-reload mode.

| Reloaded on the fly | Requires a restart |
|---|---|
| The interface, shortcuts, system commands | `bin/vigie.dart`, the `runTerminal` parameters, a new field in the state, a change to the sections `enum`, a new class, a file move |

## Debugging a blank screen

An exception during rendering leaves the screen empty, and the alternate screen hides the message. Redirect errors to a file:

```bash
dart run bin/vigie.dart --no-session 2> errors.log
cat errors.log
```

## Before committing

```bash
dart analyze
```

Test both languages (`--lang fr`, `--lang en`) and several terminal widths. Test root actions (users, services, processes) on a **test machine**, never on a production server.

## Building

```bash
dart compile exe bin/vigie.dart -o vigie
```

The Debian package is built with `scripts/build-deb.sh`.

Previous: [Usage](usage.md) · Next: [Architecture](architecture.md)
