import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:webviewmeet_fluttertemplate/shareLocal.dart';

import 'HttpHelper.dart';
import 'Model.dart';
//使用人脸数据类型
class CustomFaceClass {
  final String PeoName;
  final String ImgPath;
  final String ImgCreateTime;
  final String recognitionState;
  final List<Face> faceMess;
  final InputImage iptImage;

  CustomFaceClass({
    required this.PeoName,
    required this.ImgPath,
    required this.ImgCreateTime,
    required this.recognitionState,
    required this.faceMess,
    required this.iptImage,
  });

  // 添加一个工厂构造函数来方便地创建对象
  factory CustomFaceClass.fromJson(Map<String, dynamic> json) {
    return CustomFaceClass(
      PeoName: json['PeoName'],
      ImgPath: json['ImgPath'],
      ImgCreateTime: json['ImgCreateTime'],
      recognitionState: json['recognitionState'],
      iptImage: json['iptImage'],
      faceMess: json['faceMess'],
    );
  }

  // 你可以添加一个方法来将对象转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'PeoName': PeoName,
      'ImgPath': ImgPath,
      'ImgCreateTime': ImgCreateTime,
      'recognitionState': recognitionState,
      'iptImage': iptImage,
      'faceMess': faceMess,
    };
  }

}


//使用 package:image 提供的方法将图像数据编码为 PNG 格式字节数组
class DisplayImage extends StatelessWidget {
  final img.Image imageData;

  DisplayImage(this.imageData);

  @override
  Widget build(BuildContext context) {
    // 将 img.Image 转换为 PNG 格式的字节数组
    final pngBytes = img.encodePng(imageData);

    // 使用 Flutter 的 Image.memory widget 显示图像
    return Image.memory(
      Uint8List.fromList(pngBytes),
      fit: BoxFit.contain,
    );
  }
}

// 将 NV21 转换为 RGB-----调用原生JAVA版本

Future<Uint8List?> convertNV21ToJpeg(Uint8List nv21Data, int width, int height) async {
  const platform = MethodChannel('nv21_converter');
  try {
    final jpegBytes = await platform.invokeMethod<Uint8List>(
      'convertNV21ToJpeg',
      {
        'nv21': nv21Data,
        'width': width,
        'height': height,
      },
    );
    return jpegBytes;
  } on PlatformException catch (e) {
    print("转换失败: ${e.message}");
    return null;
  }
}

// 将 NV21 转换为 RGB-----flutter版本
Uint8List convertNV21ToRGB(Uint8List nv21Data, int width, int height) {
  final imageSize = width * height;
  final rgb = Uint8List(imageSize * 3);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final yIndex = y * width + x;
      final uvIndex = imageSize + (y ~/ 2) * width + (x ~/ 2) * 2;

      final yValue = nv21Data[yIndex] & 0xFF;
      final vValue = nv21Data[uvIndex] & 0xFF;
      final uValue = nv21Data[uvIndex + 1] & 0xFF;

      final r = (yValue + 1.402 * (vValue - 128)).clamp(0, 255).toInt();
      final g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128)).clamp(0, 255).toInt();
      final b = (yValue + 1.772 * (uValue - 128)).clamp(0, 255).toInt();

      final rgbIndex = yIndex * 3;
      rgb[rgbIndex] = r;
      rgb[rgbIndex + 1] = g;
      rgb[rgbIndex + 2] = b;
    }
  }

  return rgb;
}



