import 'lolsim.dart';
import 'role.dart';

class CastSpell extends Action {
  Spell spell;
  CastSpell(this.spell) : super();

  @override
  void apply(World world) {
    spell.castOnSelf();
  }
}

class Planner {
  Mob mob;
  Mob attackTarget;

  Planner(this.mob);

  bool castIfInRange(Spell spell, List<Action> actions) {
    if (!spell.canBeCastOnSelf) return false;
    World world = World.current;
    bool inRange = world.enemiesWithin(mob, spell.range).isNotEmpty;
    bool shouldCast = inRange || spell.isActiveToggle;
    if (!shouldCast) return false;
    actions.add(new CastSpell(spell));
    return true;
  }

  List<Action> nextActions() {
    if (attackTarget?.alive == false) attackTarget = null;
    if (!mob.canAutoAttack()) return [];
    // Guarded with haveCurrentWorld for testing.
    if (attackTarget == null && World.haveCurrentWorld)
      attackTarget = World.current.closestEnemyWithin(mob, mob.stats.range);
    if (attackTarget == null) return [];
    return [new AutoAttack(mob, attackTarget)];
  }
}

class AmumuPlanner extends Planner {
  AmumuPlanner(Mob mob) : super(mob);

  @override
  List<Action> nextActions() {
    List<Action> actions = <Action>[];
    if (castIfInRange(mob.spells.w, actions)) return actions;
    if (castIfInRange(mob.spells.e, actions)) return actions;
    return super.nextActions();
  }
}

Planner plannerFor(Mob mob, Role role) {
  if (mob.name == 'Amumu') return new AmumuPlanner(mob);
  return new Planner(mob);
}
