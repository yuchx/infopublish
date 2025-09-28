import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Model.dart';
import 'face_detector_view.dart';

//摄像头签到框
class cameraSignBor extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StreamBuilder(
        stream: streamMeetThing.stream,
        builder:(context,snapshot){
          if(haveMeet==true) {
            if (ajaxData['CurrentopSign'] == 'true') {
              //有会议正在进行并且开启了签到
              return Positioned(
                top:ScreenUtil().setWidth(333),
                right: ScreenUtil().setWidth(56),
                child: Container(
                  width: ScreenUtil().setWidth(685),
                  height: ScreenUtil().setHeight(730),
                  child: Column(
                    children: [
                      // ------摄像头签到----
                      Container(
                        width: ScreenUtil().setWidth(685),
                        height: ScreenUtil().setHeight(500),
                        child: Stack(
                          children: [
                            Container(
                              width: ScreenUtil().setWidth(685),
                              height: ScreenUtil().setHeight(500),
                              decoration: BoxDecoration(
                                border:Border.all(
                                    color: Colors.red,
                                    width:ScreenUtil().setWidth(1),
                                    style: BorderStyle.solid
                                ),
                              ),
                              child: FaceDetectorView(),
                            ),
                            SignMessAlert(),//签到的弹窗
                            // SignSendborder(),//人脸数据传递加载接口标识--去掉了后来改成ding的音效
                          ],
                        )
                      ),
                      SizedBox(height: ScreenUtil().setHeight(30),),
                      SignNowLiShow(),//最后一次的签到结果

                    ],
                  ),
                ),
              );
            }else{
              return Container();
            }
          }else{
            return Container();
          }

        });

  }

}




