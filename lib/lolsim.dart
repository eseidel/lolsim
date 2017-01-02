import 'dart:math';
import 'package:logging/logging.dart';
import 'package:lol_duel/items.dart';

final Logger log = new Logger('LOL');

// No clue how often LOL ticks.
const int TICKS_PER_SECOND = 30;

// Create Mob objects for each champion
// Have a loop where 2 mobs can fight.
// Permute over all mobs.
// cooldowns are modeled using effects?
// all actions apply at the end of a frame?

double attackDelayFromBaseAttackSpeed(double baseAttackSpeed) {
  return (0.625 / baseAttackSpeed) - 1.0;
}

class Stats {
  double hp;
  double attackDamage;
  double abilityPower = 0.0;
  double armor;
  double spellBlock; // aka magic resist.

  double lifesteal = 0.0;

  // Used to compute attack speed:
  double attackDelay;
  double bonusAttackSpeed = 0.0;

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
        attackDamagePerLevel = json['attackdamageperlevel'].toDouble() {
    attackDelay = json['attackspeedoffset'].toDouble();
    attackDamage = json['attackdamage'].toDouble();
    hp = json['hp'].toDouble();
    armor = json['armor'].toDouble();
    spellBlock = json['spellblock'].toDouble();
  }

  final double hpPerLevel;
  final double mpPerLevel;
  final double armorPerLevel;
  final double spellBlockPerLevel;
  final double attackSpeedPerLevel;
  final double attackDamagePerLevel;

  Stats statsForLevel(int level) {
    Stats stats = new Stats();
    int multiplier = level - 1; // level is 1-based.
    stats.hp = hp + hpPerLevel * multiplier;
    stats.attackDamage = attackDamage + attackDamagePerLevel * multiplier;
    stats.armor = armor + armorPerLevel * multiplier;
    stats.spellBlock = spellBlock + spellBlockPerLevel * multiplier;
    stats.attackDelay = attackDelay;
    stats.bonusAttackSpeed = attackSpeedPerLevel * multiplier;
    return stats;
  }
}

class Maps {
  static String CURRENT_TWISTED_TREELINE = "10";
  static String CURRENT_SUMMONERS_RIFT = "11";
  static String CURRENT_HOWLING_ABYSS = "12";
}

typedef DamageRecievedModifier(Hit, DamageRecievedDelta);

abstract class ItemEffects {
  damageRecievedModifier(Hit hit, DamageRecievedDelta delta) {}
}

class Item {
  final String name;
  final String id;
  final Map<String, bool> maps;
  final Map<String, num> stats;
  final Map<String, dynamic> gold;
  final List<String> tags;
  final String requiredChampion;
  final bool inStore;
  final bool hideFromAll; // true for jungle enchants?
  ItemEffects effects;

  bool isAvailableOn(String mapId) {
    return maps[mapId] == true;
  }

  bool get purchasable {
    return gold['purchasable'] == true;
  }

  bool get generallyAvailable {
    return gold['base'] > 0 && inStore != false && requiredChampion == null;
  }

  String toString() {
    return "${name} (${gold['total']}g)";
  }

  // FIXME: Should use items['basic'] for defaults.
  Item.fromJSON({Map<String, dynamic> json, String id})
      : id = id,
        name = json['name'],
        maps = json['maps'],
        tags = json['tags'],
        gold = json['gold'],
        requiredChampion = json['requiredChampion'],
        inStore = json['in'],
        hideFromAll = json['hideFromAll'],
        stats = json['stats'] {
    effects = itemEffects[name];
  }
}

abstract class PeriodicGlobalEffect {
  double period;

  bool tick(double timeDelta);
  void apply();
}

abstract class Buff {
  Buff(this.target, this.remaining);
  // Fixed at time of creation in LOL. CDR does not affect in-progress cooldowns:
  // http://leagueoflegends.wikia.com/wiki/Cooldown_reduction
  double remaining;
  Mob target;
  bool get expired => remaining <= 0.0;

  void tick(double timeDelta) {
    remaining -= timeDelta;
    if (expired) didExpire();
  }

  void didExpire() {}
}

