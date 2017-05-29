import 'package:lol_duel/champions/jax.dart';
import "package:lol_duel/creator.dart";
import 'package:lol_duel/lolsim.dart';
import "package:test/test.dart";

import '../utils.dart';

dynamic main() async {
  Creator data = await Creator.loadLatest();

  group("Relentless Assault", () {
    test("basic", () {
      Mob jax = data.champs.championById('Jax');
      Mob mob = createTestMob(hp: 1000.0);
      World world = new World();
      double initialAttackSpeed = jax.stats.attackSpeed;
      new AutoAttack(jax, mob).apply(world);
      expect(initialAttackSpeed, lessThan(jax.stats.attackSpeed));
      RelentlessAssault buff =
          jax.buffs.firstWhere((buff) => buff is RelentlessAssault);
      expect(buff.stacks, 1);
      new AutoAttack(jax, mob).apply(world); // 2
      new AutoAttack(jax, mob).apply(world); // 3
      new AutoAttack(jax, mob).apply(world); // 4
      new AutoAttack(jax, mob).apply(world); // 5
      new AutoAttack(jax, mob).apply(world); // 6
      new AutoAttack(jax, mob).apply(world); // 7
      new AutoAttack(jax, mob).apply(world); // 8
      expect(buff.stacks, 8);
      new AutoAttack(jax, mob).apply(world); // 9
      expect(buff.stacks, 8);
      jax.tick(2.25);
      expect(buff.stacks, 8);
      jax.tick(.25);
      expect(buff.stacks, 7);
      jax.tick(.25);
      expect(buff.stacks, 6);
      jax.tick(3.0);
      expect(buff.stacks, 0);
      expect(buff.expired, true);
    });
  });
}
