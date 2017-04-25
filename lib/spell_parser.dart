import 'dart:convert';

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

enum DamageType { magic, physical, trueDamage }

DamageType damageTypeFromString(String string) {
  return {
    'magic': DamageType.magic,
    'physical': DamageType.physical,
    'true': DamageType.trueDamage,
  }[string];
}

class DamageEffect {
  DamageType type;
  double base;
  double apRatio;
  double adRatio;
  DamageEffect({this.type, this.base, this.apRatio, this.adRatio});
}

class Spell {
  String champName;
  Key key;
  List<DamageEffect> damageEffects;
  Map data;

  Spell.fromJson({this.champName, this.key, Map json}) : data = json {
    damageEffects = parseEffects(json).toList();
  }
}

final RegExp effectRegexp = new RegExp(
    r'\{\{ (\w{2}) \}\} <span[^>]*>\(\+\{\{ (\w{2}) \}\}\)</span> (magic|physical|true) damage');

double lookupForRank(Map data, String effectName, int rank) {
  assert(effectName.startsWith('e'));
  assert(effectName.length == 2);
  List<List<double>> effects = data['effect'];
  int effectIndex = int.parse(effectName[1]);
  return effects[effectIndex][rank - 1];
}

Iterable<DamageEffect> parseEffects(Map data) sync* {
  String tooltip = data['tooltip'];
  List<Map> vars = data['vars'];
  for (Match match in effectRegexp.allMatches(tooltip)) {
    String baseVar = match[1];
    String scaleVar = match[2];
    String damageType = match[3];
    print(scaleVar);
    print(JSON.encode(vars));
    Map varMap = vars.firstWhere((varMap) => varMap['key'] == scaleVar,
        orElse: () => null);
    if (varMap == null) {
      print("ERROR");
      print(data['name']);
      continue;
    }

    var effect = new DamageEffect(
      type: damageTypeFromString(damageType),
      base: lookupForRank(data, baseVar, 1),
    );

    double ratio = varMap['coeff'];
    String scalingSource = varMap['link'];
    if (scalingSource == 'spelldamage')
      effect.apRatio = ratio;
    else if (scalingSource == 'bonusattackdamage')
      effect.adRatio = ratio;
    else {
      print('Unknown scaling source $scalingSource');
      assert(false);
    }
  }
}