// FIXME: How would AA-resets work with this?  Find the buff and clear it?
// Probably buffs should just be re-applied every tick?
class AutoAttackCooldown extends Buff {
  AutoAttackCooldown(Mob target, double duration) : super(target, duration) {
    // log.fine("${target} aa cooldown for ${duration.toStringAsFixed(1)}s");
    target.canAttack = false;
  }
  void didExpire() {
    // This is error-prone.
    target.canAttack = true;
  }
}

abstract class Action {
  Action(this.target);
  Mob target;
  void apply(World world);
  // on attack effects
  // damage dealt modifier (including crit)
  // percent damage recieved modifier (including ar/mr)
  // flat damage reduction
  // damage prevention (immunity)
  // on-hit effects
  // lifesteal
}

class AutoAttack extends Action {
  Mob source;

  AutoAttack(this.source, Mob target) : super(target);

  void apply(World world) {
    world.buffs
        .add(new AutoAttackCooldown(source, source.stats.attackDuration));
    log.fine(
        "${world.logTime}: ${source} attacks ${target} for ${source.stats.attackDamage.toStringAsFixed(1)} damage");
    double damage = target.applyHit(new Hit(
      attackDamage: source.stats.attackDamage,
      source: source,
    ));
    source.lifestealFrom(damage);
  }
}

class Hit {
  Hit({
    this.attackDamage: 0.0,
    this.magicDamage: 0.0,
    this.trueDamage: 0.0,
    this.source: null,
  });

  double attackDamage = 0.0;
  double magicDamage = 0.0;
  double trueDamage = 0.0;
  Mob source = null;
}

enum Team {
  red,
  blue,
}

String teamToString(Team team) => (team == Team.red) ? 'Red' : 'Blue';

typedef void StatApplier(Stats stats, Item item, String name);

class DamageRecieved {
  double physicalDamage = 0.0;
  double magicDamage = 0.0;
  double trueDamage = 0.0;
}

class DamageRecievedDelta {
  double percentPhysical = 0.0;
  double percentMagical = 0.0;
  double flatPhysical = 0.0;
  double flatMagical = 0.0;
  double flatCombined = 0.0;
}

final Map<String, double> _sharedMinionStats = {
  'spellblockperlevel': 0.0,
  'armorperlevel': 0.0,
  'mpperlevel': 0.0,
  'movespeed': 325.0,
  'attackspeedperlevel': 0.0,
  'armor': 0.0,
  'spellblock': 0.0,
};

final Map<String, dynamic> _meleeMinionJson = {
  'name': 'Melee Minion',
  'stats': new Map.from(_sharedMinionStats)
    ..addAll(<String, double>{
      'hp': 455.0,
      'hpperlevel': 18.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(1.25),
      'attackdamage': 12.0,
      'attackdamageperlevel': 0.0,
      'attackrange': 110.0,
    }),
};

final Map<String, dynamic> _rangedMinionJson = {
  'name': 'Ranged Minion',
  'stats': new Map.from(_sharedMinionStats)
    ..addAll(<String, double>{
      'hp': 290.0,
      'hpperlevel': 6.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(0.667),
      'attackdamage': 22.5,
      'attackdamageperlevel': 1.5,
      'attackrange': 550.0,
    }),
};

final Map<String, dynamic> _siegeMinionJson = {
  'name': 'Siege Minion',
  'stats': new Map.from(_sharedMinionStats)
    ..addAll(<String, double>{
      'hp': 805.0,
      'hpperlevel': 0.0, // FIXME: This is likely wrong, missing from wiki.
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(1.0),
      'attackdamage': 39.5,
      'attackdamageperlevel': 1.5,
      'attackrange': 300.0,
    }),
};

final Map<String, dynamic> _superMinionJson = {
  'name': 'Siege Minion',
  'stats': new Map.from(_sharedMinionStats)
    ..addAll(<String, double>{
      'hp': 1500.0,
      'hpperlevel': 200.0,
      'attackspeedoffset': attackDelayFromBaseAttackSpeed(0.694),
      'attackdamage': 190.0,
      'attackdamageperlevel': 10.0,
      'attackrange': 170.0,
      'armor': 30.0,
      'spellblock': -30.0,
    }),
};

enum MinionType { melee, caster, siege, superMinion }

class Mob {
  Team team;
  String name;
  String title;
  String id;
  Mob lastTarget;
  List<Item> items;
  final BaseStats baseStats;
  Stats stats; // updated per-tick.
  int level = 1;
  double hpLost = 0.0;
  bool canAttack = true;
  bool alive = true;
  bool isChampion = false;

