part of parrot.cmd;

class CommandModule<T> implements Module {
  const CommandModule._internal();

  static final Map<Type, CommandModule> _modules = <Type, CommandModule>{};

  factory CommandModule() =>
      _modules.putIfAbsent(T, () => CommandModule<T>._internal())
          as CommandModule<T>;

  @override
  Set<Module> get imports => const {};

  @override
  Set<Object> get exports => {
        _commandRunnerProvider<T>,
        argParserProvider<T>,
        CommandRunnrtInfo.provider<T>,
      };

  @override
  Set<Provider> get providers => {
        _commandRunnerProvider<T>,
        argParserProvider<T>,
        CommandRunnrtInfo.provider<T>,
      };
}
