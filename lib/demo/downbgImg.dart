import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../Model.dart';
import '../shareLocal.dart';
import 'localfileUseSetting.dart';
//下载要更换的背景图
chanbgNow(imageUrl) async {
  var listimgcf = imageUrl.split(".").last;//文件的后缀名
  int timesname = DateTime.now().second; // 获取当前时间戳（单位：秒）
  var nowsaImgname ='${timesname}${listimgcf}';//现在的文件名
  var response = await http.get(Uri.parse(imageUrl));
  final documentDirectory = await getApplicationDocumentsDirectory();
  var nowpathimg = '${documentDirectory.path}/${nowsaImgname}';//图片的地址
  final filebgimg = File(nowpathimg);
  await filebgimg.writeAsBytes(response.bodyBytes);
  backimgAll = FileImage(filebgimg);//整个APP的背景图
  streamchangebg.add('$filebgimg');//更换背景图
  StorageUtil.setStringItem('bgImg','$nowpathimg');//整个APP的背景图的地址
}