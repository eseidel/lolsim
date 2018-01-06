import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'stat_constants.dart';

double letalityToFlatPenatration(int targetLevel) {
  //  LETHALITY × (0.6 + 0.4 × Target's level ÷ 18)
  return 0.6 + 0.4 * targetLevel / 18.0;
}

final Logger _log = new Logger('stats');

typedef StatApplier = void Function(Stats stats, num value);

// FIXME: There is probably a better way to do this where we combine all the
// stat modifications together in json form and then collapse them all at the end instead.
// FIXME: These are neither complete, nor necessarily correct.
final Map<String, StatApplier> _statAppliersByName = {
  FlatHPPoolMod: (stats, value) => stats.bonusHp += value,
  FlatCritChanceMod: (stats, value) => stats.critChance += value,
  FlatMagicDamageMod: (stats, value) => stats.abilityPower += value,
  FlatMPPoolMod: (stats, value) => stats.mp += value,

  PercentSpellBlockMod: (stats, value) =>
      stats.percentSpellBlockMod = (100.0 + value) / 100,
  FlatSpellBlockMod: (stats, value) => stats.flatSpellBlockMod += value,

  FlatPhysicalDamageMod: (stats, value) => stats.bonusAttackDamage += value,
  PercentAttackSpeedMod: (stats, value) => stats.percentAttackSpeedMod += value,
  PercentLifeStealMod: (stats, value) => stats.lifesteal += value,

  FlatArmorMod: (stats, value) => stats.addBonusArmor(value.toDouble()),
  // FIXME: PercentArmorMod is wrong!  It should not be =, but rather *=?
  PercentArmorMod: (stats, value) =>
      stats.percentArmorMod = (100.0 + value) / 100,
  FlatArmorReduction: (stats, value) => stats.flatArmorReduction += value,

  FlatMagicPenetrationMod: (stats, value) =>
      stats.flatMagicPenetration += value,
  PercentMagicPenetrationMod: (stats, value) =>
      stats.percentMagicPenetration *= (100.0 - value) / 100,

  Lethality: (stats, value) => stats.lethality += value,
  PercentArmorPenetrationMod: (stats, value) =>
      stats.percentArmorPenetration *= (100.0 - value) / 100,
  PercentBonusArmorPenetrationMod: (stats, value) =>
      stats.percentBonusArmorPenetration *= (100.0 - value) / 100,

  FlatHPRegenMod: (stats, value) => stats.flatHpRegenMod += value,
  FlatMPRegenMod: (stats, value) => stats.flatMpRegenMod += value,
  PercentBaseHPRegenMod: (stats, value) => stats.percentBaseHpRegenMod += value,
  PercentBaseMPRegenMod: (stats, value) => stats.percentBaseMpRegenMod += value,

  PercentCooldownMod: (stats, value) => stats.percentCooldownMod += value,

  // 'FlatMovementSpeedMod': (stats, value) => stats.movespeed += value,
  // 'PercentMovementSpeedMod': (stats, value) => stats.movespeed *= value,
};

Map<String, String> _shortNamesByStatName = {
  FlatMagicPenetrationMod: 'Magic Pen',
  FlatSpellBlockMod: 'MR',
  FlatArmorMod: 'Armor',
  FlatMagicDamageMod: 'AP',
};

String shortStringForStatValue(String statName, double statValue) {
  String shortName = _shortNamesByStatName[statName];
  String valueString = statValue.toStringAsFixed(1);
  if (shortName == null) return '$statName : $valueString';
  if (statValue > 0) return '+$valueString $shortName';
  return '$valueString $shortName';
}

class Stats {
  double baseHp;
  double bonusHp = 0.0;
  double mp;
  double baseAttackDamage;
  double bonusAttackDamage = 0.0;
  double abilityPower = 0.0;

  double baseHpRegen;
  double baseMpRegen;
  double flatHpRegenMod = 0.0;
  double flatMpRegenMod = 0.0;
  double percentBaseHpRegenMod = 1.0;
  double percentBaseMpRegenMod = 1.0;

  double _baseArmor; // Before reductions.
  double _bonusArmor = 0.0; // incoming armor changes.
  double flatArmorReduction = 0.0; // incoming armor changes.
  double percentArmorMod = 1.0; // incoming armor changes.

  double lethality = 0.0; // outgoing armor changes.
  double percentArmorPenetration = 1.0; // outgoing armor changes.
  double percentBonusArmorPenetration = 1.0; // outgoing armor changes.

  double _baseSpellBlock; // aka magic resist, before reductions.
  double flatSpellBlockMod = 0.0; // incoming mr changes.
  double percentSpellBlockMod = 1.0; // incoming mr changes.

