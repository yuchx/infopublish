import 'dart:typed_data';

import 'package:disk_space_update/disk_space_update.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
// import 'package:volume_controller/volume_controller.dart';
import '../demo/chanOfYisheng.dart';
import 'passmdtext.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:ntp/ntp.dart';
import 'package:system_info2/system_info2.dart';
import '../custom_channel.dart';
import '../demo/downbgImg.dart';
import '../demo/localfileUseSetting.dart';
import 'mattt_cert.dart';
import 'state/MQTTAppState.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Model.dart';
import '../HttpHelper.dart';
import 'package:flutter/services.dart';
// import 'package:get_ip/get_ip.dart';
import '../shareLocal.dart';
import 'package:webview_flutter/webview_flutter.dart';

// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
//截取屏幕
import 'package:screenshot/screenshot.dart';
// import 'package:just_audio/just_audio.dart';
//发送系统通知
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:crypto/crypto.dart';//md5
import 'mattt_cert.dart';
var connectNum = 1;
var mytimer;//MQTT发送心跳
var mymusictimer;//每分钟循环一次播放无声音乐（保活机制有的设备息屏以后不保活）
var myContimer;//对比版本配置项
var myplayschtimer;//每S更新最后播放时间
String proIdOfdownload = '0';//要下载的节目的ID
String playproId = '0';//当前播放的节目的ID
String playscheduleproId = '0';//当前播放的节目的任务ID
String playType = '0';//节目的类型（0展示空白内容，1下载节目，2播放节目，3下载并加载节目）
String locaPath = "";
int certificate = 1;//0无证书 1有证书
String playinsertId = '0';//当前播放字幕的ID
//插播的一系列信息--位置速度样式字体色号等
var insertmess = {
  "Message": "",//展示的内容
  "EndTime": "",//插播消息的结束时间
  "Speed": "",//速度
  "BackColor": "",//背景色
  "MessageColor": "",//字的颜色
  "FontName": "",//字体
  "FontSize": "",//字号
  "Dock": ""//滚动位置1上2下3左4右
};

//连接MQTT
//调节音量的设置（媒体音量）
// AudioManager audioManager = AudioManager.STREAM_MUSIC;
void configureindexConnect() async {
  //音量调节种类设置
  // Volume.controlVolume(audioManager);
  var posalUrl = await StorageUtil.getStringItem('posalUrl');
  var posalport = await StorageUtil.getStringItem('posalport');//服务器的端口号
  var clientIdT = await StorageUtil.getStringItem('deviceID');
  if (posalUrl == null||posalUrl=='null'||posalUrl=='') {
    Fluttertoast.showToast(msg: "服务器地址和端口号不能为空，请填写设置项");
  }else{
    //如果填了服务器地址和端口号，则走接口获取MQTT相关信息（有无证书以及MQTT地址） /InfoPublish/RegisterPlayer/GetDeviceByMachineCode?MachineCode=56a46bb93492104323&Key
    if(clientIdT==null||clientIdT=='null'||clientIdT==''){
      //没有设备ID说明没有授权，或者清了缓存
    }else{
      //有设备ID，说明已经授权，则走是否获取授权的接口去获取授权
    }
    if(myContimer!=null){
      myContimer.cancel();//清空定时器，之后重新定时
    }
    getConVsiAndMess(0);//第一次进入页面加载配置
    Future.delayed(Duration(seconds: 5), (){
      getconTimer();//定时去获取有没有授权以及授权返回的配置
    });
  }

  if(posalUrl==''||posalport==''||posalUrl == null||posalUrl=='null'||posalport==null||posalport=='null'){
    //服务器地址或服务器端口号为空--无颜色--把所有的灯都关上
    lightNoColor();//3个灯都不亮
  }else if(havesucccode==0){
    //有后台地址，但是授权没成功
    lightYellow();//未授权--变为黄色（红色+绿色）
  }
  // else if('${ajaxDataValue['RoomName']}'==''||'${ajaxDataValue['RoomName']}'=='null'){
    //写了后台地址授权成功了--没有配置会议室
    // lightBlue();//亮蓝色的灯
  // }
}
void getconTimer() {
  //300秒调一次，每5分钟去获取对比一次
  const period = const Duration(seconds: 300);
  myContimer = Timer.periodic(period, (timer) {
    //到时回调
    getconfigchange(1);//看看配置项有没有改变
  });
}
//每秒钟去更新正在播放的节目的最后播放时间
void getplayschTimer() {
  //1秒调一次
  const period = const Duration(seconds: 1);
  myplayschtimer = Timer.periodic(period, (timer){
    //到时回调
    chalastplaymess();
  });
}
//获取缓存里的当前正在播放的值，并看看计划当前是否正在播放，如果是则更新最后播放时间
chalastplaymess() async {
  String? playschmess = await StorageUtil.getStringItem('playschmess');
  if(playschmess!=null&&playschmess!='null'&&playschmess!=''){
    var messplay = json.decode(playschmess);
    if(playscheduleproId=='${messplay['scheduleID']}'){
      //当前播放的任务ID等于缓存里的任务ID
      //获取当前时间的时间戳
      int nowtimeA = gettimeNowNtp().millisecondsSinceEpoch;//当前时间的毫秒数
      print('$nowtimeA');
      var starttimelen = '${nowplayschMess['playStart']}';//开始的时间戳
      int timeaa = int.parse(starttimelen);
      var durtimenow = nowtimeA-timeaa;//时间差
      nowplayschMess['lastplaytime'] = '$nowtimeA';//结束时间赋值
      nowplayschMess['Durationtime'] = '$durtimenow';//持续时间赋值
      var playschmessStr = json.encode(nowplayschMess);
      StorageUtil.setStringItem('playschmess', playschmessStr);//存在缓存里
    }else{
      //当前正在播的任务ID不等于缓存里的任务ID
    }
  }else{
    //本地缓存里没有正在
  }

}

//定时获取版本信息有没有改变
void getconfigchange(type) async{
  var posalUrl = await StorageUtil.getStringItem('posalUrl');//服务器的IP
  var posalport = await StorageUtil.getStringItem('posalport');//服务器的端口号
  var devicecodeHC = await StorageUtil.getStringItem('devicecode');//存起来的授权码
  var MqttconfigKey = await StorageUtil.getStringItem('MqttconfigKey');//配置项的key值
  await getDeviceInfo();//获取设备信息
  var sendMachineCode = DeviceInfo['DeviceId'];
  var posalUrlGetToken = 'http://$posalUrl:$posalport';
  var bodySend = {
    'MachineCode': "$sendMachineCode",
    'key': "$KeySend",
  };
  HttpDioHelper helper = HttpDioHelper();
  //
  helper.httpDioGet(posalUrlGetToken, "/InfoPublish/RegisterPlayer/GetKeyByMachineCode",body:bodySend).then((datares) {
    if(datares.statusCode!=200){
      //服务器问题 接口断网或404 500 403等
      if(type==0){
        //从来没连接过
        deviceLogAdd(-1, 'GetKeyByMachineCode接口获取失败$sendMachineCode', 'GetKeyByMachineCode接口获取失败$sendMachineCode');
        if('${devicecodeHC}'=='null'){
          devicecodeHC="";
        }
        jiemisqcode(devicecodeHC).then((codeouttime) {
          print(codeouttime); //授权码的过期时间---现在的逻辑是以前的授权码全都废弃，用新的授权码
          int nowtimeAA = gettimeNowNtp().millisecondsSinceEpoch ~/1000; //当前时间的秒数
          if (codeouttime == "") {
            //没返回过期时间说明是旧的授权码（现已经废弃）
            if (havesucccode != 0) {
              havesucccode = 0;
              changAuthorize(havesucccode); //更改授权的展示
            }
          }
          else {
            print(nowtimeAA);
            int numcodeouttime = int.parse(codeouttime);
            if (numcodeouttime < nowtimeAA) {
              //过期时间小于当前时间说明已经过期
              if (havesucccode != 0) {
                havesucccode = 0;
                changAuthorize(havesucccode); //更改授权的展示
              }
            } else {
              //没有过期
              if (havesucccode != 1) {
                havesucccode = 1;
                changAuthorize(havesucccode); //更改授权的展示
              }
              getdevschList(posalUrlGetToken);//获取当前设备未结束的所有的任务--获取所有的cron
            }
          }
        });


      }
    }
    else{
      var resjson = (datares.data);//json数据
      Map datajaon = json.decode(resjson);
      if('${datajaon['code']}'=='200'){
        var messdatare = datajaon['data'];
        NtpServer = '${messdatare['NtpServer']}';//NTP服务器地址用于时间校对
        var devAuthorizationCode = '${messdatare['AuthorizationCode']}';//返回的获取的当前设备的授权码
        if(devAuthorizationCode=='null'){
          devAuthorizationCode='';
        }
        // var aaa = 'VThkKzc4ZG5WekcxUHJ5bWpwWDE0QT09';
        jiemisqcode(devAuthorizationCode).then((codeouttime) async {
          print(codeouttime);//授权码的过期时间---现在的逻辑是以前的授权码全都废弃，用新的授权码
          int nowtimeAA = gettimeNowNtp().millisecondsSinceEpoch ~/ 1000;//当前时间的毫秒数
          if(codeouttime==""){
            //没返回过期时间说明是旧的授权码（现已经废弃）
            if(havesucccode!=0){
              havesucccode = 0;
              changAuthorize(havesucccode);//更改授权的展示
            }
          }
          else{
            print(nowtimeAA);
            int numcodeouttime = int.parse(codeouttime);
            if(numcodeouttime<nowtimeAA){
              //过期时间小于当前时间说明已经过期
              if(havesucccode!=0){
                havesucccode = 0;
                changAuthorize(havesucccode);//更改授权的展示
              }
            }else{
              //没有过期
              if(havesucccode!=1){
                havesucccode = 1;
                changAuthorize(havesucccode);//更改授权的展示
              }
            }
          }

          StorageUtil.remove('devicecode');//设备的授权码的值
          StorageUtil.setStringItem('devicecode',devAuthorizationCode);//存储设备授权码
          devicecode = devAuthorizationCode;//设备的授权码
          if(havesucccode==0){
            DiscoveryDevice(posalUrlGetToken);//没获取到授权码或授权码过期需要上报
          }

          if(devicecodeHC!=devAuthorizationCode){
            //如果现在的授权码和之前的不一样了
            getConVsiAndMess(0);
          }else{
            //之前的授权码跟现在的一样
            //如果key的值跟本地不一致，重新校对时间  checkntpTime();//NTP校对时间
            var MqttKey = '${messdatare['MqttKey']}';//配置项的key的值
            StorageUtil.setStringItem('MqttconfigKey',MqttKey);//存储配置项的key值
            if(MqttconfigKey!=MqttKey){
              getConVsiAndMess(1);//如果获取的key和本地不一样，则重新拉取配置项
            }else if(mqoffstanum==2){
              //返回的相等,但是没有连过MQTT或者一开始没网，后来有网了
              var mqttUrlR =await StorageUtil.getStringItem('mqttUrl');//MQTT服务器
              var mqttPortR =await StorageUtil.getStringItem('mqttPort');//MQTT端口号
              var MqttUserR =await StorageUtil.getStringItem('MqttUser');//mqtt用户名
              var MqttPasswordR =await StorageUtil.getStringItem('MqttPassword');//mqtt密码
              var deviceID =await StorageUtil.getStringItem('deviceID');//设备ID
              mqttUrl = isNullKong(mqttUrlR);
              mqttPort = isNullKong(mqttPortR);
              MqttUser = isNullKong(MqttUserR);
              MqttPassword = isNullKong(MqttPasswordR);
              deviceLogAdd('1', 'MQTT$MqttUser$MqttPassword', 'MQTT$MqttUser$MqttPassword');
              if(mqttUrl!=''&&mqttPort!=''){
                //如果mqtt地址和端口号不为空，则连接MQTT
                configureAndConnect(mqttUrl,'$mqttPort',deviceID);//连接MQTT（0是当前还没有连接MQTT）
                checkntpTime();//NTP校对时间
              }
            }
          }
        });
      }else{
        //获取失败 mqtt配置的key获取失败
        if(type==0){
          deviceLogAdd(-1, 'GetKeyByMachineCode接口获取失败或设备未注册$sendMachineCode', 'GetKeyByMachineCode接口获取失败或设备未注册$sendMachineCode');
        }
        //返回的不是200，说明无授权码，设备未注册
        StorageUtil.remove('devicecode');//设备的授权码的值
        StorageUtil.setStringItem('devicecode','');//存储设备授权码
        devicecode = '';//设备的授权码
        StorageUtil.remove('deviceID');//设备ID
        StorageUtil.setStringItem('deviceID','');//设备ID
        if(havesucccode!=0){
          havesucccode = 0;
          changAuthorize(havesucccode);//更改授权的展示
        }
        DiscoveryDevice(posalUrlGetToken);//发现设备
      }

    }
  });
}