Future<void> uploadFaceData(timestamp, Uint8List sddata) async {
  //http://localhost:5000/api/TonleMeet/FaceRecognizerSignIn?OrderId=123&DeviceId=&DeviceType=InfoPublishing&Location=
  var posalUrlGetToken = 'http://$meetorderUrl';
  var meetId = ajaxData['CurrentOrderId'];//当前正在进行的会议
  deviceID = await StorageUtil.getStringItem('deviceID');
  if(meetId!=''){
    final responseBody = await compute(_uploadFaceDataIsolate, {
      'url': '${posalUrlGetToken}/api/TonleMeet/FaceRecognizerSignIn?OrderId=${meetId}&DeviceId=${deviceID}&DeviceType=InfoPublishing',
      'data': sddata,
    });
    //人脸上传框消失
    // int upnum = ajaxData['SignSendPosition']['upnum'];
    // ajaxData['SignSendPosition'] = {
    //   'x':0,
    //   'y':0,
    //   'x2':0,
    //   'y2':0,
    //   'upnum':upnum
    // };
    print('人脸上传成功');
    // var mess = {
    //   "TotalCount":0,
    //   "Result":{
    //     "Id":"9b607cdd-9ab6-4184-a0a6-180fa8718181",
    //     "Name":"预约正在进程",
    //     "Times":"2025-06-12 15:03-18:00",
    //     "UserName":"于春晓二号",
    //     "UserTel":"17664080580",
    //     "Status":0,
    //     "IsAttendance":null,
    //     "Istemporary":0,
    //     "TableCardName":null,
    //     "JoinCode":"660996"
    //   },
    //   "Tag":1,
    //   "Message":"签到成功",
    //   "Description":null
    // };
    // 在主线程中处理 UI 相关逻辑
    if (responseBody != null&&responseBody!="") {
      final redataJson = json.decode(responseBody);
      // Fluttertoast.showToast(msg: "返回結果$responseBody");
      //Tag 0签到失败:没勾选签到\不到点或者过点  1签到成功   2您不在参会人员名单中  3你已签到  -1人脸模糊
      if ('${redataJson['Tag']}' == '1') {
        playerMeet.setAsset(
            'files/qiandaochenggong.mp3');//播放签到成功的音频
        playerMeet.play();

        if(redataJson['Result']?.isNotEmpty == true){
          String TableCardName = '${redataJson['Result']['TableCardName']}';
          if(TableCardName=='null'){
            TableCardName="-";
          }
          String Updatedate = '${redataJson['Result']['Updatedate']}';
          if(Updatedate=='null'){
            Updatedate="-";
          }
          for(var a=0;a<SignPeoList.length;a++){
            var UserTel = SignPeoList[a]['UserTel'];
            if(UserTel=='${redataJson['Result']['UserTel']}'){
              SignPeoList.removeAt(a);//移除当前
            }
          }
          SignPeoList.insert(0,{
            'PeoName': '${redataJson['Result']['UserName']}',
            'UserTel': '${redataJson['Result']['UserTel']}',
            'PhotoPath': '${redataJson['Result']['PhotoPath']}',
            'TableCardName': TableCardName,
            'Updatedate': Updatedate,
            'State': '1',
          });//签到人员列表

          ajaxData['SignReMess'] = "1";//签到结果-1成功
          ajaxData['SignReTime'] = DateTime.now().millisecondsSinceEpoch; //签到结果的时间 获取当前时间戳（单位：秒）

          streamsdAddPeoImg.add('新增了一张人脸图像');
        }
        // Fluttertoast.showToast(msg: "${redataJson['Message']}");
      }else if ('${redataJson['Tag']}' == '3'){
        //已经签到了如果列表里没有
        // playerMeet.stop();
        // playerMeet.setAsset(
        //     'files/niyiqiandao.mp3');//播放你已签到的音频
        // playerMeet.play();
        String TableCardName = '${redataJson['Result']['TableCardName']}';
        if(TableCardName=='null'){
          TableCardName="-";
        }
        String Updatedate = '${redataJson['Result']['Updatedate']}';
        if(Updatedate=='null'){
          Updatedate="-";
        }
        for(var a=0;a<SignPeoList.length;a++){
          var UserTel = SignPeoList[a]['UserTel'];
          if(UserTel=='${redataJson['Result']['UserTel']}'){
            SignPeoList.removeAt(a);//移除当前
          }
        }
        SignPeoList.insert(0,{
          'PeoName': '${redataJson['Result']['UserName']}',
          'UserTel': '${redataJson['Result']['UserTel']}',
          'PhotoPath': '${redataJson['Result']['PhotoPath']}',
          'TableCardName': TableCardName,
          'Updatedate': Updatedate,
          'State': '1',
        });
        ajaxData['SignReMess'] = "1";//签到结果-1成功
        ajaxData['SignReTime'] = DateTime.now().millisecondsSinceEpoch; //签到结果的时间 获取当前时间戳（单位：秒）
        streamsdAddPeoImg.add('新增了一张人脸图像');
      }else if('${redataJson['Tag']}' == '2'||'${redataJson['Tag']}' == '0'||'${redataJson['Tag']}' == '-1'){
        //不在参会人员里
        String PhotoPath = "";
        if('${redataJson['Result']}'!='null'){
          PhotoPath = '${redataJson['Result']['PhotoPath']}';
          if(PhotoPath=='null'){
            PhotoPath="-";
          }
        }
        SignPeoList.insert(0,{
          'PeoName': '${redataJson['Message']}',
          'UserTel': '',
          'PhotoPath': PhotoPath,
          'TableCardName': '',
          'Updatedate': '',
          'State': '0',
        });
        ajaxData['SignReMess'] = "2";//签到结果-1成功 2失败
        ajaxData['SignReTime'] = DateTime.now().millisecondsSinceEpoch; //签到结果的时间 获取当前时间戳（单位：秒）
        streamsdAddPeoImg.add('不在参会人员里的人脸图像0签到失败:没勾选签到\不到点或者过点\人脸不在系统中-1模糊的脸');
      }
    }else{
      //没有返回结果--网络异常等
      SignPeoList.insert(0,{
        'PeoName': '网络异常',
        'UserTel': '',
        'PhotoPath': '',
        'TableCardName': '',
        'Updatedate': '',
        'State': '0',
      });
      ajaxData['SignReMess'] = "2";//签到结果-1成功 2失败
      ajaxData['SignReTime'] = DateTime.now().millisecondsSinceEpoch; //签到结果的时间 获取当前时间戳（单位：秒）
      streamsdAddPeoImg.add('网络异常');
    }
  }

}

