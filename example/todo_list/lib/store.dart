import 'todo_list.dart';

abstract class AbstractInMemoryRepository<E> {
  final List<E> entities = [];

  AbstractInMemoryRepository();

  Future<Iterable<E>> findAll() async {
    return entities.where((_) => true);
  }

  Future<E> findBy(bool Function(E) predicate) async {
    return entities.firstWhere(predicate);
  }

  Future<Iterable<E>> findAllBy(bool Function(E) predicate) async {
    return entities.where(predicate);
  }

  Future<void> save(E entity) async {
    entities.removeWhere((current) => current == entity);
    entities.add(entity);
  }
}

class InMemoryTodoListRepository extends AbstractInMemoryRepository<TodoList>
    implements ITodoListRepository {
  @override
  Future<TodoList> findById(String id) {
    return findBy((list) => list.id == id);
  }
}

class InMemoryTodoItemRepository extends AbstractInMemoryRepository<TodoItem>
    implements ITodoItemRepository {
  @override
  Future<TodoItem> findById(String id) {
    return findBy((item) => item.id == id);
  }

  @override
  Future<Iterable<TodoItem>> findByListId(String listId) {
    return findAllBy((item) => item.listId == listId);
  }
}
