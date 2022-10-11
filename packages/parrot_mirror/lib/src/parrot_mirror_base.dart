import 'package:parrot/parrot.dart';

import 'compiler/compiler.dart';
import 'compiler/module_compiler.dart';
import 'compiler/provider_compiler.dart';

class _ParrotCompilerImpl = ParrotCompiler
    with Compiler, ModuleCompiler, ProviderCompiler;

/// [ParrotCompiler] implementation based on [datr:mirrors] instance.
final ParrotCompiler compiler = _ParrotCompilerImpl();
