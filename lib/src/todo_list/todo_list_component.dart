import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import 'todo_list_offline_sync_component.dart';
import 'todo_list_service.dart';

@Component(
  selector: 'todo-list',
  styleUrls: ['todo_list_component.css'],
  templateUrl: 'todo_list_component.html',
  directives: [
    MaterialCheckboxComponent,
    MaterialFabComponent,
    MaterialIconComponent,
    materialInputDirectives,
    MaterialChipComponent,
    NgFor,
    NgIf,
  ],
  providers: [ClassProvider(TodoListService)],
)
class TodoListComponent implements OnInit, OnDestroy {
  final TodoListService todoListService;

  List<Task> items = [];
  String newTodo = '';

  TodoListComponent(this.todoListService);

  OfflineSync offlineSync;
  bool serverOffline = false;

  @override
  Future<Null> ngOnInit() async {
    items = await todoListService.getTodoList();
    serverOffline = todoListService.offline;
    offlineSync = new OfflineSync(todoListService, this);
    offlineSync.startSync();
  }

  @override
  void ngOnDestroy() {
    offlineSync.setActive(false);
    print('destroyed app');
  }

  bool amIFree() {
    bool ret = true;
    items.forEach((task) => !task.isDone ? ret = false : ret = ret);
    return ret;
  }

  void add() {
    items.add(new Task(newTodo, "new", ""));
    offlineSync.performAction('add', desc: newTodo);
    newTodo = '';
  }

  Task remove(int index) {
    offlineSync.performAction("remove", index: index);
    return items.removeAt(index);
  }

  Task isDone(int index) {
    offlineSync.performAction("done", index: index, done: items[index].isDone);
    return items[index];
  }

  String getBadgeClass(Task item) {
    String badgeClass;
    if (item.age == 'new') {
      badgeClass = 'new';
    } else {
      badgeClass = 'ongoing';
    }
    return badgeClass;
  }
}
