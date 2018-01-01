import 'effects.dart';
import 'mob.dart';

typedef RuneEffectsConstructor = RuneEffects Function(Mob champ);

final Map<String, RuneEffectsConstructor> RuneEffectsConstructors = {
  'Electrocute': (Mob champ) => new Electrocute(champ),
};

String shortNameForRune(String name) {
  String shortName = {
    'Grasp of the Undying': 'Grasp',
    'Arcane Comet': 'Comet',
    'Press the Attack': 'PtA',
    'Electrocute': 'Elec.',
  }[name];
  return shortName == null ? name : shortName;
}

class Electrocute extends RuneEffects {
  Electrocute(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Hitting a champion with 3 separate attacks or abilities within
  // @WindowDuration@s deals bonus adaptive damage.
  //
  // Damage: @DamageBase@ - @DamageMax@ (+@BonusADRatio.-1@ bonus AD,
  // +@APRatio.-1@ AP) damage.
  //
  // Cooldown: @Cooldown@ - @CooldownMin@s
  //
  // 'We called them the Thunderlords, for to speak of their lightning was to
  // invite disaster.'
}

class Predator extends RuneEffects {
  Predator(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Enchants your boots with the active effect
  // '{{perk_displayname_KSLycanthropy}}.'
  //
  // {{ game_itemmod_bloodmoonboots }}
}

class DarkHarvest extends RuneEffects {
  DarkHarvest(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Champions, large minions, and large monsters drop soul essence on death.
  // Collect souls to become Soul Charged. Your next attack on a champion or
  // structure consumes Soul Charged to deal bonus adaptive damage.
  //
  //
  // Soul Charged lasts @ONHDuration@s, increased to @ONHDurationLong@s after
  // collecting @SoulsRequiredForIncreasedDuration@ soul essence.
  //
  // Bonus damage: @DamageMin@ - @DamageMax@ (+@ADRatio.2@ bonus AD)
  // (+@APRatio.1@ AP) + soul essence collected.
  //
  // Champions - @champstacks@ soul essence.
  // Monsters - @monsterstacks@ soul essence.
  // Minions - @minionstacks@ soul essence.
}

class CheapShot extends RuneEffects {
  CheapShot(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Damaging champions with impaired movement or actions deals @DamageIncMin@
  // - @DamageIncMax@ bonus true damage (based on level).
  //
  // Cooldown: @Cooldown@s
  // Activates on damage occurring after the impairment.
}

class TasteofBlood extends RuneEffects {
  TasteofBlood(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Heal when you damage an enemy champion.
  //
  // Healing: @HealAmount@-@HealAmountMax@ (+@ADRatio.-1@ bonus AD,
  // +@APRatio.-1@ AP) health (based on level)
  //
  // Cooldown: @Cooldown@s
}

class SuddenImpact extends RuneEffects {
  SuddenImpact(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // After exiting stealth or using a dash, leap, blink, or teleport, dealing
  // any damage to a champion grants you @BonusLethality.0@ Lethality and
  // @BonusMpen.0@ Magic Penetration for @Duration@s.
  //
  // Cooldown: @Cooldown@s
}

class ZombieWard extends RuneEffects {
  ZombieWard(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // After killing a ward, a friendly Zombie Ward is raised in its place.
  // Additionally, when your wards expire, they reanimate as Zombie Wards.
  //
  //
  // Zombie Wards are visible, last for @WardDuration@s and don't count towards
  // your ward limit.
}

class GhostPoro extends RuneEffects {
  GhostPoro(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Enter a brush to summon a poro after a brief channel. The poro will stay
  // behind to give you vision until you summon a new one.
  //
  // If an enemy enters brush with a poro in it, they scare it away, putting {{
  // perk_displayname_ViciousPoro }} on a @Cooldown@s cooldown.
  //
  // Poro channel is interrupted if you take damage.
}

class EyeballCollection extends RuneEffects {
  EyeballCollection(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Collect eyeballs for champion and ward takedowns. Gain {{
  // perk_subtext_AdaptiveForce }}, per eyeball collected.
  //
  // Upon completing your collection at @MaxEyeballs@ eyeballs, additionally
  // gain {{ perk_subtext_AdaptiveForce_EyeballCollection }}.
  //
  // Collect @StacksPerTakedown@ eyeballs per champion kill, @StacksPerAssist@
  // per assist, and @StacksPerWard@ per ward takedown.
}

class RavenousHunter extends RuneEffects {
  RavenousHunter(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Heal for a percentage of the damage dealt by your abilities.
  // Healing: @StartingOmnivamp*100@% + @OmnivampPerStack*100@% per Bounty
  // Hunter stack.
  //
  // Earn a Bounty Hunter stack the first time you get a takedown on each enemy
  // champion.
  //
  // Healing reduced to one third for Area of Effect abilities.
  //
}

class IngeniousHunter extends RuneEffects {
  IngeniousHunter(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Gain @StartingActiveItemCDR.0*100@% Active Item CDR plus an additional
  // @ActiveItemCDRPerStack.0*100@% per Bounty Hunter stack (includes
  // Trinkets).
  //
  // Earn a Bounty Hunter stack the first time you get a takedown on each enemy
  // champion.
}

class RelentlessHunter extends RuneEffects {
  RelentlessHunter(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Gain @StartingOOCMS@ out of combat Movement Speed plus @OOCMS.0@ per
  // Bounty Hunter stack.
  //
  // Earn a Bounty Hunter stack the first time you get a takedown on each enemy
  // champion.
}

class UnsealedSpellbook extends RuneEffects {
  UnsealedSpellbook(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Gain a Summoner Shard at @ShardFirstMinutes@ min and another every
  // @ShardRechargeMinutes@ min after (Max @Maxshards@ shards).
  //
  // While near the shop, you can exchange @ShardCost@ Summoner Shard to
  // replace a Summoner Spell with a different one.
  //
  // Additionally, your Summoner Spell Cooldowns are reduced by
  // @SummonerCDR.0*100@%.
  //
  // Smite: Buying Smite won't grant access to Smite items
  // You cannot have two of the same Summoner Spell
}

class GlacialAugment extends RuneEffects {
  GlacialAugment(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Basic attacking a champion slows them for @SlowDuration.0@s. The slow
  // increases in strength over its duration.
  // Ranged: Ranged attacks slow by up to @SlowAmountBase.0*-100@% -
  // @SlowAmountMax.0*-100@%
  // Melee: Melee attacks slow by up to @SlowAmountBaseMelee.0*-100@% -
  // @SlowAmountMaxMelee.0*-100@%
  // Slowing a champion with active items shoots a freeze ray through them,
  // freezing the nearby ground for @SlowZoneDuration@s, slowing all units
  // inside by @SlowZoneSlow*-100@%.
  //
  // Cooldown: @UnitCDBase@-@UnitCD16@s per unit
}

class Kleptomancy extends RuneEffects {
  Kleptomancy(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // After using an ability, your next attack will grant bonus gold if used on
  // a champion. There's a chance you'll also gain a consumable.
}

class HextechFlashtraption extends RuneEffects {
  HextechFlashtraption(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // While Flash is on cooldown it is replaced by Hexflash.
  //
  // Hexflash: Channel for @ChannelDuration@s to blink to a new location.
  //
  //
  // Cooldown: @CooldownTime@s. Goes on a @ChampionCombatCooldown@s cooldown
  // when you enter champion combat.
}

class BiscuitDelivery extends RuneEffects {
  BiscuitDelivery(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Biscuit Delivery: Gain a {{game_item_displayname_2010}} every
  // @BiscuitMinuteInterval@ mins, until @SwapOverMinute@ min.
  //
  // Biscuits restore @HealthHealPercent.0*100@% of your missing health and
  // mana. Consuming any Biscuit increases your mana cap by @PermanentMana@
  // mana permanently.
  //
  // Manaless: Champions without mana restore
  // @HealthHealPercentManaless.0*100@% missing health instead.
}

class PerfectTiming extends RuneEffects {
  PerfectTiming(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Start the game with a {{ game_item_displayname_2419 }} that transforms
  // into a {{ game_item_displayname_2420 }} after @InitialCooldown.0@ min. {{
  // game_item_displayname_2420 }} has a one time use Stasis effect.
  //
  //
  // Reduces the cooldown of {{ game_item_displayname_3157 }}, {{
  // game_item_displayname_3026 }}, and {{ game_item_displayname_3193 }} by
  // @PercentGAZhonyasCDR.0*100@%.
}

class MagicalFootwear extends RuneEffects {
  MagicalFootwear(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // You get free {{game_item_displayname_2422}} at @GiveBootsAtMinute@ min,
  // but you cannot buy boots before then. For each takedown you acquire the
  // boots @SecondsSoonerPerTakedown@s sooner.
  //
  // {{game_item_displayname_2422}} give you an additional
  // +@AdditionalMovementSpeed@ Movement Speed and upgrade for 50 gold less.
}

class FuturesMarket extends RuneEffects {
  FuturesMarket(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // You can enter debt to buy items. The amount you can borrow increases over
  // time.
  //
  // Lending Fee: @ExcessCostPenaltyFlat@ gold
}

class MinionDematerializer extends RuneEffects {
  MinionDematerializer(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Start the game with @GainedMinionKillers@ {{game_item_displayname_2403}}s
  // that kill and absorb lane minions instantly.
  // {{game_item_displayname_2403}}s are on cooldown for the first
  // @InitialCooldown@s of the game.
  //
  // Absorbing a minion increases your damage by
  // +@DamageBonusForAnyAbsorbed.0*100@% against that type of minion
  // permanently, and an extra +@DamageBonusPerAdditionalAbsorbed.0*100@% for
  // each additional minion of that type absorbed.
  //
}

class CosmicInsight extends RuneEffects {
  CosmicInsight(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // +@CDR*100@% CDR
  // +@CDR*100@% Max CDR
  // +@CDR*100@% Summoner Spell CDR
  // +@CDR*100@% Item CDR
}

class ApproachVelocity extends RuneEffects {
  ApproachVelocity(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Gain @MovementSpeedPercentBonus.0*100@% Movement Speed towards nearby ally
  // champions that are movement impaired or enemy champions that you impair.
  //
  //
  // Range: @ActivationDistance@
}

class CelestialBody extends RuneEffects {
  CelestialBody(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // +@HealthBonus@ Health permanently
  // -@ChampionDamagePenalty*100@% damage to champions and monsters until
  // @EndTime@ min
  //
  //
  // 'The greatest legends live on in the stars.'
  // âDaphna the Dreamer
}

class PresstheAttack extends RuneEffects {
  PresstheAttack(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Hitting an enemy champion with @HitsRequired@ consecutive basic attacks
  // deals @MinDamage@ - @MaxDamage@ bonus adaptive damage (based on level) and
  // makes them vulnerable, increasing the damage they take by
  // @AmpPotencySelf.0*100@% from all sources for @AmpDuration@s.
}

class LethalTempo extends RuneEffects {
  LethalTempo(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // @LeadInDelay.1@s after damaging a champion gain @AttackSpeedMin*100@ -
  // @AttackSpeedMax*100@% Attack Speed (based on level) for
  // @AttackSpeedBuffDurationMin@s. Attacking a champion extends the effect to
  // @AttackSpeedBuffDurationMax@s.
  //
  // Cooldown: @Cooldown@s
  //
  // {{perk_displayname_FlowofBattle}} allows you to temporarily exceed the
  // attack speed limit.
}

class FleetFootwork extends RuneEffects {
  FleetFootwork(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Attacking and moving builds Energy stacks. At 100 stacks, your next attack
  // is Energized.
  //
  // Energized attacks heal you for @HealBase@ - @HealMax@
  // (+@HealBonusADRatio.-1@ Bonus AD, +@HealAPRatio.-1@ AP) and grant
  // +@MSBuff*100@% movement speed for @MSDuration.0@s.
  // Healing is @MinionHealMod*100@% as effective when used on a minion.
  //
  // Healing is increased by @HealCritMod*100@% of your critical damage
  // modifier when triggered by a critical hit.
}

class Overheal extends RuneEffects {
  Overheal(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Excess healing on you becomes a shield, for up to @ShieldCapRatio.0*100@%
  // of your total health + @MaxBaseShieldCap@.
  //
  // Shield is built up from @ShieldGenerationRateSelf.0*100@% of excess
  // self-healing, or @ShieldGenerationRateOtherMax.0*100@% of excess healing
  // from allies.
}

class Triumph extends RuneEffects {
  Triumph(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Takedowns restore @MissingHealthRestored.0*100@% of your missing health
  // and grant an additional @BonusGold@ gold.
  //
  //
  // 'The most dangerous game brings the greatest glory.'
  // âNoxian Reckoner
}

class PresenceofMind extends RuneEffects {
  PresenceofMind(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // For @BuffDuration@s after gaining a level or takedown any mana you spend
  // is fully restored.
}

class LegendAlacrity extends RuneEffects {
  LegendAlacrity(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Gain @AttackSpeedBase*100@% attack speed plus an additional
  // @AttackSpeedPerStack*100@% for every Legend stack (max @MaxLegendStacks@
  // stacks).
  //
  // Earn progress toward Legend stacks for every champion takedown, epic
  // monster takedown, large monster kill, and minion kill.
}

class LegendTenacity extends RuneEffects {
  LegendTenacity(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Gain @TenacityBase*100@% tenacity plus an additional
  // @TenacityPerStack*100@% for every Legend stack (max @MaxLegendStacks@
  // stacks).
  //
  // Earn progress toward Legend stacks for every champion takedown, epic
  // monster takedown, large monster kill, and minion kill.
}

class LegendBloodline extends RuneEffects {
  LegendBloodline(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Gain @LifeStealPerStack*100@% life steal for every Legend stack (max
  // @MaxLegendStacks@ stacks).
  //
  // Earn progress toward Legend stacks for every champion takedown, epic
  // monster takedown, large monster kill, and minion kill.
}

class CoupdeGrace extends RuneEffects {
  CoupdeGrace(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Deal @BonusPercentDamage.0 *100@% more damage to champions who have less
  // than @EnemyHealthPercentageThreshold*100@% health.
  //
  // Additionally, takedowns on champions grant {{ perk_subtext_AdaptiveForce
  // }} for @Duration@s.
}

class CutDown extends RuneEffects {
  CutDown(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Deal @MinBonusDamagePercent.0*100@% more damage to champions with
  // @MinHealthDifference@ more max health than you, increasing to
  // @MaxBonusDamagePercent.0*100@% at @MaxHealthDifference@ more max health.
}

class LastStand extends RuneEffects {
  LastStand(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Deal @MinBonusDamagePercent.0*100@% - @MaxBonusDamagePercent.0*100@%
  // increased damage to champions while you are below
  // @HealthThresholdStart.0*100@% health. Max damage gained at
  // @HealthThresholdEnd.0*100@% health.
}

class GraspoftheUndying extends RuneEffects {
  GraspoftheUndying(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Every @TriggerTime@s in combat, your next basic attack on a champion will:
  //
  // Deal bonus magic damage equal to @PercentHealthDamage.0@% of your max
  // health
  // Heal you for @PercentHealthHeal*100@% of your max health
  // Permanently increase your health by @MaxHealthPerProc@
  // Ranged Champions: Damage and healing are halved and gain
  // @RangedHealthPerProc@ permanent health instead.
}

class Aftershock extends RuneEffects {
  Aftershock(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // After immobilizing an enemy champion, increase your Armor and Magic Resist
  // by @FlatResists@ + @ResistInc.0*100@% for @DelayBeforeBurst.1@s. Then
  // explode, dealing magic damage to nearby enemies.
  //
  // Damage: @StartingBaseDamage@ - @MaxBaseDamage@ (+@HealthRatio.1@% of your
  // maximum health)
  // Cooldown: @Cooldown@s
}

class Guardian extends RuneEffects {
  Guardian(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // {{ perk_shared_desc_KSBuddyShield }}
  //
  // Cooldown: @Cooldown@s
  // Shield: @ShieldBase@ - @ShieldMax@ +(@APRatio.-1@ AP) + (+@HPRatio.0*100@%
  // bonus health).
  // Haste: +@Haste*100@% Movement Speed.
}

class Unflinching extends RuneEffects {
  Unflinching(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // After casting a Summoner Spell, gain @BonusTenacity*100@% Tenacity and
  // Slow Resistance for @BuffDuration@s. Additionally, gain
  // @PersistTenacity*100@% Tenacity and Slow Resistance for each Summoner
  // Spell on cooldown.
}

class Demolish extends RuneEffects {
  Demolish(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Charge up a powerful attack against a tower over @TotalSiegeTime@s, while
  // within @DistanceToTower@ range of it. The charged attack deals
  // @OutputDamagePerStack@ (+@MaxHealthPercentDamage.0 * 100@% of your max
  // health) bonus physical damage.
  //
  // Cooldown: @CooldownSeconds@s
}

class FontofLife extends RuneEffects {
  FontofLife(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Impairing the movement of an enemy champion marks them for
  // @MarkDuration@s.
  //
  // Ally champions who attack marked enemies heal for @FlatHealAmount@ +
  // @HealthRatio.-1 * 100@% of your max health over @HealDuration@s.
}

class IronSkin extends RuneEffects {
  IronSkin(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Gain +@ArmorBase@ Armor.
  //
  // Heal effects from consumables, heals for at least @FlatHealThreshold@
  // health and shields increase your Armor by @TotalExtraArmor*100@% for
  // @EvolveArmorDuration@s.
}

class MirrorShell extends RuneEffects {
  MirrorShell(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Gain +@MRBase@ Magic Resist.
  //
  // Heal effects from consumables, heals for at least @FlatHealThreshold@
  // health and shields increase your Magic Resist by @EvolveBonusMR*100@% for
  // @EvolveShellDuration@s.
}

class Conditioning extends RuneEffects {
  Conditioning(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // {{ perk_short_desc_NemFighter }}
}

class Overgrowth extends RuneEffects {
  Overgrowth(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Permanently gain @MaxHealthRatioPerTier*100@% maximum health for every
  // @UnitsPerTier@ monsters or enemy minions that die near you.
}

class Revitalize extends RuneEffects {
  Revitalize(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Heals and shields you cast or receive are @StandardAmp.0@% stronger and
  // increased by an additional @ExtraAmp.0@% on targets below
  // @HealthCutoff.0@% health.
}

class SecondWind extends RuneEffects {
  SecondWind(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // After taking damage from an enemy champion, heal for
  // @RegenPercentMax.0*100@% of your missing health +@RegenFlat.0@ over
  // @RegenSeconds@s.
}

class SummonAery extends RuneEffects {
  SummonAery(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Your attacks and abilities send Aery to a target, damaging enemy champions
  // or shielding allies.
  //
  // Damage: @DamageBase@ - @DamageMax@ based on level (+@DamageAPRatio.-1@ AP
  // and +@DamageADRatio.-1@ bonus AD)
  // Shield: @ShieldBase@ - @ShieldMax@ based on level (+@ShieldRatio.-1@ AP
  // and +@ShieldRatioAD.-1@ bonus AD)
  //
  // Aery cannot be sent out again until she returns to you.
}

class ArcaneComet extends RuneEffects {
  ArcaneComet(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Damaging a champion with an ability hurls a comet at their location, or,
  // if Arcane Comet is on cooldown, reduces its remaining cooldown.
  //
  //
  // Adaptive Damage: @DamageBase@ - @DamageMax@ based on level (+@APRatio.-1@
  // AP and +@ADRatio.-1@ bonus AD)
  // Cooldown: @RechargeTime@ - @RechargeTimeMin@s
  //
  // Cooldown Reduction:
  // Single Target: @PercentRefund*100@%.
  // Area of Effect: @AoEPercentRefund*100@%.
  // Damage over Time: @DotPercentRefund*100@%.
  //
}

class PhaseRush extends RuneEffects {
  PhaseRush(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Hitting an enemy champion with 3 attacks or separate abilities within
  // @Window@s grants @HasteBase*100@ - @HasteMax*100@% Movement Speed based on
  // level and @SlowResist*100@% Slow Resistance.
  //
  // Duration: @Duration@s
  // Cooldown: @Cooldown@s
}

class NullifyingOrb extends RuneEffects {
  NullifyingOrb(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // When you take magic damage that would reduce your Health below
  // @PercHealthTrigger.0*100@%, gain a shield that absorbs @ShieldMin@ -
  // @ShieldMax@ magic damage based on level (+@APRatio.-1@ AP and
  // +@ADRatio.-1@ bonus AD) for @ShieldDuration@s.
  //
  // Cooldown: @Cooldown@s
}

class ManaflowBand extends RuneEffects {
  ManaflowBand(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Every @Cooldown.0@s, your next ability used has its mana or energy cost
  // refunded, and restores @MPToRestoreRatio.0*100@% of your missing mana or
  // energy.
}

class TheUltimateHat extends RuneEffects {
  TheUltimateHat(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Your ultimate's cooldown is reduced by @StartingCDR@%. Each time you cast
  // your ultimate, its cooldown is further reduced by @CDChunkPerStack@%.
  // Stacks up to @MaxStacks@ times.
}

class Transcendence extends RuneEffects {
  Transcendence(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Gain @MaxCDR*100@% CDR when you reach level @LevelToTurnOn@.
  //
  // Each percent of CDR exceeding the CDR limit is converted to {{
  // perk_subtext_AdaptiveForce }}.
}

class Celerity extends RuneEffects {
  Celerity(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Gain @PercentMS.0@% increased Movement Speed and add
  // @PercentOfMOvespeedAsPrimaryStat.0@% of your Bonus Movement Speed to your
  // AP or AD, adaptive.
}

class AbsoluteFocus extends RuneEffects {
  AbsoluteFocus(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // While above @HealthPercent*100@% health, gain {{
  // perk_subtext_AdaptiveForce_Max }} (based on level).
}

class Scorch extends RuneEffects {
  Scorch(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Your next ability hit sets champions on fire dealing @damage@ -
  // @damagemax@ bonus magic damage based on level after @dotduration@s.
  //
  //
  // Cooldown: @BurnlockoutDuration@s
}

class Waterwalking extends RuneEffects {
  Waterwalking(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Gain @MovementSpeed@ Movement Speed and {{ perk_subtext_AdaptiveForce_Max
  // }} (based on level) when in the river.
  //
  //
  // May you be as swift as the rushing river and agile as a startled Rift
  // Scuttler.
  //
}

class GatheringStorm extends RuneEffects {
  GatheringStorm(Mob champ) : super(champ);

  @override
  String get lastUpdate => VERSION_7_24_1;

  // Every @UpdateAfterMinutes@ min gain AP or AD, adaptive.
  //
  // 10 min: + 8 AP or 5 AD
  // 20 min: + 24 AP or 14 AD
  // 30 min: + 48 AP or 29 AD
  // 40 min: + 80 AP or 48 AD
  // 50 min: + 120 AP or 72 AD
  // 60 min: + 168 AP or 101 AD
  // etc...
}
