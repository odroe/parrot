import 'exceptions/instance_not_found_exception.dart';
import 'parrot_context.dart';

abstract class ParrotContainer extends Map<Type, ParrotContext> {
  factory ParrotContainer() = _ParrotContainerImpl;
}

class _ParrotContainerImpl implements ParrotContainer {
  _ParrotContainerImpl._();

  factory _ParrotContainerImpl() => _ParrotContainerImpl._();

  final Map<Type, ParrotContext> instances = {};

  @override
  ParrotContext operator [](Object? key) {
    assert(key is Type, 'The key must be a Type');

    final ParrotContext? instance = instances[key];
    if (instance == null) {
      throw InstanceNotFoundException(key as Type);
    }

    return instance;
  }

  @override
  void operator []=(Type key, ParrotContext value) => instances[key] = value;

  @override
  void addAll(Map<Type, ParrotContext> other) => instances.addAll(other);

  @override
  void addEntries(Iterable<MapEntry<Type, ParrotContext>> newEntries) =>
      instances.addEntries(newEntries);

  @override
  Map<RK, RV> cast<RK, RV>() => instances.cast<RK, RV>();

  @override
  void clear() => instances.clear();

  @override
  bool containsKey(Object? key) => instances.containsKey(key);

  @override
  bool containsValue(Object? value) => instances.containsValue(value);

  @override
  Iterable<MapEntry<Type, ParrotContext>> get entries => instances.entries;

  @override
  void forEach(void Function(Type key, ParrotContext value) action) =>
      instances.forEach(action);

  @override
  bool get isEmpty => instances.isEmpty;

  @override
  bool get isNotEmpty => instances.isNotEmpty;

  @override
  Iterable<Type> get keys => instances.keys;

  @override
  int get length => instances.length;

  @override
  Map<K2, V2> map<K2, V2>(
          MapEntry<K2, V2> Function(Type key, ParrotContext value) convert) =>
      instances.map(convert);

  @override
  ParrotContext putIfAbsent(Type key, ParrotContext Function() ifAbsent) =>
      instances.putIfAbsent(key, ifAbsent);

  @override
  ParrotContext? remove(Object? key) => instances.remove(key);

  @override
  void removeWhere(bool Function(Type key, ParrotContext value) test) =>
      instances.removeWhere(test);

  @override
  ParrotContext update(
          Type key, ParrotContext Function(ParrotContext value) update,
          {ParrotContext Function()? ifAbsent}) =>
      instances.update(key, update, ifAbsent: ifAbsent);

  @override
  void updateAll(
          ParrotContext Function(Type key, ParrotContext value) update) =>
      instances.updateAll(update);

  @override
  Iterable<ParrotContext> get values => instances.values;
}
