//import 'dart:js';flutter3.24.0版本
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'vision_detector_views/cameraSignPart.dart';
import 'demo/localfileUseSetting.dart';
import 'demo/myselfmarquee.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'demo/TimerWidget.dart';
import 'demo/messagePage.dart';//填写信息的页面
import 'Model.dart';
import 'demo/listview-demo.dart';
import 'demo/listDate-demo.dart';
import 'mqtt/MQTTManager.dart';
import 'shareLocal.dart';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:dio/dio.dart';

import 'dart:ui';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'dart:io';
//截取屏幕
import 'package:screenshot/screenshot.dart';

//定义两个全局变量用来预约时间
var metOrderStartTime='';
var metOrderEndTime='';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);
  runApp(new MyApp());
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    getLocalMess();//获取storage里的内容
    DateTime ?lastPopTime;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:Scaffold(
          resizeToAvoidBottomInset:false,//控制界面内容body,防止键盘弹出后页面比例改变
          backgroundColor: Colors.transparent, //把scaffold的背景色改成透明
          body:WillPopScope(
              child: MyHomePage(title: '1', key: Key('123'),),
              onWillPop: () async {
                if (Platform.isIOS) { return false; }//ios平台不支持
                if (lastPopTime == null ||DateTime.now().difference(lastPopTime!) > Duration(seconds: 1)) {
                  lastPopTime = DateTime.now();
                  Fluttertoast.showToast(msg: '再按一次退出程序');
                  return Future.value(false);
                } else {
                  lastPopTime = DateTime.now();
                  // SystemNavigator.pop();
                  exit(0); // 退出app
                  return Future.value(true);
                }
              }
          )
      ),
    );
  }
}
class MyHomePage extends StatefulWidget {
  MyHomePage({required Key key, required this.title}) : super(key: key);
  final String title;

  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver{
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);//隐藏状态栏
    initPlatSocketState();
  }
  Future<void> initPlatSocketState() async {
    if (!mounted) return;
    setState(() {
      configureindexConnect();//连接MQTT
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(1920, 1080));
    var textTitle = '$meetName';
    textTitle = isNullKong(textTitle);
    return StreamBuilder(
          stream: streamchangebg.stream,
          builder:(context,snapshot) {
            return Container(
              padding: EdgeInsets.all(0),
              decoration: BoxDecoration(
                  color:  Colors.white,
                  image: DecorationImage(
                    image: AssetImage('images/backImg.png'),
                    fit: BoxFit.fill,
                  )),
              child: Center(
                  child: StackListBottom()
              ),
            );
          }
      );
  }
}
//会议室默认名称
class meetClassName extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _statemeetClassName();
  }
}
class _statemeetClassName extends State<meetClassName>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var textTitle = '$meetName';
    textTitle = isNullKong(textTitle);
    return StreamBuilder(
        stream: streamDemo.stream,
        builder:(context,snapshot){
          return Container(
            child: Text(
              '$meetName',
              style:TextStyle(fontSize: ScreenUtil().setSp(54.0),decoration: TextDecoration.none,color: Colors.white,height: 1),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
            ),
          );
        });

  }
}
//会议室默认名称---无二维码版本用--后来更改的
class meetClassNameAfter extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _statemeetClassNameAfter();
  }
}
class _statemeetClassNameAfter extends State<meetClassNameAfter>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var textTitle = '$meetName';
    textTitle = isNullKong(textTitle);
    return StreamBuilder(
        stream: streamDemo.stream,
        builder:(context,snapshot){
          return Container(
            child: Text(
              '$meetName',
              style:TextStyle(
                  fontSize: ScreenUtil().setSp(72.0),
                  decoration: TextDecoration.none,
                  color: Color.fromRGBO(78, 78, 78, 1),
                  height: 1,
                fontWeight: FontWeight.w700
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
            ),
          );
        });

  }
}
//会议室默认名称---摄像头签到版本用--后来更改的
class meetClassNameSignTop extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _statemeetClassNameSignTop();
  }
}
class _statemeetClassNameSignTop extends State<meetClassNameSignTop>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var textTitle = '$meetName';
    textTitle = isNullKong(textTitle);
    return StreamBuilder(
        stream: streamDemo.stream,
        builder:(context,snapshot){
          return Row(
            children: [
              Icon(
                  Icons.location_pin,
                  color: havePro==4&&havesucccode==1?Colors.white:Colors.transparent,
                  size: ScreenUtil().setSp(48)
              ),
              SizedBox(width: ScreenUtil().setWidth(11),),
              Text(
                '$meetName',
                style:TextStyle(
                    fontSize: ScreenUtil().setSp(40.0),
                    decoration: TextDecoration.none,
                    color: Colors.white,
                    height: 1.25,
                    fontWeight: FontWeight.w700
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
              ),
            ],
          );
        });

  }
}





