import 'dart:collection';

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

class IteratorIterable<T> extends Iterable<T> {
  const IteratorIterable(this._iterator);

  final Iterator<T> _iterator;

  @override
  Iterator<T> get iterator => _iterator;
}

typedef ContextBuilder = Context Function(Context parent);

abstract class Context implements Iterable<Context> {
  static Context empty() => _EmptyContext();

  static ContextBuilder compose(Iterable<ContextBuilder> builders) {
    Context applyChildren(Context parent) {
      return builders.fold(parent, (parent, builder) => parent.derive(builder));
    }

    return applyChildren;
  }

  Context? get parent;

  Context derive(ContextBuilder builder);
}

class _EmptyContext with IterableMixin<Context> implements Context {
  @override
  Context? get parent => null;

  @override
  Iterator<Context> get iterator => _ContextIterator(this);

  @override
  Context derive(ContextBuilder builder) {
    return builder.call(this);
  }
}

class MutableContext with IterableMixin<Context> implements Context {
  MutableContext(this._context);

  Context _context;

  @override
  Context? get parent => _context.parent;

  Context get latest => _context;

  Context get snapshot => latest;

  @override
  Iterator<Context> get iterator => latest.iterator;

  @override
  Context derive(ContextBuilder builder) {
    return builder.call(latest);
  }

  MutableContext apply(ContextBuilder builder) {
    _context = latest.derive(builder);

    return this;
  }
}

extension ContextExtensions on Context {
  MutableContext get mutable => MutableContext(this);
}

extension MutableContextOverrideExtensions on MutableContext {
  MutableContext get mutable => this;
}

abstract class Marker with IterableMixin<Context> implements Context {
  const Marker();

  @override
  Iterator<Context> get iterator => _ContextIterator(this);

  @override
  Context derive(ContextBuilder builder) {
    return builder.call(this);
  }
}

abstract class State with IterableMixin<Context> implements Context {
  const State();

  @override
  Iterator<Context> get iterator => _ContextIterator(this);

  @override
  Context derive(ContextBuilder builder) {
    return builder.call(this);
  }
}

class _ContextIterator implements Iterator<Context> {
  _ContextIterator(this._current);

  int _offset = -1;

  Context _current;

  @override
  Context get current => _offset == -1
      ? throw UnsupportedError(
          "cannot access value before moveNext() on Iterator")
      : _current;

  @override
  bool moveNext() {
    if (_offset == -1) {
      _offset++;
      return true;
    }

    final parent = _findParent();
    if (parent == null) {
      return false;
    }
    _offset++;
    _current = parent;

    return true;
  }

  Context? _findParent() {
    Context? current = _current;

    // If a context is [MutableContext], it means the context has compressed
    // more than one [Context] in [MutableContext]. We need to decomporess
    // those [Context] from [MutableContext], just visit them in bottom-to-top
    // way. In other words, use the latest [Context] (i.e [MutableContext.snapshot])
    // as the start and repeats the old way.
    if (current is MutableContext) {
      current = current.latest;
    }

    if (current.parent == null) {
      return null;
    }
    return current.parent;
  }
}

class Value extends State {
  const Value(this.value, {this.parent});

  @override
  final Context? parent;

  final Option<Object> value;
}

class KeyedValue extends Value {
  const KeyedValue(
    this.key,
    Option<Object> value, {
    Context? parent,
  }) : super(value, parent: parent);

  final Object key;
}
