import 'package:parrot/parrot.dart';
import 'package:test/test.dart';

void main() {
  late ParrotContainer container;

  setUp(() {
    container = ParrotContainer();
  });

  test('should be able to add a provider', () async {
    container.addProvider(
      LazyProvider(
        token: 'token',
        factory: (container) async => 'instance',
      ),
    );

    expect(container.has('token'), isTrue);
  });

  test('should be able to get a provider', () async {
    container.addProvider(
      LazyProvider(
        token: 'token',
        factory: (container) async => 'instance',
      ),
    );

    final provider = container.getProvider<String>('token');

    expect(provider.token, 'token');
  });

  test('should be able to get a instance', () async {
    container.addProvider(
      LazyProvider(
        token: 'token',
        factory: (container) async => 'instance',
      ),
    );

    final instance = await container.getInstance<String>('token');

    expect(instance, 'instance');
  });

  test('should be able to get a instance with a eager provider', () async {
    await container.addProvider(
      EagerProvider(
        token: 'token',
        factory: (container) async => 'instance',
      ),
    );

    final instance = await container.getInstance<String>('token');

    expect(instance, 'instance');
  });
}
