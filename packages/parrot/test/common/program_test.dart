import 'package:test/scaffolding.dart';

import 'package:parrot/src/common/container.dart';
import 'package:parrot/src/common/program.dart';

void main() {
  test("should run", () {
    final program = Program();
    final interpreter = ProgramInterpreter();

    program.defineFunction(Symbol("sum"), (context) {
      final first = context.getArgument(0).cast<int>();
      final second = context.getArgument(1).cast<int>();

      context.dumpState();

      return Some(first.value + second.value);
    });
    program.defineEntrypoint((context) {
      context.callFunction(Symbol("sum"), const [1, 2]);

      return None();
    });

    interpreter.interprete(program.compile());
  });
}
