
extension FunctionTimer<S> on S Function() {
  S time([String? label]) {
    final s = Stopwatch()..start();
    final x = call();
    print("""${label == null ? "" : "$label "}took: ${s.elapsed}""");
    return x;
  }

  Future<S> timeAsync([String? label]) async {
    final s = Stopwatch()..start();
    final x = call();
    print("""${label == null ? "" : "$label "}took: ${s.elapsed}""");
    return x;
  }
}