//定时获取版本配置
void getConVsiAndMess(type) async{
  var posalUrl = await StorageUtil.getStringItem('posalUrl');//服务器的IP
  var posalport = await StorageUtil.getStringItem('posalport');//服务器的端口号
  var devicecodeHC = await StorageUtil.getStringItem('devicecode');//存起来的授权码
  // var clientIdT = await StorageUtil.getStringItem('deviceID');
  await getDeviceInfo();//获取设备信息
  var sendMachineCode = DeviceInfo['DeviceId'];
  var posalUrlGetToken = 'http://$posalUrl:$posalport';
  var bodySend = {
    'MachineCode': "$sendMachineCode",
    'key': "$KeySend",
  };
  HttpDioHelper helper = HttpDioHelper();
  helper.httpDioGet(posalUrlGetToken, "/InfoPublish/RegisterPlayer/GetDeviceByMachineCode",body:bodySend).then((datares) {
    if(datares.statusCode!=200){
      //服务器问题 接口断网或404 500 403等
      if(type==0){
        //从来没连接过
        deviceLogAdd(-1, 'GetDeviceByMachineCode接口获取失败$sendMachineCode', 'GetDeviceByMachineCode接口获取失败$sendMachineCode');
        if('${devicecodeHC}'=='null'){
          devicecodeHC="";
        }
        jiemisqcode(devicecodeHC).then((codeouttime) {
          print(codeouttime); //授权码的过期时间---现在的逻辑是以前的授权码全都废弃，用新的授权码
          int nowtimeAA = gettimeNowNtp().millisecondsSinceEpoch ~/1000; //当前时间的秒数
          if (codeouttime == "") {
            //没返回过期时间说明是旧的授权码（现已经废弃）
            if (havesucccode != 0) {
              havesucccode = 0;
              changAuthorize(havesucccode); //更改授权的展示
            }
          }
          else {
            print(nowtimeAA);
            int numcodeouttime = int.parse(codeouttime);
            if (numcodeouttime < nowtimeAA) {
              //过期时间小于当前时间说明已经过期
              if (havesucccode != 0) {
                havesucccode = 0;
                changAuthorize(havesucccode); //更改授权的展示
              }
            } else {
              //没有过期
              if (havesucccode != 1) {
                havesucccode = 1;
                changAuthorize(havesucccode); //更改授权的展示
              }
              getdevschList(posalUrlGetToken);//获取当前设备未结束的所有的任务--获取所有的cron
            }
          }
        });


      }
    }
    else{
      var resjson = (datares.data);//json数据
      Map datajaon = json.decode(resjson);
      if('${datajaon['code']}'=='200'){
        var messdatare = datajaon['data'];
        NtpServer = '${messdatare['NtpServer']}';//NTP服务器地址用于时间校对
        var deviceMessre = messdatare['Device'];//返回的获取的device的内容
        var redeviceId = '${deviceMessre['DeviceId']}';//返回的后台注册后生成的deviceID
        var devAuthorizationCode = '${messdatare['AuthorizationCode']}';//返回的获取的当前设备的授权码
        if(devAuthorizationCode=='null'){
          devAuthorizationCode='';
        }
        // var aaa = 'VThkKzc4ZG5WekcxUHJ5bWpwWDE0QT09';
        jiemisqcode(devAuthorizationCode).then((codeouttime) {
          print(codeouttime);//授权码的过期时间---现在的逻辑是以前的授权码全都废弃，用新的授权码
          int nowtimeAA = gettimeNowNtp().millisecondsSinceEpoch ~/ 1000;//当前时间的毫秒数
          if(codeouttime==""){
            //没返回过期时间说明是旧的授权码（现已经废弃）
            if(havesucccode!=0){
              havesucccode = 0;
              changAuthorize(havesucccode);//更改授权的展示
            }

          }
          else{
            print(nowtimeAA);
            int numcodeouttime = int.parse(codeouttime);
            if(numcodeouttime<nowtimeAA){
              //过期时间小于当前时间说明已经过期
              if(havesucccode!=0){
                havesucccode = 0;
                changAuthorize(havesucccode);//更改授权的展示
              }
            }else{
              //没有过期
              if(havesucccode!=1){
                havesucccode = 1;
                changAuthorize(havesucccode);//更改授权的展示
              }
            }
          }
          StorageUtil.remove('devicecode');//设备的授权码的值
          StorageUtil.setStringItem('devicecode',devAuthorizationCode);//存储设备授权码
          devicecode = devAuthorizationCode;//设备的授权码
          if(redeviceId=='null'){
            redeviceId='';
          }
          StorageUtil.remove('deviceID');//设备ID
          StorageUtil.setStringItem('deviceID',redeviceId);//设备ID
          if('$redeviceId'!='null'&&'$redeviceId'!=''&&'$redeviceId'!='0'){
            //返回的设备ID不是空
            var DicConfigNow = messdatare['MqttSetting'];//MQTT的一些配置的返回
            var nowpadMqtt = '${DicConfigNow['MqttServerIP']}';//返回的MQTTIP
            // var nowpadMqtt = '119.167.71.254';//返回的MQTTIP
            if('${DicConfigNow['MqttServerIsSSL']}'=='true'){
              certificate = 1;//0无证书 1有证书 默认有证书实际以后台获取的为准
            }else{
              certificate = 0;//0无证书 1有证书 默认有证书实际以后台获取的为准
            }
            var nowpadMqPort ='';//MQTT的端口号
            if(certificate==1){
              nowpadMqPort = '${DicConfigNow['MqttServerSSLPort']}';//返回的MQTT的有证书的端口号
            }else{
              nowpadMqPort = '${DicConfigNow['MqttServerPort']}';//返回的MQTT的无需证书的端口号
            }
            MqttUser=DicConfigNow['MqttServerUserName'];//MQTT连接的用户名
            MqttPassword=DicConfigNow['MqttServerPassWord'];//MQTT连接的密码
            StorageUtil.setStringItem('MqttUser', MqttUser);
            StorageUtil.setStringItem('MqttPassword',MqttPassword);//存储端口号
            //MQTT返回的内容不是空
            if(nowpadMqtt!=null&&nowpadMqPort!=null&&nowpadMqtt!='null'&&nowpadMqPort!='null'&&nowpadMqPort!=''){
              //当前本地存起来的MQTT跟返回的不相等
              if(mqttUrl!=nowpadMqtt||mqttPort!=nowpadMqPort){
                mqttUrl = nowpadMqtt;//Mqtt服务器的IP
                mqttPort =nowpadMqPort;//Mqtt的端口号
                StorageUtil.setStringItem('mqttUrl', nowpadMqtt);
                StorageUtil.setStringItem('mqttPort',nowpadMqPort);//存储端口号
                deviceLogAdd('1', 'MQTT$MqttUser$MqttPassword', 'MQTT$MqttUser$MqttPassword');
                configureAndConnect(nowpadMqtt,'$nowpadMqPort',redeviceId);//MQTT改变了重新连接MQTT 211 8081
                checkntpTime();//NTP校对时间
              }else if(type==0){
                //返回的相等但是没有连过MQTT 或许重新要连接一下MQTT
                deviceLogAdd('1', 'MQTT$MqttUser$MqttPassword', 'MQTT$MqttUser$MqttPassword');
                configureAndConnect(nowpadMqtt,'$nowpadMqPort',redeviceId);//连接MQTT（0是当前还没有连接MQTT）
                checkntpTime();//NTP校对时间
              }else if(mqoffstanum==2){
                //返回的相等但是没有连过MQTT---一开始没网，后来有网了
                deviceLogAdd('1', 'MQTT$MqttUser$MqttPassword', 'MQTT$MqttUser$MqttPassword');
                configureAndConnect(nowpadMqtt,'$nowpadMqPort',redeviceId);//连接MQTT（0是当前还没有连接MQTT）
                checkntpTime();//NTP校对时间
              }
            }
            if(havesucccode==0){
              //未授权获授权失败，即使有deviceid也需要上报
              DiscoveryDevice(posalUrlGetToken);
            }
          }else{
            //返回的设备ID是空，则在后台还没有授权过，上报设备到后台的未授权设备列表Discovery  model  Key
            DiscoveryDevice(posalUrlGetToken);
          }
        });
      }else{
        //获取失败 设备未注册等 则在后台还没有授权过，上报设备到后台的未授权设备列表Discovery  model  Key
        if(type==0){
          deviceLogAdd(-1, 'GetDeviceByMachineCode接口获取失败或设备未注册$sendMachineCode', 'GetDeviceByMachineCode接口获取失败或设备未注册$sendMachineCode');
        }
        //返回的不是200，设备未注册
        StorageUtil.remove('devicecode');//设备的授权码的值
        StorageUtil.setStringItem('devicecode','');//存储设备授权码
        devicecode = '';//设备的授权码
        StorageUtil.remove('deviceID');//Token的过期时间
        StorageUtil.setStringItem('deviceID','');//设备ID
        if(havesucccode!=0){
          havesucccode = 0;
          changAuthorize(havesucccode);//更改授权的展示
        }
        DiscoveryDevice(posalUrlGetToken);
      }

    }
  });
}

