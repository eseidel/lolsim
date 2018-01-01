import 'dragon/stat_constants.dart';
import 'effects.dart';
import 'mob.dart';

typedef MasteryEffectsConstructor = MasteryEffects Function(
    Mob champ, int rank);

final Map<String, MasteryEffectsConstructor> masteryEffectsConstructors = {
  'Battering Blows': (Mob champ, int rank) => new BatteringBlows(champ, rank),
  'Double Edged Sword': (Mob champ, int rank) =>
      new DoubleEdgedSword(champ, rank),
  'Fury': (Mob champ, int rank) => new Fury(champ, rank),
  'Merciless': (Mob champ, int rank) => new Merciless(champ, rank),
  'Natural Talent': (Mob champ, int rank) => new NaturalTalent(champ, rank),
  'Piercing Thoughts': (Mob champ, int rank) =>
      new PiercingThoughts(champ, rank),
  'Precision': (Mob champ, int rank) => new Precision(champ, rank),
  'Recovery': (Mob champ, int rank) => new Recovery(champ, rank),
  'Sorcery': (Mob champ, int rank) => new Sorcery(champ, rank),
  'Savagery': (Mob champ, int rank) => new Savagery(champ, rank),
  'Tough Skin': (Mob champ, int rank) => new ToughSkin(champ, rank),
  'Unyielding': (Mob champ, int rank) => new Unyielding(champ, rank),
  'Vampirism': (Mob champ, int rank) => new Vampirism(champ, rank),
  'Veterans Scars': (Mob champ, int rank) => new VeteransScars(champ, rank),
};

class Fury extends MasteryEffects {
  Fury(Mob champ, int rank) : super(champ, rank);

  @override
  String get lastUpdate => VERSION_7_11_1;

  // .8% * rank attack speed
  @override
  Map<String, num> get stats => {PercentAttackSpeedMod: .008 * rank};
}

class Sorcery extends MasteryEffects {
  Sorcery(Mob champ, int rank) : super(champ, rank);

  @override
  String get lastUpdate => VERSION_7_11_1;

  // .04 * R increased Ability damage
  @override
  void damageDealtModifier(Hit hit, DamageDealtDelta delta) {
    // Only applies to ability or spell damage.
    // FIXME: Unclear if this is the right check.
    if (!hit.appliesSpellEffects) return;
    delta.percentMagical *= 1.0 + (.004 * rank);
    delta.percentPhysical *= 1.0 + (.004 * rank);
  }
}

class FreshBlood {
  // Your first basic attack against a champion deals an additional
  // 10 +1 per level damage (6 second cooldown)
  // damage modifer + cooldown buff.
}

class Feast {
  // Killing a unit restores 20 Health (30 second cooldown)
  // onKill hook.
}

class ExposeWeakness {
  // Damaging enemy champions causes them to take 3% more damage from your allies
  // buff which applies a dmg amp.
}

class Vampirism extends MasteryEffects {
  Vampirism(Mob champ, int rank) : super(champ, rank);

  @override
  String get lastUpdate => VERSION_7_11_1;

  // .4% * R lifesteal and spell vamp.
  @override
  Map<String, num> get stats => {
        PercentLifeStealMod: .004 * rank,
        PercentSpellVampMod: .004 * rank,
      };
}

class NaturalTalent extends MasteryEffects {
  NaturalTalent(Mob champ, int rank) : super(champ, rank);

  @override
  String get lastUpdate => VERSION_7_2_1;

  // Gain 0.4 * R + 0.09 * R per level Attack Damage, and
  // 0.6 * R + 0.13 * R per level Ability Power (+2 Attack
  // Damage and 3 Ability Power at level 18)
  @override
  Map<String, num> get stats => {
        FlatPhysicalDamageMod: .004 * rank,
        FlatPhysicalDamageModPerLevel: .0009 * rank,
        FlatMagicDamageMod: .006 * rank,
        FlatMagicDamageModPerLevel: .0013 * rank,
      };
}

class BountyHunter {
  // Deal 1.5% increased damage for each unique enemy champion you have killed
  // buff which applies a damage amp.
  // OnKill hook with a stacking buff.
}

class DoubleEdgedSword extends MasteryEffects {
  DoubleEdgedSword(Mob champ, int rank) : super(champ, rank);

  @override
  String get lastUpdate => VERSION_7_11_1;

  // Deal 3% additional damage, take 1.5% additional damage.
  @override
  void damageDealtModifier(Hit hit, DamageDealtDelta delta) {
    delta.percentPhysical *= 1.03;
    delta.percentMagical *= 1.03;
  }

