import 'package:parrot/parrot.dart';
import 'package:test/test.dart';

const String parrot = '🦜 Parrot';

@Injectable()
class AppService {
  String get name => parrot;
}

@Module(providers: [AppService])
class AppModule {}

void main() {
  late ParrotApplication app;

  setUp(() async {
    app = await ParrotApplication.create(AppModule);
  });

  test('Implements ParrotContext', () {
    expect(app, isA<ParrotContext>());
  });

  test('ParrotContainer created', () async {
    expect(app.container, isA<ParrotContainer>());
    expect(
      await app.container.get(TypedSymbol.create(ParrotApplication)).resolve(),
      app,
    );
  });

  group('resolve method', () {
    test('Resolve Success', () async {
      expect(await app.resolve(AppService), isA<AppService>());
    });

    test('Resolve Error', () {
      expect(app.resolve(ParrotApplication), throwsA(isA<Exception>()));
    });
  });

  group('get method', () {
    test('Get Success', () async {
      expect(await app.get(AppService), isA<AppService>());
    });

    test('Get Error', () {
      expect(app.get(ParrotApplication), throwsA(isA<Exception>()));
    });
  });

  group('select method', () {
    test('Select Success', () async {
      expect(await app.select(AppModule), isA<ModuleContext>());
    });

    test('Select Error', () {
      expect(app.select(ParrotApplication), throwsA(isA<Exception>()));
    });
  });
}
