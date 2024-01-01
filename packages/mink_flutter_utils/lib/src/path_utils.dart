import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:xdg_directories/xdg_directories.dart';

Future<String> get getLocalPath async => !Platform.isLinux
    ? await getApplicationDocumentsDirectory().then((e) => e.path)
    : "${dataHome.path}/de.minktec.rectify/";

Future<String> get getDownloadsPath async =>
    (await getDownloadsDirectory())?.path ?? await getLocalPath;

Future<Directory> getLocalDir(String name) async {
  if (!Platform.isLinux) {
    return Directory(
        "${await getApplicationDocumentsDirectory().then((e) => e.path)}/$name");
  } else {
    final dir = Directory("${dataHome.path}/de.minktec.rectify/$name");
    return await _createIfNeeded(dir);
  }
}

Future<Directory> _createIfNeeded(Directory dir) async =>
    (!await dir.exists()) ? await dir.create(recursive: true) : dir;

Future<File> getLocalFile(String name) async =>
    File('${await getLocalPath}/$name');

Future<File> getDownloadsFile(String name) async =>
    File('${await getDownloadsPath}/$name');

Future<File> writeToExternalFile(String name, String content) async {
  final dir = await getExternalStorageDirectory();
  final file = File("${dir!.path}/$name");
  return file.writeAsString(content);
}

Future<File> writeToLocalFile(String name, String content) async {
  final file = await getLocalFile(name);
  return await file.writeAsString(content);
}

Future<File> writeToDownloadFile(String name, String content) async =>
    getDownloadsFile(name).then((file) => file.writeAsString(content));

class PathBuf {
  static final splitChar = Platform.isWindows ? "\\" : "/";

  String path;
  PathBuf(this.path);

  Iterable<T> _allButLast<T>(List<T> l) => l.take(l.length - 1);

  Iterable<String> get _splits => path.split(splitChar);

  String get basepath => _allButLast(path.split(splitChar)).join(splitChar);

  String get end => _splits.last;

  String? get extension => path.split(".").last;
}

extension MinkUtilsDirExtensions on Directory {
  Stream<FileStat> get fileStats => list().map((e) => e.statSync());

  /// size of all top level files in bytes
  Future<int> get size async {
    int sizeInByte = 0;
    await fileStats.forEach((stat) {
      sizeInByte += stat.size;
    });
    return sizeInByte;
  }
}
