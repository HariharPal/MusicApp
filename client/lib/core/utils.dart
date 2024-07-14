import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(content),
      ),
    );
}

Future<File?> pickAudio() async {
  try {
    final filePickerResult =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    if (filePickerResult != null) {
      return File(filePickerResult.files.first.xFile.path);
    }
    return null;
  } catch (e) {
    return null;
  }
}

String rgbToHex(Color color) {
  return "${color.red.toRadixString(16).padLeft(2, "0")}${color.green.toRadixString(16).padLeft(2, "0")}${color.blue.toRadixString(16).padLeft(2, "0")}";
}

Color hexToColor(String hex) {
  return Color(int.parse(hex, radix: 16) + 0xFF000000);
}

Future<File?> pickImage() async {
  try {
    final filePickerResult =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (filePickerResult != null) {
      return File(filePickerResult.files.first.xFile.path);
    }
    return null;
  } catch (e) {
    return null;
  }
}
