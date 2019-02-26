import 'globals.dart' as globals;

String formatData(String tab, final String text) {
  var tabData = text.trim();
  if (tabData.isEmpty) {
    tabData = "none";
  } else {
    if (tab == 'tasks') {
      tabData = formatTasks(tabData);
    } else {
      tabData = formatATextTab(tabData);
    }
  }
  return tabData;
}

String getRandomTrick(String text) {
  var groups = text.split("\n\n");
  List<String> tricks = [];
  for (var i = 0; i < groups.length; i++) {
    var eachGroup = groups[i].trim();
    if (eachGroup.length == 0) {
      continue;
    }

    eachGroup = eachGroup.trim();
    var lines = eachGroup.split("\n");
    if (lines.length == 1) {
      tricks.add(lines[0]);
    } else if (lines[0].endsWith(":")) {
      for (var j = 1; j < lines.length; j++) {
        tricks.add(lines[0] + " " + lines[j]);
      }
    } else {
      for (var j = 0; j < lines.length; j++) {
        tricks.add(lines[j]);
      }
    }
  }

  return tricks[globals.r.nextInt(tricks.length - 1)];
}

String formatATextTab(String allText) {
  var ret = "";
  var groups = allText.split("\n\n");
  for (var i = 0; i < groups.length; i++) {
    var eachGroup = groups[i].trim();
    if (eachGroup.length == 0) {
      continue;
    }
    var header = getHeader(eachGroup);
    var afterHeader = customFormatting(header);
    if (afterHeader.length == header.length &&
        header.trim().indexOf(":") > -1) {
      ret += "<b>" +
          header.trim().split(":")[0] +
          ":</b>" +
          header.trim().split(":")[1] +
          "<br>";
      ret += body(eachGroup);
    } else {
      ret += customFormatting(eachGroup);
    }
    ret += "<br><br>";
  }
  return ret;
}

String formatTasks(String data) {
  var date = data.split("--updated on");
  data = date[0];
  globals.total = 0;
  globals.done = 0;
  RegExp urlRegex = new RegExp(r">TASK:([Dd]one)?( [Aa]ge:([\d]+))?([^>]+)");

  data = data.replaceAllMapped(urlRegex, (m) => formatIndividualTasks(m));

  double completeStatus = (globals.done / globals.total) * 100;
  if (completeStatus == 0) {
    completeStatus = 3;
  }
  var guage = "<br><br><div class='container'>" +
      "<div class='progress'>" +
      "<div class='progress-bar progress-bar-striped progress-bar-animated' role='progressbar' aria-valuenow='" +
      completeStatus.toString() +
      "' aria-valuemin='0' aria-valuemax='100' style='width:" +
      completeStatus.toString() +
      "%'>" +
      "</div>\n" +
      "  </div></div>";

  var updated = "";
  if (date[1] != null) {
    updated =
        "<p style='float:right'>--<i><b>" + date[1].trim() + "</b></i></p>";
  }
  return "<ul class='list-group'>" + data + '</ul>' + guage + updated;
}

String formatIndividualTasks(Match m) {
  int age = int.parse(m.group(3));
  bool isDone = m.group(1) != null && m.group(1).toLowerCase() == "done";

  String cbeValue = "";
  if(isDone) {
    cbeValue = "checked";
  }
  var data = "<lable><input type='checkbox' " + cbeValue + " "
      "id='cbt_" + globals
      .total.toString() + "'> "
      "</lable>";
  data += "<h7 style='text-align:left;'><strong>" +
      getHeader(m.group(4)) +
      "</strong>";
  var badge = "";
  if (!isDone) {
    if (age > 0) {
      badge = "badge-warning'> " + age.toString();
    } else {
      badge = "badge-info'>new";
    }
  } else {
    badge = "badge-success'>done";
  }
  data +=
      "<span style='float:right;' class='badge badge-pill " + badge + "</span>";
  data += "</h7><br>";
  data += body(m.group(4)) + "";

  if (isDone) {
    data = "<del>" + data + "</del>";
    globals.done++;
  }
  globals.total++;
  return "<li class='list-group-item'><pre>" + data + "</pre></li>";
}

String getHeader(String text) {
  var index = text.indexOf("\n");
  if (index == -1) {
    return text;
  }
  var id = text.substring(0, index);
  if (id.trim().length == 0) {
    id = "Task";
  }
  return id.trim() + " ";
}

String body(String txt) {
  String text = txt;
  var index = text.indexOf('\n');
  if (index == -1) {
    return " ";
  }
  text = text.substring(index + 1);
  var arr = text.split("\n");
  var ret = "";
  RegExp urlRegex = new RegExp(r"(https?://([^\s]+))");
  RegExp fileRegex = new RegExp(r"(file://([^\s]+))");
  for (var i = 0; i < arr.length; i++) {
    String line = arr[i].trim();
    if (line.startsWith("ex: ")) {
      line = "<mark><code>" + line + "</code></mark>";
    } else if (line.startsWith("continue")) {
      line = line.replaceAll("continue ->", "<b>continue:</b>");
      line = "<mark>" + line + "</mark>";
    } else if (line.indexOf(":") > -1 &&
        !urlRegex.hasMatch(line) &&
        !fileRegex.hasMatch(line)) {
      line = "<b>" + line + "</b>";
    }
    ret += "  " + line + "\n";
  }

  return customFormatting("  " + ret.trim() + " ");
}

String customFormatting(String text) {
  return imagify(urlify(formatSource(text)));
}

formatSource(String text) {
  RegExp urlRegex = new RegExp(r"source:[\s]?https?://([^\s]+)");
  return text.replaceFirstMapped(
      urlRegex,
      (match) =>
          '<i>source: </i><a href="${match[1]}" target="_blank"><i>${match[1]}</i></a>');
}

String imagify(String text) {
  RegExp urlRegex = new RegExp(r"img:[\s]?//([^\s]+)");
  return text.replaceAllMapped(
      urlRegex, (match) => '<figure><img src="images/${match[1]}"></figure>');
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
  int counter = globals.urlCounter++;
  String id = "myModal" + counter.toString();
  return '<code><a href="${match[0]}" target="_blank">${match[1]} </a><i class="far fa-hand-point-right" data-toggle="modal" data-target="#' +
      id +
      '" ></i></code>' +
      '<div class="modal fade" id="' +
      id +
      '" style="top:10%; left: 50%;" tabindex="0"><div class="modal-dialog modal-lg"><div class="modal-content">' +
      '<div class="modal-header">\n' +
      '<h4 class="modal-title">URL Preview</h4>' +
      '          <button type="button" class="close" data-dismiss="modal">&times;</button>\n' +
      '        </div>' +
      '<div><object type="text/html" data="${match[0]}" width="800px" height="800px" style="overflow:auto;border:2px ridge blue">Cannot preview URL</object></div></div></div></div>';
}
