extension RecordZip2<T, S> on (List<T>, List<S>) {
  List<(T, S)> zip() => [for (int i = 0; i < $1.length; i++) ($1[i], $2[i])];
}

extension RecordZip3<T, S, X> on (List<T>, List<S>, List<X>) {
  List<(T, S, X)> zip() =>
      [for (int i = 0; i < $1.length; i++) ($1[i], $2[i], $3[i])];
}

extension RecordZip4<T, S, X, Y> on (List<T>, List<S>, List<X>, List<Y>) {
  List<(T, S, X, Y)> zip() =>
      [for (int i = 0; i < $1.length; i++) ($1[i], $2[i], $3[i], $4[i])];
}

extension RecordZip5<T, S, X, Y, Z> on (
  List<T>,
  List<S>,
  List<X>,
  List<Y>,
  List<Z>
) {
  List<(T, S, X, Y, Z)> zip() =>
      [for (int i = 0; i < $1.length; i++) ($1[i], $2[i], $3[i], $4[i], $5[i])];
}
