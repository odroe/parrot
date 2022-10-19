library parrot.cmd;

import 'package:args/command_runner.dart';
import 'package:parrot/parrot.dart';

abstract class CommandRunnrtInfo {
  String get executableName;
  String get description;
  int? get usageLineLength;
  int get suggestionDistanceLimit;

  set executableName(String name);
  set description(String description);
  set usageLineLength(int? length);
  set suggestionDistanceLimit(int limit);
}

class _CommandRunnerInfoImpl implements CommandRunnrtInfo {
  @override
  String description = "";

  @override
  String executableName = 'dart run <pkg>';

  @override
  int suggestionDistanceLimit = 2;

  @override
  int? usageLineLength;
}

CommandRunnrtInfo _commandRunnrtInfo(ModuleRef ref) => _CommandRunnerInfoImpl();
Future<CommandRunner> _commandRunner(ModuleRef ref) async {
  final CommandRunnrtInfo info = await ref(_commandRunnrtInfo);

  return CommandRunner(
    info.executableName,
    info.description,
    usageLineLength: info.usageLineLength,
    suggestionDistanceLimit: info.suggestionDistanceLimit,
  );
}

final module = Module(
  providers: {
    _commandRunnrtInfo,
    _commandRunner,
  },
).useEffect((ref) async {
  final info = await ref(_commandRunnrtInfo);
  info.description = '222';
});

void main(List<String> args) async {
  final app = Parrot(module);

  final demo = await app.resolve(_commandRunner);

  print(demo.commands);
}