class StackListBottom extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StreamBuilder(
        stream: streamtemplate.stream,
        builder:(context,snapshot){
          if(havesucccode==0){
            //未授权
            return Stack(
              children: <Widget>[
                Positioned(
                  left:ScreenUtil().setWidth(0),
                  top: ScreenUtil().setHeight(0),
                  height: ScreenUtil().setHeight(1080),
                  width:ScreenUtil().setWidth(1920),
                  child: Container(
                    decoration: BoxDecoration(
                        color:  Colors.white,
                        image: DecorationImage(
                          image: AssetImage('images/NoAuthorize.png'),
                          fit: BoxFit.fill,
                        )
                    ),
                  ),
                ),
                Positioned(
                  left:ScreenUtil().setWidth(0),
                  // height: ScreenUtil().setHeight(90),
                  width:ScreenUtil().setWidth(1920),
                  child: Container(
                    color: Color.fromRGBO(0, 0, 0, 0),
                    padding: EdgeInsets.only(left:ScreenUtil().setWidth(60),right: ScreenUtil().setWidth(60)),
                    child:DynamicClock(),
                  ),
                ),
                //设置按钮
                Positioned(
                  left:ScreenUtil().setWidth(1840),
                  top:0,
                  height: ScreenUtil().setHeight(90),
                  width: ScreenUtil().setWidth(48),
                  child:topsetbtn(),
                ),
              ],
            );
          }else{
            //已授权
            if(havePro==3){
              //3只加载会议--无二维码版本---1会议+节目  0单会议（现在需要展示会议室的二维码）  2单节目  3单会议无会议二维码-涉外版本
              return Stack(
                children: <Widget>[
                  Positioned(
                    right:ScreenUtil().setWidth(60),
                    top: ScreenUtil().setHeight(82),
                    child: Container(
                      color: Color.fromRGBO(0, 0, 0, 0),
                      // padding: EdgeInsets.only(left:ScreenUtil().setWidth(60),right: ScreenUtil().setWidth(60)),
                      child:DynamicClock(),
                    ),
                  ),
                  Positioned(
                    top:ScreenUtil().setHeight(101),
                    left:ScreenUtil().setWidth(90),
                    height: ScreenUtil().setHeight(189),
                    width: ScreenUtil().setWidth(1200),
                    child: meetClassNameAfter(),//会议室名称,
                  ),
                  //是否有会议进行 2为不带会议
                  ComMeetDemo(),
                  //节目部分 0为不带节目 右侧二维码部分 0不带节目才显示  单会议模式显示会议室的二维码用来小程序的会议签到
                  Positioned(
                    left:ScreenUtil().setWidth(45),
                    bottom: ScreenUtil().setHeight(40),
                    width: ScreenUtil().setWidth(1820),
                    height: ScreenUtil().setHeight(330),
                    child:ListViewDataDemo(),//会议列表
                  ),
                  //设置按钮
                  Positioned(
                    left:ScreenUtil().setWidth(1840),
                    top:0,
                    height: ScreenUtil().setHeight(90),
                    width: ScreenUtil().setWidth(48),
                    child:topsetbtn(),
                  ),
                  QuickOrderAlert(),//快速预约的弹窗
                ],
              );
            }
            else if(havePro==4){
              //4 只加载会议 包含人脸签到版本
              return Stack(
                children: [
                  Positioned(
                    top:ScreenUtil().setHeight(0),
                    left:ScreenUtil().setWidth(0),
                    height: ScreenUtil().setHeight(100),
                    width: ScreenUtil().setWidth(1920),
                    child: Container(
                      color:Color.fromRGBO(0, 0, 0, 0.3),
                      padding: EdgeInsets.only(left:ScreenUtil().setWidth(62),top:ScreenUtil().setHeight(0)),
                      child: meetClassNameSignTop(),//会议室名称摄像头签到版本
                    ),
                  ),
                  Positioned(
                    right:ScreenUtil().setWidth(120),
                    top: ScreenUtil().setHeight(0),
                    child: Container(
                      child:DynamicClock(),//时钟
                    ),
                  ),
                  ComMeetDemo(),//是否有会议进行--摄像头人脸签到有区分
                  cameraSignBor(),//摄像头签到部分

                  Positioned(
                    left:ScreenUtil().setWidth(53),
                    bottom: ScreenUtil().setHeight(20),
                    width: ScreenUtil().setWidth(1820),
                    height: ScreenUtil().setHeight(320),
                    child:ListViewDataDemo(),//会议列表
                  ),
                  hotloadbor(),//热更新的弹出遮罩层
                  //设置按钮
                  Positioned(
                    left:ScreenUtil().setWidth(1840),
                    top:0,
                    height: ScreenUtil().setHeight(100),
                    width: ScreenUtil().setWidth(48),
                    child:topsetbtn(),
                  ),
                  QuickOrderAlert(),//快速预约的弹窗
                ],
              );
            }
            else{
              //1会议+节目  0单会议（现在需要展示会议室的二维码）  2单节目
              return Stack(
                children: <Widget>[
                  Positioned(
                    left:ScreenUtil().setWidth(0),
                    height: ScreenUtil().setHeight(90),
                    width: havePro==1?ScreenUtil().setWidth(670):ScreenUtil().setWidth(1920),
                    child: Container(
                      color: Color.fromRGBO(0, 0, 0, 0),
                      padding: EdgeInsets.only(left:ScreenUtil().setWidth(60),right: ScreenUtil().setWidth(60)),
                      child:DynamicClock(),
                    ),
                  ),

                  havePro==2?Container():Positioned(
                    top:ScreenUtil().setHeight(105),
                    left:ScreenUtil().setWidth(60),
                    height: ScreenUtil().setHeight(178),
                    width: ScreenUtil().setWidth(590),
                    child: Padding(
                      padding: EdgeInsets.only(left:ScreenUtil().setWidth(10),top:ScreenUtil().setHeight(47)),
                      child: meetClassName(),//会议室名称
                    ),
                  ),
                  //是否有会议进行 2为不带会议
                  havePro==2?Container():ComMeetDemo(),

                  //节目部分 0为不带节目 右侧二维码部分 0不带节目才显示  单会议模式显示会议室的二维码用来小程序的会议签到
                  havePro==0?Positioned(
                    top:ScreenUtil().setWidth(258),
                    right: ScreenUtil().setWidth(60),
                    child: Container(
                      height: ScreenUtil().setHeight(460),
                      width: ScreenUtil().setWidth(580),
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.2),
                          borderRadius: BorderRadius.circular(8.0)
                      ),
                      child: Column(
                        children: [
                          //------扫描二维码签到--------
                          SizedBox(
                            height: ScreenUtil().setHeight(90),
                          ),
                          meetRoomSighImg(),//会议室的签到二维码

                          Container(
                            height: ScreenUtil().setHeight(66),
                            width: ScreenUtil().setWidth(300),
                            child: Text('请扫描二维码进行签到',
                              style: TextStyle(fontSize: ScreenUtil().setSp(24),color: Colors.white,height: 2.75),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ):Positioned(
                    top:0,
                    left: havePro==2?ScreenUtil().setWidth(0):ScreenUtil().setWidth(670),
                    height: havePro==2?ScreenUtil().setHeight(1080):ScreenUtil().setHeight(703),
                    width: havePro==2?ScreenUtil().setWidth(1920):ScreenUtil().setWidth(1250),
                    child: Container(
                      // child: viewPart(),
                      // decoration: BoxDecoration(
                      //   // color: Color.fromRGBO(0, 0, 0, 1),
                      // ),
                    ),
                  ),
                  //右侧二维码部分上方ICON
                  havePro==0?Positioned(
                      top:ScreenUtil().setWidth(164),
                      right: ScreenUtil().setWidth(256),
                      child: Container(
                        height: ScreenUtil().setHeight(188),
                        width: ScreenUtil().setWidth(188),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('images/meetsignIcon.png'),
                              fit: BoxFit.fill,
                            )
                        ),
                      )
                  ):Container(),
                  havePro==2?Container():Positioned(
                    left:ScreenUtil().setWidth(53),
                    bottom: ScreenUtil().setHeight(20),
                    width: ScreenUtil().setWidth(1820),
                    height: ScreenUtil().setHeight(320),
                    child:ListViewDataDemo(),//会议列表
                  ),
                  //设置按钮
                  Positioned(
                    left:havePro==1?ScreenUtil().setWidth(582):ScreenUtil().setWidth(1840),
                    top:0,
                    height: ScreenUtil().setHeight(90),
                    width: ScreenUtil().setWidth(48),
                    child:topsetbtn(),
                  ),
                ],
              );
            }

          }

        });

  }

}
//会议室的签到二维码
class meetRoomSighImg extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: ScreenUtil().setHeight(300),
      width: ScreenUtil().setWidth(300),
      decoration: BoxDecoration(
          color: Colors.white
      ),
      child: StreamBuilder(
          stream: streamDemo.stream,
          builder:(context,snapshot){
            return meetRoomCodeUrl!=''?Image(
              image: NetworkImage('$meetRoomCodeUrl'),
              height: ScreenUtil().setHeight(300),
              width: ScreenUtil().setWidth(300),
            )
            :Image(
              image: AssetImage('images/nocodeImg.png'),
              height: ScreenUtil().setHeight(300),
              width: ScreenUtil().setWidth(300),
            );
          }
      ),
    );
  }

}



