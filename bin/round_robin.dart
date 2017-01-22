import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:lol_duel/champions.dart';
import 'package:lol_duel/creator.dart';
import 'package:lol_duel/lolsim.dart';
import 'package:trotter/trotter.dart';

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
  List<String> defeatedChamps = [];
  ChampResults(this.champId);

  bool get hasEffects => championEffectsConstructors[champId] != null;

  int get victories => defeatedChamps.length;

  void recordVictory(String champId) {
    defeatedChamps.add(champId);
  }

  int compareTo(ChampResults b) {
    int result = victories.compareTo(b.victories);
    if (result != 0) return result;
    return champId.compareTo(b.champId);
  }
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

void printForHumans(List<ChampResults> results) {
  TableLayout layout = new TableLayout([13, 10, 10]);
  layout.printRow(['Name', 'Victories', 'Status']);
  layout.printDivider();
  results.sort();
  results.forEach((result) {
    String statusString = result.hasEffects ? '(has passive)' : '';
    layout
        .printRow([result.champId, result.victories.toString(), statusString]);
  });
}

void printForTests(List<ChampResults> results) {
  results.sort((a, b) => a.champId.compareTo(b.champId));
  results.forEach((result) {
    String titleString = '${result.champId} ${result.victories}';
    titleString += result.hasEffects ? ' (has passive)' : '';
    print(titleString);
    result.defeatedChamps.sort((a, b) => a.compareTo(b));
    result.defeatedChamps.forEach((champId) => print('  $champId'));
  });
}

main(List<String> args) async {
  Logger.root.level = Level.WARNING;
  Logger.root.onRecord.listen((LogRecord rec) {
    // ${rec.time}:
    print('${rec.level.name.toLowerCase()}: ${rec.message}');
  });

  ArgParser parser = new ArgParser()
    ..addFlag('verbose', abbr: 'v')
    ..addFlag('test');
  ArgResults argResults = parser.parse(args);
  if (argResults['verbose']) Logger.root.level = Level.ALL;

  Creator data = await Creator.loadLatest();
  List<String> champIds = data.champs.loadChampIds();
  Map<String, ChampResults> resultsById = {};
  champIds.forEach((id) => resultsById[id] = new ChampResults(id));
  Combinations combos = new Combinations(2, champIds);
  print(
      "Standing still and AAing-to-death all ${combos.length} pairs of ${champIds.length} champions");
  print("using no items, runes or masteries or abilities.");
  print("Note: A few have passives implemented, as indicated.\n");

  // Combinations doesn't implement Iterable, so I can't for-in with strong mode. :(
  for (int i = 0; i < combos.length; i += 1) {
    List<String> names = combos[i] as List<String>;
    // Loading champ new every time to avoid any buffs hanging over, etc.
    Mob red = data.champs.championById(names[0]);
    Mob blue = data.champs.championById(names[1]);
    int result = champCompare(red, blue);
    if (result > 0)
      resultsById[blue.id].recordVictory(red.id);
    else if (result < 0) resultsById[red.id].recordVictory(blue.id);
  }
  List<ChampResults> results = resultsById.values.toList();
  printForHumans(results);
  if (argResults['test']) printForTests(results);
}
