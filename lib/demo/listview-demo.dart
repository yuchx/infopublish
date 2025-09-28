import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../HttpHelper.dart';
import '../shareLocal.dart';
import '../vision_detector_views/cameraSignPart.dart';
import 'postData.dart';
import 'theme_base.dart';
import 'listDate-demo.dart';
import '../Model.dart';
import 'package:intl/intl.dart';  // 引入 intl 包来格式化日期时间

//不包含人脸签到样式的
class ComMeetDemo extends StatefulWidget {
  @override
  _ComMeetDemo createState() => _ComMeetDemo();
}
class _ComMeetDemo extends State<ComMeetDemo> {
  @override
  Widget build(BuildContext context) {
    return new TimerMeetComWidget();
  }
}
class TimerMeetComWidget extends  StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //streamMeetThing
    return StreamBuilder(
        stream: streamMeetThing.stream,
        builder:(context,snapshot){
          if(havePro!=4){
            if(haveMeet==true){
              //如果有正在进行的会议 1会议+节目  0单会议（现在需要展示会议室的二维码）  2单节目  3单会议无会议二维码（涉外版本）
              if(havePro==3){
                return commeetMess(); //有会议正在进行---长条的红色的带快速预约按钮
              }else{
                return commeetchangelenMess();//会议正在进行信息长条左边红色边框背景透明--根据模板可改变长度
              }
            }else{
              //没有正在进行的会议--空闲
              if(havePro==3){
                //单会议-无二维码
                return nomeetLenMess();//会议室空闲长条
              }else{
                return nomeetchangeLenMess();//会议室空闲长条--根据模板可变宽度
              }

            }
          }else{
            //有正在进行的会议但是没有开启签到，开启签到了以后不长这样
            if(haveMeet==true){
              if(ajaxData['CurrentopSign']=='true'){
                //开启签到
                return commeetsignMess();//开启签到后正在进行的会议的样式
              }else{
                //未开启签到
                return commeetMess(); //有会议正在进行
              }

            }else{
              return nomeetLenMess();//会议室空闲长条
            }

          }
        });



  }
}
//会议正在进行信息长条---带快速预约按钮
class commeetMess extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Positioned(
      top:ScreenUtil().setWidth(290),
      left: ScreenUtil().setWidth(0),
      height: ScreenUtil().setHeight(380),
      width: ScreenUtil().setWidth(1920),
      child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Color(0x98FF5E5E),Color(
                0x98FD8383)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          child: Row(
            mainAxisAlignment:MainAxisAlignment.start,
            crossAxisAlignment:CrossAxisAlignment.start,
            children: [
              Container(
                width: ScreenUtil().setWidth(1540),
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(90)),
                child: Column(

                  mainAxisAlignment:MainAxisAlignment.center,
                  crossAxisAlignment:CrossAxisAlignment.start,
                  children: <Widget>[
                    // SizedBox(height: ScreenUtil().setHeight(109),),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        '${ajaxData['CurrentName']}',
                        style:TextStyle(
                            fontSize: ScreenUtil().setSp(72.0),
                            color: Colors.white,
                            height:1.2,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(40),),
                    Row(
                      children: [
                        Text(
                          '${ajaxData['CurrentTime']}',
                          style:TextStyle(fontSize: ScreenUtil().setSp(32.0),color: Colors.white,fontWeight: FontWeight.bold,decoration: TextDecoration.none),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          ' / ',
                          style:TextStyle(fontSize: ScreenUtil().setSp(32.0),color: Colors.white,fontWeight: FontWeight.bold,decoration: TextDecoration.none),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          "${ajaxData['CurrentTeacher']}",
                          style:TextStyle(fontSize: ScreenUtil().setSp(32.0),color: Colors.white,height:1,decoration: TextDecoration.none),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ksOrdermeetBtn(),//快速预约
              // Container(
              //   width: ScreenUtil().setWidth(320),
              //   padding: EdgeInsets.only(top: ScreenUtil().setHeight(130)),
              //   child: Container(
              //     width: ScreenUtil().setWidth(320),
              //     height: ScreenUtil().setHeight(120),
              //     alignment: Alignment.center,
              //     decoration: BoxDecoration(
              //       border:Border.all(
              //           color: Color.fromRGBO(255, 255, 255, 1),
              //           width:ScreenUtil().setWidth(2),
              //           style: BorderStyle.solid
              //       ),
              //         borderRadius: BorderRadius.circular(16.0)
              //     ),
              //     child: Text(
              //       '正在进行',
              //       style:TextStyle(fontSize: ScreenUtil().setSp(64.0),color: Colors.white,fontWeight: FontWeight.bold,height:1,decoration: TextDecoration.none),
              //       textAlign: TextAlign.center,
              //     ),
              //   ),
              // )
            ],
          )
      ),
    );
  }

}
//会议室空闲长条
class nomeetLenMess extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Positioned(
      top:ScreenUtil().setWidth(290),
      left: ScreenUtil().setWidth(0),
      height: ScreenUtil().setHeight(380),
      width: ScreenUtil().setWidth(1920),
      child: Container(
          padding:EdgeInsets.only(left:ScreenUtil().setWidth(10)),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Color(0x992A705D),Color(
                0x99529E8A)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          child: Row(
            mainAxisAlignment:MainAxisAlignment.start,
            crossAxisAlignment:CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: ScreenUtil().setWidth(380),
              ),
              Container(
                  width: ScreenUtil().setWidth(1160),
                  height: ScreenUtil().setHeight(380),
                  alignment: Alignment.center,
                  child: Text(
                    '会议室空闲',
                    style:TextStyle(fontSize: ScreenUtil().setSp(120.0),color: Colors.white,fontWeight: FontWeight.bold,decoration: TextDecoration.none),
                    textAlign: TextAlign.center,
                  )
              ),
              ksOrdermeetBtn()
            ],
          )
      ),
    );
  }

}
//会议正在进行信息长条左边红色边框背景透明--根据模板可改变长度
class commeetchangelenMess extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Positioned(
      top:ScreenUtil().setWidth(273),
      left: ScreenUtil().setWidth(60),
      height: ScreenUtil().setHeight(434),
      width: havePro!=2?ScreenUtil().setWidth(580):ScreenUtil().setWidth(1800),
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
        child: Container(
            padding:EdgeInsets.only(left:0),
            decoration: BoxDecoration(
              border:Border(
                left: BorderSide(
                    color: Color.fromRGBO(255, 85, 85, 1),
                    width:ScreenUtil().setWidth(20),
                    style: BorderStyle.solid
                ),
              ),
              gradient: havePro!=2?LinearGradient(colors: [Color(0xFFFF5555),Color(0x00000000)], begin: FractionalOffset(0, 1), end: FractionalOffset(1, 0))
                  :LinearGradient(colors: [Color(0x66FF5555),Color(0x00000000)], begin: FractionalOffset(0, 1), end: FractionalOffset(1, 0)),
            ),
            child: Column(
              children: <Widget>[
                Container(
                  width: havePro!=2?ScreenUtil().setWidth(500):ScreenUtil().setWidth(1720),
                  margin: EdgeInsets.only(top:ScreenUtil().setHeight(40),bottom:ScreenUtil().setHeight(5),),
                  child: Text(
                    '会议进行中',
                    style:TextStyle(fontSize: ScreenUtil().setSp(32.0),color: Colors.white,fontWeight: FontWeight.bold,height:1,decoration: TextDecoration.none),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  width: havePro!=2?ScreenUtil().setWidth(500):ScreenUtil().setWidth(1720),
                  height: ScreenUtil().setHeight(200),
                  child: Center(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${ajaxData['CurrentName']}',
                        style:TextStyle(fontSize: havePro!=2?ScreenUtil().setSp(48.0):ScreenUtil().setSp(72.0),color: Colors.white,height:1.2,fontWeight: FontWeight.bold,decoration: TextDecoration.none),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: havePro!=2?ScreenUtil().setWidth(500):ScreenUtil().setWidth(1720),
                  margin: EdgeInsets.only(top:ScreenUtil().setHeight(30),bottom:ScreenUtil().setHeight(12),),
                  child: Text(
                    "预约者：${ajaxData['CurrentTeacher']}",
                    style:TextStyle(fontSize: ScreenUtil().setSp(24.0),color: Colors.white,height:1,decoration: TextDecoration.none),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  width: havePro!=2?ScreenUtil().setWidth(500):ScreenUtil().setWidth(1720),
                  child: Text(
                    '${ajaxData['CurrentTime']}',
                    style:TextStyle(fontSize: ScreenUtil().setSp(24.0),color: Colors.white,fontWeight: FontWeight.bold,decoration: TextDecoration.none),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            )
        ),
      ),
    );
  }

}

//会议室空闲长条左边框绿色背景透明--根据模板可变宽度
class nomeetchangeLenMess extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Positioned(
      top:ScreenUtil().setWidth(273),
      left: ScreenUtil().setWidth(60),
      height: ScreenUtil().setHeight(434),
      width: havePro!=2?ScreenUtil().setWidth(580):ScreenUtil().setWidth(1800),
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
        child: Container(
            padding:EdgeInsets.only(left:ScreenUtil().setWidth(10)),
            decoration: BoxDecoration(
              border:Border(
                left: BorderSide(
                    color: Color.fromRGBO(63, 194, 160, 1),
                    width:ScreenUtil().setWidth(20),
                    style: BorderStyle.solid
                ),

              ),
              gradient: havePro!=2?LinearGradient(colors: [Color(0xFF3FC2A0),Color(0x00000000)], begin: FractionalOffset(0, 1), end: FractionalOffset(1, 0)):
              LinearGradient(colors: [Color(0x663FC2A0),Color(0x00000000)], begin: FractionalOffset(0, 1), end: FractionalOffset(1, 0)),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                      '$meetName空闲中',
                      style:TextStyle(fontSize: havePro!=2?ScreenUtil().setSp(48.0):ScreenUtil().setSp(72.0),color: Colors.white,fontWeight: FontWeight.bold,decoration: TextDecoration.none),
                      textAlign: TextAlign.left,
                    )
                ),
              ],
            )
        ),
      ),
    );
  }

}


