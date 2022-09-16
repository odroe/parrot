import 'injector/module_context.dart';

/// Parrot context.
///
/// The context is a container for modules.
abstract class ParrotContext {
  /// 从当前上下文中搜索模块。
  ///
  /// 如果选择的模块不是当前上下文，则从当前模块的依赖中进行检索。
  ///
  /// 如果选择的模块是一个全局模块，则任何节点通过 [select] 方法都可以访问。
  Future<ModuleContext> select(Type module);

  /// 从当前提供者中获取实例，如果当前提供者中没有，则从 `AnyContext` 中获取。
  ///
  /// 如果没有找到，抛出异常。
  Future<T> get<T extends Object>(Type type);

  /// 从当前模块中查找实例，与 [get] 不同的是，[get] 只会查找当前模块中的实例。
  /// 而 [resolve] 则会对 `dependencies` 进行查找。
  ///
  /// 如果获取的实例是一个全局模块，则任何节点通过 [resolve] 方法都可以访问。
  Future<T> resolve<T extends Object>(Type type);
}
