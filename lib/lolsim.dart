import 'dart:math';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'buffs.dart';
import 'champions/all.dart';
import 'dragon/dragon.dart';
import 'dragon/spellkey.dart';
import 'dragon/stats.dart';
import 'effects.dart';
import 'items.dart';
import 'masteries.dart';
import 'mastery_pages.dart';
import 'planning.dart';
import 'rune_pages.dart';

export 'dragon/spellkey.dart';
export 'dragon/stats.dart';

final Logger _log = new Logger('lolsim');

// Supposedly the internal server tick rate is 30fps:
// https://www.reddit.com/r/leagueoflegends/comments/2mmlkr/0001_second_kill_on_talon_even_faster_kill_out/cm5tizu/
const int TICKS_PER_SECOND = 30;
const double SECONDS_PER_TICK = 1 / TICKS_PER_SECOND;

typedef void OnHitCallback(Hit target);
typedef void DamageDealtModifier(Hit hit, DamageDealtModifier);
typedef void DamageRecievedModifier(Hit hit, DamageRecievedDelta);

class Rune {
  RuneDescription description;

  Rune(this.description) {
    logIfMissingStats();
  }

  String get name => description.name;
  String get statName => description.statName;
  double get statValue => description.statValue;

  @override
  String toString() => name;

  static final Set _loggedRuneNames = new Set();
  void logIfMissingStats() {
    if (description.statName != null) return;
    if (_loggedRuneNames.contains(name)) return;
    _loggedRuneNames.add(name);
    _log.warning('Rune ${name} has no stats!');
  }
}

class Item {
  final Mob owner;
  final ItemDescription description;
  BuffEffects effects;

  Item(this.owner, this.description) {
    effects = constructEffectsForItem(name);
    if (effects == null && description.hasEffects) logMissingEffects();
  }

  String get name => description.name;
  Map<String, num> get stats => description.stats;

  @override
  String toString() => '${name} (${description.gold['total']}g)';

  static final Set _loggedEffects = new Set();
  void logMissingEffects() {
    // Note this one does not check if missing, unlike Rune or Mastery's version.
    if (_loggedEffects.contains(name)) return;
    _loggedEffects.add(name);
    _log.fine('Item ${name} references effects but no effects class found.');
  }
}

class Mastery {
  final MasteryDescription description;
  final int rank;
  MasteryEffects effects;

  Mastery(this.description, this.rank) {
    assert(rank >= 1);
    assert(rank <= description.ranks);
  }

  void initForChamp(Mob champ) {
    MasteryEffectsConstructor effectsConstructor =
        masteryEffectsConstructors[description.name];
    if (effectsConstructor != null) effects = effectsConstructor(champ, rank);
  }

  static final Set _loggedEffects = new Set();
  void logIfMissingEffects() {
    if (effects != null) return;
    if (_loggedEffects.contains(description.name)) return;
    _loggedEffects.add(description.name);
    _log.warning('Mastery ${description.name} has no defined effects.');
  }

  @override
  String toString() {
    return '${description.name} rank $rank';
  }
}

// FIXME: Support AA Resets.
class AutoAttackCooldown extends Cooldown {
  AutoAttackCooldown(Mob target, double duration)
      : super(name: 'AutoAttackCooldown', target: target, duration: duration) {
    // _log.fine("${target} aa cooldown for ${duration.toStringAsFixed(1)}s");
  }

  @override
  String get lastUpdate => VERSION_7_2_1;
}

abstract class Action {
  bool ignored; // silence warning
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
  Mob target;

  AutoAttack(this.source, this.target);

  static void applyAuto(
    World world,
    Mob source,
    Mob target,
    double attackDamage, {
    String label: 'AA',
  }) {
    bool isCrit = world.critProvider(source);
    String attackString = isCrit ? 'CRITS' : 'attacks';
    String damageString = attackDamage.toStringAsFixed(1);
    World.combatLog("$source $attackString $target for $damageString damage");
    Hit hit = source.createHitForTarget(
      label: isCrit ? '$label Crit' : label,
      target: target,
      isCrit: isCrit,
      physicalDamage: attackDamage,
      targeting: Targeting.basicAttack,
    );
    source.applyOnAutoAttackHitEffects(hit);
    double appliedDamage = target.applyHit(hit);
    source.lifestealFrom(appliedDamage);
  }

