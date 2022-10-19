part of parrot.cmd;

/// Command runner info.
abstract class CommandRunnrtInfo<T> {
  /// Set command executable name.
  set executableName(String name);

  /// Set command description.
  set description(String description);

  /// Set command usage line.
  set usageLineLength(int? length);

  /// Set suggestion distance limit.
  set suggestionDistanceLimit(int limit);

  /// Custom command runner.
  set commandRunner(CommandRunner<T> runner);

  /// Command runner info provider.
  ///
  /// ```dart
  /// final info = await ref(CommandRunnrtInfo.provider); // CommandRunnrtInfo<dunamic>
  /// final info2 = await ref(CommandRunnrtInfo.provider<int>) // CommandRunnrtInfo<int>
  /// ```
  static const CommandRunnrtInfo<T> Function<T>(ModuleRef ref) provider =
      _CommandRunnerInfoImpl.upsert;
}

class _CommandRunnerInfoImpl<T> implements CommandRunnrtInfo<T> {
  _CommandRunnerInfoImpl._internal();

  /// Cached command runner info.
  static final Map<Type, _CommandRunnerInfoImpl> _cache =
      <Type, _CommandRunnerInfoImpl>{};

  /// Create new command runner info.
  factory _CommandRunnerInfoImpl.upsert(ModuleRef ref) {
    return _cache.putIfAbsent(T, () => _CommandRunnerInfoImpl<T>._internal())
        as _CommandRunnerInfoImpl<T>;
  }

  @override
  String description = r'<description>';

  @override
  String executableName = r'<executable>';

  @override
  int suggestionDistanceLimit = 2;

  @override
  int? usageLineLength;

  @override
  CommandRunner<T>? commandRunner;
}
