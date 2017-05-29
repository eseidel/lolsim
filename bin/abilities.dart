#!/usr/local/bin/dart
import 'package:lol_duel/dragon/spell_parser.dart';
import 'package:lol_duel/utils/cli_table.dart';
import 'package:lol_duel/utils/common_args.dart';

dynamic main(List<String> args) async {
  handleCommonArgs(args);
  SpellLibrary spells = await SpellLibrary.load();
  List<SpellDescription> allSpells = spells.allSpells;

  List<SpellDescription> doesDamage =
      spells.allSpells.where((spell) => spell.doesDamage).toList();

  RegExp damageRegexp = new RegExp('amage');
  List<SpellDescription> mentionsDamage = spells.allSpells
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
  List<SpellDescription> parseError =
      allSpells.where((var spell) => spell.parseError != null).toList();
  print("Total: ${allSpells.length}");
  print("Parse Error: ${parseError.length}"); // 40
  print("Does damage: ${doesDamage.length}"); // 305
  print("Mentions damage: ${mentionsDamage.length}"); // 471

  TableLayout layout = new TableLayout([30, 50]);
  layout.printRow(['Ability', 'Damage']);
  layout.printDivider();

  for (SpellDescription spell in doesDamage) {
    layout.printRow([spell.name, spell.effectsSummaryForRank(1)]);
  }

  // mentionsDamage.forEach((var spell) {
  //   if (doesDamage.contains(spell)) return;
  //   String errorString = spell.parseError ? '* ' : '';
  //   print("$errorString${spell.name}");
  //   // print(spell.data['tooltip']);
  // });
}
