import 'container.dart';

abstract class Interpreter {
  void interprete(Instruction instruction);
}

abstract class Instruction {
  Tuple2<Context, Option<Instruction>> run(
    Context context,
    InstructionTracer tracer,
  );
}

abstract class InstructionTracer {
  Context enter(Context context, Instruction instruction);

  Context leave(Context context, Instruction instruction);

  Context interrupt(Context context);
}

abstract class InstructionTraceOverride {
  bool get shouldTrace;
}

extension InstructionTracerExtensions on InstructionTracer {
  Tuple2<Context, Option<Instruction>> traceAndRun(
    Context context,
    Instruction instruction,
  ) {
    Context currentContext = context;

    bool shouldTraceCurrentInstruction = true;
    if (instruction is InstructionTraceOverride) {
      shouldTraceCurrentInstruction =
          (instruction as InstructionTraceOverride).shouldTrace;
    }

    if (shouldTraceCurrentInstruction) {
      currentContext = enter(currentContext, instruction);
    }

    final next = instruction.run(currentContext, this);
    currentContext = next.first;

    if (shouldTraceCurrentInstruction) {
      currentContext = leave(currentContext, instruction);
    }

    return Tuple2(currentContext, next.second);
  }
}

class Sequence implements Instruction, InstructionTraceOverride {
  const Sequence(this.instructions);

  @override
  bool get shouldTrace => false;

  final Iterable<Instruction> instructions;

  @override
  Tuple2<Context, Option<Instruction>> run(
    Context context,
    InstructionTracer tracer,
  ) {
    Context currentState = context;
    for (final instruction in instructions) {
      currentState = runUntilStop(currentState, instruction, tracer);
    }

    return Tuple2(currentState, None());
  }

  @override
  String toString() {
    return "Sequence()";
  }
}

class Parallel implements Instruction, InstructionTraceOverride {
  const Parallel(this.instructions);

  @override
  bool get shouldTrace => false;

  final Iterable<Instruction> instructions;

  @override
  Tuple2<Context, Option<Instruction>> run(
    Context context,
    InstructionTracer tracer,
  ) {
    for (final instruction in instructions) {
      runUntilStop(context, instruction, tracer);
    }

    return Tuple2(context, None());
  }

  @override
  String toString() {
    return "Parallel()";
  }
}

class Condition implements Instruction {
  const Condition(this.evaluator, this.ifTrue, this.ifFalse);

  final bool Function(Context context) evaluator;

  final Instruction ifTrue;

  final Instruction ifFalse;

  @override
  Tuple2<Context, Option<Instruction>> run(
    Context context,
    InstructionTracer tracer,
  ) {
    return Tuple2(context, Some(evaluator(context) ? ifTrue : ifFalse));
  }

  @override
  String toString() {
    return "Condition()";
  }
}

class InstructionMarker extends Marker {
  const InstructionMarker(this.instruction, {this.parent});

  @override
  final Context? parent;

  final Instruction instruction;

  @override
  String toString() {
    return "InstructionMarker(instruction=${instruction.toString()})";
  }
}

abstract class TraceMarker {}

class EnterInstruction extends Marker implements TraceMarker {
  const EnterInstruction(this.instruction, {this.parent});

  @override
  final Context? parent;

  final Instruction instruction;

  @override
  String toString() {
    return "EnterInstruction(instruction=${instruction.toString()})";
  }
}

class LeaveInstruction extends Marker implements TraceMarker {
  const LeaveInstruction(this.instruction, {this.parent});

  @override
  final Context? parent;

  final Instruction instruction;

  @override
  String toString() {
    return "LeaveInstruction(instruction=${instruction.toString()})";
  }
}

class ApplyContext implements Instruction {
  const ApplyContext(this.builder);

  final ContextBuilder builder;

  @override
  Tuple2<Context, Option<Instruction>> run(
    Context context,
    InstructionTracer tracer,
  ) {
    return Tuple2(context.mutable.apply(builder), None());
  }

  @override
  String toString() {
    return "ApplyContext()";
  }
}

Context runUntilStop(
  Context context,
  Instruction instruction,
  InstructionTracer tracer,
) {
  final queue = <Instruction>[];
  Context currentState = context;

  queue.add(instruction);
  while (queue.isNotEmpty) {
    final currentInstruction = queue.removeAt(0);

    final next = tracer.traceAndRun(currentState, currentInstruction);
    currentState = next.first;
    if (next.second.hasValue) {
      queue.add(next.second.value);
    }
  }

  return currentState;
}
