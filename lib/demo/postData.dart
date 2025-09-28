import 'dart:convert';

import 'package:flutter/material.dart';
import '../Model.dart';
import '../dataValUse.dart';
import 'chanOfYisheng.dart';
//数据更新
runMeet() {
  var meetList = [];
  var ScheduleTable = ajaxData['ScheduleTable'];

  ajaxData['RoomName'] = ajaxData['RoomName'];
  //print(jsonEncode(ScheduleTable));
  final beforeHaveMeet = '$haveMeet';
  final beforeComOrderId = '${ajaxData['CurrentOrderId']}';
  //streamMeetThing
  var nowDate = getDataNowNtp();
  if (isNull(ScheduleTable)) {
    haveMeet = false;
    ajaxData['meetList'] = [];
    ajaxData['CurrentName'] = "";
    ajaxData['CurrentTeacher'] = "";
    ajaxData['CurrentTime'] = "";
    ajaxData['CurrentOrderId'] = "";
    ajaxData['CurrentopSign'] = "";
    ajaxData['AllSignPeoNum'] = 0;//所有的签到人数
  } else {
    haveMeet = false;
    for (var value in ScheduleTable) {
      var startTime2 = turnTimePass(value['StartTime']);
      var startTimeAgain = DateTime.parse('$startTime2');
      var endTime2 = turnTimePass(value['EndTime']);
      var endTimeAgain = DateTime.parse('$endTime2');
      var statusText = "未开始";
      if (CompareDate(nowDate, startTimeAgain) &&
          CompareDate(endTimeAgain, nowDate)) {
        ajaxData['CurrentName'] = value['MeetTitle'];
        ajaxData['CurrentTeacher'] = value['OrderPerson'];
        ajaxData['CurrentTime'] = startTime2.substring(11, 16) + "-" + (endTime2.substring(11, 16));
        ajaxData['CurrentOrderId'] = value['OrderId'];
        ajaxData['CurrentopSign'] = '${value['IsAttendance']}';//是否开启签到
        statusText = "进行中";
        haveMeet = true;
      }
      if (CompareDate(nowDate, endTimeAgain)) {
        statusText = "已结束";
      }
      //判断时间是今天的，开始时间大于今天的0点，结束时间小于明天的0点
      var nowDateComC = new DateTime(nowDate.year,nowDate.month,nowDate.day);
      var meetPreviewInt = int.parse('$meetPreview');
      var afterDateCom = new DateTime(nowDate.year,nowDate.month,nowDate.day).add(new Duration(hours: 24*meetPreviewInt));
      if (CompareDate(startTimeAgain, nowDateComC) &&CompareDate(afterDateCom, endTimeAgain)) {
        if (statusText != "已结束") {
//          print(ScheduleTable);
          meetList.add({
            "StartTime": startTime2.substring(0, 16),
            "EndTime": endTime2.substring(11, 16),
            "MeetTitle": value['MeetTitle'],
            "OrderPerson": value['OrderPerson'],
            "statusText": statusText
          });
        }
      }
      ajaxData['meetList'] = meetList;

      if(haveMeet==false){
        ajaxData['CurrentName'] = "";//会议名称
        ajaxData['CurrentTeacher'] = "";//预约人
        ajaxData['CurrentTime'] = "";
        ajaxData['CurrentOrderId'] = "";
        ajaxData['CurrentopSign'] = "";
        ajaxData['AllSignPeoNum'] = 0;//所有的签到人数
      }
//      print(meetList);
    }
  }
  //
  // if(posalUrl==''||posalport==''){
  //   //服务器地址或服务器端口号为空--无颜色--把所有的灯都关上
  //   lightNoColor();//3个灯都不亮
  // }else if(havesucccode==0){
  //   //有后台地址，但是授权没成功
  //   lightYellow();//未授权--变为黄色（红色+绿色）
  // }
  // else if(haveMeet==true){
  //   //写了后台地址授权成功了
  //   lightRed();//有会议亮红灯
  // }else{
  //   lightGreen();//无会议亮绿灯
  // }

  if('$haveMeet'!=beforeHaveMeet||'${ajaxData['CurrentOrderId']}'!=beforeComOrderId){
    //会议状态或正在进行的会议ID和之前不一样
    SignPeoList = [];//签到人员列表置空
    ajaxData['AllSignPeoNum'] = 0;//所有的签到人数
    streamMeetThing.add('${haveMeet}${ajaxData['CurrentOrderId']}');
    getSignListofHost();//获取后台已经签到的人员的列表
  }
  return ajaxData;
}
//亮红灯
Future<void> lightRed() async {
  //控制侧边灯 GPIO 口：1是绿2是红3是蓝   值：1是关 0是开  开之前先把其余的关上，要不然会出现重合起来的颜色，显示会变得不准
  //高电平--1 低电平--0
  var apiVersionNum = await VendorAPI.getApiVersion();
  var gpioVal1 = await VendorAPI.getGpioValue(1);
  var gpioVal2 = await VendorAPI.getGpioValue(2);
  var gpioVal3 = await VendorAPI.getGpioValue(3);
  if(gpioVal1!="1"){
    bool? sucVAL1 = await VendorAPI.writeGpioValue(1, '1');//先把口1关闭
  }
  if(gpioVal3!="1"){
    bool? sucVAL2 = await VendorAPI.writeGpioValue(3, '1');//先把口3关闭
  }
  if(gpioVal2!="0"){
    bool? sucVAL3 = await VendorAPI.writeGpioValue(2, '0');//把口2打开
  }

}

