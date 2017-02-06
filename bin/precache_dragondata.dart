import 'package:lol_duel/dragon.dart';
import 'package:lol_duel/dragon_loader.dart';

void main() {
  DragonData.loadLatest(loader: new NetworkLoader());
  print("Successfully cached dragon data to $DEFAULT_CACHE_DIR");
}
