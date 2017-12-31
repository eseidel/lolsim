import 'package:lol_duel/mob.dart';
import 'package:logging/logging.dart';

final Logger _log = new Logger('world');

abstract class MapSettings {
  final String name;
  MapSettings(this.name);
  double cummulativeExperianceToLevel(int level);
}

class SummonersRift extends MapSettings {
  SummonersRift() : super('Summoner\'s Rift');
  double _deltaExperianceToLevel(int level) {
    return 100.0 * level + 80.0;
  }

  // FIXME: This is static and could be cached.
  @override
  double cummulativeExperianceToLevel(int level) {
    double total = 0.0;
    while (level > 1) {
      total += _deltaExperianceToLevel(level);
      level -= 1;
    }
    return total;
  }
}

class World {
  double time = 0.0;
  MapSettings map = new SummonersRift();
  List<Mob> reds = [];
  List<Mob> blues = [];
  CritProvider critProvider;
  static World _current;

  World({this.reds, this.blues, this.critProvider}) {
    reds ??= [];
    blues ??= [];
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