  @override
  void apply(World world) {
    source.buffs
        .add(new AutoAttackCooldown(source, source.stats.attackDuration));
    applyAuto(world, source, target, source.stats.attackDamage, label: 'AA');
  }
}

class Damage {
  String label;
  double physicalDamage;
  double magicDamage;
  double trueDamage;

  Damage({
    this.label: null,
    this.physicalDamage: 0.0,
    this.magicDamage: 0.0,
    this.trueDamage: 0.0,
  });

  double get totalDamage => physicalDamage + magicDamage + trueDamage;

  @override
  String toString() {
    String damageString = totalDamage.toStringAsFixed(1);
    return label != null ? '$damageString ($label)' : '$damageString';
  }
}

enum Targeting {
  singleTargetSpell,
  basicAttack,
  dot,
  aoe,
}

class Hit {
  String label;
  bool isCrit;
  Mob source;
  Mob target;
  Targeting targeting;
  Damage baseDamage;
  List<Damage> onHits = [];

  Hit._({
    this.label: null,
    this.isCrit: false,
    double physicalDamage: 0.0,
    double magicDamage: 0.0,
    double trueDamage: 0.0,
    this.source: null,
    this.target: null,
    this.targeting: Targeting.singleTargetSpell,
  })
      : baseDamage = new Damage(
          label: label,
          physicalDamage: physicalDamage,
          magicDamage: magicDamage,
          trueDamage: trueDamage,
        );

  bool get isAutoAttack => targeting == Targeting.basicAttack;
  bool get isSingleTarget =>
      targeting == Targeting.singleTargetSpell ||
      targeting == Targeting.basicAttack ||
      targeting == Targeting.dot;

  // Unclear if this is correct.
  bool get appliesSpellEffects =>
      targeting == Targeting.singleTargetSpell || targeting == Targeting.aoe;

  double get physicalDamage {
    double totalPhysical = baseDamage.physicalDamage;
    onHits.forEach((onHit) => totalPhysical += onHit.physicalDamage);
    return totalPhysical;
  }

  double get magicDamage {
    double totalMagic = baseDamage.magicDamage;
    onHits.forEach((onHit) => totalMagic += onHit.magicDamage);
    return totalMagic;
  }

  double get trueDamage {
    double totalTrue = baseDamage.trueDamage;
    onHits.forEach((onHit) => totalTrue += onHit.trueDamage);
    return totalTrue;
  }

  // This only applies to baseDamage for now?  Unclear if
  // onHits can have damage-dealt-side amplification?
  // Maybe from Exhaust?
  void applyDamageDealtModifier(DamageDealtDelta delta) {
    // Damage Amplification -- Percentage
    baseDamage.physicalDamage *= delta.percentPhysical;
    baseDamage.magicDamage *= delta.percentMagical;
    // Damage Amplification -- Flat
    // It is not clear if flat amp is before or after precentage, however
    // The few cases I've seen (savagery and gp barrels) appear to be after.
    baseDamage.physicalDamage += delta.flatPhysical;
    baseDamage.magicDamage += delta.flatMagical;
    // Most damage amps appear to explicitly exclude true dmg, including
    // double edged sword, assasin, etc.
  }

  String get sourceString {
    String result = source.toString();
    if (label != null) result += ' ($label)';
    return result;
  }

  String get summaryString {
    String summary = '';
    if (onHits.isNotEmpty)
      summary += ([baseDamage]..addAll(onHits)).toString();
    else
      summary += baseDamage.toString();
    return summary + ' from $source';
  }

  void addOnHitDamage(Damage damage) {
    onHits.add(damage);
  }
}

enum Team {
  red,
  blue,
}

String teamToString(Team team) => (team == Team.red) ? 'Red' : 'Blue';

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

enum LogType {
  healing,
  damage,
}

class LogEntry {
  LogType type;
  double total = 0.0;
  int count = 0;

  LogEntry(this.type);

  String get typeString {
    return (type == LogType.healing) ? 'healing' : 'damage';
  }
}

class DamageLog {
  Map<String, LogEntry> entries = {};
  void recordDamage(Hit hit, double damage) {
    String source = hit.sourceString;
    LogEntry entry = entries[source] ?? new LogEntry(LogType.damage);
    assert(entry.type == LogType.damage);
    entry.total += damage;
    entry.count += 1;
    entries[source] = entry;
  }

