import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:lol_duel/dragon/dragon.dart';
import 'package:lol_duel/dragon/loader.dart';
import 'package:path/path.dart' as pathPackage;
import 'package:quiver/cache.dart';

final Logger _log = new Logger('dragon_loader');

class NetworkLoader extends DragonLoader {
  Cache<DragonKey, String> cache;

  NetworkLoader({this.cache}) {
    // FIXME: This will not work on windows.
    // Directory.systemTemp doesn't give a consistent value between runs.
    cache ??= new DiskCache(DEFAULT_CACHE_DIR);
  }

  String _urlForKey(DragonKey key) =>
      'http://ddragon.leagueoflegends.com/cdn/${key.toDragonPath()}';

  @override
  Future<String> loadKey(DragonKey key) {
    Future<String> _fetchDataForKey(DragonKey key) {
      // FIXME: Should be possible to use package:resource here and share
      // code with the LocalLoader path, except for
      // https://github.com/dart-lang/resource/issues/21
      return http.read(_urlForKey(key));
    }

    return cache.get(key, ifAbsent: _fetchDataForKey);
  }
}

// FIXME: This has no locking and is thus racey.
class DiskCache extends Cache<DragonKey, String> {
  String cacheDir;
  DiskCache(this.cacheDir);

  String _pathForKey(DragonKey key) =>
      pathPackage.join(cacheDir, key.toDragonPath());

  @override
  Future<String> get(DragonKey key, {Loader<DragonKey> ifAbsent}) async {
    File file = new File(_pathForKey(key));
    if (await file.exists()) {
      _log.info('Cache hit: $key');
      return file.readAsString();
    }
    _log.info('Cache miss: $key, fetching.');
    String value = await ifAbsent(key);
    await set(key, value);
    return value;
  }

  @override
  Future set(DragonKey key, String value) async {
    _log.info('Cache set: $key ${value.length} bytes.');
    File file = new File(_pathForKey(key));
    file = await file.create(recursive: true);
    return file.writeAsString(value);
  }

  @override
  Future invalidate(DragonKey key) {
    return new File(_pathForKey(key)).delete();
  }
}

dynamic main() async {
  await DragonData.loadLatest(loader: new NetworkLoader());
  print("Successfully cached dragon data to $DEFAULT_CACHE_DIR");
}
