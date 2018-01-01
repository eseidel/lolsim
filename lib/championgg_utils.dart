import 'package:lol_duel/dragon/dragon.dart';
import 'package:lol_duel/mob.dart';
import 'package:lol_duel/rune_pages.dart';

// FIXME: Unclear exactly how to factor this, but champion.gg parsing
// code shouldn't need to know about mob.dart.

RunePage runesFromHash(RuneLibrary library, String hash) {
  // id-count-id-count...
  List<String> strings = hash.split('-');
  int index = 0;
  List<Rune> runes = [];
  while (index < strings.length) {
    int id = int.parse(strings[index++]);
    int count = int.parse(strings[index++]);
    runes.addAll(
        new List.generate(count, (int _) => new Rune(library.runeById(id))));
  }
  return new RunePage(runes: runes);
}