  double flatMagicPenetration = 0.0; // outgoing mr changes.
  double percentMagicPenetration = 1.0; // outgoing mr changes.

  double lifesteal = 0.0; // 0-100
  // FIXME: Implement 40% cooldown cap!
  double percentCooldownMod = 0.0;
  double critChance = 0.0;
  double critDamageMultiplier = 2.0;
  int range;

  // Used to compute attack speed:
  double attackDelay;
  double percentAttackSpeedMod = 0.0;

  // For testing:
  Stats({
    this.baseHp,
    this.mp,
    this.baseAttackDamage,
    this.attackDelay,
    double baseArmor,
    double baseSpellBlock,
    this.baseHpRegen,
    this.baseMpRegen,
  })
      : _baseArmor = baseArmor,
        _baseSpellBlock = baseSpellBlock;

  double flatArmorPenetrationForTargetWithLevel(int targetLevel) =>
      lethality * letalityToFlatPenatration(targetLevel);

  String debugString() {
    return """
    hp: ${maxHp.toStringAsFixed(1)}
    ad: ${attackDamage.toStringAsFixed(1)}
    ap: ${abilityPower.toStringAsFixed(1)}
    ar: ${armor.toStringAsFixed(1)}
    mr: ${spellBlock.toStringAsFixed(1)}
    as: ${attackSpeed.toStringAsFixed(3)}
    """;
  }

  // http://leagueoflegends.wikia.com/wiki/Attack_delay
  double get baseAttackSpeed => 0.625 / (1.0 + attackDelay);
  // http://leagueoflegends.wikia.com/wiki/Attack_speed
  double get attackSpeed => baseAttackSpeed * (1.0 + percentAttackSpeedMod);
  double get displayBonusAttackSpeed => baseAttackSpeed * percentAttackSpeedMod;
  double get attackDuration => 1.0 / attackSpeed;

  double get attackDamage => baseAttackDamage + bonusAttackDamage;

  double get maxHp => baseHp + bonusHp;

  double get hpRegen => baseHpRegen * percentBaseHpRegenMod + flatHpRegenMod;
  double get mpRegen => baseMpRegen * percentBaseMpRegenMod + flatMpRegenMod;

  double get magicalEffectiveHealth => maxHp * (1 + 0.01 * spellBlock);
  double get physicalEffectiveHealth => maxHp * (1 + 0.01 * armor);

  void addBonusArmor(double newArmor) {
    assert(newArmor > 0);
    _bonusArmor += newArmor;
  }

  double get _bonusArmorReductionRatio {
    if (_baseArmor <= 0) return 1.0;
    if (_bonusArmor < 0) return 0.0;
    double totalArmor = _baseArmor + _bonusArmor;
    assert(totalArmor > 0);
    return _bonusArmor / totalArmor;
  }

  double get _bonusArmorFlatReduction =>
      _bonusArmorReductionRatio * flatArmorReduction;
  double get _baseArmorFlatReduction =>
      (1.0 - _bonusArmorReductionRatio) * flatArmorReduction;

  double get bonusArmor {
    double afterReduction = _bonusArmor - _bonusArmorFlatReduction;
    if (afterReduction < 0) return afterReduction;
    return afterReduction * percentArmorMod;
  }

  double get baseArmor {
    double afterReduction = _baseArmor - _baseArmorFlatReduction;
    if (afterReduction < 0) return afterReduction;
    return afterReduction * percentArmorMod;
  }

  double get spellBlock {
    double afterReduction = _baseSpellBlock + flatSpellBlockMod;
    if (afterReduction < 0) return afterReduction;
    return afterReduction * percentSpellBlockMod;
  }

  double get armor => baseArmor + bonusArmor;

  static final Set _warnedStats = new Set();
  void warnUnhandledStat(String statName) {
    if (!_warnedStats.contains(statName)) {
      _log.warning("Stat: $statName missing apply rule.");
    }
    _warnedStats.add(statName);
  }

  void applyStatMap(Map<String, num> stats) {
    for (String statName in stats.keys) {
      StatApplier statApplier = _statAppliersByName[statName];
      if (statApplier == null)
        warnUnhandledStat(statName);
      else
        statApplier(this, stats[statName]);
    }
  }
}

