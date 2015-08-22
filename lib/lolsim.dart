import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:logging/logging.dart';

final Logger log = new Logger('LOL');

// No clue how often LOL ticks.
const int TICKS_PER_SECOND = 30;

// Create Mob objects for each champion
// Have a loop where 2 mobs can fight.
// Permute over all mobs.
// cooldowns are modeled using effects?
// all actions apply at the end of a frame?

class Stats {
  double hp;
  double attackDamage;
  double abilityPower = 0.0;
  double armor;
  double spellBlock; // aka magic resist.

  // Used to compute attack speed:
  double attackDelay;
  double bonusAttackSpeed = 0.0;

  String debugString() {
    return """
    hp: $hp
    ad: $attackDamage
    ap: $abilityPower
    ar: $armor
    mr: $spellBlock
    as: $attackSpeed
    """;
  }

  // http://leagueoflegends.wikia.com/wiki/Attack_delay
  double get baseAttackSpeed => 0.625 / (1.0 + attackDelay);
  // http://leagueoflegends.wikia.com/wiki/Attack_speed
  double get attackSpeed => baseAttackSpeed * (1.0 + bonusAttackSpeed);
  double get attackDuration => 1.0 / attackSpeed;
}

class BaseStats extends Stats {
  BaseStats.fromJSON(json) {
    attackDelay = json['attackspeedoffset'].toDouble();
    attackDamage = json['attackdamage'].toDouble();
    hp = json['hp'].toDouble();
    armor = json['armor'].toDouble();
    spellBlock = json['spellblock'].toDouble();

    spellBlockPerLevel = json['spellblockperlevel'].toDouble();
    armorPerLevel = json['armorperlevel'].toDouble();
    hpPerLevel = json['hpperlevel'].toDouble();
    mpPerLevel = json['mpperlevel'].toDouble();
    attackSpeedPerLevel = json['attackspeedperlevel'].toDouble() / 100.0;
    attackDamagePerLevel = json['attackdamageperlevel'].toDouble();
  }

  double hpPerLevel;
  double mpPerLevel;
  double armorPerLevel;
  double spellBlockPerLevel;
  double attackSpeedPerLevel;
  double attackDamagePerLevel;

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

class Item {
  Item.fromJSON(var json) {

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

class AutoAttackCooldown extends Buff {
  AutoAttackCooldown(Mob target, double duration) : super(target, duration) {
    log.fine("${target.name} aa cooldown for ${duration.toStringAsFixed(3)}s");
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
}

class AutoAttack extends Action {
  Mob source;

  AutoAttack(this.source, Mob target) : super(target);

  void apply(World world) {
    world.buffs.add(new AutoAttackCooldown(source, source.stats.attackDuration));
    log.fine("${world.time.toStringAsFixed(2)}s: ${source.name} attacks for ${source.stats.attackDamage} damage");
    target.applyHit(new Hit(attackDamage: source.stats.attackDamage));
  }
}

class Hit {
  Hit({this.attackDamage : 0.0, this.magicDamage : 0.0, this.trueDamage : 0.0});

  double attackDamage = 0.0;
  double magicDamage = 0.0;
  double trueDamage = 0.0;
}

enum Team {
  red,
  blue,
}

class Mob {
  Team team;
  String name;
  Mob lastTarget;
  List<Item> items;
  final BaseStats baseStats;
  Stats stats; // updated per-tick.
  int level = 1;
  double hpLost = 0.0;
  bool canAttack = true;
  bool alive = true;

  double get currentHp => max(0.0, stats.hp - hpLost);

  Mob.fromJSON(var json)
    : baseStats = new BaseStats.fromJSON(json['stats'])
  {
    stats = computeStats();
    name = json['name'];
    revive();
  }

  Stats computeStats() {
    return baseStats.statsForLevel(level);
  }

  String toString() {
    return "$name (lvl ${level})";
  }

  // Not clear if buffs should be held on the Mob or not.
  List<Action> tick(double timeDelta) {
    stats = computeStats();
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

  void applyHit(Hit hit) {
    double trueDamage = hit.trueDamage;
    trueDamage += hit.attackDamage * resistanceMultiplier(stats.armor);
    trueDamage += hit.magicDamage * resistanceMultiplier(stats.spellBlock);
    hpLost += trueDamage;
    log.fine("$name takes ${trueDamage.toStringAsFixed(3)} true damage, "
      + "${currentHp.toStringAsFixed(3)} of ${stats.hp.toStringAsFixed(3)} remains");
    if (stats.hp <= hpLost) die();
  }

  void revive() {
    alive = true;
    hpLost = 0.0;
    canAttack = true;
  }

  void die() {
    alive = false;
  }
}

class ChampionFactory {
  var _json;

  ChampionFactory.fromChampionJson(String path) {
    String string = new File(path).readAsStringSync();
    _json = JSON.decode(string);
  }

  Mob championByName(String name) {
    var json = _json['data'][name];
    if (json == null) {
      log.severe("No champion matching $name.");
      return null;
    }
    return new Mob.fromJSON(json);
  }
}

class ItemFactory {
  var _json;

  ItemFactory.fromItemJson(String path) {
    String string = new File(path).readAsStringSync();
    _json = JSON.decode(string);
  }

  Item itemByName(String name) {
    return new Item.fromJSON(_json['data'][name]);
  }
}

class World {
  double time = 0.0;
  List<Buff> buffs = [];
  List<Mob> reds = [];
  List<Mob> blues = [];

  List<Mob> get allMobs => []..addAll(reds)..addAll(blues);

  void addMobs(Iterable<Mob> mobs) {
    mobs.forEach((Mob mob) {
      assert(mob.team != null);
      if (mob.team == Team.red) reds.add(mob);
      else blues.add(mob);
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
    List<Action> actions = allMobs
      .map((mob) => mob.tick(timeDelta))
      .reduce((all, actions) {
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
    } while(!condition(this));
  }

  List<Mob> get living {
    return allMobs.where((Mob mob) => mob.alive).toList();
  }
}
