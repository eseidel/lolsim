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

enum ScalingSource {
  spellPower,
  attackDamage,
  bonusAttackDamage,
  bonusSpellBlock,
  bonusHealth,
  armor,
}

ScalingSource scalingSourceFromString(String string) {
  return {
    'spelldamage': ScalingSource.spellPower,
    'bonusattackdamage': ScalingSource.bonusAttackDamage,
    'attackdamage': ScalingSource.attackDamage,
    'bonusspellblock': ScalingSource.bonusSpellBlock,
    'bonushealth': ScalingSource.bonusHealth,
    'armor': ScalingSource.armor,
  }[string];
}

class DamageEffect {
  DamageType damageType;
  List<double> baseByRank;
  List<double> ratioByRank;
  ScalingSource scalingSource;

  DamageEffect({
    @required this.damageType,
    this.baseByRank,
    this.ratioByRank,
    this.scalingSource,
  });
}

class Spell {
  final String champName;
  final String name;
  final Key key;
  final Map data;
  List<DamageEffect> damageEffects = [];
  bool parseError = false;

  Spell.fromJson({this.champName, this.key, this.data}) : name = data['name'] {
    try {
      damageEffects = parseEffects(data).toList();
    } on ArgumentError catch (e) {
      parseError = true;
      _log.warning(e.message);
    }
  }

  bool get doesDamage => damageEffects.isNotEmpty;
}

final RegExp effectRegexp =
    new RegExp(r'(?:<span[^>]*>\s*)?\{\{ (\w+) \}\}\s*(?:</span>\s*)?'
        r'<span[^>]*>\s*\(\+\{\{ (\w+) \}\}\)</span>\s*'
        r'(?:<span[^>]*>\s*\(\+\{\{ (\w+) \}\}\)</span>\s*)?'
        r'([Mm]agic|[Pp]hysical|[Tt]rue)');

List<double> lookupEffectArray(Map data, String effectName) {
  assert(effectName.startsWith('e'));
  assert(effectName.length == 2);
  List<List<double>> effects = data['effect'];
  int effectIndex = int.parse(effectName.substring(1));
  return effects[effectIndex];
}

void applyScaleVar(DamageEffect effect, Map data, String varName) {
  List<Map> vars = data['vars'];
  Map varMap =
      vars.firstWhere((varMap) => varMap['key'] == varName, orElse: () => null);
  if (varMap == null) {
    throw new ArgumentError("${data['name']} VAR ${varName} is not defined");
  }

  dynamic coeffValue = varMap['coeff'];
  if (coeffValue is List)
    effect.ratioByRank = coeffValue;
  else
    effect.ratioByRank = new List.filled(data['maxrank'], coeffValue);

  effect.scalingSource = scalingSourceFromString(varMap['link']);
  if (effect.scalingSource == null) {
    throw new ArgumentError(
        '${data['name']} UNKNOWN SOURCE ${varMap['link']}.');
  }
}

Iterable<DamageEffect> parseEffects(Map data) sync* {
  String tooltip = data['tooltip'];
  for (Match match in effectRegexp.allMatches(tooltip)) {
    String baseVar = match[1];
    String firstScaleVar = match[2];
    String secondScaleVar = match[3];
    String damageType = match[4];

    var effect = new DamageEffect(
      damageType: damageTypeFromString(damageType),
      baseByRank: lookupEffectArray(data, baseVar),
    );
    applyScaleVar(effect, data, firstScaleVar);
    if (secondScaleVar != null) {
      applyScaleVar(effect, data, secondScaleVar);
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
