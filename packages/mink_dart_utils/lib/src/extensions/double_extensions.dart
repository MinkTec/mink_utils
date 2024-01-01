extension FiniteDouble on double {
  /// return 0.0 if this.isFinite is false
  double get finite => isFinite ? this : 0.0;
}
