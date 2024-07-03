typedef Predicate<T> = bool Function(T element);

enum PredicateRelation {
  and,
  or,
  xor,
  ;

  Predicate<T> join<T>(Predicate<T> a, Predicate<T> b) {
    return switch (this) {
      PredicateRelation.and => (T m) => a(m) & b(m),
      PredicateRelation.or => (T m) => a(m) || b(m),
      PredicateRelation.xor => (T m) => a(m) ^ b(m),
    };
  }
}

extension JoinPredicates<T> on Predicate<T> {
  Predicate<T> join(Predicate<T> other, PredicateRelation relation) =>
      relation.join(this, other);
}
