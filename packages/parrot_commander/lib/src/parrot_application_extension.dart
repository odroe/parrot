import 'package:args/command_runner.dart';
import 'package:parrot/parrot.dart';

import 'commander_module.dart';

extension CommandRunnerExtension on ParrotApplication {
  /// Calls [CommandRunner.run] method.
  Future<T?> run<T>(Iterable<String> args) async {
    final ModuleRef module = select(CommanderModule<T>);
    final CommandRunner<T> runner = await module.find(CommandRunner<T>);

    return runner.run(args);
  }
}