//上报未注册的设备
DiscoveryDevice(urlandport) async{
  var ipAddressS;
  try {
    String ipAddressS = "";
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        ipAddressS = '${addr.address}';
        print('${addr.address}');
      }
    }
    await getDeviceInfo();
    var deviceIDs = DeviceInfo['DeviceId'];
    var deviceName =  DeviceInfo['DeviceName'];
    var deviceVersion = DeviceInfo['DeviceVersion'];
    var systemVersion = DeviceInfo['SystemVersion'];
    var register = {
      'model': {
        "DeviceName": deviceName,
        "IPAddress": ipAddressS,
        "MACAddress": deviceIDs,
        "MachineCode": deviceIDs,
        "SystemVersion": systemVersion,
        "DeviceType": "2",
        "DeviceVersion": deviceVersion,
        "Memory": '0',
        "DiskFreeSize": '0',
        "Location": "",
        "Width": '0',
        "Height": '0',
        "EncryptedSignatureData": "",
        "TcpClientID": "",
        "CurrentStickTime": DateTime
            .now()
            .millisecondsSinceEpoch
      },
      'key': "$KeySend",
    };
    print(register);
    HttpDioHelper helper = HttpDioHelper();
    helper.postUrlencodedDio(urlandport, "/InfoPublish/RegisterPlayer/Discovery",body:register).then((datares) {
      if(datares.statusCode!=200){
        deviceLogAdd(-1, 'Discovery接口没有走通', 'Discovery接口没有走通');
      }else{
        var res = json.decode(datares.data);
        // Fluttertoast.showToast(msg: "${res['info']}");
        if('${res['code']}'!='200'){
          //发现接口报错
          deviceLogAdd(-1, 'Discovery接口${res['info']}', 'Discovery接口${res['info']}');
        }
      }
    });
  } on PlatformException {
    ipAddressS = 'Failed to get ipAddress.';
  }
  //var response = HttpHelper.httpPost(url,"{headers: '12',body: 'body'}");
}



//截取屏幕
ScreenshotController screenshotController = ScreenshotController();

MQTTAppState currentAppState = MQTTAppState();
MQTTManager? manager;
void configureAndConnect(urlMqtt,portMqttsd,clientIdT) {
  // TODO: Use UUID
  var sendMachineCode = DeviceInfo['DeviceId'];
  deviceLogAdd('1', '$urlMqtt$portMqttsd连接MQTT$clientIdT--$certificate--$sendMachineCode', '$urlMqtt$portMqttsd连接MQTT$clientIdT--$certificate--$sendMachineCode');
  var portMqtt = int.parse('$portMqttsd');
  String osPrefix = 'Flutter${getDataNowNtp().millisecondsSinceEpoch}';//默认就是安卓
  var mytopic = '/InfoPublish_DownTopic/$clientIdT';//没有证书的时候的topic
  if(certificate==1){
    var beesmart_key = md5.convert(utf8.encode("tonle-InfoPW")).toString();//写死的跟后台统一的固定头
    var cltidmdval =md5.convert(utf8.encode("$clientIdT")).toString();
    var maxsmkey = beesmart_key.toUpperCase();//转换成大写
    var maxcltidmd = cltidmdval.toUpperCase();//转换成大写
    mytopic = "/InfoPublish_DownTopic/$maxsmkey/$maxcltidmd";//有证书时的topic
  }else{
    mytopic = '/InfoPublish_DownTopic/$clientIdT';//没有证书的时候的topic
  }
  manager = MQTTManager(
      host: urlMqtt,
      port: portMqtt,
      topic: mytopic,
      identifier: osPrefix,
      state: currentAppState
  );

  // manager.initializeMQTTClient();
  // manager.connect();
  // int mqttres = manager.initializeMQTTClient();//安全证书的初始化  0初始化成功  !=0初始化失败
  manager?.initializeMQTTClient();//安全证书的初始化  0初始化成功  !=0初始化失败
  // if(mqttres==0){
    manager?.connect();

  // }
}
void publishMessage(String text) {
  String osPrefix = 'Flutter_Android';
  // final String message = osPrefix + ' says: ' + text;
  print("1111111111111111111111111111111111111111");
  manager?.publish(text);
}
class MQTTManager{
  // Private instance of client
  final MQTTAppState _currentState;
  MqttServerClient? _client;
  final String _identifier;
  final String _host;
  final int _port;
  final String _topic;

  // Constructor
  MQTTManager({
    required String host,
    required int port,
    required String topic,
    required String identifier,
    required MQTTAppState state
  }): _identifier = identifier, _host = host, _port = port, _topic = topic, _currentState = state ;

  int initializeMQTTClient(){
    _client = MqttServerClient(_host,_identifier);
//    _client = MqttClient('test.mosquitto.org',_identifier);
//    _client.port = 1883;
    _client?.port = _port;
    _client?.keepAlivePeriod = 20;
    _client?.onDisconnected = onDisconnected;
    _client?.logging(on: true);
    if(certificate==1){
      _client?.secure = true;//安全认证  有证书之后是true
    }else{
      _client?.secure = false;//安全认证  没有证书是false
    }
    // 安全认证
    SecurityContext context = SecurityContext.defaultContext;
    /// Add the successful connection callback
    _client?.onConnected = onConnected;
    _client?.onSubscribed = onSubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(_identifier)
        .withWillTopic('willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atMostOnce);
    print('EXAMPLE::Mosquitto client connecting....');
    _client?.connectionMessage = connMess;
    try {
      if(certificate==1){
        context.setTrustedCertificatesBytes(utf8.encode(cert_ca));//安全认证ca.crt赋值
        context.useCertificateChainBytes(utf8.encode(cert_client_crt));//安全认证client.crt赋值
        context.usePrivateKeyBytes(utf8.encode(cert_client_key));//安全认证client.key赋值
        context.setAlpnProtocols(['TLSv1.0', 'TLSv1.1', 'TLSv1.2', 'TLSv12'],false);// 设置 ALPN 协议   TLS 协议  false 指示是否为服务器请求
      }
    }catch (e) {
      //出现异常 证书配置语法方面的错误
      print("SecurityContext set  error : " + e.toString());
      // deviceLogAdd(-1,"证书配置语法方面的错误",'证书配置语法方面的错误');
      deviceLogAdd(-1,"证书配置错误$e",'证书配置错误$e');
      return -1;
    }
    if(certificate==1){
      _client?.securityContext = context;//安全证书赋值
    }

    _client?.setProtocolV311();//安全证书相关
    // _client.onBadCertificate = (X509Certificate certificate) {
    //   print('Bad certificate encountered');
    //   return true;
    //   // 在这里处理证书验证失败的逻辑
    // };
    // _client.onBadCertificate Callback = ((X509 Certificate Cert, String host, int port) => true);
    return 0;
  }
  // badcertfun(X509Certificate certificate, String host, int port){
  //   deviceLogAdd(-1,"证书配置错误的返回方法重写",'证书配置错误的返回方法重写');
  //   return true;
  // }
  // Connect to the host
  void connect() async{
    assert(_client != null);
    try {
      print('EXAMPLE::Mosquitto start client connecting....');
      await _client?.connect('$MqttUser','$MqttPassword');//需要传递用户名和密码
      print('成功');
      Fluttertoast.showToast(msg: "MQTT连接成功");
      mqoffstanum = 0;//MQTT掉线后是1，未连接和正常连接都是0
      sendofflog();//把收集的离线日志上传到服务器
      deviceLogAdd('1', 'MQTT连接成功', 'MQTT连接成功');
      deviceLogAdd(7,"上报一下当前的应用唯一号和版本",'上报一下当前的应用唯一号和版本');
      deviceNowAdd();//一进系统上报一下当前的应用唯一号和版本
      sendplaytimeMess();//上传之前缓存里的上传失败的播放时长的集合
      //连接成功后每10秒发送一次心跳
      if(mytimer!=null){
        mytimer.cancel();
      }
      startTimer();
      var urlPlaylist = 'http://$posalUrl:$posalport';
      //走接口获取当前播放节目
      if(urlPlaylist!='http://'){
        if(myplayschtimer!=null){
          myplayschtimer.cancel();//清空每秒钟更新最后播放时间的定时器，之后重新定时
        }
        getplayschTimer();//实时更新最后播放时间---不写在这，测试用的，最后需要注释掉
        Future.delayed(Duration(seconds: 3), (){
          //3S后去获取，确保之前缓存里的播放时长可以提交上去
          // searchlistplayNow(urlPlaylist,"0");
          getnowsertList(urlPlaylist);//获取当前正在播放的字幕
          getdevschList(urlPlaylist);//获取当前设备未结束的所有的任务--获取所有的cron
          //走http 接口更新会议数据
          getIframeConnect();
        });
      }
    } catch(e) {
      print('EXAMPLE::client exception - $e');
      if(mqoffstanum!=1){
        //之前没有断开现在断开了，上传一下日志
        deviceLogAdd(-1,"$e","$runtimeType：${e.runtimeType}message：${e}");//
        // deviceLogAdd(-1,"$e","$runtimeType：${e.runtimeType}message：${e.message}${e.osError.message}");//
      }
      disconnect();
    }
  }
  void startTimer() {
    const period = const Duration(seconds: 10);
    mytimer = Timer.periodic(period, (timer) {
      //到时回调
      send();
    });
  }
  //发送心跳
  send() async{
    print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
    // String ipsocket = await GetIp.ipAddress;
    String ipsocket = "";
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        ipsocket = '${addr.address}';
        print('${addr.address}');
      }
    }
    StorageUtil.setStringItem('ipAddress',ipsocket);//设备Ip
    deviceID = await StorageUtil.getStringItem('deviceID');
    // var sysvolume = await Volume.getVol;
    double sysvolume = await FlutterVolumeController.getVolume() as double;
    String strOfVlo = sysvolume.toStringAsFixed(1);
    sysvolume = double.parse(strOfVlo);


    var sysZhengVideo = (sysvolume*100).round();
    if(numcompare!=-1){
      if(sysvolume!=numcompare){
        // Volume.setVol(numcompare, showVolumeUI: ShowVolumeUI.SHOW);
        FlutterVolumeController.setVolume(numcompare);
        deviceLogAdd(4,"当前音量不一致，设备当前音量：$sysvolume，收到命令音量：*$numcompare","以收到命令为准");
      }
    }

    var diskTotal = await DiskSpace.getTotalDiskSpace;//当前总的存储空间
    var diskFree = await DiskSpace.getFreeDiskSpace;//当前剩余的存储空间
    double diskPre = 0;//剩余空间占总容量的百分比
    if (diskTotal != null && diskTotal > 0 && diskFree != null) {
      diskPre = 1 - (diskFree / diskTotal);
    }
    var diskPreDou = (diskPre*100).toStringAsFixed(0);

