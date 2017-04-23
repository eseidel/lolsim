#!/usr/local/bin/dart
import 'package:lol_duel/common_args.dart';
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/dragon.dart';
import 'package:lol_duel/cli_table.dart';

// Level 1
// All Champs
// vs champ, 10k health
// no items
// 10s, stop, divide

Mob createDummy() {
  Mob mob = new Mob(
    new MobDescription(
      name: 'Dummy',
      baseStats: new BaseStats(
        armor: 0.0,
        armorPerLevel: 0.0,
        attackDamage: 0.0,
        attackDamagePerLevel: 0.0,
        attackSpeedPerLevel: 0.0,
        attackDelay: 0.0,
        hp: 1000.0,
        hpPerLevel: 0.0,
        hpRegen: 1000.0,
        hpRegenPerLevel: 0.0,
        mp: 0.0,
        mpPerLevel: 0.0,
        spellBlock: 0.0,
        spellBlockPerLevel: 0.0,
      ),
    ),
    MobType.champion,
  );
  mob.updateStats();
  return mob;
}

double calculateDps(Mob mob, {double totalTime = 100.0}) {
  Mob dummy = createDummy();
  dummy.shouldRecordDamage = true;
  World world = new World(
    reds: [mob],
    blues: [dummy],
    critProvider: new PredictableCrits([mob.id, dummy.id]),
  );
  world.tickUntil((World world) {
    return world.time >= totalTime;
  });
  return dummy.damageLog.totalDamage / totalTime;
}

class _Calculate {
  String champName;
  bool hasEffects;
  double baseDps;
  double asDps;
  double adDps;

  _Calculate(Creator creator, this.champName) {
    Mob base = creator.champs.championByName(champName);
    hasEffects = base.effects != null;
    baseDps = calculateDps(base);
    Mob withAs = creator.champs.championByName(champName)
      ..addItem(creator.items.itemByName('Dagger'));
    asDps = calculateDps(withAs);
    Mob withAd = creator.champs.championByName(champName)
      ..addItem(creator.items.itemByName('Long Sword'));
    adDps = calculateDps(withAd);
  }
}

dynamic main(List<String> args) async {
  handleCommonArgs(args);

  Creator creator = await Creator.loadLatest();
  creator.items.itemByName('Dagger'); // Get warnings over with.

  // List<String> champNames = creator.dragon.champs.loadChampNames();
  // for (String champName in champNames) {
  //   Mob champ = creator.champs.championByName(champName);
  //   double dps = calculateDps(champ);
  //   print("${champ.name} dps: ${dps.toStringAsFixed(2)}");
  // }
  List<String> champNames = creator.dragon.champs.loadChampNames();
  List<_Calculate> results = champNames.map((champName) {
    return new _Calculate(creator, champName);
  }).toList();
  results.sort((a, b) => a.baseDps.compareTo(b.baseDps));

  TableLayout layout = new TableLayout([1, 13, 6, 15, 15]);
  layout.printRow(['P', 'Name', 'DPS', '+15% AS', '+10 AD']);
  layout.printDivider();

  String _withPercentFrom(double baseline, double actual) {
    double change = (actual - baseline) / baseline;
    return "${actual.toStringAsFixed(2)} (${(100 * change).toStringAsFixed(1)}%)";
  }

  for (var r in results) {
    layout.printRow([
      r.hasEffects ? '*' : ' ',
      r.champName,
      r.baseDps.toStringAsFixed(2),
      _withPercentFrom(r.baseDps, r.asDps),
      _withPercentFrom(r.baseDps, r.adDps)
    ]);
  }
}
