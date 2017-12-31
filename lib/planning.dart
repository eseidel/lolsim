import 'mob.dart';
import 'role.dart';
import 'buffs.dart';
import 'items.dart';
import 'world.dart';

class SelfCastSpell extends Action {
  Spell spell;
  SelfCastSpell(this.spell);

  @override
  void apply(World world) {
    World.combatLog('${spell.mob} casts ${spell}');
    (spell.effects as SelfTargetedSpell).castOnSelf();
  }
}

class TargetCastSpell extends Action {
  Spell spell;
  Mob target;
  TargetCastSpell(this.spell, this.target);

  @override
  void apply(World world) {
    World.combatLog('${spell.mob} casts ${spell} on ${target}');
    (spell.effects as SingleTargetSpell).castOn(target);
  }
}

class ActivateItem extends Action {
  Item item;
  Mob target;
  ActivateItem(this.item, this.target);

  @override
  void apply(World world) {
    World.combatLog('${item.owner} activates ${item.name} on ${target}');
    (item.effects as RefillablePotion).castOn(target);
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
    // is Toggle : inRange != toggled state
    // not Toggle : inRange
    bool shouldCast = inRange && !effects.isActiveToggle;
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

  bool consumePotionIfNeeded(Mob self, List<Action> actions) {
    if (self.healthPercent > 0.7) return false;
    Item potion = self.firstItemNamed(ItemNames.RefillablePotion);
    if (potion == null) return false;
    RefillablePotion effects = potion.effects as RefillablePotion;
    if (!effects.canBeCastOn(self)) return false;
    if (effects.isActive(self)) return false;
    actions.add(new ActivateItem(potion, self));
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

List<Action> assertNotEmpty(List<Action> actions) {
  assert(actions.isNotEmpty);
  return actions;
}

// FIXME: This probably belongs in amumu.dart
class AmumuPlanner extends Planner {
  AmumuPlanner(Mob self) : super(self);

  @override
  List<Action> nextActions() {
    List<Action> actions = <Action>[];
    if (selfCastIfInRange(self.spells.w, actions))
      return assertNotEmpty(actions);
    if (selfCastIfInRange(self.spells.e, actions))
      return assertNotEmpty(actions);
    // FIXME: Hack to not smite when it doesn't heal us.
    // FIXME: This should lookup the summoner by name not position?
    if (self.healthPercent < .7 &&
        targetCastIfInRange(self.summoners.d, actions))
      return assertNotEmpty(actions);
    if (consumePotionIfNeeded(self, actions)) return assertNotEmpty(actions);

    return super.nextActions();
  }
}

class JunglePlaner extends Planner {
  JunglePlaner(Mob self) : super(self);

  @override
  List<Action> nextActions() {
    List<Action> actions = <Action>[];
    // FIXME: Hack to not smite when it doesn't heal us.
    // FIXME: This should lookup the summoner by name not position?
    if (self.healthPercent < .7 &&
        targetCastIfInRange(self.summoners.d, actions)) return actions;
    return super.nextActions();
  }
}

Planner plannerFor(Mob mob, Role role) {
  if (mob.name == 'Amumu') return new AmumuPlanner(mob);
  if (role == Role.jungle) return new JunglePlaner(mob);
  return new Planner(mob);
}

class SkillPlanner extends PermanentBuff {
  List<SpellKey> skillOrder;

  SkillPlanner(Mob target, this.skillOrder) : super('Skill Planner', target);

  @override
  String get lastUpdate => null;

  @override
  void onLevelUp() {
    target.addSkillPointTo(skillOrder[target.level - 1]);
  }
}
