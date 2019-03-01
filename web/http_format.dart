import 'globals.dart' as globals;

String formatData(String tab, final String text) {
  var tabData = text.trim();
  if (tabData.isEmpty) {
    tabData = "none";
  } else {
    tabData = formatATextTab(tabData);
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

String getHeader(String text) {
  var index = text.indexOf("\n");
  if (index == -1) {
    return text;
  }
  var id = text.substring(0, index);
  if (id.trim().isEmpty) {
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
      line = "<mark><code>${line}</code></mark>";
    } else if (line.startsWith("continue")) {
      line = line.replaceAll("continue ->", "<b>continue:</b>");
      line = "<mark>${line}</mark>";
    } else if (line.contains(":") &&
        !urlRegex.hasMatch(line) &&
        !fileRegex.hasMatch(line)) {
      line = "<b>${line}</b>";
    }
    ret += "  ${line}\n";
  }

  return customFormatting("  ${ret.trim()} ");
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
  return text.replaceAllMapped(urlRegex,
      (match) => '<figure><img src="images/${match[1]}" alt=""></figure>');
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
  return '<code><a href="${match[0]}" target="_blank">${match[1]} </a></code>';
}
