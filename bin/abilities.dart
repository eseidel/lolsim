#!/usr/local/bin/dart
import 'package:lol_duel/common_args.dart';
import 'package:lol_duel/spell_parser.dart';

dynamic main(List<String> args) async {
  handleCommonArgs(args);
  SpellFactory spells = await SpellFactory.load();
  List<Spell> allSpells = spells.allSpells;

  RegExp damageRegexp = new RegExp('amage');

  allSpells.forEach((spell) {
    if (spell.damageEffects.length > 0) return;
    String tooltip = spell.data['tooltip'];
    if (!tooltip.contains(damageRegexp)) return;
    print(
        "${spell.champName} ${spell.key} ${spell.data['name']} ${spell.damageEffects.length}");
    // print(spell.champName);
    // print(spell.data['tooltip']);
    // spell.data.keys.forEach((key) => print(key));
    // spell.data['vars'].forEach((key) => print(key));
    // spell.data['effect'].forEach((key) => print(key));
  });
  print("count: ${allSpells.length}"); // currently 536
}
