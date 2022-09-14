import 'exceptions/instance_not_found_exception.dart';
import 'parrot_context.dart';

abstract class ParrotContainer extends Map<Type, ParrotContext> {
  factory ParrotContainer() = _ParrotContainerImpl;
}

class _ParrotContainerImpl implements ParrotContainer {
  _ParrotContainerImpl._();

  factory _ParrotContainerImpl() => _ParrotContainerImpl._();

  final Map<int, ParrotContext> instances = {};
  final Map<int, Type> hashes = {};

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
  void operator []=(Type key, ParrotContext value) {
    instances[key.hashCode] = value;
    hashes[key.hashCode] = key;
  }

  @override
  void addAll(Map<Type, ParrotContext> other) {
    instances.addAll(other.map((key, value) => MapEntry(key.hashCode, value)));
    hashes.addAll(other.map((key, value) => MapEntry(key.hashCode, key)));
  }

  @override
  void addEntries(Iterable<MapEntry<Type, ParrotContext>> newEntries) {
    instances.addEntries(
        newEntries.map((entry) => MapEntry(entry.key.hashCode, entry.value)));
    hashes.addEntries(
        newEntries.map((entry) => MapEntry(entry.key.hashCode, entry.key)));
  }

  @override
  Map<RK, RV> cast<RK, RV>() => instances.cast<RK, RV>();

  @override
  void clear() {
    instances.clear();
    hashes.clear();
  }

  @override
  bool containsKey(Object? key) => instances.containsKey(key.hashCode);

  @override
  bool containsValue(Object? value) => instances.containsValue(value);

  @override
  Iterable<MapEntry<Type, ParrotContext>> get entries {
    return instances.entries
        .map((entry) => MapEntry(hashes[entry.key]!, entry.value));
  }

  @override
  void forEach(void Function(Type key, ParrotContext value) action) {
    instances.forEach((key, value) => action(hashes[key]!, value));
  }

  @override
  bool get isEmpty => instances.isEmpty;

  @override
  bool get isNotEmpty => instances.isNotEmpty;

  @override
  Iterable<Type> get keys {
    return instances.keys.map((key) => hashes[key]!);
  }

  @override
  int get length => instances.length;

  @override
  Map<K2, V2> map<K2, V2>(
    MapEntry<K2, V2> Function(Type key, ParrotContext value) convert,
  ) {
    return instances.map((key, value) => convert(hashes[key]!, value));
  }

  @override
  ParrotContext putIfAbsent(Type key, ParrotContext Function() ifAbsent) {
    return instances.putIfAbsent(key.hashCode, () {
      hashes[key.hashCode] = key;

      return ifAbsent();
    });
  }

  @override
  ParrotContext? remove(Object? key) {
    hashes.remove(key.hashCode);
    return instances.remove(key.hashCode);
  }

  @override
  void removeWhere(bool Function(Type key, ParrotContext value) test) {
    instances.removeWhere((hash, value) => test(hashes[hash]!, value));
  }

  @override
  ParrotContext update(
      Type key, ParrotContext Function(ParrotContext value) update,
      {ParrotContext Function()? ifAbsent}) {
    return instances.update(key.hashCode, (value) {
      hashes[key.hashCode] = key;
      return update(value);
    }, ifAbsent: ifAbsent);
  }

  @override
  void updateAll(ParrotContext Function(Type key, ParrotContext value) update) {
    instances.updateAll((hash, value) => update(hashes[hash]!, value));
  }

  @override
  Iterable<ParrotContext> get values => instances.values;
}
