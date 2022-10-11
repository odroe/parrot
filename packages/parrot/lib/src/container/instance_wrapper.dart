import 'instance_context.dart';

/// Instance Wrapper.
///
/// Wrap the instance with an [Provider].
abstract class InstanceWrapper<T> {
  /// Create a new [InstanceWrapper] instance.
  factory InstanceWrapper({
    required InstanceContext<T> context,
    required T instance,
  }) = _InstanceWrapper<T>;

  /// Instance context.
  InstanceContext get context;

  /// Instance value.
  T get instance;
}

/// Instance wrapper implementation.
class _InstanceWrapper<T> implements InstanceWrapper<T> {
  @override
  final InstanceContext<T> context;

  @override
  final T instance;

  const _InstanceWrapper({
    required this.context,
    required this.instance,
  });
}
