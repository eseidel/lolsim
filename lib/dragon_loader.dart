import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as pathPackage;
import 'package:quiver/cache.dart';
import 'package:resource/resource.dart';

final Logger _log = new Logger('dragon_loader');

const String DEFAULT_VERSION = '7.2.1';
const String DEFAULT_LOCALE = 'en_US';
const String DEFAULT_CACHE_DIR = '/tmp/lolsim';

typedef Future<String> StringReader(String path);

Future<String> _ioReader(String path) {
  return new Resource(path).readAsString();
}

abstract class DragonLoader {
  Future<String> load(String filename, {String version, String locale}) {
    return loadKey(new DragonKey(filename, version: version, locale: locale));
  }

  Future<String> loadKey(DragonKey key);
}

class LocalLoader extends DragonLoader {
  final StringReader reader;
  final String rootDir;
  LocalLoader({this.rootDir = DEFAULT_CACHE_DIR, this.reader = _ioReader});

  String _pathForKey(DragonKey key) =>
      pathPackage.join(rootDir, key.toDragonPath());

  @override
  Future<String> loadKey(DragonKey key) => reader(_pathForKey(key));
}

class DragonKey {
  final String filename;
  final String version;
  final String locale;
  DragonKey(this.filename, {String version, String locale})
      : this.version = version ?? DEFAULT_VERSION,
        this.locale = locale ?? DEFAULT_LOCALE;

  @override
  String toString() => '${version}-${locale}-${filename}';

  /// Path following Rito's dragontail layout pattern.
  // FIXME: This won't work correctly on windows and likely
  // needs to be split into two separate functions, one for urls
  // and one for caching.
  String toDragonPath() => '${version}/data/${locale}/${filename}';
}

class NetworkLoader extends DragonLoader {
  Cache<DragonKey, String> cache;

  NetworkLoader({this.cache}) {
    // FIXME: This will not work on windows.
    // Directory.systemTemp doesn't give a consistent value between runs.
    cache ??= new DiskCache(pathPackage.join('/tmp', 'lolsim'));
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
    file.writeAsString(value);
    return new Future.value(1);
  }

  @override
  Future invalidate(DragonKey key) {
    return new File(_pathForKey(key)).delete();
  }
}
