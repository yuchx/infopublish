import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';

import '../Model.dart';
import '../dataValUse.dart';
import 'detector_view.dart';
import 'painters/face_detector_painter.dart';
import 'package:image/image.dart' as img;
int aNum=0;
class FaceDetectorView extends StatefulWidget {
  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

// 添加一个时间戳变量
DateTime? lastProcessedTime;
class _FaceDetectorViewState extends State<FaceDetectorView> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,//面部轮廓点检测--关闭的话减少返回减少内存占用
      enableLandmarks: false,//键点检测（如眼、耳、鼻等）--关闭的话减少返回减少内存占用
      enableClassification: false, // 关闭表情识别（如微笑、睁眼）--减少返回减少内存占用
      performanceMode: FaceDetectorMode.accurate, // 精确模式，更高精度但检测速度略慢FaceDetectorMode.fast, // 使用快速模式（牺牲精度提高速度）--减少返回减少内存占用
    ),
  );
  bool _canProcess = true;//用于控制人脸检测任务是否可以继续进行处理。通常用于启动或停止图像处理的流程。
  bool _isBusy = false;//当前没有正在执行任务
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;//前置摄像头
  @override
  void dispose() {
    _canProcess = false;//确保在页面退出时，不再处理摄像头的图像流。
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'Face Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;//如果当前正在执行任务，则退出
    // 检查是否需要间隔 1 秒

    _isBusy = true;//当前正在执行任务
    setState(() {
      _text = '';
    });
    final faces = await _faceDetector.processImage(inputImage);
    if(faces.isNotEmpty){

      print('Detected face(s): ${faces.length}');
      // Fluttertoast.showToast(msg: "检测到人脸图像");


      // 保存图像到本地
      // if(aNum==0){
      //   _saveImageToFile(faces,inputImage);//整张图
      //   aNum=1;
      // }

      saveFaceToFile2(faces,inputImage);//只保留人脸

    }
    if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
      final painter = FaceDetectorPainter(
        faces,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      String text = 'Faces found: ${faces.length}\n\n';
      for (final face in faces) {
        text += 'face: ${face.boundingBox}\n\n';
      }
      _text = text;
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    _isBusy = false;//当前没有正在执行任务，执行任务已完成
    if (mounted) {
      setState(() {});
    }
  }


  Future<void> saveFaceToFile2(face, InputImage inputImage) async {
    // 时间戳命名
    DateTime now = DateTime.now();
    if (lastProcessedTime != null) {
      final currentTime = DateTime.now();
      final duration = currentTime.difference(lastProcessedTime!);
      if (duration.inSeconds < 3) {
        return; // 间隔不足 3 秒，跳过处理
      }
    }
    // 更新上次处理时间
    lastProcessedTime = DateTime.now();
    // Fluttertoast.showToast(msg: "检测到人脸图像去保存");
    String timestamp = '${now.year}_${now.month}_${now.day}_${now.hour}_${now.minute}_${now.second}';

    // 保存路径
    final directory = await getExternalStorageDirectory();
    final filePath = '${directory?.path}/face_$timestamp.png';

    // 原始图像尺寸
    final width = inputImage.metadata!.size.width.toInt();
    final height = inputImage.metadata!.size.height.toInt();

    // 原始图像字节流 (NV21 => RGB)
    final rgbData = convertNV21ToRGB(inputImage.bytes!, width, height);//flutter版本
    final rgbImage = img.Image.fromBytes(width: width, height: height, bytes: rgbData.buffer);
    // final jpegBytes = await convertNV21ToJpeg(inputImage.bytes!, width, height);//原生版本
    // print('${inputImage.bytes?.length}');
    // final rgbImage = img.decodeImage(jpegBytes!);
    // uploadFaceData(rgbData.buffer.asUint8List());//给后台发送数据
    // 获取人脸的矩形区域
    for(var a=0;a<face.length;a++){
      final box = face[a].boundingBox;

      // 原始图像尺寸
      final imgW = inputImage.metadata!.size.width.toInt();
      final imgH = inputImage.metadata!.size.height.toInt();

// 设定扩展比例或像素值（可调）
      final expandRatio = 0.2; // 扩展 20%
      final expandX = (box.width * expandRatio).toInt();
      final expandY = (box.height * expandRatio).toInt();

// 计算新的裁剪区域（注意边界限制）
      final cropX = (box.left - expandX).toInt().clamp(0, imgW - 1);
      final cropY = (box.top - expandY).toInt().clamp(0, imgH - 1);
      final cropW = (box.width + expandX * 2).toInt().clamp(1, imgW - cropX);
      final cropH = (box.height + expandY * 2).toInt().clamp(1, imgH - cropY);

      // int upnum = ajaxData['SignSendPosition']['upnum']+1;
      // ajaxData['SignSendPosition'] = {
      //   'x':box.left,
      //   'y':box.top,
      //   'x2':box.right,
      //   'y2':box.bottom,
      //   'upnum':upnum
      // };
      // streamsdAddPeoImg.add('要上传的人脸画框');
      // playerMeet.stop();
      // playerMeet.setAsset(
      //     'files/ding.mp3');
      // playerMeet.play();//播放ding的音效

// 裁剪更大的区域（含头部和上下留白）
      final faceImage = img.copyCrop(rgbImage!, x: cropX, y: cropY, width: cropW, height: cropH);

      final pngBytes = await encodeFaceToPng(faceImage);
      // final base64Image = base64Encode(pngBytes);

      // uploadFaceData(faceImage);//给后台发送数据
      uploadFaceData(timestamp,pngBytes);//给后台发送数据

      // print("处理完毕");
      // // 保存为 PNG
      // final file = File(filePath);
      // final encoded = img.encodePng(faceImage);
      // await file.writeAsBytes(encoded);
      // print('Face image saved at: $filePath');
    }

  }





  // Future<void> saveFaceToFile(List<Face> faceList, InputImage inputImage) async {
  //   DateTime now = DateTime.now();
  //   if (lastProcessedTime != null) {
  //     final duration = now.difference(lastProcessedTime!);
  //     //检测时间间隔1S
  //     if (duration.inSeconds < 1) {
  //       return;
  //     }
  //   }
  //   lastProcessedTime = now;
  //
  //   final width = inputImage.metadata!.size.width.toInt();
  //   final height = inputImage.metadata!.size.height.toInt();
  //
  //   final rgbData = convertNV21ToRGB(inputImage.bytes!, width, height);
  //   final rgbImage = img.Image.fromBytes(width: width, height: height, bytes: rgbData.buffer);
  //
  //   for (var face in faceList) {
  //     final boundingBox = face.boundingBox;
  //
  //     final pngBytes = await compute(_processFaceImageIsolate, {
  //       'rgbImage': rgbImage,
  //       'box': boundingBox,
  //       'imgW': width,
  //       'imgH': height,
  //     });
  //
  //     uploadFaceData(pngBytes); // 上传异步处理
  //   }
  // }



}



Uint8List _processFaceImageIsolate(Map<String, dynamic> data) {
  final img.Image rgbImage = data['rgbImage'];
  final Rect box = data['box'];
  final int imgW = data['imgW'];
  final int imgH = data['imgH'];

  const expandRatio = 0.2;
  final expandX = (box.width * expandRatio).toInt();
  final expandY = (box.height * expandRatio).toInt();

  final cropX = (box.left - expandX).toInt().clamp(0, imgW - 1);
  final cropY = (box.top - expandY).toInt().clamp(0, imgH - 1);
  final cropW = (box.width + expandX * 2).toInt().clamp(1, imgW - cropX);
  final cropH = (box.height + expandY * 2).toInt().clamp(1, imgH - cropY);

  final cropped = img.copyCrop(rgbImage, x: cropX, y: cropY, width: cropW, height: cropH);
  return Uint8List.fromList(img.encodePng(cropped));
}





Future<Uint8List> encodeFaceToPng(img.Image image) async {
  return await compute(_encodeImageIsolate, image);
}

Uint8List _encodeImageIsolate(img.Image image) {
  return Uint8List.fromList(img.encodePng(image));
}