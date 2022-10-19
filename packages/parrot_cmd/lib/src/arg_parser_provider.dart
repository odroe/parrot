part of parrot.cmd;

Future<ArgParser> argParserProvider<T>(ModuleRef ref) async {
  final CommandRunner<T> runner = await ref(_commandRunnerProvider<T>);

  return runner.argParser;
}