    var memoryTotal = SysInfo.getTotalPhysicalMemory();//总物理内存
    var freememoryVal = SysInfo.getFreePhysicalMemory();//空闲的物理内存
    double memoryPre = 1-(freememoryVal/memoryTotal);//剩余空间占总容量的百分比
    var diskPrememory = (memoryPre*100).toStringAsFixed(0);

    //看是否有deviceID
    StorageUtil.getStringItem('deviceID').then((datares) async {
      //发送过心跳
      if(datares != null){
        // print('发送注册完心跳');
        print(sysZhengVideo);
        var dataJson = {
          "Memory":"$diskPrememory",
          "Disk":"$diskPreDou",
          "SysVolunme":sysZhengVideo,
        };
        //var sendData=jsonEncode({
        //  "ClientId":datares,
         // "DataType":1,
        //  "DataJson":dataJson
       // });
        var sendData={
          "ClientId":datares,
          "DataType":1,
          "DataJson":dataJson
        };

        print(sendData);
        if(certificate==1){
          var newsenddata = await jiamiasc(sendData);
          String message = encodeBase64(json.encode(newsenddata));
          publishMessage(message);
        }else{
          String message = encodeBase64(json.encode(sendData));
          publishMessage(message);
        }
      }
      else{
//        print('发送注册心跳');
        var deviceIDs = DeviceInfo['DeviceId'];
        var deviceName =  DeviceInfo['DeviceName'];
        var deviceVersion = DeviceInfo['DeviceVersion'];
        var systemVersion = DeviceInfo['SystemVersion'];
        Map register = (
            {
              "DeviceId":"",
              "DeviceName":deviceName,
              "IPAddress":ipsocket,
              "MACAddress":deviceIDs,
              "MachineCode":deviceIDs,
              "SystemVersion":systemVersion,
              "DeviceType":"2",
              "DeviceVersion":deviceVersion,
              "Memory":0,
              "DiskFreeSize":0,
              "Location":"",
              "Width":0,
              "Height":0,
              "AuthorizationCode":devicecode,
              "EncryptedSignatureData":"",
              "TcpClientID":"",
              "CurrentStickTime": getDataNowNtp().millisecondsSinceEpoch
            }
        );
        Map sendData={
          "ClientId":"",
          "DataType":0,
          "DataJson":register
        };

        if(certificate==1){
          var newsenddata = await jiamiasc(sendData);
          String message = encodeBase64(json.encode(newsenddata));
          publishMessage(message);
        }else{
          String message = encodeBase64(json.encode(sendData));
          publishMessage(message);
        }

        print(sendData);
      }

    });
    //看看有无插播字幕，如果有判断字幕的结束时间是否该结束了
    if(playinsertId!="0"){
      if('${insertmess['EndTime']}'!=""){
        //2023-08-07T14:51:43.0549426+08:00
        DateTime nowMeet = getDataNowNtp();//当前时间
        //结束时间小于当前时间，则应该结束了
        if(CompareTime(nowMeet,'${insertmess['EndTime']}')) {
          playinsertId = '0';
          insertmess = {
            "Message": "",//展示的内容
            "EndTime": "",//插播消息的结束时间
            "Speed": "",//速度
            "BackColor": "",//背景色
            "MessageColor": "",//字的颜色
            "FontName": "",//字体
            "FontSize": "",//字号
            "Dock": ""//滚动位置1上2下3左4右
          };
          streaminsert.add('$playinsertId');//更改字幕
          Future.delayed(Duration(seconds: 3), (){
            var url = 'http://$posalUrl:$posalport';
            getnowsertList(url);//获取当前正在播放的字幕
          });
        }
      }
    }

  }

  void disconnect() {
    print('Disconnected');
    _client?.disconnect();
  }

  void publish(String message){
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    final payload = builder.payload!; // typed.Uint8Buffer
    if('${_client?.connectionStatus?.state}'=='${MqttConnectionState.connected}'){
      _client?.publishMessage("InfoPublishMqtt_CallBack", MqttQos.atMostOnce, payload);
    }else{
      Fluttertoast.showToast(msg: "MQTT连接处于断开状态");
    }

  }

  /// 订阅的回调
  void onSubscribed(String topic) {
    print('onSubscribed');
  }

  /// 主动断开连接回调
  void onDisconnected() {
//    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    print('连接断开');
    Fluttertoast.showToast(msg: "MQTT连接断开，10S后进行重连");
    if(mqoffstanum==1){
      //已经上传过MQTT断开连接的日志了，已经掉线了
    }else{
      //还没有上传过连接断开的消息
      deviceLogAdd(19,"MQTT连接断开，10S后进行重连","MQTT连接断开，10S后进行重连");
      mqoffstanum = 1;//MQTT掉线后是1，未连接和正常连接都是0
    }

    Future.delayed(Duration(seconds: 10), (){
      print('重新连接');
      manager?.connect();
    });
    if (_client?.connectionStatus?.disconnectionOrigin == MqttDisconnectionOrigin.solicited) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }
  }

  /// 成功的连接回调
  void onConnected() {
//    _currentState.setAppConnectionState(MQTTAppConnectionState.connected);
    print('EXAMPLE::Mosquitto client connected.....');
    _client?.subscribe(_topic, MqttQos.atMostOnce);
    _client?.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      //接收到的消息
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;;
      final String pt =MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      var message = decodeBase64(pt);
      // print(message);
      // print('EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      Map resBefore = json.decode(message);
      if(certificate==1){
        jiemiascwww(resBefore).then((resstr) {
          Map res = json.decode(resstr);
          arrangeMqttMess(res,message);//后续数据的处理
        });
      }else{
        arrangeMqttMess(resBefore,message);//后续数据的处理
      }


    });
    print('EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }

}
//MQTT数据处理后的一系列操作
arrangeMqttMess(res,message) async {
  if('${res['DataType']}'=='3'){
    print('截取屏幕');
    deviceLogAdd(3,message,"接收截取屏幕的命令！$deviceID");
    myscrshotTwo();//获取截图


    // screenshotController
    //     .capture(path:'',delay: Duration(milliseconds: 10))
    //     .then((File image) async {
    //   var byteImg = await image.readAsBytesSync();
    //   var testimg= base64Encode(byteImg);
    //   // String baseingtrstr = byteImg.toString();
    //   // var baseData = encodeBase64(baseingtrstr);
    //   var sendData={
    //     "ClientId":deviceID,
    //     "DataType":3,
    //     "DataJson":testimg
    //   };
    //   String message = encodeBase64(json.encode(sendData));
    //   publishMessage(message);
    // }).catchError((onError) {
    //   deviceLogAdd(3,"截取屏幕时报错！$deviceID","截取屏幕时报错！$deviceID");
    //   print(onError);
    // });
  }
  else if('${res['DataType']}'=='4'){
    print('音量调节');
    var datajson = res['DataJson'];
    var voNum = int.parse(datajson);
    String voshowNumStr = (voNum/100).toStringAsFixed(1);
    double voshowNum = double.parse(voshowNumStr);
    numcompare = voshowNum;
    StorageUtil.setStringItem('numcompare','$numcompare');//Token的值
    print('$voshowNum');
    deviceLogAdd(4,message,"接收音量调节的命令！$deviceID");
    // Volume.setVol(voshowNum, showVolumeUI: ShowVolumeUI.SHOW);
    FlutterVolumeController.setVolume(voshowNum.toDouble());
  }
  else if('${res['DataType']}'=='5'){
    numcompare = 0;
    StorageUtil.setStringItem('numcompare','$numcompare');//Token的值
    deviceLogAdd(5,message,"接收静音的命令！$deviceID");
    print('静音');
    // Volume.setVol(0, showVolumeUI: ShowVolumeUI.SHOW);
    FlutterVolumeController.setVolume(0);
  }
  else if('${res['DataType']}'=='7'){
    //------------进行热更新的一系列操作start---------------
    var datajson = json.decode(res['DataJson']);
    var AppId = datajson['AppId'];
    var VersionName = datajson['VersionName'];
    var VersionNumber = int.parse('${datajson['VersionNumber']}');
    var CheckSum = datajson['CheckSum'];//要下载的文件的MD5的值
    var nowpath = datajson['Path'];//要下载的文件位置
    // sendAppId = '${datajson['AppId']}';//MQTT发送过来的唯一版本号
    // sendVersionName = '${datajson['VersionName']}';//MQTT发送过来的版本名
    // sendVersionNumber = '${datajson['VersionNumber']}';//MQTT发送过来的版本号
    deviceLogAdd(7,"收到热更命令$AppId-$VersionName-$VersionNumber-$deviceID","收到热更命令$AppId-$VersionName-$VersionNumber-$deviceID");
    devicehotUpAdd(1);//走接口更新版本热更新的更新状态---接受命令成功

    //判断是否是更新的当前APP
    if(AppId==myAppId){
      String version = await getAndroidManifestVersion();
      print('AndroidManifest.xml中的版本号: $version');
      if(VersionName==version){
        //是当前主版本的热更新
        if(VersionNumber>myhotversionNum){
          //版本号大于当前安装的版本号
          expectedChecksum = CheckSum;//下载的文件md5的值
          hotdownpath = nowpath;//要下载的文件的位置
          StorageUtil.setStringItem('upstanum','2');// 处于热更新的过程中  1更新进来的 0正常进入 2热更新步骤还未走完退出APP后进来的
          StorageUtil.setStringItem('expectedChecksum','$expectedChecksum');// 下载文件的md5值
          StorageUtil.setStringItem('hotdownpath','$hotdownpath');// 下载文件的位置
          StorageUtil.setStringItem('mqttVsName','$VersionName');// MQTT命令要下载的版本名称（按最后一次发命令为准）
          StorageUtil.setStringItem('mqttVsNumber','$VersionNumber');// MQTT命令要下载的版本号（按最后一次发命令为准）
          deviceLogAdd(7,"热更新的版本正确准备去下载$nowpath","热更新的版本正确准备去下载$nowpath");
          downhotfile(1);//下载热更新的文件
        }else{
          deviceLogAdd(7,"热更新的版本号小于当前版本号$AppId-$VersionName-$VersionNumber-$deviceID","热更新的版本号小于当前版本号$AppId-$VersionName-$VersionNumber-$deviceID");
          devicehotUpAdd(-4);//走接口更新版本热更新的更新状态--更新失败
        }
      }else{
        deviceLogAdd(7,"版本名称不一致$AppId-$VersionName-$VersionNumber-$deviceID","版本名称不一致$AppId-$VersionName-$VersionNumber-$deviceID");
        devicehotUpAdd(-4);//走接口更新版本热更新的更新状态--更新失败
      }
    }else{
      deviceLogAdd(7,"APPID不一致$AppId-$VersionName-$VersionNumber-$deviceID","APPID不一致$AppId-$VersionName-$VersionNumber-$deviceID");
      devicehotUpAdd(-4);//走接口更新版本热更新的更新状态--更新失败
    }
    //------------进行热更新的一系列操作end---------------
  }
  else if('${res['DataType']}'=='9'){
    deviceLogAdd(9,message,"接收到插播消息的命令！$deviceID");
    //根据projectId去下载节目的压缩包
    var datajson = json.decode(res['DataJson']);
    //返回的数据
    playinsertId = '1';
    insertmess = {
      "Message": "${datajson['Message']}",//展示的内容
      "EndTime": "${datajson['EndTime']}",//插播消息的结束时间
      "Speed": "${datajson['Speed']}",//速度
      "BackColor": "${datajson['BackColor']}",//背景色
      "MessageColor": "${datajson['MessageColor']}",//字的颜色
      "FontName": "${datajson['FontName']}",//字体
      "FontSize": "${datajson['FontSize']}",//字号
      "Dock": "${datajson['Dock']}"//滚动位置1上2下3左4右
    };
    streaminsert.add('$playinsertId');//更改字幕

  }
  else if('${res['DataType']}'=='10'){
    deviceLogAdd(10,message,"接收到下载的命令！$deviceID");
    print('下载并解压缩节目');
    //根据projectId去下载节目的压缩包
    var datajson = json.decode(res['DataJson']);
    var ProgramId = datajson['ProgramId'];
    var ScheduleId = datajson['ScheduleId'];
    var TYPE = datajson['TYPE'];//节目的类型（如果是紧急插播则立即播放）1 普通节目 2 插播节目 3 插播字幕 4系统开屏 5 系统关屏
    if(TYPE==2){
      // playscheduleproId = ScheduleId;
      // steamProplayChange(ProgramId);//下载播放
      //因为紧急插播节目还会发一遍20的命令，所以不动作
    }else{
      //接收到下载命令的时候也去更新一下任务列表（要不然断网后数据会有偏差）
      Future.delayed(Duration(seconds: 3), (){
        var url = 'http://$posalUrl:$posalport';
        getdevschList(url);//获取当前设备未结束的所有的任务--获取所有的cron
      });
      steamProplay(ProgramId);
    }

  }
  else if('${res['DataType']}'=='12'){
    //开屏
    print('----------开屏-------------');
    deviceLogAdd(12,message,"接收开屏的命令！$deviceID");
    showOpenNotification();//开屏
  }
  else if('${res['DataType']}'=='13'){
    //关屏
    print('----------关屏-------------');
    deviceLogAdd(13,message,"接收关屏的命令！$deviceID");
    showCloseNotification();//关屏
  }
  else if('${res['DataType']}'=='14'){
    print('停止播放节目');
    deviceLogAdd(14,message,"接收到删除节目安排的命令！$deviceID");
    var datajson = json.decode(res['DataJson']);
    var ProgramId = datajson['ProgramId'];
    var ScheduleId = datajson['ScheduleId'];
    var TYPE = datajson['TYPE'];//type是3的话是取消插播的字幕
    if(TYPE==3){
      // if(playinsertId=='$ScheduleId'){
        //当前正在播的字幕的ID是要取消的，则取消当前字幕的播放
        playinsertId = '0';
        insertmess = {
          "Message": "",//展示的内容
          "EndTime": "",//插播消息的结束时间
          "Speed": "",//速度
          "BackColor": "",//背景色
          "MessageColor": "",//字的颜色
          "FontName": "",//字体
          "FontSize": "",//字号
          "Dock": ""//滚动位置1上2下3左4右
        };
        streaminsert.add('$playinsertId');//更改字幕
        Future.delayed(Duration(seconds: 3), (){
          var url = 'http://$posalUrl:$posalport';
          getnowsertList(url);//获取当前正在播放的字幕
        });
      // }
    }
    //停止播放（查看当前播放的是哪一个节目，如果是一样的节目就停止播放，如果是不一样的就不管）
    print('当前节目：$playproId**停止播放节目$ProgramId');
    print('当前任务：$ScheduleId**停止播放任务$playscheduleproId');
    if(ScheduleId==playscheduleproId){
      steamstoppro('0');
      Future.delayed(Duration(seconds: 3), (){
        var url = 'http://$posalUrl:$posalport';
        // searchlistplayNow(url,ScheduleId);//重新获取应该播放的列表
        getdevschList(url);//获取当前设备未结束的所有的任务--获取所有的cron
      });

    }
  }
  else if('${res['DataType']}'=='19'){
    deviceLogAdd(19,message,"接收到拉取数据的命令！$deviceID");
    getIframeConnect();//拉取数据
  }
  else if('${res['DataType']}'=='20'){
    var datajson = json.decode(res['DataJson']);
    var ProgramId = datajson['ProgramId'];
    var PlayTypeme = datajson['PlayType'];//1是播放，0是停止
    var ScheduleId = datajson['ScheduleId'];//任务ID
    if(PlayTypeme==1){
      deviceLogAdd(20,message,"接收到播放任务--开始！任务id：$ScheduleId节目id:$ProgramId");
      //播放
      var TYPE = datajson['TYPE'];//节目的类型（如果是紧急插播则立即播放）1 普通节目 2 插播节目 3 插播字幕 4系统开屏 5 系统关屏
      if(TYPE!=2){}
      //任务的结束时间
      // Future.delayed(Duration(seconds: 3), (){
      //   playscheduleproId = ScheduleId;
      //   steamProplayChange(ProgramId);
      // });
      //为了防止审核以后节目已经不需要播放了然后不停止的bug，直接改为走接口获取当前应该播放的节目
      Future.delayed(Duration(seconds: 3), (){
        var url = 'http://$posalUrl:$posalport';
        // searchlistplayNow(url,0);
        getdevschList(url);//获取当前设备未结束的所有的任务--获取所有的cron
      });
    }
    else{
      //停止播放（查看当前播放的是哪一个节目，如果是一样的节目就停止播放，如果是不一样的就不管）
      deviceLogAdd(20,message,"接到停止播放的命令--停止！任务id：$ScheduleId节目id:$ProgramId");
      // print('当前节目：$playproId**停止播放节目$ProgramId');
      // print('当前任务：$ScheduleId**停止播放任务$playscheduleproId');
      if(ScheduleId==playscheduleproId){
        steamstoppro('0');
        Future.delayed(Duration(seconds: 3), (){
          var url = 'http://$posalUrl:$posalport';
          // searchlistplayNow(url,ScheduleId);
          getdevschList(url);//获取当前设备未结束的所有的任务--获取所有的cron
        });
      }
    }
  }
  else if('${res['DataType']}'=='21'){
    //接收到删除某一个节目或者所有的节目的命令
    deviceLogAdd(5,message,"接收到删除所有节目的命令！");
    //假设传过来的节目ID是6bbbb754-3d3a-4a24-bae7-f68d04c2463e
    var proCid = '6bbbb754-3d3a-4a24-bae7-f68d04c2463e';
    delectProFile(proCid);//删除当前节目
  }
  else if('${res['DataType']}'=='22'){
    deviceLogAdd(22,message,"接收更改APP模板样式的命令！");
    //接收到是否加载节目的命令
    if('${res['DataJson']}'=='0'){
      //加载不带有节目的样式（一整个都是会议）--有会议小程序二维码
      changetemp("0");
    }else if('${res['DataJson']}'=='1'){
      //加载带有节目的样式（一半节目一半会议）
      changetemp("1");
    }else if('${res['DataJson']}'=='2'){
      //加载不带有会议的样式（一整个都是节目）
      changetemp("2");
    }else if('${res['DataJson']}'=='3'){
      //加载不带有节目的样式（一整个都是会议）--无会议小程序二维码--涉外版本
      changetemp("3");
    }else if('${res['DataJson']}'=='4'){
      //加载不带有节目的样式（一整个都是会议）--摄像头人脸签到版本
      changetemp("4");
    }

  }
  else if('${res['DataType']}'=='29'){
    deviceLogAdd(29,message,"接收更改终端背景的命令！");
    var datajson = '${res['DataJson']}';
    var posalUrlGetToken = 'http://$posalUrl:$posalport';
    var imgpoUrl = '$posalUrlGetToken$datajson';
    if(datajson!='null'&&datajson!=''){
      chanbgNow(imgpoUrl);//背景图片下载到本地
    }

    // ByteData bytesbgImg = await rootBundle.load('$posalUrlGetToken$datajson');
    // var bufferbgImg = bytesbgImg.buffer;
    // var backImgbgImg = base64.encode(Uint8List.view(bufferbgImg));

  }
  else if('${res['DataType']}'=='30'){
    deviceLogAdd(30,message,"接收到当前设备授权已过期！");
    if(havesucccode!=0){
      havesucccode = 0;//授权已过期
      changAuthorize(havesucccode);//更改授权的展示
    }

  }
}
String decodeBase64(String data){
//  return String.fromCharCodes(base64Decode(data));
  return Utf8Decoder().convert(base64Decode(data));
}
//授权信息更改
changAuthorize(sucodeval){
  streamtemplate.add('$sucodeval');
}



