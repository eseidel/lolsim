import 'package:meta/meta.dart';

class Stats {
  double hp;
  double mp;
  double baseAttackDamage;
  double bonusAttackDamage = 0.0;
  double abilityPower = 0.0;
  double armor;
  double spellBlock; // aka magic resist.
  double hpRegen;

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
    this.armor,
    this.spellBlock,
    this.hpRegen,
  });

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
    armor = json['armor'].toDouble();
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
    double armor,
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
          armor: armor,
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
    stats.armor = _curve(armor, armorPerLevel, level);
    stats.spellBlock = _curve(spellBlock, spellBlockPerLevel, level);
    stats.attackDelay = attackDelay;
    stats.bonusAttackSpeed =
        attackSpeedPerLevel * (level - 1) * (0.685 + 0.0175 * level);
    stats.range = range;
    return stats;
  }
}
