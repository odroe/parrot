import 'package:args/command_runner.dart';
import 'package:parrot/parrot.dart';
import 'package:parrot_cmd/parrot_cmd.dart';

class SayCommand extends Command<int> {
  SayCommand(ModuleRef ref);

  @override
  String get description => 'demo';

  @override
  String get name => 'say';
}

final root = Module(imports: {
  CommandModule<int>(),
}, providers: {
  SayCommand.new
}).useCommand(SayCommand.new).useEffect((ref, next) async {
  final info = await ref(CommandRunnrtInfo.provider<int>);

  info.executableName = '111';

  return next();
}).useEffect((ref, next) async {
  final info = await ref(CommandRunnrtInfo.provider<int>);

  info.description = '22222';

  return next();
}).useEffect((ref, next) async {
  final args = await ref(argParserProvider<int>);

  return next();
});

void main(List<String> args) {
  final app = Parrot(root);

  app.run<int>(args);
}