class BaseStats extends Stats {
  BaseStats.fromJSON(json)
      : spellBlockPerLevel = json['spellblockperlevel'].toDouble(),
        armorPerLevel = json['armorperlevel'].toDouble(),
        hpPerLevel = json['hpperlevel'].toDouble(),
        mpPerLevel = json['mpperlevel'].toDouble(),
        attackSpeedPerLevel = json['attackspeedperlevel'].toDouble() / 100.0,
        attackDamagePerLevel = json['attackdamageperlevel'].toDouble(),
        hpRegenPerLevel = json['hpregenperlevel'].toDouble(),
        mpRegenPerLevel = json['mpregenperlevel'].toDouble() {
    attackDelay = json['attackspeedoffset'].toDouble();
    baseAttackDamage = json['attackdamage'].toDouble();
    baseHp = json['hp'].toDouble();
    mp = json['mp'].toDouble();
    _baseArmor = json['armor'].toDouble();
    _baseSpellBlock = json['spellblock'].toDouble();
    baseHpRegen = json['hpregen'].toDouble();
    baseMpRegen = json['mpregen'].toDouble();
    range = json['attackrange'].toInt();
  }

  // For testing
  BaseStats({
    @required double baseHp,
    double mp,
    double baseAttackDamage,
    double attackDelay,
    double baseHpRegen,
    double baseMpRegen,
    double baseArmor,
    double baseSpellBlock,
    this.armorPerLevel,
    this.attackDamagePerLevel,
    this.attackSpeedPerLevel,
    this.hpPerLevel,
    this.hpRegenPerLevel,
    this.mpPerLevel,
    this.mpRegenPerLevel,
    this.spellBlockPerLevel,
  })
      : super(
          baseHp: baseHp,
          mp: mp,
          baseAttackDamage: baseAttackDamage,
          baseHpRegen: baseHpRegen,
          baseMpRegen: baseMpRegen,
          attackDelay: attackDelay,
          baseArmor: baseArmor,
          baseSpellBlock: baseSpellBlock,
        );

  final double hpPerLevel;
  final double mpPerLevel;
  final double armorPerLevel;
  final double spellBlockPerLevel;
  final double attackSpeedPerLevel;
  final double attackDamagePerLevel;
  final double hpRegenPerLevel;
  final double mpRegenPerLevel;

  Stats _statsForLevel(
      int level, double _curveWithoutBase(double perLevel, int level)) {
    Stats stats = new Stats();

    double _curve(double base, double perLevel, int level) {
      return base + _curveWithoutBase(perLevel, level);
    }

    // Every stat must be listed here or it will be its initial value.
    stats.baseHp = _curve(baseHp, hpPerLevel, level);
    stats.mp = _curve(mp, mpPerLevel, level);
    stats.baseHpRegen = _curve(baseHpRegen, hpRegenPerLevel, level);
    stats.baseMpRegen = _curve(baseMpRegen, mpRegenPerLevel, level);
    stats.baseAttackDamage =
        _curve(baseAttackDamage, attackDamagePerLevel, level);
    stats._baseArmor = _curve(_baseArmor, armorPerLevel, level);
    stats._baseSpellBlock = _curve(_baseSpellBlock, spellBlockPerLevel, level);
    stats.attackDelay = attackDelay;
    stats.percentAttackSpeedMod = _curveWithoutBase(attackSpeedPerLevel, level);

    stats.range = range;
    return stats;
  }

  Stats championCurvedStatsForLevel(int level) {
    // http://leagueoflegends.wikia.com/wiki/Champion_statistic#Growth_statistic_per_level
    return _statsForLevel(level, (double perLevel, int level) {
      // perLevel is applied at level-1 to match dragon data values.
      return perLevel * (level - 1) * (0.685 + 0.0175 * level);
    });
  }

  Stats linearStatsForLevel(int level) {
    return _statsForLevel(level, (double perLevel, int level) {
      // Unlike champion curves perLevel is added in level 1.
      return perLevel * level;
    });
  }

  double _monsterHPScaleForLevel(int level) {
    if (level < 3) return 1.0;
    if (level < 5) return 1.125;
    if (level < 7) return 1.25;
    if (level < 8) return 1.4;
    if (level < 9) return 1.5;
    if (level < 11) return 1.6;
    return 1.75;
  }

  Stats monsterCurvedStatsForLevel(int level) {
    Stats stats = new Stats();

    // Every stat must be listed here or it will be its initial value.
    stats.baseHp = baseHp * _monsterHPScaleForLevel(level);
    stats.mp = mp;
    stats.baseHpRegen = 0.0;
    stats.baseMpRegen = 0.0;
    stats.baseAttackDamage = baseAttackDamage; // FIXME: Wrong.
    stats._baseArmor = _baseArmor; // FIXME: Wrong.
    stats._baseSpellBlock = _baseSpellBlock; // FIXME: Wrong.
    stats.attackDelay = attackDelay;
    stats.percentAttackSpeedMod = 0.0;

    stats.range = range;
    return stats;
  }
}
