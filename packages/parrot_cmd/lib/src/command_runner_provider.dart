part of parrot.cmd;

/// Command runner provider.
Future<CommandRunner> _commandRunnerProvider(ModuleRef ref) async {
  final _CommandRunnerInfoImpl info =
      (await ref(CommandRunnrtInfo.provider)) as _CommandRunnerInfoImpl;

  if (info.commandRunner != null) {
    return info.commandRunner!;
  }

  final runner = CommandRunner(
    info.executableName,
    info.description,
    usageLineLength: info.usageLineLength,
    suggestionDistanceLimit: info.suggestionDistanceLimit,
  );

  return runner;
}
