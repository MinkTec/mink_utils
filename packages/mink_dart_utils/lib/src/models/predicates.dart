typedef Predicate<T> = bool Function(T element);

enum UnaryLogicalConnective {
  confirm,
  negate,
  ;

  Predicate<T> transform<T>(Predicate<T> predicate) {
    return switch (this) {
      UnaryLogicalConnective.confirm => predicate,
      UnaryLogicalConnective.negate => (T t) => !predicate(t),
    };
  }

  String get label => switch (this) {
        UnaryLogicalConnective.confirm => "is",
        UnaryLogicalConnective.negate => "is not",
      };
}

enum BinaryLogicalConnective {
  and,
  or,
  xor,
  nand,
  nor,
  ;

  Predicate<T> join<T>(Predicate<T> a, Predicate<T> b) {
    return switch (this) {
      BinaryLogicalConnective.and => (T m) => a(m) & b(m),
      BinaryLogicalConnective.or => (T m) => a(m) || b(m),
      BinaryLogicalConnective.xor => (T m) => a(m) ^ b(m),
      BinaryLogicalConnective.nand => (T m) => !(a(m) & b(m)),
      BinaryLogicalConnective.nor => (T m) => !a(m) & !b(m),
    };
  }
}

extension JoinPredicates<T> on Predicate<T> {
  Predicate<T> join(Predicate<T> other, BinaryLogicalConnective relation) =>
      relation.join(this, other);
}
