import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'dragon_loader.dart';

final Logger _log = new Logger('spell_parser');

class Key {
  final String char;
  const Key(this.char);

  static Key q = const Key('Q');
  static Key w = const Key('W');
  static Key e = const Key('E');
  static Key r = const Key('R');

  factory Key.fromIndex(int index) {
    return [
      Key.q,
      Key.w,
      Key.e,
      Key.r,
    ][index];
  }

  @override
  String toString() => char;
}

class SpellBook {
  String champName;
  Spell q;
  Spell e;
  Spell w;
  Spell r;

  operator []=(int i, Spell spell) {
    switch (i) {
      case 0:
        q = spell;
        break;
      case 1:
        e = spell;
        break;
      case 2:
        w = spell;
        break;
      case 3:
        r = spell;
        break;
      default:
        throw new ArgumentError("$i is not in the range 0-3");
    }
  }
}

enum DamageType { magic, physical, trueDamage }

DamageType damageTypeFromString(String string) {
  return {
    'magic': DamageType.magic,
    'physical': DamageType.physical,
    'true': DamageType.trueDamage,
  }[string];
}

class DamageEffect {
  DamageType damageType;
  double base;
  double apRatio;
  double adRatio;
  DamageEffect({
    @required this.damageType,
    this.base: 0.0,
    this.apRatio: 0.0,
    this.adRatio: 0.0,
  });
}

class Spell {
  final String champName;
  final String name;
  final Key key;
  final Map data;
  List<DamageEffect> damageEffects;

  Spell.fromJson({this.champName, this.key, this.data})
      : name = data['name'],
        damageEffects = parseEffects(data).toList();

  bool get doesDamage => damageEffects.length > 0;

  // FIXME: This doesn't work yet.
  List<DamageEffect> damageEffectsAtRank(int rank) => damageEffects;
}

final RegExp effectRegexp = new RegExp(
    r'\{\{ (\w+) \}\}\s*<span[^>]*>\s*\(\+\{\{ (\w+) \}\}\)</span>\s*(?:<span[^>]*>\s*\(\+\{\{ (\w+) \}\}\)</span>\s*)?([Mm]agic|[Pp]hysical|[Tt]rue)');

double lookupForRank(Map data, String effectName, int rank) {
  assert(effectName.startsWith('e'));
  assert(effectName.length == 2);
  List<List<double>> effects = data['effect'];
  int effectIndex = int.parse(effectName.substring(1));
  return effects[effectIndex][rank - 1].toDouble();
}

bool applyScaleVar(DamageEffect effect, Map data, String varName, int rank) {
  List<Map> vars = data['vars'];
  Map varMap =
      vars.firstWhere((varMap) => varMap['key'] == varName, orElse: () => null);
  if (varMap == null) {
    _log.warning(
        "${data['name']} references ${varName} which is not defined, ignoring.");
    return false;
  }

  dynamic coeffValue = varMap['coeff'];
  double ratio;
  if (coeffValue is List)
    ratio = coeffValue[rank - 1];
  else
    ratio = coeffValue;

  String scalingSource = varMap['link'];
  if (scalingSource == 'spelldamage')
    effect.apRatio = ratio;
  else if (scalingSource == 'bonusattackdamage')
    effect.adRatio = ratio;
  else if (scalingSource == 'attackdamage')
    effect.adRatio = ratio;
  else {
    _log.warning(
        '${data['name']} uses unknown scaling source $scalingSource, ignoring.');
    return false;
  }
  return true;
}

Iterable<DamageEffect> parseEffects(Map data) sync* {
  String tooltip = data['tooltip'];
  int rank = 1;
  for (Match match in effectRegexp.allMatches(tooltip)) {
    String baseVar = match[1];
    String firstScaleVar = match[2];
    String secondScaleVar = match[3];
    String damageType = match[4];

    var effect = new DamageEffect(
      damageType: damageTypeFromString(damageType),
      base: lookupForRank(data, baseVar, rank),
    );
    if (!applyScaleVar(effect, data, firstScaleVar, rank)) continue;
    if (secondScaleVar != null) {
      if (!applyScaleVar(effect, data, secondScaleVar, rank)) continue;
    }

    yield effect;
  }
}

class SpellFactory {
  List<Spell> allSpells;
  Map<String, SpellBook> _bookByChampionName;

  SpellFactory.fromJson(Map<String, dynamic> json) {
    allSpells = [];
    _bookByChampionName = {};
    json['data'].values.forEach((champ) {
      List spells = champ['spells'];
      SpellBook book = new SpellBook();
      _bookByChampionName[champ['name']] = book;
      for (int x = 0; x < spells.length; x++) {
        Spell spell = new Spell.fromJson(
          champName: champ['name'],
          key: new Key.fromIndex(x),
          data: spells[x],
        );
        book[x] = spell;
        allSpells.add(spell);
      }
    });
  }

  static Future<SpellFactory> load({DragonLoader loader}) async {
    loader = loader ?? new LocalLoader();
    Map json = JSON.decode(await loader.load('championFull.json'));
    return new SpellFactory.fromJson(json);
  }

  SpellBook bookForChampionName(String championName) {
    return _bookByChampionName[championName];
  }
}
