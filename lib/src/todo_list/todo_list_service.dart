import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'package:angular/core.dart';

@Injectable()
class TodoListService {
  List<Task> todoList = <Task>[];
  bool offline = false;
  bool dirtyMarker = false;

  Future<List<Task>> getTodoList() async {
    await fetchTasks();
    return todoList;
  }

  bool isListDirty() {
    return dirtyMarker;
  }

  fetchTasks() async {
    String resp;
    print("fetching tasks in service.");
    try {
      await HttpRequest.getString("http://localhost:4040/getAllTasks")
          .then((ret) => (resp = ret));
      dirtyMarker = false;
    } catch (exception) {
      print(exception.toString() + " while fethcing all tasks");
      dirtyMarker = true;
    }
    if (resp != null && resp.isNotEmpty) {
      var json = jsonDecode(resp);
      print(json);
      todoList.clear();
      List taskList = json['tasklist'];
      int numOdTasks = taskList.length;
      for (int i = 0; i < numOdTasks; i++) {
        var jsonTask = json['tasklist'][i];
        Task t = new Task(
            jsonTask['detailshead'], jsonTask['age'], jsonTask['detailsbody']);
        t.isDone = jsonTask['state'] == 'done';
        todoList.add(t);
      }
    } else {
      print("device offline");
      offline = true;
    }
  }

  Future<HttpRequest> addTaskEvent(String desc) {
    var data = {'task': desc};
    return HttpRequest.postFormData("http://localhost:4040/addTask", data);
  }

  Future<HttpRequest> changeTaskState(int id, bool state) {
    var data = {'num': id.toString(), 'state': state.toString()};
    print(data);
    return HttpRequest.postFormData(
        "http://localhost:4040/markTaskAsDone", data);
  }

  Future<HttpRequest> deleteTaskEvent(int id) {
    var data = {'num': id.toString()};
    print(data);
    return  HttpRequest.postFormData("http://localhost:4040/removeTask", data);
  }
}

class Task {
  String title;
  String desc;
  bool isDone;
  String age;

  Task(String title, String age, String desc) {
    this.title = title;
    if (age.isEmpty || age == '0') {
      age = 'new';
    }

    this.age = age;
    this.desc = desc.replaceAll('-n-', '\n').trim();
    isDone = false;
  }
}
