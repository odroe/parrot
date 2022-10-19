part of parrot.cmd;

Future<ArgParser> argParserProvider(ModuleRef ref) async {
  final CommandRunner runner = await ref(_commandRunnerProvider);

  return runner.argParser;
}
