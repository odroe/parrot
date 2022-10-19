part of parrot.cmd;

extension ParrotCommandRunnerExtension on Parrot {
  /// Runs the command line application.
  Future<T?> run<T>(Iterable<String> arguments) async {
    final CommandRunner<T> runner = await resolve(_commandRunnerProvider<T>);

    return runner.run(arguments);
  }
}
