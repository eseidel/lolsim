import 'package:logging/logging.dart';
import 'package:lol_duel/common_args.dart';
import 'package:lol_duel/dragon.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:trotter/trotter.dart';
import 'package:lol_duel/champions.dart';

int champCompare(Mob red, Mob blue) {
  World world = new World(
    reds: [red],
    blues: [blue],
    critProvider: new PredictableCrits([blue.id, red.id]),
  );
  world.tickUntil(World.oneSideDies);
  return blue.currentHp.floor() - red.currentHp.floor();
}

class ChampResults implements Comparable<ChampResults> {
  final String champId;
  int victories = 0;
  ChampResults(this.champId);

  bool get hasEffects => championEffectsConstructors[champId] != null;

  void recordVictory() {
    victories += 1;
  }

  int compareTo(ChampResults b) => victories.compareTo(b.victories);
}

class TableLayout {
  List<int> columnWidths;
  TableLayout(this.columnWidths);

  void printRow(List<String> cells) {
    assert(cells.length == columnWidths.length);
    List<String> paddedCells = [];
    for (int i = 0; i < cells.length; i += 1) {
      paddedCells.add(cells[i].padRight(columnWidths[i]));
    }
    print(paddedCells.join(' '));
  }

  void printDivider() {
    int width = columnWidths.reduce((a, b) => a + b) + columnWidths.length - 1;
    print('=' * width);
  }
}

main(List<String> args) async {
  handleCommonArgs(args);
  Logger.root.level = Level.WARNING;
  DragonData data = await DragonData.loadLatest();
  List<String> champIds = data.champs.loadChampIds();
  Map<String, ChampResults> resultsById = {};
  champIds.forEach((id) => resultsById[id] = new ChampResults(id));
  Combinations combos = new Combinations(2, champIds);
  print(
      "Standing still and AAing-to-death all ${combos.length} pairs of ${champIds.length} champions");
  print("using no items, runes or masteries or abilities.");
  print("Note: A few have passives implemented, as indicated.\n");

  // Combinations doesn't implement iterable, so I can't use it in strong mode. :(
  for (int i = 0; i < combos.length; i += 1) {
    List<String> names = combos[i] as List<String>;
    // Loading champ new every time to avoid any buffs hanging over, etc.
    Mob red = data.champs.championById(names[0]);
    Mob blue = data.champs.championById(names[1]);
    int result = champCompare(red, blue);
    if (result > 0)
      resultsById[blue.id].recordVictory();
    else if (result < 0) resultsById[red.id].recordVictory();
  }
  List<ChampResults> results = resultsById.values.toList();
  results.sort();
  TableLayout layout = new TableLayout([13, 10, 10]);
  layout.printRow(['Name', 'Victories', 'Status']);
  layout.printDivider();
  results.forEach((result) {
    String statusString = result.hasEffects ? '(has passive)' : '';
    layout
        .printRow([result.champId, result.victories.toString(), statusString]);
  });
}
