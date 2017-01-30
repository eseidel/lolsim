import 'dart:convert';

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
  final bool hasEffects;
  List<String> defeatedChamps = [];

  ChampResults(this.champId)
      : hasEffects = championEffectsConstructors[champId] != null;

  Map<String, dynamic> toJson() {
    return {
      'champId': champId,
      'skills': hasEffects ? skillsString : null,
      'defeatedChamps': sortedDefeatedChamps,
    };
  }

  String diffString(ChampResults other) {
    assert(champId == other.champId);
    String diff = '$champId';
    if (skillsString != other.skillsString) diff += ' ${skillsString} -> ${other.skillsString}';
    Set<String> from = new Set.from(defeatedChamps);
    Set<String> to = new Set.from(other.defeatedChamps);
    from.difference(to).forEach((champId) => diff += ' -$champId');
    to.difference(from).forEach((champId) => diff += ' +$champId');
    return diff;
  }

  ChampResults.fromJson(Map<String, dynamic> json)
      : champId = json['champId'],
        hasEffects = json['skills'] != null,
        defeatedChamps = json['defeatedChamps'];

  List<String> get sortedDefeatedChamps {
    List<String> sorted = new List.from(defeatedChamps);
    sorted.sort((a, b) => a.compareTo(b));
    return sorted;
  }

  String get skillsString => hasEffects ? 'P' : '';

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
  layout.printRow(['Name', 'Victories', 'Skills']);
  layout.printDivider();
  results.sort();
  results.forEach((result) {
    layout.printRow(
        [result.champId, result.victories.toString(), result.skillsString]);
  });
}

void printForTests(List<ChampResults> results) {
  results.sort((a, b) => a.champId.compareTo(b.champId));
  results.forEach((result) {
    print('${result.champId} ${result.victories} ${result.skillsString}');
    result.sortedDefeatedChamps.forEach((champId) => print('  $champId'));
  });
}

void printForJson(List<ChampResults> results) {
  results.sort((a, b) => a.champId.compareTo(b.champId));
  JsonEncoder encoder = new JsonEncoder.withIndent(' ');
  print(encoder.convert(results));
}

enum OutputMode {
  human,
  test,
  json,
}

OutputMode modeFromString(String mode) {
  switch (mode) {
    case 'human':
      return OutputMode.human;
    case 'test':
      return OutputMode.test;
    case 'json':
      return OutputMode.json;
  }
  return OutputMode.human;
}

main(List<String> args) async {
  Logger.root.level = Level.WARNING;
  Logger.root.onRecord.listen((LogRecord rec) {
    // ${rec.time}:
    print('${rec.level.name.toLowerCase()}: ${rec.message}');
  });

  ArgParser parser = new ArgParser()
    ..addFlag('verbose', abbr: 'v')
    ..addOption('mode', allowed: ['human', 'test', 'json']);
  ArgResults argResults = parser.parse(args);
  if (argResults['verbose']) Logger.root.level = Level.ALL;

  OutputMode mode = modeFromString(argResults['mode']);

  Creator data = await Creator.loadLatest();
  List<String> champIds = data.dragon.champs.loadChampIds();
  Map<String, ChampResults> resultsById = {};
  champIds.forEach((id) => resultsById[id] = new ChampResults(id));
  Combinations combos = new Combinations(2, champIds);
  if (mode != OutputMode.json) {
    print(
        "Standing still and AAing-to-death all ${combos
            .length} pairs of ${champIds.length} champions");
    print("using no items, runes or masteries or abilities.");
    print("Note: A few have passives implemented, as indicated.\n");
  }

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
  if (mode != OutputMode.json) printForHumans(results);
  if (mode == OutputMode.test) printForTests(results);
  if (mode == OutputMode.json) printForJson(results);
}
