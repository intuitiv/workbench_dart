import 'dart:async';
import 'dart:html';
import 'dart:math';

import 'http_format.dart' as format;
import 'package:http/http.dart';
import 'globals.dart' as globals;

const List<String> tabs = [
  "tasks",
  "learn",
  "read",
  "todo",
  "wb",
  "tricks",
  "tech"
];

void main() {
  querySelector('#refreshIcon').onClick.listen(loadData);
  loadWB();
  globals.r = new Random.secure();
  loadFinish();
}

loadFinish() async {
  querySelector("#loader").style.visibility = "hidden";
  querySelector("#maincontent").style.removeProperty("visibility");
}

loadStart() async {
  querySelector("#maincontent").style.visibility = "hidden";
  querySelector("#loader").style.removeProperty("visibility");
}

loadData(Event e) {
  loadWB();
}

loadWB() {
  tabs.forEach((tab) => loadFile(tab));
}

Future loadFile(String fileName) async {
  Element el = querySelector("#${fileName}");
  if (el != null) {
    el.children.clear();
    el.style.removeProperty("display");

    if (fileName == 'tasks') {
      el.children.add(addTaskElement());
    }
//    addBadge("Edit", "e_" + fileName, el).onClick.listen(editATab);
    addIcon("icns fas fa-edit", "e_${fileName}", el).onClick.listen(editATab);

    Element pretext = new Element.pre();
    el.children.add(pretext);

    var fileData;
    await read("data/_${fileName}").then((val) => fileData = val);

    String formattedData = format.formatData(fileName, fileData);
    pretext.setInnerHtml(formattedData,
        treeSanitizer: new DummyTreeSanitizer());
    if (fileName == 'tricks') {
      querySelector("#totd").text =
          "Trick of the day: " + format.getRandomTrick(fileData);
    }
    if (fileName == 'tasks') {
      for (int i = 0; i < globals.total; i++) {
        querySelector("#cbt_${i.toString()}").onChange.listen(changeTaskState);
        querySelector("#td_${i.toString()}").onClick.listen(deleteTaskEvent);
      }
    }
  }
}

deleteTaskEvent(Event e) async {
  print("deleteTaskEvent");
  Element el = e.target;
  String taskNum = el.id.substring(3); //td_
  var data = {
    'num': taskNum,
  };
  print(data);
  HttpRequest.postFormData("http://localhost:4040/removeTask", data);
  await new Future.delayed(const Duration(milliseconds: 500), () => "1");
  loadFile('tasks');
}

DivElement addTaskElement() {
  DivElement div = new DivElement();
  div.id = "addTask";
  div.classes.add("container");
  div.classes.add("mt-3");
  div.classes.add("input-group");
  div.classes.add("mb-3");

  DivElement buttonDiv = new DivElement();
  buttonDiv.classes.add("input-group-append");
  ButtonElement addButton = new ButtonElement();
  addButton.classes.add("btn");
  addButton.classes.add("btn-primary");
  addButton.type = "button";
  addButton.text = "Add Task";
  buttonDiv.children.add(addButton);
  addButton.onClick.listen(addTaskEvent);

  InputElement taskDesc = new InputElement();
  taskDesc.id = "addTaskInput";
  taskDesc.classes.add("form-control");
  taskDesc.placeholder = "Task description...";
  taskDesc.onKeyUp.listen(onPressingENTER);
  div.children.add(taskDesc);
  div.children.add(buttonDiv);

  return div;
}

onPressingENTER(KeyboardEvent keyboardEvent) {
  var keyEvent = new KeyEvent.wrap(keyboardEvent);
  if (keyEvent.keyCode == KeyCode.ENTER) {
    addTaskEvent(keyboardEvent);
  }
}

addTaskEvent(Event e) async {
  InputElement el = querySelector("#addTaskInput");
  var data = {'task': el.value};
  HttpRequest.postFormData("http://localhost:4040/addTask", data);
  await new Future.delayed(const Duration(milliseconds: 500), () => "1");
  loadFile('tasks');
  print(el.value);
}

changeTaskState(Event e) async {
  Element el = e.target;
  String taskNum = el.id.substring(4); //cbt_
  CheckboxInputElement cbe = el;
  var data = {'num': taskNum, 'state': cbe.checked.toString()};
  print(data);
  HttpRequest.postFormData("http://localhost:4040/markTaskAsDone", data);
  await new Future.delayed(const Duration(milliseconds: 500), () => "1");
  loadFile('tasks');
}

class DummyTreeSanitizer implements NodeTreeSanitizer {
  NodeValidator validator;

  @override
  void sanitizeTree(Node node) {
    // TODO: implement sanitizeTree
  }
}

Element addIcon(String iconClass, String id, Element parent) {
  PreElement icon = new Element.pre();
  icon.innerHtml =
      "<i class='${iconClass}' id ='${id}' style='padding: 0px 8px 0px 0px;'></i>";
  parent.children.add(icon);
  return icon;
}

Element addBadge(String text, String id, Element parent) {
  AnchorElement editLink = new Element.a();
  editLink.text = text;
  editLink.href = "#";
  editLink.id = id;

  SpanElement span = new Element.span();
  span.classes.add("badge");
  span.classes.add("badge-pill");
  span.classes.add("badge-warning");
  span.children.add(editLink);

  parent.children.add(span);
  return editLink;
}

editATab(Event e) {
  Element el = e.target;
  String tab = el.id.substring(2, el.id.length);
  TextAreaElement textArea = new Element.textarea();
  textArea.cols = 150;
  textArea.rows = 30;
  textArea.classes.add("ta");
  textArea.id = "t_${tab}";
  querySelector("#${tab}").children.clear();
  querySelector("#${tab}").children.add(textArea);
  DivElement gap = new DivElement();
  gap.style.padding = "inherit";
  querySelector("#${tab}").children.add(gap);

  addIcon("icns fas fa-paper-plane", "s_${tab}", querySelector("#${tab}"))
      .onClick
      .listen(postEdit);
  DivElement gap1 = new DivElement();
  gap1.style.padding = "inherit";
  querySelector("#${tab}").children.add(gap1);
  addIcon("icns fas fa-eraser", "c_${tab}", querySelector("#${tab}"))
      .onClick
      .listen(cancelEdit);
  read("data/_${tab}").then((val) => textArea.innerHtml = val);
  querySelector("#${tab}").style.display = "-webkit-box";
}

postEdit(Event e) async {
  loadStart();
  Element el = e.target;
  String tab = el.id.substring(2, el.id.length);
  TextAreaElement tael = querySelector("#t_${tab}");
  var data = {'tab': tab, 'data': tael.value};
  HttpRequest.postFormData("http://localhost:4040/updatetab", data);
  await new Future.delayed(const Duration(milliseconds: 500), () => "1");
  loadFile(tab);
  loadFinish();
}

cancelEdit(Event e) {
  Element el = e.target;
  String tab = el.id.substring(2, el.id.length);
  loadFile(tab);
}