//会议正在进行-----摄像头人脸签到
class commeetsignMess extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Positioned(
      top:ScreenUtil().setWidth(132),
      left: ScreenUtil().setWidth(32),
      child:Container(
        width: ScreenUtil().setWidth(1856),
        height: ScreenUtil().setHeight(916),
        decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 0.8),
            borderRadius: BorderRadius.circular(8.0)
        ),
        child: Column(
          mainAxisAlignment:MainAxisAlignment.start,
          crossAxisAlignment:CrossAxisAlignment.start,
          children: [
            Container(
              height: ScreenUtil().setHeight(170),
              width: ScreenUtil().setWidth(1856),
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(32),right: ScreenUtil().setWidth(40)),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Color(0x98FF5E5E),Color(
                    0x98FD8383)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              ),
              child: Row(
                children: [
                  //会议相关信息
                  Container(
                    width: ScreenUtil().setWidth(1430),
                    child: Column(
                      mainAxisAlignment:MainAxisAlignment.center,
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: <Widget>[
                        // SizedBox(height: ScreenUtil().setHeight(109),),
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            '${ajaxData['CurrentName']}',
                            style:TextStyle(
                                fontSize: ScreenUtil().setSp(48.0),
                                color: Colors.white,
                                height:1.1,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(height: ScreenUtil().setHeight(16),),
                        Row(
                          children: [
                            Text(
                              '${ajaxData['CurrentTime']}',
                              style:TextStyle(fontSize: ScreenUtil().setSp(24.0),color: Colors.white,decoration: TextDecoration.none),
                              textAlign: TextAlign.left,
                            ),
                            Text(
                              ' / ',
                              style:TextStyle(fontSize: ScreenUtil().setSp(24.0),color: Colors.white,decoration: TextDecoration.none),
                              textAlign: TextAlign.left,
                            ),
                            Text(
                              "${ajaxData['CurrentTeacher']}",
                              style:TextStyle(fontSize: ScreenUtil().setSp(24.0),color: Colors.white,height:1,decoration: TextDecoration.none),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  OrderSignPeoNum(),//签到人数情况

                ],
              ),
            ),
            //签到列表
            Container(
              width: ScreenUtil().setWidth(1198),
              height: ScreenUtil().setHeight(746),
              padding: EdgeInsets.only(top: ScreenUtil().setHeight(16)),
              child: SignOrderMess(),//签到列表
            )
          ],
        ),
      ),
    );
  }

}


//快速预约btn
class ksOrdermeetBtn extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: ScreenUtil().setWidth(280),
      padding: EdgeInsets.only(top: ScreenUtil().setHeight(145)),
      child: InkWell(
        onTap: (){
          showQuickOrderAlert(1);//打开临时会议的弹窗
        },
        child: Container(
          width: ScreenUtil().setWidth(280),
          height: ScreenUtil().setHeight(90),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              border:Border.all(
                  color: Color.fromRGBO(255, 255, 255, 1),
                  width:ScreenUtil().setWidth(1),
                  style: BorderStyle.solid
              ),
              borderRadius: BorderRadius.circular(45.0)
          ),
          child: Row(
            mainAxisAlignment:MainAxisAlignment.center,
            children: [
              Container(
                width: ScreenUtil().setWidth(48),
                height: ScreenUtil().setHeight(48),
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/ksorderIcon.png'),
                      fit: BoxFit.fill,
                    )
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(20),),
              Text(
                '快速预约',
                style:TextStyle(fontSize: ScreenUtil().setSp(32.0),color: Colors.white,fontWeight: FontWeight.bold,height:1,decoration: TextDecoration.none),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }

}
var meetTitleOr = "临时会议";//快速预约的主题
FocusNode LSYYfocusNode = FocusNode();
int showQuOrderAlert = 0;//0 隐藏快速预约弹窗 1 展示快速预约会议弹窗
StreamController<String> streamQuOrderAlert= StreamController.broadcast();//开启快速预约会议弹窗
StreamController<String> streamchangeMeetTime= StreamController.broadcast();//预约会议时间
DateTime StartTimeLS = DateTime.now();//开始时间
DateTime EndTimeLS = DateTime.now();//结束时间
int chootimePN = 1;//选择哪一个时间 1开始时间 2结束时间
late FixedExtentScrollController dateController;
late FixedExtentScrollController hourController;
late FixedExtentScrollController minuteController;

late FToast fToast = FToast();//提示框相关

//计算当前时间的整十数时间点
DateTime getTenMinTime(sendtime) {
  // 获取当前时间
  // DateTime sendtime = DateTime.now();

  // 计算下一个整十分钟
  int minutes = sendtime.minute;
  int roundedMinutes = ((minutes ~/ 10) + 1) * 10;

  // 如果整十分钟大于59，则将小时加1，并将分钟设为0
  if (roundedMinutes >= 60) {
    sendtime = sendtime.add(Duration(hours: 1));
    roundedMinutes = 0;
  }

  // 创建新的时间对象
  DateTime nextRoundedTime = DateTime(
    sendtime.year,
    sendtime.month,
    sendtime.day,
    sendtime.hour,
    roundedMinutes,
  );
  // 输出结果
  print('当前时间: $sendtime');
  print('下一个整十分钟时间: $nextRoundedTime');
  return nextRoundedTime;
}

double calculateHoursDifference(DateTime dateTime1, DateTime dateTime2) {
  // 计算两个DateTime对象之间的差值（以毫秒为单位）
  int millisecondsDifference = dateTime2.millisecondsSinceEpoch - dateTime1.millisecondsSinceEpoch;

  // 将毫秒差值转换为小时数
  double hoursDifference = millisecondsDifference / (1000 * 60 * 60);

  return hoursDifference;
}

//改变临时会议弹窗的显示和隐藏
showQuickOrderAlert(val){
  print(val);
  //初始化-----改变开始时间和结束时间
  DateTime sendtime = DateTime.now();//当前时间
  StartTimeLS = getTenMinTime(sendtime);//开始时间当前时间往后的整十数分钟
  EndTimeLS = StartTimeLS.add(Duration(hours: 1));//结束时间为开始时间往后的一个小时
  if(val==1){
    showQuOrderAlert = val;
    streamQuOrderAlert.add('$showQuOrderAlert');
  }else{
    showQuOrderAlert = val;
    streamQuOrderAlert.add('$showQuOrderAlert');
  }
}
//预约会议弹窗
class QuickOrderAlert extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    fToast.init(context);//提示弹窗使用
    return StreamBuilder(
        stream: streamQuOrderAlert.stream,
        builder: (context,snapshot){
          if(showQuOrderAlert==0){
            return Container();
          }else{
            meetTitleOr = "临时会议";//快速预约的主题
            return Positioned(
              left: ScreenUtil().setWidth(0),
              right: ScreenUtil().setWidth(0),
              top: ScreenUtil().setHeight(0),
              bottom: ScreenUtil().setHeight(0),
              child:Container(
                color: Color.fromRGBO(0, 0, 0, 0.5),
                alignment: Alignment.center,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 80.0,sigmaY: 80.0),
                    child: Container(
                      width: ScreenUtil().setWidth(900),
                      height: ScreenUtil().setHeight(867),
                      decoration: BoxDecoration(
                        color:  Color.fromRGBO(255, 255, 255, 1),
                        borderRadius: new BorderRadius.all( Radius.circular(ScreenUtil().setWidth(16))),
                      ),
                      child: Column(
                        crossAxisAlignment:CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: ScreenUtil().setHeight(78),
                            padding: EdgeInsets.only(left: ScreenUtil().setWidth(40),right: ScreenUtil().setWidth(24)),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color.fromRGBO(216, 216, 216, 1),
                                  width: ScreenUtil().setWidth(1),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(
                                      '快速预约',
                                      style:TextStyle(
                                          fontSize: ScreenUtil().setSp(24.0),decoration: TextDecoration.none,color: Color.fromRGBO(47, 47, 47, 1),height: 1.25
                                      ),
                                      textAlign: TextAlign.left,
                                    )
                                ),
                                InkWell(
                                  onTap: (){
                                    showQuickOrderAlert(0);//改变临时会议弹窗的显示和隐藏
                                  },
                                  child:Container(
                                    width: ScreenUtil().setWidth(48),
                                    height: ScreenUtil().setHeight(48),
                                    padding: EdgeInsets.only(left: ScreenUtil().setWidth(16),top: ScreenUtil().setHeight(8),bottom: ScreenUtil().setHeight(8)),
                                    child: Container(
                                      width: ScreenUtil().setWidth(32),
                                      height: ScreenUtil().setHeight(32),
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage('images/closeXhui.png'),
                                            fit: BoxFit.fill,
                                          )),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: ScreenUtil().setWidth(40)),
                              child: Column(
                                crossAxisAlignment:CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: ScreenUtil().setHeight(24),),
                                  Text(
                                    '会议主题',
                                    style:TextStyle(
                                      fontSize: ScreenUtil().setSp(20.0),decoration: TextDecoration.none,color: Color.fromRGBO(47, 47, 47, 1),height: 1.25,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  SizedBox(height: ScreenUtil().setHeight(16),),
                                  Container(
                                    width: ScreenUtil().setWidth(820),
                                    alignment: Alignment.topLeft,
                                    height: ScreenUtil().setHeight(64),
                                    padding:EdgeInsets.only(left:ScreenUtil().setWidth(20)),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Color.fromRGBO(216, 216, 216, 1),
                                          width:ScreenUtil().setWidth(1),
                                          style: BorderStyle.solid
                                      ),
                                      borderRadius: new BorderRadius.all( Radius.circular(ScreenUtil().setWidth(12))),
                                    ),
                                    child: MyTextField(),//会议主题的输入框
                                  ),
                                  SizedBox(height: ScreenUtil().setHeight(20),),
                                  meetTimeTextAndKuai(),//时间的数字和时间的块
                                  SizedBox(height: ScreenUtil().setHeight(20),),
                                  changeMeetTimeBor(),//选择开始时间和结束时间
                            TimePickerchoo(),//选择时间

                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: ScreenUtil().setHeight(112),
                            decoration: BoxDecoration(
                                color:  Color.fromRGBO(244, 244, 244, 1),
                                borderRadius: new BorderRadius.only(
                                  bottomRight: Radius.circular(ScreenUtil().setWidth(12)),
                                  bottomLeft: Radius.circular(ScreenUtil().setWidth(12)),
                                )
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: ScreenUtil().setWidth(160),
                                  height: ScreenUtil().setHeight(64),
                                  decoration: BoxDecoration(
                                    borderRadius: new BorderRadius.all( Radius.circular(ScreenUtil().setWidth(16))),
                                    border: Border.all(
                                        color: Color.fromRGBO(216, 216, 216, 1),
                                        width:ScreenUtil().setWidth(1),
                                        style: BorderStyle.solid
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: (){
                                      showQuickOrderAlert(0);//改变临时会议弹窗的显示和隐藏
                                    },
                                    child:Center(
                                      child: Text(
                                        '取消',
                                        style:TextStyle(fontSize: ScreenUtil().setSp(24.0),decoration: TextDecoration.none,
                                            color: Color.fromRGBO(47, 47, 47, 1),height: 1.25),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: ScreenUtil().setWidth(24),),
                                Container(
                                  width: ScreenUtil().setWidth(160),
                                  height: ScreenUtil().setHeight(64),
                                  decoration: BoxDecoration(
                                      borderRadius: new BorderRadius.all( Radius.circular(ScreenUtil().setWidth(16))),
                                      color: Color.fromRGBO(0, 145, 255, 1)
                                  ),
                                  child: InkWell(
                                    onTap: (){
                                      if (StartTimeLS.isBefore(EndTimeLS)) {
                                        print("开始时间小于结束时间");
                                        // 计算两个DateTime对象之间的差值（以小时为单位）
                                        double hoursDifference = calculateHoursDifference(StartTimeLS, EndTimeLS);
                                        // 输出结果
                                        print('两个DateTime对象之间相差的小时数: $hoursDifference');
                                        if(hoursDifference>24){
                                          alayuAlarmtoo('images/used.png',"预约不可超过24小时！");
                                        }else{
                                          orderMeetLinshi(meetTitleOr,StartTimeLS,EndTimeLS);//临时预约
                                        }
                                      } else if (StartTimeLS.isAfter(EndTimeLS)) {
                                        print("开始时间大于结束时间");
                                        alayuAlarmtoo('images/used.png',"请选择正确的时间范围！");
                                      } else {
                                        print("开始时间和结束时间相同");
                                        alayuAlarmtoo('images/used.png',"请选择正确的时间范围！");
                                      }
                                    },
                                    child: Center(
                                      child: Text(
                                        '确定',
                                        style:TextStyle(fontSize: ScreenUtil().setSp(24.0),decoration: TextDecoration.none,
                                            color: Color.fromRGBO(255, 255, 255, 1),height: 1.25),
                                      ),
                                    ),
                                  ),
                                ),


                              ],
                            ),
                          ),
                        ],
                      ),

                    ),
                  ),
                ),
              ),


            );
          }
        });

  }
}

