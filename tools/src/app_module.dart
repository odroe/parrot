import 'package:parrot/parrot.dart';
import 'package:parrot_cmd/parrot_cmd.dart';

import 'commands/license_consistency.dart';

/// Top-level command for the Parrot tools.
final Iterable<CommandProvider> commands = [
  licenseConsistencyCommand,
];

/// Command runner info effect
Future<void> commandRunnerInfoEffect(
    ModuleRef ref, ModuleEffectNext next) async {
  final CommandRunnrtInfo info = await ref(CommandRunnrtInfo.provider);

  info.executableName = 'dart run tools/bin.dart';
  info.description = 'Parrot development tool command-line application.';

  return next();
}

/// Create tools app module
final Module appModule =
    Module().useCommands(commands).useEffect(commandRunnerInfoEffect);
