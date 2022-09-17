<h1 align="center">🦜 Parrot</h1>

A progressive [Dart](https://dart.dev) framework for building **efficient**, **reliable** and **scalable** server-side applications.

[![pub package](https://img.shields.io/pub/v/parrot.svg)](https://pub.dev/packages/parrot)
[![License](https://img.shields.io/badge/license-BSD%203--Clause-blue.svg)](LICENSE)

## What is Parrot?

Parrot is a Dart framework for building server-side applications. It is designed to be modular and maintainable.

In the Parrot core container, we use the DIP (Dependency Inversion Principle) design and agree on the way modules are composed.

> **NOTE**: Parrot uses `dart:mirrors` to parse annotations and put the processed results into a container.

## Getting Started

Create a simple module:

```dart
import 'package:parrot/parrot.dart';

@Injectable()
class SimpleService {
  void say() {
    print('Hello, 🦜 Parrot!');
  }
}

@Module(
  providers: [SimpleService],
)
class SimpleModule {}
```

Next, create an application module:

```dart
import 'package:parrot/parrot.dart';

@Module(
  dependencies: [SimpleModule],
)
class AppModule {}
```

Finally, create an application:

```dart
import 'package:parrot/parrot.dart';

void main() async {
  final app = await ParrotApplication.create(AppModule);
  final SimpleService simple = app.resolve(SimpleService);

  simple.say(); // Hello, 🦜 Parrot!
}
```

## Documentation

Read the [documentation](https://parrot.odroe.com) for more information.

## Examples

For more examples please visit 👉 [examples](https://github.com/odroe/parrot/tree/main/examples)