// InAppWebViewController mywebViewController;
late AndroidWebViewController mywebViewController;
String mywebUrl = '';

String mylocaPath = "";


void steamProplay(val) async{
  print('下载并解压缩节目');
  deviceLogAdd(10,"接收到下载节目的命令！$deviceID","接收到下载节目的命令！$deviceID");
  if(isKeptOn==true){
    //开着屏（屏幕常亮已关闭）
    proIdOfdownload="$val";
    playType = '1';//1下载节目 2播放节目 3下载并加载节目
    streamDemo.add(playType);
    //走判断当前存储空间的方法小于总容量的百分之5或者内存小于500M的时候添加报警日志
    initPlatformState();
  }else{
  //
  }
}
//更改播放的节目
void steamProplayChange(val,playschId) async{
  if(isKeptOn==true){
    deviceLogAdd(10,"收到10紧急插播或者是20播放的命令或者是一进页面自动获取当前该播放的节目的播放！$deviceID","加载文件并播放$deviceID");
    //开着屏（屏幕常亮已关闭）
    print('更改播放的节目');//检查文件夹有没有被下载，没有被下载的话下载并播放，如果下载过了直接播放
    proIdOfdownload="$val";
    playproId="$val";
    playType = '3';
    mylocaPath = await findLocalPath();
    var yuanlaiwebUrl = mywebUrl;//原来的播放地址
    var webUrlnow = 'file://$mylocaPath/$playproId/${playproId}.html';
    if(webUrlnow!=yuanlaiwebUrl){
      //如果不一致，则更换播放的节目
      streamDemo.add(playproId);
    }
    //收到命令更改播放的节目，此时需要上传上一份计划的播放时长，并开始存储当前的计划的播放时长
    var plschmessBefore = await StorageUtil.getStringItem('playschmess');//缓存里当前任务的播放时长
    var nowtimeA = gettimeNowNtp().millisecondsSinceEpoch;//当前时间的毫秒数
    nowplayschMess = {
      'scheduleID':'$playschId',//任务ID
      'proID':playproId,//节目ID
      'playStart':'$nowtimeA',//开始播放时间时间戳
      'lastplaytime':'$nowtimeA',//最后播放时间戳
      'Durationtime':'0'//持续时间单位ms毫秒
    };
    var playschmessStr = json.encode(nowplayschMess);
    StorageUtil.setStringItem('playschmess', playschmessStr);//存在缓存里
    sendAndChangeSch(plschmessBefore);//把之前的上传至服务器
    //走判断当前存储空间的方法小于总容量的百分之5或者内存小于500M的时候添加报警日志
    initPlatformState();
  }else{

  }
}

