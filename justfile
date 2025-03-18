gen:
  flutter pub run build_runner build --delete-conflicting-outputs

coverage:
    dart test --coverage=coverage
    dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages=.packages --report-on=lib
    genhtml coverage/lcov.info -o coverage/html
    firefox coverage/html/index.html

