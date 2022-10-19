part of parrot.cmd;

/// Command runner info.
abstract class CommandRunnrtInfo {
  /// Set command executable name.
  set executableName(String name);

  /// Set command description.
  set description(String description);

  /// Set command usage line.
  set usageLineLength(int? length);

  /// Set suggestion distance limit.
  set suggestionDistanceLimit(int limit);

  /// Custom command runner.
  set commandRunner(CommandRunner runner);

  /// Command runner info provider.
  ///
  /// ```dart
  /// final info = await ref(CommandRunnrtInfo.provider); // CommandRunnrtInfo<dunamic>
  /// final info2 = await ref(CommandRunnrtInfo.provider<int>) // CommandRunnrtInfo<int>
  /// ```
  static final Provider<CommandRunnrtInfo> provider =
      _CommandRunnerInfoImpl._internal;
}

class _CommandRunnerInfoImpl implements CommandRunnrtInfo {
  _CommandRunnerInfoImpl._internal(ModuleRef ref);

  @override
  String description = r'<description>';

  @override
  String executableName = r'<executable>';

  @override
  int suggestionDistanceLimit = 2;

  @override
  int? usageLineLength;

  @override
  CommandRunner? commandRunner;
}
