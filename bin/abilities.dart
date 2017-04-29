#!/usr/local/bin/dart
import 'package:lol_duel/common_args.dart';
import 'package:lol_duel/spell_parser.dart';

dynamic main(List<String> args) async {
  handleCommonArgs(args);
  SpellFactory spells = await SpellFactory.load();
  List<Spell> allSpells = spells.allSpells;

  List<Spell> doesDamage =
      spells.allSpells.where((spell) => spell.doesDamage).toList();

  RegExp damageRegexp = new RegExp('amage');
  List<Spell> mentionsDamage = spells.allSpells
      .where((spell) => spell.data['tooltip'].contains(damageRegexp))
      .toList();

  // allSpells.forEach((spell) {
  //   if (spell.damageEffects.length > 0) return;
  //   String tooltip = spell.data['tooltip'];
  //   if (!tooltip.contains(damageRegexp)) return;
  //   print(
  //       "${spell.champName} ${spell.key} ${spell.data['name']} ${spell.damageEffects.length}");
  //   // print(spell.champName);
  //   // print(spell.data['tooltip']);
  //   // spell.data.keys.forEach((key) => print(key));
  //   // spell.data['vars'].forEach((key) => print(key));
  //   // spell.data['effect'].forEach((key) => print(key));
  // });
  List<Spell> parseError =
      allSpells.where((var spell) => spell.parseError).toList();
  print("Total: ${allSpells.length}");
  print("Parse Error: ${parseError.length}"); // 40
  print("Does damage: ${doesDamage.length}"); // 305
  print("Mentions damage: ${mentionsDamage.length}"); // 471

  for (Spell spell in doesDamage) {
    print('${spell.name}');
    for (var effect in spell.damageEffects) {
      print(effect.summaryStringForRank(1));
    }
  }

  // mentionsDamage.forEach((var spell) {
  //   if (doesDamage.contains(spell)) return;
  //   String errorString = spell.parseError ? '* ' : '';
  //   print("$errorString${spell.name}");
  //   // print(spell.data['tooltip']);
  // });
}
