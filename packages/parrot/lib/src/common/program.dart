import 'container.dart';
import 'interpreter.dart';

class ProgramInterpreter implements Interpreter, InstructionTracer {
  ProgramInterpreter();

  @override
  void interprete(Instruction instruction) {
    final context = Context.empty().mutable;

    runUntilStop(
      context.apply((parent) => ProgramHeader()),
      instruction,
      this,
    );
  }

  @override
  Context enter(Context context, Instruction instruction) {
    return context;
  }

  @override
  Context leave(Context context, Instruction instruction) {
    return context;
  }

  @override
  Context interrupt(Context context) {
    return context;
  }
}

class Program {
  Program();

  final List<ContextBuilder> _static = [];

  void defineEntrypoint(JustInTimeInvocation invocation) {
    defineFunction(Symbol("_main"), invocation);
  }

  void defineFunction(Object symbol, JustInTimeInvocation invocation) {
    _static.add(
      (parent) => FunctionDeclaration(
        symbol,
        CompileAndInvokeJustInTimeInvocation(
            JustInTimeInvocationCompiler(invocation)),
        parent: parent,
      ),
    );
  }

  Instruction compile() {
    return Sequence([
      ..._static.map((e) => ApplyContext(e)),
      InvokeDeclaredFunction(Symbol("_main"), ["./mysql -u root -p"])
    ]);
  }
}

typedef JustInTimeInvocation = Option<Object> Function(
  JustInTimeInvocationDelegate delegate,
);

class JustInTimeInvocationCompiler {
  const JustInTimeInvocationCompiler(this.invocation);

  final JustInTimeInvocation invocation;

  Tuple2<Context, Option<Instruction>> compileAndRun(
    JustInTimeContext context,
  ) {
    final delegate = JustInTimeInvocationDelegate(context);
    return delegate.compileAndRun(invocation);
  }
}

class JustInTimeInvocationDelegate {
  JustInTimeInvocationDelegate(this._context);

  final JustInTimeContext _context;

  final List<Instruction> _compiledInstructions = [];

  Iterable<Context> get _functionReferences =>
      _context.snapshot.whereType<FunctionReference>();

  Iterable<Context> get _stackFrame =>
      _context.snapshot.takeWhile((e) => e is! StackFrame);

  Iterable<Argument> get arguments => _stackFrame.whereType<Argument>();

  Iterable<VariableDeclaration> get variableDeclarations =>
      _stackFrame.whereType<VariableDeclaration>();

  Iterable<VariableOverride> get variableOverrides =>
      _stackFrame.whereType<VariableOverride>();

  int get numberOfArguments => arguments.length;

  Option<Object> getArgument(int offset) {
    return arguments
        .map<Option<Argument>>((e) => Some(e))
        .firstWhere((e) => e.value.offset == offset, orElse: () => None())
        .map((e) => e.value);
  }

  Option<Object> callFunction(Object symbol, Iterable<Object> arguments) {
    return _context
        .evaluateInIsolatedScope(InvokeDeclaredFunction(symbol, arguments))
        .whereType<ReturnValue>()
        .first
        .value;
  }

  void setVariable(Object symbol, Option<Object> value) {
    if (!variableDeclarations.any((e) => e.symbol == symbol)) {
      _context.evaluate(ApplyContext(
        (parent) => VariableDeclaration(symbol, value, parent: parent),
      ));
    }
    _context.evaluate(ApplyContext(
      (parent) => VariableOverride(symbol, value, parent: parent),
    ));
  }

  Option<Object> getVariable(Object symbol) {
    return variableOverrides
        .map<Option<VariableOverride>>((e) => Some(e))
        .firstWhere((e) => e.value.symbol == symbol, orElse: () => None());
  }

  void dumpState() {
    for (var element in _context.snapshot) {
      print(element);
    }
  }

  Tuple2<Context, Option<Instruction>> compileAndRun(
    JustInTimeInvocation invocation,
  ) {
    return Tuple2(
      _context.snapshot,
      Some(InvokeNativeFunction((_) => invocation.call(this))),
    );
  }
}

class JustInTimeContext {
  JustInTimeContext(this._context, this._tracer);

  final MutableContext _context;

  final InstructionTracer _tracer;

  Context get snapshot => _context.snapshot;

  Context evaluateInIsolatedScope(Instruction instruction) {
    return runUntilStop(snapshot, instruction, _tracer);
  }

