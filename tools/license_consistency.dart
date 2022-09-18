import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';

void main(List<String> args) {
  final ArgParser argParser = ArgParser()
    ..addOption(
      'license',
      abbr: 'l',
      help: 'The license to check for.',
      defaultsTo: join(Directory.current.path, 'LICENSE'),
      valueHelp: 'path',
    )
    ..addOption('filename',
        abbr: 'f',
        help: 'License filename.',
        defaultsTo: 'LICENSE',
        valueHelp: 'name')
    ..addMultiOption(
      'directory',
      abbr: 'd',
      help: 'packages directory.',
      defaultsTo: [join(Directory.current.path, 'packages')],
      valueHelp: 'path',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Prints this help message.',
      negatable: false,
    );
  final ArgResults argResults = argParser.parse(args);
  if (argResults['help'] as bool) {
    print(argParser.usage);
    return;
  }

  final String license = readLicense(argResults['license'] as String);
  final List<File> packageLicenseFiles = findPackageLicenseFiles(
    argResults['directory'] as List<String>,
    argResults['filename'] as String,
  );

  for (final File file in packageLicenseFiles) {
    file.writeAsString(license);
  }
}

/// Readme license file content.
String readLicense(String path) {
  final File licenseFile = File(path);
  if (!licenseFile.existsSync()) {
    throw Exception('License file not found: $path');
  }
  return licenseFile.readAsStringSync();
}

/// Find all license files in the packages directory.
List<File> findPackageLicenseFiles(List<String> directories, String filename) {
  final List<File> licenseFiles = <File>[];
  for (final String directory in directories) {
    final Directory packagesDirectory = Directory(directory);
    if (!packagesDirectory.existsSync()) {
      continue;
    }

    for (final FileSystemEntity entity in packagesDirectory.listSync()) {
      if (entity is! Directory) {
        continue;
      }

      final File pubspecFile = File(join(entity.path, 'pubspec.yaml'));
      if (!pubspecFile.existsSync()) {
        continue;
      }

      // Delete all license files.
      Directory(entity.path)
          .listSync()
          .where((element) =>
              element is File &&
              basename(element.path).toLowerCase() == filename.toLowerCase())
          .forEach((element) {
        element.deleteSync();
      });

      final File licenseFile = File(join(entity.path, filename));
      licenseFiles.add(licenseFile);
    }
  }

  return licenseFiles;
}
