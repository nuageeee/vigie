import 'package:commander_ui/tui.dart';
import 'package:vigie/vigie.dart';

Future<void> onEvent(VigieState s, Event event, RunHandle handle) async {
  if (event is TickEvent) {
    if (s.prompt == null) s.refreshInBackground();
    return;
  }
}