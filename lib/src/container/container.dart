import './lookup.dart';

typedef ConflictResolution<TInstance> = TInstance Function(
  TInstance older,
  TInstance newer,
);

abstract class IContainer {
  IContainer createChild();

  void register<TInstance>(
    Type type,
    TInstance instance, {
    ConflictResolution? conflictResolution,
  });

  bool has(Type type);

  TInstance get<TInstance>(Type type);
}

class Container implements IContainer {
  final Lookup _lookup;

  Container(
    this._lookup,
  );

  @override
  Container createChild() {
    throw UnimplementedError();
  }

  void _registerOrReplace<TInstance>(Type type, TInstance instance) {
    _lookup.register(type, instance);
  }

  @override
  void register<TInstance>(
    Type type,
    TInstance instance, {
    ConflictResolution? conflictResolution,
  }) {
    if (has(type)) {
      if (conflictResolution != null) {
        _registerOrReplace(type, conflictResolution(get(type), instance));
      }
      return;
    }
    _registerOrReplace(type, instance);
  }

  @override
  bool has(Type type) {
    return _lookup.has(type);
  }

  @override
  TInstance get<TInstance>(Type type) {
    return _lookup.get(type);
  }
}