  void recordHealing(String source, double healing) {
    LogEntry entry = entries[source] ?? new LogEntry(LogType.healing);
    assert(entry.type == LogType.healing);
    entry.total += healing;
    entry.count += 1;
    entries[source] = entry;
  }

  String get summaryString {
    String summary = "";
    entries.forEach((name, entry) {
      summary +=
          "${entry.total.toStringAsFixed(1)} ${entry.typeString} from $name (${entry.count} instances)\n";
    });
    return summary;
  }

  double totalForType(LogType type) {
    double total = 0.0;
    entries.values.forEach((entry) {
      if (entry.type != type) return;
      total += entry.total;
    });
    return total;
  }

  double get totalDamage => totalForType(LogType.damage);
}

enum MobState {
  ready,
  stopped,
}

class AbilityRanks {
  int q;
  int w;
  int e;
  int r;
  AbilityRanks({this.q: 0, this.w: 0, this.e: 0, this.r: 0});
}

class Healing extends TickingBuff {
  Healing(Mob target) : super(name: 'Healing', target: target);

  @override
  String get lastUpdate => VERSION_7_2_1;

  @override
  void onTick() {
    double hpPerSecond = target.stats.hpRegen / 5.0;
    target.healFor(hpPerSecond * secondsBetweenTicks, 'hp5');
    if (target.healthPercent >= 1.0) expire();
  }
}

class ManaRecovery extends TickingBuff {
  ManaRecovery(Mob target) : super(name: 'Mana Recovery', target: target);

  @override
  String get lastUpdate => VERSION_7_11_1;

  @override
  void onTick() {
    double mpPerSecond = target.stats.mpRegen / 5.0;
    target.recoverMana(mpPerSecond * secondsBetweenTicks, 'mp5');
    if (target.mpSpent <= 0.0) expire();
  }
}

enum MobType {
  champion,
  minion,
  smallMonster,
  largeMonster,
  epicMonster,
  structure,
}

class Spell {
  final SpellDescription description;
  final Mob mob;
  BuffEffects effects;
  int _rank = 0;

  Spell(this.mob, this.description);

  void addSkillPoint() {
    _rank += 1;
    effects = constructEffectsForSpell(description, mob, _rank);
  }

  int get rank => _rank;
  int get range => description.rangeForRank(rank);

  @override
  String toString() => "Rank $_rank ${description.name}";
}

// FIXME: Unclear if the 'Spell' class is necessary
// could it just be rolled into SpellEffects?
class SummonerBook {
  Spell d;
  Spell f;
}

class SpellBook {
  Spell q;
  Spell e;
  Spell w;
  Spell r;

  SpellBook(Mob mob, SpellDescriptionBook description)
      : q = new Spell(mob, description.q),
        e = new Spell(mob, description.e),
        w = new Spell(mob, description.w),
        r = new Spell(mob, description.r);

  Spell spellForKey(SpellKey key) {
    return {
      SpellKey.q: q,
      SpellKey.w: w,
      SpellKey.e: e,
      SpellKey.r: r,
    }[key];
  }

  void addSkillPointTo(SpellKey key) {
    spellForKey(key).addSkillPoint();
  }

  void forEach(void callback(Spell spell)) {
    callback(q);
    callback(e);
    callback(w);
    callback(r);
  }
}

typedef PlanningFunction = List<Action> Function(Mob mob);

class Mob {
  final MobDescription description;
  final MobType _type;
  Team team;
  Planner planner;

  // FIXME: These could group into some sort of effects object.
  List<Item> items = <Item>[];
  List<Buff> buffs = <Buff>[];
  MasteryPage _masteryPage;
  RunePage _runePage;
  ChampionEffects championEffects;
  SpellBook spells;
  SummonerBook summoners;

  Stats stats; // updated per-tick.
  int _level = 1;
  double hpLost = 0.0;
  double mpSpent = 0.0;
  bool alive = true;
  DamageLog damageLog;

  MobState state; // Eventually for CC, etc.

  bool _updatingBuffs = false;
  List<Buff> _buffsAddedWhileUpdating = <Buff>[];
  List<EffectsBase> _cachedEffects = <EffectsBase>[];

