import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

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
class TodoListComponent implements OnInit {
  final TodoListService todoListService;

  List<Task> items = [];
  String newTodo = '';

  TodoListComponent(this.todoListService);

  @override
  Future<Null> ngOnInit() async {
    items = await todoListService.getTodoList();
  }

  void fetch() async {
    todoListService.fetchTasks();
    await todoListService.getTodoList().then((value) => items = value);
  }

  bool amIFree() {
    bool ret = true;
    items.forEach((task) => !task.isDone ? ret = false : ret = ret );
    return ret;
  }

  void add() {
    items.add(new Task(newTodo, "new", ""));
    todoListService.addTaskEvent(newTodo);
    newTodo = '';
  }

  Task remove(int index) {
    todoListService.deleteTaskEvent(index);
    return items.removeAt(index);
  }

  Task isDone(int index) {
    todoListService.changeTaskState(index, !items[index].isDone);
    print("removed ${index}");
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
