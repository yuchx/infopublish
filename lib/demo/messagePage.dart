import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../Model.dart';
import '../HttpHelper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../FileHelper.dart';
import '../mqtt/passmdtext.dart';
import '../shareLocal.dart';

import 'package:flutter/services.dart';
// import 'package:get_ip/get_ip.dart';
import '../mqtt/MQTTManager.dart';
import 'common.dart';
//获取token
getToken(url,port) async {
    var posalUrlGetToken = 'http://$url:$port';
    var userPass={
      "username":"system",
      "password":"1"
    };
    HttpDioHelper helper = HttpDioHelper();
    helper.httpDioGet(posalUrlGetToken, "/api/InfoPublish/Login",body:userPass).then((datares) {
      if(datares.statusCode==200){
        var res = (datares.data);
        deviceLogAdd(19,"获取token成功${res['data']['Token']}----${res['data']['ExpireTime']}传的","获取token成功${res['data']['Token']}---${res['data']['ExpireTime']}");
        StorageUtil.remove('TokenValue');//Token的值
        StorageUtil.remove('TokenExpireTime');//Token的过期时间
        StorageUtil.setStringItem('posalUrl', url);
        StorageUtil.setStringItem('TokenValue','${res['data']['Token']}');//Token的值
        StorageUtil.setStringItem('TokenExpireTime','${res['data']['ExpireTime']}');//Token的过期时间
        configureindexConnect();//连接MQTT
      }else{
        deviceLogAdd(-1,"获取token报400失败","获取token报400失败");
      }
    });
}
//加载设备注册接口
registerDevice(url,port,passcode,meetTextName,meetTextPreview,meeturl) async{
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
    var registerUrl = "http://"+url+":"+port;//服务器地址加端口
    var deviceIDs = DeviceInfo['DeviceId'];
    var deviceName =  DeviceInfo['DeviceName'];
    var deviceVersion = DeviceInfo['DeviceVersion'];
    var systemVersion = DeviceInfo['SystemVersion'];
    var register = (
        {
          "DeviceId":"",
          "DeviceName":deviceName,
          "IPAddress":ipAddressS,
          "MACAddress":deviceIDs,
          "MachineCode":deviceIDs,
          "SystemVersion":systemVersion,
          "DeviceType":"2",
          "DeviceVersion":deviceVersion,
          "Memory":'0',
          "DiskFreeSize":'0',
          "Location":"",
          "Width":'0',
          "Height":'0',
          "AuthorizationCode":passcode,
          "EncryptedSignatureData":"",
          "TcpClientID":"",
          "CurrentStickTime": getDataNowNtp().millisecondsSinceEpoch
        }
    );
    print(register);
    HttpDioHelper helper = HttpDioHelper();

    //passcode  自己先限制一下格式(是否是正确的时间戳加密后的格式)以及是否过期
    jiemisqcode(passcode).then((codeouttime) {
      print(codeouttime);//授权码的过期时间---现在的逻辑是以前的授权码全都废弃，用新的授权码
      int nowtimeAA = gettimeNowNtp().millisecondsSinceEpoch ~/ 1000;//当前时间的毫秒数
      if(codeouttime==""){
        //没返回过期时间说明是旧的授权码（现已经废弃）
        Fluttertoast.showToast(msg: "授权码格式不正确");
      }
      else{
        print(nowtimeAA);
        int numcodeouttime = int.parse(codeouttime);
        if(numcodeouttime<nowtimeAA){
          //过期时间小于当前时间说明已经过期
          Fluttertoast.showToast(msg: "授权码已过期");
        }else{
          //没有过期
          helper.postUrlencodedDio(registerUrl, "/InfoPublish/RegisterPlayer/Register",body:register).then((datares) {
            if(datares.statusCode!=200){
              var res = json.decode(datares.data);
              Fluttertoast.showToast(msg: "${res['info']}");
            }
            else{
              var res = json.decode(datares.data);
              Fluttertoast.showToast(msg: "${res['info']}");
              StorageUtil.remove('posalUrl');//Token的值
              StorageUtil.remove('posalport');//Token的过期时间
              StorageUtil.remove('devicecode');//Token的值
              StorageUtil.remove('meetName');//会议室默认名称
              StorageUtil.remove('deviceID');//Token的过期时间
              StorageUtil.remove('ipAddress');//Token的过期时间
              StorageUtil.remove('meetorderUrl');//会议预约地址
              StorageUtil.setStringItem('posalUrl', url);
              StorageUtil.setStringItem('posalport',port);//存储端口号
              StorageUtil.setStringItem('devicecode',passcode);//存储设备授权码
              StorageUtil.setStringItem('meetName',meetTextName);//存储设备授权码
              StorageUtil.setStringItem('meetPreview',meetTextPreview);//存储设备授权码
              StorageUtil.setStringItem('deviceID','${res['data']['DeviceId']}');//设备ID
              StorageUtil.setStringItem('ipAddress',ipAddressS);//设备ID
              StorageUtil.setStringItem('meetorderUrl',meeturl);//会议预约地址
              posalUrl = url;
              posalport = port;
              devicecode = passcode;
              meetName = meetTextName;
              meetPreview = meetTextPreview;
              meetorderUrl = meeturl;
              getToken(url,port);
              meetnamechange(meetName);//动态更改更改会议室名称
            }
          });
        }
      }
    });





  } catch(e) {
    ipAddressS = 'Failed to get ipAddress.';
    deviceLogAdd(-1,"$e",'$e');
  }
  //var response = HttpHelper.httpPost(url,"{headers: '12',body: 'body'}");
}

