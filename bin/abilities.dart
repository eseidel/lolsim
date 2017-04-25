#!/usr/local/bin/dart
import 'dart:convert';

import 'package:lol_duel/common_args.dart';
import 'package:lol_duel/dragon_loader.dart';
import 'package:lol_duel/spell_parser.dart';

dynamic main(List<String> args) async {
  handleCommonArgs(args);
  var loader = new LocalLoader();
  var json = JSON.decode(await loader.load('championFull.json'));

  List<Spell> allSpells = [];

  // json['data'].values.first['spells'].first.keys.forEach((name) {
  //   print(name);
  // });
  // print(json['data'].values.first['spells'].first['tooltip']);

  json['data'].values.forEach((champ) {
    List spells = champ['spells'];
    for (int x = 0; x < spells.length; x++) {
      allSpells.add(new Spell.fromJson(
        champName: champ['name'],
        key: new Key.fromIndex(x),
        json: spells[x],
      ));
    }
  });

  // json['data'].values.forEach((champ) {
  //   champ['spells'].forEach((spell) {
  //     tuples.add([champ['name'], spell['name'], spell['cooldown'].first, spell['cost'].first]);
  //   });
  // });
  // Collect all abilities.
  // Sort them by cost, cooldown, etc.

  allSpells.forEach((spell) {
    print(
        "${spell.champName} ${spell.key} ${spell.data['name']} ${spell.damageEffects.length}");
    // print(spell.champName);
    print(spell.data['tooltip']);
    spell.data.keys.forEach((key) => print(key));
    spell.data['vars'].forEach((key) => print(key));
    spell.data['effect'].forEach((key) => print(key));
  });

  // spells.sort((a, b) {
  //
  // });

  // tuples.forEach((spell) {
  //   if (spell[2] < 5) print(spell);
  // });
}