//热更新时弹出的遮罩层
class hotloadbor extends StatelessWidget{
  Widget build(BuildContext content){
    return StreamBuilder(
        stream: streamhotload.stream,
        builder:(context,snapshot){
          if(showhotload==1){
            //显示加载动画
            return Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 0,
              child: Container(
                color: Color.fromRGBO(24, 27, 42, 0.8),
                child: Center(
                  child: Container(
                    width: ScreenUtil().setWidth(250),
                    height: ScreenUtil().setHeight(250),
                    child: Column(
                      children: [
                        Container(
                            width: ScreenUtil().setWidth(160),
                            height: ScreenUtil().setHeight(160),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('images/hoticon.gif'),
                                  fit: BoxFit.cover,
                                )
                            )
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(26),
                        ),
                        Text('软件正在更新中,请稍后',
                          style: TextStyle(fontSize: ScreenUtil().setSp(20),color: Colors.white,height: 1),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );//更新APP的内容
          }else{
            //不显示加载动画
            return Container();
          }

        }
    );
  }
}

//设置按钮
class topsetbtn extends StatelessWidget{
  Widget build(BuildContext context) {
    // TODO: implement build
    return IconButton(
      padding: EdgeInsets.all(0),
      icon: Icon(
          Icons.settings,
          color: havePro==4&&havesucccode==1?Colors.white:Colors.transparent,
          size: ScreenUtil().setSp(48)
      ),
      tooltip: '1',
      onPressed: (){
        var passwordInput = "";
        // pastmessExample();//测试接口的方法
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  title: Row(children: <Widget>[
                    Padding(child: Text('请输入密码'), padding: EdgeInsets.only(left: ScreenUtil().setWidth(12))) ]),
                  titleTextStyle: TextStyle(color: Color.fromRGBO(69, 155, 242, 1), fontSize: ScreenUtil().setSp(40), fontWeight: FontWeight.w600,decoration: TextDecoration.none),
                  content: Container(
                    //color: Colors.yellow,
                    width:ScreenUtil().setWidth(400),
                    height:ScreenUtil().setHeight(150),
                    child: TextField(
                      keyboardType: TextInputType.numberWithOptions(),
                      obscureText:true,//隐藏输入
                      decoration:InputDecoration(
                        helperText: '请输入密码',
                      ),
                      onChanged: (String str){
                        passwordInput = str;
                      },
                    ),
                  ),
                  contentTextStyle: TextStyle(color: Colors.black,decoration: TextDecoration.none, fontSize: ScreenUtil().setSp(40), fontWeight: FontWeight.w300),
                  contentPadding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                  elevation: 10.0,
                  actions: <Widget>[
                    TextButton(child: Text("确定"), onPressed: (){
                      if(passwordInput=="1234"){
                        Navigator.of(context).pop();
                        Navigator.push(context,MaterialPageRoute(builder: (context) => TabBarControllerPage()));//跳转到填写信息的页面
                      }else{
                        Fluttertoast.showToast(msg: "密码错误");
                      }

                    }),
                    TextButton(child: Text("取消"), onPressed: () => Navigator.of(context).pop())
                  ]);
            }
        );
      },
    );
  }
}
//时间显示
class DynamicClock extends StatefulWidget {
  @override
  _DynamicClockState createState() => _DynamicClockState();
}
class _DynamicClockState extends State<DynamicClock> {
  @override
  Widget build(BuildContext context) {
    return new TimerWidget();
  }
}