  // FIXME: Split this out into named constructors.
  Mob(this.description, this._type) {
    ChampionEffectsConstructor effectsConstructor =
        championEffectsConstructors[id];
    if (effectsConstructor != null) championEffects = effectsConstructor(this);
    updateStats();
    if (championEffects != null) championEffects.onChampionCreate();
    revive();
    planner = new Planner(this);
  }

  double get currentHp => alive ? max(0.0, stats.hp - hpLost) : 0.0;
  double get healthPercent => currentHp / stats.hp;

  double get currentMp => alive ? max(0.0, stats.mp - mpSpent) : 0.0;
  double get manaPercent => currentMp / stats.mp;

  String get id => description.id;
  String get name => description.name;

  bool get isChampion => _type == MobType.champion;
  bool get isMinion => _type == MobType.minion;
  bool get isMonster => _type == MobType.smallMonster || isLargeMonster;
  bool get isLargeMonster =>
      _type == MobType.largeMonster || _type == MobType.epicMonster;
  bool get isStructure => _type == MobType.structure;

  int get level => _level;
  set level(int newLevel) {
    assert(newLevel >= 1);
    assert(newLevel <= 18);
    _level = newLevel;
  }

  void addSkillPointTo(SpellKey key) {
    spells.addSkillPointTo(key);
    _updateCachedEffects();
  }

  bool get shouldRecordDamage => damageLog != null;
  set shouldRecordDamage(bool flag) {
    if (flag == shouldRecordDamage) return;
    if (flag)
      damageLog = new DamageLog();
    else
      damageLog = null;
  }

  MasteryPage get masteryPage => _masteryPage;
  set masteryPage(MasteryPage newPage) {
    _masteryPage = newPage;
    _masteryPage.initForChamp(this);
    _masteryPage.logAnyMissingEffects();
    updateStats();
  }

  RunePage get runePage => _runePage;
  set runePage(RunePage newPage) {
    _runePage = newPage;
    _runePage.logAnyMissingStats();
    updateStats();
  }

  String statsSummary() {
    String summary = """  $name (lvl ${level})
    HP : ${currentHp.toStringAsFixed(1)} / ${stats.hp.toStringAsFixed(1)} + ${stats.hpRegen.toStringAsFixed(1)}/5
    AD : ${stats.attackDamage.round()}  AP : ${stats.abilityPower.round()}
    AR : ${stats.armor.round()}  MR : ${stats.spellBlock.round()}
    AS : ${stats.attackSpeed.toStringAsFixed(3)} (${stats.attackDuration.toStringAsFixed(1)}s)\n""";
    if (runePage != null) summary += '    Runes: ${runePage.summaryString}\n';
    if (masteryPage != null) summary += '    Masteries: ${masteryPage}\n';
    if (items.isNotEmpty) summary += '    Items: ${items}\n';
    return summary;
  }

  Stats updateStats() {
    if (isChampion)
      stats = description.baseStats.championCurvedStatsForLevel(level);
    else
      stats = description.baseStats.linearStatsForLevel(level);
    if (runePage != null) stats.applyStatMap(runePage.collectStats());
    if (masteryPage != null) {
      for (Mastery mastery in masteryPage.masteries) {
        if (mastery?.effects?.stats != null) {
          stats.applyStatMap(mastery.effects.stats);
        }
      }
    }
    for (Item item in items) {
      stats.applyStatMap(item.stats);
      if (item.effects != null && item.effects.stats != null)
        stats.applyStatMap(item.effects.stats);
    }
    for (Buff buff in buffs)
      if (buff.stats != null) stats.applyStatMap(buff.stats);
    spells?.forEach((Spell spell) {
      Map spellStats = spell?.effects?.stats;
      if (spellStats != null) stats.applyStatMap(spellStats);
    });
    return stats;
  }

  @override
  String toString() {
    String teamString = (team != null) ? "${teamToString(team)} " : "";
    return "$teamString$name";
  }

  Item addItem(ItemDescription description) {
    Item item = new Item(this, description);
    items.add(item);
    updateStats();
    return item;
  }

  Item firstItemNamed(String name) =>
      items.firstWhere((item) => item.name == name, orElse: () => null);