  Context evaluate(Instruction instruction) {
    return _context
        .apply((parent) => runUntilStop(parent, instruction, _tracer));
  }
}

class ProgramHeader extends Marker {
  const ProgramHeader({this.parent});

  @override
  final Context? parent;

  @override
  String toString() {
    return "ProgramHeader()";
  }
}

class FunctionReference extends State {
  const FunctionReference(this.declaration, {this.parent});

  @override
  final Context? parent;

  final FunctionDeclaration declaration;

  @override
  String toString() {
    return "FunctionReference(declaration=${declaration.toString()})";
  }
}

class FunctionDeclaration extends State {
  const FunctionDeclaration(this.symbol, this.instruction, {this.parent});

  @override
  final Context? parent;

  final Object symbol;

  final Instruction instruction;

  ContextBuilder get reference =>
      (parent) => FunctionReference(this, parent: parent);

  @override
  String toString() {
    return "FunctionDeclaration(symbol=${symbol.toString()}, instruction=${instruction.toString()})";
  }
}

class CallSite extends State {
  const CallSite(this.context, {this.parent});

  @override
  final Context? parent;

  final Context context;

  @override
  String toString() {
    return "CallSite(context=${context.toString()})";
  }
}

class StackFrame extends Marker {
  const StackFrame({this.parent});

  @override
  final Context? parent;

  @override
  String toString() {
    return "StackFrame()";
  }
}

class Callee extends State {
  const Callee(this.context, this.instruction, {this.parent});

  @override
  final Context? parent;

  final Context context;

  final Instruction instruction;

  @override
  String toString() {
    return "Callee(context=${context.toString()}, instruction=${instruction.toString()})";
  }
}

class Argument extends State {
  const Argument(this.offset, this.value, {this.parent});

  static Iterable<Argument> from<T>(Context context) => context
      .takeWhile((context) => context is! EnterInstruction)
      .whereType<Argument>();

  @override
  final Context? parent;

  final int offset;

  final Object value;

  @override
  String toString() {
    return "Argument(position=${offset.toString()}, value=${value.toString()})";
  }
}

class VariableDeclaration extends State {
  const VariableDeclaration(this.symbol, this.value, {this.parent});

  @override
  final Context? parent;

  final Object symbol;

  final Option<Object> value;

  @override
  String toString() {
    return "VariableDeclaration(symbol=${symbol.toString()}, value=${value.toString()})";
  }
}

class VariableOverride extends State {
  const VariableOverride(this.symbol, this.value, {this.parent});

  @override
  final Context? parent;

  final Object symbol;

  final Option<Object> value;

  @override
  String toString() {
    return "VariableOverride(symbol=${symbol.toString()}, value=${value.toString()})";
  }
}

class ReturnValue extends Marker {
  const ReturnValue(this.value, {this.parent});

  @override
  final Context? parent;

  final Option<Object> value;

  @override
  String toString() {
    return "ReturnValue(value=${value.toString()})";
  }
}

class Interrupt implements Instruction {
  const Interrupt(this.handler);

  final Instruction handler;

  @override
  Tuple2<Context, Option<Instruction>> run(
    Context context,
    InstructionTracer tracer,
  ) {
    _runInIsolatedScope(context.mutable, tracer);

    return Tuple2(context, None());
  }

  void _runInIsolatedScope(
    MutableContext context,
    InstructionTracer tracer,
  ) {
    context.apply((parent) => CallSite(context.snapshot, parent: parent));
    runUntilStop(context, handler, tracer);
  }

  @override
  String toString() {
    return "Interrupt()";
  }
}

class InvokeNativeFunction implements Instruction {
  const InvokeNativeFunction(this.nativeFunction);

  final Option<Object> Function(Context context) nativeFunction;

  @override
  Tuple2<Context, Option<Instruction>> run(
    Context context,
    InstructionTracer tracer,
  ) {
    return Tuple2(_runInIsolatedScope(context), None());
  }

  Context _runInIsolatedScope(Context context) {
    final currentContext = context.mutable;

    currentContext
        .apply((parent) => CallSite(parent, parent: parent))
        .apply(_applyCallFrame(context, this, []));

    final result = nativeFunction(currentContext.snapshot);

    return currentContext
        .apply((parent) => ReturnValue(result, parent: parent));
  }

  @override
  String toString() {
    return "InvokeNativeFunction()";
  }
}

class InvokeFunction implements Instruction {
  const InvokeFunction(this.instruction, this.arguments);

