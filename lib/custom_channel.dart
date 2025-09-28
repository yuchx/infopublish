// TODO Implement this library.import 'package:flutter/services.dart';


import 'package:flutter/services.dart';

final MethodChannel _channel = MethodChannel('com.example.custom_channel');

Future<String> getAndroidManifestVersion() async {
  return await _channel.invokeMethod('getAndroidManifestVersion');
}
Future<bool> myjavaisScreenOn() async {
  return await _channel.invokeMethod('isScreenOn');
}
