import 'dart:async';
import 'package:flutter/material.dart';
import 'common.dart';
import '../Model.dart';

class ClockBaseStatefulWidget extends StatefulWidget {
  ClockBaseStatefulWidget({required Key key}) : super(key: key);

  @override
  ClockBaseState createState() {
    var state = new ClockBaseState();
    state.startClock();
    return state;
  }
}

class ClockBaseState<T extends StatefulWidget> extends State {
  ClockBaseState() : super();

  DateTime now = getDataNowNtp();

  @override
  Widget build(BuildContext context) {
    return new Text('ClockBaseState is not implemented!');
  }

  startClock() {
    Timer.periodic(CLOCK_INTERVAL, (Timer t) {
      if (!mounted) {
        return;
      }

      setState(() {
        now = getDataNowNtp();
      });
    });
  }

  startMeetcOM(){
    Timer.periodic(CLOCK_INTERVAL, (Timer t) {
      if (!mounted) {
        return;
      }
      setState(() {
        ajaxData['RoomName'] = ajaxDataValue['RoomName'];
        ajaxData['ScheduleTable'] = ajaxDataValue['ScheduleTable'];
//        now = DateTime.now();
//        ajaxData = {
//          'RoomName':ajaxDataValue['RoomName'],
//          'currentAddData': '',
//          'currentAddData': '',
//          'ScheduleTable': ajaxDataValue['ScheduleTable'],
//          'meetList':[],
//          'CurrentName': "",
//          'CurrentTeacher': "",
//          'CurrentTime': "",
//          'nextCurrentName': ""
//        };
      });
    });
  }

  startMeetList(){
    Timer.periodic(CLOCK_INTERVAL, (Timer t) {
      if (!mounted) {
        return;
      }
      setState(() {
        ajaxData['RoomName'] = ajaxDataValue['RoomName'];
        ajaxData['ScheduleTable'] = ajaxDataValue['ScheduleTable'];
//        ajaxData = {
//          'RoomName':ajaxDataValue['RoomName'],
//          'currentAddData': '',
//          'currentAddData': '',
//          'ScheduleTable': ajaxDataValue['ScheduleTable'],
//          'meetList':[],
//          'CurrentName': "",
//          'CurrentTeacher': "",
//          'CurrentTime': "",
//          'nextCurrentName': ""
//        };
      });
    });
  }
  startTitle(){
    Timer.periodic(CLOCK_INTERVAL, (Timer t) {
      if (!mounted) {
        return;
      }
      setState(() {
        ajaxData['RoomName'] = ajaxDataValue['RoomName'];
        ajaxData['ScheduleTable'] = ajaxDataValue['ScheduleTable'];
//        ajaxData = {
//          'RoomName':ajaxDataValue['RoomName'],
//          'currentAddData': '',
//          'currentAddData': '',
//          'ScheduleTable': ajaxDataValue['ScheduleTable'],
//          'meetList':[],
//          'CurrentName': "",
//          'CurrentTeacher': "",
//          'CurrentTime': "",
//          'nextCurrentName': ""
//        };
      });
    });
  }


  Size getDeviceSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }
}