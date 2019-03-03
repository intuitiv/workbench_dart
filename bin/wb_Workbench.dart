import 'dart:core';
import 'dart:io';
import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

@JsonSerializable()
class WorkBench {
  List<Task> tasks;
  bool shouldProceed = false;
  bool shouldUpdateAge;

  WorkBench(List<Task> tasks, bool shouldUpdateDate) {
    this.tasks = tasks;
    this.shouldUpdateAge = shouldUpdateDate;
  }

  List<Task> getTasks() {
    return tasks;
  }

  void markTaskAsDone(int taskID, bool done) {
    if (done) {
      tasks[taskID].state = "done";
    } else {
      tasks[taskID].state = "";
    }
    shouldProceed = true;
  }

  static WorkBench parse(String taskFile) {
    bool shouldUpdateDate = true;
    List<String> arr = taskFile.split("--updated on");
    RegExp r = new RegExp(r"--updated on (\d\d/\d\d/\d\d\d\d)");
    Match m = r.firstMatch(taskFile);
    if (r.hasMatch(taskFile)) {
      shouldUpdateDate = shouldUpdate("${m[1]}");
    }
    String task = arr[0].trim();

    List<Task> tasks = parseTasks(task);
    return new WorkBench(tasks, shouldUpdateDate);
  }

  String dump() {
    String postTask = "\n\n\n\n\n--updated on " + currentDate();

    String task = convertTasksToString(tasks);
    return task.trim() + "\n\n\n" + postTask.trim();
  }

  String getJSON() {
    String toRet = "{\"tasklist\":[";
    tasks.sort((a, b) => b.age - a.age);
    tasks.forEach((task) => {
          toRet += task.toJson().toString() +
              (tasks.indexOf(task) == tasks.length - 1 ? "" : ",")
        });
    return toRet + "]}";
  }

  bool shouldUpdateDump() {
    return shouldProceed || shouldUpdateAge;
  }

  void updateWorkBench(String workBenchFile) {
    if (shouldProceed || shouldUpdateAge) {
      writeTextToFile(dump(), workBenchFile);
    }
  }

  void addTask(String detail) {
    tasks.add(new Task(0, "", detail));
    shouldProceed = true;
  }

  void removeTask(int id) {
    tasks.removeAt(id);
    shouldProceed = true;
  }

  void archiveTask(Task task, String path) {
    File f = new File(path);
    f.writeAsStringSync(task.toStringWithDate().trim() + "\n\n\n");
  }

  static String currentDate() {
    return new DateFormat("dd/MM/yyyy").format(DateTime.now()).toString();
  }

  static bool shouldUpdate(String str) {
    DateTime dt = fromString(str);
    return dt.compareTo(fromString(currentDate())) != 0;
  }

  static DateTime fromString(String date) {
    RegExp r = new RegExp(r"(\d\d)/(\d\d)/(\d\d\d\d)");
    Match m = r.firstMatch(date);
    DateTime dt = new DateTime(
        int.parse(m.group(3)), int.parse(m.group(2)), int.parse(m.group(1)));
    return dt;
  }

  void archiveRequiredTasks(String archiveFile) {
    if (shouldUpdateAge) {
      for (Task task in tasks) {
        if (task.state == "done") {
          archiveTask(task, archiveFile);
          tasks.remove(task);
        }
      }
    }
  }

  String convertTasksToString(List<Task> tasks) {
    String toRet = "";
    tasks.sort((a, b) => b.age - a.age);
    tasks.forEach((task) => toRet += convertTaskToString(task));
    return toRet;
  }

  String convertTaskToString(Task task) {
    if (task.state != "done") {
      if (shouldUpdateAge) {
        task.age++;
      }
    }
    return task.toString().trim() + "\n\n";
  }

  static List<Task> parseTasks(String task) {
    RegExp taskPattern =
        new RegExp(r">TASK:([Dd]one)?( [Aa]ge:([\d]+))?([^>]+)");
    List<Task> tasks = [];
    Iterable<Match> matches = taskPattern.allMatches(task);
    for (Match match in matches) {
      String status = match.group(1);
      String ag = match.group(2);
      int age = 0;
      if (ag != null && ag.isNotEmpty) {
        age = int.parse(match.group(3));
      }
      String details = match.group(4);
      Task tsk = new Task(age, status, details);
      tasks.add(tsk);
    }
    return tasks;
  }

  void writeTextToFile(String data, String file) {
    File f = new File(file);
    f.writeAsStringSync(data);
  }

  static String readFile(String file) {
    return new File(file).readAsStringSync();
  }
}

@JsonSerializable()
class Task implements Comparable<Task> {
  int age;
  String state;
  String details;

  Task(int age, String state, String details) {
    this.age = age;
    if (state != null && state == "done") {
      this.state = "done";
    } else {
      this.state = "";
    }
    this.details = details;
  }

  String toString() {
    return "\n>TASK:" +
        state +
        (age > 0 ? " Age:" + age.toString() : "") +
        "\t\t" +
        details.trim() + "\n\n";
  }

  Map<String, dynamic> toJson() => {
        '\"state\"': "\"${state}\"",
        '\"age\"': "\"${age}\"",
        '\"detailshead\"': "\"${getDetailsHead().trim()}\"",
        '\"detailsbody\"': "\"${getDetailsBody().trim()}\""
      };

  String getDetailsHead() {
    return details.split("\n")[0];
  }

  String getDetailsBody() {
    String ret = "";
    List<String> lines = details.split("\n");

    for (int i = 1; i < lines.length; i++) {
      ret += lines[i].trim() + "-n-";
    }
    return ret;
  }

  String toStringWithDate() {
    return "\n>TASK: " + WorkBench.currentDate() + details;
  }

  int compareTo(Task another) {
    if (this.age < another.age) {
      return 1;
    } else {
      return -1;
    }
  }
}

class Date {
  int date;
  int month;
  int year;

  Date(int date, int month, int year) {
    this.date = date;
    this.month = month;
    this.year = year;
  }

  String toString() {
    date.toString() + "/" + month.toString() + "/" + year.toString();
  }

  String currentDate() {
    return new Date(
            DateTime.now().day, DateTime.now().month, DateTime.now().year)
        .toString();
  }
}
