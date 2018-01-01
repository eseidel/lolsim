import 'package:lol_duel/dragon/dragon.dart';
import 'package:lol_duel/mob.dart';
import 'package:lol_duel/rune_pages.dart';

// FIXME: Unclear exactly how to factor this, but champion.gg parsing
// code shouldn't need to know about mob.dart.

RunePage runesFromHash(RuneLibrary library, String hash) {
  // path-id-id-id-id-path-id-id
  // e.g. 8000-8005-9111-9104-8014-8200-8234-8236
  List<String> strings = hash.split('-');
  assert(strings.length == 8);
  List<int> ints = strings.map(int.parse).toList();
  int secondaryPathId = ints.removeAt(5);
  assert(RuneDescription.pathById(secondaryPathId) != null);
  int primaryPathId = ints.removeAt(0);
  assert(RuneDescription.pathById(primaryPathId) != null);
  List<Rune> runes =
      ints.map((int id) => new Rune(library.runeById(id))).toList();
  return new RunePage(runes: runes);
}
