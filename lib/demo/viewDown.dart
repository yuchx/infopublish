import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/src/types/load_request_params.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'localfileUseSetting.dart';
import 'updateApp.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Model.dart';
import '../mqtt/MQTTManager.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//新的webview插件
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:isolate';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


import 'dart:async';
import 'dart:io';
//解压缩
// import 'package:archive/archive.dart';
// import 'package:archive/archive_io.dart';
import 'package:flutter_archive/flutter_archive.dart';
import "package:system_info2/system_info2.dart";
//截取屏幕
import 'package:screenshot/screenshot.dart';

import '../shareLocal.dart';
class viewPart extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _stateviewPart();
  }
}

class _stateviewPart extends State<viewPart>{
//  WebViewController _webViewController;
//  String filePath = 'file:///storage/emulated/0/Android/data/com.tonle.flutterInfopublishapp/files/download/26a935a8-7a89-457e-aac6-81efcbf6aadc/26a935a8-7a89-457e-aac6-81efcbf6aadc.html';
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping("downloader_send_port");
    // mywebViewController = null;
    FlutterDownloader.cancelAll();
    super.dispose();
  }

  // final GlobalKey webViewKey = GlobalKey();
  // InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
  //   crossPlatform: InAppWebViewOptions(
  //     useShouldOverrideUrlLoading: true,
  //     mediaPlaybackRequiresUserGesture: false,//解决自动播放video视频
  //     allowFileAccessFromFileURLs:true,
  //     allowUniversalAccessFromFileURLs:true,
  //   ),
  //   /// android 支持HybridComposition
  //   android: AndroidInAppWebViewOptions(
  //     useHybridComposition: true,
  //   ),
  //   ios: IOSInAppWebViewOptions(
  //     allowsInlineMediaPlayback: true,
  //   ),
  // );
//节目的类型（0展示空白内容，1下载节目，2播放节目，3下载并加载节目）
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
//    var mywebUrl = 'file:///storage/emulated/0/Android/data/com.tonle.flutterInfopublishapp/files/download/3939f44f-dad8-4be4-8065-51775ca09aae/3939f44f-dad8-4be4-8065-51775ca09aae.html';
    mywebUrl = 'file://$mylocaPath/$playproId/${playproId}.html';
    print('webUrl:$mywebUrl');
    return StreamBuilder(
        stream: streamDemo.stream,
        builder:(context,snapshot){
          mywebUrl = 'file://$mylocaPath/$playproId/${playproId}.html';
          // var playyes=0;
          // if(playType=='1'){
          //   var posalUrlGetToken = 'http://$posalUrl:$posalport';
          //   _doDownload(posalUrlGetToken,proIdOfdownload,playType);
          // }else if(playType=='3'){
          //   var posalUrlGetToken = 'http://$posalUrl:$posalport';
          //   _doDownload(posalUrlGetToken,proIdOfdownload,playType);
          // }
          if(playproId=='0'){
            return Stack(
              children: [
                Positioned(
                    child: Container(
                      color:Colors.transparent,
                      child: playType!='2'&&playType!='0'?downproThing():Container(),
                    )
                ),
                Container(
                    height: havePro==2?ScreenUtil().setHeight(1080):ScreenUtil().setHeight(703),
                    width: havePro==2?ScreenUtil().setWidth(1920):ScreenUtil().setWidth(1250),
                    padding: EdgeInsets.all(0),
                    child: Text(
                        '$proIdOfdownload,$playproId,$playType',
                        style:TextStyle(color: Color.fromRGBO(69, 155, 242, 0))
                    ),
                    decoration: BoxDecoration(
                      color:  Colors.transparent,
                    )
                )
              ],
            );
          }else{
            return Stack(
              children: <Widget>[
                Positioned(
                    child: Container(
                      color:Colors.transparent,
                      child: playType!='2'&&playType!='0'?downproThing():Container(),
                    )
                ),
                Positioned(
                  child: Text(
                      '$proIdOfdownload,$playproId,$playType',
                      style:TextStyle(color: Color.fromRGBO(69, 155, 242, 0))
                  ),
                ),
                // InAppWebView(
                //   key: webViewKey,
                //   initialUrlRequest:URLRequest(url: Uri.parse(mywebUrl)),
                //   initialOptions: options,
                //   initialUserScripts: UnmodifiableListView<UserScript>([]),
                //   onWebViewCreated: (InAppWebViewController controller) {
                //     mywebViewController = controller;
                //   },
                //   androidOnPermissionRequest: (controller, origin, resources) async {
                //     return PermissionRequestResponse(
                //         resources: resources,
                //         action: PermissionRequestResponseAction.GRANT);
                //   },
                //   shouldOverrideUrlLoading: (controller, navigationAction) async {
                //     var uri = navigationAction.request.url;
                //
                //     if (![ "http", "https", "file", "chrome",
                //       "data", "javascript", "about"].contains(uri.scheme)) {
                //       if (await canLaunch(mywebUrl)) {
                //         // Launch the App
                //         await launch(
                //           mywebUrl,
                //         );
                //         // and cancel the request
                //         return NavigationActionPolicy.CANCEL;
                //       }
                //     }
                //
                //     return NavigationActionPolicy.ALLOW;
                //   },
                //   onLoadStart: (controller, url) async {
                //
                //   },
                //   onLoadStop: (controller, url) async {
                //     playyes=1;
                //   },
                //   onLoadError: (controller,url, code, message) {
                //     print(message);
                //     if('$playyes'=='0'){
                //       if(url.toString().indexOf('.html')>=0){
                //         // controller.loadFile(assetFilePath: 'images/5.png');
                //         controller.loadUrl(urlRequest: URLRequest(
                //             url: Uri.dataFromString()
                //         ));
                //       }
                //     }
                //   },
                // )
                myProviewShow(),

              ],
            );
          }
        });
  }


  // static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
  //   final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');
  //   send.send([id, status, progress]);
  // }
}

