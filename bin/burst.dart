#!/usr/local/bin/dart
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/dragon/spell_parser.dart';
import 'package:lol_duel/utils/dummy_mob.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/utils/cli_table.dart';
import 'package:lol_duel/utils/common_args.dart';

double applyRatio(ScaledValue ratio, int rank, Mob source) {
  int rankIndex = rank - 1;
  switch (ratio.scalingSource) {
    case ScalingSource.attackDamage:
      return ratio.ratioByRank[rankIndex] * source.stats.attackDamage;
    case ScalingSource.bonusAttackDamage:
      return ratio.ratioByRank[rankIndex] * source.stats.bonusAttackDamage;
    case ScalingSource.spellPower:
      return ratio.ratioByRank[rankIndex] * source.stats.abilityPower;
    case ScalingSource.armor:
      return ratio.ratioByRank[rankIndex] * source.stats.armor;
    case ScalingSource.bonusHealth: // FIXME: bonus vs. base
      return ratio.ratioByRank[rankIndex] * source.stats.hp;
    case ScalingSource.bonusSpellBlock: // FIXME: bonus vs. base
      return ratio.ratioByRank[rankIndex] * source.stats.spellBlock;
  }
  return null;
}

void applySpell(SpellDescription spell, int rank, Mob source, Mob target) {
  if (rank < 1) return;
  double physicalDamage = 0.0;
  double magicDamage = 0.0;
  double trueDamage = 0.0;
  int rankIndex = rank - 1;
  for (DamageEffect effect in spell.damageEffects) {
    // print('${effect.base} ${effect.adRatio} ${source.stats.attackDamage} '
    //     '${effect.apRatio} ${source.stats.abilityPower}');
    double damage = effect.baseByRank[rankIndex].toDouble();
    for (ScaledValue ratio in effect.ratios)
      damage += applyRatio(ratio, rank, source);
    physicalDamage += (effect.damageType == DamageType.physical) ? damage : 0.0;
    magicDamage += (effect.damageType == DamageType.magic) ? damage : 0.0;
    trueDamage += (effect.damageType == DamageType.trueDamage) ? damage : 0.0;
  }

  target.applyHit(new Hit(
    source: source,
    target: target,
    label: spell.name,
    physicalDamage: physicalDamage,
    magicDamage: magicDamage,
    trueDamage: trueDamage,
    // FIXME: Not all spells are single-target.
    targeting: Targeting.singleTargetSpell,
  ));
}

double burstDamage(Mob champ, SpellDescriptionBook spells, AbilityRanks ranks) {
  Mob dummy = createDummyMob();
  dummy.shouldRecordDamage = true;

  World world = new World();
  new AutoAttack(champ, dummy).apply(world);
  applySpell(spells.q, ranks.q, champ, dummy);
  applySpell(spells.e, ranks.e, champ, dummy);
  applySpell(spells.w, ranks.w, champ, dummy);
  applySpell(spells.r, ranks.r, champ, dummy);

  // print(dummy.damageLog.summaryString);
  return dummy.damageLog.totalDamage;
}

String abilitiesString(
    Mob champ, SpellDescriptionBook book, AbilityRanks ranks) {
  String keyChar(SpellDescription spell, int rank) {
    if (spell.parseError != null) return '*';
    if (spell.doesDamage && rank > 0) return spell.key.toString();
    return ' ';
  }

  return (champ.championEffects != null ? 'P' : ' ') +
      keyChar(book.q, ranks.q) +
      keyChar(book.w, ranks.w) +
      keyChar(book.e, ranks.e) +
      keyChar(book.r, ranks.r);
}

class _Result {
  String champName;
  double burst;
  String abilitiesString;
  double burstAdRatio;
  double burstBonusAdRatio;
  double burstApRatio;
}

double sumOfDamageRatios(
    SpellDescriptionBook book, ScalingSource source, AbilityRanks ranks) {
  double sum = 0.0;
  void addFrom(SpellDescription spell, int rank) {
    if (!spell.doesDamage || rank < 1) return;
    sum += spell.sumOfRatios(source, rank);
  }

  addFrom(book.q, ranks.q);
  addFrom(book.w, ranks.w);
  addFrom(book.e, ranks.e);
  addFrom(book.r, ranks.r);
  return sum;
}

dynamic main(List<String> args) async {
  handleCommonArgs(args);
  Creator creator = await Creator.loadLatest();
  SpellLibrary spells = await SpellLibrary.load();
  AbilityRanks ranks = new AbilityRanks(q: 1, w: 1, e: 1);
  int level = 3;

  // Mob champ = creator.champs.championByName('Pantheon');
  // SpellBook spellBook = spells.bookForChampionName('Pantheon');
  // print(burstDamage(champ, spellBook));

  TableLayout layout = new TableLayout([6, 13, 6, 8, 8, 8]);
  layout.printRow([
    'Skills',
    'Name',
    'Burst',
    'AP Ratio',
    'AD Ratio',
    'Bonus AD Ratio',
  ]);
  layout.printDivider();

  List<String> champNames = creator.dragon.champs.loadChampNames();
  List<_Result> results = champNames.map((champName) {
    Mob champ = creator.champs.championByName(champName);
    champ.level = level;
    champ.updateStats();

    SpellDescriptionBook spellBook = spells.bookForChampionName(champName);
    return new _Result()
      ..abilitiesString = abilitiesString(champ, spellBook, ranks)
      ..burst = burstDamage(champ, spellBook, ranks)
      ..champName = champName
      ..burstAdRatio =
          sumOfDamageRatios(spellBook, ScalingSource.attackDamage, ranks)
      ..burstBonusAdRatio =
          sumOfDamageRatios(spellBook, ScalingSource.bonusAttackDamage, ranks)
      ..burstApRatio =
          sumOfDamageRatios(spellBook, ScalingSource.spellPower, ranks);
  }).toList();
  results.sort((a, b) => a.burst.compareTo(b.burst));

  String emptyIfZero(double value) {
    return value == 0.0 ? '' : value.toStringAsFixed(1);
  }

  for (_Result result in results) {
    layout.printRow([
      result.abilitiesString,
      result.champName,
      result.burst.toStringAsFixed(1),
      emptyIfZero(result.burstApRatio),
      emptyIfZero(result.burstAdRatio),
      emptyIfZero(result.burstBonusAdRatio),
    ]);
  }

  // All champs at lvl 3, full hp, full mana.
  // cycle through all known damaging abilities and a single auto attack?

  // A more sophisticated version would run for 3s and would include
  // AAs and likely need some sort of planning:
  // -- knows how to apply damage, based on scaling and set a cooldown.
  // - Default plan just AAs
  // - Burst plan does rotations on cooldown.
}
