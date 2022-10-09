import 'instance_wrapper.dart';
import 'provider.dart';

/// Parrot Container.
///
/// The container is manage all instances.
abstract class ParrotContainer extends Iterable<Provider> {
  /// Create a new container.
  factory ParrotContainer() = _ParrotContainerImpl;

  /// Check a instance is registered.
  bool has(Object token);

  /// Returns a [Provider] instance.
  Provider<T> getProvider<T>(Object token);

  /// Returns a [InstanceWrapper] instance.
  Future<InstanceWrapper<T>> getInstanceWrapper<T>(Object token);

  /// Returns a instance.
  Future<T> getInstance<T>(Object token);

  /// Add a [Provider] instance.
  Future<void> addProvider<T>(Provider<T> provider);

  /// Add a [InstanceWrapper] instance.
  void addInstanceWrapper<T>(InstanceWrapper<T> instanceWrapper);
}

/// Parrot Container implementation.
class _ParrotContainerImpl extends Iterable<Provider>
    implements ParrotContainer {
  /// Registered providers.
  final Set<Provider> _providers = {};

  /// Reolved instances.
  final Map<Provider, InstanceWrapper> _instances = {};

  @override
  Future<InstanceWrapper<T>> getInstanceWrapper<T>(Object token) async {
    final Provider<T> provider = getProvider<T>(token);

    if (_instances.containsKey(provider)) {
      return _instances[provider] as InstanceWrapper<T>;
    }

    return _getInstanceWrappperByProvider<T>(provider);
  }

  @override
  Provider<T> getProvider<T>(Object token) => _providers.firstWhere(
        (provider) => provider.token == token,
        orElse: () => throw Exception('Provider not found.'),
      ) as Provider<T>;

  @override
  bool has(Object token) =>
      _providers.any((Provider provider) => provider.token == token);

  @override
  Iterator<Provider> get iterator => _providers.iterator;

  @override
  void addInstanceWrapper<T>(InstanceWrapper<T> instanceWrapper) {
    _instances.putIfAbsent(instanceWrapper.provider, () => instanceWrapper);
    _onlyAddProvider(instanceWrapper.provider);
  }

  @override
  Future<void> addProvider<T>(Provider<T> provider) async {
    /// If the provider is eager, resolve the instance.
    if (provider is EagerProvider<T>) {
      await _getInstanceWrappperByProvider<T>(provider);
    }

    _onlyAddProvider(provider);
  }

  /// Only add a provider.
  void _onlyAddProvider<T>(Provider<T> provider) {
    if (!_providers.contains(provider)) {
      _providers.add(provider);
    }
  }

  /// Create or get a [InstanceWrapper] with a [Provider].
  Future<InstanceWrapper<T>> _getInstanceWrappperByProvider<T>(
      Provider<T> provider) async {
    if (_instances.containsKey(provider)) {
      return _instances[provider] as InstanceWrapper<T>;
    }

    final T instance = await provider.factory(this);
    final InstanceWrapper<T> instanceWrapper = InstanceWrapper<T>(
      provider: provider,
      instance: instance,
    );

    return _instances.putIfAbsent(provider, () => instanceWrapper)
        as InstanceWrapper<T>;
  }

  @override
  Future<T> getInstance<T>(Object token) async {
    final InstanceWrapper<T> instanceWrapper =
        await getInstanceWrapper<T>(token);
    return instanceWrapper.instance;
  }
}