//会议主题输入框
class MyTextField extends StatefulWidget {
  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '$meetTitleOr');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      maxLength: 30,
      // maxLines: 1,
      focusNode: LSYYfocusNode,
      style:TextStyle(
          fontSize: ScreenUtil().setSp(24.0),
          color: Color.fromRGBO(47, 47, 47, 1),
          // height:2.66,
          fontWeight: FontWeight.w700
      ),
      // textAlign: TextAlign.left,
      textAlignVertical: TextAlignVertical.center,
      keyboardType: TextInputType.text,
      onSubmitted: (value){
        meetTitleOr = value;
      },
      decoration:InputDecoration(
        counterText: "",
        hintStyle: TextStyle(
            fontSize: ScreenUtil().setSp(24),
            color: Color.fromRGBO(255, 255, 255, 0.5),
            // height:2.66
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(255, 255, 255, 0)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(255, 255, 255, 0)),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(22)),
      ),
      onChanged: (String str){
        meetTitleOr = str;
      },

    );
  }
}
//选择开始时间和结束时间的框
class changeMeetTimeBor extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    chootimePN = 1;
    return  StreamBuilder(
        stream: streamchangeMeetTime.stream,
        builder: (context,snapshot){
          return Container(
            width: ScreenUtil().setWidth(820),
            height: ScreenUtil().setHeight(150),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DateTimeStartPicker(),//开始时间选择
                SizedBox(width: ScreenUtil().setWidth(36),),
                Container(
                  width: ScreenUtil().setWidth(48),
                  height: ScreenUtil().setHeight(48),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/opMttimeline.png'),
                        fit: BoxFit.fill,
                      )
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(36),),
                DateTimeEndPicker(),//结束时间选择
              ],
            ),
          );
        });

  }


}

