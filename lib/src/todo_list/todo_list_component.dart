import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import 'todo_list_offline_sync_component.dart' as offline;
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
  bool active = true;

  bool serverOffline;

  TodoListComponent(this.todoListService);

  offline.OfflineSync offlineSync;

  @override
  Future<Null> ngOnInit() async {
    items = await todoListService.getTodoList();
    serverOffline = todoListService.offline;
    offlineSync = new offline.OfflineSync(todoListService);
    healthping();
  }

  @override
  void ngOnDestroy() {
    active = false;
    print('destroyed app');
  }

  healthping() async {
    int syncperiod = 60;
    for (; active;) {
      print("syncing.." + DateTime.now().toString());
      try {
        await HttpRequest.getString("http://localhost:4040/health");
        if (serverOffline) {
          await todoListService.fetchTasks();
          if (todoListService.dirtyMarker) {
            throw new Exception("offine again");
          }
          offlineSync.syncItems(todoListService.todoList, items);
        }
        serverOffline = false;
        syncperiod = 60;
      } catch (excep) {
        print('server offline in health ping ' + excep.toString());
        serverOffline = true;
        syncperiod = 10;
      }
      await wait(syncperiod);
    }
  }

  wait(int timeInSec) async {
    print(timeInSec.toString() + " time to wait");
    await new Future.delayed(Duration(seconds: timeInSec), () => "1");
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
