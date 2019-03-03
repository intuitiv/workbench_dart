import 'dart:async';
import 'dart:html';
import 'dart:math';

import 'package:angular/angular.dart';
import 'package:http/http.dart';
import 'package:wb_dart/app_component.template.dart' as ng;

import 'globals.dart' as globals;
import 'http_format.dart' as format;

const List<String> tabs = [
  "tasks",
  "learn",
  "read",
  "todo",
  "wb",
  "tricks",
  "tech"
];

ComponentRef todoComponent;

void main() {
  todoComponent = runApp(ng.AppComponentNgFactory);
  querySelector('#refreshIcon').onClick.listen(loadData);
  loadWB();
  globals.r = new Random.secure();
  loadFinish();
  window.onBeforeUnload.listen((Event e) {
    BeforeUnloadEvent be = e;
    if (globals.editInProgress) {
      be.returnValue = "Don't levae";
    }
  });
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
  globals.editInProgress = false;
}

loadWB() {
  tabs.forEach((tab) => loadFile(tab));
}

Future loadFile(String fileName) async {
  Element el = querySelector("#${fileName}");
  if (el != null) {
    if (fileName != 'tasks') {
      el.children.clear();
      el.style.removeProperty("display");

      addIcon("icns fas fa-edit", "e_${fileName}", el).onClick.listen(editATab);

      Element pretext = new Element.pre();
      el.children.add(pretext);

      var fileData;
      print("loading file ${fileName}");
      await read("data/_${fileName}").then((val) => fileData = val);

      String formattedData = format.formatData(fileName, fileData);
      pretext.setInnerHtml(formattedData,
          treeSanitizer: new DummyTreeSanitizer());
      if (fileName == 'tricks') {
        querySelector("#totd").text =
            "Trick of the day: " + format.getRandomTrick(fileData);
      }
    }
  }
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
  icon.style.paddingTop = '10px';
  icon.style.paddingRight = '10px';
  icon.innerHtml =
      "<i class='${iconClass}' id ='${id}'></i>";
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
  globals.editInProgress = true;

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
  await HttpRequest.postFormData("http://localhost:4040/updatetab", data);
  await new Future.delayed(const Duration(milliseconds: 200), () => "1");
  await loadFile(tab);
  loadFinish();
  globals.editInProgress = false;
}

cancelEdit(Event e) {
  Element el = e.target;
  String tab = el.id.substring(2, el.id.length);
  loadFile(tab);
}
