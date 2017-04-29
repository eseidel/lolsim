#!/usr/local/bin/dart
import 'package:lol_duel/cli_table.dart';
import 'package:lol_duel/common_args.dart';
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/dummy_mob.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/spell_parser.dart';

double applyRatio(ScaledValue ratio, int rank, Mob source) {
  switch (ratio.scalingSource) {
    case ScalingSource.attackDamage:
    case ScalingSource.bonusAttackDamage: // FIXME: bonus vs. base
      return ratio.ratioByRank[rank] * source.stats.attackDamage;
    case ScalingSource.spellPower:
      return ratio.ratioByRank[rank] * source.stats.abilityPower;
    case ScalingSource.armor:
      return ratio.ratioByRank[rank] * source.stats.armor;
    case ScalingSource.bonusHealth: // FIXME: bonus vs. base
      return ratio.ratioByRank[rank] * source.stats.hp;
    case ScalingSource.bonusSpellBlock: // FIXME: bonus vs. base
      return ratio.ratioByRank[rank] * source.stats.spellBlock;
  }
  return null;
}

void applySpell(Spell spell, Mob source, Mob target, int rank) {
  double physicalDamage = 0.0;
  double magicDamage = 0.0;
  double trueDamage = 0.0;
  for (DamageEffect effect in spell.damageEffects) {
    // print('${effect.base} ${effect.adRatio} ${source.stats.attackDamage} '
    //     '${effect.apRatio} ${source.stats.abilityPower}');
    double damage = effect.baseByRank[rank].toDouble();
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
  ));
}

double burstDamage(Mob champ, SpellBook spells) {
  champ.level = 3;
  champ.updateStats();
  Mob dummy = createDummyMob();
  dummy.shouldRecordDamage = true;

  World world = new World();
  new AutoAttack(champ, dummy).apply(world);
  int rank = 1; // HACK
  applySpell(spells.q, champ, dummy, rank);
  applySpell(spells.e, champ, dummy, rank);
  applySpell(spells.w, champ, dummy, rank);

  // print(dummy.damageLog.summaryString);
  return dummy.damageLog.totalDamage;
}

String abilitiesString(Mob champ, SpellBook book) {
  String keyChar(Spell spell, String char) {
    if (spell.parseError) return '*';
    if (spell.doesDamage) return char;
    return ' ';
  }

  return (champ.effects != null ? 'P' : ' ') +
      keyChar(book.q, 'Q') +
      keyChar(book.w, 'W') +
      keyChar(book.e, 'E');
}

class _Result {
  String champName;
  double burst;
  String abilitiesString;
}

dynamic main(List<String> args) async {
  handleCommonArgs(args);
  Creator creator = await Creator.loadLatest();
  SpellFactory spells = await SpellFactory.load();

  // Mob champ = creator.champs.championByName('Pantheon');
  // SpellBook spellBook = spells.bookForChampionName('Pantheon');
  // print(burstDamage(champ, spellBook));

  TableLayout layout = new TableLayout([10, 13, 6]);
  layout.printRow(['Abilities', 'Name', 'Burst']);
  layout.printDivider();

  List<String> champNames = creator.dragon.champs.loadChampNames();
  List<_Result> results = champNames.map((champName) {
    Mob champ = creator.champs.championByName(champName);
    SpellBook spellBook = spells.bookForChampionName(champName);
    return new _Result()
      ..abilitiesString = abilitiesString(champ, spellBook)
      ..burst = burstDamage(champ, spellBook)
      ..champName = champName;
  }).toList();
  results.sort((a, b) => a.burst.compareTo(b.burst));
  for (_Result result in results) {
    layout.printRow([
      result.abilitiesString,
      result.champName,
      result.burst.toStringAsFixed(1)
    ]);
  }

  // All champs at lvl 3, full hp, full mana.
  // cycle through all known damaging abilities and a single auto attack?

  // A more sophisticated version would run for 3s and would include
  // AAs and likely need some sort of planning:
  // - json-based default ability approximation
  // -- knows how to apply damage, based on scaling and set a cooldown.
  // - Default plan just AAs
  // - Burst plan does rotations on cooldown.
}
