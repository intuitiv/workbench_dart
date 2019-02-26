import 'package:intl/intl.dart';

main(List<String> args) {
  print(new DateFormat("dd/MM/yyyy").format(DateTime.now()));
}

String processMatch(Match match) {
  print("first -> ${match[1]}");
  return "";
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
    return date.toString() + "/" + month.toString() + "/" + year.toString();
  }

  static String currentDate() {
    return new Date(DateTime
        .now()
        .day, DateTime
        .now()
        .month, DateTime
        .now()
        .year).toString();
  }
}