//预约的开始时间
class DateTimeStartPicker extends StatefulWidget {
  @override
  _DateTimeStartPickerState createState() => _DateTimeStartPickerState();
}
//预约的开始时间
class _DateTimeStartPickerState extends State<DateTimeStartPicker> {
  Future<void> _selectDateTime(BuildContext context) async {
    // 选择日期
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      // 选择时间
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          StartTimeLS = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          streamchangeMeetTime.add("开始时间改变");//开始时间发生改变--会议占用情况发生改变
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    String nowWeekText = reWeekText('${StartTimeLS.weekday}');//周几
    String minuAddZero ='${StartTimeLS.minute}';
    if(StartTimeLS.minute<10){
      minuAddZero = '0${StartTimeLS.minute}';
    }
    return InkWell(
      onTap: (){
        FocusScope.of(context).unfocus();//输入框失去焦点
        // _selectDateTime(context);//弹出选择时间
        chootimePN=1;//改变选择的是哪个时间

        streamchangeMeetTime.add("改变选的是哪一个时间");//开始时间发生改变--会议占用情况发生改变
        if(chootimePN == 1) {
          hourController.animateToItem(
            StartTimeLS.hour,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          minuteController.animateToItem(
            StartTimeLS.minute,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          hourController.animateToItem(
            EndTimeLS.hour,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          minuteController.animateToItem(
            EndTimeLS.minute,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }

      },
      child:Container(
        width: ScreenUtil().setWidth(350),
        height: ScreenUtil().setHeight(150),
        decoration: BoxDecoration(
          color:  Color.fromRGBO(244, 244, 244, 1),
          borderRadius: new BorderRadius.all( Radius.circular(ScreenUtil().setWidth(12))),
        ),
        child: Container(
          padding: EdgeInsets.only(left: ScreenUtil().setWidth(105)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '开始',
                style:TextStyle(fontSize: ScreenUtil().setSp(18.0),decoration: TextDecoration.none,color: Color.fromRGBO(158, 158, 158, 1),height: 1.25),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: ScreenUtil().setHeight(10),),
              Text(
                '${StartTimeLS.hour}:${minuAddZero}',
                style:TextStyle(fontSize: ScreenUtil().setSp(28.0),decoration: TextDecoration.none,fontWeight: FontWeight.w700,
                    color: chootimePN==1?Color.fromRGBO(37, 139, 255, 1):Color.fromRGBO(56, 56, 56, 1),height: 1.25),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: ScreenUtil().setHeight(8),),
              Text(
                '${StartTimeLS.month}月${StartTimeLS.day}日  $nowWeekText',
                style:TextStyle(fontSize: ScreenUtil().setSp(20.0),decoration: TextDecoration.none,
                    color: chootimePN==1?Color.fromRGBO(37, 139, 255, 1):Color.fromRGBO(56, 56, 56, 1),height: 1.25),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),//开始时间选择
      ),

    );
  }
}
//预约的结束时间
class DateTimeEndPicker extends StatefulWidget {
  @override
  _DateTimeEndPickerState createState() => _DateTimeEndPickerState();
}
//预约的结束时间
class _DateTimeEndPickerState extends State<DateTimeEndPicker> {

  Future<void> _selectDateTime(BuildContext context) async {
    // 选择日期
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      // 选择时间
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          EndTimeLS = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // _selectDateTime(context)定义日期时间格式
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    String nowWeekText = reWeekText('${EndTimeLS.weekday}');//周几
    String minuAddZero ='${EndTimeLS.minute}';
    if(EndTimeLS.minute<10){
      minuAddZero = '0${EndTimeLS.minute}';
    }
    return InkWell(
      onTap: (){
        FocusScope.of(context).unfocus();//输入框失去焦点
        // _selectDateTime(context);//弹出选择时间
        chootimePN=2;//改变选择的是哪个时间
        streamchangeMeetTime.add("改变选的是哪一个时间");//开始时间发生改变--会议占用情况发生改变

        if(chootimePN == 1) {
          hourController.animateToItem(
            StartTimeLS.hour,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          minuteController.animateToItem(
            StartTimeLS.minute,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          hourController.animateToItem(
            EndTimeLS.hour,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          minuteController.animateToItem(
            EndTimeLS.minute,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }


      },
      child:
      Container(
        width: ScreenUtil().setWidth(350),
        height: ScreenUtil().setHeight(150),
        decoration: BoxDecoration(
          color:  Color.fromRGBO(244, 244, 244, 1),
          borderRadius: new BorderRadius.all( Radius.circular(ScreenUtil().setWidth(12))),
        ),
        child: Container(
          // width: ScreenUtil().setWidth(255),
          // height: ScreenUtil().setHeight(150),
          padding: EdgeInsets.only(left: ScreenUtil().setWidth(105)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '结束',
                style:TextStyle(fontSize: ScreenUtil().setSp(18.0),decoration: TextDecoration.none,color: Color.fromRGBO(158, 158, 158, 1),height: 1.25),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: ScreenUtil().setHeight(10),),
              Text(
                '${EndTimeLS.hour}:${minuAddZero}',
                style:TextStyle(fontSize: ScreenUtil().setSp(28.0),decoration: TextDecoration.none,fontWeight: FontWeight.w700,
                    color: chootimePN==2?Color.fromRGBO(37, 139, 255, 1):Color.fromRGBO(56, 56, 56, 1),height: 1.25),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: ScreenUtil().setHeight(8),),
              Text(
                '${EndTimeLS.month}月${EndTimeLS.day}日  $nowWeekText',
                style:TextStyle(fontSize: ScreenUtil().setSp(20.0),decoration: TextDecoration.none,
                    color: chootimePN==2?Color.fromRGBO(37, 139, 255, 1):Color.fromRGBO(56, 56, 56, 1),height: 1.25),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),

    );
  }
}

//会议室时间文本以及时间的块
class meetTimeTextAndKuai extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _statetimeAndkuai();
  }
}
class _statetimeAndkuai extends State<meetTimeTextAndKuai>{
  Widget meetTimeGZ() {
    List<Widget> tiles = []; // 初始化一个列表用于存放循环生成的Widget
    List<int> timetextList = []; // 定义明确的类型List<int>
    int nowtimeT = 0; // 当前开始时间的0点

    // 填充 timetextList
    for (var a = 0; a < 25; a++) {
      if (a == 24) {
        timetextList.add(a - 24);
      } else {
        timetextList.add(a);
      }
    }

    var now = DateTime.now(); // 获取当前时间
    var nowyear = now.year;
    var nowmonth = now.month;
    var nowday = now.day;
    var nowhour = now.hour;

    var sttime = StartTimeLS; // 获取开始时间
    var sttimeyear = sttime.year;
    var sttimemonth = sttime.month;
    var sttimeday = sttime.day;
    var sttimehour = sttime.hour;

    // 使用 map 来生成 tiles 列表
    timetextList.forEach((timeshowtext) {
      Color teColorofTime = Color.fromRGBO(158, 158, 158, 1);
      if (nowyear == sttimeyear &&
          nowmonth == sttimemonth &&
          nowday == sttimeday &&
          nowhour == timeshowtext) {
        teColorofTime = Color.fromRGBO(255, 125, 125, 1); // 当前时间
      }
      tiles.add(
        Container(
          width: ScreenUtil().setWidth(33),
          child: Text(
            "$timeshowtext",
            style: TextStyle(
              fontSize: ScreenUtil().setSp(16.0),
              decoration: TextDecoration.none,
              color: teColorofTime,
              height: 1.25,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      );
    });

    return Row(
      children: tiles,
    );
  }

  Widget meetTimeTC() {
    List<Widget> tiles = []; // 用于存放生成的 widgets
    DateTime pasttimenow = StartTimeLS; // 获取开始时间
    DateTime roundedTime = DateTime(pasttimenow.year, pasttimenow.month, pasttimenow.day, 0); // 设置开始时间为0点

    List<Map<String, dynamic>> schedule = [];

    // 生成 48 个时间段，每半小时一个
    int gezijg = 2;//半个小时是30--现在是2分钟
    int maxgezi = 720;//总格子数
    for (int i = 0; i < maxgezi; i++) {
      DateTime currentTime = roundedTime.add(Duration(minutes: i * gezijg));
      bool haveMeet = false;

      // 获取当前时间段的结束时间
      DateTime halfHourLater = currentTime.add(Duration(minutes: gezijg));

      var meetOrderList = ajaxData['ScheduleTable']; // 会议列表
      for (var meeting in meetOrderList) {
        DateTime arrangeMeetTime = DateTime.parse(meeting['StartTime']);
        DateTime endTime = DateTime.parse(meeting['EndTime']);

        // 判断当前时间是否在会议时间范围内
        if (currentTime.isBefore(endTime) && halfHourLater.isAfter(arrangeMeetTime)) {
          haveMeet = true;
          break;
        }
      }

      // 将时间段信息添加到 schedule 列表
      schedule.add({
        "time": currentTime.toIso8601String().substring(0, 16).replaceFirst('T', ' '),
        "haveMeet": haveMeet,
        "index": i,
      });
    }

    // 根据 schedule 生成 tiles 列表
    schedule.forEach((entry) {
      var timeshowtext = entry['time']; // 时间
      var timeindex = entry['index']; // 索引
      var timehaveMeet = entry['haveMeet']; // 是否有会议

      Color tileColor = timehaveMeet ? Color.fromRGBO(0, 145, 255, 1) : Color.fromRGBO(244, 244, 244, 1);

      // 判断是否是第一个或最后一个时间块，设置圆角
      BoxDecoration decoration = BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.horizontal(
          left: timeindex == 0 ? Radius.circular(ScreenUtil().setWidth(4)) : Radius.zero,
          right: timeindex == (maxgezi-1) ? Radius.circular(ScreenUtil().setWidth(4)) : Radius.zero,
        ),
        border: Border.all(
            color: tileColor,
            width:ScreenUtil().setWidth(0),
            style: BorderStyle.solid
        )
      );

      tiles.add(
        Container(
          width: ScreenUtil().setWidth(1.132),
          height: ScreenUtil().setHeight(24),
          decoration: decoration,
          child: Container(),
        ),
      );
    });

    // 使用 Row 来布局所有的 tiles
    return Container(
      padding: EdgeInsets.only(top:ScreenUtil().setHeight(1)),
      child: Row(
        children: tiles,
      ),
    );
  }

  //选择的开始结束时间的占用，绿色是已选择，红色是占用的
  Widget meetchooTimeTC() {
    //根据选择的开始结束时间计算位置 开始时间计算left的值，结束时间-开始时间计算宽度  半个小时是宽度17
    int strtimetiis = StartTimeLS.millisecondsSinceEpoch;
    int strtimeDay = StartTimeLS.day;//当前开始时间的day
    int strtimeHour = StartTimeLS.hour;//当前开始时间的小时
    int strtimeminu = StartTimeLS.minute;//当前开始时间的分钟
    int endtimetiis = EndTimeLS.millisecondsSinceEpoch;
    int endtimeDay = EndTimeLS.day;//当前时间的day
    int endtimeHour = EndTimeLS.hour;//当前时间的小时
    int endtimeminu = EndTimeLS.minute;//当前时间的分钟
    int chatime = endtimeHour-strtimeHour;
    //如果开始时间和结束时间不在同一天,结束时间大于开始时间
    if(strtimeDay!=endtimeDay&&endtimetiis<strtimetiis){
      //不是同一天，结束时间小于开始时间，啥都不显示
      return Container();
    }else if(strtimeDay!=endtimeDay&&endtimetiis>strtimetiis){
      endtimeHour = 24;//结束到今天的0点
      endtimeminu = 0;//结束到今天的0点
    }else if(strtimeDay==endtimeDay){
      //开始时间结束时间是同一天,正常返回
    }
    List<Widget> tiles = []; // 用于存放生成的 widgets
    DateTime pasttimenow = StartTimeLS; // 获取开始时间
    DateTime roundedTime = DateTime(pasttimenow.year, pasttimenow.month, pasttimenow.day, 0); // 设置开始时间为0点

    List<Map<String, dynamic>> schedule = [];
    int gezijg = 2;//半个小时是30--现在是一分钟
    int maxgezi = 720;//总格子数
    // 生成 48 个时间段，每半小时一个
    for (int i = 0; i < maxgezi; i++) {
      DateTime currentTime = roundedTime.add(Duration(minutes: i * gezijg));
      bool havecdMeet = false;
      // 获取当前时间段的结束时间
      DateTime halfHourLater = currentTime.add(Duration(minutes: gezijg));
      var meetOrderList = ajaxData['ScheduleTable']; // 会议列表
      for (var meeting in meetOrderList) {
        DateTime arrangeMeetTime = DateTime.parse(meeting['StartTime']);
        DateTime endTime = DateTime.parse(meeting['EndTime']);
        // 判断当前时间是否在会议时间范围内
        if (currentTime.isBefore(endTime) && halfHourLater.isAfter(arrangeMeetTime)) {
          //再判断当前时间在选择的开始结束时间范围内
          if (currentTime.isBefore(EndTimeLS) && halfHourLater.isAfter(StartTimeLS)){
            havecdMeet = true;
            break;
          }
        }
      }

      // 将时间段信息添加到 schedule 列表
      schedule.add({
        "time": currentTime.toIso8601String().substring(0, 16).replaceFirst('T', ' '),
        "havecdMeet": havecdMeet,
        "index": i,
      });
    }

    // 根据 schedule 生成 tiles 列表
    schedule.forEach((entry) {
      var timeshowtext = entry['time']; // 时间
      var timeindex = entry['index']; // 索引
      var timehavecdMeet = entry['havecdMeet']; // 是否有会议

      Color tileColor = timehavecdMeet ? Color.fromRGBO(255,119,119,1) : Colors.transparent;

      // 判断是否是第一个或最后一个时间块，设置圆角
      BoxDecoration decoration = BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.horizontal(
          left: timeindex == 0 ? Radius.circular(ScreenUtil().setWidth(4)) : Radius.zero,
          right: timeindex == (maxgezi-1) ? Radius.circular(ScreenUtil().setWidth(4)) : Radius.zero,
        ),
          border: Border.all(
              color: tileColor,
              width:ScreenUtil().setWidth(0),
              style: BorderStyle.solid
          )
      );


      tiles.add(
        Container(
          width: ScreenUtil().setWidth(1.132),
          height: ScreenUtil().setHeight(24),
          decoration: decoration,
          child: Container(),
        ),
      );
    });

    // 使用 Row 来布局所有的 tiles
    return Positioned(
        top:ScreenUtil().setHeight(1),
        left:0,
        child: Row(
          children: tiles,
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // int nowtimeHour = DateTime.now().hour;//当前时间的小时
    int nowtimeHour = StartTimeLS.hour;//当前开始时间的小时
    return StreamBuilder(
        stream: streamchangeMeetTime.stream,
        builder: (context,snapshot){
          //根据选择的开始结束时间计算位置 开始时间计算left的值，结束时间-开始时间计算宽度  半个小时是宽度17
          int strtimetiis = StartTimeLS.millisecondsSinceEpoch;
          int strtimeDay = StartTimeLS.day;//当前开始时间的day
          int strtimeHour = StartTimeLS.hour;//当前开始时间的小时
          int strtimeminu = StartTimeLS.minute;//当前开始时间的分钟
          int endtimetiis = EndTimeLS.millisecondsSinceEpoch;
          int endtimeDay = EndTimeLS.day;//当前时间的day
          int endtimeHour = EndTimeLS.hour;//当前时间的小时
          int endtimeminu = EndTimeLS.minute;//当前时间的分钟
          int chatime = endtimeHour-strtimeHour;
          // int lezhanyong = strtimeHour*17*2;//left的值
          // int widzhanyong = chatime*17*2;//width的值
          double lezhanyong = (strtimeHour*60+strtimeminu)*0.566;//left的值--
          double widzhanyong =((endtimeHour*60+endtimeminu)-(strtimeHour*60+strtimeminu))*0.566;//width的值


          //结束时间小于开始时间
          if(endtimetiis<strtimetiis){
            widzhanyong = 0;//width的值
          }else {
            //如果开始时间和结束时间不在同一天,结束时间大于开始时间
            if(strtimeDay!=endtimeDay){
              endtimeHour = 24;//结束到今天的0点
              endtimeminu = 0;//结束到今天的0点
            }
            chatime = endtimeHour-strtimeHour;
            // lezhanyong = strtimeHour*17*2;//left的值
            // widzhanyong = chatime*17*2;//width的值


            lezhanyong = (strtimeHour*60+strtimeminu)*0.566;//left的值--
            widzhanyong =((endtimeHour*60+endtimeminu)-(strtimeHour*60+strtimeminu))*0.566;//width的值

            // if(strtimeminu>29&&endtimeminu>29){
            //   //开始时间在后半个小时//结束时间在后半个小时
            //   lezhanyong = lezhanyong+17;
            // }else if(strtimeminu>29&&endtimeminu<30){
            //   //开始时间在后半个小时//结束时间在前半个小时
            //   lezhanyong = lezhanyong+17;
            //   widzhanyong = chatime*17*2-17;//width的值
            // }else if(strtimeminu<30&&endtimeminu>29){
            //   //开始时间在前半个小时//结束时间在后半个小时
            //   widzhanyong = chatime*17*2+17;//width的值
            // }else if(strtimeminu<30&&endtimeminu<30){
            //   //开始时间在前半个小时//结束时间在前半个小时-----不变
            // }
          }




          return Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                meetTimeGZ(),//时间的数字
                SizedBox(height: ScreenUtil().setHeight(8),),
                Container(
                  width: ScreenUtil().setWidth(820),
                  height: ScreenUtil().setHeight(26),
                  // color:Colors.yellow,
                  child: Stack(
                    children: [
                      meetTimeTC(),//时间的块
                      Positioned(
                        top:0,
                        left:ScreenUtil().setWidth(lezhanyong),
                          child: Container(
                            width: ScreenUtil().setWidth(widzhanyong),
                            height: ScreenUtil().setHeight(26),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(37, 243, 157, 0.2),
                                border:Border.all(
                                    color: Color.fromRGBO(37, 243, 157, 1),
                                    width:ScreenUtil().setWidth(2),
                                    style: BorderStyle.solid
                                ),
                            ),
                          )
                      ),
                      meetchooTimeTC(),//已选时间和现有时间的重叠变红
                    ],
                  )
                ),

              ],
            ),
          );
        });
  }
}



//返回周几
reWeekText(WeekDayNum){
  String WeekDayNumRead = '';
  if(WeekDayNum=="1"){
    WeekDayNumRead = '星期一';
  }else if(WeekDayNum=="2"){
    WeekDayNumRead = '星期二';
  }else if(WeekDayNum=="3"){
    WeekDayNumRead = '星期三';
  }else if(WeekDayNum=="4"){
    WeekDayNumRead = '星期四';
  }else if(WeekDayNum=="5"){
    WeekDayNumRead = '星期五';
  }else if(WeekDayNum=="6"){
    WeekDayNumRead = '星期六';
  }else if(WeekDayNum=="7"){
    WeekDayNumRead = '星期日';
  }
  return WeekDayNumRead;
}



//临时预约
orderMeetLinshi(meetTit,Stime,Etime) async {
  var posalUrlGetToken = 'http://$meetorderUrl';
  var sendTimeS ='${Stime.year}/${Stime.month}/${Stime.day} ${Stime.hour}:${Stime.minute}';
  var sendTimeE ='${Etime.year}/${Etime.month}/${Etime.day} ${Etime.hour}:${Etime.minute}';
  // 预约人姓名OrderPerson
  // 预约人电话 OrderPersonPhone
  var orderpeo = 'APP临时预约';//预约人赋值
  var mychooRoomid = ajaxDataValue['RoomId'];
  var bodySend = {
    'MeetTitle': meetTit,
    'StartTime': sendTimeS,
    'EndTime': sendTimeE,
    'RoomId': mychooRoomid,
    'OrderPerson': orderpeo,
  };
  if(mychooRoomid!=""){
    var meetTokenValue = await StorageUtil.getStringItem('meetTokenValue');
    Map<String,String> headersSend = {
      "Authorization":'$meetTokenValue'
    };
    HttpDioHelper helper = HttpDioHelper();
    helper.httpDioPost(posalUrlGetToken, "/api/TonleMeet/MeetOrderTempApp",headers:headersSend,body:bodySend).then((dataresjson) {
      if(dataresjson.statusCode!=200){
      }
      else{
        var dataNow = dataresjson.data;
        if(dataNow.indexOf('登录')>0||dataNow.indexOf('Token is null')>0){
          orderMeetLSLogin(meetTit,Stime,Etime);//Token失效了先登录再去走接口
        }else{
          var redata = json.decode(dataNow);
          if('${redata['code']}'=='200'){
            // 0预约失败 1预约成功 2会议室已被占用
            if('${redata['data']}'=='0'){
              // Fluttertoast.showToast(msg: "预约失败");
              alayuAlarmtoo('images/used.png',"预约失败！");
              deviceLogAdd(-1, '临时预约会议失败', '临时预约会议失败');
            }
            else if('${redata['data']}'=='1'){
              // Fluttertoast.showToast(msg: "预约成功");
              alayuAlarmtoo('images/canuse.png',"预约成功！");
              showQuickOrderAlert(0);//改变临时会议弹窗的显示和隐藏
              deviceLogAdd(1, '临时预约成功', '临时预约会议成功');
            }
            else if('${redata['data']}'=='2'){
              // Fluttertoast.showToast(msg: "会议室已被占用");

              alayuAlarmtoo('images/used.png',"会议室已被占用！");
              deviceLogAdd(-1,'会议室已被占用','会议室已被占用');
            }
          }else{
            // Fluttertoast.showToast(msg: "预约失败");
            alayuAlarmtoo('images/used.png',"预约失败！");

            deviceLogAdd(-1, '临时预约会议失败', '临时预约会议失败');
          }
        }

      }

    });
  }else{
    Fluttertoast.showToast(msg: "当前设备未绑定会议室");
  }

}


//临时预约--先登录
orderMeetLSLogin(meetTit,Stime,Etime) async {
  var posalUrlGetToken = 'http://$meetorderUrl';
  var userPass={
    "UserName":"admin",
    "Password":"123456"
  };
  HttpDioHelper helper = HttpDioHelper();
  helper.httpDioPost(posalUrlGetToken, "/api/TonleMeet/Login",body:userPass).then((datarlo) {
    if(datarlo.statusCode!=200){
      deviceLogAdd(-1,'会议系统登录失败','会议系统登录失败');
      Fluttertoast.showToast(msg: "屏幕登录失败");
    }
    else{
      var resjson = (datarlo.data);
      Map res = json.decode(resjson);
      if(res['code']!=200){
        deviceLogAdd(-1,'会议系统登录失败','会议系统登录失败');
        Fluttertoast.showToast(msg: "屏幕登录失败");
      }else{
        deviceLogAdd(1,'会议系统登录成功','会议系统登录成功');
        String meetTokenValueLogin = '${res['data']['Token']}';
        StorageUtil.remove('meetTokenValue');//Token的值
        StorageUtil.remove('meetTokenExpireTime');//Token的过期时间
        StorageUtil.setStringItem('meetTokenValue','${res['data']['Token']}');//Token的值
        StorageUtil.setStringItem('meetTokenExpireTime','${res['data']['ExpireTime']}');//Token的过期时间


        var sendTimeS ='${Stime.year}/${Stime.month}/${Stime.day} ${Stime.hour}:${Stime.minute}';
        var sendTimeE ='${Etime.year}/${Etime.month}/${Etime.day} ${Etime.hour}:${Etime.minute}';
        // 预约人姓名OrderPerson
        // 预约人电话 OrderPersonPhone

        var orderpeo = 'APP临时预约';//预约人赋值
        var mychooRoomid = ajaxDataValue['RoomId'];
        var bodySend = {
          'MeetTitle': meetTit,
          'StartTime': sendTimeS,
          'EndTime': sendTimeE,
          'RoomId': mychooRoomid,
          'OrderPerson': orderpeo,
        };
        Map<String,String> headersSend = {
          "Authorization":'$meetTokenValueLogin'
        };
        helper.httpDioPost(posalUrlGetToken, "/api/TonleMeet/MeetOrderTempApp",headers:headersSend,body:bodySend).then((dataresjson) {
          if(dataresjson.statusCode!=200){
          }else{
            var dataNow = dataresjson.data;
            if(dataNow.indexOf('登录')>0){
              // Fluttertoast.showToast(msg: "登录后预约失败");//登录后token还不好使
              alayuAlarmtoo('images/used.png',"登录后预约失败！");
            }else{
              var redata = json.decode(dataNow);
              if('${redata['code']}'=='200'){
                // 0预约失败 1预约成功 2会议室已被占用
                if('${redata['data']}'=='0'){
                  // Fluttertoast.showToast(msg: "预约失败");
                  alayuAlarmtoo('images/used.png',"预约失败！");
                }
                else if('${redata['data']}'=='1'){
                  // Fluttertoast.showToast(msg: "预约成功");
                  alayuAlarmtoo('images/canuse.png',"预约成功！");
                  showQuickOrderAlert(0);//改变临时会议弹窗的显示和隐藏
                }
                else if('${redata['data']}'=='2'){
                  // Fluttertoast.showToast(msg: "会议室已被占用");
                  alayuAlarmtoo('images/used.png',"会议室已被占用！");
                }
              }else{
                // Fluttertoast.showToast(msg: "预约失败");
                alayuAlarmtoo('images/used.png',"预约失败！");
              }
            }
          }
        });
      }
    }
  });
}

//下滑选择时间
// class TimePickerchoo extends StatefulWidget {
//   @override
//   _TimePickerChooState createState() => _TimePickerChooState();
// }
//
// class _TimePickerChooState extends State<TimePickerchoo> {
//   DateTime selectedDate = DateTime.now();
//   DateTime selectedDateForPicker = DateTime.now();  // 当前日期选择器用的日期
//   int selectedHour = 0;
//   int selectedMinute = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     // 计算当前日期、后一天和后两天的日期
//     List<DateTime> dateOptions = [
//       selectedDateForPicker,
//       selectedDateForPicker.add(Duration(days: 1)),
//       selectedDateForPicker.add(Duration(days: 2)),
//     ];
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(width: ScreenUtil().setWidth(115),),
//         DropdownButton<DateTime>(
//           value: selectedDateForPicker,
//           items: dateOptions.map((chdate) {
//             var nnweek = reWeekText('${chdate.weekday}');
//             String dateString = '${chdate.month}月${chdate.day}日$nnweek';
//             return DropdownMenuItem<DateTime>(
//               value: chdate,
//               child: Text(
//                 "$dateString",
//                 style: TextStyle(
//                   fontSize: ScreenUtil().setSp(24.0),
//                   decoration: TextDecoration.none,
//                   color: Color.fromRGBO(0, 145, 255, 1),
//                   height: 1.25,
//                 ),
//                 textAlign: TextAlign.left,
//               ),
//             );
//           }).toList(),
//           onChanged: (value) {
//             setState(() {
//               selectedDateForPicker = value!;
//               changeTimeofmeet(selectedDateForPicker,selectedHour,selectedMinute);//
//             });
//           },
//         ),
//
//         SizedBox(width: ScreenUtil().setWidth(90),),
//         DropdownButton<int>(
//           value: selectedHour,
//           items: List.generate(24, (index) {
//             return DropdownMenuItem<int>(
//               value: index,
//               child: Text(
//                 "$index",
//                 style: TextStyle(
//                   fontSize: ScreenUtil().setSp(24.0),
//                   decoration: TextDecoration.none,
//                   color: Color.fromRGBO(0, 145, 255, 1),
//                   height: 1.25,
//                 ),
//                 textAlign: TextAlign.left,
//               ),
//             );
//           }),
//           onChanged: (value) {
//             setState(() {
//               selectedHour = value!;
//               changeTimeofmeet(selectedDateForPicker,selectedHour,selectedMinute);//
//             });
//           },
//         ),
//
//         SizedBox(width: ScreenUtil().setWidth(90),),
//         // Minute Picker
//         DropdownButton<int>(
//           value: selectedMinute,
//           items: List.generate(60, (index) {
//             return DropdownMenuItem<int>(
//               value: index,
//               child: Text(
//                 "$index",
//                 style: TextStyle(
//                   fontSize: ScreenUtil().setSp(24.0),
//                   decoration: TextDecoration.none,
//                   color: Color.fromRGBO(0, 145, 255, 1),
//                   height: 1.25,
//                 ),
//                 textAlign: TextAlign.left,
//               ),
//             );
//           }),
//           onChanged: (value) {
//             setState(() {
//               selectedMinute = value!;
//               changeTimeofmeet(selectedDateForPicker,selectedHour,selectedMinute);//
//             });
//           },
//         ),
//       ],
//     );
//   }
// }

//实时改变选择的时间




class TimePickerchoo extends StatefulWidget {
  @override
  _TimePickerChooState createState() => _TimePickerChooState();
}

class _TimePickerChooState extends State<TimePickerchoo> {
  DateTime selectedDate = DateTime.now();
  DateTime selectedDateForPicker = DateTime.now(); // 当前日期选择器用的日期
  int selectedHour = StartTimeLS.hour;
  int selectedMinute = StartTimeLS.minute;
  int chdatenum = 0;
  int chhournum = StartTimeLS.hour;
  int chminunum = StartTimeLS.minute;


  late List<DateTime> dateOptions;
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
// 计算当前日期、后一天和后两天的日期
    dateOptions = [
      selectedDate,
      selectedDate.add(Duration(days: 1)),
      selectedDate.add(Duration(days: 2)),
    ];
    // 根据你的逻辑，计算 chdatenum、chhournum、chminunum
    if(chootimePN == 1) {
      chdatenum  = 0;                      // 假设想默认选第 1 号索引
      chhournum  = StartTimeLS.hour;       // 小时默认
      chminunum  = StartTimeLS.minute;     // 分钟默认
    } else {
      chdatenum  = 0;
      chhournum  = EndTimeLS.hour;
      chminunum  = EndTimeLS.minute;
    }
    dateController  = FixedExtentScrollController(initialItem: chdatenum);
    hourController  = FixedExtentScrollController(initialItem: chhournum);
    minuteController= FixedExtentScrollController(initialItem: chminunum);
    return Container(
      height: ScreenUtil().setHeight(240),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 使用 ListWheelScrollView 创建日期选择器
          SizedBox(width: ScreenUtil().setWidth(50)),
          Container(
            width: ScreenUtil().setWidth(280),height: ScreenUtil().setHeight(240),
            alignment: Alignment.topLeft,
            child: ListWheelScrollView.useDelegate(
              itemExtent: ScreenUtil().setHeight(80),
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedDateForPicker = dateOptions[index];
                  changeTimeofmeet(selectedDateForPicker, selectedHour, selectedMinute);
                });
              },
              controller: dateController,  // 初始项为第5项
              diameterRatio: 1.5,  // 改变列表的视锥形状
              perspective: 0.005,  // 控制透视效果
              magnification: 1.2,  // 放大比例
              useMagnifier: true,  // 启用放大效果
              overAndUnderCenterOpacity: 0.3,  // 控制透明度
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  DateTime chdate = dateOptions[index];
                  var nnweek = reWeekText('${chdate.weekday}');
                  String dateString = '${chdate.month}月${chdate.day}日 $nnweek';
                  var nnweek2 = reWeekText('${selectedDateForPicker.weekday}');
                  String dateString2 = '${selectedDateForPicker.month}月${selectedDateForPicker.day}日 $nnweek2';

                  return Container(
                    alignment: Alignment.center,
                    height: ScreenUtil().setHeight(80),
                    child: Text(
                      "$dateString",
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24.0),
                        decoration: TextDecoration.none,
                        color: dateString == dateString2?Color.fromRGBO(0, 145, 255, 1):Color.fromRGBO(56, 56, 56, 0.5),
                        height: 1.25,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  );
                },
                childCount: dateOptions.length,
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(40)),
          // 创建小时选择器
          Container(
            width: ScreenUtil().setWidth(180),height: ScreenUtil().setHeight(240),
            child: ListWheelScrollView.useDelegate(
              itemExtent: ScreenUtil().setHeight(80),
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedHour = index;
                  changeTimeofmeet(selectedDateForPicker, selectedHour, selectedMinute);
                });
              },
              controller: hourController,  // 初始项为第5项
              diameterRatio: 1.5,  // 改变列表的视锥形状
              perspective: 0.005,  // 控制透视效果
              magnification: 1.2,  // 放大比例
              useMagnifier: true,  // 启用放大效果
              overAndUnderCenterOpacity: 0.3,  // 控制透明度
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  return Container(
                    alignment: Alignment.center,
                    height: ScreenUtil().setHeight(80),
                    child: Text(
                      index<10?"0$index":"$index",
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24.0),
                        decoration: TextDecoration.none,
                        color: selectedHour == index?Color.fromRGBO(0, 145, 255, 1):Color.fromRGBO(56, 56, 56, 0.5),
                        height: 1.25,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  );
                },
                childCount: 24, // 24 小时
              ),
            ),
          ),

          SizedBox(width: ScreenUtil().setWidth(40)),
          // 创建分钟选择器
          Container(
            width: ScreenUtil().setWidth(150),height: ScreenUtil().setHeight(240),
            child: ListWheelScrollView.useDelegate(
              itemExtent: ScreenUtil().setHeight(80),
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedMinute = index;
                  changeTimeofmeet(selectedDateForPicker, selectedHour, selectedMinute);
                });
              },
              controller: minuteController,  // 初始项为第5项
              diameterRatio: 1.5,  // 改变列表的视锥形状
              perspective: 0.005,  // 控制透视效果
              magnification: 1.2,  // 放大比例
              useMagnifier: true,  // 启用放大效果
              overAndUnderCenterOpacity: 0.3,  // 控制透明度
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  return Container(
                    alignment: Alignment.center,
                    height: ScreenUtil().setHeight(80),
                    child: Text(
                      index<10?"0$index":"$index",
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24.0),
                        decoration: TextDecoration.none,
                        color: selectedMinute == index?Color.fromRGBO(0, 145, 255, 1):Color.fromRGBO(56, 56, 56, 0.5),
                        height: 1.25,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  );
                },
                childCount: 60, // 60 分钟
              ),
            ),
          ),

        ],
      ),
    );
  }
}