//会议的确定
orderMeet(a,b,c) async{
  var posalUrlGetMeet = 'http://$a';
  var userPass={
    "username":"$b",
    "password":"$c"
  };
  HttpDioHelper helper = HttpDioHelper();
  helper.httpDioGet(posalUrlGetMeet, "/Mobile/PadLogin",body:userPass).then((datares) {
    if(datares.statusCode==200){
      var res = (datares.data);
      Fluttertoast.showToast(msg: "${res['info']}");
      StorageUtil.remove('meetUrl');//Token的值
      StorageUtil.remove('meetUser');//Token的过期时间
      StorageUtil.remove('meetPassword');//Token的过期时间
      StorageUtil.setStringItem('meetUrl',a);//Token的值
      StorageUtil.setStringItem('meetUser',b);//Token的值
      StorageUtil.setStringItem('meetPassword',c);//Token的值
    }else{
      var res = (datares.data);
      Fluttertoast.showToast(msg: "${res['info']}");
    }
  });
}
//没有授权码的注册
registNocodeDevice(url,port,meetTextName,meetTextPreview,meeturl) async{
  var ipAddressS;
  var passcode = '';//授权码参数
  try {
    String ipAddressS = "";
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        ipAddressS = '${addr.address}';
        print('${addr.address}');
      }
    }
    await getDeviceInfo();
    var registerUrl = "http://"+url+":"+port;//服务器地址加端口
    var deviceIDs = DeviceInfo['DeviceId'];
    var deviceName =  DeviceInfo['DeviceName'];
    var deviceVersion = DeviceInfo['DeviceVersion'];
    var systemVersion = DeviceInfo['SystemVersion'];
    var register = (
        {
          "DeviceId":"",
          "DeviceName":deviceName,
          "IPAddress":ipAddressS,
          "MACAddress":deviceIDs,
          "MachineCode":deviceIDs,
          "SystemVersion":systemVersion,
          "DeviceType":"2",
          "DeviceVersion":deviceVersion,
          "Memory":'0',
          "DiskFreeSize":'0',
          "Location":"",
          "Width":'0',
          "Height":'0',
          "AuthorizationCode":passcode,
          "EncryptedSignatureData":"",
          "TcpClientID":"",
          "CurrentStickTime": getDataNowNtp().millisecondsSinceEpoch
        }
    );
    print(register);
    StorageUtil.remove('posalUrl');//服务器地址的值
    StorageUtil.remove('posalport');//服务器端口
    StorageUtil.remove('meetorderUrl');//会议预约服务器
    StorageUtil.setStringItem('posalUrl', url);//服务器地址的值
    StorageUtil.setStringItem('posalport',port);//服务器端口
    StorageUtil.setStringItem('meetorderUrl',meeturl);//会议预约地址
    posalUrl = url;
    posalport = port;
    meetorderUrl = meeturl;
    configureindexConnect();//连接MQTT
  } on PlatformException {
    ipAddressS = 'Failed to get ipAddress.';
  }
  //var response = HttpHelper.httpPost(url,"{headers: '12',body: 'body'}");
}

class TabBarControllerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyTabBarControllerPage();
//  _MyTabBarControllerPage createState() => _MyTabBarControllerPage();
}

class _MyTabBarControllerPage extends State<TabBarControllerPage> {
  @override
  Widget build(BuildContext context) {
    getLocalMess();

    ScreenUtil.init(context, designSize: const Size(1920, 1080));
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        // resizeToAvoidBottomPadding: false,//控制界面内容body,防止键盘弹出后页面比例改变
        //backgroundColor: Colors.transparent, //把scaffold的背景色改成透明
        resizeToAvoidBottomInset:true,
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              print('点击了返回按钮');
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            "配置页面",
            style:TextStyle(fontSize: ScreenUtil().setSp(40),color: Colors.white,decoration: TextDecoration.none),
          ),
          //backgroundColor: Color.fromRGBO(0, 0, 0, 0.5), //把appbar的背景色改成透明
          elevation: 0,//appbar的阴影
          bottom: TabBar(
            //controller: this._tabController,
            tabs: <Widget>[
              Tab(text:"配置",),
              Tab(text:"离线日志",),
              Tab(text:"播放时长统计",),
              // Tab(text:"会议配置"),
            ],
          ),
        ),
        body: TabBarView(
          //controller: this._tabController,
          children: <Widget>[
            setInforpublish(),
            offAndErrorlog(),//离线异常日志
            deviceplaytime(),//播放时长统计
            // setMeet(),
          ],
        ),
      ),
    );
  }
}
//配置信息发布地址
class setInforpublish extends StatefulWidget {
  @override
//  _setInforpublish createState() => _setInforpublish();
  State<StatefulWidget> createState() => _setInforpublish();
}
class _setInforpublish extends State<setInforpublish> {
  @override
  var url = posalUrl;
  var port = posalport;
  var passcode = devicecode;
  var meetTextName = meetName;
  var meetTextPreview = meetPreview;
  var setUpname = upanName;//U盘的名字

  var meeturl = meetorderUrl;


