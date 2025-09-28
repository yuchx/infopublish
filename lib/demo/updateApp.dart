import 'package:external_path/external_path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import '../Model.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:isolate';
import 'dart:ui';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';
//解压缩
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import "package:system_info2/system_info2.dart";

import 'package:crypto/crypto.dart';

import '../shareLocal.dart';
//更新APP的弹窗
class cenNewDownApp extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _statenewappPart();
  }
}

String localappPath="";//热更新文件的存放位置
String? taskIdnewapp;//下载热更新包的ID
List taskhotfiIdlist = [];//下载热更新的下载的taskid的队列集合---(需要存在缓存里，每次替换文件以后在检测是否还有任务需要更新)
class _statenewappPart extends State<cenNewDownApp>{

  ProgressDialog? newpro;
  ReceivePort downport = ReceivePort();
  bool _softwareRendering = false;//是否使用软件渲染器
  @override
  void initState() {
    super.initState();
    // WidgetsFlutterBinding.ensureInitialized();
    // FlutterDownloader.initialize(debug:true).then((v){
    //   initapp();
    // }).catchError((e) {
    //   print('$e');
    //   initapp();
    // });
    initapp();
    // azhuang();

  }
  DownloadTaskStatus appdownstatus = DownloadTaskStatus.fromInt(0);
  initapp() async{
    if(await _checkPermission()){
      //获取路径
      localappPath = await _findLocalPathTwo();//获取热更新文件的存放位置
      // if (Platform.isAndroid) {
      //   await Permission.storage.request();
      // }
      // 初始化进度条
      IsolateNameServer.registerPortWithName(downport.sendPort, 'newapp_port');
      downport.listen((dynamic data) {
        String id = data[0];
        appdownstatus = DownloadTaskStatus.fromInt(data[1]);
        // print(data[2].toString());
        if(appdownstatus== DownloadTaskStatus.running){
          print("最新版APP下载中-----------------------------------------");
        }
        if(appdownstatus == DownloadTaskStatus.complete){
          //判断最后一个taskId//下载队列不是空
          if(taskhotfiIdlist.length>0){
            if(taskhotfiIdlist.contains('$id')==true){
              //当前ID在下载队列中
              if(taskhotfiIdlist.last=='$id'){
                //如果当前下载的ID是最后一个下载任务
                Fluttertoast.showToast(msg: "最新版APP下载完成");
                deviceLogAdd(7,"热更新文件下载完成！","热更新文件下载完成！");
                devicehotUpAdd(2);//走接口更新版本热更新的更新状态--下载成功
                Future.delayed(Duration(seconds: 1), (){
                  unTonlePlayerZip(); //下载完成以后验证完整性再去解压TonlePlayer.zip
                });
              }
            }
          }
          // 打开文件,apk的名称需要与下载时对应
        }
        if(appdownstatus== DownloadTaskStatus.failed){


          if(taskhotfiIdlist.length>0){
            if(taskhotfiIdlist.contains('$id')==true){
              //当前ID在下载队列中
              if(taskhotfiIdlist.last=='$id'){
                //如果当前下载的ID是最后一个下载任务
                print("最新版APP下载失败");
                Fluttertoast.showToast(msg: "最新版APP下载失败");
                deviceLogAdd(7,"热更新文件下载失败！","热更新文件下载失败！");
                devicehotUpAdd(-2);//走接口更新版本热更新的更新状态--下载失败
                hideshowhotload(0);//隐藏热更新弹窗动画
                var posalUrlGetToken = 'http://$posalUrl:$posalport';
                deviceLogAdd(7,"$deviceID下载热更新文件失败5分钟后重新下载","$deviceID下载热更新文件失败5分钟后重新下载");
                Future.delayed(Duration(seconds: 300), (){
                  hideshowhotload(1);//显示热更新弹窗动画
                  _nowappDownload(posalUrlGetToken);//下载安装包
                });
              }
            }
          }


        }
      });
      FlutterDownloader.registerCallback(downloadCallback);
    }else{
    }
  }
  //验证下载完的压缩包的完整性然后解压
  void unTonlePlayerZip() async{

    final filePath = '$localappPath/TonlePlayer.zip';
    print('路径地址：$localappPath/TonlePlayer.zip');
    String zipFilePath = '$localappPath/TonlePlayer.zip';
    deviceLogAdd(7,"开始解压热更新文件$localappPath/TonlePlayer.zip","开始解压热更新文件$localappPath/TonlePlayer.zip");
    Fluttertoast.showToast(msg: "开始解压热更新文件$localappPath/TonlePlayer.zip");
    if(File(zipFilePath).existsSync()){
      //暂时注释掉，因为每次更换文件的流不一样，MQTT还没有发命令，暂时还没法验证
      var fileyanzheng = File(filePath);
      var bytesyanzheng = await fileyanzheng.readAsBytes();
      var mymd5 = md5.convert(bytesyanzheng);// 计算文件的md5值
      var calculatedChecksum = mymd5.toString();
      // var calculatedChecksum = "ae241a898f58fefe1492818ebe63a434";//暂时写死假设文件流一致，因为MQTT还没有发消息
      if (expectedChecksum == calculatedChecksum) {
        print('文件完整性验证通过');
        deviceLogAdd(7,"文件完整性验证通过","文件完整性验证通过");
        List<int> bytes =[];
        try{
          try{
            // 从磁盘读取Zip文件。
            bytes = File(zipFilePath).readAsBytesSync();
            deviceLogAdd(7,"读取热更新文件成功！","读取热更新文件成功！");
          }on FileSystemException{
            deviceLogAdd(7,"读取热更新文件失败！","读取热更新文件失败！");
            devicehotUpAdd(-4);//走接口更新版本热更新的更新状态--更新失败
            hideshowhotload(0);//隐藏热更新弹窗动画
          }
          // 解码Zip文件
          Archive archive = ZipDecoder().decodeBytes(bytes);
          // 将Zip存档的内容解压缩到磁盘。
          await Directory(localappPath+"/TonlePlayer")
            ..create(recursive: true);
          for (ArchiveFile file in archive) {
            if (file.isFile) {
              List<int> data = file.content;
              await File(localappPath+"/TonlePlayer/"+file.name)
                ..createSync(recursive: true)
                ..writeAsBytesSync(data);
            } else {
              await Directory(localappPath+"/TonlePlayer/"+file.name)
                ..create(recursive: true);
            }
          }
          print("热更新文件解压成功");
          Fluttertoast.showToast(msg: "热更新文件解压成功");
          deviceLogAdd(7,"热更新文件解压成功","热更新文件解压成功！");
          StorageUtil.remove('bgImg');//清除掉存在缓存中的服务器发过来的改变的背景图
          devicehotUpAddNew(3);//走接口更新版本热更新的更新状态--开始替换文件
        }on ArchiveException{
          const int MEGABYTE = 1024 * 1024;
          print("空闲物理内存 : ${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB");
          print("热更新文件解压失败");
          deviceLogAdd(7,"热更新文件解压失败！空闲物理内存${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB","热更新文件解压失败！空闲物理内存${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB");
          devicehotUpAdd(-4);//走接口更新版本热更新的更新状态--更新失败
          hideshowhotload(0);//隐藏热更新弹窗动画
          // Future.delayed(Duration(seconds: 10), (){
          //   deviceLogAdd(0,"10S后重新解压","10S后重新解压");
          //   unZip(idpro);
          // });
        }
      } else {
        print('文件完整性验证失败');
        deviceLogAdd(7,"热更新文件完整性验证失败文件不完整","热更新文件完整性验证失败文件不完整");
        devicehotUpAdd(-4);//走接口更新版本热更新的更新状态--更新失败
        hideshowhotload(0);//隐藏热更新弹窗动画
      }
    }else{
      Fluttertoast.showToast(msg: "热更新压缩文件本地不存在1");
      deviceLogAdd(7,"热更新压缩文件本地不存在1","热更新压缩文件本地不存在1");
      devicehotUpAdd(-4);//走接口更新版本热更新的更新状态--更新失败
      hideshowhotload(0);//隐藏热更新弹窗动画

    }
  }

