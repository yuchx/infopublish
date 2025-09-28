//import 'dart:html';

import 'package:flutter/material.dart';
import 'postData.dart';
import 'theme_base.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Model.dart';



class ListViewDataDemo extends StatefulWidget {
  @override
  _ListViewData createState() => _ListViewData();
}
class _ListViewData extends State<ListViewDataDemo> {
  @override
  Widget build(BuildContext context) {
    return new TimerMeetWidget();
  }
}
class TimerMeetWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    var state = new _TimerMeetState();
    state.startMeetList();
    return state;
  }
}


class _TimerMeetState extends ClockBaseState<TimerMeetWidget>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    ScreenUtil.init(context, designSize: const Size(1920, 1080));
    //    列表数据
    Map dateMessage =ajaxData;
    List pastList = [];//下方要展示的内容--进行中的不放只在列表上
    for(var a=0;a<dateMessage['meetList'].length;a++){
      if(dateMessage['meetList'][a]['statusText']!='进行中'){
        pastList.add(
          {
            "StartTime": dateMessage['meetList'][a]['StartTime'],
            "EndTime": dateMessage['meetList'][a]['EndTime'],
            "MeetTitle": dateMessage['meetList'][a]['MeetTitle'],
            "OrderPerson":dateMessage['meetList'][a]['OrderPerson'],
            "statusText": dateMessage['meetList'][a]['statusText']
          }
        );
      }
    }
    runMeet();//数据更新
    //print(dateMessage['meetList'].length);


    Widget _listdataItemBuilder(BuildContext context,int index){
      if(havePro==3){
        if(index==0){
          return Container(
            alignment: Alignment.bottomLeft,
            width: ScreenUtil().setWidth(580),
            height:ScreenUtil().setHeight(330),
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 1),
              border:Border(
                top: BorderSide(
                    color: Color.fromRGBO(255, 119, 119, 1),
                    width:ScreenUtil().setHeight(16),
                    style: BorderStyle.solid
                ),
              ),
            ),
            margin: EdgeInsets.only(left:ScreenUtil().setWidth(15),right:ScreenUtil().setWidth(15)),
            padding: EdgeInsets.only(left:ScreenUtil().setWidth(30),right:ScreenUtil().setWidth(30)),
            child: Column(
              children: <Widget>[
                SizedBox(height: ScreenUtil().setHeight(40),),
                Container(
                  height: ScreenUtil().setHeight(45),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "下一会议",
                    style:TextStyle(
                        fontSize: ScreenUtil().setSp(34.0),
                        color: Color.fromRGBO(255, 119, 119, 1),
                        fontWeight: FontWeight.bold,
                        height: 1,
                        decoration: TextDecoration.none
                    ),
                  ),
                ),
                Container(
                  height: ScreenUtil().setHeight(140.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${pastList[index]['MeetTitle']}",
                    style:TextStyle(
                        fontSize: ScreenUtil().setSp(34.0),
                        color: Color.fromRGBO(78, 78, 78, 1),
                        height:1.2,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  height:ScreenUtil().setHeight(70.0),
                  width:ScreenUtil().setWidth(520.0),
                  alignment: Alignment.centerLeft,
                  child:Text(
                    "${pastList[index]['StartTime']} - ${pastList[index]['EndTime']} / ${pastList[index]['OrderPerson']}",
                    style:TextStyle(fontSize: ScreenUtil().setSp(24.0),color: Color.fromRGBO(78, 78, 78, 1),decoration: TextDecoration.none),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          );
        }
        else{
          return Container(
            alignment: Alignment.bottomLeft,
            width: ScreenUtil().setWidth(580),
            height:ScreenUtil().setHeight(300),
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 0.8),
              border:Border(
                top: BorderSide(
                    color: Color.fromRGBO(248, 209, 81, 1),
                    width:ScreenUtil().setHeight(10),
                    style: BorderStyle.solid
                ),
              ),
            ),
            margin: EdgeInsets.only(left:ScreenUtil().setWidth(15),right:ScreenUtil().setWidth(15),top: ScreenUtil().setWidth(30)),
            padding: EdgeInsets.only(left:ScreenUtil().setWidth(30),right:ScreenUtil().setWidth(30)),
            child: Column(
              children: <Widget>[
                SizedBox(height: ScreenUtil().setHeight(46),),
                Container(
                  height: ScreenUtil().setHeight(40),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "待开始",
                    style:TextStyle(
                        fontSize: ScreenUtil().setSp(30.0),
                        color: Color.fromRGBO(248, 209, 81, 1),
                        fontWeight: FontWeight.bold,
                        height: 1,
                        decoration: TextDecoration.none
                    ),
                  ),
                ),
                Container(
                  height: ScreenUtil().setHeight(113.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${pastList[index]['MeetTitle']}",
                    style:TextStyle(
                        fontSize: ScreenUtil().setSp(30.0),
                        color: Color.fromRGBO(78, 78, 78, 1),
                        height:1.3,
                        decoration: TextDecoration.none
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  height:ScreenUtil().setHeight(70.0),
                  width:ScreenUtil().setWidth(520.0),
                  alignment: Alignment.centerLeft,
                  child:Text(
                    "${pastList[index]['StartTime']} - ${pastList[index]['EndTime']} / ${pastList[index]['OrderPerson']}",
                    style:TextStyle(fontSize: ScreenUtil().setSp(24.0),color: Color.fromRGBO(78, 78, 78, 1),decoration: TextDecoration.none),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          );
        }

      }else if(havePro==4&&ajaxData['CurrentopSign']!='true'){
        if(index==0){
          return Container(
            alignment: Alignment.bottomLeft,
            width: ScreenUtil().setWidth(580),
            height:ScreenUtil().setHeight(330),
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 1),
              border:Border(
                top: BorderSide(
                    color: Color.fromRGBO(255, 119, 119, 1),
                    width:ScreenUtil().setHeight(16),
                    style: BorderStyle.solid
                ),
              ),
            ),
            margin: EdgeInsets.only(left:ScreenUtil().setWidth(15),right:ScreenUtil().setWidth(15)),
            padding: EdgeInsets.only(left:ScreenUtil().setWidth(30),right:ScreenUtil().setWidth(30)),
            child: Column(
              children: <Widget>[
                SizedBox(height: ScreenUtil().setHeight(40),),
                Container(
                  height: ScreenUtil().setHeight(45),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "下一会议",
                    style:TextStyle(
                        fontSize: ScreenUtil().setSp(34.0),
                        color: Color.fromRGBO(255, 119, 119, 1),
                        fontWeight: FontWeight.bold,
                        height: 1,
                        decoration: TextDecoration.none
                    ),
                  ),
                ),
                Container(
                  height: ScreenUtil().setHeight(140.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${pastList[index]['MeetTitle']}",
                    style:TextStyle(
                        fontSize: ScreenUtil().setSp(34.0),
                        color: Color.fromRGBO(78, 78, 78, 1),
                        height:1.2,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  height:ScreenUtil().setHeight(70.0),
                  width:ScreenUtil().setWidth(520.0),
                  alignment: Alignment.centerLeft,
                  child:Text(
                    "${pastList[index]['StartTime']} - ${pastList[index]['EndTime']} / ${pastList[index]['OrderPerson']}",
                    style:TextStyle(fontSize: ScreenUtil().setSp(24.0),color: Color.fromRGBO(78, 78, 78, 1),decoration: TextDecoration.none),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          );
        }
        else{
          return Container(
            alignment: Alignment.bottomLeft,
            width: ScreenUtil().setWidth(580),
            height:ScreenUtil().setHeight(300),
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 0.8),
              border:Border(
                top: BorderSide(
                    color: Color.fromRGBO(248, 209, 81, 1),
                    width:ScreenUtil().setHeight(10),
                    style: BorderStyle.solid
                ),
              ),
            ),
            margin: EdgeInsets.only(left:ScreenUtil().setWidth(15),right:ScreenUtil().setWidth(15),top: ScreenUtil().setWidth(30)),
            padding: EdgeInsets.only(left:ScreenUtil().setWidth(30),right:ScreenUtil().setWidth(30)),
            child: Column(
              children: <Widget>[
                SizedBox(height: ScreenUtil().setHeight(46),),
                Container(
                  height: ScreenUtil().setHeight(40),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "待开始",
                    style:TextStyle(
                        fontSize: ScreenUtil().setSp(30.0),
                        color: Color.fromRGBO(248, 209, 81, 1),
                        fontWeight: FontWeight.bold,
                        height: 1,
                        decoration: TextDecoration.none
                    ),
                  ),
                ),
                Container(
                  height: ScreenUtil().setHeight(113.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${pastList[index]['MeetTitle']}",
                    style:TextStyle(
                        fontSize: ScreenUtil().setSp(30.0),
                        color: Color.fromRGBO(78, 78, 78, 1),
                        height:1.3,
                        decoration: TextDecoration.none
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  height:ScreenUtil().setHeight(70.0),
                  width:ScreenUtil().setWidth(520.0),
                  alignment: Alignment.centerLeft,
                  child:Text(
                    "${pastList[index]['StartTime']} - ${pastList[index]['EndTime']} / ${pastList[index]['OrderPerson']}",
                    style:TextStyle(fontSize: ScreenUtil().setSp(24.0),color: Color.fromRGBO(78, 78, 78, 1),decoration: TextDecoration.none),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          );
        }
      }else if(havePro==4&&ajaxData['CurrentopSign']=='true'){
        return Container();
      }
      else{
        return Container(
          alignment: Alignment.bottomLeft,
          width: ScreenUtil().setWidth(580),
          height:ScreenUtil().setHeight(300),
          color: Color.fromRGBO(0, 0, 0, 0.5),
          margin: EdgeInsets.only(left:ScreenUtil().setWidth(15),right:ScreenUtil().setWidth(20),bottom: ScreenUtil().setWidth(10)),
          child: Column(
            children: <Widget>[
              Container(
                  height: ScreenUtil().setHeight(90.0),
                  decoration: ShapeDecoration(
                      shape: UnderlineInputBorder( borderSide:BorderSide(color: Color(0xFFFFFFFF), style: BorderStyle.solid, width: ScreenUtil().setWidth(1)))
                    //borderRadius: BorderRadius.circular(8.0)
                  ),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: ScreenUtil().setWidth(30.0),
                        height: ScreenUtil().setHeight(30.0),
                      ),
                      SizedBox(
                        width: ScreenUtil().setWidth(30.0),
                        height: ScreenUtil().setHeight(30.0),
                        child: pastList[index]['statusText']=='进行中'?Container(
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 85, 85, 1),
                            shape: BoxShape.circle,
                          ),
                        ):Container(
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(248, 148, 81, 1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      SizedBox(
                          width: ScreenUtil().setWidth(100.0),
                          height: ScreenUtil().setHeight(30.0),
                          child: Text(
                            "${pastList[index]['statusText']}",
                            style:TextStyle(fontSize: ScreenUtil().setSp(24.0),color: Colors.white,decoration: TextDecoration.none),
                            textAlign: TextAlign.right,
                          )
                      ),
                      SizedBox(
                        width: ScreenUtil().setWidth(400.0),
                        child: Text(
                          "${pastList[index]['StartTime']} - ${pastList[index]['EndTime']}",
                          style:TextStyle(fontSize: ScreenUtil().setSp(24.0),color: Colors.white,decoration: TextDecoration.none),
                          textAlign: TextAlign.right,
                        ),
                      )
                    ],
                  )
              ),
              Container(
                  height: ScreenUtil().setHeight(200.0),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Container(
                          height:ScreenUtil().setHeight(130.0),
                          width:ScreenUtil().setWidth(540.0),
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left:ScreenUtil().setWidth(15),right: ScreenUtil().setWidth(15)),
                          child: Text(
                            "${pastList[index]['MeetTitle']}",
                            style:TextStyle(fontSize: ScreenUtil().setSp(24.0),color: Colors.white,height:1.5,fontWeight: FontWeight.bold,decoration: TextDecoration.none),
                            textAlign: TextAlign.left,
//                        maxLines: 1,
//                        strutStyle:StrutStyle(
//                          forceStrutHeight:true,
//                        )
                          ),
                        ),
                        Container(
                          height:ScreenUtil().setHeight(70.0),
                          padding: EdgeInsets.only(left:ScreenUtil().setWidth(15),right: ScreenUtil().setWidth(15)),
                          width:ScreenUtil().setWidth(540.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "预约者：${pastList[index]['OrderPerson']}",
                            style: TextStyle(fontSize: ScreenUtil().setSp(24.0),color: Colors.white,decoration: TextDecoration.none),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  )
              ),
            ],
          ),
        );
      }
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: pastList.length,
      itemBuilder: _listdataItemBuilder,
    );
  }
}