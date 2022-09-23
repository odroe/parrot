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