//播放下载并解压好的节目
void steamProplayplay(val) async{
  if(isKeptOn==true){
    //开着屏（屏幕常亮已关闭）
    print('播放的节目');
    deviceLogAdd(10,"播放下载完成并且解压好的节目！$playproId","播放下载完成并且解压好的节目！$playproId");
    playproId="$val";
    playType = '2';
    mylocaPath = await findLocalPath();
    mywebUrl = 'file://$mylocaPath/$playproId/${playproId}.html';
    if(mywebViewController!=null){
      // mywebViewController.loadUrl(mywebUrl);
      // mywebViewController?.loadRequest(Uri.parse(
      //   '$mywebUrl',
      // ));

      mywebViewController?.loadRequest(LoadRequestParams(
        uri: Uri.parse('$mywebUrl'),
      ),);
    }
    streamDemo.add(playType);   //暂时注释掉
    //收到命令更改播放的节目，此时需要上传上一份计划的播放时长，并开始存储当前的计划的播放时长

    var plschmessBefore = await StorageUtil.getStringItem('playschmess');//缓存里当前任务的播放时长
    var nowtimeA = gettimeNowNtp().millisecondsSinceEpoch;//当前时间的毫秒数
    nowplayschMess = {
      'scheduleID':'$playscheduleproId',//任务ID
      'proID':playproId,//节目ID
      'playStart':'$nowtimeA',//开始播放时间时间戳
      'lastplaytime':'$nowtimeA',//最后播放时间戳
      'Durationtime':'0'//持续时间单位ms毫秒
    };
    var playschmessStr = json.encode(nowplayschMess);
    StorageUtil.setStringItem('playschmess', playschmessStr);//存在缓存里
    sendAndChangeSch(plschmessBefore);//把之前的上传至服务器，方法中会判断是否有值

  }else{

  }
}
//展示空白节目
void steamstoppro(val) async{
  print('展示空白节目');
  deviceLogAdd(0,"停止播放当前节目","停止播放当前节目");
  playproId="0";
  playscheduleproId = '0';
  playType = '0';
  mylocaPath = await findLocalPath();
  mywebUrl = 'file://$mylocaPath/$playproId/${playproId}.html';
  streamDemo.add(playproId);
  //收到命令更改播放的节目，此时需要上传上一份计划的播放时长，并开始存储当前的计划的播放时长
  var plschmessBefore = await StorageUtil.getStringItem('playschmess');//缓存里当前任务的播放时长
  var nowtimeA = gettimeNowNtp().millisecondsSinceEpoch;//当前时间的毫秒数
  nowplayschMess = {
    'scheduleID':'',//任务ID
    'proID':'',//节目ID
    'playStart':'',//开始播放时间时间戳
    'lastplaytime':'',//最后播放时间戳
    'Durationtime':''//持续时间单位ms毫秒
  };
  var playschmessStr = json.encode(nowplayschMess);
  StorageUtil.setStringItem('playschmess', '');//存在缓存里,把缓存的值清空
  sendAndChangeSch(plschmessBefore);//把之前的上传至服务器，方法中会判断是否有值
}

//上传上一份的播放时长，并开始存储当前计划的播放时长
sendAndChangeSch(playschmess){
  if(playschmess!=null&&playschmess!='null'&&playschmess!=''){
    var messplay = json.decode(playschmess);
    //一进入页面有值说明是之前没有上传过的数据，有值就上传,传值过去以后就清空缓存里的值
    var sendlist = [
      {
        'ScheduleId':'${messplay['scheduleID']}',
        'ProgramId':'${messplay['proID']}',
        'DeviceId':'$deviceID',
        'StartDate':'${messplay['playStart']}',
        'EndDate':'${messplay['lastplaytime']}',
        'Duration':'${messplay['Durationtime']}',
      }
    ];
    sendplschtimeMess(sendlist);//上传缓存里的数值
  }
}




//走接口获取任务列表，寻找当前时间在大于开始时间小于结束时间的list,然后选择开始时间最晚的那一个节目
void searchlistplayNow(url,ScheduleId) async{
  deviceID = await StorageUtil.getStringItem('deviceID');
  if(deviceID!='null'){
    deviceLogAdd(10,"获取当前设备所有正在播的节目！$deviceID","获取当前设备所有正在播的节目！$deviceID");
    var deviceMess ={
      'DeviceId':deviceID,
    };
    HttpDioHelper helper = HttpDioHelper();
    helper.httpDioGet(url, "/RegisterPlayer/DeviceLoadProgramQuartz",body:deviceMess).then((datares) {
      if(datares.statusCode==200){
        var res = json.decode(datares.data);
        var playlist = res['data'];
        print("________________________________");
        print("$res");
        var diffcomOnece = 0;
        var diffcom = 0;
        var palyID='0';
        var playsch = '0';
        if(playlist.length==0){
          steamstoppro('0');//停止播放节目
          deviceLogAdd(0,"获取播放的节目列表数据为空停止播放节目",'获取播放的节目列表数据为空停止播放节目');
        }
        //遍历整个播放列表
        for(var item in playlist){
          var PlayTime = item['PlayTime'];
          var StopTime = item['StopTime'];
          DateTime nowMeet = getDataNowNtp();//当前时间
          //开始时间小于当前时间
          if(CompareTime(nowMeet,PlayTime)) {
            //结束时间大于当前时间
            if (CompareTime(StopTime, PlayTime)) {
              var stsTimeP = DateTime.parse(PlayTime);//开始时间
              var endsTimeP = DateTime.parse(StopTime);//结束时间
              var difference = nowMeet.difference(stsTimeP);//开始时间与当前时间的时间差，时间差越小越要播放
              var diffSecond = difference.inMilliseconds;
              print('$diffSecond');
              //当是初始值的时候先默认放置循环里的第一个值
              if(diffcomOnece==0){
                if(ScheduleId!=item['ScheduleId']){
                  diffcom =diffSecond;
                  palyID = item['ProgramId'];
                  playsch = item['ScheduleId'];
                  diffcomOnece = 1;
                }

              }else if(diffSecond<=diffcom){
                if(ScheduleId!=item['ScheduleId']){
                  diffcom =diffSecond;
                  palyID = item['ProgramId'];
                  playsch = item['ScheduleId'];
                }
              }

            }
          }
        }
        if(palyID!='0'){
          //有正在播放的节目，播放当前节目
          Future.delayed(Duration(seconds: 3), (){
            playscheduleproId = playsch;
            steamProplayChange(palyID,playscheduleproId);
          });

        }
      }

    }).catchError(
            (e){
          if(e is DioError)
          {
            deviceLogAdd(14,"获取节目正在播放列表",'获取节目正在播放列表:${e.error}');
          }
          else
          {
            deviceLogAdd(14,"获取节目正在播放列表",'获取节目正在播放列表');
          }
        }
    ).whenComplete(() => deviceLogAdd(14, '获取节目正在播放列表流程结束', '获取节目正在播放列表流程结束'));

  }



}
//获取正在播放的字幕列表
void getnowsertList(url) async{
  deviceID = await StorageUtil.getStringItem('deviceID');
  if(deviceID!='null'){
    deviceLogAdd(10,"获取当前设备所有的插播字幕列表！$deviceID","获取当前设备所有的插播字幕列表！$deviceID");
    var deviceMess ={
      'deviceid':deviceID,
    };
    HttpDioHelper helper = HttpDioHelper();
    ///InfoPublish/RegisterPlayer/GetInsertMessageByDeviceId?deviceid=
    helper.httpDioGet(url, "/RegisterPlayer/GetInsertMessageByDeviceId",body:deviceMess).then((datares) {
      if(datares.statusCode==200){
        var res = json.decode(datares.data);
        var ptextlist = res['data'];
        print("________________________________");

        if(ptextlist.length==0){
          deviceLogAdd(0,"获取播放的插播字幕数据为空停止播放节目",'获取播放的插播字幕数据为空');
        }else{
          playinsertId = '1';
          var intextjaon = ptextlist[0];
          insertmess = {
            "Message": "${intextjaon['Message']}",//展示的内容
            "EndTime": "${intextjaon['EndTime']}",//插播消息的结束时间
            "Speed": "${intextjaon['Speed']}",//速度
            "BackColor": "${intextjaon['BackColor']}",//背景色
            "MessageColor": "${intextjaon['MessageColor']}",//字的颜色
            "FontName": "${intextjaon['FontName']}",//字体
            "FontSize": "${intextjaon['FontSize']}",//字号
            "Dock": "${intextjaon['Dock']}"//滚动位置1上2下3左4右
          };
          streaminsert.add('$playinsertId');//更改字幕
        }

      }

    }).catchError(
            (e){
          if(e is DioError)
          {
            deviceLogAdd(14,"获取节目插播字幕列表",'获取节目插播字幕列表:${e.error}');
          }
          else
          {
            deviceLogAdd(14,"获取节目插播字幕列表",'获取节目插播字幕列表');
          }
        }
    ).whenComplete(() => deviceLogAdd(14, '获取节目插播字幕流程结束', '获取节目插播字幕流程结束'));

  }


}
//获取设备加载任务列表(当前未结束的、未来所有的)
// void getdevschList(url) async{
//   deviceID = await StorageUtil.getStringItem('deviceID');//当前设备的设备ID
//   if(deviceID!='null'){
//     deviceLogAdd(10,"获取当前设备所有的未结束的任务列表！$deviceID","获取当前设备所有的未结束的任务列表！$deviceID");
//     var deviceMess ={
//       'deviceid':deviceID,
//     };
//     HttpDioHelper helper = HttpDioHelper();
//     helper.httpDioGet(url, "/RegisterPlayer/DeviceLoadProgramQuartzAll",body:deviceMess).then((datares) {
//       if(datares.statusCode==200){
//         var res = json.decode(datares.data);
//         var schplanlist = res['data'];
//
//         //CronShow 一次
//         if(schplanlist.length==0){
//           deviceLogAdd(0,"获取当前设备未结束的任务列表为空",'获取当前设备未结束的任务列表为空');
//         }else{
//
//         }
//
//       }
//
//     });
//
//   }
//
//
// }