  double get currentHp => max(0.0, stats.hp - hpLost);

  String statsSummary() {
    String summary = """  $name (lvl ${level})
    HP : ${currentHp} / ${stats.hp}
    AD : ${stats.attackDamage.round()}  AP : ${stats.abilityPower.round()}
    AR : ${stats.armor.round()}  MR : ${stats.spellBlock.round()}
    AS : ${stats.attackSpeed.toStringAsFixed(3)}
    """;
    if (items.isNotEmpty) summary += 'Items: ${items}\n';
    return summary;
  }

  static Mob createMinion(MinionType type) {
    switch (type) {
      case MinionType.melee:
        return new Mob.fromJSON(_meleeMinionJson);
      case MinionType.caster:
        return new Mob.fromJSON(_rangedMinionJson);
      case MinionType.siege:
        return new Mob.fromJSON(_siegeMinionJson);
      case MinionType.superMinion:
        return new Mob.fromJSON(_superMinionJson);
    }
    assert(false);
    return null;
  }

  Mob.fromJSON(Map<String, dynamic> json, {this.isChampion: false})
      : baseStats = new BaseStats.fromJSON(json['stats']) {
    id = json['id'];
    name = json['name'];
    title = json['title'];
    items = [];
    updateStats();
    revive();
  }

  static Set _warnedStats = new Set();
  void warnUnhandledStat(String statName) {
    if (!_warnedStats.contains(statName)) {
      print("Unhandled: $statName");
    }
    _warnedStats.add(statName);
  }

  // FIXME: There is probably a better way to do this where we combine all the
  // stat modifications together in json form and then collapse them all at the end instead.
  // FIXME: These are neither complete, nor necessarily correct.
  final Map<String, StatApplier> appliers = {
    'FlatArmorMod': (computed, item, statName) =>
        computed.armor += item.stats[statName],
    'FlatHPPoolMod': (computed, item, statName) =>
        computed.hp += item.stats[statName],
    // 'FlatCritChanceMod': (computed, item, statName) => computed.crit += item.stats[statName],
    // 'FlatHPRegenMod': (computed, item, statName) => computed.hpRegen += item.stats[statName],
    'FlatMagicDamageMod': (computed, item, statName) =>
        computed.abilityPower += item.stats[statName],
    // 'FlatMovementSpeedMod': (computed, item, statName) => computed.movespeed += item.stats[statName],
    // 'FlatMPPoolMod': (computed, item, statName) => computed.mpRegen += item.stats[statName],
    'FlatSpellBlockMod': (computed, item, statName) =>
        computed.spellBlock += item.stats[statName],
    'FlatPhysicalDamageMod': (computed, item, statName) =>
        computed.attackDamage += item.stats[statName],
    // 'PercentAttackSpeedMod': (computed, item, statName) => computed.bonusAttackSpeed *= item.stats[statName],
    'PercentLifeStealMod': (computed, item, statName) =>
        computed.lifesteal += item.stats[statName],
    // 'PercentMovementSpeedMod': (computed, item, statName) => computed.movespeed *= item.stats[statName],
  };

  void updateStats() {
    stats = computeStats();
  }

  Stats computeStats() {
    Stats computed = baseStats.statsForLevel(level);
    for (Item item in items) {
      for (String statName in item.stats.keys) {
        StatApplier statApplier = appliers[statName];
        if (statApplier == null)
          warnUnhandledStat(statName);
        else
          statApplier(computed, item, statName);
      }
    }
    return computed;
  }

  String toString() {
    String teamString = (team != null) ? "${teamToString(team)} " : "";
    return "$teamString$name";
  }

  void addItem(Item item) {
    items.add(item);
    updateStats();
  }

  // Not clear if buffs should be held on the Mob or not.
  List<Action> tick(double timeDelta) {
    updateStats();
    List<Action> actions = [];
    if (!alive) return actions;
    if (canAttack && lastTarget != null) {
      actions.add(new AutoAttack(this, lastTarget));
    }
    return actions;
  }

  double resistanceMultiplier(double resistance) {
    if (resistance > 0) return 100 / (100 + resistance);
    return 2 - (100 / (100 - resistance));
  }

