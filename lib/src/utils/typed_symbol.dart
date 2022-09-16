abstract class TypedSymbol {
  static Symbol create(Type type) => Symbol('$type-${type.hashCode}');
}
