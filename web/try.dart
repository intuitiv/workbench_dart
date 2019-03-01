import 'package:http/http.dart';
import 'dart:convert';

main(List<String> args) {
  post("http://localhost:4040/getAllTasks").then((response) =>handleResponse
    (response));
}

handleResponse(Response res) {
  print(jsonDecode(res.body)['tasklist'][0]['age']);
}