changeTimeofmeet(DateTime selectedDateForPicker,int hourm,int minm){
  if(chootimePN==1){
    //改变开始时间
    StartTimeLS = DateTime(
      selectedDateForPicker.year,
      selectedDateForPicker.month,
      selectedDateForPicker.day,
      hourm,
      minm,
    );
    streamchangeMeetTime.add("开始时间改变");//开始时间发生改变--会议占用情况发生改变

  }else{
    //改变结束时间
    EndTimeLS = DateTime(
      selectedDateForPicker.year,
      selectedDateForPicker.month,
      selectedDateForPicker.day,
      hourm,
      minm,
    );
    streamchangeMeetTime.add("结束时间改变");//开始时间发生改变--会议占用情况发生改变
  }
}


//横向滑块--选择时分的
class TimeSlider extends StatefulWidget {
  final TimeOfDay initialTime;
  final TimeOfDay minTime;
  final TimeOfDay maxTime;
  final ValueChanged<TimeOfDay> onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final bool showLabels;

  TimeSlider({
    super.key,
    required this.initialTime,
    this.minTime = const TimeOfDay(hour: 0, minute: 0),
    this.maxTime = const TimeOfDay(hour: 23, minute: 59),
    required this.onChanged,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.showLabels = true,
  });

  @override
  _TimeSliderState createState() => _TimeSliderState();
}