  void addBuff(Buff buff) {
    if (_updatingBuffs)
      _buffsAddedWhileUpdating.add(buff);
    else {
      buffs.add(buff);
      _didUpdateBuffs();
    }
  }

  void _didUpdateBuffs() {
    updateStats(); // needed?
    _updateCachedEffects();
  }

  void removeBuff(Buff buff) {
    buff.expire();
    buffs.remove(buff);
  }

  bool canAutoAttack() {
    if (state != MobState.ready) return false;
    if (buffs.any((buff) => buff is AutoAttackCooldown)) return false;
    return true;
  }

  List<EffectsBase> collectEffects() {
    var effects = new List.from(buffs);
    if (championEffects != null) effects.add(championEffects);
    items.forEach((item) {
      if (item != null && item.effects != null) effects.add(item.effects);
    });
    spells?.forEach((Spell spell) {
      if (spell.effects != null) effects.add(spell.effects);
    });
    return effects;
  }

  void _updateCachedEffects() {
    _cachedEffects = collectEffects();
  }

  void _tickBuffs(double timeDelta) {
    // Buffs can cause dmg which can add other buffs so we
    // guard traversal.
    _updatingBuffs = true;
    buffs.forEach((buff) => buff.tick(timeDelta));
    buffs.addAll(_buffsAddedWhileUpdating);
    _buffsAddedWhileUpdating = [];
    buffs = buffs.where((buff) => !buff.expired).toList();
    _updatingBuffs = false;
    _didUpdateBuffs();
  }

  // Not clear if buffs should be held on the Mob or not.
  List<Action> tick(double timeDelta) {
    updateStats();
    if (!alive) return [];
    _tickBuffs(timeDelta);
    updateStats(); // Buffs can affect stats.
    return planner.nextActions();
  }

  List<DamageDealtModifier> collectDamageDealtModifiers() {
    List<DamageDealtModifier> modifiers = [
      // I'm not sure this is right, there may be a difference between
      // total critical dmg vs. base critical dmg.
      (hit, delta) {
        if (!hit.isCrit) return;
        delta.percentPhysical *= stats.critDamageMultiplier;
        delta.percentMagical *= stats.critDamageMultiplier;
      }
    ];
    if (masteryPage != null) {
      for (Mastery mastery in masteryPage.masteries) {
        if (mastery.effects != null)
          modifiers.add(mastery.effects.damageDealtModifier);
      }
    }
    for (Buff buff in buffs) {
      modifiers.add(buff.damageDealtModifier);
    }
    spells?.forEach((Spell spell) {
      if (spell.effects != null)
        modifiers.add(spell.effects.damageDealtModifier);
    });
    return modifiers;
  }

  DamageDealtDelta computeDamageDealtDelta(Hit hit) {
    List<DamageDealtModifier> modifiers = collectDamageDealtModifiers();
    DamageDealtDelta delta = new DamageDealtDelta();
    modifiers.forEach((modifier) => modifier(hit, delta));
    return delta;
  }

  Hit createHitForTarget({
    @required Mob target,
    @required String label,
    bool isCrit: false,
    double physicalDamage: 0.0,
    double magicDamage: 0.0,
    double trueDamage: 0.0,
    @required Targeting targeting,
  }) {
    Hit hit = new Hit._(
      source: this,
      target: target,
      label: label,
      isCrit: isCrit,
      physicalDamage: physicalDamage,
      magicDamage: magicDamage,
      trueDamage: trueDamage,
      targeting: targeting,
    );

    DamageDealtDelta delta = computeDamageDealtDelta(hit);
    hit.applyDamageDealtModifier(delta);
    return hit;
  }

  static double resistanceMultiplier(double resistance) {
    if (resistance > 0) return 100 / (100 + resistance);
    return 2 - (100 / (100 - resistance));
  }

  double armorAfterPenatration(Mob source) {
    // Pen is ignored when source is null (during some tests).
    if (source == null) return stats.armor;
    if (stats.armor <= 0) return stats.armor;
    double effectiveArmor = (stats.baseArmor +
            stats.bonusArmor * source.stats.percentBonusArmorPenetration) *
        source.stats.percentArmorPenetration;
    effectiveArmor -=
        source.stats.flatArmorPenetrationForTargetWithLevel(level);
    return max(effectiveArmor, 0.0);
  }

