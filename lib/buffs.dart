import 'dart:math';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'lolsim.dart';

final Logger _log = new Logger('buffs');

// I think you want ticks to be synchronized.  Unclear if that's across dots or not.

// Refreshing dots, options:
// 1. Add N ticks (or N-1) ticks to the exisitng dot, do not update stats or start time.
// 2. Update start-time, possibly skipping a tick.

// I think you want a fixed start time, a refresh updates stacks, etc.
// Stacks all share the same stats, which can be updated when a stack is applied.
// Ticks know how to catch-up from time?

// Buff
// StackableBuff
// DOT
// StackableDOT

// FIXME: Not all buffs are finite and need ticks.
abstract class Buff {
  String name;
  Mob target;

  bool expired = false;
  bool get retainedAfterDeath => false;

  Buff({this.name, @required this.target});

  @override
  String toString() {
    if (name != null) return name;
    return "Buff";
  }

  Map<String, num> get stats => null;

  void tick(double timeDelta);

  void expire() {
    expired = true;
  }
}

class PermanentBuff extends Buff {
  PermanentBuff({String name, Mob target}) : super(name: name, target: target);
  bool get retainedAfterDeath => true;

  @override
  void tick(double timeDelta) {}
}

class TimedBuff extends Buff {
  final double duration;
  double remaining;

  TimedBuff({String name, @required Mob target, @required this.duration})
      : remaining = duration,
        super(name: name, target: target);

  void refresh() {
    remaining = duration;
  }

  @override
  void tick(double timeDelta) {
    remaining -= timeDelta;
    if (remaining <= 0.0) expire();
  }
}

class Cooldown extends TimedBuff {
  // Fixed at time of creation in LOL. CDR does not affect in-progress cooldowns:
  // http://leagueoflegends.wikia.com/wiki/Cooldown_reduction
  Cooldown({String name, Mob target, double duration})
      : super(name: name, target: target, duration: duration);
}

abstract class TickingBuff extends Buff {
  final double secondsBetweenTicks;
  double untilNextTick;

  TickingBuff(
      {String name, Mob target, this.secondsBetweenTicks: 0.5, double duration})
      : untilNextTick = secondsBetweenTicks,
        super(name: name, target: target) {}

  @override
  void tick(double timeDelta) {
    assert(!expired);
    untilNextTick -= timeDelta;
    // This implementation supports catch-up damage.
    while (!expired && untilNextTick <= 0) {
      onTick();
      untilNextTick += secondsBetweenTicks;
    }
  }

  void onTick();
}

abstract class DOT extends TickingBuff {
  List<int> perStackTicksRemaining;
  // Currently dmg is fixed at time of creation or last application.
  Hit dmgPerTick;
  final int maxStacks;
  final int initialTicks;

  DOT({
    String name,
    @required Mob target,
    double secondsBetweenTicks: 0.5,
    @required double duration,
    int initialStacks: 1,
    this.maxStacks: 1,
  })
      : initialTicks = (duration / secondsBetweenTicks).floor(),
        super(
            name: name,
            target: target,
            secondsBetweenTicks: secondsBetweenTicks) {
    // FIXME: This should use integer number of ticks.
    assert(duration % secondsBetweenTicks == 0);
    perStackTicksRemaining = [];
    addStacks(initialStacks);
  }

  int get stacks => perStackTicksRemaining.length;

  String _plural(String word, int count) {
    return count > 1 ? word + 's' : word;
  }

  @override
  String toString() {
    String stacksString = "$stacks " + _plural('stack', stacks);
    return "$name ($stacksString)";
  }

  List<int> takeLast(List<int> list, int toTake) {
    return list.skip(max(0, list.length - toTake)).toList();
  }

  void addStacks(int count) {
    assert(count <= maxStacks);
    // Add a new full ticks to the stack, or if the stack is
    // full then take the oldest ticks and make it full.
    // Does not change tick timing.
    perStackTicksRemaining.addAll(new List.filled(count, initialTicks));
    perStackTicksRemaining = takeLast(perStackTicksRemaining, maxStacks);
  }

  Hit createHitForStacks(int stackCount);

  @override
  void onTick() {
    // Currently combining stacks into one damage event.
    Hit hit = createHitForStacks(stacks);
    target.applyHit(hit);
  }
}

// FIXME: This could share code with DOT.
class StackedBuff extends Buff {
  final int maxStacks;
  final double duration;
  final double timeBetweenFalloffs;

  int stacks = 0;
  double untilFirstFalloff;
  double untilNextFalloff;

  StackedBuff({
    @required this.maxStacks,
    @required this.duration,
    @required this.timeBetweenFalloffs,
    Mob target,
    String name,
  })
      : super(name: name, target: target) {
    refreshAndAddStack();
  }

  void tick(double totalTimeDelta) {
    // FIXME: Handling totalTimeDelta > timeBetweenFalloffs is only for unittests
    // instead this 'catch-up' logic should move to a higher level.
    while (totalTimeDelta > 0 && !expired) {
      double timeDelta = min(totalTimeDelta, timeBetweenFalloffs);
      totalTimeDelta -= timeDelta;
      if (untilFirstFalloff > 0) {
        untilFirstFalloff -= timeDelta;
      } else {
        untilNextFalloff -= timeDelta;
      }
      if (untilFirstFalloff <= 0) {
        stacks -= 1;
        untilNextFalloff = timeBetweenFalloffs;
      }
      if (stacks <= 0) expire();
    }
  }

  void refreshAndAddStack() {
    untilFirstFalloff = duration;
    untilNextFalloff = 0.0;
    if (stacks < maxStacks) stacks += 1;
  }
}
