// import 'package:flutter/cupertino.dart';
// import 'package:mqtt_client/mqtt_client.dart';
// import 'state/MQTTAppState.dart';
// import 'dart:convert';
// import 'dart:async';
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import '../Model.dart';
// import '../HttpHelper.dart';
// import 'package:flutter/services.dart';
// // import 'package:get_ip/get_ip.dart';
// import '../shareLocal.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// // import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:volume/volume.dart';
// import 'package:disk_space/disk_space.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// //截取屏幕
// import 'package:screenshot/screenshot.dart';
// import 'package:just_audio/just_audio.dart';
// //发送系统通知
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// var connectNum = 1;
// var mytimer;
// var mymusictimer;//每分钟循环一次播放无声音乐
//
// String proIdOfdownload = '0';//要下载的节目的ID
// String playproId = '0';//当前播放的节目的ID
// String playscheduleproId = '0';//当前播放的节目的任务ID
// String playType = '0';//节目的类型（0展示空白内容，1下载节目，2播放节目，3下载并加载节目）
// String locaPath = "";
//
//
// //连接MQTT
// //调节音量的设置（媒体音量）
// AudioManager audioManager = AudioManager.STREAM_MUSIC;
// void configureindexConnect() async {
//   //音量调节种类设置
//   Volume.controlVolume(audioManager);
//   var posalUrlMqtt = await StorageUtil.getStringItem('posalUrl');
//   var clientIdT = await StorageUtil.getStringItem('deviceID');
//   if (posalUrlMqtt == null||posalUrlMqtt=='null') {
//     Fluttertoast.showToast(msg: "服务器地址和端口号不能为空，请填写设置项");
//   }else{
//     configureAndConnect(posalUrlMqtt,8081,clientIdT);//连接MQTT
//
//   }
// }
//
// //截取屏幕
// ScreenshotController screenshotController = ScreenshotController();
//
// MQTTAppState currentAppState;
// MQTTManager manager;
// void configureAndConnect(urlMqtt,portMqtt,clientIdT) {
//   // TODO: Use UUID
//   String osPrefix = 'Flutter${DateTime.now().millisecondsSinceEpoch}';//默认就是安卓
//   manager = MQTTManager(
//       host: urlMqtt,
//       port: portMqtt,
//       topic: '/InfoPublish_DownTopic/$clientIdT',
//       identifier: osPrefix,
//       state: currentAppState
//   );
//
//   manager.initializeMQTTClient();
//   manager.connect();
// }
// void publishMessage(String text) {
//   String osPrefix = 'Flutter_Android';
//   // final String message = osPrefix + ' says: ' + text;
//   print("1111111111111111111111111111111111111111");
//   manager.publish(text);
// }
// class MQTTManager{
//   // Private instance of client
//   final MQTTAppState _currentState;
//   MqttClient _client;
//   final String _identifier;
//   final String _host;
//   final int _port;
//   final String _topic;
//
//   // Constructor
//   MQTTManager({
//    @required String host,
//    @required int port,
//     @required String topic,
//     @required String identifier,
//     @required MQTTAppState state
//   }): _identifier = identifier, _host = host, _port = port, _topic = topic, _currentState = state ;
//
//   void initializeMQTTClient(){
//     _client = MqttClient(_host,_identifier);
// //    _client = MqttClient('test.mosquitto.org',_identifier);
// //    _client.port = 1883;
//     _client.port = _port;
//     _client.keepAlivePeriod = 20;
//     _client.onDisconnected = onDisconnected;
//     _client.secure = false;
//     _client.logging(on: true);
//
//     /// Add the successful connection callback
//     _client.onConnected = onConnected;
//     _client.onSubscribed = onSubscribed;
//
//     final MqttConnectMessage connMess = MqttConnectMessage()
//         .withClientIdentifier(_identifier)
//         .withWillTopic('willtopic') // If you set this you must set a will message
//         .withWillMessage('My Will message')
//         .startClean() // Non persistent session for testing
//         .withWillQos(MqttQos.atMostOnce);
//     print('EXAMPLE::Mosquitto client connecting....');
//     _client.connectionMessage = connMess;
//
//   }
//   // Connect to the host
//   void connect() async{
//     assert(_client != null);
//     try {
//       print('EXAMPLE::Mosquitto start client connecting....');
//       await _client.connect();
//       print('成功');
//       Fluttertoast.showToast(msg: "MQTT连接成功");
//       deviceLogAdd('1', 'MQTT连接成功', 'MQTT连接成功');
//       //连接成功后每10秒发送一次心跳
//       if(mytimer!=null){
//         mytimer.cancel();
//       }
//       startTimer();
//       var urlPlaylist = 'http://$posalUrl:$posalport';
//       //走接口获取当前播放节目
//       if(urlPlaylist!='http://'){
//         Future.delayed(Duration(seconds: 3), (){
//           searchlistplayNow(urlPlaylist,"0");
//           //走http 接口更新会议数据
//           getIframeConnect();
//         });
//       }
//     } on Exception catch (e) {
//       print('EXAMPLE::client exception - $e');
//       deviceLogAdd(-1,"$e",'MQTT连接不成功');
//       disconnect();
//     }
//   }
//   void startTimer() {
//     const period = const Duration(seconds: 10);
//     //print('startTimer='+DateTime.now().toString());
//     mytimer = Timer.periodic(period, (timer) {
//       //到时回调
//       send();
//     });
//   }
//   //发送心跳
//   send() async{
//     print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
//     // String ipsocket = await GetIp.ipAddress;
//     String ipsocket = "";
//     for (var interface in await NetworkInterface.list()) {
//       for (var addr in interface.addresses) {
//         ipsocket = '${addr.address}';
//         print('${addr.address}');
//       }
//     }
//     StorageUtil.setStringItem('ipAddress',ipsocket);//设备Ip
//     deviceID = await StorageUtil.getStringItem('deviceID');
//     var sysvolume = await Volume.getVol;
//     var sysZhengVideo = (sysvolume*6.66).round();
//     if(numcompare!=-1){
//       if(sysvolume!=numcompare){
//         Volume.setVol(numcompare, showVolumeUI: ShowVolumeUI.SHOW);
//         deviceLogAdd(4,"当前音量不一致，设备当前音量：$sysvolume，收到命令音量：*$numcompare","以收到命令为准");
//       }
//     }
//
//     var diskTotal = await DiskSpace.getTotalDiskSpace;//当前总的存储空间
//     var diskFree = await DiskSpace.getFreeDiskSpace;//当前剩余的存储空间
//     double diskPre = 1-(diskFree/diskTotal);//剩余空间占总容量的百分比
//     var diskPreDou = (diskPre*100).toStringAsFixed(0);
//     //看是否有deviceID
//     StorageUtil.getStringItem('deviceID').then((datares) {
//       //发送过心跳
//       if(datares != null){
//         // print('发送注册完心跳');
//         print(sysZhengVideo);
//         var dataJson = {
//           "Memory":"12",
//           "Disk":"$diskPreDou",
//           "SysVolunme":sysZhengVideo,
//         };
//         //var sendData=jsonEncode({
//         //  "ClientId":datares,
//          // "DataType":1,
//         //  "DataJson":dataJson
//        // });
//         var sendData={
//           "ClientId":datares,
//           "DataType":1,
//           "DataJson":dataJson
//         };
//
//         print(sendData);
//         String message = encodeBase64(json.encode(sendData));
//         publishMessage(message);
//       }else{
// //        print('发送注册心跳');
//         var deviceIDs = DeviceInfo['DeviceId'];
//         var deviceName =  DeviceInfo['DeviceName'];
//         var deviceVersion = DeviceInfo['DeviceVersion'];
//         var systemVersion = DeviceInfo['SystemVersion'];
//         Map register = (
//             {
//               "DeviceId":"",
//               "DeviceName":deviceName,
//               "IPAddress":ipsocket,
//               "MACAddress":deviceIDs,
//               "MachineCode":deviceIDs,
//               "SystemVersion":systemVersion,
//               "DeviceType":"2",
//               "DeviceVersion":deviceVersion,
//               "Memory":0,
//               "DiskFreeSize":0,
//               "Location":"",
//               "Width":0,
//               "Height":0,
//               "AuthorizationCode":devicecode,
//               "EncryptedSignatureData":"",
//               "TcpClientID":"",
//               "CurrentStickTime": DateTime.now().millisecondsSinceEpoch
//             }
//         );
//         //String sendData=jsonEncode({
//           //"ClientId":"",
//           //"DataType":0,
//          // "DataJson":register
//         //});
//         Map sendData={
//           "ClientId":"",
//           "DataType":0,
//           "DataJson":register
//         };
//
//         String message = encodeBase64(json.encode(sendData));
//         publishMessage(message);
//
//         print(sendData);
//       }
//
//     });
//
//   }
//
//   void disconnect() {
//     print('Disconnected');
//     _client.disconnect();
//   }
//
//   void publish(String message){
//     final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
//     builder.addString(message);
//     _client.publishMessage("InfoPublishMqtt_CallBack", MqttQos.atMostOnce, builder.payload);
//   }
//
//   /// 订阅的回调
//   void onSubscribed(String topic) {
//     print('onSubscribed');
//   }
//
//   /// 主动断开连接回调
//   void onDisconnected() {
// //    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
//     print('连接断开');
//     Fluttertoast.showToast(msg: "MQTT连接断开，10S后进行重连");
//     deviceLogAdd(19,"MQTT连接断开，10S后进行重连","MQTT连接断开，10S后进行重连");
//     Future.delayed(Duration(seconds: 10), (){
//       print('重新连接');
//       manager.connect();
//     });
//     if (_client.connectionStatus.returnCode == MqttConnectReturnCode.solicited) {
//       print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
//     }
//   }
//
//   /// 成功的连接回调
//   void onConnected() {
// //    _currentState.setAppConnectionState(MQTTAppConnectionState.connected);
//     print('EXAMPLE::Mosquitto client connected.....');
//     _client.subscribe(_topic, MqttQos.atMostOnce);
//     _client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
//       //接收到的消息
//       final MqttPublishMessage recMess = c[0].payload;
//       final String pt =MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
//       var message = decodeBase64(pt);
//       // print(message);
//       // print('EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
//       Map res = json.decode(message);
//       if('${res['DataType']}'=='19'){
//         deviceLogAdd(19,message,"接收到拉取数据的命令！$deviceID");
//         getIframeConnect();//拉取数据
//       }
//       else if('${res['DataType']}'=='10'){
//         deviceLogAdd(10,message,"接收到下载的命令！$deviceID");
//         print('下载并解压缩节目');
//         //根据projectId去下载节目的压缩包
//         var datajson = json.decode(res['DataJson']);
//         var ProgramId = datajson['ProgramId'];
//         var ScheduleId = datajson['ScheduleId'];
//         var TYPE = datajson['TYPE'];//节目的类型（如果是紧急插播则立即播放）1 普通节目 2 插播节目 3 插播字幕 4系统开屏 5 系统关屏
//         if(TYPE==2){
//           // playscheduleproId = ScheduleId;
//           // steamProplayChange(ProgramId);//下载播放
//           //因为紧急插播节目还会发一遍20的命令，所以不动作
//         }else{
//           steamProplay(ProgramId);
//         }
//
//       }
//       else if('${res['DataType']}'=='20'){
//
//         var datajson = json.decode(res['DataJson']);
//         var ProgramId = datajson['ProgramId'];
//         var PlayTypeme = datajson['PlayType'];//1是播放，0是停止
//         var ScheduleId = datajson['ScheduleId'];
//         if(PlayTypeme==1){
//           deviceLogAdd(20,message,"接收到播放任务--开始！任务id：$ScheduleId节目id:$ProgramId");
//           //播放
//           var TYPE = datajson['TYPE'];//节目的类型（如果是紧急插播则立即播放）1 普通节目 2 插播节目 3 插播字幕 4系统开屏 5 系统关屏
//           if(TYPE!=2){
//           }
//           Future.delayed(Duration(seconds: 3), (){
//             playscheduleproId = ScheduleId;
//             steamProplayChange(ProgramId,playscheduleproId);
//           });
//         }
//         else{
//           //停止播放（查看当前播放的是哪一个节目，如果是一样的节目就停止播放，如果是不一样的就不管）
//
//           deviceLogAdd(20,message,"接到停止播放的命令--停止！任务id：$ScheduleId节目id:$ProgramId");
//           // print('当前节目：$playproId**停止播放节目$ProgramId');
//           // print('当前任务：$ScheduleId**停止播放任务$playscheduleproId');
//           if(ScheduleId==playscheduleproId){
//             steamstoppro('0');
//             Future.delayed(Duration(seconds: 3), (){
//               var url = 'http://$posalUrl:$posalport';
//               searchlistplayNow(url,ScheduleId);
//             });
//           }
//         }
//       }
//       else if('${res['DataType']}'=='14'){
//         print('停止播放节目');
//         deviceLogAdd(14,message,"接收到删除节目安排的命令！$deviceID");
//         var datajson = json.decode(res['DataJson']);
//         var ProgramId = datajson['ProgramId'];
//         var ScheduleId = datajson['ScheduleId'];
//         //停止播放（查看当前播放的是哪一个节目，如果是一样的节目就停止播放，如果是不一样的就不管）
//         print('当前节目：$playproId**停止播放节目$ProgramId');
//         print('当前任务：$ScheduleId**停止播放任务$playscheduleproId');
//         if(ScheduleId==playscheduleproId){
//           steamstoppro('0');
//           Future.delayed(Duration(seconds: 3), (){
//             var url = 'http://$posalUrl:$posalport';
//             searchlistplayNow(url,ScheduleId);
//           });
//
//         }
//       }
//       else if('${res['DataType']}'=='3'){
//         print('截取屏幕');
//         deviceLogAdd(3,message,"接收截取屏幕的命令！$deviceID");
//         screenshotController
//             .capture(path:'',delay: Duration(milliseconds: 10))
//             .then((File image) async {
//           var byteImg = await image.readAsBytesSync();
//           var testimg= base64Encode(byteImg);
//           // String baseingtrstr = byteImg.toString();
//           // var baseData = encodeBase64(baseingtrstr);
//           var sendData={
//             "ClientId":deviceID,
//             "DataType":3,
//             "DataJson":testimg
//           };
//           String message = encodeBase64(json.encode(sendData));
//           publishMessage(message);
//         }).catchError((onError) {
//           deviceLogAdd(3,"截取屏幕时报错！$deviceID","截取屏幕时报错！$deviceID");
//           print(onError);
//         });
//       }
//       else if('${res['DataType']}'=='4'){
//         print('音量调节');
//         var datajson = res['DataJson'];
//         var voNum = int.parse(datajson);
//         var voshowNum = (voNum/6.66).round();
//         numcompare = voshowNum;
//         StorageUtil.setStringItem('numcompare','$numcompare');//Token的值
//         print('$voshowNum');
//         deviceLogAdd(4,message,"接收音量调节的命令！$deviceID");
//         Volume.setVol(voshowNum, showVolumeUI: ShowVolumeUI.SHOW);
//       }
//       else if('${res['DataType']}'=='5'){
//         numcompare = 0;
//         StorageUtil.setStringItem('numcompare','$numcompare');//Token的值
//         deviceLogAdd(5,message,"接收静音的命令！$deviceID");
//         print('静音');
//         Volume.setVol(0, showVolumeUI: ShowVolumeUI.SHOW);
//       }
//       else if('${res['DataType']}'=='21'){
//         //接收到删除某一个节目或者所有的节目的命令
//         deviceLogAdd(5,message,"接收到删除所有节目的命令！");
//         //假设传过来的节目ID是6bbbb754-3d3a-4a24-bae7-f68d04c2463e
//         var proCid = '6bbbb754-3d3a-4a24-bae7-f68d04c2463e';
//         delectProFile(proCid);//删除当前节目
//       }
//       else if('${res['DataType']}'=='22'){
//         //接收到是否加载节目的命令
//         if('${res['DataJson']}'=='1'){
//           //加载带有节目的样式
//           changetemp("1");
//         }else if('${res['DataJson']}'=='0'){
//           //加载不带有节目的样式
//           changetemp("0");
//         }
//
//       }else if('${res['DataType']}'=='12'){
//         //开屏
//         print('----------开屏-------------');
//         deviceLogAdd(12,message,"接收开屏的命令！$deviceID");
//         showOpenNotification();//开屏
//       }else if('${res['DataType']}'=='13'){
//         //关屏
//         print('----------关屏-------------');
//         deviceLogAdd(13,message,"接收关屏的命令！$deviceID");
//         showCloseNotification();//关屏
//       }
//
//
//     });
//     print('EXAMPLE::OnConnected client callback - Client connection was sucessful');
//   }
//
// }
// String decodeBase64(String data){
// //  return String.fromCharCodes(base64Decode(data));
//   return Utf8Decoder().convert(base64Decode(data));
// }
//
// // InAppWebViewController mywebViewController;
// WebViewController mywebViewController;
// String mywebUrl = '';
//
// String mylocaPath = "";
//
//
// void steamProplay(val) async{
//   print('下载并解压缩节目');
//   deviceLogAdd(10,"接收到下载节目的命令！$deviceID","接收到下载节目的命令！$deviceID");
//   if(isKeptOn==true){
//     //开着屏（屏幕常亮已关闭）
//     proIdOfdownload="$val";
//     playType = '1';
//     streamDemo.add(playType);
//     //走判断当前存储空间的方法小于总容量的百分之5或者内存小于500M的时候添加报警日志
//     initPlatformState();
//   }else{
//
//   }
// }
//
// void steamProplayChange(val,playschId) async{
//   deviceLogAdd(10,"收到10紧急插播或者是20播放的命令或者是一进页面自动获取当前该播放的节目的播放！$deviceID","加载文件并播放$deviceID");
//   if(isKeptOn==true){
//     //开着屏（屏幕常亮已关闭）
//     print('更改播放的节目');//检查文件夹有没有被下载，没有被下载的话下载并播放，如果下载过了直接播放
//     proIdOfdownload="$val";
//     playproId="$val";
//     playType = '3';
//     mylocaPath = await findLocalPath();
//     var yuanlaiwebUrl = mywebUrl;
//     var webUrlnow = 'file://$mylocaPath/$playproId/${playproId}.html';
//     if(webUrlnow!=yuanlaiwebUrl){
//       streamDemo.add(playproId);
//     }
//     //走判断当前存储空间的方法小于总容量的百分之5或者内存小于500M的时候添加报警日志
//     initPlatformState();
//   }else{
//
//   }
// }
//
//
// void steamProplayplay(val) async{
//   if(isKeptOn==true){
//     //开着屏（屏幕常亮已关闭）
//     print('播放的节目');
//     deviceLogAdd(10,"播放下载完成并且解压好的节目！$playproId","播放下载完成并且解压好的节目！$playproId");
//     playproId="$val";
//     playType = '2';
//     mylocaPath = await findLocalPath();
//     mywebUrl = 'file://$mylocaPath/$playproId/${playproId}.html';
//     if(mywebViewController!=null){
//       mywebViewController.loadUrl(mywebUrl);
//       // mywebViewController.loadUrl(urlRequest: URLRequest(url: Uri.parse(mywebUrl)));
//     }
//     streamDemo.add(playType);
//   }else{
//
//   }
// }
// void steamstoppro(val) async{
//   print('展示空白节目');
//   deviceLogAdd(0,"停止播放当前节目","停止播放当前节目");
//   playproId="0";
//   playscheduleproId = '0';
//   playType = '0';
//   mylocaPath = await findLocalPath();
//   mywebUrl = 'file://$mylocaPath/$playproId/${playproId}.html';
//   streamDemo.add(playproId);
// }
//
// //走接口获取任务列表，寻找当前时间在大于开始时间小于结束时间的list,然后选择开始时间最晚的那一个节目
// void searchlistplayNow(url,ScheduleId) async{
//   deviceID = await StorageUtil.getStringItem('deviceID');
//   if(deviceID!='null'){
//     deviceLogAdd(10,"获取当前设备所有的节目！$deviceID","获取当前设备所有的节目！$deviceID");
//     var deviceMess ={
//       'DeviceId':deviceID,
//     };
//     HttpDioHelper helper = HttpDioHelper();
//     helper.httpDioGet(url, "/RegisterPlayer/DeviceLoadProgramQuartz",body:deviceMess).then((datares) {
//       if(datares.statusCode==200){
//         var res = json.decode(datares.data);
//         var playlist = res['data'];
//         print("________________________________");
//         print("$res");
//         var diffcomOnece = 0;
//         var diffcom = 0;
//         var palyID='0';
//         var playsch = '0';
//         if(playlist.length==0){
//           steamstoppro('0');//停止播放节目
//           deviceLogAdd(0,"获取播放的节目列表数据为空停止播放节目",'获取播放的节目列表数据为空停止播放节目');
//         }
//         for(var item in playlist){
//           var PlayTime = item['PlayTime'];
//           var StopTime = item['StopTime'];
//           DateTime nowMeet = DateTime.now();//当前时间
//           //开始时间小于当前时间
//           if(CompareTime(nowMeet,PlayTime)) {
//             //结束时间大于当前时间
//             if (CompareTime(StopTime, PlayTime)) {
//               var stsTimeP = DateTime.parse(PlayTime);//开始时间
//               var endsTimeP = DateTime.parse(StopTime);//结束时间
//               var difference = nowMeet.difference(stsTimeP);//开始时间与当前时间的时间差，时间差越小越要播放
//               var diffSecond = difference.inMilliseconds;
//               print('$diffSecond');
//               //当是初始值的时候先默认放置循环里的第一个值
//               if(diffcomOnece==0){
//                 if(ScheduleId!=item['ScheduleId']){
//                   diffcom =diffSecond;
//                   palyID = item['ProgramId'];
//                   playsch = item['ScheduleId'];
//                   diffcomOnece = 1;
//                 }
//
//               }else if(diffSecond<=diffcom){
//                 if(ScheduleId!=item['ScheduleId']){
//                   diffcom =diffSecond;
//                   palyID = item['ProgramId'];
//                   playsch = item['ScheduleId'];
//                 }
//               }
//
//             }
//           }
//         }
//         if(palyID!='0'){
//           //播放当前节目
//           playscheduleproId = playsch;
//           steamProplayChange(palyID,playscheduleproId);
//         }
//       }
//
//     }).catchError(
//             (e){
//           if(e is DioError)
//           {
//             deviceLogAdd(14,"获取节目播放列表",'获取节目播放列表:${e.error}');
//           }
//           else
//           {
//             deviceLogAdd(14,"获取节目播放列表",'获取节目播放列表');
//           }
//         }
//     ).whenComplete(() => deviceLogAdd(14, '获取节目播放列表流程结束', '获取节目播放列表流程结束'));
//
//   }
//
//
//
// }
// //比较两个日期的大小第一个值比第二个值大返回true，否则返回false
// bool CompareTime(one, two) {
//   DateTime d1 = null;
//   DateTime d2 = null;
//   if (one.runtimeType == String) {
//     d1 = DateTime.parse(one);
//   } else if (one.runtimeType == DateTime) {
//     d1 = one;
//   }
//   if (two.runtimeType == String) {
//     d2 = DateTime.parse(two);
//   }else if (two.runtimeType==DateTime)
//   {d2=two;}
//   return d2.isBefore(d1);
// }
//
// //删除节目文件夹
// Future<void> delectProFile(String ProId) {
//   deviceLogAdd(00,"删除所有节目文件夹开始","删除所有节目文件夹开始");
//   String path = '$mylocaPath';
//   Directory directory = new Directory(path);
//   if (directory.existsSync()) {
//     // listdelect(directory);
//     List<FileSystemEntity> filesone = directory.listSync();
//     if('$directory'.indexOf('$playproId')>=0&&'$playproId'!='0'){
//     }else{
//       if (filesone.length > 0) {
//         filesone.forEach((filesItem) {
//           if(FileSystemEntity.isFileSync(filesItem.absolute.path)){
//             filesItem.deleteSync();
//           }else{
//             Directory directorytwo = new Directory(filesItem.absolute.path);
//             List<FileSystemEntity> filesTwo = directorytwo.listSync();
//             if('$directorytwo'.indexOf('$playproId')>=0&&'$playproId'!='0'){
//             }else{
//               if (filesTwo.length > 0) {
//                 filesTwo.forEach((filesTwoItem) {
//                   if(FileSystemEntity.isFileSync(filesTwoItem.absolute.path)){
//                     filesTwoItem.deleteSync();
//                   }else{
//                     Directory directorythree = new Directory(filesTwoItem.absolute.path);
//                     List<FileSystemEntity> filesThree = directorythree.listSync();
//                     if('$directorythree'.indexOf('$playproId')>=0&&'$playproId'!='0'){
//                     }else{
//                       if(filesThree.length>0){
//                         filesThree.forEach((filesThreeItem) {
//                           if(FileSystemEntity.isFileSync(filesThreeItem.absolute.path)){
//                             filesThreeItem.deleteSync();
//                           }else{
//                             Directory directoryfour = new Directory(filesThreeItem.absolute.path);
//                             List<FileSystemEntity> filesfour = directoryfour.listSync();
//                             if(filesfour.length>0){
//                               filesfour.forEach((filesfourItem) {
//                                 if(FileSystemEntity.isFileSync(filesfourItem.absolute.path)){
//                                   filesfourItem.deleteSync();
//                                 }else{
//                                   Directory directoryfive = new Directory(filesfourItem.absolute.path);
//                                   List<FileSystemEntity> filesfive = directoryfive.listSync();
//                                   if(filesfive.length>0){
//                                     filesfive.forEach((filesfiveItem) {
//                                       if(FileSystemEntity.isFileSync(filesfiveItem.absolute.path)){
//                                         filesfiveItem.deleteSync();
//                                       }else{
//                                         Directory directorysix = new Directory(filesfiveItem.absolute.path);
//                                         List<FileSystemEntity> filessix = directorysix.listSync();
//                                         if(filessix.length>0){
//                                           filessix.forEach((filessixItem) {
//                                             if(FileSystemEntity.isFileSync(filessixItem.absolute.path)){
//                                               filessixItem.deleteSync();
//                                             }else{
//                                               Directory directoryseven = new Directory(filessixItem.absolute.path);
//                                               List<FileSystemEntity> filesseven = directoryseven.listSync();
//                                               if(filesseven.length>0){
//                                                 filesseven.forEach((filessevenItem) {
//                                                   if(FileSystemEntity.isFileSync(filessevenItem.absolute.path)){
//                                                     filessevenItem.deleteSync();
//                                                   }else{
//
//                                                   }
//                                                 });
//                                               }
//                                               directoryseven.deleteSync();
//                                             }
//                                           });
//                                         }
//                                         directorysix.deleteSync();
//                                       }
//                                     });
//                                   }
//                                   directoryfive.deleteSync();
//                                 }
//                               });
//                             }
//                             directoryfour.deleteSync();
//                           }
//                         });
//                       }
//                       directorythree.deleteSync();
//                     }
//                   }
//                 });
//               }
//               directorytwo.deleteSync();
//             }
//           }
//         });
//       }
//       // directory.deleteSync();
//       deviceLogAdd(00,"删除所有节目文件夹完成","删除所有节目文件夹完成");
//     }
//   }
// }
// // 走判断当前存储空间的方法小于总容量的百分之5或者内存小于500M的时候添加报警日志
// Future<void> initPlatformState() async {
//   double platformTotal;
//   double platformFree;
//   try {
//     platformTotal = await DiskSpace.getTotalDiskSpace;//当前总的存储空间
//     platformFree = await DiskSpace.getFreeDiskSpace;//当前剩余的存储空间
//     if(platformFree<500){
//       deviceLogAdd(0,"存储空间小于500M","存储空间小于500M");
//     }
//     double scale = platformFree/platformTotal;//剩余空间占总容量的百分比
//     if(scale<0.05){
//       deviceLogAdd(0,"存储空间小于总容量的百分之五","存储空间小于总容量的百分之五");
//     }
//   } on PlatformException {
//     platformFree = 0;
//   }
// }
//
// // 获取存储路径
// Future<String> findLocalPath() async {
//   // 因为Apple没有外置存储，所以第一步我们需要先对所在平台进行判断
//   // 如果是android，使用getExternalStorageDirectory getTemporaryDirectory
//   // 如果是iOS，使用getApplicationSupportDirectory
//   // androidPath 用于存储安卓段的路径
//   String androidPath = "";
//   await getExternalStorageDirectory().then((f){
//     print(f.path);
//     androidPath = f.path + "/download";
//   });
//
//   //判断androidPath是否为空 为空返回ios的路径 否则 返回android的路径
//   if(androidPath!=""){
//     final savedDir = Directory(androidPath);
//     // 判断下载路径是否存在
//     bool hasExisted = await savedDir.exists();
//     // 不存在就新建路径
//     if (!hasExisted) {
//       savedDir.create();
//     }
//     return androidPath;
//   }
// }
//
// //比较两个日期的大小第一个值比第二个值大返回true，否则返回false
// bool CompareDate(one, two) {
//   DateTime d1 = null;
//   DateTime d2 = null;
//   if (one.runtimeType == String) {
//     d1 = DateTime.parse(one);
//   } else if (one.runtimeType == DateTime) {
//     d1 = one;
//   }
//   if (two.runtimeType == String) {
//     d2 = DateTime.parse(two);
//   }else if (two.runtimeType==DateTime)
//   {d2=two;}
//   return d2.isBefore(d1);
// }
//
// //base64加密
// String encodeBase64(String data){
//   var content = utf8.encode(data);
//   var digest = base64Encode(content);
//   return digest;
// }
//
// final player = AudioPlayer();//定义一个全局的音频
// //亮屏
// showOpenNotification() async {
//   var android = new AndroidNotificationDetails(
//       'channel id', 'channel NAME','channelDescription',
//       priority: Priority.high,importance: Importance.max
//   );
//   var platform = new NotificationDetails(android:android);
//   var timenow = new DateTime.now();
//   //第一个参数id，第二个参数标题，第三个参数内容
//   await flutterLocalNotificationsPlugin.show(
//       1, '标题', '内容：亮屏$timenow', platform,
//       payload: '无关紧要暂时不关心这个参数');
//   if(isKeptOn!=true){
//     isKeptOn = true;//屏幕是否打开
//     StorageUtil.setStringItem('lockstate','$isKeptOn');//开关屏的值
//     deviceLogAdd(1213,"监听到已开开开屏","监听到已开开开屏！$deviceID");
//     var url = 'http://$posalUrl:$posalport';
//     searchlistplayNow(url,0);//亮屏后走接口获取当前节目
//   }
//   //音乐的循环清空
//   if(mymusictimer!=null){
//     mymusictimer.cancel();
//   }
//   player.stop();//亮屏后停止音乐的播放
// }
// //灭屏
// showCloseNotification() async {
//   var android = new AndroidNotificationDetails(
//       'channel id', 'channel NAME','channelDescription',
//       priority: Priority.high,importance: Importance.max
//   );
//   var platform = new NotificationDetails(android:android);
//   var timenow = new DateTime.now();
//   //第一个参数id，第二个参数标题，第三个参数内容
//   await flutterLocalNotificationsPlugin.show(
//       2, '标题', '内容：灭屏$timenow', platform,
//       payload: '无关紧要暂时不关心这个参数');
//   if(isKeptOn!=false){
//     isKeptOn = false;//屏幕是否打开
//     StorageUtil.setStringItem('lockstate','$isKeptOn');//开关屏的值
//     steamstoppro('0');//暂时停止节目的播放
//     deviceLogAdd(1213,"监听到已关关关屏","监听到已关关关屏！$deviceID");
//   }
//   //灭屏后播放循环无声音乐
//   //研究重新播放----需要循环播放，播放节目有的视频音频，会停止播放------每隔多长时间循环一次重新播放
//   player.setAsset(
//       'files/nothing.mp3');
//   player.play();
//   if(mymusictimer!=null){
//     mymusictimer.cancel();
//   }
//   mymusicTimer();//音乐的循环赋值
// }
// //屏幕是否是亮着的值的改变---（手动改变，以及命令改变，监听到屏幕亮灭的变化就会触发这个方法）
// void keepscreenLight(staval) async{
//   if(staval==1){
//     if(isKeptOn!=true){
//       isKeptOn = true;//屏幕是否打开
//       StorageUtil.setStringItem('lockstate','$isKeptOn');//开关屏的值
//       var url = 'http://$posalUrl:$posalport';
//       searchlistplayNow(url,0);//亮屏后走接口获取当前节目
//       deviceLogAdd(1213,"监听到已开开开屏","监听到已开开开屏！$deviceID");
//       //音乐的循环清空
//       if(mymusictimer!=null){
//         mymusictimer.cancel();
//       }
//       player.stop();//亮屏后停止音乐的播放
//     }
//
//   }else{
//     if(isKeptOn!=false){
//       isKeptOn = false;//屏幕是否打开
//       StorageUtil.setStringItem('lockstate','$isKeptOn');//开关屏的值
//       steamstoppro('0');//暂时停止节目的播放
//       deviceLogAdd(1213,"监听到已关关关屏","监听到已关关关屏！$deviceID");
//       //灭屏后播放循环无声音乐
//       //研究重新播放----需要循环播放，播放节目有的视频音频，会停止播放------每隔多长时间循环一次重新播放
//       player.setAsset(
//           'files/nothing.mp3');
//       player.play();
//       if(mymusictimer!=null){
//         mymusictimer.cancel();
//       }
//       mymusicTimer();//音乐的循环赋值
//     }
//   }
// }
// //每分钟循环如果是关屏状态，则播放无声音乐（为了保活）
// void mymusicTimer() {
//   const period = const Duration(seconds: 60);
//   mymusictimer = Timer.periodic(period, (timer) {
//     //到时回调
//     if(isKeptOn==false){
//       //屏幕是关闭状态
//       player.setAsset(
//           'files/nothing.mp3');
//       player.play();
//     }else{
//       //屏幕是开启状态--关闭无声音乐
//       player.stop();
//     }
//   });
// }
