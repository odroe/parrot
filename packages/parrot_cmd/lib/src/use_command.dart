part of parrot.cmd;

typedef CommandProvider = Provider<Command>;

extension UseCommandExtension on Module {
  /// Register a top-level command.
  ///
  /// ```dart
  /// final module = Module().useCommand(<COMMAND-PROVIDER>)
  /// ```
  Module useCommand(CommandProvider command) =>
      _UseCommandWrapper(this, command);

  /// Register commands to top-level.
  Module useCommands(Iterable<CommandProvider> commands) =>
      commands.fold(this, (module, command) => module.useCommand(command));
}

class _UseCommandWrapper implements Module, UseModuleEffect {
  const _UseCommandWrapper(this._module, this._command);

  final Module _module;
  final CommandProvider _command;

  @override
  Set<Object> get exports => _module.exports;

  @override
  Set<Module> get imports => {..._module.imports, commandModule};

  @override
  Set<Provider> get providers => _module.providers;

  @override
  Future<void> effect(ModuleRef ref, ModuleEffectNext next) async {
    return _resolveEffectNext(ref, next).call().then((void_) async {
      final CommandRunner runner = await ref(_commandRunnerProvider);
      final Command command = await ref(_command);

      runner.addCommand(command);
    });
  }

  ModuleEffectNext _resolveEffectNext(ModuleRef ref, ModuleEffectNext next) {
    if (_module is UseModuleEffect) {
      final UseModuleEffect effectModule = _module as UseModuleEffect;

      return () => effectModule.effect(ref, next);
    }

    return next;
  }
}
