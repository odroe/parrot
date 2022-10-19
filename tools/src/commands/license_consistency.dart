import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:parrot_cmd/parrot_cmd.dart';
import 'package:path/path.dart';

class _LicenseConsistencyCommand extends Command {
  _LicenseConsistencyCommand() {
    argParser
      ..addOption(
        'license',
        abbr: 'l',
        help: 'The license to check for.',
        defaultsTo: join(Directory.current.path, 'LICENSE'),
        valueHelp: 'path',
      )
      ..addMultiOption(
        'directory',
        abbr: 'd',
        help: 'packages directory.',
        defaultsTo: [join(Directory.current.path, 'packages')],
        valueHelp: 'path',
      )
      ..addFlag(
        'try-run',
        abbr: 'n',
        help: "Validate but do not fix the licenses.",
      );
  }

  @override
  String get description => 'License consistency check and fix tool.';

  @override
  String get name => 'license-consistency';

  @override
  void run() {
    final File license = File(argResults!['license']);
    if (!license.existsSync()) {
      throw UsageException(
          'License file does not exist: ${license.absolute.path}', usage);
    }

    final List<String> directories = argResults!['directory'];
    final List<File> licenseFiles =
        findPackageLicenseFiles(directories, basename(license.path));

    for (final File child in licenseFiles) {
      if (!child.existsSync()) {
        child.createSync(recursive: true);
      }

      if (argResults?.wasParsed('try-run') == true) {
        if (child.readAsStringSync() != license.readAsStringSync()) {
          print('License file ${child.absolute.path} is not consistent.');
          exitCode = 1;
        }

        continue;
      }

      child.writeAsStringSync(license.readAsStringSync());
    }
  }

  /// Find all license files in the packages directory.
  List<File> findPackageLicenseFiles(
      List<String> directories, String filename) {
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

        final File licenseFile = File(join(entity.path, filename));
        licenseFiles.add(licenseFile);
      }
    }

    return licenseFiles;
  }
}

final CommandProvider licenseConsistencyCommand =
    (ref) => _LicenseConsistencyCommand();