  @override
  void damageRecievedModifier(Hit hit, DamageRecievedDelta delta) {
    delta.percentPhysical *= 1.015;
    delta.percentMagical *= 1.015;
  }
}

class BattleTrance {
  // Gain up to 5% increased damage over 5 seconds when in combat with enemy Champions
  // Buff which provides damage amp, applied on combat ticks.
}

class BatteringBlows extends MasteryEffects {
  BatteringBlows(Mob champ, int rank) : super(champ, rank);

  @override
  String get lastUpdate => VERSION_7_2_1;

  // 1.4 * R percent Armor Penetration
  @override
  Map<String, num> get stats => {
        PercentArmorPenetrationMod: 1.4 * rank,
      };
}

class PiercingThoughts extends MasteryEffects {
  PiercingThoughts(Mob champ, int rank) : super(champ, rank);

  @override
  String get lastUpdate => VERSION_7_2_1;

  // +1.4 * R percent Magic Penetration
  @override
  Map<String, num> get stats => {
        PercentMagicPenetrationMod: 1.4 * rank,
      };
}

class WarlordsBloodlust {
  // Gain increasingly more Life Steal based on your missing health
  // against champions (up to 20%). Against minions gain 50%
  // benefit (25% for ranged champions).
  // Non-linear curve (need to work it out).
  // hp-sensitive stat boost.
}

class FervorofBattle {
  // Hitting champions with basic attacks generates a Fervor stack (2 for melee attacks).
  // Stacks of Fervor last 6 seconds (max 8 stacks) and increase your AD by 1-8 for each stack.
  // on-champion-hit triggered buff
}

class DeathfireTouch {
  // Your damaging abilities cause enemy champions to take magic damage over 4 seconds.
  // Damage: 8 + 60% Bonus Attack Damage and 25% Ability Power
  // Deathfire Touch's duration is reduced for:
  // - Area of Effect: 2 second duration.
  // - Damage over Time: 1 second duration.
  // On-ability-Hit buff.
}

class Wanderer {
  // +0.6% * R percent Movement Speed out of combat
  // on-out-of-combat triggered buff?
}

class Savagery extends MasteryEffects {
  Savagery(Mob champ, int rank) : super(champ, rank);

  @override
  String get lastUpdate => VERSION_7_2_1;

  // Single target attacks and spells deal 1 * R bonus damage to minions and monsters
  @override
  void damageDealtModifier(Hit hit, DamageDealtDelta delta) {
    if (!hit.target.isMinion && !hit.target.isMonster) return;
    if (!hit.isSingleTarget) return;
    // Unclear if this preference to magic dmg is correct, lolwiki has no guidance.
    if (hit.magicDamage > 0)
      delta.flatMagical += rank;
    else
      delta.flatPhysical += rank;
  }
}

class RunicAffinity {
  // Buffs from neutral monsters last 15% longer
  // Source-sensitive buff duration modifer.
}

class SecretStash {
  // Your Potions and Elixirs last 10% longer.
  // Your Health Potions are replaced with Biscuits that restore 15 Health and Mana instantly on use.
}

class Assassin {
  // Deal 2% increased damage to champions when no allied champions (800u) are nearby
  // Need a way to detect nearby, then simple dmg amp.
}

class Merciless extends MasteryEffects {
  Merciless(Mob champ, int rank) : super(champ, rank);

  @override
  String get lastUpdate => VERSION_7_2_1;

  // Deal 1% * R percent increased damage to champions below 40% Health
  @override
  void damageDealtModifier(Hit hit, DamageDealtDelta delta) {
    if (!hit.target.isChampion) return;
    if (hit.target.healthPercent >= 0.4) return;
    double damageAmp = 1.0 + (0.01 * rank);
    delta.percentPhysical *= damageAmp;
    delta.percentMagical *= damageAmp;
  }
}

class Meditation {
  // Regenerate 0.3% * R of your missing Mana every 5 seconds
  // percent missing mp5
}

class GreenfathersGift {
// Stepping into brush causes your next damaging attack or ability to
// deal 3% of your target's current health as bonus magic damage (9s Cooldown)
// buff + onhit modifier
}

class Bandit {
  // Gain 1 gold for each nearby minion killed by an ally.
  // Gain 3 gold (10 if melee) when hitting an enemy champion with a basic attack (5 second cooldown)
  // On nearby-death, and on-hit action.
}

class DangerousGame {
  // Champion kills and assists restore 5% of your missing Health and Mana
  // on-kill or on-assist trigger.
}

class Precision extends MasteryEffects {
  Precision(Mob champ, int rank) : super(champ, rank);

  @override
  String get lastUpdate => VERSION_7_11_1;

