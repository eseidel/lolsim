const String FlatArmorMod = 'FlatArmorMod';
const String FlatCritChanceMod = 'FlatCritChanceMod';
const String FlatHPPoolMod = 'FlatHPPoolMod';
const String FlatHPRegenMod = 'FlatHPRegenMod';
const String FlatMagicDamageMod = 'FlatMagicDamageMod';
const String FlatMagicDamageModPerLevel = 'rFlatMagicDamageModPerLevel';
const String FlatMovementSpeedMod = 'FlatMovementSpeedMod';
const String FlatMPPoolMod = 'FlatMPPoolMod';
const String FlatPhysicalDamageMod = 'FlatPhysicalDamageMod';
const String FlatPhysicalDamageModPerLevel = 'rFlatPhysicalDamageModPerLevel';
const String FlatSpellBlockMod = 'FlatSpellBlockMod';
const String PercentArmorPenetrationMod = 'rPercentArmorPenetrationMod';
const String PercentAttackSpeedMod = 'PercentAttackSpeedMod';
const String PercentLifeStealMod = 'PercentLifeStealMod';
const String PercentMagicPenetrationMod = 'rPercentMagicPenetrationMod';
const String PercentMovementSpeedMod = 'PercentMovementSpeedMod';
const String PercentSpellVampMod = 'PercentSpellVampMod';

class MasteryEffects {
  int rank;
  MasteryEffects(this.rank);

  Map<String, num> get stats => null;
}

typedef MasteryEffects MasteryEffectsConstructor(int rank);

final Map<String, MasteryEffectsConstructor> masteryEffectsConstructors = {
  'Fury': (int rank) => new Fury(rank),
  'Vampirism': (int rank) => new Vampirism(rank),
  'Natural Talent': (int rank) => new NaturalTalent(rank),
  'Battering Blows': (int rank) => new BatteringBlows(rank),
  'Piercing Thoughts': (int rank) => new PiercingThoughts(rank),
  'Recovery': (int rank) => new Recovery(rank),
  'Veterans Scars': (int rank) => new VeteransScars(rank),
};

class Fury extends MasteryEffects {
  Fury(int rank) : super(rank);

  // .8% * rank attack speed
  Map<String, num> get stats => {PercentAttackSpeedMod: .008 * rank};
}

class Sorcery {
  // .4 * R increased Ability damage
  // Some sort of damage modifier?
}

class FreshBlood {
// Your first basic attack against a champion deals an additional 10 +1 per level damage (6 second cooldown)
// damage modifer?
}

class Feast {
// Killing a unit restores 20 Health (30 second cooldown)
// onKill hook.
}

class ExposeWeakness {
// Damaging enemy champions causes them to take 3% more damage from your allies
// buff
}

class Vampirism extends MasteryEffects {
  Vampirism(int rank) : super(rank);

  // .4% * R lifesteal and spell vamp.
  Map<String, num> get stats => {
        PercentLifeStealMod: .004 * rank,
        PercentSpellVampMod: .004 * rank,
      };
}

class NaturalTalent extends MasteryEffects {
  NaturalTalent(int rank) : super(rank);

// Gain 0.4 * R + 0.09 * R per level Attack Damage, and
// 0.6 * R + 0.13 * R per level Ability Power (+2 Attack Damage and 3 Ability Power at level 18)
  Map<String, num> get stats => {
        FlatPhysicalDamageMod: .004 * rank,
        FlatPhysicalDamageModPerLevel: .0009 * rank,
        FlatMagicDamageMod: .006 * rank,
        FlatMagicDamageModPerLevel: .0013 * rank,
      };
}

class BountyHunter {
// Deal 1.5% increased damage for each unique enemy champion you have killed
// buff
}

class DoubleEdgedSword {
// Deal 5% additional damage, take 2.5% additional damage.
// damage modifiers
}

class BattleTrance {
// Gain up to 5% increased damage over 5 seconds when in combat with enemy Champions
}

class BatteringBlows extends MasteryEffects {
  BatteringBlows(int rank) : super(rank);

  // 1.4 * R percent Armor Penetration
  Map<String, num> get stats => {
        PercentArmorPenetrationMod: .014 * rank,
      };
}

class PiercingThoughts extends MasteryEffects {
  PiercingThoughts(int rank) : super(rank);

  // +1.4 * R percent Magic Penetration
  Map<String, num> get stats => {
        PercentMagicPenetrationMod: .014 * rank,
      };
}

class WarlordsBloodlust {
// Gain increasingly more Life Steal based on your missing health
// against champions (up to 20%). Against minions gain 50% benefit (25% for ranged champions).
}

class FervorofBattle {
// Hitting champions with basic attacks generates a Fervor stack (2 for melee attacks).
// Stacks of Fervor last 6 seconds (max 8 stacks)and increase your AD by 1-8 for each stack.
// on-champion-hit triggered buff
}

class DeathfireTouch {
// Your damaging abilities cause enemy champions to take magic damage over 4 seconds.
// Damage: 8 + 60% Bonus Attack Damage and 25% Ability Power
// Deathfire Touch's duration is reduced for:
// - Area of Effect: 2 second duration.
// - Damage over Time: 1 second duration.
}

class Wanderer {
// +0.6% * R percent Movement Speed out of combat
// on-out-of-combat triggered buff?
}

class Savagery {
  // Single target attacks and spells deal 1 * R bonus damage to minions and monsters
  // Target-sensitive flat damage modifier.
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
  // Deal 2% increased damage to champions when no allied champions are nearby
}

class Merciless {
  // Deal 1% * R percent increased damage to champions below 40% Health
  // Damage modifier
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
}

class DangerousGame {
// Champion kills and assists restore 5% of your missing Health and Mana
}

class Precision {
// Gain 1.7 * R Lethality and 0.6 * R + 0.06 * R per level Magic Penetration
// Easy item once I understand leathlity.
}

class Intelligence {
// Your Cooldown Reduction cap is increased by 1% * R and you gain 1% * R Cooldown Reduction
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
  Recovery(int rank) : super(rank);
  // +0.4 * R Health per 5 seconds
  Map<String, num> get stats => {
        FlatHPRegenMod: .4 * rank,
      };
}

class Unyielding {
  // +1% Bonus Armor and Magic Resist
  // Percent resistances modifier.
}

class Explorer {
  // +15 Movement Speed in Brush and River
}

class ToughSkin {
  // You take 2 less damage from champion and neutral monster basic attacks
  // Flat damage modifier.
}

class Siegemaster {
// Gain 8 Armor and Magic Resistance when near an allied tower
}

class RunicArmor {
// Shields, healing, regeneration, and lifesteal on you are R * 1.6% stronger
}

class VeteransScars extends MasteryEffects {
  VeteransScars(int rank) : super(rank);
  // +10 * R Health
  Map<String, num> get stats => {
        FlatHPPoolMod: 10 * rank,
      };
}

class Insight {
// Reduces the cooldown of Summoner Spells by 15%
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