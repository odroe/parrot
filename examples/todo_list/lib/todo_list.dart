class TodoList {
  String id;

  TodoList({
    required this.id,
  });
}

class TodoItem {
  static const inProgress = "IN_PROGRESS";

  static const ignored = "IGNORED";

  static const done = "DONE";

  String id;

  String listId;

  bool draft;

  String state;

  TodoItem({
    required this.id,
    required this.listId,
    required this.draft,
    required this.state,
  });

  bool isDraft() => draft;

  bool isInProgress() => state == inProgress;

  bool isIgnored() => state == ignored;

  bool isDone() => state == done;
}

class TodoListService {
  ITodoListRepository todoListRepo;
  ITodoItemRepository todoItemRepo;

  TodoListService(this.todoListRepo, this.todoItemRepo);

  Future<TodoList> findListById(String id) {
    return todoListRepo.findById(id);
  }

  Future<TodoItem> findItemById(String id) {
    return todoItemRepo.findById(id);
  }

  Future<Iterable<TodoItem>> findItemsByListId(String listId) {
    return todoItemRepo.findByListId(listId);
  }

  Future<void> markItemAsInProgress(String itemId) async {
    _setItemState(itemId, TodoItem.inProgress);
  }

  Future<void> markItemAsIgnored(String itemId) async {
    _setItemState(itemId, TodoItem.ignored);
  }

  Future<void> markItemAsDone(String itemId) async {
    _setItemState(itemId, TodoItem.done);
  }

  Future<void> _setItemState(String itemId, String state) async {
    var item = await todoItemRepo.findById(itemId);
    item.state = state;
    await todoItemRepo.save(item);
  }
}

abstract class ITodoListRepository {
  Future<TodoList> findById(String id);

  Future<void> save(TodoList list);
}

abstract class ITodoItemRepository {
  Future<TodoItem> findById(String id);

  Future<Iterable<TodoItem>> findByListId(String listId);

  Future<void> save(TodoItem item);
}
