import 'package:parrot/src/container/v1/internal/helpers/interpreter.dart';
import 'package:test/scaffolding.dart';

void main() {
  test("should run", () {
    final program = SimpleProgram();

    program.interprete(Sequence([
      WriteState(([
        (parent) => Parameter(0, 1, parent: parent),
        (parent) => Parameter(1, 2, parent: parent),
      ])),
      Sum(),
    ]));
  });
}

class Sum implements Instruction {
  @override
  Tuple2<Context, Option<Instruction>> run(
    Context context,
    InstructionTracer tracer,
  ) {
    final contextMut = context.mutable;

    final first = context
        .whereType<Parameter>()
        .firstWhere((param) => param.offset == 0)
        .value as int;
    final second = context
        .whereType<Parameter>()
        .firstWhere((param) => param.offset == 1)
        .value as int;

    contextMut.apply((parent) => ReturnValue(first + second, parent: parent));
    return Tuple2(contextMut.snapshot, None());
  }

  @override
  String toString() {
    return "Sum()";
  }
}

class SimpleProgram implements Interpreter, InstructionTracer {
  bool enableTrace = false;

  List<TraceMarker> trace = [];

  @override
  void interprete(Instruction instruction) {
    final state = runUntilStop(Environment(), instruction, this);

    for (final node in state.toList().reversed) {
      print(node.toString());
    }
  }

  @override
  Context enter(Context context, Instruction instruction) {
    if (!enableTrace) {
      return context;
    }
    return context.mutable
        .apply((parent) => EnterInstruction(instruction, parent: parent));
  }

  @override
  Context leave(Context context, Instruction instruction) {
    if (!enableTrace) {
      return context;
    }
    return context.mutable
        .apply((parent) => LeaveInstruction(instruction, parent: parent));
  }

  @override
  Context interrupt(Context context) {
    return context;
  }
}

class Environment extends State implements TraceMarker {
  const Environment();

  @override
  Context? get parent => null;

  @override
  String toString() {
    return "Environment()";
  }
}
