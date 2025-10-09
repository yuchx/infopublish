//import 'dart:js';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'demo/TimerWidget.dart';
import 'demo/messagePage.dart';//填写信息的页面
import 'Model.dart';
import 'demo/listview-demo.dart';
import 'demo/listDate-demo.dart';
import 'mqtt/MQTTManager.dart';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'dart:io';
//截取屏幕

//定义两个全局变量用来预约时间
var metOrderStartTime='';
var metOrderEndTime='';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(new MyApp());
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  static const platform = MethodChannel('myUsbBroReceiver');
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
                if (lastPopTime == null ||DateTime.now().difference(lastPopTime!) > Duration(seconds: 1)) {
                  lastPopTime = DateTime.now();
                  Fluttertoast.showToast(msg: '再按一次退出程序');
                  return Future.value(false);
                } else {
                  lastPopTime = DateTime.now();
                  exit(0); // 退出app
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
//  _MyHomePageState createState() => _MyHomePageState();
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
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initSetttings = new InitializationSettings(android:android);
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
                  color: Colors.white,
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
          }
          else{
            //已授权 3只加载会议--无二维码版本---1会议+节目  0单会议（现在需要展示会议室的二维码）  2单节目  3单会议无会议二维码-涉外版本
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

        });

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
          color: Colors.white,
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
                  //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14.0))),
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

