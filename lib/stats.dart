import 'package:meta/meta.dart';

double letalityToFlatPenatration(int targetLevel) {
  //  LETHALITY × (0.6 + 0.4 × Target's level ÷ 18)
  return 0.6 + 0.4 * targetLevel / 18.0;
}

class Stats {
  double hp;
  double mp;
  double baseAttackDamage;
  double bonusAttackDamage = 0.0;
  double abilityPower = 0.0;
  double _baseArmor; // Before reductions.
  double _bonusArmor = 0.0; // incoming bonus armor.
  double flatArmorReduction = 0.0;
  double armorPercentMod = 1.0; // incoming armor changes.

  double spellBlock; // aka magic resist.
  double hpRegen;

  double lethality = 0.0; // outgoing armor changes.
  double percentArmorPenetration = 1.0; // outgoing armor changes.
  double percentBonusArmorPenetration = 1.0; // outgoing armor changes.

  double lifesteal = 0.0;
  double critChance = 0.0;
  double critDamageMultiplier = 2.0;
  int range;

  // Used to compute attack speed:
  double attackDelay;
  double bonusAttackSpeed = 0.0;

  // For testing:
  Stats({
    this.hp,
    this.mp,
    this.baseAttackDamage,
    this.attackDelay,
    double baseArmor,
    this.spellBlock,
    this.hpRegen,
  })
      : _baseArmor = baseArmor;

  double flatArmorPenetrationForTargetWithLevel(int level) =>
      lethality * letalityToFlatPenatration(level);

  String debugString() {
    return """
    hp: ${hp.toStringAsFixed(1)}
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
  double get attackSpeed => baseAttackSpeed * (1.0 + bonusAttackSpeed);
  double get attackDuration => 1.0 / attackSpeed;

  double get attackDamage => baseAttackDamage + bonusAttackDamage;

  double get magicalEffectiveHealth => hp * (1 + 0.01 * spellBlock);
  double get physicalEffectiveHealth => hp * (1 + 0.01 * armor);

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
    return afterReduction * armorPercentMod;
  }

  double get baseArmor {
    double afterReduction = _baseArmor - _baseArmorFlatReduction;
    if (afterReduction < 0) return afterReduction;
    return afterReduction * armorPercentMod;
  }

  double get armor => baseArmor + bonusArmor;
}

class BaseStats extends Stats {
  BaseStats.fromJSON(json)
      : spellBlockPerLevel = json['spellblockperlevel'].toDouble(),
        armorPerLevel = json['armorperlevel'].toDouble(),
        hpPerLevel = json['hpperlevel'].toDouble(),
        mpPerLevel = json['mpperlevel'].toDouble(),
        attackSpeedPerLevel = json['attackspeedperlevel'].toDouble() / 100.0,
        attackDamagePerLevel = json['attackdamageperlevel'].toDouble(),
        hpRegenPerLevel = json['hpregenperlevel'].toDouble() {
    attackDelay = json['attackspeedoffset'].toDouble();
    baseAttackDamage = json['attackdamage'].toDouble();
    hp = json['hp'].toDouble();
    mp = json['mp'].toDouble();
    _baseArmor = json['armor'].toDouble();
    spellBlock = json['spellblock'].toDouble();
    hpRegen = json['hpregen'].toDouble();
    range = json['attackrange'].toInt();
  }

  // For testing
  BaseStats({
    @required double hp,
    double mp,
    double baseAttackDamage,
    double attackDelay,
    double hpRegen,
    double baseArmor,
    double spellBlock,
    this.armorPerLevel,
    this.attackDamagePerLevel,
    this.attackSpeedPerLevel,
    this.hpPerLevel,
    this.hpRegenPerLevel,
    this.mpPerLevel,
    this.spellBlockPerLevel,
  })
      : super(
          hp: hp,
          mp: mp,
          baseAttackDamage: baseAttackDamage,
          hpRegen: hpRegen,
          attackDelay: attackDelay,
          baseArmor: baseArmor,
          spellBlock: spellBlock,
        );

  final double hpPerLevel;
  final double mpPerLevel;
  final double armorPerLevel;
  final double spellBlockPerLevel;
  final double attackSpeedPerLevel;
  final double attackDamagePerLevel;
  final double hpRegenPerLevel;

  Stats statsForLevel(int level) {
    Stats stats = new Stats();

    // http://leagueoflegends.wikia.com/wiki/Champion_statistic#Growth_statistic_per_level
    double _curve(double base, double perLevel, int level) {
      return base + perLevel * (level - 1) * (0.685 + 0.0175 * level);
    }

    // Every stat must be listed here or it will be its initial value.
    stats.hp = _curve(hp, hpPerLevel, level);
    stats.mp = _curve(mp, mpPerLevel, level);
    stats.hpRegen = _curve(hpRegen, hpRegenPerLevel, level);
    stats.baseAttackDamage =
        _curve(baseAttackDamage, attackDamagePerLevel, level);
    stats._baseArmor = _curve(armor, armorPerLevel, level);
    stats.spellBlock = _curve(spellBlock, spellBlockPerLevel, level);
    stats.attackDelay = attackDelay;
    stats.bonusAttackSpeed =
        attackSpeedPerLevel * (level - 1) * (0.685 + 0.0175 * level);
    stats.range = range;
    return stats;
  }
}