  double spellBlockAfterPenatration(Mob source) {
    // Pen is ignored when source is null (during some tests).
    if (source == null) return stats.spellBlock;
    if (stats.spellBlock <= 0) return stats.spellBlock;
    double effectiveSpellBlock =
        stats.spellBlock * source.stats.percentMagicPenetration;
    effectiveSpellBlock -= source.stats.flatMagicPenetration;
    return max(effectiveSpellBlock, 0.0);
  }

  List<DamageRecievedModifier> collectDamageRecievedModifiers() {
    List<DamageRecievedModifier> modifiers = [
      (hit, delta) {
        // hit.target can be null.
        delta.percentPhysical *=
            resistanceMultiplier(armorAfterPenatration(hit.source));
        delta.percentMagical *=
            resistanceMultiplier(spellBlockAfterPenatration(hit.source));
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
    spells?.forEach((Spell spell) {
      if (spell.effects != null)
        modifiers.add(spell.effects.damageRecievedModifier);
    });
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

  String get mpStatusString {
    int percent = (manaPercent * 100).round();
    return "$percent% (${currentMp.toStringAsFixed(1)} / ${stats.mp.round()})";
  }

  void startHealingIfNecessary() {
    if (buffs.any((buff) => buff is Healing)) return;
    addBuff(new Healing(this));
  }

  double applyHit(Hit hit) {
    World.combatLog("$this hit by ${hit.summaryString}");
    if (hit.appliesSpellEffects) hit.source.applyOnSpellHitEffects(hit);
    // FIXME: Unclear if this onBeforeDamageRecieved is necessary (or correct).
    _cachedEffects.forEach((effect) => effect.onBeforeDamageRecieved(hit));
    double damage = computeDamageRecieved(hit);
    hpLost += damage;
    World.combatLog(
        "$this took ${damage.toStringAsFixed(1)} damage from ${hit.sourceString}, "
        "$hpStatusString remains");
    damageLog?.recordDamage(hit, damage);
    if (hit.isAutoAttack)
      _cachedEffects.forEach((effect) => effect.onBeingHit(hit));
    _cachedEffects.forEach((effect) => effect.onDamageRecieved());
    startHealingIfNecessary();
    if (currentHp <= 0.0) die();
    return damage; // This could be beyond-fatal damage.
  }

  void applyOnAutoAttackHitEffects(Hit hit) {
    _cachedEffects.forEach((effect) => effect.onAutoAttackHit(hit));
  }

  void applyOnSpellHitEffects(Hit hit) {
    _cachedEffects.forEach((effect) => effect.onSpellHit(hit));
  }

  void lifestealFrom(double damage) {
    healFor(damage * stats.lifesteal, 'lifesteal');
  }

  void healFor(double healing, String source) {
    if (!alive) return;
    if (healing == 0.0) return;
    assert(healing > 0.0);
    World.combatLog(
        "$this healed ${healing.toStringAsFixed(1)} from $source $hpStatusString remains");
    damageLog?.recordHealing(source, healing);
    // FIXME: Missing healing modifiers.
    hpLost -= min(hpLost, healing);
  }

  void recoverMana(double additionalMana, String source) {
    if (!alive) return;
    if (additionalMana == 0.0) return;
    assert(additionalMana > 0.0);
    World.combatLog(
        "$this recovered ${additionalMana.toStringAsFixed(1)} mana from $source $mpStatusString remains");
    mpSpent -= min(mpSpent, additionalMana);
  }

  void revive() {
    alive = true;
    state = MobState.ready;
    hpLost = 0.0;
    mpSpent = 0.0;
    buffs = buffs.where((buff) => buff.retainedAfterDeath).toList();
    _didUpdateBuffs();
  }

  void die() {
    _log.info("DEATH: $this");
    hpLost = stats.hp;
    if (damageLog != null) _log.info(damageLog.summaryString);
    _cachedEffects.forEach((effect) => effect.onDeath(this));
    // FIXME: Death could be a buff if there are rez timers.
    alive = false;
  }

  bool spendManaIfPossible(int mana) {
    if (currentMp < mana) return false;
    mpSpent += mana;
    startManaRecoveryIfNecessary();
    return true;
  }

  void startManaRecoveryIfNecessary() {
    if (buffs.any((buff) => buff is ManaRecovery)) return;
    addBuff(new ManaRecovery(this));
  }
}

typedef bool TickCondition(World world);
typedef bool CritProvider(Mob attacker);

class RandomCrits {
  Random random = new Random();
  bool call(Mob attacker) {
    if (attacker.stats.critChance == 0.0) return false;
    return random.nextDouble() < attacker.stats.critChance;
  }
}

class PredictableCrits {
  Map<String, Random> randomForChamp = {};

  bool call(Mob attacker) {
    if (attacker.stats.critChance == 0.0) return false;
    Random random =
        randomForChamp.putIfAbsent(attacker.id, () => new Random(0));
    return random.nextDouble() < attacker.stats.critChance;
  }
}

class World {
  double time = 0.0;
  List<Mob> reds = [];
  List<Mob> blues = [];
  CritProvider critProvider;
  static World _current;

  World({this.reds: const [], this.blues: const [], this.critProvider}) {
    reds.forEach((mob) => mob.team = Team.red);
    blues.forEach((mob) => mob.team = Team.blue);
    if (critProvider == null) critProvider = new RandomCrits();
  }

  static bool get haveCurrentWorld => _current != null;
  static World get current {
    assert(_current != null, 'No current world use makeCurrentForScope');
    return _current;
  }

  List<Mob> get allMobs => []..addAll(reds)..addAll(blues);

  String get logTime => "${time.toStringAsFixed(2)}s";

  static void log(String message) {
    if (haveCurrentWorld)
      _log.info('${_current.logTime}: $message');
    else
      _log.info(message);
  }

  static void combatLog(String message) {
    if (haveCurrentWorld)
      _log.fine('${_current.logTime}: $message');
    else
      _log.fine(message);
  }

  void addMobs(Iterable<Mob> mobs) {
    mobs.forEach((Mob mob) {
      assert(mob.team != null);
      if (mob.team == Team.red)
        reds.add(mob);
      else
        blues.add(mob);
    });
  }

  Mob closestEnemyWithin(Mob reference, int range) {
    List<Mob> enemies = enemiesWithin(reference, range);
    if (enemies.isEmpty) return null;
    return enemies.first;
  }

  List<Mob> enemiesWithin(Mob reference, int range) {
    // FIXME: Respect range.
    if (reference.team == Team.red) return new List.from(livingBlues);
    // Using a copy to allow callers to add while iterating.
    return new List.from(livingReds);
  }

  Iterable<Mob> visibleNearbyEnemyChampions(Mob reference, {int range = 1000}) {
    if (range == 0) return []; // range is ignored for now.
    Iterable<Mob> allMobs =
        (reference.team == Team.red) ? livingBlues : livingReds;
    return allMobs.where((mob) => mob.isChampion && mob.team != reference.team);
  }

  void tick() {
    const double timeDelta = 1 / TICKS_PER_SECOND;
    time += timeDelta;
    List<Action> actions =
        allMobs.map((mob) => mob.tick(timeDelta)).reduce((all, actions) {
      all.addAll(actions);
      return all;
    });
    // Might need to sort actions?
    // FIXME: Targets can become invalid when applying actions!
    actions.forEach((action) => action.apply(this));
  }

  // Very common usage, hence defined here.
  static TickCondition oneSideDies = (World world) {
    bool survivingBlues = world.blues.any((Mob mob) => mob.alive);
    bool survivingReds = world.reds.any((Mob mob) => mob.alive);
    return !survivingBlues || !survivingReds;
  };

  void tickUntil(TickCondition condition) {
    makeCurrentForScope(() {
      do {
        tick();
      } while (!condition(this));
    });
  }

  void tickFor(double duration) {
    double endTime = time + duration;
    tickUntil((world) => world.time >= endTime);
  }

  void makeCurrentForScope(void closure()) {
    World previous = _current;
    _current = this;
    try {
      closure();
    } finally {
      _current = previous;
    }
  }

  Iterable<Mob> get livingBlues => blues.where((Mob mob) => mob.alive);
  Iterable<Mob> get livingReds => reds.where((Mob mob) => mob.alive);
  Iterable<Mob> get living => allMobs.where((Mob mob) => mob.alive);
}