//签到的实时返回信息
class SignNowLiShow extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StreamBuilder(
        stream: streamsdAddPeoImg.stream,
        builder:(context,snapshot){
          if(SignPeoList.length>0){
            var photoPath = "";
            var PeoErrMess = "签到失败";
            // if('${SignPeoList[0]['State']}'=='1'){
              if('${SignPeoList[0]['PhotoPath']}'!='null'&&'${SignPeoList[0]['PhotoPath']}'!=''&&'${SignPeoList[0]['PhotoPath']}'!='-'){
                photoPath = 'http://$meetorderUrl${SignPeoList[0]['PhotoPath']}';
              }
            if('${SignPeoList[0]['State']}'!='1'){
              if('${SignPeoList[0]['PeoName']}'!='null'&&'${SignPeoList[0]['PeoName']}'!=''&&'${SignPeoList[0]['PeoName']}'!='-'){
                PeoErrMess = '${SignPeoList[0]['PeoName']}';
              }
            }

            // }
            if('${SignPeoList[0]['PhotoPath']}'=='111'||'${SignPeoList[0]['PhotoPath']}'=='222'){
              //是获取回来的列表上的，不是摄像头签到生成的不显示
              return Container();
            }else{
              return Container(
                height: ScreenUtil().setHeight(150),
                child: Row(
                  mainAxisAlignment:MainAxisAlignment.start,
                  crossAxisAlignment:CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: ScreenUtil().setWidth(140),
                      height: ScreenUtil().setHeight(140),
                      // decoration: BoxDecoration(
                      //     image: DecorationImage(
                      //       image: '$photoPath'!=''?NetworkImage('$photoPath'):AssetImage('images/people.png'),
                      //       fit: BoxFit.fill,
                      //     )),
                      child: Image(
                        image: '$photoPath'!=''?NetworkImage('$photoPath'):AssetImage('images/people.png'),
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) {
                          return Image(
                            image: AssetImage('images/people.png'),
                            fit: BoxFit.fill,
                          );
                        },
                      ),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(24),),
                    Container(
                      width: ScreenUtil().setWidth(510),
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
                      child: Column(
                        mainAxisAlignment:MainAxisAlignment.start,
                        crossAxisAlignment:CrossAxisAlignment.start,
                        children: [
                          '${SignPeoList[0]['State']}'!='1'? Text('${PeoErrMess}',
                            style: TextStyle(fontSize: ScreenUtil().setSp(28),color: Color.fromRGBO(80, 80, 80, 1),height: 1.25),
                            textAlign: TextAlign.left,
                          ):Row(
                            mainAxisAlignment:MainAxisAlignment.start,
                            crossAxisAlignment:CrossAxisAlignment.start,
                            children: [
                              Text('${SignPeoList[0]['PeoName']}',
                                style: TextStyle(fontSize: ScreenUtil().setSp(28),color: Color.fromRGBO(80, 80, 80, 1),height: 1.25),
                                textAlign: TextAlign.left,
                              ),
                              // SizedBox(width: ScreenUtil().setWidth(24),),
                              // Text('${SignPeoList[0]['TableCardName']}',
                              //   style: TextStyle(fontSize: ScreenUtil().setSp(28),color: Color.fromRGBO(80, 80, 80, 1),height: 1.25),
                              //   textAlign: TextAlign.left,
                              // ),
                              SizedBox(width: ScreenUtil().setWidth(24),),
                              Text('${SignPeoList[0]['Updatedate']}',
                                style: TextStyle(fontSize: ScreenUtil().setSp(28),color: Color.fromRGBO(80, 80, 80, 1),height: 1.25),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                          SizedBox(height: ScreenUtil().setHeight(20),),
                          Container(
                            width: ScreenUtil().setWidth(150),
                            height: ScreenUtil().setHeight(40),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: '${SignPeoList[0]['State']}'=='1'?AssetImage('images/signNowSuccess.png'):AssetImage('images/signNowError.png'),
                                  fit: BoxFit.fill,
                                )),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            }

          }else{
            return Container();
          }

        });
  }

}


//会议摄像头人脸签到版本正在进行的会议展示
class SignOrderMess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //签到人员放置

    Widget _pastSignPeoList() {
      List<Widget> tiles = [];//先建一个数组用于存放循环生成的widget
      List pastSignList = [];//要防止的
      for(var a=0;a<SignPeoList.length;a++){
        if('${SignPeoList[a]['State']}'=='1'){
          //签到成功才放置---改为所有的人员的
          pastSignList.add(SignPeoList[a]);

        }
      }
      //把结果不是1的，但是PhotoPath是111放置上
      for(var b=0;b<SignPeoList.length;b++){
        if('${SignPeoList[b]['State']}'!='1'&&SignPeoList[b]['PhotoPath']=='111'){
          pastSignList.add(SignPeoList[b]);
        }
      }
      for(var c=0;c<pastSignList.length;c++){
        double jsnumbl = 1;
        if(pastSignList.length>21){
          jsnumbl = 1;
        }else if(pastSignList.length>14){
          jsnumbl = 1.33;
        }else if(pastSignList.length>7){
          jsnumbl = 2;
        }else if(pastSignList.length>0){
          jsnumbl = 2;
        }
        tiles.add(
          Container(
              width: ScreenUtil().setWidth(275*jsnumbl),
              height: ScreenUtil().setHeight(90),
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 1),
                // borderRadius: BorderRadius.circular(4.0),
                border:Border(
                  top: BorderSide(
                      color: Color.fromRGBO(235, 238, 245, 1),
                      width:ScreenUtil().setWidth(1),
                      style: BorderStyle.solid
                  ),
                  right: BorderSide(
                      color: Color.fromRGBO(235, 238, 245, 1),
                      width:ScreenUtil().setWidth(1),
                      style: BorderStyle.solid
                  ),
                  bottom: BorderSide(
                      color: Color.fromRGBO(235, 238, 245, 1),
                      width:ScreenUtil().setWidth(1),
                      style: BorderStyle.solid
                  ),
                  left: BorderSide(
                      color: '${pastSignList[c]['State']}'=='1'?Color.fromRGBO(50, 196, 151, 1):Color.fromRGBO(216, 216, 216, 1.0),
                      width:ScreenUtil().setWidth(5),
                      style: BorderStyle.solid
                  ),
                ),

              ),
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(10),top: ScreenUtil().setHeight(19)),
              margin: EdgeInsets.only(left: ScreenUtil().setWidth(8),bottom: ScreenUtil().setHeight(10)),
              child: Row(
                mainAxisAlignment:MainAxisAlignment.start,
                crossAxisAlignment:CrossAxisAlignment.start,
                children: [
                  Expanded(
                    // width: ScreenUtil().setWidth(160),
                    // height: ScreenUtil().setHeight(90),
                    child: Column(
                      mainAxisAlignment:MainAxisAlignment.start,
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('${pastSignList[c]['PeoName']}',
                              style:TextStyle(fontSize: ScreenUtil().setSp(18.0),color: Color.fromRGBO(93, 93, 93, 1),height:1,fontWeight: FontWeight.w700,decoration: TextDecoration.none),
                              textAlign: TextAlign.left,),
                          ],
                        ),
                        SizedBox(height: ScreenUtil().setHeight(18),),
                        Text('${pastSignList[c]['State']}'=='1'?'${pastSignList[c]['Updatedate']}':'-',
                          style:TextStyle(fontSize: ScreenUtil().setSp(14.0),color: Color.fromRGBO(144, 151, 167, 1),height:1,decoration: TextDecoration.none),
                          textAlign: TextAlign.left,),
                      ],
                    ),

                  ),
                  Container(
                    width: ScreenUtil().setWidth(72),
                    height: ScreenUtil().setHeight(52),
                    alignment: Alignment.centerLeft,
                    child: '${pastSignList[c]['State']}'=='1'?Text('签到成功',
                      style:TextStyle(fontSize: ScreenUtil().setSp(16.0),color: Color.fromRGBO(50, 196, 151, 1),height:1,decoration: TextDecoration.none),
                      textAlign: TextAlign.left,):Text('未签到',
                      style:TextStyle(fontSize: ScreenUtil().setSp(16.0),color: Color.fromRGBO(93, 93, 93, 1),height:1,decoration: TextDecoration.none),
                      textAlign: TextAlign.left,),
                  ),
                  Container(
                    width: ScreenUtil().setWidth(20),
                    height: ScreenUtil().setWidth(52),
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: ScreenUtil().setWidth(20),
                      height: ScreenUtil().setWidth(20),
                      decoration: '${pastSignList[c]['State']}'=='1'?BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('images/signSuccess.png'),
                            fit: BoxFit.fill,
                          )):BoxDecoration(),
                    ),
                  ),
                  SizedBox(width: ScreenUtil().setWidth(10),)
                ],
              )
          ),
        );
      }

      Widget content =  ListView(
        children: [
          Wrap(
              children: tiles //重点在这里，因为用编辑器写Column生成的children后面会跟一个<Widget>[]，
            //此时如果我们直接把生成的tiles放在<Widget>[]中是会报一个类型不匹配的错误，把<Widget>[]删了就可以了
          )
        ],
      );
      return content;
    }




    return StreamBuilder(
        stream: streamsdAddPeoImg.stream,
        builder:(context,snapshot){
          return _pastSignPeoList();
        });
  }
}

