import 'wb_Workbench.dart';

main(List<String> args) {
  String workBenchFile = "/run/media/sainath/WindowsSSD/wb_dart/web/data/_tasks";
  String archiveFile = "/run/media/sainath/WindowsSSD/wb_dart/web/data/Archive/tasksArchive.txt";
  WorkBench wb = WorkBench.parse(WorkBench.readFile(workBenchFile));
  wb.archiveRequiredTasks(archiveFile);
  wb.updateWorkBench(workBenchFile);
}
