import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as pathPackage;
import 'package:quiver/cache.dart';
import 'package:resource/resource.dart';

const String DEFAULT_VERSION = '7.2.1';
const String DEFAULT_LOCALE = 'en_US';

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
  LocalLoader({this.reader = _ioReader});

  Future<String> loadKey(DragonKey key) {
    return reader('package:dragon_data/${key.toDragonPath()}');
  }
}

class DragonKey {
  final String filename;
  final String version;
  final String locale;
  DragonKey(this.filename, {String version, String locale})
      : this.version = version ?? DEFAULT_VERSION,
        this.locale = locale ?? DEFAULT_LOCALE {}

  /// Path following Rito's dragontail layout pattern.
  // FIXME: This won't work correctly on windows and likely
  // needs to be split into two separate functions, one for urls
  // and one for caching.
  String toDragonPath() => '${version}/data/${locale}/${filename}';
}

class NetworkLoader extends DragonLoader {
  DiskCache cache =
      new DiskCache(pathPackage.join(Directory.systemTemp.path, 'lolsim'));

  Future<String> loadKey(DragonKey key) {
    Future<String> _fetchDataForKey(DragonKey key) {
      String url =
          'http://ddragon.leagueoflegends.com/cdn/${key.toDragonPath()}';
      return new Resource(url).readAsString();
    }

    return cache.get(key, ifAbsent: _fetchDataForKey);
  }
}

class DiskCache extends Cache<DragonKey, String> {
  String cacheRoot;
  DiskCache(this.cacheRoot);

  String _pathForKey(DragonKey key) =>
      pathPackage.join(cacheRoot, key.toDragonPath());

  Future<String> get(DragonKey key, {Loader<DragonKey> ifAbsent}) async {
    File file = new File(_pathForKey(key));
    if (await file.exists()) return file.readAsString();
    String value = await ifAbsent(key);
    set(key, value);
    return value;
  }

  Future set(DragonKey key, String value) async {
    File file = new File(_pathForKey(key));
    await file.create(recursive: true);
    return file.writeAsString(value);
  }

  Future invalidate(DragonKey key) {
    File file = new File(_pathForKey(key));
    return file.delete();
  }
}
