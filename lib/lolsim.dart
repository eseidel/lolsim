import 'dart:math';
import 'package:logging/logging.dart';
import 'items.dart';
import 'mastery_pages.dart';
import 'rune_pages.dart';
import 'masteries.dart';
import 'package:meta/meta.dart';

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

typedef DamageDealtModifier(Hit hit, DamageDealtModifier);
typedef DamageRecievedModifier(Hit hit, DamageRecievedDelta);

abstract class ItemEffects {
  damageRecievedModifier(Hit hit, DamageRecievedDelta delta) {}
}

class Rune {
  final String name;
  final int id;
  final Map<String, num> stats;

  String toString() {
    return "${name}";
  }

  static Set _loggedRuneNames = new Set();
  void logMissingStats() {
    if (_loggedRuneNames.contains(name)) return;
    _loggedRuneNames.add(name);
    log.warning('Rune ${name} has no stats!');
  }

  // FIXME: Should use items['basic'] for defaults.
  Rune.fromJSON({Map<String, dynamic> json, int id})
      : id = id,
        name = json['name'],
        stats = json['stats'] {
    assert(json['rune']['isrune'] == true);
    if (stats.isEmpty) logMissingStats();
  }
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
    if (effects == null && json['effect'] != null) logMissingEffects();
  }

  static Set _loggedEffects = new Set();
  void logMissingEffects() {
    if (_loggedEffects.contains(name)) return;
    _loggedEffects.add(name);
    log.warning('Item ${name} references effects but no effects class found.');
  }
}

enum MasteryTree {
  ferocity,
  cunning,
  resolve,
}

class MasteryDescription {
  final int id;
  final String name;
  final List<String> descriptions;
  final int ranks;

  MasteryTree get tree {
    // HACK: But seems to work and is quick.
    // Could also load the tree definitions from mastery.json.
    assert(id <= 6400);
    if (id >= 6300) return MasteryTree.cunning;
    if (id >= 6200) return MasteryTree.resolve;
    assert(id >= 6100);
    return MasteryTree.ferocity;
  }

  MasteryDescription.fromJSON(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        descriptions = json['description'],
        ranks = json['ranks'] {}
}

class Mastery {
  MasteryDescription description;
  int rank;
  MasteryEffects effects;

  Mastery(this.description, this.rank) {
    assert(rank >= 1);
    assert(rank <= description.ranks);
    MasteryEffectsConstructor effectsConstructor =
        masteryEffectsConstructors[description.name];
    if (effectsConstructor != null) effects = effectsConstructor(rank);
  }

  static Set _loggedEffects = new Set();
  void logMissingEffects() {
    if (effects != null) return;
    if (_loggedEffects.contains(description.name)) return;
    _loggedEffects.add(description.name);
    log.warning('Mastery ${description.name} has no defined effects.');
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
    double damage = target.applyHit(source.createHitForTarget(
      target: target,
      physicalDamage: source.stats.attackDamage,
    ));
    source.lifestealFrom(damage);
  }
}

class Hit {
  Hit({
    this.physicalDamage: 0.0,
    this.magicDamage: 0.0,
    this.trueDamage: 0.0,
    this.source: null,
    this.target: null,
  });

  double physicalDamage = 0.0;
  double magicDamage = 0.0;
  double trueDamage = 0.0;
  Mob source = null;
  Mob target = null;
}

enum Team {
  red,
  blue,
}

String teamToString(Team team) => (team == Team.red) ? 'Red' : 'Blue';

typedef void StatApplier(Stats stats, num statValue);

class DamageRecieved {
  double physicalDamage = 0.0;
  double magicDamage = 0.0;
  double trueDamage = 0.0;
}

// Possibly could share class with DamageRecievedDelta.
class DamageDealtDelta {
  double percentPhysical = 1.0;
  double percentMagical = 1.0;
  double flatPhysical = 0.0;
  double flatMagical = 0.0;
}

class DamageRecievedDelta {
  double percentPhysical = 1.0;
  double percentMagical = 1.0;
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

class DamageEntry {
  double totalDamage = 0.0;
  int count = 0;
}

class DamageLog {
  Map<String, DamageEntry> entries = {};
  void recordDamage(String source, double damage) {
    DamageEntry entry = entries[source] ?? new DamageEntry();
    entry.totalDamage += damage;
    entry.count += 1;
    entries[source] = entry;
  }

