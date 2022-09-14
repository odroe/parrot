import 'package:test/test.dart';
import 'package:todo_list/todo_list.dart';

void main() {
  test('should initialize TodoList', () {
    var list = TodoList(id: "1");

    expect(list.id, "1");
  });

  test("should initialize TodoItem", () {
    var item = TodoItem(
      id: "1",
      listId: "1",
      draft: true,
      state: TodoItem.inProgress,
    );

    expect(item.id, "1");
    expect(item.listId, "1");
    expect(item.draft, true);
    expect(item.state, TodoItem.inProgress);
    expect(item.isDraft(), true);
    expect(item.isInProgress(), true);
    expect(item.isIgnored(), false);
    expect(item.isDone(), false);
  });
}