//把下载单独拿出来
class downproThing extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _mydownproState();
  }
}
class _mydownproState extends State<downproThing>{
  ProgressDialog? pro;
  ReceivePort proport = ReceivePort();
  bool _softwareRendering = false;//是否使用软件渲染器
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _setSoftwareRendering(true);
    }
    // WidgetsFlutterBinding.ensureInitialized();
    init();
    // //初始化FlutterDownloader
    // FlutterDownloader.initialize(debug:true).then((v){
    //   init();
    // }).catchError((e) {
    //   print('$e');
    //   init();
    // });
  }
  DownloadTaskStatus status = DownloadTaskStatus.fromInt(0);
  init() async{
    // if(await _checkPermission()){
      //获取路径
      mylocaPath = await _findLocalPath();

      IsolateNameServer.removePortNameMapping('downloader_send_port');// 确保之前没有残留的注册
      // 初始化进度条
      IsolateNameServer.registerPortWithName(proport.sendPort, 'downloader_send_port');// 注册端口（名字要和回调里 lookupPortByName 的一致）
      proport.listen((dynamic data) {

        final String id = data[0] as String;
        final int rawStatus = data[1] as int;
        final int progress = data[2] as int;

        status = DownloadTaskStatus.fromInt(rawStatus);
        print('监听到下载进度：$progress%, 状态=$status, taskId=$id');
        // String id = data[0];
        // status = data[1];
        // print(data[2].toString());
        if(status == DownloadTaskStatus.running){
          print("下载中");
//          pro.update(progress: 0.0,message: "下载中");
        }
        if(status== DownloadTaskStatus.complete){
          print("下载完成");
          deviceLogAdd(10,"下载完成！$proIdOfdownload","下载完成！$proIdOfdownload");

          if(taskhotfiIdlist.length>0){
            if(taskhotfiIdlist.contains('$id')==false){
              //当前ID不在热更新下载队列中-热更新的ID不等于本次ID，说明不是热更新的ID，是下载节目的ID
              deviceLogAdd(10,"节目下载完成！$proIdOfdownload","节目下载完成！$proIdOfdownload");
              Future.delayed(Duration(seconds: 2), (){
                unZip(proIdOfdownload);
              });
            }else{
              print("是热更新的下载完成");
            }
          }else{
            //没有热更新文件的队列
            deviceLogAdd(10,"节目下载完成！$proIdOfdownload","节目下载完成！$proIdOfdownload");
            Future.delayed(Duration(seconds: 2), (){
              unZip(proIdOfdownload);
            });
          }
        }
        if(status== DownloadTaskStatus.failed){
          print("下载失败");
          //下载失败后重新下载
          var posalUrlGetToken = 'http://$posalUrl:$posalport';

          if(taskhotfiIdlist.length>0){
            if(taskhotfiIdlist.contains('$id')==false){
              //当前ID不在热更新下载队列中-热更新的ID不等于本次ID，说明不是热更新的ID，是下载节目的ID
              deviceLogAdd(-1,"$deviceID下载失败5S后重新下载！节目ID$proIdOfdownload","$deviceID下载失败重新下载！节目ID$proIdOfdownload");
              Future.delayed(Duration(seconds: 5), (){
                _doDownload(posalUrlGetToken,proIdOfdownload,playType);
              });
            }else{
              print("是热更新的下载完成");
            }
          }else{
            //没有热更新文件的队列
            deviceLogAdd(-1,"$deviceID下载失败5S后重新下载！节目ID$proIdOfdownload","$deviceID下载失败重新下载！节目ID$proIdOfdownload");
            Future.delayed(Duration(seconds: 5), (){
              _doDownload(posalUrlGetToken,proIdOfdownload,playType);
            });
          }



        }
      });
      FlutterDownloader.registerCallback(downloadCallback);
//     }else{
// //      Toast.show("没有权限，请打开存储权限！", context);
//     }
  }

  void unZip(idpro) async{
    print('$idpro');
    print('路径地址：$mylocaPath/$idpro');
    String zipFilePath = '$mylocaPath/${idpro}.zip';
    String htmlFilePath = '$mylocaPath/${idpro}/${idpro}.html';
    //html文件存不存在
    if(File(htmlFilePath).existsSync()){
      if(playType=='3'){
        Future.delayed(Duration(seconds: 5), (){
          steamProplayplay(proIdOfdownload);//播放下载的节目
        });
      }
    }else{
      const int MEGABYTE = 1024 * 1024;
      print("空闲物理内存 : ${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB");
      if(File(zipFilePath).existsSync()){

        deviceLogAdd(10,"开始解压物理内存 : ${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB$idpro","开始解压物理内存 : ${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB$idpro");
        // List<int> _zipbytes =[];
        // try{
          // try{
          // 从磁盘读取Zip文件。
          // _zipbytes = File(zipFilePath).readAsBytesSync();
          try {
            final zipFile = File(zipFilePath);
            final destinationDir = await Directory(mylocaPath+"/"+idpro);
            await ZipFile.extractToDirectory(
                zipFile: zipFile, destinationDir: destinationDir,
                // onExtracting: (zipEntry, progress) {
                //   print('progress: ${progress.toStringAsFixed(1)}%');
                //   print('name: ${zipEntry.name}');
                //   print('isDirectory: ${zipEntry.isDirectory}');
                //   print(
                //       'modificationDate: ${zipEntry.modificationDate.toLocal().toIso8601String()}');
                //   print('uncompressedSize: ${zipEntry.uncompressedSize}');
                //   print('compressedSize: ${zipEntry.compressedSize}');
                //   print('compressionMethod: ${zipEntry.compressionMethod}');
                //   print('crc: ${zipEntry.crc}');
                //   return ZipFileOperation.includeItem;
                // }
            );
            print("解压成功");
            deviceLogAdd(10,"解压成功${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB$deviceID","解压成功！${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB$deviceID");
            if(playType=='3'){
              Future.delayed(Duration(seconds: 5), (){
                steamProplayplay(proIdOfdownload);//播放下载的节目
              });

            }
          } catch(e,stack){
            // deviceLogAdd(0, '解压时报错${e.message}', '解压报错${e.message}');
            deviceLogAdd(-1, '解压：${e}', '$runtimeType：${e.runtimeType}');
            // deviceLogAdd(0, '解压：${e}message：${e.message}', '$runtimeType：${e.runtimeType}message：${e.message}${e.osError.message}');
            // deviceLogAdd(0, 'stack:${stack}', '解压失败堆栈信息');
            print('${e.runtimeType}');//FileSystemException
            const int MEGABYTE = 1024 * 1024;
            print("空闲物理内存 : ${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB");
            print("解压失败");
            // deviceLogAdd(-1,"解压失败！空闲物理内存${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB","解压失败！空闲物理内存${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB");
            // Future.delayed(Duration(seconds: 10), (){
            //   deviceLogAdd(0,"10S后重新解压","10S后重新解压");
            //   unZip(idpro);
            // });
          }
          // deviceLogAdd(0,"读取文件成功物理内存 : ${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB！","读取文件成功物理内存 : ${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB！");
          // 解码Zip文件
          // Archive _archive = ZipDecoder().decodeBytes(_zipbytes);
          // await Directory(mylocaPath+"/"+idpro)
          //   ..create(recursive: true);// 将Zip存档的内容解压缩到磁盘。
          // for (ArchiveFile _arfile in _archive) {
          //   if (_arfile.isFile) {
          //     List<int> _fidata = _arfile.content;
          //     await File(mylocaPath+"/"+idpro+"/"+_arfile.name)
          //       ..createSync(recursive: true)
          //       ..writeAsBytesSync(_fidata);
          //   } else {
          //     await Directory(mylocaPath+"/"+idpro+"/"+_arfile.name)
          //       ..create(recursive: true);
          //   }
          // }

          // var inputStreamA = InputStream(zipFilePath);
          //
          //
          // final archive = ZipDecoder().decodeBuffer(inputStreamA);
          // for (var fileli in archive.files) {
          //   if (fileli.isFile) {
          //     final outputStream = OutputFileStream('out/${fileli.name}');
          //
          //     fileli.writeContent(outputStream);
          //     outputStream.close();
          //   }
          // }
          // }on FileSystemException catch(e){
          //   deviceLogAdd(0,"读取文件失败！${e.message}","读取文件失败！$e");
          // }
        // }catch(e,stack){
        //   // deviceLogAdd(0, '解压时报错${e.message}', '解压报错${e.message}');
        //   deviceLogAdd(-1, '解压：${e}message：${e.message}', '$runtimeType：${e.runtimeType}message：${e.message}');
        //   // deviceLogAdd(0, '解压：${e}message：${e.message}', '$runtimeType：${e.runtimeType}message：${e.message}${e.osError.message}');
        //   // deviceLogAdd(0, 'stack:${stack}', '解压失败堆栈信息');
        //   print('${e.runtimeType}');//FileSystemException
        //   const int MEGABYTE = 1024 * 1024;
        //   print("空闲物理内存 : ${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB");
        //   print("解压失败");
        //   deviceLogAdd(-1,"解压失败！空闲物理内存${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB","解压失败！空闲物理内存${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB");
        //   // Future.delayed(Duration(seconds: 10), (){
        //   //   deviceLogAdd(0,"10S后重新解压","10S后重新解压");
        //   //   unZip(idpro);
        //   // });
        // }
      }else{
        deviceLogAdd(-1,"压缩文件$idpro不存在1","压缩文件$idpro不存在11");

      }
    }
  }
  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping("downloader_send_port");// 一般在 dispose 时，注销端口
    FlutterDownloader.cancelAll();
    super.dispose();
  }
  void _setSoftwareRendering(bool useSoftwareRendering) {
    if (useSoftwareRendering != _softwareRendering) {
      _softwareRendering = useSoftwareRendering;
      if (_softwareRendering) {
        // 启用软件渲染器---暂时注释掉
        // WebView.platform = SurfaceAndroidWebView();

      }
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(playType=='1'){
      var posalUrlGetToken = 'http://$posalUrl:$posalport';
      _doDownload(posalUrlGetToken,proIdOfdownload,playType);
    }else if(playType=='3'){
      var posalUrlGetToken = 'http://$posalUrl:$posalport';
      _doDownload(posalUrlGetToken,proIdOfdownload,playType);
    }
    return Container();
  }
  //文件下载
  _doDownload(pathurl,ProgramId,playType){
//    pro.show();
    String _urldown = "$pathurl/RegisterPlayer/ProjrctDownload?projectId=$ProgramId";

    _downloadFile(
      downloadUrl: _urldown,
      savePath: mylocaPath,
      proid: ProgramId,
      playType: playType,
    );
  }
  // 判断是否拿到权限
  Future<bool> _checkPermission() async {
    // 先对所在平台进行判断
    if (Theme.of(context).platform == TargetPlatform.android) {
      if (await Permission.storage.request().isGranted) {
        return true;
      }else{
        return false;
      }
      // PermissionStatus permission = await PermissionHandler()
      //     .checkPermissionStatus(PermissionGroup.storage);
      // if (permission != PermissionStatus.granted) {
      //   Map<PermissionGroup, PermissionStatus> permissions =
      //   await PermissionHandler()
      //       .requestPermissions([PermissionGroup.storage]);
      //   if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
      //     return true;
      //   }
      // } else {
      //   return true;
      // }
    } else {
      return true;
    }
    return false;
  }
  // 获取存储路径
  Future<String> _findLocalPath() async {
    // 因为Apple没有外置存储，所以第一步我们需要先对所在平台进行判断
    // 如果是android，使用getExternalStorageDirectory  getTemporaryDirectory
    // 如果是iOS，使用getApplicationSupportDirectory
    // androidPath 用于存储安卓段的路径
    String androidPath = "";
    // final directory = Theme.of(context).platform == TargetPlatform.android
    //     ? await getExternalStorageDirectory().then((f){
    //   print(f.path);
    //   androidPath = f.path + "/download";
    // })
    //     : await getApplicationSupportDirectory();

    final directory = await getExternalStorageDirectory().then((f){
      print(f?.path);
      androidPath = (f!.path + "/download")!;
    });

    //判断androidPath是否为空 为空返回ios的路径 否则 返回android的路径
    if(androidPath!=""){
      final savedDir = Directory(androidPath);
      // 判断下载路径是否存在
      bool hasExisted = await savedDir.exists();
      // 不存在就新建路径
      if (!hasExisted) {
        savedDir.create();
      }
      return androidPath;
    }else{
      return directory.path;
    }
  }
  // 根据 downloadUrl 和 savePath 下载文件
  _downloadFile({downloadUrl, savePath,proid,playType}) async {
    print("下载名称：$proid");
    //下载不播放
    var downFilePath = '$mylocaPath/$playproId';
    var downFilezipPath = '$mylocaPath/${playproId}.zip';
    if(playType=='1'){
      downFilePath = '$mylocaPath/$proIdOfdownload';
      downFilezipPath = '$mylocaPath/${proIdOfdownload}.zip';
    }
    //节目文件已经存在就不去下载和解压缩了
    if(File(downFilePath).existsSync()){
      //如果是下载完立即播放的类型，节目已经存在则立即播放
      if(playType=='3'){
        Future.delayed(Duration(seconds: 3), (){
          steamProplayplay(proIdOfdownload);//播放下载的节目
        });
      }
    }else{
      //压缩包存在
      if(File(downFilezipPath).existsSync()){
        if(status == DownloadTaskStatus.complete||status== DownloadTaskStatus.undefined){
          Future.delayed(Duration(seconds: 2), (){
            unZip(proid);
          });
        }
        if(status == DownloadTaskStatus.failed){
          status = DownloadTaskStatus.undefined;
          await  FlutterDownloader.enqueue(
            url: downloadUrl,
            savedDir: savePath,
            fileName: '${proid}.zip',
            showNotification: true,
            openFileFromNotification: true, // click on notification to open downloaded file (for Android)
          );
        }
      }else if(File(downFilezipPath).existsSync()&&status== DownloadTaskStatus.running){
        //下载中并且压缩文件已经存在不去下载（下载中的时候。zip文件已经存在）
      }else if(!File(downFilezipPath).existsSync()){
        //压缩包不存在
        await  FlutterDownloader.enqueue(
          url: downloadUrl,
          savedDir: savePath,
          fileName: '${proid}.zip',
          showNotification: true,
          openFileFromNotification: true, // click on notification to open downloaded file (for Android)
        );
      }
    }

  }
  // 根据taskId打开下载文件
  Future<bool> _openDownloadedFile(taskId) {
    return FlutterDownloader.open(taskId: taskId);
  }
}

