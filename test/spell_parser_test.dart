import 'package:lol_duel/spell_parser.dart';
import "package:test/test.dart";

dynamic main() async {
  group("effectRegexp", () {
    test("missing spaces", () {
      var tooltip = "Aatrox takes flight and slams down at target location, "
          "dealing {{ e1 }}<span class=\"colorF88017\"> (+{{ a1 }})</span> "
          "physical damage and knocking up enemies at the center of impact "
          "for {{ e5 }} second.";
      expect(effectRegexp.hasMatch(tooltip), true);
    });
    test("duel scaling", () {
      var tooltip = "Dashes through target enemy, dealing {{ e1 }} <span "
          "class=\"color99FF99\">(+{{ a1 }})</span><span "
          "class=\"colorFF8C00\">(+{{ f3 }})</span> Magic Damage. Each cast "
          "increases your next dash's base Damage by 25%, up to {{ e6 }}%."
          "<br><br>Cannot be re-cast on the same enemy for {{ e2 }} seconds."
          "<br><br><span class=\"color99FF99\">If cast while dashing, Steel "
          "Tempest will strike as a circle.</span>";
      expect(effectRegexp.hasMatch(tooltip), true);
    });
    test('nested spans', () {
      var tooltip = "Aatrox unleashes the power of his blade, dealing "
          "{{ e1 }} <span class=\"color99FF99\">(+{{ a1 }}) <span "
          "class=\"colorF88017\">(+{{ a2 }})</span></span> Magic Damage to "
          "enemies hit and slowing them by {{ e2 }}% for {{ e4 }} seconds.";
      expect(effectRegexp.hasMatch(tooltip), true);
    }, skip: true);
    test('mf', () {
      var tooltip = "Miss Fortune fires a bouncing shot through an enemy, "
          "dealing {{ e2 }} <span class=\"colorFF8C00\">(+{{ f1 }})</span> "
          "<span class=\"color99FF99\">(+{{ a1 }})</span> physical damage to "
          "the first target and {{ e4 }} <span class=\"colorFF8C00\">"
          "(+{{ f2 }})</span> <span class=\"color99FF99\">(+{{ a2 }})</span> "
          "damage to the second. Both apply on-hit effects.<br><br>If the "
          "first shot kills its target, the second deals 50% increased damage.";
      expect(effectRegexp.hasMatch(tooltip), true);
    });
    test('braum q max health', () {
      var tooltip = "Braum propels freezing ice from his shield dealing "
          "{{ e1 }} <span class=\"colorCC3300\">(+{{ f1 }}) [2.5% of Braum's "
          "Max Health]</span> magic damage to the first enemy hit and slowing "
          "them by {{ e2 }}%, decaying over the next {{ e5 }} seconds.<br><br>"
          "Applies a stack of <span class=\"colorFFF673\">Concussive Blows</span>. ";
      expect(effectRegexp.hasMatch(tooltip), true);
    }, skip: true);
    test('casseopia twin fangs', () {
      // Has a span around the base damage which is unusual.
      var tooltip = "Deal <span class=\"colorFFFFFF\">{{ f1 }}</span> <span "
          "class=\"color99FF99\">(+{{ a1 }})</span> magic damage to a target. "
          "If the target is killed by Twin Fang, or is killed during its flight, "
          "Cassiopeia gains {{ cost }} Mana.<br><br>If the victim is <span "
          "class=\"color32CD32\">Poisoned</span> when Twin Fang hits, it takes "
          "{{ e1 }} <span class=\"color99FF99\">(+{{ a2 }})</span> additional "
          "magic damage and Cassiopeia heals for <span class=\"colorFFFFFF\">"
          "{{ f4 }}</span> <span class=\"color99FF99\">(+{{ f2 }})</span>.";
      expect(effectRegexp.hasMatch(tooltip), true);
    });
  });
  group("parseEffects", () {
    test('null apRatio', () {
      List<DamageEffect> effects = parseEffects({
        "tooltip":
            "Aatrox takes flight and slams down at target location, dealing "
            "{{ e1 }}<span class=\"colorF88017\"> (+{{ a1 }})</span> physical"
            " damage and knocking up enemies at the center of impact for "
            "{{ e5 }} second.",
        "maxrank": 5,
        "effect": [
          null,
          [70, 115, 160, 205, 250],
          [22, 20, 18, 16, 14],
          [10, 10, 10, 10, 10],
          [225, 225, 225, 225, 225],
          [1, 1, 1, 1, 1]
        ],
        "vars": [
          {
            "link": "bonusattackdamage",
            "coeff": 0.6,
            "key": "a1",
          }
        ],
      }).toList();
      expect(effects.length, 1);
      expect(effects[0].baseByRank, isNotNull);
      expect(effects[0].baseByRank, isNotNull);
    });
  });
}
