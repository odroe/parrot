class Tuple2<T1, T2> {
  const Tuple2(this.first, this.second);

  final T1 first;

  final T2 second;

  Tuple2<R1, R2> flatMap<R1, R2>(
          Tuple2<R1, R2> Function(T1 first, T2 second) mapper) =>
      mapper(first, second);

  Tuple2<R1, R2> cast<R1, R2>() => Tuple2(first as R1, second as R2);

  @override
  String toString() {
    return "Tuple2<${T1.toString()}, ${T2.toString()}>(first=${first.toString()}, second=${second.toString()})";
  }
}

class Tuple3<T1, T2, T3> {
  const Tuple3(this.first, this.second, this.third);

  final T1 first;

  final T2 second;

  final T3 third;

  Tuple3<R1, R2, R3> flatMap<R1, R2, R3>(
          Tuple3<R1, R2, R3> Function(T1 first, T2 second, T3 third) mapper) =>
      mapper(first, second, third);

  Tuple3<R1, R2, R3> cast<R1, R2, R3>() =>
      Tuple3(first as R1, second as R2, third as R3);

  @override
  String toString() {
    return "Tuple3<${T1.toString()}, ${T2.toString()}, ${T3.toString()}>(first=${first.toString()}, second=${second.toString()}, third=${third.toString()})";
  }
}
