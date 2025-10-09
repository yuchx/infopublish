import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Model.dart';
import 'theme_base.dart';

import 'common.dart';

class TimerWidget extends StatefulWidget {

  String? name;
  String? title;

  @override
  State<StatefulWidget> createState() {
    var state = new _TimerWidgetState();
    state.startClock();
    return state;
  }
}

class _TimerWidgetState extends ClockBaseState<TimerWidget> {
  @override
  Widget build(BuildContext context) {
    var WeekDayText = '${now.weekday}';
    var WeekDayTextRead;
    if(WeekDayText=="1"){
       WeekDayTextRead = '星期一';
    }else if(WeekDayText=="2"){
       WeekDayTextRead = '星期二';
    }else if(WeekDayText=="3"){
       WeekDayTextRead = '星期三';
    }else if(WeekDayText=="4"){
       WeekDayTextRead = '星期四';
    }else if(WeekDayText=="5"){
       WeekDayTextRead = '星期五';
    }else if(WeekDayText=="6"){
       WeekDayTextRead = '星期六';
    }else if(WeekDayText=="7"){
       WeekDayTextRead = '星期日';
    }

    ScreenUtil.init(context, designSize: const Size(1920, 1080));

    String timenowttt = "${pad0(now.hour)}:${pad0(now.minute)}:${pad0(now.second)}";
    //如果当前时间是00:00:05的话，//校对时间
    if(timenowttt=="00:00:05"){
      checkntpTime();//校对时间
    }
    var nowSNum = DateTime.now().millisecondsSinceEpoch;
    if(ajaxData['SignReTime']!=0&&ajaxData['SignReMess'] != ""){
      if(nowSNum-ajaxData['SignReTime']>2000){
        ajaxData['SignReMess'] = "";//签到结果-1成功 2失败 空不显示//签到结果的时间 获取当前时间戳（单位：秒）和当前时间相差2秒弹窗消失---2秒后消失
        if(SignPeoList.length>0){
          if(SignPeoList[0]['PhotoPath']=='111'){}else{
            SignPeoList[0]['PhotoPath'] = "222";//右下角不显示--右下角不是111和222的时候才显示
          }
        }
        streamsdAddPeoImg.add('弹窗和右下角结果消失');
      }
    }

    return Column(
      children: <Widget>[
        Container(
          height:ScreenUtil().setHeight(81),
          child: Center(
            child: Text(
              '${pad0(now.hour)}:${pad0(now.minute)}',
              style:TextStyle(
                  fontSize: ScreenUtil().setSp(64),
                  color: Color.fromRGBO(78, 78, 78, 1),
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                  height: 1
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
        Container(
          height:ScreenUtil().setHeight(64),
          margin:EdgeInsets.only(left:ScreenUtil().setHeight(24)),
          child: Center(
            child: Text(
              '${now.year}/${now.month}/${now.day}    $WeekDayTextRead',
              style:TextStyle(fontSize: ScreenUtil().setSp(32),color: Color.fromRGBO(78, 78, 78, 1),decoration: TextDecoration.none,height:1),
              textAlign: TextAlign.left,
            ),
          ),
        )
      ],
    );
  }
}