  Widget build(BuildContext context) {
    // TODO: implement build
    return  Container(
        padding: EdgeInsets.only(left:ScreenUtil().setWidth(60)),
        alignment: Alignment.center,
        child: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Row(
              mainAxisAlignment:MainAxisAlignment.start,//垂直方向的布局
              crossAxisAlignment:CrossAxisAlignment.start,//水平方向的布局
              children: <Widget>[
                Container(
                  child: Column(
                    mainAxisAlignment:MainAxisAlignment.start,//垂直方向的布局
                    crossAxisAlignment:CrossAxisAlignment.start,//水平方向的布局
                    children: <Widget>[
                      Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top:ScreenUtil().setHeight(30),bottom: ScreenUtil().setHeight(20)),
                          width:ScreenUtil().setWidth(1000),
                          height: ScreenUtil().setHeight(80),
                          //color: Colors.yellow,
                          child: Row(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  '服务器地址',
                                  style:TextStyle(
                                    fontSize: ScreenUtil().setSp(30.0),color: Color.fromRGBO(69, 155, 242, 1),decoration: TextDecoration.none,
                                    height: 2,
                                  ),
                                  //textAlign: TextAlign.right,
                                ),
                                width: ScreenUtil().setWidth(250),
                              ),
                              Container(
                                width: ScreenUtil().setWidth(700),
                                alignment: Alignment.topRight,
                                child:TextField(
                                  style:TextStyle(fontSize: ScreenUtil().setSp(30.0),decoration: TextDecoration.none,color: Color.fromRGBO(69, 155, 242, 1)),
                                  keyboardType: TextInputType.text,
                                  onSubmitted: (value){
                                    posalUrl = value;//服务器地址
                                    url = value;//服务器地址
                                  },
                                  decoration:InputDecoration(
                                    hintStyle: TextStyle(
                                      fontSize: ScreenUtil().setSp(40),decoration: TextDecoration.none,
                                      color: Colors.black,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:  Color.fromRGBO(69, 155, 242, 1),
                                      ),
                                    ),
                                  ),
                                  onChanged: (String str){
                                    posalUrl = str;//服务器地址
                                    url = str;//服务器地址
                                  },
                                  controller: TextEditingController.fromValue(
                                      TextEditingValue(
                                        text: url,
                                      )
                                  ),
                                ),
                              ),

                            ],
                          )
                      ),
                      Container(
                          margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
                          alignment: Alignment.center,
                          width:ScreenUtil().setWidth(1000),
                          height: ScreenUtil().setHeight(80),
                          //color: Colors.yellow,
                          child: Row(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topLeft,
                                child: Text('端口号',style:TextStyle(fontSize: ScreenUtil().setSp(30.0),decoration: TextDecoration.none,color: Color.fromRGBO(69, 155, 242, 1),
                                  height: 2,),),
                                width: ScreenUtil().setWidth(250),
                              ),
                              Container(
                                width: ScreenUtil().setWidth(700),
                                alignment: Alignment.topRight,
                                child:TextField(
                                  style:TextStyle(fontSize: ScreenUtil().setSp(30.0),decoration: TextDecoration.none,color: Color.fromRGBO(69, 155, 242, 1)),
                                  keyboardType: TextInputType.text,
                                  onSubmitted: (value){
                                    posalport = value;//端口号
                                    port = value;//端口号
                                  },
                                  decoration:InputDecoration(
                                    hintStyle: TextStyle(
                                      fontSize: ScreenUtil().setSp(40),decoration: TextDecoration.none,
                                      color: Colors.black,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:  Color.fromRGBO(69, 155, 242, 1),
                                      ),
                                    ),
                                  ),
                                  onChanged: (String str){
                                    posalport = str;//端口号
                                    port = str;//端口号
                                  },
                                  controller: TextEditingController.fromValue(
                                      TextEditingValue(
                                        text: port,
                                      )
                                  ),
                                ),
                              ),

                            ],
                          )
                      ),

                      Container(
                          margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
                          alignment: Alignment.center,
                          width:ScreenUtil().setWidth(1000),
                          height: ScreenUtil().setHeight(80),
                          //color: Colors.yellow,
                          child: Row(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  '设备授权码',
                                  style:TextStyle(
                                    fontSize: ScreenUtil().setSp(30.0),decoration: TextDecoration.none,
                                    color: Color.fromRGBO(69, 155, 242, 1),
                                    height: 2,
                                  ),
                                ),
                                width: ScreenUtil().setWidth(250),
                              ),
                              Container(
                                width: ScreenUtil().setWidth(700),
                                alignment: Alignment.topRight,
                                child: TextField(
                                  style:TextStyle(fontSize: ScreenUtil().setSp(30.0),color: Color.fromRGBO(69, 155, 242, 1),decoration: TextDecoration.none),
                                  keyboardType: TextInputType.text,
                                  decoration:InputDecoration(
                                    hintStyle: TextStyle(
                                      fontSize: ScreenUtil().setSp(40),decoration: TextDecoration.none,
                                      color: Colors.black,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:  Color.fromRGBO(69, 155, 242, 1),
                                      ),
                                    ),
                                  ),
                                  onSubmitted: (value){
                                    devicecode = value;//设备授权码
                                    passcode = value;//设备授权码
                                  },
                                  onChanged: (String str){
                                    devicecode = str;//设备授权码
                                    passcode = str;//设备授权码
                                  },
                                  controller: TextEditingController.fromValue(
                                      TextEditingValue(
                                        text: passcode,
                                      )
                                  ),
                                ),
                              ),

                            ],
                          )
                      ),
                      Container(
                          margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
                          alignment: Alignment.center,
                          width:ScreenUtil().setWidth(1000),
                          height: ScreenUtil().setHeight(80),
                          //color: Colors.yellow,
                          child: Row(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'U盘名称',
                                  style:TextStyle(
                                    fontSize: ScreenUtil().setSp(30.0),decoration: TextDecoration.none,
                                    color: Color.fromRGBO(69, 155, 242, 1),
                                    height: 2,
                                  ),
                                ),
                                width: ScreenUtil().setWidth(250),
                              ),
                              Container(
                                width: ScreenUtil().setWidth(700),
                                alignment: Alignment.topRight,
                                child: TextField(
                                  style:TextStyle(fontSize: ScreenUtil().setSp(30.0),color: Color.fromRGBO(69, 155, 242, 1),decoration: TextDecoration.none),
                                  keyboardType: TextInputType.text,
                                  decoration:InputDecoration(
                                    hintStyle: TextStyle(
                                      fontSize: ScreenUtil().setSp(40),decoration: TextDecoration.none,
                                      color: Colors.black,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:  Color.fromRGBO(69, 155, 242, 1),
                                      ),
                                    ),
                                  ),
                                  onSubmitted: (value){
                                    upanName = value;//U盘名称
                                    setUpname = value;//U盘名称
                                  },
                                  onChanged: (String str){
                                    upanName = str;//U盘名称
                                    setUpname = str;//U盘名称
                                  },
                                  controller: TextEditingController.fromValue(
                                      TextEditingValue(
                                        text: setUpname,
                                      )
                                  ),
                                ),
                              ),

                            ],
                          )
                      ),
                      Container(
                          margin: EdgeInsets.only(top:ScreenUtil().setHeight(60),bottom: ScreenUtil().setHeight(20)),
                          alignment: Alignment.center,
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: ScreenUtil().setWidth(300)),
                              TextButton(
                                  child: Text(
                                    '无码注册',
                                    style: TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(18)),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(69, 155, 242, 1)),
                                    // foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                    // padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(16)),
                                  ),
                                  onPressed: (){
                                    StorageUtil.setStringItem('upanName',setUpname);//U盘名称
                                    upanName = setUpname;//U盘名称
                                    registNocodeDevice(url,port,meetTextName,meetTextPreview,meeturl);//没有授权码的注册
                                  }
                              ),
                              SizedBox(width: ScreenUtil().setWidth(30)),
                              TextButton(
                                  child: Text(
                                    '确认',
                                    style: TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(18)),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(69, 155, 242, 1)),
                                    // foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                    // padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(16)),
                                  ),
                                  onPressed: (){
                                    StorageUtil.setStringItem('upanName',setUpname);//U盘名称
                                    upanName = setUpname;//U盘名称
                                    registerDevice(url,port,passcode,meetTextName,meetTextPreview,meeturl);//注册
                                  }
                              ),
                              SizedBox(width: ScreenUtil().setWidth(30)),
                              TextButton(
                                  child: Text(
                                    '扫码授权',
                                    style: TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(18)),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(69, 155, 242, 1)),
                                    // foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                    // padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(16)),
                                  ),
                                  onPressed: () async {
                                    StorageUtil.setStringItem('upanName',setUpname);//U盘名称
                                    upanName = setUpname;//U盘名称
                                    await getDeviceInfo();
                                    var deviceIDs = DeviceInfo['DeviceId'];
                                    var ewmtext='http://${url}:${port}/InfoPublish/RegisterPlayer/RegisterForm?MachineCode=${deviceIDs}&Key=$KeySend';
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                              title: Row(children: <Widget>[
                                                Padding(child: Text('请扫码'), padding: EdgeInsets.only(left: ScreenUtil().setWidth(12))) ]),
                                              titleTextStyle: TextStyle(color: Color.fromRGBO(69, 155, 242, 1), fontSize: ScreenUtil().setSp(40), fontWeight: FontWeight.w600,decoration: TextDecoration.none),
                                              content: //二维码
                                              Container(
                                                width: ScreenUtil().setWidth(200),
                                                height: ScreenUtil().setWidth(200),
                                                child: Center(
                                                  child: QrImage(
                                                    data: '$ewmtext',
                                                    size: ScreenUtil().setWidth(200),
                                                  ),
                                                ),
                                              ),
                                              contentTextStyle: TextStyle(color: Colors.black,decoration: TextDecoration.none, fontSize: ScreenUtil().setSp(40), fontWeight: FontWeight.w300),
                                              contentPadding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                                              elevation: 10.0,
                                              actions: <Widget>[
                                                TextButton(child: Text("确定"), onPressed: (){
                                                  Navigator.of(context).pop();

                                                }),
                                              ]);
                                        }
                                    );
                                  }
                              ),
                              // OutlinedButton(
                              //   style: OutlinedButton.styleFrom(
                              //     shape: StadiumBorder(),
                              //     side: BorderSide(color: Color.fromRGBO(69, 155, 242, 1),),
                              //   ),
                              //   onPressed: () {Navigator.of(context).pop();},
                              //   child: Text('取消'),
                              // ),
                            ],
                          )
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    mainAxisAlignment:MainAxisAlignment.start,//垂直方向的布局
                    crossAxisAlignment:CrossAxisAlignment.start,//水平方向的布局
                    children: <Widget>[
                      Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top:ScreenUtil().setHeight(30),bottom: ScreenUtil().setHeight(0)),
                          width:ScreenUtil().setWidth(850),
                          height: ScreenUtil().setHeight(80),
                          // color: Colors.yellow,
                          child: Row(
                            mainAxisAlignment:MainAxisAlignment.start,//垂直方向的布局
                            crossAxisAlignment:CrossAxisAlignment.start,//水平方向的布局
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  '会议预约地址',
                                  style:TextStyle(
                                    fontSize: ScreenUtil().setSp(30.0),decoration: TextDecoration.none,
                                    color: Color.fromRGBO(69, 155, 242, 1),
                                    height: 2,
                                  ),
                                ),
                                width: ScreenUtil().setWidth(250),
                              ),
                              Container(
                                width: ScreenUtil().setWidth(550),
                                alignment: Alignment.topRight,
                                child:TextField(
                                  style:TextStyle(fontSize: ScreenUtil().setSp(30.0),decoration: TextDecoration.none,color: Color.fromRGBO(69, 155, 242, 1)),
                                  keyboardType: TextInputType.text,
                                  onSubmitted: (value){
                                    meetorderUrl = value;//服务器地址
                                    meeturl = value;//服务器地址
                                  },
                                  decoration:InputDecoration(
                                    hintStyle: TextStyle(
                                      fontSize: ScreenUtil().setSp(40),decoration: TextDecoration.none,
                                      color: Colors.black,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:  Color.fromRGBO(69, 155, 242, 1),
                                      ),
                                    ),
                                  ),
                                  onChanged: (String str){
                                    meetorderUrl = str;//服务器地址
                                    meeturl = str;//服务器地址
                                  },
                                  controller: TextEditingController.fromValue(
                                      TextEditingValue(
                                        text: meeturl,
                                      )
                                  ),
                                ),
                              ),

                            ],
                          )
                      ),


                      Container(
                          margin: EdgeInsets.only(top:ScreenUtil().setHeight(30),bottom: ScreenUtil().setHeight(20)),
                          alignment: Alignment.center,
                          width:ScreenUtil().setWidth(850),
                          height: ScreenUtil().setHeight(80),
                          //color: Colors.yellow,
                          child: Row(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  '会议室默认名称',
                                  style:TextStyle(
                                    fontSize: ScreenUtil().setSp(30.0),decoration: TextDecoration.none,
                                    color: Color.fromRGBO(69, 155, 242, 1),
                                    height: 2,
                                  ),
                                ),
                                width: ScreenUtil().setWidth(250),
                              ),
                              Container(
                                width: ScreenUtil().setWidth(550),
                                alignment: Alignment.topRight,
                                child: TextField(
                                  style:TextStyle(fontSize: ScreenUtil().setSp(30.0),color: Color.fromRGBO(69, 155, 242, 1),decoration: TextDecoration.none),
                                  keyboardType: TextInputType.text,
                                  decoration:InputDecoration(
                                    hintStyle: TextStyle(
                                      fontSize: ScreenUtil().setSp(40),decoration: TextDecoration.none,
                                      color: Colors.black,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:  Color.fromRGBO(69, 155, 242, 1),
                                      ),
                                    ),
                                  ),
                                  onSubmitted: (value){
                                    meetName = value;
                                    meetTextName = value;
                                  },
                                  onChanged: (String str){
                                    meetName = str;//设备授权码
                                    meetTextName = str;//设备授权码
                                  },
                                  controller: TextEditingController.fromValue(
                                      TextEditingValue(
                                        text: meetTextName,
                                      )
                                  ),
                                ),
                              ),

                            ],
                          )
                      ),
                      Container(
                          margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
                          alignment: Alignment.center,
                          width:ScreenUtil().setWidth(850),
                          height: ScreenUtil().setHeight(80),
                          //color: Colors.yellow,
                          child: Row(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  '会议显示天数',
                                  style:TextStyle(
                                    fontSize: ScreenUtil().setSp(30.0),decoration: TextDecoration.none,
                                    color: Color.fromRGBO(69, 155, 242, 1),
                                    height: 2,
                                  ),
                                ),
                                width: ScreenUtil().setWidth(250),
                              ),
                              Container(
                                width: ScreenUtil().setWidth(550),
                                alignment: Alignment.topRight,
                                child: TextField(
                                  style:TextStyle(fontSize: ScreenUtil().setSp(30.0),color: Color.fromRGBO(69, 155, 242, 1),decoration: TextDecoration.none),
                                  keyboardType: TextInputType.number,
                                  decoration:InputDecoration(
                                    hintStyle: TextStyle(
                                      fontSize: ScreenUtil().setSp(40),decoration: TextDecoration.none,
                                      color: Colors.black,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:  Color.fromRGBO(69, 155, 242, 1),
                                      ),
                                    ),
                                  ),
                                  onSubmitted: (value){
                                    if(value=='0'){
                                      value='1';
                                    }
                                    if(value!=''){
                                      meetPreview = value;//会议显示天数
                                      meetTextPreview = value;//会议显示天数
                                    }
                                  },
                                  onChanged: (String str){
                                    if(str=='0'){
                                      str="1";
                                    }
                                    if(str!=""){
                                      meetPreview = str;//会议显示天数
                                      meetTextPreview = str;//会议显示天数
                                    }

                                  },
                                  controller: TextEditingController.fromValue(
                                      TextEditingValue(
                                        text: meetTextPreview,
                                      )
                                  ),
                                ),
                              ),

                            ],
                          )
                      ),
                      Container(
                          margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
                          alignment: Alignment.center,
                          width:ScreenUtil().setWidth(850),
                          height: ScreenUtil().setHeight(80),
                          //color: Colors.yellow,
                          child: Row(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  '设备标识码',
                                  style:TextStyle(
                                    fontSize: ScreenUtil().setSp(30.0),decoration: TextDecoration.none,
                                    color: Color.fromRGBO(69, 155, 242, 1),
                                    height: 2,
                                  ),
                                ),
                                width: ScreenUtil().setWidth(220),
                              ),
                              Container(
                                width: ScreenUtil().setWidth(550),
                                alignment: Alignment.topRight,
                                child: Text('${DeviceInfo['DeviceId']}',
                                  style:TextStyle(
                                    fontSize: ScreenUtil().setSp(30.0),color: Color.fromRGBO(69, 155, 242, 1),decoration: TextDecoration.none,
                                    height: 2,
                                  ),
                                ),
                              ),

                            ],
                          )



                      )
                      //设备识别码
                    ],
                  ),
                )
              ],
            )
          ],
        )
    );
  }
}

