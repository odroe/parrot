library parrot.core.exception;

import 'modular.dart';

part 'exceptions/module_export_illegal_exception.dart';
part 'exceptions/module_not_found_exception.dart';
part 'exceptions/provider_duplication_exception.dart';
part 'exceptions/provider_not_found_exception.dart';

/// Parrot basic exception.
abstract class ParrotException implements Exception {}
