import 'dart:typed_data';

import 'package:mqtt_client/mqtt_server_client.dart';
import 'passmdtext.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'mattt_cert.dart';
import 'state/MQTTAppState.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import '../Model.dart';
import '../HttpHelper.dart';
import 'package:flutter/services.dart';
import '../shareLocal.dart';
import 'package:crypto/crypto.dart';//md5
import 'mattt_cert.dart';
var connectNum = 1;
var mytimer;//MQTT发送心跳
var mymusictimer;//每分钟循环一次播放无声音乐（保活机制有的设备息屏以后不保活）
var myContimer;//对比版本配置项
String proIdOfdownload = '0';//要下载的节目的ID
String playproId = '0';//当前播放的节目的ID
String playscheduleproId = '0';//当前播放的节目的任务ID
String playType = '0';//节目的类型（0展示空白内容，1下载节目，2播放节目，3下载并加载节目）
String locaPath = "";
int certificate = 0;//0无证书 1有证书

//连接MQTT
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

}
void getconTimer() {
  //300秒调一次，每5分钟去获取对比一次
  const period = const Duration(seconds: 300);
  myContimer = Timer.periodic(period, (timer) {
    //到时回调
    getconfigchange(1);//看看配置项有没有改变
  });
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
        deviceLogAdd(-1, 'Discovery接口${datajaon}', 'Discovery接口${datajaon}');
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
}



//截取屏幕
// ScreenshotController screenshotController = ScreenshotController();

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

  manager?.initializeMQTTClient();//安全证书的初始化  0初始化成功  !=0初始化失败
    manager?.connect();
}
void publishMessage(String text) {
  String osPrefix = 'Flutter_Android';
  manager?.publish(text);
}
class MQTTManager{
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
        // context.setAlpnProtocols(['TLSv1.0', 'TLSv1.1', 'TLSv1.2', 'TLSv12'],false);// 设置 ALPN 协议   TLS 协议  false 指示是否为服务器请求
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
    return 0;
  }
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
      //连接成功后每10秒发送一次心跳
      if(mytimer!=null){
        mytimer.cancel();
      }
      startTimer();
      var urlPlaylist = 'http://$posalUrl:$posalport';
      //走接口获取当前播放节目
      if(urlPlaylist!='http://'){
        Future.delayed(Duration(seconds: 3), (){
          //3S后去获取，确保之前缓存里的播放时长可以提交上去
          // getnowsertList(urlPlaylist);//获取当前正在播放的字幕
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
    var diskTotal = 100;//当前总的存储空间
    var diskFree = 100;//当前剩余的存储空间
    double diskPre = 0;//剩余空间占总容量的百分比
    if (diskTotal != null && diskTotal > 0 && diskFree != null) {
      diskPre = 1 - (diskFree / diskTotal);
    }
    var diskPreDou = (diskPre*100).toStringAsFixed(0);

    var memoryTotal = 100;//总物理内存
    var freememoryVal = 100;//空闲的物理内存
    double memoryPre = 1-(freememoryVal/memoryTotal);//剩余空间占总容量的百分比
    var diskPrememory = (memoryPre*100).toStringAsFixed(0);

    //看是否有deviceID
    StorageUtil.getStringItem('deviceID').then((datares) async {
      //发送过心跳
      if(datares != null){
        // print('发送注册完心跳');
        var dataJson = {
          "Memory":"$diskPrememory",
          "Disk":"$diskPreDou",
          "SysVolunme":0,
        };
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
  }
  else if('${res['DataType']}'=='4'){

  }
  else if('${res['DataType']}'=='5'){

  }
  else if('${res['DataType']}'=='7'){
    //------------进行热更新的一系列操作end---------------
  }
  else if('${res['DataType']}'=='9'){
    deviceLogAdd(9,message,"接收到插播消息的命令！$deviceID");
  }
  else if('${res['DataType']}'=='10'){


  }
  else if('${res['DataType']}'=='12'){
    //开屏
    print('----------开屏-------------');
    deviceLogAdd(12,message,"接收开屏的命令！$deviceID");
    // showOpenNotification();//开屏
  }
  else if('${res['DataType']}'=='13'){
    //关屏
    print('----------关屏-------------');
    deviceLogAdd(13,message,"接收关屏的命令！$deviceID");
    // showCloseNotification();//关屏
  }
  else if('${res['DataType']}'=='14'){
    print('停止播放节目');
    deviceLogAdd(14,message,"接收到删除节目安排的命令！$deviceID");

  }
  else if('${res['DataType']}'=='19'){
    deviceLogAdd(19,message,"接收到拉取数据的命令！$deviceID");
    getIframeConnect();//拉取数据
  }
  else if('${res['DataType']}'=='20'){

  }
  else if('${res['DataType']}'=='21'){
    //接收到删除某一个节目或者所有的节目的命令
  }
  else if('${res['DataType']}'=='22'){
    deviceLogAdd(22,message,"接收更改APP模板样式的命令！");
  }
  else if('${res['DataType']}'=='29'){
    deviceLogAdd(29,message,"接收更改终端背景的命令！");

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



