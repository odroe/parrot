/// Command registrar
abstract class CommandRegistrar<T> {
  const CommandRegistrar();

  /// Register commands.
  Set<Object> get commands;
}
