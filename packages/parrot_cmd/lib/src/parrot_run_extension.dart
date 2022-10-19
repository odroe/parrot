part of parrot.cmd;

extension ParrotCommandRunnerExtension on Parrot {
  /// Runs the command line application.
  Future<dynamic> run(Iterable<String> arguments) async {
    final CommandRunner runner = await resolve(_commandRunnerProvider);

    return runner.run(arguments);
  }
}
