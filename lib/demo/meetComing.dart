import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Model.dart';
class meetComDemo extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Positioned(
      left:ScreenUtil().setWidth(10),
      height: ScreenUtil().setHeight(510),
      width: ScreenUtil().setWidth(1100),
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
              gradient: LinearGradient(colors: [Color(0xFF3FC2A0),Color(0x00000000)], begin: FractionalOffset(0, 1), end: FractionalOffset(1, 0)),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                      '$meetName空闲中',
                      style:TextStyle(fontSize: ScreenUtil().setSp(48.0),color: Colors.white,fontWeight: FontWeight.bold,decoration: TextDecoration.none),
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