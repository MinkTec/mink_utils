import 'dart:math' as math;

class ClusteredData {
  List<int> baskets = [];
  List<List<double>> borders = [];

  factory ClusteredData.dummy() => ClusteredData(data: [], n: 1);

  ClusteredData({required List<List<num>> data, required int n}) {
    if (data.isEmpty || data.first.isEmpty) {
      baskets = [];
      borders = [];
      return;
    }
    assert(data.every((d) => d.length == data.first.length));
    borders = data.map((l) => _genHistogramBordersTuple(l.extrema, n)).toList();
    baskets = List<int>.filled(math.pow(n, data.length).toInt(), 0);

    List<double> factors = borders
        .map((border) => (n - 1) / (border.last - border.first))
        .toList();

    int index = 0;
    List<int> pows = List<int>.generate(
        data.length, (i) => math.pow(data.length, i).toInt());
    for (int i = 0; i < data.first.length; i++) {
      for (int d = 0; d < data.length; d++) {
        index +=
            (((data[d][i] - borders[d].first) * factors[d]).round() * pows[d])
                .toInt();
        //print(index);
      }
      baskets[index]++;
      index = 0;
    }
  }
}

// ignore: unused_element
List<double> _genHistogramBorders(min, max, n) => [
      ...List<double>.generate(n, (i) => min + (max - min) / n * i),
      max.toDouble()
    ];

List<double> _genHistogramBordersTuple(extrema, n) => [
      ...List<double>.generate(
          n, (i) => extrema.first + (extrema.last - extrema.first) / n * i),
      extrema.last.toDouble()
    ];

extension StatsticsExtensions<T extends num> on Iterable<T> {
  List<T> get extrema {
    T min = first;
    T max = first;
    for (var e in this) {
      if (e.isNaN) {
        continue;
      } else if (e < min) {
        min = e;
      } else if (e > max) {
        max = e;
      }
    }
    return [min, max];
  }

  ClusteredData cluster(int n) => ClusteredData(data: [toList()], n: n);

  @Deprecated("use cluster")
  ClusteredData histogram(int n) => cluster(n);
}

extension HistogramND<T extends num> on List<List<T>> {
  ClusteredData cluster(int n) => ClusteredData(data: this, n: n);
}
