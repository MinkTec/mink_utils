import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mink_flutter_utils/mink_flutter_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xdg_directories/xdg_directories.dart';

Future<String> get getLocalPath async {
  if (kIsWeb) {
    return "";
  } else if (!PlatformInfo.isLinux) {
    return await getApplicationDocumentsDirectory().then((e) => e.path);
  } else {
    return "${dataHome.path}${PathBuf.splitChar}de.minktec.rectify";
  }
}

Future<String> get getDownloadsPath async =>
    (await getDownloadsDirectory())?.path ?? await getLocalPath;

Future<Directory> getLocalDir(String name) async {
  if (kIsWeb) {
    return Directory("");
  } else if (!PlatformInfo.isLinux) {
    return Directory(
        "${await getApplicationDocumentsDirectory().then((e) => e.path)}${PathBuf.splitChar}$name");
  } else {
    final dir = Directory(
        "${dataHome.path}${PathBuf.splitChar}de.minktec.rectify${PathBuf.splitChar}$name");
    return await _createIfNeeded(dir);
  }
}

Future<Directory> _createIfNeeded(Directory dir) async =>
    (!await dir.exists()) ? await dir.create(recursive: true) : dir;

Future<File> getLocalFile(String name) async =>
    File('${await getLocalPath}${PathBuf.splitChar}$name');

Future<File> getDownloadsFile(String name) async =>
    File('${await getDownloadsPath}${PathBuf.splitChar}$name');

Future<File> writeToExternalFile(String name, String content) async {
  final dir = await getExternalStorageDirectory();
  final file = File("${dir!.path}${PathBuf.splitChar}$name");
  return file.writeAsString(content);
}

Future<File> writeToLocalFile(String name, String content) async {
  final file = await getLocalFile(name);
  return await file.writeAsString(content);
}

Future<File> writeToDownloadFile(String name, String content) async =>
    getDownloadsFile(name).then((file) => file.writeAsString(content));

class PathBuf {
  static final splitChar = PlatformInfo.pathSeperator;

  String path;
  PathBuf(this.path);

  Iterable<T> _allButLast<T>(List<T> l) => l.take(l.length - 1);

  Iterable<String> get _splits => path.split(splitChar);

  String get basepath => _allButLast(path.split(splitChar)).join(splitChar);

  String get end => _splits.last;

  String? get extension => path.split(".").last;

  void add(String level) => path = path + splitChar + level;
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
