import 'parrot_token.dart';

class ParrotContainer extends Iterable<ParrotToken> {
  final Set<ParrotToken> _tokens = {};

  @override
  Iterator<ParrotToken> get iterator => Set<ParrotToken>.from(_tokens).iterator;

  /// Has a identifier.
  bool has(Symbol identifier) =>
      any((ParrotToken token) => token.identifier == identifier);

  /// Get a token.
  ParrotToken<T> get<T extends Object>(Symbol identifier) {
    return firstWhere(
      (ParrotToken token) => token.identifier == identifier,
      orElse: () {
        if (has(identifier)) {
          throw Exception('The token $identifier is not the same type.');
        }

        throw Exception('The token $identifier is not found.');
      },
    ) as ParrotToken<T>;
  }

  /// Register a token.
  void register<T extends Object>(ParrotToken<T> token) {
    if (has(token.identifier)) {
      throw Exception(
          'The identifier ${token.identifier} is already registered.');
    }

    _tokens.add(token);
  }
}
