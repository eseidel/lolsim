#!/usr/local/bin/dart
import 'package:lol_duel/utils/common_args.dart';
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/dragon/dragon.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:lol_duel/utils/cli_table.dart';
import 'package:lol_duel/utils/dummy_mob.dart';

double calculateDps(Mob mob, {double totalTime = 100.0}) {
  Mob dummy = createDummyMob(hp: 1000.0);
  dummy.shouldRecordDamage = true;
  World world = new World(
    reds: [mob],
    blues: [dummy],
    critProvider: new PredictableCrits(),
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

  _Calculate(Creator creator, this.champName, int level) {
    Mob makeChamp() {
      return creator.champs.championByName(champName)..jumpToLevel(level);
    }

    ItemDescription item(String name) => creator.items.itemByName(name);

    Mob base = makeChamp();
    hasEffects = base.championEffects != null;
    baseDps = calculateDps(base);
    asDps = calculateDps(makeChamp()..addItem(item('Dagger')));
    adDps = calculateDps(makeChamp()..addItem(item('Long Sword')));
  }
}

dynamic main(List<String> args) async {
  handleCommonArgs(args);

  int level = 1;
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
    return new _Calculate(creator, champName, level);
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
