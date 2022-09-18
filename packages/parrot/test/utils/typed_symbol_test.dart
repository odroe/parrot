import 'package:parrot/parrot.dart';
import 'package:test/test.dart';

void main() {
  test('Is it a symbol created', () {
    expect(TypedSymbol.create(Type), isA<Symbol>());
  });

  test('Typed symbol format', () {
    final Type type = Type;
    expect(
        TypedSymbol.create(type).toString(), contains('Type-${type.hashCode}'));
  });
}