//把webview单独拿出来
class myProviewShow extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    // return _myProviewState();
    return _MyAndroidWebViewState();
  }
}
//把webview单独拿出来
// class _myProviewState extends State<myProviewShow>{
//   void initState() {
//     super.initState();
//
//     var playyes=0;
//     late final PlatformWebViewControllerCreationParams params;
//     if (WebViewPlatform.instance is WebKitWebViewPlatform) {
//       params = WebKitWebViewControllerCreationParams(
//         allowsInlineMediaPlayback: true,
//         mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
//       );
//     } else {
//       print(WebViewPlatform.instance);//AndroidWebViewPlatform
//       params = const PlatformWebViewControllerCreationParams();
//     }
//     // WebViewController controller = WebViewController.fromPlatformCreationParams(params);
//     mywebViewController = WebViewController.fromPlatformCreationParams(params)
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onNavigationRequest: (NavigationRequest request) {
//             if (request.url.startsWith('js://webview')) {
//               Fluttertoast.showToast(msg: 'JS调用了Flutter By navigationDelegate');
//               print('blocking navigation to $request}');
//               return NavigationDecision.prevent;
//             }
//             return NavigationDecision.navigate;
//           },
//           onPageFinished: (String url) async {
//             print('Page finished loading: $url');
//             setState(() {
//               playyes = 1;
//             });
//             Directory cacheDir = await getTemporaryDirectory();
//             if (cacheDir.existsSync()) {
//               // 清除缓存
//               cacheDir.deleteSync(recursive: true);
//               const int MEGABYTE = 1024 * 1024;
//               print("加载完成物理内存 : ${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB");
//               deviceLogAdd(0,
//                   "加载完成物理内存${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB",
//                   "加载完成物理内存${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB");
//             }
//             //播放视频--静音播放
//             await mywebViewController.runJavaScript("""
//                 var videos = document.querySelectorAll('video');
//                 videos.forEach((video) => {
//                   video.muted = true;
//                   video.play().catch(e => console.log(e));
//                 });
//               """);
//             // 如果需要，可以在这里执行 JavaScript
//             // _controller.runJavaScript("videohavePlay()");
//           },
//           onWebResourceError: (WebResourceError error) async {
//             if('$playyes'=='0'){
//               mywebViewController?.loadHtmlString(
//                   '<div style="position:absolute;top:0;left:0;width:100%;height:100%;background-color:#181B2A;"></div>'
//               );
//               //背景
//               playyes=2;//加载了没有加载的图
//               //加载节目时的背景图
//               ByteData bytesA = await rootBundle.load('images/backImg.png');
//               var bufferA = bytesA.buffer;
//               var backImgA = base64.encode(Uint8List.view(bufferA));
//
//               var nowbgpath = await StorageUtil.getStringItem('bgImg');//整个APP的背景图的地址
//               if(nowbgpath!=null&&nowbgpath!='null'&&nowbgpath!=''){
//                 File filebgimg = File(nowbgpath);
//                 //读缓存里的背景图的地址
//                 bool imageExists = filebgimg.existsSync();
//                 if (imageExists) {
//                   print('缓存里的图片存在');
//                   Uint8List imageBytes = await filebgimg.readAsBytes();
//                   backImgA = base64.encode(imageBytes);
//                 } else {
//                   print('缓存里图片不存在，继续使用代码里的图片');
//                 }
//               }
//
//               //动图
//               ByteData bytesB = await rootBundle.load('images/hoticon.gif');
//               var bufferB = bytesB.buffer;
//               var backImgB = base64.encode(Uint8List.view(bufferB));
//
//               if(error.url!.indexOf('.html')>=0){
//                 mywebViewController?.loadHtmlString(
//                     '<img style="position: absolute;left:0;top:0;width:100%;height:100%;" src="data:image/png;base64,$backImgA"><div style="position: absolute;left:0;top:0;width:100%;height:100%;background-color:rgba(24,27,42,0.8);"></div><img style="position: absolute;left:50%;top:43%;width:160px;height:160px;margin-left:-80px;margin-top:-80px;" src="data:image/gif;base64,$backImgB"><div style="position: absolute;left:0%;top:43%;width:100%;height:50px;line-height:50px;margin-top:80px;font-size:24px;color:#ffffff;text-align:center;">加载中，请稍后</div>'
//                 );
//               }
//             }
//           },
//         ),
//       )
//       ..setBackgroundColor(Colors.transparent)
//       ..addJavaScriptChannel(
//         'YourChannelName',
//         onMessageReceived: (JavaScriptMessage message) {
//           // 处理来自JavaScript的消息
//           print(message.message);
//         },
//       )
//       ..loadRequest(Uri.parse(mywebUrl));
//
//   }
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return WebViewWidget(controller: mywebViewController);
//   }
//   @override
//   void dispose() {
//     // mywebViewController = null;
//     super.dispose();
//   }
// }

class _MyAndroidWebViewState extends State<myProviewShow> {
  // late final AndroidWebViewController _androidController;
  // late final PlatformWebViewController _controller;
  @override
  void initState() {
    super.initState();
    var playyes=0;
    final AndroidWebViewControllerCreationParams params = AndroidWebViewControllerCreationParams();
    // 1. 创建 AndroidNavigationDelegate 来监听事件
    final PlatformNavigationDelegateCreationParams baseParams = const PlatformNavigationDelegateCreationParams();
    final AndroidNavigationDelegateCreationParams androidParams =
    AndroidNavigationDelegateCreationParams.fromPlatformNavigationDelegateCreationParams(
      baseParams,
      // 如果需要测试替换 androidWebViewProxy，可以在这里传
    );
    final AndroidNavigationDelegate navDelegate = AndroidNavigationDelegate(androidParams);
    // 根据需要设置回调
    navDelegate.setOnPageFinished((String url) async {
      debugPrint('Android WebView加载完成: $url');
      print('Page finished loading: $url');
      setState(() {
        playyes = 1;
      });
      Directory cacheDir = await getTemporaryDirectory();
      if (cacheDir.existsSync()) {
        // 清除缓存
        cacheDir.deleteSync(recursive: true);
        const int MEGABYTE = 1024 * 1024;
        print("加载完成物理内存 : ${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB");
        deviceLogAdd(0,
            "加载完成物理内存${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB",
            "加载完成物理内存${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB");
      }
      //播放视频--静音播放
      // await mywebViewController.runJavaScript("""
      //           var videos = document.querySelectorAll('video');
      //           videos.forEach((video) => {
      //             video.muted = true;
      //             video.play().catch(e => console.log(e));
      //           });
      //         """);
    });
    navDelegate.setOnWebResourceError((error) async {
      debugPrint('Android WebView出错: ${error.description}');
      if('$playyes'=='0'){
        mywebViewController?.loadHtmlString(
            '<div style="position:absolute;top:0;left:0;width:100%;height:100%;background-color:#181B2A;"></div>'
        );
        //背景
        playyes=2;//加载了没有加载的图
        //加载节目时的背景图
        ByteData bytesA = await rootBundle.load('images/backImg.png');
        var bufferA = bytesA.buffer;
        var backImgA = base64.encode(Uint8List.view(bufferA));

        var nowbgpath = await StorageUtil.getStringItem('bgImg');//整个APP的背景图的地址
        if(nowbgpath!=null&&nowbgpath!='null'&&nowbgpath!=''){
          File filebgimg = File(nowbgpath);
          //读缓存里的背景图的地址
          bool imageExists = filebgimg.existsSync();
          if (imageExists) {
            print('缓存里的图片存在');
            Uint8List imageBytes = await filebgimg.readAsBytes();
            backImgA = base64.encode(imageBytes);
          } else {
            print('缓存里图片不存在，继续使用代码里的图片');
          }
        }

        //动图
        ByteData bytesB = await rootBundle.load('images/hoticon.gif');
        var bufferB = bytesB.buffer;
        var backImgB = base64.encode(Uint8List.view(bufferB));

        if(error.url!.indexOf('.html')>=0){
          mywebViewController?.loadHtmlString(
              '<img style="position: absolute;left:0;top:0;width:100%;height:100%;" src="data:image/png;base64,$backImgA"><div style="position: absolute;left:0;top:0;width:100%;height:100%;background-color:rgba(24,27,42,0.8);"></div><img style="position: absolute;left:50%;top:43%;width:160px;height:160px;margin-left:-80px;margin-top:-80px;" src="data:image/gif;base64,$backImgB"><div style="position: absolute;left:0%;top:43%;width:100%;height:50px;line-height:50px;margin-top:80px;font-size:24px;color:#ffffff;text-align:center;">加载中，请稍后</div>'
          );
        }
      }
    });

    // 2. 创建 AndroidWebViewController 并绑定 navDelegate
    mywebViewController = AndroidWebViewController(params)
      ..setPlatformNavigationDelegate(navDelegate)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setMediaPlaybackRequiresUserGesture(false)
      ..setAllowFileAccess(true)
      ..loadRequest(
        LoadRequestParams(uri: Uri.parse(mywebUrl)),
      );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWebViewWidget(
      PlatformWebViewWidgetCreationParams(controller: mywebViewController),
    ).build(context);
  }
}
