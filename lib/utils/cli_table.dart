// This doesn't belong in lol_duel, but I would like to share it
// and I don't want to bother starting a new package yet.

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
