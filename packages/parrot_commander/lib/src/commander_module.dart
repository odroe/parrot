import 'package:args/command_runner.dart';
import 'package:parrot/parrot.dart';

@Module()
class CommanderModule<T> extends DynamicModule {
  const CommanderModule({
    required this.name,
    required this.description,
    this.suggestionDistanceLimit = 2,
    this.usageLineLength,
  });

  /// Executable name.
  final String name;

  /// Executable description.
  final String description;

  /// Usage line length.
  final int? usageLineLength;

  /// Suggestion distance limit.
  final int suggestionDistanceLimit;

  @override
  Type get module => CommanderModule<T>;

  @override
  bool get global => true;

  @override
  Set<Object> get providers => {_commandRunnerProvider};

  /// Create [CommandRunner<T>] instance.
  CommandRunner<T> _createCommandRunner() => CommandRunner<T>(
        name,
        description,
        usageLineLength: usageLineLength,
        suggestionDistanceLimit: suggestionDistanceLimit,
      );

  /// Create provider for [CommandRunner<T>].
  FactoryProvider get _commandRunnerProvider => FactoryProvider(
      token: CommandRunner<T>, useFactory: _createCommandRunner);
}