//离线日志的展示
class offAndErrorlog extends StatelessWidget{


  Widget offlogbuildGrid() {
    List<Widget> tiles = [];//先建一个数组用于存放循环生成的widget
    Widget content; //单独一个widget组件，用于返回需要生成的内容widget
    new List<Widget>.from(offlinelogList.asMap().keys.map((i) {
      var datatype = offlinelogList[i]['datatype'];//datatype
      var dataContent = '${offlinelogList[i]['dataContent']}';//dataContent
      var module = '${offlinelogList[i]['module']}';//module
      var ordernow = 1+i;
      tiles.add(
        Container(
          decoration: BoxDecoration(
            border:Border(
              bottom: BorderSide(
                  color: Color.fromRGBO(183, 194, 192, 1.0),
                  width:ScreenUtil().setWidth(2),
                  style: BorderStyle.solid
              ),
            ),
          ),
          padding: EdgeInsets.only(left: ScreenUtil().setWidth(20),right: ScreenUtil().setWidth(20),top:ScreenUtil().setHeight(5),bottom: ScreenUtil().setHeight(5)),
          child: Row(
            children: [
              Container(
                width: ScreenUtil().setWidth(100),
                child: Text('$ordernow',
                  style:TextStyle(fontSize: ScreenUtil().setSp(20.0),color: Colors.black,height:1.3,decoration: TextDecoration.none),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: ScreenUtil().setWidth(280),
                child: Text('$datatype',
                  style:TextStyle(fontSize: ScreenUtil().setSp(20.0),color: Colors.black,height:1.3,decoration: TextDecoration.none),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: ScreenUtil().setWidth(950),
                child: Text('$dataContent',
                  style:TextStyle(fontSize: ScreenUtil().setSp(20.0),color: Colors.black,height:1.3,decoration: TextDecoration.none),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: ScreenUtil().setWidth(550),
                child: Text('$module',
                  style:TextStyle(fontSize: ScreenUtil().setSp(20.0),color: Colors.black,height:1.3,decoration: TextDecoration.none),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    })
    ).toList();
    content = new Column(
        children: tiles //重点在这里，因为用编辑器写Column生成的children后面会跟一个<Widget>[]，
      //此时如果我们直接把生成的tiles放在<Widget>[]中是会报一个类型不匹配的错误，把<Widget>[]删了就可以了
    );
    return content;
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Column(
        children: [
          Container(
            height: ScreenUtil().setHeight(60),
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(20),right: ScreenUtil().setWidth(20),top:0,bottom: 0),
            decoration: BoxDecoration(
              border:Border(
                bottom: BorderSide(
                    color: Color.fromRGBO(183, 194, 192, 1.0),
                    width:ScreenUtil().setWidth(2),
                    style: BorderStyle.solid
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: ScreenUtil().setWidth(100),
                  child: Text('序号',
                    style:TextStyle(fontSize: ScreenUtil().setSp(24.0),color: Colors.black,height:1.3,fontWeight: FontWeight.bold,decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: ScreenUtil().setWidth(280),
                  child: Text('dataType',
                    style:TextStyle(fontSize: ScreenUtil().setSp(24.0),color: Colors.black,height:1.3,fontWeight: FontWeight.bold,decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: ScreenUtil().setWidth(950),
                  child: Text('dataContent',
                    style:TextStyle(fontSize: ScreenUtil().setSp(24.0),height:1.3,color: Colors.black,fontWeight: FontWeight.bold,decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: ScreenUtil().setWidth(550),
                  child: Text('module',
                    style:TextStyle(fontSize: ScreenUtil().setSp(24.0),height:1.3,color: Colors.black,fontWeight: FontWeight.bold,decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: ListView(
                padding: EdgeInsets.all(0),
                children: [
                  offlogbuildGrid()
                  // Column(
                  //   children: [
                  //     Container(
                  //       decoration: BoxDecoration(
                  //         border:Border(
                  //           bottom: BorderSide(
                  //               color: Color.fromRGBO(183, 194, 192, 1.0),
                  //               width:ScreenUtil().setWidth(2),
                  //               style: BorderStyle.solid
                  //           ),
                  //         ),
                  //       ),
                  //       padding: EdgeInsets.only(left: ScreenUtil().setWidth(20),right: ScreenUtil().setWidth(20),top:ScreenUtil().setHeight(5),bottom: ScreenUtil().setHeight(5)),
                  //       child: Row(
                  //         children: [
                  //           Container(
                  //             width: ScreenUtil().setWidth(100),
                  //             child: Text('1',
                  //               style:TextStyle(fontSize: ScreenUtil().setSp(20.0),color: Colors.black,height:1.3,decoration: TextDecoration.none),
                  //               textAlign: TextAlign.center,
                  //             ),
                  //           ),
                  //           Container(
                  //             width: ScreenUtil().setWidth(280),
                  //             child: Text('0',
                  //               style:TextStyle(fontSize: ScreenUtil().setSp(20.0),color: Colors.black,height:1.3,decoration: TextDecoration.none),
                  //               textAlign: TextAlign.center,
                  //             ),
                  //           ),
                  //           Container(
                  //             width: ScreenUtil().setWidth(950),
                  //             child: Text('dataContentdataContentdataContentdataContent',
                  //               style:TextStyle(fontSize: ScreenUtil().setSp(20.0),color: Colors.black,height:1.3,decoration: TextDecoration.none),
                  //               textAlign: TextAlign.center,
                  //             ),
                  //           ),
                  //           Container(
                  //             width: ScreenUtil().setWidth(550),
                  //             child: Text('modulemodulemodulemodulemodule',
                  //               style:TextStyle(fontSize: ScreenUtil().setSp(20.0),color: Colors.black,height:1.3,decoration: TextDecoration.none),
                  //               textAlign: TextAlign.center,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     )
                  //   ],
                  // )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
//设备上节目的播放时长

class deviceplaytime extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _devStateplaytime();
  }
}

class _devStateplaytime extends State<deviceplaytime>{
  var errorlenlist = [];//上传失败的时长
  var successlenlist = [];//上传成功的时长
  @override
  void initState(){
    super.initState();
    initsetaa();
  }
  void initsetaa() async {
    String playsenderrmess = await StorageUtil.getStringItem('playsenderrmess');//之前没提交成功的播放时长的集合
    if(playsenderrmess!=""&&playsenderrmess!="null"&&playsenderrmess!=null) {
      //如果之前不是空
      errorlenlist = json.decode(playsenderrmess);
    }
    String playsdsucmess = await StorageUtil.getStringItem('playsdsucmess');//之前没提交成功的播放时长的集合
    if(playsdsucmess!=""&&playsdsucmess!="null"&&playsdsucmess!=null) {
      //如果之前不是空
      successlenlist = json.decode(playsdsucmess);
    }
    setState(() {
    });
  }
  Widget playlenbuildGrid(){
    List<Widget> tiles = [];//先建一个数组用于存放循环生成的widget
    Widget content; //单独一个widget组件，用于返回需要生成的内容widget
    var newsendlist = [];
    // newsendlist..addAll(successlenlist);//合并数组
    // newsendlist..addAll(errorlenlist);//合并数组
    // if(newsendlist.length>0){
    //   newsendlist.sort((a, b) => a['EndDate'].compareTo(b['EndDate']));
    // }


    new List<Widget>.from(errorlenlist.asMap().keys.map((x) {
      var ScheduleId = errorlenlist[x]['ScheduleId'];//datatype
      var ProgramId = '${errorlenlist[x]['ProgramId']}';//dataContent
      var StartDate = '${errorlenlist[x]['StartDate']}';//module
      var EndDate = '${errorlenlist[x]['EndDate']}';//module
      var Duration = '${errorlenlist[x]['Duration']}';//module
      //没有上报成功的播放时长
      newsendlist.add({
        'ScheduleId':ScheduleId,
        'ProgramId':ProgramId,
        'StartDate':StartDate,
        'EndDate':EndDate,
        'Duration':Duration,
        'state':0,//上报失败的是0
      });

    })
    ).toList();
    new List<Widget>.from(successlenlist.asMap().keys.map((y) {
      var ScheduleId = successlenlist[y]['ScheduleId'];//datatype
      var ProgramId = '${successlenlist[y]['ProgramId']}';//dataContent
      var StartDate = '${successlenlist[y]['StartDate']}';//module
      var EndDate = '${successlenlist[y]['EndDate']}';//module
      var Duration = '${successlenlist[y]['Duration']}';//module
      //没有上报成功的播放时长
      newsendlist.add({
        'ScheduleId':ScheduleId,
        'ProgramId':ProgramId,
        'StartDate':StartDate,
        'EndDate':EndDate,
        'Duration':Duration,
        'state':1,//上报失败的是0
      });

    })
    ).toList();
    if(newsendlist.length>0){
      newsendlist.sort((a, b) => b['EndDate'].compareTo(a['EndDate']));
    }
    print(newsendlist);

    new List<Widget>.from(newsendlist.asMap().keys.map((a) {
      var ScheduleId = newsendlist[a]['ScheduleId'];//datatype
      var ProgramId = '${newsendlist[a]['ProgramId']}';//dataContent
      var StartDateA = '${newsendlist[a]['StartDate']}';//module
      var EndDateA = '${newsendlist[a]['EndDate']}';//module
      var Duration = '${newsendlist[a]['Duration']}';//module
      var state = '${newsendlist[a]['state']}';//module
      int StartDateB = int.parse(StartDateA);
      int EndDateB = int.parse(EndDateA);
      // 将时间戳转换为 DateTime 对象
      DateTime StartDateC = DateTime.fromMillisecondsSinceEpoch(StartDateB);
      DateTime EndDateC = DateTime.fromMillisecondsSinceEpoch(EndDateB);
      if(ScheduleId=='0'){
        ScheduleId ='当前无任务';
      }
      if(ProgramId=='0'){
        ProgramId ='当前无节目';
      }
      // 格式化时间
      String StartDate = '${StartDateC.year}/${StartDateC.month}/${StartDateC.day} ${pad0(StartDateC.hour)}:${pad0(StartDateC.minute)}:${pad0(StartDateC.second)}';
      String EndDate = '${EndDateC.year}/${EndDateC.month}/${EndDateC.day} ${pad0(EndDateC.hour)}:${pad0(EndDateC.minute)}:${pad0(EndDateC.second)}';
      if(state=='1'){
        tiles.add(
          Container(
            decoration: BoxDecoration(
              border:Border(
                bottom: BorderSide(
                    color: Color.fromRGBO(183, 194, 192, 1.0),
                    width:ScreenUtil().setWidth(2),
                    style: BorderStyle.solid
                ),
              ),
            ),
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(20),right: ScreenUtil().setWidth(20),top:ScreenUtil().setHeight(5),bottom: ScreenUtil().setHeight(5)),
            child: Row(
              children: [
                Container(
                  width: ScreenUtil().setWidth(356),
                  child: Text('$ScheduleId',
                    style:TextStyle(fontSize: ScreenUtil().setSp(20.0),color: Colors.black,height:1.3,decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: ScreenUtil().setWidth(356),
                  child: Text('$ProgramId',
                    style:TextStyle(fontSize: ScreenUtil().setSp(20.0),color: Colors.black,height:1.3,decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: ScreenUtil().setWidth(356),
                  child: Text('$StartDate $StartDateA',
                    style:TextStyle(fontSize: ScreenUtil().setSp(20.0),color: Colors.black,height:1.3,decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: ScreenUtil().setWidth(356),
                  child: Text('$EndDate $EndDateA',
                    style:TextStyle(fontSize: ScreenUtil().setSp(20.0),color: Colors.black,height:1.3,decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: ScreenUtil().setWidth(356),
                  child: Text('$Duration',
                    style:TextStyle(fontSize: ScreenUtil().setSp(20.0),color: Colors.black,height:1.3,decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      }else{
        tiles.add(
          Container(
            decoration: BoxDecoration(
              border:Border(
                bottom: BorderSide(
                    color: Color.fromRGBO(183, 194, 192, 1.0),
                    width:ScreenUtil().setWidth(2),
                    style: BorderStyle.solid
                ),
              ),
            ),
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(20),right: ScreenUtil().setWidth(20),top:ScreenUtil().setHeight(5),bottom: ScreenUtil().setHeight(5)),
            child: Row(
              children: [
                Container(
                  width: ScreenUtil().setWidth(356),
                  child: Text('$ScheduleId',
                    style:TextStyle(fontSize: ScreenUtil().setSp(20.0),color: Colors.red,height:1.3,decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: ScreenUtil().setWidth(356),
                  child: Text('$ProgramId',
                    style:TextStyle(fontSize: ScreenUtil().setSp(20.0),color: Colors.red,height:1.3,decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: ScreenUtil().setWidth(356),
                  child: Text('$StartDate $StartDateA',
                    style:TextStyle(fontSize: ScreenUtil().setSp(20.0),color: Colors.red,height:1.3,decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: ScreenUtil().setWidth(356),
                  child: Text('$EndDate $EndDateA',
                    style:TextStyle(fontSize: ScreenUtil().setSp(20.0),color: Colors.red,height:1.3,decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: ScreenUtil().setWidth(356),
                  child: Text('$Duration',
                    style:TextStyle(fontSize: ScreenUtil().setSp(20.0),color: Colors.red,height:1.3,decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      }

    })
    ).toList();

    content = new Column(
        children: tiles //重点在这里，因为用编辑器写Column生成的children后面会跟一个<Widget>[]，
      //此时如果我们直接把生成的tiles放在<Widget>[]中是会报一个类型不匹配的错误，把<Widget>[]删了就可以了
    );
    return content;

  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build


    return Container(
      child: Column(
        children: [
          Container(
            height: ScreenUtil().setHeight(60),
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(20),right: ScreenUtil().setWidth(20),top:0,bottom: 0),
            decoration: BoxDecoration(
              border:Border(
                bottom: BorderSide(
                    color: Color.fromRGBO(183, 194, 192, 1.0),
                    width:ScreenUtil().setWidth(2),
                    style: BorderStyle.solid
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: ScreenUtil().setWidth(356),
                  child: Text('计划id',
                    style:TextStyle(fontSize: ScreenUtil().setSp(24.0),color: Colors.black,height:1.3,fontWeight: FontWeight.bold,decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: ScreenUtil().setWidth(356),
                  child: Text('节目ID',
                    style:TextStyle(fontSize: ScreenUtil().setSp(24.0),color: Colors.black,height:1.3,fontWeight: FontWeight.bold,decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: ScreenUtil().setWidth(356),
                  child: Text('开始时间',
                    style:TextStyle(fontSize: ScreenUtil().setSp(24.0),height:1.3,color: Colors.black,fontWeight: FontWeight.bold,decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: ScreenUtil().setWidth(356),
                  child: Text('结束时间',
                    style:TextStyle(fontSize: ScreenUtil().setSp(24.0),height:1.3,color: Colors.black,fontWeight: FontWeight.bold,decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: ScreenUtil().setWidth(356),
                  child: Text('持续时间（ms）',
                    style:TextStyle(fontSize: ScreenUtil().setSp(24.0),height:1.3,color: Colors.black,fontWeight: FontWeight.bold,decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: ListView(
                padding: EdgeInsets.all(0),
                children: [
                  playlenbuildGrid()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

