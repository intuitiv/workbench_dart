import 'dart:io';
import 'dart:convert';
import 'wb_Workbench.dart';

Future main(List<String> args) async {
  var server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    4040,
  );
  print('Listening on localhost:${server.port}');

  await for (HttpRequest request in server) {
    handleRequest(request);
  }
}

void handleRequest(HttpRequest request) async {
  String payload = await request.transform(Utf8Decoder()).join();
  switch (request.uri.path) {
    case '/updatetab':
      print("handlerequest");
      var data = Uri.splitQueryString(payload)['data'];
      var tab = Uri.splitQueryString(payload)['tab'];
      File f = new File("/run/media/sainath/WindowsSSD/wb_dart/web/data/_" + tab);
      f.writeAsStringSync(data);
      break;
    case '/markTaskAsDone':
      var taskID = Uri.splitQueryString(payload)['num'];
      var state = Uri.splitQueryString(payload)['state'];
      print(taskID + "--" + state);
      String workBenchFile = "/run/media/sainath/WindowsSSD/wb_dart/web/data/_tasks";
      WorkBench wb = WorkBench.parse(WorkBench.readFile(workBenchFile));
      wb.markTaskAsDone(int.parse(taskID), state.toLowerCase() == 'true');
      wb.updateWorkBench(workBenchFile);
      break;
    case '/addTask':
      var taskDesc = Uri.splitQueryString(payload)['task'];
      print("add ${taskDesc}");
      String workBenchFile = "/run/media/sainath/WindowsSSD/wb_dart/web/data/_tasks";
      WorkBench wb = WorkBench.parse(WorkBench.readFile(workBenchFile));
      wb.addTask(taskDesc);
      wb.updateWorkBench(workBenchFile);
      break;
    case '/removeTask':
      var taskID = Uri.splitQueryString(payload)['num'];
      print("remove ${taskID}");
      String workBenchFile = "/run/media/sainath/WindowsSSD/wb_dart/web/data/_tasks";
      WorkBench wb = WorkBench.parse(WorkBench.readFile(workBenchFile));
      wb.removeTask(int.parse(taskID));
      wb.updateWorkBench(workBenchFile);
      break;
    default:
    // TODO: Forward to static file server
  }
}
