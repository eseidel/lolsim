import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:resource/resource.dart';
import 'package:path/path.dart' as pathPackage;

final Logger _log = new Logger('dragon_loader');

const String DEFAULT_VERSION = '7.10.1';
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
  Future<String> loadKey(DragonKey key, {bool exitOnFailure: true}) {
    Future<String> result = reader(_pathForKey(key));
    if (exitOnFailure) {
      return result.catchError((e) {
        print(
            "Failed to load $key.\n$e\nTry running bin/precache_dragondata.dart first.");
        exit(1);
      });
    }
    return result;
  }
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
