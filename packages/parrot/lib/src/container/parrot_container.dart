import 'instance_wrapper.dart';
import 'instance_provider.dart';

/// Parrot Container.
///
/// The container is manage all instances.
abstract class ParrotContainer extends Iterable<InstanceProvider> {
  /// Create a new container.
  factory ParrotContainer() = _ParrotContainerImpl;

  /// Check a instance is registered.
  bool has(Object token);

  /// Returns a [Provider] instance.
  InstanceProvider<T> getInstanceProvider<T>(Object token);

  /// Returns a [InstanceWrapper] instance.
  Future<InstanceWrapper<T>> getInstanceWrapper<T>(Object token);

  /// Returns a instance.
  Future<T> getInstance<T>(Object token);

  /// Add a [Provider] instance.
  Future<void> addInstanceProvider<T>(InstanceProvider<T> provider);

  /// Add a [InstanceWrapper] instance.
  void addInstanceWrapper<T>(InstanceWrapper<T> instanceWrapper);
}

/// Parrot Container implementation.
class _ParrotContainerImpl extends Iterable<InstanceProvider>
    implements ParrotContainer {
  /// Registered providers.
  final Set<InstanceProvider> _providers = {};

  /// Reolved instances.
  final Map<InstanceProvider, InstanceWrapper> _instances = {};

  @override
  Future<InstanceWrapper<T>> getInstanceWrapper<T>(Object token) async {
    final InstanceProvider<T> provider = getInstanceProvider<T>(token);

    if (_instances.containsKey(provider)) {
      return _instances[provider] as InstanceWrapper<T>;
    }

    return _getInstanceWrappperByProvider<T>(provider);
  }

  @override
  InstanceProvider<T> getInstanceProvider<T>(Object token) =>
      _providers.firstWhere(
        (provider) => provider.token == token,
        orElse: () => throw Exception('Provider not found.'),
      ) as InstanceProvider<T>;

  @override
  bool has(Object token) =>
      _providers.any((InstanceProvider provider) => provider.token == token);

  @override
  Iterator<InstanceProvider> get iterator => _providers.iterator;

  @override
  void addInstanceWrapper<T>(InstanceWrapper<T> instanceWrapper) {
    _instances.putIfAbsent(instanceWrapper.provider, () => instanceWrapper);
    _onlyAddProvider(instanceWrapper.provider);
  }

  @override
  Future<void> addInstanceProvider<T>(InstanceProvider<T> provider) async {
    /// If the provider is eager, resolve the instance.
    if (provider is EagerInstanceProvider<T>) {
      await _getInstanceWrappperByProvider<T>(provider);
    }

    _onlyAddProvider(provider);
  }

  /// Only add a provider.
  void _onlyAddProvider<T>(InstanceProvider<T> provider) {
    if (!_providers.contains(provider)) {
      _providers.add(provider);
    }
  }

  /// Create or get a [InstanceWrapper] with a [Provider].
  Future<InstanceWrapper<T>> _getInstanceWrappperByProvider<T>(
      InstanceProvider<T> provider) async {
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
