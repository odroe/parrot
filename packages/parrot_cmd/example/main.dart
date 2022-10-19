import 'package:args/command_runner.dart';
import 'package:parrot/parrot.dart';
import 'package:parrot_cmd/parrot_cmd.dart';

class SayCommand extends Command {
  SayCommand(ModuleRef ref) {
    argParser.addOption('word',
        abbr: 'w', help: 'Word to say', defaultsTo: "World");
  }

  @override
  String get description => 'Say something';

  @override
  String get name => 'say';

  @override
  Future<void> run() async {
    final word = argResults!['word'] as String;

    print('Hello $word');
  }
}

final root = Module(
  providers: {SayCommand.new},
).useCommands([SayCommand.new]);

void main(List<String> args) {
  final app = Parrot(root);

  app.run(args);
}
