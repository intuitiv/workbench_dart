import 'todo_list_service.dart';
import 'todo_list_component.dart';
import 'dart:collection';

import 'dart:html';

class OfflineSync {
  Queue<Action> actions;
  TodoListService todoListService;
  TodoListComponent todoListComponent;

  bool active = true;
  bool completeSync = false;

  int pingFreq = 60;

  OfflineSync(TodoListService service, TodoListComponent todoListComponent) {
    todoListService = service;
    this.todoListComponent = todoListComponent;
    actions = new Queue();
    if (todoListComponent.serverOffline) {
      completeSync = true;
      startSync();
    }
  }

  setActive(bool active) {
    this.active = active;
  }

  startSync() async {
    for (; todoListComponent.serverOffline;) {
      print("syncing.." + DateTime.now().toString());
      try {
        await HttpRequest.getString("http://localhost:4040/health");
        if (completeSync) {
          syncCompletely();
        } else {
          deltaSync();
        }
        return;
      } catch (excep) {
        print('server offline in health ping ' + excep.toString());
        todoListComponent.serverOffline = true;
      }
      await wait(10);
    }
  }

  wait(int timeInSec) async {
    print(timeInSec.toString() + " time to wait");
    await new Future.delayed(Duration(seconds: timeInSec), () => "1");
  }

  bool shouldQueueItems() {
    return todoListComponent.serverOffline;
  }

  deltaSync() async {
    print("delta syncing items...");
    Action top;
    try {
      for (; actions.isNotEmpty;) {
        Action top = actions.removeFirst();
        await top.performAction();
      }
      todoListComponent.serverOffline = false;
    } catch (exception) {
      print('exception caught executing ${top.actionName}');
      todoListComponent.serverOffline = true;
      actions.addFirst(top);
      startSync();
      print('sync failed in the middle');
    }

    print('sync successfully finished');
  }

  syncCompletely() {
    try {
      //TODO implement
      print('complete sync support is not added yet');
    } finally {
      completeSync = false;
    }
  }

  queue(Action action) async {
    if (shouldQueueItems()) {
      actions.add(action);
      print("QueueLength: " + actions.length.toString());
    } else {
      try {
        await action.performAction();
      } catch (exception) {
        print('exception caught executing ${action.actionName}');
        todoListComponent.serverOffline = true;
        actions.add(action);
        startSync();
      }
      print("QueueLength: " + actions.length.toString());
    }
  }

  performAction(String action, {int index, String desc, bool done}) {
    Map<String, dynamic> params = {};
    switch (action) {
      case 'remove':
        params['index'] = index;
        break;
      case 'defer':
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
      case 'defer':
        print('deferring index: ${params['index']}');
        return todoListService.deferTaskEvent(params['index']);
        break;
      case 'add':
        print('added ${params['desc']}');
        return todoListService.addTaskEvent(params['desc']);
        break;
      case 'done':
        print("done ${params['index']}, state: ${params['done']}");
        return todoListService.changeTaskState(params['index'], params['done']);
        break;
      default:
        throw new Exception('invalid args');
        break;
    }
  }
}
