import '../annotations/injectable.dart';
import '../container/parrot_container.dart';
import '../exceptions/provider_context_unsupported_exception.dart';
import '../parrot_context.dart';
import 'module_context.dart';

abstract class ProviderContext<T> extends Injectable implements ParrotContext {
  const ProviderContext({
    required this.module,
    super.scope,
  });

  /// Current provider module.
  final ModuleContext module;

  /// **WARN** [ProviderContext] Unsupported [get] method.
  @override
  U get<U extends Object>(Type type) {
    throw ProviderContextUnsupportedException('get');
  }

  /// **WARN** [ProviderContext] Unsupported [resolve] method.
  @override
  U resolve<U extends Object>(Type type) {
    throw ProviderContextUnsupportedException('resolve');
  }

  /// **WARN** [ProviderContext] Unsupported [select] method.
  @override
  ModuleContext select(Type module) {
    throw ProviderContextUnsupportedException('select');
  }
}

class _ProviderContextImpl<T> extends ProviderContext<T> {
  _ProviderContextImpl({
    required this.container,
    required super.module,
    super.scope,
  });

  /// Parrot container.
  final ParrotContainer container;
}