//时间格式化
String turnTimePass(value) {
  var date = DateTime.parse('$value');
  String timestamp =
      "${date.year.toString()}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:00";
  //print(timestamp);
  return timestamp;
}

//比较两个日期的大小第一个值比第二个值大返回true，否则返回false
bool CompareDate(one, two) {
  DateTime? d1 = null;
  DateTime? d2 = null;
  if (one.runtimeType == String) {
//convert
    d1 = DateTime.parse(one);
  } else if (one.runtimeType == DateTime) {
    d1 = one;
  }
  if (two.runtimeType == String) {
//convert
    d2 = DateTime.parse(two);
  }else if (two.runtimeType==DateTime)
    {d2=two;}
//  var done = DateTime.parse('$one');
  //DateTime.tryParse(formattedString)
//  var dTwo = DateTime.parse('$Two');
//  var d1 = new DateTime(one.year, one.month, one.day, one.hour, one.minute);
//  var d2 = new DateTime(Two.year, Two.month, Two.day, Two.hour, Two.minute);
  if(d1!=null&&d2!=null){
    return d2.isBefore(d1);
  }else{
    return false;
  }
}

//当前时间的0点
nowdateLC() {
  var today = getDataNowNtp();
//  var year = today.year;
//  var month = today.month;
//  var date = today.day;
//  month = checkTime(month);
//  date = checkTime(date);
  return new DateTime(today.year,today.month,today.day);
}

//今天的23:59
afterdateLC() {
  var today = getDataNowNtp();
//  var year = today.year;
//  var month = today.month;
//  var date = today.day;
//  month = checkTime(month);
//  date = checkTime(date);
//  return "$year-$month-$date 23:59:59";
//  new DateTime(today.year,today.month,today.day);
  return  new DateTime(today.year,today.month,today.day).add(new Duration(hours: 24));
}

//数值小于10首尾添加0
//checkTime(i) {
//  String res;
//  if (i < 10) {
//    res = "0" + i.toString();
//  }
//  return res;
//}

//检验数据是否为空
bool isNull(val) {
  if (val == "undefined" ||
      val == null ||
      val == "" ||
      val == '' ||
      val == "null" ||
      val == "NULL" ||
      val.length == 0) {
    return true;
  }
  return false;
}
