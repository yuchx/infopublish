import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileHelper {
  static getLocalPath() async {
    return (await getApplicationDocumentsDirectory()).path;
  }
  Future<File?> getLocalFile(String filename) async {
    // get the path to the document directory.
    try {
      if(filename.isEmpty) {
        print("getLocalFile filename isEmpty");
        filename = "temp";
      }

      String dir = (await getTemporaryDirectory()).path;
      return new File('$dir/$filename.txt');
    } on FileSystemException {
      print("getLocalFile FileSystemException");
      return null;
    }
  }

  Future<String?> readCounter(String filename) async {
    try {
      if(filename.isEmpty) {
        print("readCounter filename isEmpty");
        return "";
      }

      File? file = await getLocalFile(filename);
      // read the variable as a string from the file.
      String? contents = await file?.readAsString();
      return contents;
    } on FileSystemException {
      print("readCounter FileSystemException");
      return "";
    }
  }

  void writeCounter(String filename, String content) async {
    // write the variable as a string to the file
    if(filename.isEmpty) {
      print("writeCounter filename isEmpty");
      return;
    }

    print("writeCounter $content");
    await (await getLocalFile(filename))?.writeAsString(content);
  }
}