import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'package:angular/core.dart';

@Injectable()
class TodoListService {
  List<Task> todoList = <Task>[];

  Future<List<Task>> getTodoList() async {
    await fetchTasks();
    return todoList;
  }

  fetchTasks() async {
    String resp;
    print("fetching.");
    await HttpRequest.getString("http://localhost:4040/getAllTasks")
        .then((ret) => (resp = ret));
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
  }

  addTaskEvent(String desc) async {
    var data = {'task': desc};
    await HttpRequest.postFormData("http://localhost:4040/addTask", data);
  }

  changeTaskState(int id, bool state) async {
    var data = {'num': id, 'state': state.toString()};
    print(data);
    await HttpRequest.postFormData(
        "http://localhost:4040/markTaskAsDone", data);
  }

  deleteTaskEvent(int id) async {
    var data = {'num': id.toString()};
    print(data);
    await HttpRequest.postFormData("http://localhost:4040/removeTask", data);
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

  String urlify(String text) {
    RegExp urlRegex = new RegExp(r"https?://([^\s<]+)");
    var ret = addPreviewLink(urlRegex, text);

    RegExp fileRegex = new RegExp(r"file://([^\s]+)");
    return addPreviewLink(fileRegex, ret);
  }

  String addPreviewLink(RegExp urlRegex, String text) {
    return text.replaceAllMapped(
        urlRegex, (match) => replaceRegexForPreviewLink(match));
  }

  String replaceRegexForPreviewLink(Match match) {
    return '<code><a href="${match[0]}" target="_blank">${match[1]} </a></code>';
  }
}
