class Role {
  final String id;
  const Role(this.id);

  // FIXME: This shouldn't have champion.gg knowledge.
  factory Role.fromChampionGG(String id) {
    return {
      top.id: top,
      mid.id: mid,
      jungle.id: jungle,
      support.id: support,
      adc.id: adc,
    }[id];
  }

  static const Role top = const Role('TOP');
  static const Role mid = const Role('MIDDLE');
  static const Role jungle = const Role('JUNGLE');
  static const Role support = const Role('DUO_SUPPORT');
  static const Role adc = const Role('DUO_CARRY');

  String get shortName {
    return {
      top.id: 'Top',
      mid.id: 'Mid',
      jungle.id: 'Jung',
      adc.id: 'ADC',
      support.id: 'Support',
    }[id];
  }
}
