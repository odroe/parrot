import 'instance_provider.dart';

/// Instance Wrapper.
///
/// Wrap the instance with an [Provider].
abstract class InstanceWrapper<T> {
  /// Create a new [InstanceWrapper] instance.
  factory InstanceWrapper({
    required InstanceProvider<T> provider,
    required T instance,
  }) = _InstanceWrapper<T>;

  /// Instance provider.
  InstanceProvider get provider;

  /// Instance value.
  T get instance;
}

/// Instance wrapper implementation.
class _InstanceWrapper<T> implements InstanceWrapper<T> {
  @override
  final InstanceProvider<T> provider;

  @override
  final T instance;

  const _InstanceWrapper({
    required this.provider,
    required this.instance,
  });
}