class _TimeSliderState extends State<TimeSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = _timeToMinutes(widget.initialTime).toDouble();
  }

  int _timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  TimeOfDay _minutesToTime(double minutes) {
    int total = minutes.round();
    return TimeOfDay(
      hour: total ~/ 60,
      minute: total % 60,
    );
  }

  String _formatTime(double value) {
    final time = _minutesToTime(value);
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final minMinutes = _timeToMinutes(widget.minTime);
    final maxMinutes = _timeToMinutes(widget.maxTime);

    return Column(
      children: [
        if (widget.showLabels)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTime(minMinutes.toDouble())),
                Text(_formatTime(maxMinutes.toDouble())),
              ],
            ),
          ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: widget.activeColor,
            inactiveTrackColor: widget.inactiveColor,
            thumbColor: widget.activeColor,
            overlayColor: widget.activeColor.withOpacity(0.2),
            valueIndicatorColor: widget.activeColor,
            showValueIndicator: ShowValueIndicator.always,
          ),
          child: Slider(
            min: minMinutes.toDouble(),
            max: maxMinutes.toDouble(),
            value: _currentValue.clamp(minMinutes.toDouble(), maxMinutes.toDouble()),
            divisions: (maxMinutes - minMinutes),
            label: _formatTime(_currentValue),
            onChanged: (value) {
              setState(() {
                _currentValue = value;
              });
              widget.onChanged(_minutesToTime(value));
            },
          ),
        ),
        Text(
          _formatTime(_currentValue),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: widget.activeColor,
          ),
        ),
      ],
    );
  }
}

//统一预约的弹窗
alayuAlarmtoo(iconpath,tootext){
  //提示图以及提示文本
  Widget toast = Container(
    width: ScreenUtil().setWidth(360),
    height: ScreenUtil().setHeight(100),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(ScreenUtil().setHeight(8)),
      color: Color.fromRGBO(47, 47, 47, 0.8),
    ),
    child: Row(
      mainAxisAlignment:MainAxisAlignment.center,
      crossAxisAlignment:CrossAxisAlignment.center,
      children: [
        Container(
          height: ScreenUtil().setWidth(48),
          width: ScreenUtil().setWidth(48),
          decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('$iconpath'),
                fit: BoxFit.fill,
              )
          ),
        ),
        SizedBox(
          width: ScreenUtil().setWidth(16),
        ),
        Text("$tootext",style:TextStyle(
            fontSize: ScreenUtil().setSp(24),
            color: Colors.white,
            decoration: TextDecoration.none,
            height: 1
        ),),
      ],
    ),
  );
  fToast.showToast(
    child: toast,
    gravity: ToastGravity.CENTER,
    toastDuration: Duration(milliseconds: 1500),
  );

}
