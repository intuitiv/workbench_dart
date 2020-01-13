import 'dart:convert';
import 'dart:io';

import 'wb_Workbench.dart';

Future main(List<String> args) async {
  await HttpServer.bind('127.0.0.1', 4040).then((server) {
    server.listen((HttpRequest request) async {
      request.uri.queryParameters.forEach((param, val) {
        print(param + '-' + val);
      });

      request.response.headers.add("Access-Control-Allow-Origin", "*");
      request.response.headers
          .add("Access-Control-Allow-Methods", "POST,GET,DELETE,PUT,OPTIONS");
      request.response.headers.add("Access-Control-Allow-Credentials", "true");
      request.response.headers
          .add("Access-Control-Allow-Methods", "GET,HEAD,OPTIONS,POST,PUT");
      request.response.headers.add(
          "Access-Control-Allow-Headers",
          "Access-Co"
          "ntrol-Allow-Origin, Access-Control-Allow-Headers, Origin,Accept, "
          "X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers");
      request.response.statusCode = HttpStatus.OK;
      await requestReceivedHandler(request, request.response);
      request.response.close();
    });
  });
}

void requestReceivedHandler(HttpRequest request, HttpResponse response) async {
  String payload = await request.transform(Utf8Decoder()).join();
  print(request.uri.path);
  switch (request.uri.path) {
    case '/health':
      print("health ping: " + DateTime.now().toString());
      request.response.write("success");
      break;
    case '/getData':
      var tab = Uri.splitQueryString(payload)['tab'];
      File f =
      new File("/run/media/sainath/WindowsSSD/wb_dart/web/data/_" + tab);
      String data = f.readAsStringSync();
      request.response.write(data);
      break;
    case '/updatetab':
      print("handlerequest");
      var data = Uri.splitQueryString(payload)['data'];
      var tab = Uri.splitQueryString(payload)['tab'];
      File f =
          new File("/run/media/sainath/WindowsSSD/wb_dart/web/data/_" + tab);
      f.writeAsStringSync(data);
      request.response.write("{'status' : 'OK'}");
      break;
    case '/markTaskAsDone':
      var taskID = Uri.splitQueryString(payload)['num'];
      var state = Uri.splitQueryString(payload)['state'];
      print(taskID + "--" + state);
      String workBenchFile =
          "/run/media/sainath/WindowsSSD/wb_dart/web/data/_tasks";
      WorkBench wb = WorkBench.parse(WorkBench.readFile(workBenchFile));
      wb.markTaskAsDone(int.parse(taskID), state.toLowerCase() == 'true');
      wb.updateWorkBench(workBenchFile);
      request.response.write("{'status' : 'OK'}");
      break;
    case '/addTask':
      var taskDesc = Uri.splitQueryString(payload)['task'];
      print("add ${taskDesc}");
      String workBenchFile =
          "/run/media/sainath/WindowsSSD/wb_dart/web/data/_tasks";
      WorkBench wb = WorkBench.parse(WorkBench.readFile(workBenchFile));
      wb.addTask(taskDesc);
      wb.updateWorkBench(workBenchFile);
      request.response.write("{'status' : 'OK'}");
      break;
    case '/removeTask':
      var taskID = Uri.splitQueryString(payload)['num'];
      print("remove ${taskID}");
      String workBenchFile =
          "/run/media/sainath/WindowsSSD/wb_dart/web/data/_tasks";
      WorkBench wb = WorkBench.parse(WorkBench.readFile(workBenchFile));
      wb.removeTask(int.parse(taskID));
      wb.updateWorkBench(workBenchFile);
      request.response.write("{'status' : 'OK'}");
      break;
    case '/deferTask':
      var taskID = Uri.splitQueryString(payload)['num'];
      print("defer ${taskID}");
      String workBenchFile =
          "/run/media/sainath/WindowsSSD/wb_dart/web/data/_tasks";
      WorkBench wb = WorkBench.parse(WorkBench.readFile(workBenchFile));
      Task t = wb.removeTask(int.parse(taskID));
      wb.archiveTask(t, "/run/media/sainath/WindowsSSD/wb_dart/web/data"
          "/Archive/deferredTasks.txt");
      wb.updateWorkBench(workBenchFile);
      request.response.write("{'status' : 'OK'}");
      break;

    case '/getAllTasks':
      print("getTasks");
      String workBenchFile =
          "/run/media/sainath/WindowsSSD/wb_dart/web/data/_tasks";
      WorkBench wb = WorkBench.parse(WorkBench.readFile(workBenchFile));
      String reply = wb.getJSON();
      request.response.write(reply);
      print(reply);
      break;
    default:
    // TODO: Forward to static file server
  }
}