  String get summaryString {
    String summary = "";
    entries.forEach((name, entry) => summary +=
        "${entry.totalDamage.toStringAsFixed(1)} damage from $name (${entry.count} instances)\n");
    return summary;
  }
}

enum MobType {
  champion,
  minion,
  monster,
}

class Mob {
  Team team;
  String name;
  String title;
  String id;
  Mob lastTarget;
  List<Item> items;
  MasteryPage _masteryPage;
  RunePage _runePage;
  final BaseStats baseStats;
  Stats stats; // updated per-tick.
  int level = 1;
  double hpLost = 0.0;
  bool canAttack = true;
  bool alive = true;
  MobType type;
  DamageLog damageLog = null;

  double get currentHp => max(0.0, stats.hp - hpLost);
  double get healthPercent => currentHp / stats.hp;

  bool get shouldRecordDamage => damageLog != null;
  void set shouldRecordDamage(bool flag) {
    if (flag == shouldRecordDamage) return;
    if (flag)
      damageLog = new DamageLog();
    else
      damageLog = null;
  }

  MasteryPage get masteryPage => _masteryPage;
  void set masteryPage(MasteryPage newPage) {
    _masteryPage = newPage;
    _masteryPage.logMissingEffects();
    updateStats();
  }

  RunePage get runePage => _runePage;
  void set runePage(RunePage newPage) {
    _runePage = newPage;
    _runePage.logMissingStats();
    updateStats();
  }

  String statsSummary() {
    String summary = """  $name (lvl ${level})
    HP : ${currentHp} / ${stats.hp}
    AD : ${stats.attackDamage.round()}  AP : ${stats.abilityPower.round()}
    AR : ${stats.armor.round()}  MR : ${stats.spellBlock.round()}
    AS : ${stats.attackSpeed.toStringAsFixed(3)}\n""";
    if (runePage != null) summary += '    Runes: ${runePage}\n';
    if (masteryPage != null) summary += '    Masteries: ${masteryPage}\n';
    if (items.isNotEmpty) summary += '    Items: ${items}\n';
    return summary;
  }

  static Mob createMinion(MinionType type) {
    switch (type) {
      case MinionType.melee:
        return new Mob.fromJSON(_meleeMinionJson, MobType.minion);
      case MinionType.caster:
        return new Mob.fromJSON(_rangedMinionJson, MobType.minion);
      case MinionType.siege:
        return new Mob.fromJSON(_siegeMinionJson, MobType.minion);
      case MinionType.superMinion:
        return new Mob.fromJSON(_superMinionJson, MobType.minion);
    }
    assert(false);
    return null;
  }

  Mob.fromJSON(Map<String, dynamic> json, MobType type)
      : baseStats = new BaseStats.fromJSON(json['stats']) {
    id = json['id'];
    name = json['name'];
    title = json['title'];
    type = type;
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
    'FlatArmorMod': (computed, statValue) => computed.armor += statValue,
    'FlatHPPoolMod': (computed, statValue) => computed.hp += statValue,
    // 'FlatCritChanceMod': (computed, statValue) => computed.crit += statValue,
    // 'FlatHPRegenMod': (computed, statValue) => computed.hpRegen += statValue,
    'FlatMagicDamageMod': (computed, statValue) =>
        computed.abilityPower += statValue,
    // 'FlatMovementSpeedMod': (computed, statValue) => computed.movespeed += statValue,
    // 'FlatMPPoolMod': (computed, statValue) => computed.mpRegen += statValue,
    'FlatSpellBlockMod': (computed, statValue) =>
        computed.spellBlock += statValue,
    'FlatPhysicalDamageMod': (computed, statValue) =>
        computed.attackDamage += statValue,
    'PercentAttackSpeedMod': (computed, statValue) =>
        computed.bonusAttackSpeed += statValue,
    'PercentLifeStealMod': (computed, statValue) =>
        computed.lifesteal += statValue,
    // 'PercentMovementSpeedMod': (computed, statValue) => computed.movespeed *= statValue,
  };

  void updateStats() {
    stats = computeStats();
  }

  void applyStats(Stats computed, Map<String, num> stats) {
    for (String statName in stats.keys) {
      StatApplier statApplier = appliers[statName];
      if (statApplier == null)
        warnUnhandledStat(statName);
      else
        statApplier(computed, stats[statName]);
    }
  }

