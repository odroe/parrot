/// Instance Scope.
enum Scope {
  singleton,
  transient,
}

abstract class Scopable {
  Scope get scope;
}
