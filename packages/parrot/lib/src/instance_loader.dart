abstract class InstanceLoader {
  factory InstanceLoader() = _InstanceLoaderImpl;

  /// Prepare modules and dependencies
  Future<void> prepare(Object module);
}

/// Instance loader implementation.
class _InstanceLoaderImpl implements InstanceLoader {
  @override
  Future<void> prepare(Object module) {
    // TODO: implement prepare
    throw UnimplementedError();
  }
}