//获取当前设备所有的未结束的任务列表
void getdevschList(url) async{
  deviceID = await StorageUtil.getStringItem('deviceID');//当前设备的设备ID
  if(deviceID!='null'){
    deviceLogAdd(10,"获取当前设备所有的未结束的任务列表！$deviceID","获取当前设备所有的未结束的任务列表！$deviceID");
    var deviceMess ={
      'deviceid':deviceID,
    };
    HttpDioHelper helper = HttpDioHelper();
    helper.httpDioGet(url, "/RegisterPlayer/DeviceLoadProgramQuartzAllChild",body:deviceMess).then((datares) async {
      if(datares.statusCode==200){
        var res = json.decode(datares.data);
        schplanlist = res['data'];//给所有任务的总合集赋值
        if(schplanlist.length==0){
          deviceLogAdd(0,"获取当前设备未结束的任务列表为空",'获取当前设备未结束的任务列表为空');
          StorageUtil.setStringItem('huanplanlist', "");//存在缓存里
          schplanlist = [];
        }else{
          var huanplanlist = schplanlist;
          var huanplanlistStr = json.encode(huanplanlist);
          StorageUtil.setStringItem('huanplanlist', huanplanlistStr);//存在缓存里
        }
      }else{
        String huanplanlistStr = await StorageUtil.getStringItem('huanplanlist');//之前没提交成功的播放时长的集合
        if(huanplanlistStr!=""&&huanplanlistStr!="null"&&huanplanlistStr!=null){
          //如果之前不是空，则需要保存
          var messplay = json.decode(huanplanlistStr);
          schplanlist = messplay;
        }else{
          schplanlist = [];//给所有任务的总合集赋值
        }
      }
    });
  }
}
//获取当前正在进行的任务并开始播放
Future getnowpro() async{
  while(true){
    await Future.delayed(Duration(seconds: 5), (){});//等待5S
    if(schplanlist.length!=0&&schplanlist!=null){
      //任务列表有数据--任务列表  如果两个任务都应该播放，越晚创建的任务优先级越高
      var hasSchPro = 0;//0没找到正在进行的任务，1有正在进行的任务
      var palyID='0';
      var playsch = '0';
      var playproname = '';
      for(var a=0;a<schplanlist.length;a++){
        var ScheduleList = schplanlist[a]['ScheduleList'];
        int Duration = int.parse('${schplanlist[a]['Duration']}');//持续时间单位S
        if(hasSchPro==0){
          //没有正在进行的任务再去寻找要进行的任务，有了的话就不寻找了，因为列表是根据createDate的倒序排列的，越晚创建的越在前
          for(var b=0;b<ScheduleList.length;b++){
            int PlayTime = DateTime.parse('${ScheduleList[b]}').millisecondsSinceEpoch;//以毫秒为单位的时间戳
            int StopTime = PlayTime+(Duration*1000);//结束时间以毫秒为单位的时间戳
            int nowtime = getDataNowNtp().millisecondsSinceEpoch;//当前时间的时间戳
            //开始时间小于当前时间结束时间大于当前时间  正在进行
            if(PlayTime<nowtime&&StopTime>nowtime) {
              //有正在进行的任务
              hasSchPro = 1;//有正在进行的任务
              palyID = schplanlist[a]['ProgramId'];
              playsch = schplanlist[a]['ScheduleId'];
              playproname = schplanlist[a]['ProgramName'];
            }
          }
        }else {
          //已经有正在进行的任务了，就不用循环了
        }

      }

      if(hasSchPro!=0){
        //有正在播放的节目，播放当前节目
        print(playproname);//当前播放的节目的名称
        Future.delayed(Duration(seconds: 1), (){
          playscheduleproId = playsch;
          if(playproId!=palyID){
            //如果应该播放的节目的ID和正在播的不一致
            steamProplayChange(palyID,playscheduleproId);
          }
        });
      }else{
        //没有正在播放的节目要停止播放所有节目
        if(playproId!='0'){
          steamstoppro('0');//展示空白节目
        }

      }
    }else{
      //没有正在播放的节目要停止播放所有节目
      if(playproId!='0'){
        steamstoppro('0');//展示空白节目
      }
    }
    // return "";
  }
}

//比较两个日期的大小第一个值比第二个值大返回true，否则返回false
bool CompareTime(one, two) {
  DateTime? d1;
  DateTime? d2;
  if (one.runtimeType == String) {
    d1 = DateTime.parse(one);
  } else if (one.runtimeType == DateTime) {
    d1 = one;
  }
  if (two.runtimeType == String) {
    d2 = DateTime.parse(two);
  }else if (two.runtimeType==DateTime)
  {d2=two;}
  if(d1!=null&&d2!=null){
    return d2.isBefore(d1);
  }else{
    return false;
  }
}

//删除节目文件夹
Future<void> delectProFile(String ProId) async {
  deviceLogAdd(00,"删除所有节目文件夹开始","删除所有节目文件夹开始");
  mylocaPath = await findLocalPath();
  String path = '$mylocaPath';
  Directory directory = new Directory(path);
  if (directory.existsSync()) {
    // listdelect(directory);
    List<FileSystemEntity> filesone = directory.listSync();
    if('$directory'.indexOf('$playproId')>=0&&'$playproId'!='0'){
    }else{
      if (filesone.length > 0) {
        filesone.forEach((filesItem) {
          if(FileSystemEntity.isFileSync(filesItem.absolute.path)){
            filesItem.deleteSync();
          }else{
            Directory directorytwo = new Directory(filesItem.absolute.path);
            List<FileSystemEntity> filesTwo = directorytwo.listSync();
            if('$directorytwo'.indexOf('$playproId')>=0&&'$playproId'!='0'){
            }else{
              if (filesTwo.length > 0) {
                filesTwo.forEach((filesTwoItem) {
                  if(FileSystemEntity.isFileSync(filesTwoItem.absolute.path)){
                    filesTwoItem.deleteSync();
                  }else{
                    Directory directorythree = new Directory(filesTwoItem.absolute.path);
                    List<FileSystemEntity> filesThree = directorythree.listSync();
                    if('$directorythree'.indexOf('$playproId')>=0&&'$playproId'!='0'){
                    }else{
                      if(filesThree.length>0){
                        filesThree.forEach((filesThreeItem) {
                          if(FileSystemEntity.isFileSync(filesThreeItem.absolute.path)){
                            filesThreeItem.deleteSync();
                          }else{
                            Directory directoryfour = new Directory(filesThreeItem.absolute.path);
                            List<FileSystemEntity> filesfour = directoryfour.listSync();
                            if(filesfour.length>0){
                              filesfour.forEach((filesfourItem) {
                                if(FileSystemEntity.isFileSync(filesfourItem.absolute.path)){
                                  filesfourItem.deleteSync();
                                }else{
                                  Directory directoryfive = new Directory(filesfourItem.absolute.path);
                                  List<FileSystemEntity> filesfive = directoryfive.listSync();
                                  if(filesfive.length>0){
                                    filesfive.forEach((filesfiveItem) {
                                      if(FileSystemEntity.isFileSync(filesfiveItem.absolute.path)){
                                        filesfiveItem.deleteSync();
                                      }else{
                                        Directory directorysix = new Directory(filesfiveItem.absolute.path);
                                        List<FileSystemEntity> filessix = directorysix.listSync();
                                        if(filessix.length>0){
                                          filessix.forEach((filessixItem) {
                                            if(FileSystemEntity.isFileSync(filessixItem.absolute.path)){
                                              filessixItem.deleteSync();
                                            }else{
                                              Directory directoryseven = new Directory(filessixItem.absolute.path);
                                              List<FileSystemEntity> filesseven = directoryseven.listSync();
                                              if(filesseven.length>0){
                                                filesseven.forEach((filessevenItem) {
                                                  if(FileSystemEntity.isFileSync(filessevenItem.absolute.path)){
                                                    filessevenItem.deleteSync();
                                                  }else{

                                                  }
                                                });
                                              }
                                              directoryseven.deleteSync();
                                            }
                                          });
                                        }
                                        directorysix.deleteSync();
                                      }
                                    });
                                  }
                                  directoryfive.deleteSync();
                                }
                              });
                            }
                            directoryfour.deleteSync();
                          }
                        });
                      }
                      directorythree.deleteSync();
                    }
                  }
                });
              }
              directorytwo.deleteSync();
            }
          }
        });
      }
      // directory.deleteSync();
      deviceLogAdd(00,"删除所有节目文件夹完成","删除所有节目文件夹完成");
    }
  }
}
// 走判断当前存储空间的方法小于总容量的百分之5或者内存小于500M的时候添加报警日志
Future<void> initPlatformState() async {
  double? platformTotal;
  double? platformFree;
  try {
    platformTotal = await DiskSpace.getTotalDiskSpace;//当前总的存储空间
    platformFree = await DiskSpace.getFreeDiskSpace;//当前剩余的存储空间
    if(platformFree!<500){
      deviceLogAdd(0,"存储空间小于500M","存储空间小于500M");
    }
    double scale = platformFree/platformTotal!;//剩余空间占总容量的百分比
    if(scale<0.05){
      deviceLogAdd(0,"存储空间小于总容量的百分之五","存储空间小于总容量的百分之五");
    }
  } on PlatformException catch(e){
    deviceLogAdd(0, '${e.message}', '${e.message}');
    platformFree = 0;
  }
}