  List<DamageRecievedModifier> collectDamageModifiers() {
    List<DamageRecievedModifier> modifiers = [
      (hit, delta) {
        delta.percentPhysical = resistanceMultiplier(stats.armor);
        delta.percentMagical = resistanceMultiplier(stats.spellBlock);
      }
    ];
    // Do I need to cache these?
    for (Item item in items) {
      if (item.effects != null)
        modifiers.add(item.effects.damageRecievedModifier);
    }
    return modifiers;
  }

  DamageRecievedDelta computeDamageRecievedDelta(Hit hit) {
    List<DamageRecievedModifier> modifiers = collectDamageModifiers();
    DamageRecievedDelta delta = new DamageRecievedDelta();
    modifiers.forEach((modifier) => modifier(hit, delta));
    return delta;
  }

  // PHASE: Damage Recieved
  double computeDamageRecieved(Hit hit) {
    DamageRecievedDelta delta = computeDamageRecievedDelta(hit);

    // Apply them all, first percentage, then flat.
    DamageRecieved damage = new DamageRecieved();
    damage.trueDamage = hit.trueDamage;
    // Damage Reduction -- Percentage
    damage.physicalDamage = hit.attackDamage * delta.percentPhysical;
    damage.magicDamage = hit.magicDamage * delta.percentMagical;
    // Damage Reduction -- Flat
    damage.physicalDamage += delta.flatPhysical;
    damage.magicDamage += delta.flatMagical;
    // Unclear if this is the right place to handle combined adjustments
    // or if the individual items should self-adjust.
    double combinedDamage = damage.physicalDamage + damage.magicDamage;
    combinedDamage += delta.flatCombined;
    return damage.trueDamage + max(0, combinedDamage);
  }

  double applyHit(Hit hit) {
    double damage = computeDamageRecieved(hit);
    hpLost += damage;
    int percent = (currentHp / stats.hp * 100).round();
    log.fine("$name took ${damage.toStringAsFixed(1)} damage, "
        "$percent% (${currentHp.round()} / ${stats.hp.round()}) remains");
    if (stats.hp <= hpLost) die();
    return damage; // This could be beyond-fatal damage.
  }

  void lifestealFrom(double damage) {
    healFor(damage * stats.lifesteal);
  }

  void healFor(double healing) {
    // FIXME: Missing healing modifiers.
    hpLost -= min(hpLost, healing);
  }

  void revive() {
    alive = true;
    hpLost = 0.0;
    canAttack = true;
  }

  void die() {
    // FIXME: Death could be a buff if there are rez timers.
    alive = false;
  }
}

class World {
  double time = 0.0;
  List<Buff> buffs = [];
  List<Mob> reds = [];
  List<Mob> blues = [];

  List<Mob> get allMobs => []..addAll(reds)..addAll(blues);

  String get logTime => "${time.toStringAsFixed(2)}s";

  void addMobs(Iterable<Mob> mobs) {
    mobs.forEach((Mob mob) {
      assert(mob.team != null);
      if (mob.team == Team.red)
        reds.add(mob);
      else
        blues.add(mob);
    });
  }

  static void clearDeadTargets(Iterable<Mob> mobs) {
    mobs.forEach((Mob mob) {
      if (mob.lastTarget == null) return;
      if (mob.lastTarget.alive) return;
      mob.lastTarget = null;
    });
  }

  Mob closestTarget(Mob mob) {
    if (mob.team == Team.red) return blues.first;
    return reds.first;
  }

  void updateTargets() {
    // Unclear if clear should happen as a part of death or not?
    clearDeadTargets(allMobs);
    allMobs.forEach((mob) {
      if (mob.lastTarget != null) return;
      mob.lastTarget = closestTarget(mob);
    });
  }

  void tick() {
    const double timeDelta = 1 / TICKS_PER_SECOND;
    time += timeDelta;
    updateTargets();
    List<Action> actions =
        allMobs.map((mob) => mob.tick(timeDelta)).reduce((all, actions) {
      all.addAll(actions);
      return all;
    });
    // Might need to sort actions?
    buffs.forEach((buff) => buff.tick(timeDelta));
    buffs = buffs.where((buff) => !buff.expired).toList();
    actions.forEach((action) => action.apply(this));
  }

  void tickUntil(bool condition(World)) {
    do {
      tick();
    } while (!condition(this));
  }

  List<Mob> get living {
    return allMobs.where((Mob mob) => mob.alive).toList();
  }
}
