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
        throw new ArgumentError("$i is not in the range 0-3 for $champName");
    }
  }
}

enum DamageType { magic, physical, trueDamage }

DamageType damageTypeFromString(String string) {
  return {
    'magic': DamageType.magic,
    'physical': DamageType.physical,
    'true': DamageType.trueDamage,
  }[string.toLowerCase()];
}

String stringFromDamageType(DamageType string) {
  return {
    DamageType.magic: 'magic',
    DamageType.physical: 'physical',
    DamageType.trueDamage: 'true',
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

ScalingSource scalingSourceFromLink(String string) {
  return {
    'spelldamage': ScalingSource.spellPower,
    'bonusattackdamage': ScalingSource.bonusAttackDamage,
    'attackdamage': ScalingSource.attackDamage,
    'bonusspellblock': ScalingSource.bonusSpellBlock,
    'bonushealth': ScalingSource.bonusHealth,
    'armor': ScalingSource.armor,
  }[string];
}

String shortHandForScalingSource(ScalingSource source) {
  return {
    ScalingSource.spellPower: 'AP',
    ScalingSource.bonusAttackDamage: 'bonus AD',
    ScalingSource.attackDamage: 'AD',
    ScalingSource.bonusSpellBlock: 'bonus MR',
    ScalingSource.bonusHealth: 'bonus HP',
    ScalingSource.armor: 'Armor',
  }[source];
}

class ScaledValue {
  List<double> ratioByRank;
  ScalingSource scalingSource;
}

class DamageEffect {
  DamageType damageType;
  List<int> baseByRank;
  int maxRank;
  List<ScaledValue> ratios = [];

  DamageEffect({
    @required this.damageType,
    @required this.maxRank,
    @required this.baseByRank,
  }) {
    assert(damageType != null);
    assert(baseByRank != null);
    assert(baseByRank.length == maxRank);
  }

  void validate() {
    assert(baseByRank.length == maxRank);
    for (var ratio in ratios) assert(ratio.ratioByRank.length == maxRank);
  }

  double sumOfRatios(ScalingSource source, int rank) {
    int rankIndex = rank - 1;
    Iterable<ScaledValue> matching =
        ratios.where((ratio) => ratio.scalingSource == source);
    if (matching.isEmpty) return 0.0;
    return matching
        .map((ratio) => ratio.ratioByRank[rankIndex].toDouble())
        .reduce((a, b) => a + b);
  }

  String summaryStringForRank(int rank) {
    int rankIndex = rank - 1;
    int baseDamage = baseByRank[rankIndex];
    String summary = baseDamage == 0.0 ? '' : '${baseDamage} ';
    for (var ratio in ratios) {
      summary += '+${ratio.ratioByRank[rankIndex]} ';
      summary += shortHandForScalingSource(ratio.scalingSource) + ' ';
    }
    return summary + stringFromDamageType(damageType) + ' damage';
  }
}

class Spell {
  final String champName;
  final String name;
  final Key key;
  final Map data;
  List<DamageEffect> damageEffects = [];
  String parseError;

  Spell.fromJson({this.champName, this.key, this.data}) : name = data['name'] {
    try {
      damageEffects = parseEffects(data).toList();
    } on ArgumentError catch (e) {
      parseError = e.message;
      _log.warning(e.message);
    }
  }

  bool get doesDamage => damageEffects.isNotEmpty;

  double sumOfRatios(ScalingSource source, int rank) {
    if (damageEffects.isEmpty) return 0.0;
    return damageEffects
        .map((effect) => effect.sumOfRatios(source, rank))
        .reduce((a, b) => a + b);
  }

  String effectsSummaryForRank(int rank, {String joiner = ', '}) {
    List<String> effectSummaries = damageEffects
        .map((effect) => effect.summaryStringForRank(rank))
        .toList();
    return effectSummaries.join(joiner);
  }
}

class TooltipMatch {
  String baseVar;
  String firstScaleVar;
  String secondScaleVar;
  String damageType;
}

final RegExp _effectRegexp = new RegExp(r'\{\{ (\w+) \}\}\s*'
    r'(?:\(\+\{\{ (\w+) \}\}\)\s*)?'
    r'(?:\(\+\{\{ (\w+) \}\}\)\s*)?'
    r'(magic|physical|true) damage');

final RegExp _tagRegexp = new RegExp(r'<[^>]+?>');

Iterable<TooltipMatch> parseTooltip(String tooltip, [String spellName]) sync* {
  tooltip = tooltip.toLowerCase();
  tooltip = tooltip.replaceAll(_tagRegexp, '');
  tooltip =
      tooltip.replaceAll('magical damage', 'magic damage'); // old spelling
  tooltip = tooltip.replaceAll('  ', ' ');

  // if (spellName == "Ranger's Focus") print(tooltip);

  for (Match match in _effectRegexp.allMatches(tooltip)) {
    yield new TooltipMatch()
      ..baseVar = match[1]
      ..firstScaleVar = match[2]
      ..secondScaleVar = match[3]
      ..damageType = match[4];
  }
}

List<int> lookupEffectArray(Map data, String effectName) {
  if (!effectName.startsWith('e')) {
    throw new ArgumentError(
        'NAME $effectName is not an effect in ${data["name"]}');
  }

  List<List<int>> effects = data['effect'];
  int effectIndex = int.parse(effectName.substring(1));
  List<int> effectArray = effects[effectIndex];
  if (effectArray == null) {
    throw new ArgumentError('LOOKUP failed for $effectName in ${data["name"]}');
  }
  return effectArray;
}

void applyScaleVar(DamageEffect effect, Map data, String varName) {
  List<Map> vars = data['vars'];
  Map varMap =
      vars.firstWhere((varMap) => varMap['key'] == varName, orElse: () => null);
  if (varMap == null) {
    throw new ArgumentError(
        "VAR ${varName} is not defined for ${data['name']}");
  }

  ScaledValue ratio = new ScaledValue();
  ratio.scalingSource = scalingSourceFromLink(varMap['link']);
  if (ratio.scalingSource == null) {
    throw new ArgumentError(
        'UNKNOWN SOURCE ${varMap['link']} for ${data['name']}.');
  }

  dynamic coeffValue = varMap['coeff'];
  ratio.ratioByRank = (coeffValue is List)
      ? coeffValue
      : new List.filled(data['maxrank'], coeffValue);
  effect.ratios.add(ratio);
}

Iterable<DamageEffect> parseEffects(Map data) sync* {
  String tooltip = data['tooltip'];
  for (TooltipMatch match in parseTooltip(tooltip, data['name'])) {
    List<int> baseByRank;
    if (match.baseVar.startsWith('e')) {
      baseByRank = lookupEffectArray(data, match.baseVar);
    } else {
      // Treat baseVar as a scaleVar instead:
      if (match.secondScaleVar != null)
        throw new ArgumentError(
            'MATCHED too many variables in ${data["name"]}');
      match.secondScaleVar = match.firstScaleVar;
      match.firstScaleVar = match.baseVar;
      match.baseVar = null;
      baseByRank = new List.filled(data['maxrank'], 0);
    }
    var effect = new DamageEffect(
      damageType: damageTypeFromString(match.damageType),
      baseByRank: baseByRank,
      maxRank: data['maxrank'],
    );
    if (match.firstScaleVar != null)
      applyScaleVar(effect, data, match.firstScaleVar);
    if (match.secondScaleVar != null)
      applyScaleVar(effect, data, match.secondScaleVar);

    effect.validate();
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
