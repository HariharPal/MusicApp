import 'dart:io';

class ServerConstants {
  static String serverUrl =
      Platform.isAndroid ? "http://192.168.1.8:8000" : "http://127.0.0.1:8000";
}