  // Gain 1.2 * R Lethality and 0.3 * R + 0.05 * R per level Magic Penetration
  @override
  Map<String, num> get stats => {
        Lethality: 1.2 * rank,
        // This seems to want linear per-level scaling instead of curved?
        FlatMagicPenetrationMod: 0.3 * rank + 0.05 * rank * champ.level,
      };
}

class Intelligence {
  // Your Cooldown Reduction cap is increased by 1% * R and
  // you gain 1% * R Cooldown Reduction
}

class StormraidersSurge {
  // Dealing 30% of a champion's max Health within 2.5 seconds grants you
  // 40% Movement Speed and 75% Slow Resistance for 3 seconds (10 second cooldown).
}

class ThunderlordsDecree {
  // Your 3rd attack or damaging spell against the same enemy champion calls
  // down a lightning strike, dealing magic damage in the area.
  // Damage: 10 per level, plus 30% of your Bonus Attack Damage,
  // and 10% of your Ability Power (25-15 second cooldown, based on level).
}

class WindspeakersBlessing {
  // Your heals and shields are 10% stronger. Additionally, your shields
  // and heals on other allies increase their armor by 5-22 (based on level)
  // and their magic resistance by half that amount for 3 seconds.
}

class Recovery extends MasteryEffects {
  Recovery(Mob champ, int rank) : super(champ, rank);

  @override
  String get lastUpdate => VERSION_7_2_1;

  // +0.4 * R Health per 5 seconds
  @override
  Map<String, num> get stats => {
        FlatHPRegenMod: .4 * rank,
      };
}

class Unyielding extends MasteryEffects {
  Unyielding(Mob champ, int rank) : super(champ, rank);

  @override
  String get lastUpdate => VERSION_7_11_1;

  // +1% Bonus Armor and Magic Resist
  @override
  Map<String, num> get stats => {
        PercentArmorMod: 1 * rank,
        PercentSpellBlockMod: 1 * rank,
      };
}

class Explorer {
  // +15 Movement Speed in Brush and River
  // Location sensitive stat modifier.
}

class ToughSkin extends MasteryEffects {
  ToughSkin(Mob champ, int rank) : super(champ, rank);

  @override
  String get lastUpdate => VERSION_7_2_1;

  // You take 2 less damage from champion and neutral monster basic attacks
  @override
  void damageRecievedModifier(Hit hit, DamageRecievedDelta delta) {
    if (hit.targeting != Targeting.basicAttack) return;
    if (hit.source.isChampion || hit.source.isMonster) delta.flatPhysical -= 2;
  }
}

class Siegemaster {
  // Gain 8 Armor and Magic Resistance when near an allied tower
  // Location sensitive stat modifier.
}

class RunicArmor {
  // Shields, healing, regeneration, and lifesteal on you are R * 1.6% stronger
}

class VeteransScars extends MasteryEffects {
  VeteransScars(Mob champ, int rank) : super(champ, rank);

  @override
  String get lastUpdate => VERSION_7_2_1;

  // +10 * R Health
  @override
  Map<String, num> get stats => {
        FlatHPPoolMod: 10 * rank,
      };
}

class Insight {
  // Reduces the cooldown of Summoner Spells by 15%
  // Source-specific CDR modifier.
}

class Perseverance {
  // +50% Base Health Regen, increased to +200% when below 25% Health
  // health-triggered buff, hp5 modifier?
}

class Fearless {
  // Gain 10% +2 per level bonus Armor and Magic Resist when damaged
  // by an enemy champion for 2 seconds (9s Cooldown)
  // onhit tirggered buff?
}

class Swiftness {
  // +R * 3% Tenacity and Slow Resist
}

class LegendaryGuardian {
  // +R * 0.6 Armor and Magic Resist for each nearby enemy champion
  // Context-sensitve resistances modifer.
}

class GraspoftheUndying {
  // Every 4 seconds in combat, your next attack against an enemy
  // champion deals damage equal to 3% of your max Health and heals
  // you for 1.5% of your max Health (halved for ranged champions, deals magic damage)
  // on-combat-tick buff which applies on-attack effect?
}

class CourageoftheColossus {
  // Gain a shield for 10 +10 per level + 5%  of your maximum health for
  // each nearby enemy champion for 4 seconds after hitting an enemy champion
  // with a stun, taunt, snare, or knock up(45 - 30 second cooldown based on level).
}

class BondofStone {
  // +4% Damage Reduction. 6% of the damage from enemy champions taken by the
  // nearest allied champion is dealt to you instead. Damage is not redirected
  // if you are below 5% of your maximum health.
  // Damage modifier, as well as buff to nearby champ?
}