// 获取存储路径
Future<String> findLocalPath() async {
  // 因为Apple没有外置存储，所以第一步我们需要先对所在平台进行判断
  // 如果是android，使用getExternalStorageDirectory getTemporaryDirectory
  // 如果是iOS，使用getApplicationSupportDirectory
  // androidPath 用于存储安卓段的路径
  String androidPath = "";
  await getExternalStorageDirectory().then((f){
    print(f?.path);
    androidPath =  "${f?.path}/download";
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
    return "";
  }
}

//比较两个日期的大小第一个值比第二个值大返回true，否则返回false
bool CompareDate(one, two) {
  DateTime ?d1;
  DateTime ?d2;
  if (one.runtimeType == String) {
    d1 = DateTime.parse(one);
  } else if (one.runtimeType == DateTime) {
    d1 = one;
  }
  if (two.runtimeType == String) {
    d2 = DateTime.parse(two);
  }else if (two.runtimeType==DateTime)
  {d2=two;}
  if(d1!=null&&d2!=null) {
    return d2.isBefore(d1);
  }else{
    return false;
  }

}

//base64加密
String encodeBase64(String data){
  var content = utf8.encode(data);
  var digest = base64Encode(content);
  return digest;
}

final player = AudioPlayer();//定义一个全局的音频
//亮屏
showOpenNotification() async {
  var android = new AndroidNotificationDetails(
      'channel id', 'channel NAME',channelDescription:'channelDescription',
      priority: Priority.high,importance: Importance.max
  );
  var platform = new NotificationDetails(android:android);
  var timenow = getDataNowNtp();
  //第一个参数id，第二个参数标题，第三个参数内容
  await flutterLocalNotificationsPlugin?.show(
      -1, '标题', '内容：亮屏$timenow', platform,
      payload: '无关紧要暂时不关心这个参数');
  if(isKeptOn!=true){
    isKeptOn = true;//屏幕是否打开
    StorageUtil.setStringItem('lockstate','$isKeptOn');//开关屏的值
    deviceLogAdd(1213,"监听到已开开开屏","监听到已开开开屏！$deviceID");
    var url = 'http://$posalUrl:$posalport';
    // searchlistplayNow(url,0);//亮屏后走接口获取当前节目
    getdevschList(url);//获取当前设备未结束的所有的任务--获取所有的cron
  }
  //音乐的循环清空
  if(mymusictimer!=null){
    mymusictimer.cancel();
  }
  // player.stop();//亮屏后停止音乐的播放
}
//灭屏
showCloseNotification() async {
  var android = new AndroidNotificationDetails(
      'channel id', 'channel NAME',channelDescription:'channelDescription',
      priority: Priority.high,importance: Importance.max
  );
  var platform = new NotificationDetails(android:android);
  var timenow = getDataNowNtp();
  //第一个参数id，第二个参数标题，第三个参数内容
  await flutterLocalNotificationsPlugin?.show(
      -2, '标题', '内容：灭屏$timenow', platform,
      payload: '无关紧要暂时不关心这个参数');
  if(isKeptOn!=false){
    isKeptOn = false;//屏幕是否打开
    StorageUtil.setStringItem('lockstate','$isKeptOn');//开关屏的值
    steamstoppro('0');//暂时停止节目的播放
    deviceLogAdd(1213,"监听到已关关关屏","监听到已关关关屏！$deviceID");
  }
  //灭屏后播放循环无声音乐
  //研究重新播放----需要循环播放，播放节目有的视频音频，会停止播放------每隔多长时间循环一次重新播放
  player.setAsset(
      'files/nothing.mp3');
  player.play();
  if(mymusictimer!=null){
    mymusictimer.cancel();
  }
  mymusicTimer();//音乐的循环赋值
}
//屏幕是否是亮着的值的改变---（手动改变，以及命令改变，监听到屏幕亮灭的变化就会触发这个方法）
void keepscreenLight(staval) async{
  if(staval==1){
    if(isKeptOn!=true){
      isKeptOn = true;//屏幕是否打开
      StorageUtil.setStringItem('lockstate','$isKeptOn');//开关屏的值
      var url = 'http://$posalUrl:$posalport';
      // searchlistplayNow(url,0);//亮屏后走接口获取当前节目
      getdevschList(url);//获取当前设备未结束的所有的任务--获取所有的cron
      deviceLogAdd(1213,"监听到已开开开屏","监听到已开开开屏！$deviceID");
      //音乐的循环清空
      if(mymusictimer!=null){
        mymusictimer.cancel();
      }
      player.stop();//亮屏后停止音乐的播放
    }

  }else{
    if(isKeptOn!=false){
      isKeptOn = false;//屏幕是否打开
      StorageUtil.setStringItem('lockstate','$isKeptOn');//开关屏的值
      steamstoppro('0');//暂时停止节目的播放
      deviceLogAdd(1213,"监听到已关关关屏","监听到已关关关屏！$deviceID");
      //灭屏后播放循环无声音乐
      //研究重新播放----需要循环播放，播放节目有的视频音频，会停止播放------每隔多长时间循环一次重新播放
      player.setAsset(
          'files/nothing.mp3');
      player.play();
      if(mymusictimer!=null){
        mymusictimer.cancel();
      }
      mymusicTimer();//音乐的循环赋值
    }
  }
}
//每分钟循环如果是关屏状态，则播放无声音乐（为了保活）
void mymusicTimer() {
  const period = const Duration(seconds: 60);
  mymusictimer = Timer.periodic(period, (timer) {
    //到时回调
    if(isKeptOn==false){
      //屏幕是关闭状态
      player.setAsset(
          'files/nothing.mp3');
      player.play();
    }else{
      //屏幕是开启状态--关闭无声音乐
      player.stop();
    }
  });
}
//截图的核心代码
Future<void> myscrshotTwo() async {
  screenshotController
      .capture(delay: Duration(milliseconds: 10))
      .then((capturedImage) async {

    Uint8List? imageBytes = capturedImage;
    //压缩图片
    var compressedBytes = await FlutterImageCompress.compressWithList(
      imageBytes!,
      minHeight: 270, // 压缩高度
      minWidth: 480, // 压缩宽度
      quality: 30, // 压缩质量
      format: CompressFormat.jpeg, // 压缩格式
    );
    List<int> intimgList = compressedBytes.toList();
    var testimg= base64Encode(intimgList);
    print('获取截图…………………………………………………………………………………………');
    var sendData={
      "ClientId":deviceID,
      "DataType":3,
      "DataJson":testimg
    };
    if(certificate==1){
      var newsenddata = await jiamiasc(sendData);
      String message = encodeBase64(json.encode(newsenddata));
      publishMessage(message);
    }else{
      String message = encodeBase64(json.encode(sendData));
      publishMessage(message);
    }

  }).catchError((onError) {
    print(onError);
  });


  // final imageFile = await FlutterNativeScreenshot.takeScreenshot();//截图的临时缓存地址
  // if(imageFile!=null){
  //   Uint8List imageBytes = await File(imageFile!).readAsBytes();
  //   //压缩图片
  //   var compressedBytes = await FlutterImageCompress.compressWithList(
  //     imageBytes,
  //     minHeight: 270, // 压缩高度
  //     minWidth: 480, // 压缩宽度
  //     quality: 30, // 压缩质量
  //     format: CompressFormat.jpeg, // 压缩格式
  //   );
  //   List<int> intimgList = compressedBytes.toList();
  //   var testimg= base64Encode(intimgList);
  //   print('获取截图…………………………………………………………………………………………');
  //   var sendData={
  //     "ClientId":deviceID,
  //     "DataType":3,
  //     "DataJson":testimg
  //   };
  //   if(certificate==1){
  //     var newsenddata = await jiamiasc(sendData);
  //     String message = encodeBase64(json.encode(newsenddata));
  //     publishMessage(message);
  //   }else{
  //     String message = encodeBase64(json.encode(sendData));
  //     publishMessage(message);
  //   }
  // }

}


//测试接口的方法/存储字符串形式的json数组
pastmessExample() async{

  // var AABBCC = [
  //       {
  //         'ScheduleId':'11',
  //         'ProgramId':'22',
  //         'DeviceId':'33',
  //         'StartDate':'1694164972000',
  //         'EndDate':'1694164972442',
  //         'Duration':'442',
  //       },
  //       {
  //         'ScheduleId':'111',
  //         'ProgramId':'222',
  //         'DeviceId':'333',
  //         'StartDate':'1694164972000',
  //         'EndDate':'1694164972392',
  //         'Duration':'392',
  //       }
  // ];
  // String ABC = json.encode(AABBCC);
  // StorageUtil.setStringItem('aaa',ABC);//Token的值
  // var ABCABC = await StorageUtil.getStringItem('aaa');
  // print('${AABBCC}');
  // sendplaytimeMess();

}

//任务播放时长上传至服务器-----之前没提交成功的播放时长的提交
sendplaytimeMess() async {
  var posalUrlGetToken = 'http://$posalUrl:$posalport';
  HttpDioHelper helper = HttpDioHelper();
  //测试数据
  // var selist = [
  //   {
  //     'ScheduleId':'11',
  //     'ProgramId':'22',
  //     'DeviceId':'33',
  //     'StartDate':'1694164972000',
  //     'EndDate':'1694164972442',
  //     'Duration':'442',
  //   },
  //   {
  //     'ScheduleId':'111',
  //     'ProgramId':'222',
  //     'DeviceId':'333',
  //     'StartDate':'1694164972000',
  //     'EndDate':'1694164972392',
  //     'Duration':'392',
  //   }
  // ];


  String? playsenderrmess = await StorageUtil.getStringItem('playsenderrmess');//之前没提交成功的播放时长的集合
  if(playsenderrmess!=""&&playsenderrmess!="null"&&playsenderrmess!=null){
    //如果之前不是空，则需要保存
    var selist = json.decode(playsenderrmess);
    StorageUtil.setStringItem('playsenderrmess', '');//清空缓存里的值

    var sendmess = {
      'list':selist
    };
    helper.postUrlencodedDio(posalUrlGetToken, "/InfoPublish/RegisterPlayer/ProgramScheduleDetailSubmit",body:sendmess).then((datares) async {
      if(datares.statusCode!=200){
        //如果不等于200说明上传没有成功，则需要把失败的数据存在本地缓存中，等MQTT重新连接时一次性上传至后台
        String playsenderrmess = await StorageUtil.getStringItem('playsenderrmess');//之前没提交成功的播放时长的集合
        if(playsenderrmess!=""&&playsenderrmess!="null"&&playsenderrmess!=null){
          //如果之前不是空，则需要保存
          var messplay = json.decode(playsenderrmess);
          if(messplay.length>200){
            messplay.removeRange(0, 100);//如果超过200条，就删100条
          }
          messplay..addAll(selist);//合并之前缓存里的数组和当前上传的数组
          var messjsonNowStr = json.encode(messplay);
          StorageUtil.setStringItem('playsenderrmess', messjsonNowStr);//存在缓存里
        }
        else{
          //如果之前是空，则只需要保存本次没成功的数据
          var messplay = selist;
          var messjsonNowStr = json.encode(messplay);
          StorageUtil.setStringItem('playsenderrmess', messjsonNowStr);//存在缓存里
        }
      }
      else{
        //上传成功，保存在上传成功后的播放时长集合里
        String playsdsucmess = await StorageUtil.getStringItem('playsdsucmess');//之前提交成功的播放时长的集合
        if(playsdsucmess!=""&&playsdsucmess!="null"&&playsdsucmess!=null){
          //如果之前不是空，则需要保存
          var messplay = json.decode(playsdsucmess);
          if(messplay.length>200){
            messplay.removeRange(0, 100);//如果超过200条，就删100条
          }
          messplay..addAll(selist);//合并之前缓存里的数组和当前上传的数组
          var messjsonNowStr = json.encode(messplay);
          StorageUtil.setStringItem('playsdsucmess', messjsonNowStr);//存在缓存里
        }
        else{
          //如果之前是空，则只需要保存本次没成功的数据
          var messplay = selist;
          var messjsonNowStr = json.encode(messplay);
          StorageUtil.setStringItem('playsdsucmess', messjsonNowStr);//存在缓存里
        }
      }
    });

  }else{
    //缓存里没有则不需要上传
  }
}
