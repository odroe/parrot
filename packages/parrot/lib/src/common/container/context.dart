import 'dart:collection';

import 'option.dart';

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

  Context get _latest => _context;

  @override
  Context? get parent => _latest.parent;

  Context get snapshot => _latest;

  @override
  Iterator<Context> get iterator => _latest.iterator;

  @override
  Context derive(ContextBuilder builder) {
    return builder.call(_latest);
  }

  MutableContext apply(ContextBuilder builder) {
    _context = _latest.derive(builder);

    return this;
  }

  @override
  String toString() {
    return _latest.toString();
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
      current = current.snapshot;
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
