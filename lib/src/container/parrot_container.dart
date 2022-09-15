import 'parrot_token.dart';

class ParrotContainer {
  final List<ParrotToken> _tokens = <ParrotToken>[];

  /// Get all tokens.
  List<ParrotToken> get all => _tokens;

  /// Check a token type is registered.
  bool has<T>([Type? type]) {
    return all.any((token) => token.key == (type ?? T));
  }

  /// Retrieves the token with given type from the token container.
  ParrotToken<T>? get<T>([Type? type]) {
    final filtered = all.where((token) => token.key == (type ?? T));

    if (filtered.isEmpty) {
      return null;
    }

    return filtered.first as ParrotToken<T>;
  }

  /// Sets the token with given type to the token container.
  void set<T>(ParrotToken<T> token) {
    this
      ..remove<T>(token.key)
      .._tokens.add(token);
  }

  /// Removes the token with given type from the token container.
  void remove<T>([Type? type]) {
    _tokens.removeWhere((token) => token.key == (type ?? T));
  }
}
