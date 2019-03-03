import 'package:args/args.dart';
import 'wb_Workbench.dart';

main(List<String> args) {
  final parser = new ArgParser()..addOption("task", abbr: 't');
  ArgResults results = parser.parse(args);

  String workBenchFile = "/run/media/sainath/WindowsSSD/wb_dart/web/data/_tasks";
  WorkBench wb = WorkBench.parse(WorkBench.readFile(workBenchFile));
  wb.addTask(results['task']);
  wb.updateWorkBench(workBenchFile);
}