  Stats computeStats() {
    Stats computed = baseStats.statsForLevel(level);
    if (runePage != null)
      for (Rune rune in runePage.runes) applyStats(computed, rune.stats);
    if (masteryPage != null) {
      for (Mastery mastery in masteryPage.masteries) {
        if (mastery?.effects?.stats != null) {
          applyStats(computed, mastery.effects.stats);
        }
      }
    }
    for (Item item in items) applyStats(computed, item.stats);
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

  List<DamageDealtModifier> collectDamageDealtModifiers() {
    List<DamageDealtModifier> modifiers = [];
    if (masteryPage != null) {
      for (Mastery mastery in masteryPage.masteries) {
        if (mastery.effects != null)
          modifiers.add(mastery.effects.damageDealtModifier);
      }
    }
    return modifiers;
  }

  DamageDealtDelta computeDamageDealtDelta(Hit hit) {
    List<DamageDealtModifier> modifiers = collectDamageDealtModifiers();
    DamageDealtDelta delta = new DamageDealtDelta();
    modifiers.forEach((modifier) => modifier(hit, delta));
    return delta;
  }

  Hit createHitForTarget(
      {@required Mob target,
      double physicalDamage: 0.0,
      double magicDamage: 0.0,
      double trueDamage: 0.0}) {
    Hit hit = new Hit(
      source: this,
      target: target,
      physicalDamage: physicalDamage,
      magicDamage: magicDamage,
      trueDamage: trueDamage,
    );

    DamageDealtDelta delta = computeDamageDealtDelta(hit);
    // Damage Amplification -- Percentage
    hit.physicalDamage *= delta.percentPhysical;
    hit.magicDamage *= delta.percentMagical;
    // Damage Amplification -- Flat
    // It is not clear if flat amp is before or after precentage, however
    // The few cases I've seen (savagery and gp barrels) appear to be after.
    hit.physicalDamage += delta.flatPhysical;
    hit.magicDamage += delta.flatMagical;
    // Most damage amps appear to explicitly exclude true dmg, including
    // double edged sword, assasin, etc.
    return hit;
  }

  double _resistanceMultiplier(double resistance) {
    if (resistance > 0) return 100 / (100 + resistance);
    return 2 - (100 / (100 - resistance));
  }

  List<DamageRecievedModifier> collectDamageRecievedModifiers() {
    List<DamageRecievedModifier> modifiers = [
      (hit, delta) {
        delta.percentPhysical *= _resistanceMultiplier(stats.armor);
        delta.percentMagical *= _resistanceMultiplier(stats.spellBlock);
      }
    ];
    // Do I need to cache these?
    for (Item item in items) {
      if (item.effects != null)
        modifiers.add(item.effects.damageRecievedModifier);
    }
    if (masteryPage != null) {
      for (Mastery mastery in masteryPage.masteries) {
        if (mastery.effects != null)
          modifiers.add(mastery.effects.damageRecievedModifier);
      }
    }
    return modifiers;
  }

  DamageRecievedDelta computeDamageRecievedDelta(Hit hit) {
    List<DamageRecievedModifier> modifiers = collectDamageRecievedModifiers();
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
    damage.physicalDamage = hit.physicalDamage * delta.percentPhysical;
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

  String get hpStatusString {
    int percent = (healthPercent * 100).round();
    return "$percent% (${currentHp.toStringAsFixed(1)} / ${stats.hp.round()})";
  }

  double applyHit(Hit hit) {
    double damage = computeDamageRecieved(hit);
    hpLost += damage;
    log.fine(
        "$this took ${damage.toStringAsFixed(1)} damage from ${hit.source}, "
        "$hpStatusString remains");
    damageLog?.recordDamage(hit.source.toString(), damage);
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
    log.info("DEATH: $this");
    if (damageLog != null) log.info(damageLog.summaryString);
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
    if (mob.team == Team.red) return livingBlues.first;
    return livingReds.first;
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

  Iterable<Mob> get livingBlues {
    return blues.where((Mob mob) => mob.alive);
  }

  Iterable<Mob> get livingReds {
    return reds.where((Mob mob) => mob.alive);
  }

  Iterable<Mob> get living {
    return allMobs.where((Mob mob) => mob.alive);
  }
}
