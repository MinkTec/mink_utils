import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:xdg_directories/xdg_directories.dart';

Future<String> get getLocalPath async {
  if (!Platform.isLinux) {
    return await getApplicationDocumentsDirectory().then((e) => e.path);
  } else {
    return "${dataHome.path}/de.minktec.rectify/";
  }
}

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

Future<void> writeToDownloadFile(String name, String content) async =>
    getDownloadsFile(name).then((file) => file.writeAsString(content));