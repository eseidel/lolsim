class SpellKey {
  final String char;
  const SpellKey(this.char);

  static const SpellKey q = const SpellKey('Q');
  static const SpellKey w = const SpellKey('W');
  static const SpellKey e = const SpellKey('E');
  static const SpellKey r = const SpellKey('R');

  factory SpellKey.fromIndex(int index) {
    return [
      SpellKey.q,
      SpellKey.w,
      SpellKey.e,
      SpellKey.r,
    ][index];
  }

  @override
  String toString() => char;
}
