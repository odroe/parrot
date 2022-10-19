part of parrot.cmd;

typedef CommandProvider<T> = Provider<Command<T>>;

extension UseCommandExtension on Module {
  /// Register a top-level command.
  ///
  /// ```dart
  /// final module = Module().useCommand(<COMMAND-PROVIDER>)
  /// ```
  Module useCommand<T>(CommandProvider<T> command) =>
      _UseCommandWrapper<T>(this, command);
}

class _UseCommandWrapper<T> implements Module, UseModuleEffect {
  const _UseCommandWrapper(this._module, this._command);

  final Module _module;
  final CommandProvider<T> _command;

  @override
  Set<Object> get exports => _module.exports;

  @override
  Set<Module> get imports => {..._module.imports, CommandModule<T>()};

  @override
  Set<Provider> get providers => _module.providers;

  @override
  Future<void> effect(ModuleRef ref, ModuleEffectNext next) async {
    return _resolveEffectNext(ref, next).call().then((void_) async {
      final CommandRunner<T> runner = await ref(_commandRunnerProvider<T>);
      final CommandRunner<T> runner2 = await ref(_commandRunnerProvider<T>);

      print(runner == runner2);

      final Command<T> command = await ref(_command);

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
