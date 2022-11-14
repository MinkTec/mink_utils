import 'dart:math';

import 'package:mink_utils/iterable_utils.dart';

import 'list_utils.dart';
import 'lookup/binomial.dart';

double distance(num x1, num y1, num x2, num y2) =>
    sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));

// returns the binomial of n over k from the lookuptable (n_max = 23)
int binomial(n, k) {
  return binomialLut[n][k];
}

/// currently unused
num relativeMiddleDistance(num v, num pmin, num pmax) {
  final num range = pmax - pmin;
  return 2 * ((pmin + (range) / 2 - v) / (range)).abs();
}

/// calculate the sum of all integers until n
int smallGauss(int n) => n * (n + 1) ~/ 2;

/// weighted average of values
double weightedAverage(List<num> vals) {
  double acc = 0;
  for (int i = 0; i < vals.length; i++) {
    acc += vals[i] * (i + 1);
  }
  return acc / smallGauss(vals.length);
}

List<int> fibonacci(n) {
  final List<int> res = [1, 1];
  for (int i = 0; i < n; i++) {
    res.add(res.pysublist(-3, -1).sum);
  }
  return res;
}
