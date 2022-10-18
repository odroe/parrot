# 🦜 [Parrot](https://parrot.odroe.com) ・ [![pub package](https://img.shields.io/pub/v/parrot.svg)](https://pub.dev/packages/parrot)

Parrot is a Dart framework for building applications.

- **Declarative**: Parrot makes it easy to create instance dependencies. Design simple providers for each instance in your application, and when your instance needs to depend on another instance, Parrot will effectively provide the reference. declarative instances make your code more predictable and easier to debug.
- **Modular**: Modular design makes it easy to manage your application. Parrot provides a simple and effective modular architecture, you can easily combine instances into a functional module, which can be easily used in other modules.
- **Flexible**: Parrot is a framework that can be used in any Dart project. You can use Parrot to build a simple command-line application, or you can use it to build a complex web application. Parrot is flexible and can be used in any Dart project.

👉 [Learn how to use Parrot in your project](https://parrot.odroe.com/getting-started)

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  parrot: latest
```

# Documentation

You can find the Parrot documentation [on the website](https://parrot.odroe.com).

> If you find any errors in the documentation, please [create an issue](https://github.com/odroe/parrot/issues/new) or [sending a pull request](https://github.com/odroe/parrot/pulls) to help us improve it.

## Examples

We have several examples [on the website](https://parrot.odroe.com/examples). Hre is one of the most popular examples to get you started:

```dart
import 'package:parrot/parrot.dart';

name(ref) => 'Parrot';
hello(ref) => 'Hello ${ref(name)}';

final root = Module(
  providers: { name, hello },
);

void main() async {
  final app = Parrot(root);
  
  print(await app.resolve(hello));
}
```

This example will print `Hello Parrot` into the console.

You're thinking, `Isn't this complicating something simple?`, yes, it does in this hello example.

But when you have a complex application, you will find that Parrot is very useful. 

## Contributing

We welcome contributions to Parrot. Please read our [contributing guide](contributing.md) to learn about our development process, how to propose bugfixes and improvements, and how to build and test your changes to Parrot.

## Code of Conduct

Parrot has adopted a Code of Conduct that we expect project participants to adhere to. Please read the [full text](code_of_conduct.md) so that you can understand what actions will and will not be tolerated.

## Community

You can find Parrot community and join us [on the website](https://parrot.odroe.com/community), or follow our Twitter account [@odroeinc](https://twitter.com/odroeinc) to see our events.