//签到人员的人数情况
class OrderSignPeoNum extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StreamBuilder(
        stream: streamsdAddPeoImg.stream,
        builder:(context,snapshot){

          var signScuessPeo = [];
          for(var a=0;a<SignPeoList.length;a++){
            if(SignPeoList[a]['State']=='1'){
              //签到成功才放置
              signScuessPeo.add(SignPeoList[a]);
            }

          }
          // int nosignPeoNum = 0;//未签到人员
          // if(ajaxData['AllSignPeoNum']!=0){
          //   nosignPeoNum = ajaxData['AllSignPeoNum']-signScuessPeo.length;
          // }
          return Container(
              width: ScreenUtil().setWidth(350),
              padding: EdgeInsets.only(top: ScreenUtil().setHeight(51)),
              child:Column(
                children: [
                  Text(
                    "${signScuessPeo.length}/${ajaxData['AllSignPeoNum']}",
                    style:TextStyle(
                        fontSize: ScreenUtil().setSp(40.0),
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontWeight: FontWeight.bold,
                        height: 1.26,
                        decoration: TextDecoration.none
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(6),
                  ),
                  Text(
                    "已签到/应签到",
                    style:TextStyle(
                        fontSize: ScreenUtil().setSp(16.0),
                        color: Color.fromRGBO(255, 255, 255, 1),
                        height: 1.25,
                        decoration: TextDecoration.none
                    ),
                  ),
                ],
              )
          );
        });

  }

}
//签到的弹窗
class SignMessAlert extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StreamBuilder(
        stream: streamsdAddPeoImg.stream,
        builder:(context,snapshot){
          if(ajaxData['SignReMess'] == ""){
            return Container();
          }else{
            return Positioned(
              bottom:ScreenUtil().setWidth(30),
              right: ScreenUtil().setWidth(222),
              child: Container(
                  width: ScreenUtil().setWidth(240),
                  height: ScreenUtil().setWidth(160),
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  child:Column(
                    children: [
                      SizedBox(height: ScreenUtil().setHeight(32),),
                      Container(
                        width: ScreenUtil().setWidth(48),
                        height: ScreenUtil().setWidth(48),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ajaxData['SignReMess'] == "1"?AssetImage('images/signSuccess.png'):AssetImage('images/signError.png'),
                              fit: BoxFit.fill,
                            )),
                      ),
                      SizedBox(height: ScreenUtil().setHeight(16),),
                      Text(
                        ajaxData['SignReMess'] == "1"?"签到成功":"签到失败",
                        style:TextStyle(
                            fontSize: ScreenUtil().setSp(28.0),
                            color: Color.fromRGBO(255, 255, 255, 1),
                            height: 1.25,
                            decoration: TextDecoration.none
                        ),
                      ),
                    ],
                  )
              ),
            );
          }
        });
  }

}
//人脸数据传递加载接口标识
class SignSendborder extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StreamBuilder(
        stream: streamsdAddPeoImg.stream,
        builder:(context,snapshot){

          // ajaxData['SignSendPosition']

          var leftpast = double.parse('${ajaxData['SignSendPosition']['x']}');
          var rightpast = double.parse('${ajaxData['SignSendPosition']['x2']}');
          var toppast = double.parse('${ajaxData['SignSendPosition']['y']}');
          var bottompast = double.parse('${ajaxData['SignSendPosition']['y2']}');
          var nowleft = ScreenUtil().setWidth(685)-ScreenUtil().setWidth(rightpast);
          if('${ajaxData['SignSendPosition']['x']}'=='0'&&'${ajaxData['SignSendPosition']['x2']}'=='0'){
            return Container();
          }else{
            return Positioned(
              left:nowleft,
              top:ScreenUtil().setHeight(toppast),
              child: Container(
                // width: ScreenUtil().setWidth(100),
                // height: ScreenUtil().setWidth(40),
                child:Text('${ajaxData['SignSendPosition']['upnum']}',
                  style:TextStyle(
                      fontSize: ScreenUtil().setSp(26.0),
                      color: Color.fromRGBO(34, 194, 28, 1),
                      fontWeight: FontWeight.bold,
                      height: 1,
                      decoration: TextDecoration.none
                  ),
                ),
                // child:Icon(
                //     Icons.add_circle,
                //     color: Color.fromRGBO(34, 194, 28, 0.5),
                //     size: ScreenUtil().setSp(48)
                // ),
              ),
            );
          }

        });
  }

}