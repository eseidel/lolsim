import 'lolsim.dart';
import 'role.dart';
import 'buffs.dart';

class SelfCastSpell extends Action {
  Spell spell;
  SelfCastSpell(this.spell) : super();

  @override
  void apply(World world) {
    (spell.effects as SelfTargetedSpell).castOnSelf();
  }
}

class TargetCastSpell extends Action {
  Spell spell;
  Mob target;
  TargetCastSpell(this.spell, this.target) : super();

  @override
  void apply(World world) {
    (spell.effects as SingleTargetSpell).castOn(target);
  }
}

class Planner {
  Mob self;
  Mob attackTarget;

  Planner(this.self);

  bool selfCastIfInRange(Spell spell, List<Action> actions) {
    SelfTargetedSpell effects = spell.effects as SelfTargetedSpell;
    if (effects == null) return false;
    if (!effects.canBeCastOnSelf) return false;
    World world = World.current;
    bool inRange = world.enemiesWithin(self, spell.range).isNotEmpty;
    bool shouldCast = inRange || effects.isActiveToggle;
    if (!shouldCast) return false;
    actions.add(new SelfCastSpell(spell));
    return true;
  }

  bool targetCastIfInRange(Spell spell, List<Action> actions) {
    SingleTargetSpell effects = spell.effects as SingleTargetSpell;
    if (effects == null) return false;
    World world = World.current;
    Iterable<Mob> enemies = world
        .enemiesWithin(self, spell.range)
        .where((mob) => effects.canBeCastOn(mob));
    if (enemies.isEmpty) return false;
    Mob target = enemies.first;
    actions.add(new TargetCastSpell(spell, target));
    return true;
  }

  List<Action> nextActions() {
    if (attackTarget?.alive == false) attackTarget = null;
    if (!self.canAutoAttack()) return [];
    // Guarded with haveCurrentWorld for testing.
    if (attackTarget == null && World.haveCurrentWorld)
      attackTarget = World.current.closestEnemyWithin(self, self.stats.range);
    if (attackTarget == null) return [];
    return [new AutoAttack(self, attackTarget)];
  }
}

// FIXME: This probably belongs in amumu.dart
class AmumuPlanner extends Planner {
  AmumuPlanner(Mob self) : super(self);

  @override
  List<Action> nextActions() {
    List<Action> actions = <Action>[];
    if (selfCastIfInRange(self.spells.w, actions)) return actions;
    if (selfCastIfInRange(self.spells.e, actions)) return actions;
    // FIXME: Hack to not smite when it doesn't heal us.
    // FIXME: This should lookup the summoner by name not position?
    if (self.healthPercent < .7 &&
        targetCastIfInRange(self.summoners.d, actions)) return actions;
    return super.nextActions();
  }
}

Planner plannerFor(Mob mob, Role role) {
  if (mob.name == 'Amumu') return new AmumuPlanner(mob);
  return new Planner(mob);
}
