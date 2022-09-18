<h1 align="center">🦜 Parrot</h1>

A progressive [Dart](https://dart.dev) framework for building **efficient**, **reliable** and **scalable** server-side applications.

## What is Parrot?

Parrot is a Dart framework for building server-side applications. It is designed to be modular and maintainable.

In the Parrot core container, we use the DIP (Dependency Inversion Principle) design and agree on the way modules are composed.

> **NOTE**: Parrot uses `dart:mirrors` to parse annotations and put the processed results into a container.

## Philosophy

The [Dart language](https://dart.dev) has become more and more perfect under the birth of [Flutter](https://flutter.dev). Even if Google develops the features of Dart around Flutter, it does not mean that Dart cannot achieve achievements in other fields.

Dart as a server-side development language is not without cases, such as [dart.dev](https://dart.dev) and [pub.dev](https://pub.dev). Obviously, dart.dev is a static website, while pub.dev is developed using Firebase.

The emergence of Parrot is not a flash in the pan, but has been planned for a long time! For the development of Dart server-side applications, Dart has introduced [shelf](https://pub.dev/packages/shelf) and [googleapis](https://pub.dev/packages/googleapis), which is obviously insufficient. The [Angel framework](https://github.com/dukefirehawk/angel) that emerged in the community is a bold attempt. Under the birth of the Flutter ecosystem, a lot of toolkits based on Sourcegen or Codegen have been created, but none of them have solved the main problem - **The architecture**

Parrot is designed to provide an out-of-the-box application architecture that allows for the easy creation of highly testable, extensible, loosely coupled, and easily maintainable applications. The architecture is heavily inspired by [Nest.js](https://github.com/nestjs/nest).

## Status

| Package | Pub | CI | Coverage |
|:--------|:---:|:--:|:--------:|
| `parrot` | [![pub package](https://img.shields.io/pub/v/parrot.svg)](https://pub.dev/packages/parrot) | ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/odroe/parrot/parrot-ci.yaml) | ![Codecov](https://img.shields.io/codecov/c/github/odroe/parrot) |

## Getting Started

TODO

## Questions

If you have any questions, please feel free to ask in the [Discussions](https://github.com/odroe/parrot/discussions) section.

> **NOTE**: Please do not ask questions in the issue section, Issues are for bug reports and feature requests only.

## Stay in touch

- Website - [https://parrot.odroe.com](https://parrot.odroe.com)
- Twitter - [@odroeinc](https://twitter.com/odroeinc)

## License

Parrot is [BSD 3-Clause licensed](LICENSE).
