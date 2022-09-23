abstract class Option<T> {
  static Some<T> some<T>(T value) => Some(value);

  static None<T> none<T>() => None<T>();

  T get value;

  bool get hasValue;

  Option<R> map<R>(R Function(T) mapper);

  Option<R> flatMap<R>(Option<R> Function(T) mapper);

  Option<R> cast<R>();
}

class Some<T> implements Option<T> {
  const Some(this.value);

  @override
  final T value;

  @override
  bool get hasValue => true;

  @override
  Option<R> map<R>(R Function(T) mapper) => Some(mapper(value));

  @override
  Option<R> flatMap<R>(Option<R> Function(T) mapper) => mapper(value);

  @override
  Option<R> cast<R>() => Some<R>(value as R);

  @override
  String toString() {
    return "Some<${T.toString()}>(value=${value.toString()})";
  }
}

class None<T> implements Option<T> {
  const None();

  @override
  T get value => throw UnsupportedError("cannot retrieve value from None");

  @override
  bool get hasValue => false;

  @override
  Option<R> map<R>(R Function(T) mapper) => None<R>();

  @override
  Option<R> flatMap<R>(Option<R> Function(T) mapper) => None<R>();

  @override
  Option<R> cast<R>() => None<R>();

  @override
  String toString() {
    return "None<${T.toString()}>()";
  }
}
