part of parrot.cmd;

/// Command runner provider.
Future<CommandRunner<T>> _commandRunnerProvider<T>(ModuleRef ref) async {
  final _CommandRunnerInfoImpl<T> info =
      (await ref(CommandRunnrtInfo.provider<T>)) as _CommandRunnerInfoImpl<T>;

  if (info.commandRunner != null) {
    return info.commandRunner!;
  }

  final runner = CommandRunner<T>(
    info.executableName,
    info.description,
    usageLineLength: info.usageLineLength,
    suggestionDistanceLimit: info.suggestionDistanceLimit,
  );

  return runner;

  return info.commandRunner = runner;
}
