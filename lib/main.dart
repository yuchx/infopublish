//import 'dart:js';flutter3.24.0版本
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//定义两个全局变量用来预约时间
var metOrderStartTime='';
var metOrderEndTime='';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Hello iOS')))));
}