  @override
  void dispose() {
    downport.close();
    IsolateNameServer.removePortNameMapping('newapp_port');
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    ////去下载更新TonlePlayer
    return StreamBuilder(
        stream: streanupApp.stream,
        builder:(context,snapshot){
          if(showupApp==1){
            showupApp=0;
            var posalUrlGetToken = 'http://$posalUrl:$posalport';
            _nowappDownload(posalUrlGetToken);//下载安装包
            // var posalUrlGetToken = 'http://172.16.10.105:58992';
          }else{
          }
          return Container();
        }
      );
  }

  //文件下载
  _nowappDownload(pathurl){
//    pro.show();
    Fluttertoast.showToast(msg: "去下载TonlePlayer的压缩包");
    deviceLogAdd(7,"去下载TonlePlayer的压缩包$pathurl$hotdownpath","去下载TonlePlayer的压缩包$pathurl$hotdownpath");
    // String _urldown = "$pathurl/UpdatePlayer/TonlePlayer.zip";
    String _urldown = "$pathurl$hotdownpath";
    _downloadhotFile(
      downloadUrl: _urldown,
      savePath: localappPath,
    );
  }

  // 判断是否拿到权限
  Future<bool> _checkPermission() async {
    // 先对所在平台进行判断
    if (await Permission.storage.request().isGranted) {
      return true;
    }else{
      return false;
    }
  }

  // 获取存储路径
  Future<String> _findLocalPathTwo() async {
    //设备根目录的Download文件夹
    var path = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
    print(path);  // /storage/emulated/0/Download
    return path;
  }

  // 根据 downloadUrl 和 savePath 下载文件
  _downloadhotFile({downloadUrl, savePath}) async {
    print("下载名称：TonlePlayer.zip");
    //去下载最新版的APP  taskIdnewapp下载的热更新的下载进程的ID
    deviceLogAdd(7,"开始下载热更新文件","开始下载热更新文件");
    taskIdnewapp = await FlutterDownloader.enqueue(
      url: downloadUrl,
      savedDir: savePath,
      fileName: 'TonlePlayer.zip',
      showNotification: true,
      openFileFromNotification: true, // click on notification to open downloaded file (for Android)
    );
    print('$taskIdnewapp');
    taskhotfiIdlist.add('$taskIdnewapp');//放入热更新下载文件队列集合中
  }

  Future<bool> verifyFile(String filePath, String expectedChecksum) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();

    // 计算文件的md5值
    final mymd5 = md5.convert(bytes);
    final calculatedChecksum = mymd5.toString();

    if (expectedChecksum == calculatedChecksum) {
      print('文件完整性验证通过');
      return true;
    } else {
      print('文件完整性验证失败');
      return false;
    }
  }
//自己杀自己关掉进程，不能真正的杀掉进程，只是程序停止运行了
void closeMySystem(){
  SystemNavigator.pop();
}

}

