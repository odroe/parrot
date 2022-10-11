import 'instance_wrapper.dart';
import 'instance_context.dart';

/// Parrot Container.
///
/// The container is manage all instances.
abstract class ParrotContainer extends Iterable<InstanceContext> {
  /// Create a new container.
  factory ParrotContainer() = _ParrotContainerImpl;

  /// Check a instance is registered.
  bool has(Object token);

  /// Returns a [InstanceContext] instance.
  InstanceContext<T> getInstanceContext<T>(Object token);

  /// Returns a [InstanceWrapper] instance.
  Future<InstanceWrapper<T>> getInstanceWrapper<T>(Object token);

  /// Returns a instance.
  Future<T> getInstance<T>(Object token);

  /// Add a [Provider] instance.
  void addInstanceContext<T>(InstanceContext<T> context);

  /// Add a [InstanceWrapper] instance.
  void addInstanceWrapper<T>(InstanceWrapper<T> instanceWrapper);
}

/// Parrot Container implementation.
class _ParrotContainerImpl extends Iterable<InstanceContext>
    implements ParrotContainer {
  /// Registered providers.
  final Set<InstanceContext> _contexts = {};

  /// Reolved instances.
  final Map<InstanceContext, InstanceWrapper> _instances = {};

  @override
  Future<InstanceWrapper<T>> getInstanceWrapper<T>(Object token) async {
    final InstanceContext<T> context = getInstanceContext<T>(token);

    if (_instances.containsKey(context)) {
      return _instances[context] as InstanceWrapper<T>;
    }

    return _getInstanceWrappperByContext<T>(context);
  }

  @override
  InstanceContext<T> getInstanceContext<T>(Object token) =>
      _contexts.firstWhere(
        (context) => context.equal(token),
        orElse: () => throw Exception('The $token is not found.'),
      ) as InstanceContext<T>;

  @override
  bool has(Object token) =>
      _contexts.any((InstanceContext context) => context.equal(token));

  @override
  Iterator<InstanceContext> get iterator => _contexts.iterator;

  @override
  void addInstanceWrapper<T>(InstanceWrapper<T> instanceWrapper) {
    _instances[instanceWrapper.context] = instanceWrapper;

    addInstanceContext(instanceWrapper.context);
  }

  @override
  void addInstanceContext<T>(InstanceContext<T> context) async {
    if (!_contexts.contains(context)) {
      _contexts.add(context);
    }
  }

  /// Create or get a [InstanceWrapper] with a [Provider].
  Future<InstanceWrapper<T>> _getInstanceWrappperByContext<T>(
      InstanceContext<T> context) async {
    if (_instances.containsKey(context)) {
      return _instances[context] as InstanceWrapper<T>;
    }

    final T instance = await context.factory();
    final InstanceWrapper<T> instanceWrapper = InstanceWrapper<T>(
      context: context,
      instance: instance,
    );

    return _instances.putIfAbsent(context, () => instanceWrapper)
        as InstanceWrapper<T>;
  }

  @override
  Future<T> getInstance<T>(Object token) async {
    final InstanceWrapper<T> instanceWrapper =
        await getInstanceWrapper<T>(token);
    return instanceWrapper.instance;
  }
}
