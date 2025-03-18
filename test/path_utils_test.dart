
import 'package:mink_flutter_utils/mink_flutter_utils.dart';
import 'package:test/test.dart';

void main() {
  group("PathUtils", () {
    test("getLocalFile", () async {
      final file = await getLocalFile("test.txt");
      expect(file.path, contains("test.txt"));
    });

    test("writeToLocalFile", () async {
      final file = await writeToLocalFile("test.txt", "content");
      expect(await file.readAsString(), "content");
    });
  });
}