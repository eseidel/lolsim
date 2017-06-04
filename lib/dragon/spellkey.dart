class SpellKey {
  final String char;
  const SpellKey._fromCharUnchecked(this.char);

  static const SpellKey q = const SpellKey._fromCharUnchecked('Q');
  static const SpellKey w = const SpellKey._fromCharUnchecked('W');
  static const SpellKey e = const SpellKey._fromCharUnchecked('E');
  static const SpellKey r = const SpellKey._fromCharUnchecked('R');

  factory SpellKey.fromChar(String char) {
    return {
      q.char: q,
      w.char: w,
      e.char: e,
      r.char: r,
    }[char];
  }

  factory SpellKey.fromIndex(int index) => [q, w, e, r][index];

  @override
  String toString() => char;
}
