part of parrot.cmd;

/// Create a closure command.
CommandProvider createClosureCommand<T>(
  String name,
  String description,
  FutureOr<T> Function(ArgResults argResults, ModuleRef ref) run, {
  void Function(ArgParser argParser)? configure,
}) =>
    (ModuleRef ref) => _ClosureCommandImpl(
        name: name,
        description: description,
        handler: run,
        configure: configure,
        ref: ref);

class _ClosureCommandImpl<T> extends Command<T> {
  _ClosureCommandImpl({
    required this.name,
    required this.description,
    required this.handler,
    required this.ref,
    void Function(ArgParser argParser)? configure,
  }) {
    configure?.call(argParser);
  }

  final FutureOr<T> Function(ArgResults argResults, ModuleRef ref) handler;
  final ModuleRef ref;

  @override
  final String description;

  @override
  final String name;

  @override
  FutureOr<T> run() => handler(argResults!, ref);
}