Future<String?> _uploadFaceDataIsolate(Map<String, dynamic> params) async {
  try {
    final url = Uri.parse(params['url']);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/octet-stream'},
      body: params['data'],
    );
    return response.body;
  } catch (e) {
    print('上传失败（子线程）: $e');
    return null;
  }
}

//获取当前正在进行的会议的签到列表
void getSignListofHost(){
  var posalUrlGetToken = 'http://$meetorderUrl';
  HttpDioHelper helper = HttpDioHelper();
  var bodySend = {
    'mettingid':'${ajaxData['CurrentOrderId']}',
  };
  helper.httpDioGet(posalUrlGetToken, "/api/MeetAttendance/UserList",body:bodySend).then((datares) {
    if(datares.statusCode!=200){}
    else{
      var res = (datares.data);
      var dadata =res['data'];
      var rows = dadata['rows'];
      if(rows!=null){
        List SignPeoListAf = [];
        for(var a=0;a<rows.length;a++){
          // if('${rows[a]['Status']}'=='1'){
            //已经签到的
          //----只有签到列表接口返回的PhotoPath是111
            SignPeoListAf.add({
              'PeoName': '${rows[a]['Name']}',
              'UserTel': '${rows[a]['Tel']}',
              'PhotoPath': '111',
              'TableCardName': '${rows[a]['TableCardName']}',
              'Updatedate': '${rows[a]['Updatedate']}',
              'State': '${rows[a]['Status']}',
            });
          // }

        }

        SignPeoList = SignPeoListAf;
        ajaxData['AllSignPeoNum'] = rows.length;//所有的签到人数
        streamsdAddPeoImg.add('获取到签到列表');
      }
    }
  });
}

