class MapCache<K, V> {
  final Map<K, V> entries = {};

  bool has(K key) {
    return entries.containsKey(key);
  }

  V? tryGet(K key, {V Function()? ifAbsent}) {
    return entries.containsKey(key) ? entries[key]! : ifAbsent?.callFunction();
  }

  V mustGet(K key, {void Function()? ifThrow}) {
    if (!entries.containsKey(key)) {
      if (ifThrow != null) {
        ifThrow();
      }
      throw RangeError("out of range");
    }

    return entries[key]!;
  }

  V update(K key, V value) {
    entries[key] = value;
    return value;
  }

  V updateIfAbsent(K key, V value) {
    if (has(key)) {
      return mustGet(key);
    }

    return update(key, value);
  }

  void invalidate(K key) {
    entries.remove(key);
  }

  void invalidateAll() {
    entries.clear();
  }

  Map<K, V> toMap() {
    return Map.fromEntries(entries.entries);
  }
}

class CachedValue<T> {
  CachedValue(this.updater);

  final T Function() updater;

  bool _invalidated = true;

  T? _cache;

  T get value => _getOrUpdate();

  void invalidate() {
    _invalidated = true;
  }

  T updateAndGet() {
    _cache = _getOrUpdate();
    _invalidated = false;
    return _cache!;
  }

  T _getOrUpdate() {
    if (!_invalidated) {
      return updateAndGet();
    }
    return _cache!;
  }
}
