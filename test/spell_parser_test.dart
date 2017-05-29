import 'package:lol_duel/dragon/spell_parser.dart';
import "package:test/test.dart";

dynamic main() async {
  group("effectRegexp", () {
    test("missing spaces", () {
      var tooltip = "Aatrox takes flight and slams down at target location, "
          "dealing {{ e1 }}<span class=\"colorF88017\"> (+{{ a1 }})</span> "
          "physical damage and knocking up enemies at the center of impact "
          "for {{ e5 }} second.";
      expect(parseTooltip(tooltip), isNotEmpty);
    });
    test("duel scaling", () {
      var tooltip = "Dashes through target enemy, dealing {{ e1 }} <span "
          "class=\"color99FF99\">(+{{ a1 }})</span><span "
          "class=\"colorFF8C00\">(+{{ f3 }})</span> Magic Damage. Each cast "
          "increases your next dash's base Damage by 25%, up to {{ e6 }}%."
          "<br><br>Cannot be re-cast on the same enemy for {{ e2 }} seconds."
          "<br><br><span class=\"color99FF99\">If cast while dashing, Steel "
          "Tempest will strike as a circle.</span>";
      expect(parseTooltip(tooltip), isNotEmpty);
    });
    test('nested spans', () {
      var tooltip = "Aatrox unleashes the power of his blade, dealing "
          "{{ e1 }} <span class=\"color99FF99\">(+{{ a1 }}) <span "
          "class=\"colorF88017\">(+{{ a2 }})</span></span> Magic Damage to "
          "enemies hit and slowing them by {{ e2 }}% for {{ e4 }} seconds.";
      expect(parseTooltip(tooltip), isNotEmpty);
    });
    test('mf', () {
      var tooltip = "Miss Fortune fires a bouncing shot through an enemy, "
          "dealing {{ e2 }} <span class=\"colorFF8C00\">(+{{ f1 }})</span> "
          "<span class=\"color99FF99\">(+{{ a1 }})</span> physical damage to "
          "the first target and {{ e4 }} <span class=\"colorFF8C00\">"
          "(+{{ f2 }})</span> <span class=\"color99FF99\">(+{{ a2 }})</span> "
          "damage to the second. Both apply on-hit effects.<br><br>If the "
          "first shot kills its target, the second deals 50% increased damage.";
      expect(parseTooltip(tooltip), isNotEmpty);
    });
    test('braum q max health', () {
      var tooltip = "Braum propels freezing ice from his shield dealing "
          "{{ e1 }} <span class=\"colorCC3300\">(+{{ f1 }}) [2.5% of Braum's "
          "Max Health]</span> magic damage to the first enemy hit and slowing "
          "them by {{ e2 }}%, decaying over the next {{ e5 }} seconds.<br><br>"
          "Applies a stack of <span class=\"colorFFF673\">Concussive Blows</span>. ";
      expect(parseTooltip(tooltip), isNotEmpty);
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
      expect(parseTooltip(tooltip), isNotEmpty);
    });
    test('jihn', () {
      // Has a space before the closing span tag.
      var tooltip =
          "Jhin launches a cartridge at the targeted enemy that deals "
          "{{ e1 }} <span class=\"colorFF8C00\">(+{{ f1 }})</span> <span "
          "class=\"color99FF99\">(+{{ a1 }}) </span>physical damage before "
          "bouncing to a nearby target that has not yet been hit.<br><br>The "
          "cartridge can hit a maximum of 4 times. Each kill by the cartridge "
          "increases the damage of subsequent hits by {{ e2 }}%.";
      expect(parseTooltip(tooltip), isNotEmpty);
    });
    test('reksai', () {
      // Has a flat damage, no scaling.
      var tooltip =
          "<span class=\"colorFFFFFF\">Un-Burrowed:</span> Rek'Sai bites "
          "a target dealing <span class=\"colorFF8C00\">{{ f1 }}</span> Physical "
          "Damage, increasing by up to 100% at maximum Fury. Deals True Damage "
          "if Rek'Sai has 100 Fury.<br><br>Maximum Damage: <span "
          "class=\"colorFFFFFF\">{{ f2 }}</span><br><br><span "
          "class=\"colorFFFFFF\">Burrowed:</span> Rek'Sai tunnels forward "
          "leaving two connected <span class=\"colorF0F2B1\">Tunnel Entrances"
          "</span>. Clicking a <span class=\"colorF0F2B1\">Tunnel Entrance"
          "</span> will make Rek'Sai dive to the other entrance.<br><br><span "
          "class=\"colorF0F2B1\">Tunnel Entrances</span> last for {{ e5 }} "
          "minutes and can be destroyed by enemies. Rek'Sai may have {{ e6 }} "
          "tunnels at one time. Tunnels have a {{ e8 }} second cooldown on use.";
      expect(parseTooltip(tooltip), isNotEmpty);
    });
    test('corkie', () {
      // Missing (+) from a scaling factor.
      var tooltip = "<span class=\"colorFF9900\">Active:</span> Corki fires a "
          "missile that explodes at the first enemy it hits, dealing {{ e1 }} "
          "<span class=\"colorFF8C00\">{{ f3 }}</span> <span class=\"color99FF99\">"
          "(+{{ a1 }})</span> magic damage to all nearby enemies.<br><br>Corki "
          "can store up to 7 missiles, and every 3rd missile will be a Big One, "
          "dealing {{ e8 }}% increased damage.";
      List<TooltipMatch> matches = parseTooltip(tooltip).toList();
      expect(matches, isNotEmpty);
      TooltipMatch match = matches.first;
      expect(match.baseVar, "e1");
      expect(match.firstScaleVar, "f3");
      expect(match.secondScaleVar, "a1");
    }, skip: true);
    test('magical damage', () {
      // teemo uses 'magical damage' instead of 'magic damage'.
      var tooltip =
          "Teemo's basic attacks poison their target, dealing {{ e2 }} "
          "<span class=\"color99FF99\">(+{{ a1 }})</span> magical damage "
          "upon impact and {{ e1 }} <span class=\"color99FF99\">(+{{ a2 }})"
          "</span> magical damage each second for {{ e3 }} seconds.";
      expect(parseTooltip(tooltip), isNotEmpty);
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
