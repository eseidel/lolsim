import 'lolsim.dart';
import 'package:meta/meta.dart';

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

  Buff({this.name, @required this.target});

  void tick(double timeDelta);

  void expire() {
    expired = true;
    onExpired();
  }

  onExpired() {}
}

class TimedBuff extends Buff {
  final double duration;
  double remaining;

  TimedBuff({String name, Mob target, this.duration})
      : super(name: name, target: target);

  void refresh() {
    remaining = duration;
  }

  void tick(double timeDelta) {
    remaining -= timeDelta;
    if (remaining <= 0.0) expire();
  }
}

class Cooldown extends TimedBuff {
  // Fixed at time of creation in LOL. CDR does not affect in-progress cooldowns:
  // http://leagueoflegends.wikia.com/wiki/Cooldown_reduction
  Cooldown(Mob target, double duration)
      : super(target: target, duration: duration);
}

abstract class DOT extends Buff {
  final double secondsBetweenTicks;
  List<int> perStackTicksRemaining;
  // Currently dmg is fixed at time of creation or last application.
  Hit dmgPerTick;
  double untilNextTick;
  final int initialTicks;

  DOT({
    String name,
    @required Mob target,
    this.secondsBetweenTicks: 0.5,
    @required double duration,
    int initialStacks: 1,
  })
      : initialTicks = (duration / secondsBetweenTicks).floor(),
        super(name: name, target: target) {
    // FIXME: This should use integer number of ticks.
    assert(duration % secondsBetweenTicks == 0);
    addStacks(initialTicks);
  }

  void addStacks(int count) {
    // Add a new stack (possibly removing oldest).
    // Add a new full ticks to the stack, or if the stack is
    // full then take the oldest ticks and make it full.
    // Does not change tick timing.
    perStackTicksRemaining = new List.filled(count, initialTicks);
  }

  void tick(double timeDelta) {
    while (!expired && timeDelta > secondsBetweenTicks) {
      onTick();
      timeDelta -= secondsBetweenTicks;
    }
    untilNextTick = secondsBetweenTicks - timeDelta;
  }

  Hit createHitForStacks(int stackCount);

  void onTick() {
    // Combine the stacks into one dmg event?
    int stackCount = perStackTicksRemaining.length;
    Hit hit = createHitForStacks(stackCount);
    target.applyHit(hit);
  }
}
