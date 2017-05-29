#!/usr/local/bin/dart
import 'package:logging/logging.dart';
import 'package:lol_duel/dragon/spell_parser.dart';
import 'package:lol_duel/utils/common_args.dart';

dynamic main(List<String> args) async {
  handleCommonArgs(args, defaultLogLevel: Level.SEVERE);
  SpellLibrary spells = await SpellLibrary.load();
  List<SpellDescription> allSpells = spells.allSpells;

  List<SpellDescription> doesDamage =
      spells.allSpells.where((spell) => spell.doesDamage).toList();

  RegExp damageRegexp = new RegExp('amage');
  List<SpellDescription> mentionsDamage = spells.allSpells
      .where((spell) => spell.data['tooltip'].contains(damageRegexp))
      .toList();

  List<SpellDescription> parseError =
      allSpells.where((var spell) => spell.parseError != null).toList();
  print("Total: ${allSpells.length}");
  print("Parse Error: ${parseError.length}"); // 40
  print("Does damage: ${doesDamage.length}"); // 305
  print("Mentions damage: ${mentionsDamage.length}"); // 471

  for (var spell in allSpells) {
    print('${spell.champName} ${spell.name}');
    if (spell.parseError != null) print('ERROR: ${spell.parseError}');
    String effectsString = spell.effectsSummaryForRank(1, joiner: '\n');
    if (effectsString.isNotEmpty) print(effectsString);
  }
}