  final Instruction instruction;

  final Iterable<Object> arguments;

  @override
  Tuple2<Context, Option<Instruction>> run(
    Context context,
    InstructionTracer tracer,
  ) {
    return Tuple2(_runInIsolatedScope(context, tracer), None());
  }

  Context _runInIsolatedScope(
    Context context,
    InstructionTracer tracer,
  ) {
    final currentContext = context.mutable;

    currentContext
        .apply((parent) => CallSite(parent, parent: parent))
        .apply(_applyCallFrame(context, this, arguments));

    final switchedContext =
        runUntilStop(currentContext.snapshot, instruction, tracer).mutable;

    if (!_findReturnValue(switchedContext).hasValue) {
      switchedContext.apply((parent) => ReturnValue(None(), parent: parent));
    }

    return switchedContext.snapshot;
  }

  Option<ReturnValue> _findReturnValue(Context context) {
    return context
        .takeWhile((e) => e is! StackFrame)
        .map<Option<Context>>((e) => Some(e))
        .firstWhere((e) => e.value is ReturnValue, orElse: () => None())
        .cast<ReturnValue>();
  }

  @override
  String toString() {
    return "InvokeFunction()";
  }
}

class InvokeDeclaredFunction implements Instruction {
  const InvokeDeclaredFunction(this.symbol, this.arguments);

  final Object symbol;

  final Iterable<Object> arguments;

  @override
  Tuple2<Context, Option<Instruction>> run(
    Context context,
    InstructionTracer tracer,
  ) {
    final declaration = _findFunctionDeclaration(context, symbol);

    return Tuple2(
      context,
      declaration.map(
        (declaration) => InvokeFunction(declaration.instruction, arguments),
      ),
    );
  }

  Option<FunctionDeclaration> _findFunctionDeclaration(
    Context context,
    Object symbol,
  ) {
    return context
        .whereType<FunctionDeclaration>()
        .map<Option<FunctionDeclaration>>((e) => Some(e))
        .firstWhere((e) => e.value.symbol == symbol, orElse: () => None());
  }

  @override
  String toString() {
    return "InvokeDeclaredFunction(symbol=${symbol.toString()})";
  }
}

class CompileAndInvokeJustInTimeInvocation implements Instruction {
  CompileAndInvokeJustInTimeInvocation(this.compiler);

  final JustInTimeInvocationCompiler compiler;

  @override
  Tuple2<Context, Option<Instruction>> run(
    Context context,
    InstructionTracer tracer,
  ) {
    return compiler.compileAndRun(JustInTimeContext(context.mutable, tracer));
  }

  @override
  String toString() {
    return "CompileAndInvokeJustInTimeInvocation()";
  }
}

class WriteRegister implements Instruction {
  const WriteRegister(this.symbol, this.value);

  final Object symbol;

  final Option<Object> value;

  @override
  Tuple2<Context, Option<Instruction>> run(
    Context context,
    InstructionTracer tracer,
  ) {
    return Tuple2(
      context.mutable.apply((parent) => Register(symbol, value)),
      None(),
    );
  }

  @override
  String toString() {
    return "WriteRegister(symbol=${symbol.toString()}, value=${value.toString()})";
  }
}

class Register extends State {
  const Register(this.symbol, this.value, {this.parent});

  @override
  final Context? parent;

  final Object symbol;

  final Option<Object> value;

  @override
  String toString() {
    return "Register(symbol=${symbol.toString()}, value=${value.toString()})";
  }
}

class Halt implements Instruction {
  @override
  Tuple2<Context, Option<Instruction>> run(
    Context context,
    InstructionTracer tracer,
  ) {
    return Tuple2(context, None());
  }

  @override
  String toString() {
    return "Halt()";
  }
}

ContextBuilder _applyCallFrame(
  Context currentContext,
  Instruction currentInstruction,
  Iterable<Object> arguments,
) {
  Context applyCallFrame(Context parent) {
    return Context.compose([
      (parent) => StackFrame(parent: parent),
      (parent) => Callee(currentContext, currentInstruction, parent: parent),
      (parent) => _applyArguments(arguments)(parent),
    ])(parent);
  }

  return applyCallFrame;
}

ContextBuilder _applyArguments(Iterable<Object> parameters) {
  Context applyArguments(Context parent) {
    int offset = 0;
    return parameters.fold(
      parent,
      (parent, value) => Argument(offset++, value, parent: parent),
    );
  }

  return applyArguments;
}