#!/usr/local/bin/dart
import 'package:lol_duel/common_args.dart';
import 'dart:io';
import 'dart:convert';

class Spell {
  String champ;
  Map data;
}

main(List<String> args) async {
  handleCommonArgs(args);

  String path = 'packages/dragon_data/5.14.1/data/en_US/championFull.json';
  String string = new File(path).readAsStringSync();
  var json = JSON.decode(string);
  List<Spell> damageSpells = [];

  // json['data'].values.first['spells'].first.keys.forEach((name) {
  //   print(name);
  // });
  // print(json['data'].values.first['spells'].first['tooltip']);
  var damage = new RegExp('amage');
  json['data'].values.forEach((champ) {
    List spells = champ['spells'];
    for (int x = 0; x < spells.length; x++) {
      var spell = spells[x];
      if (spell['tooltip'].contains(damage)) {
        damageSpells.add(new Spell()
          ..champ = champ['name']
          ..data = spell);
      }
      // var tooltip = spell['tooltip'];
      // if (!tooltip.contains(damage)) {
      //   print("${champ['name']} ${tooltip}");
      // }
      // tuples.add([champ['name'], spell['name'], spell['cooldown'].first, spell['cost'].first]);
    }
  });

  // json['data'].values.forEach((champ) {
  //   champ['spells'].forEach((spell) {
  //     tuples.add([champ['name'], spell['name'], spell['cooldown'].first, spell['cost'].first]);
  //   });
  // });
  // Collect all abilities.
  // Sort them by cost, cooldown, etc.

  damageSpells.forEach((spell) {
    print(spell.champ);
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
