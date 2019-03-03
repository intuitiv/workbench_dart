import 'todo_list_service.dart';
import 'dart:collection';

import 'dart:html';

class OfflineSync {
  Queue<Action> actions;
  TodoListService todoListService;

  OfflineSync(TodoListService service) {
    todoListService = service;
    actions = new Queue();
  }

  List<Task> syncItems(List<Task> onDisk, List<Task> inMemory) {
    print("syncing items...");
  }

  queue(Action action) async{
    actions.add(action);
    try {
      await action.performAction();
    } catch(exception) {
      print('exception caught executing ${action.actionName}');
    }
    print("QueueLength: " + actions.length.toString());
  }

  performAction(String action, {int index, String desc, bool done}) {
    Map<String, dynamic> params = {};
    switch (action) {
      case 'remove':
        params['index'] = index;
        break;
      case 'add':
        params['desc'] = desc;
        break;
      case 'done':
        params['index'] = index;
        params['done'] = done;
        break;
      default:
        break;
    }
    queue(new Action(action, params, todoListService));
  }
}

class Action {
  String actionName;
  Map<String, dynamic> params;
  TodoListService todoListService;

  Action(String action, Map<String, dynamic> params, TodoListService service) {
    this.actionName = action;
    this.params = params;
    this.todoListService = service;
  }

  Future<HttpRequest> performAction() {
    switch (actionName) {
      case 'remove':
        print('delete index: ${params['index']}');
        return todoListService.deleteTaskEvent(params['index']);
        break;
      case 'add':
        print('added ${params['desc']}');
        return todoListService.addTaskEvent(params['desc']);
        break;
      case 'done':
        print("done ${params['index']}, state: ${params['done']}");
        return todoListService.changeTaskState(params['index'],
            params['done']);
        break;
      default:
        throw new Exception('invalid args');
        break;
    }
  }
}
