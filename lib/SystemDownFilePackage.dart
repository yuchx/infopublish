// import 'package:flutter/material.dart';
// import 'package:ota_update/ota_update.dart';
// import 'package:progress_dialog/progress_dialog.dart';
//
// /*
//  * AndroidStudio Generate
//  * @class
//  * @author: ZhongWb
//  * @date: 2020/3/20 9:16
//  * @description SystemDownFilePackage  文件下载封装
//  * */
// ///todo:[url] 下载地址 ， [fileName] 文件名称
// SystemDownFilePackage({BuildContext context,String url,String fileName:"name",ValueChanged<Map<String,Object>> onChanged,String showMsg:"正在下载中..."}){
//   ProgressDialog pr =  ProgressDialog(context,type: ProgressDialogType.Download, isDismissible: false, showLogs: false);
//   pr.update(progress:0.0, message: showMsg);
//   // RUN OTA UPDATE
//   // START LISTENING FOR DOWNLOAD PROGRESS REPORTING EVENTS
//   try {
//     //LINK CONTAINS APK OF FLUTTER HELLO WORLD FROM FLUTTER SDK EXAMPLES
//     //destinationFileName is optional
//     OtaUpdate() .execute(url, destinationFilename: fileName).listen(
//           (OtaEvent event) {
//         print('status: ${event.status}  value: ${event.value}');
//         String p = "0.0";
//         switch(event.status){
//           case OtaStatus.DOWNLOADING: // 下载中
//           //启动弹出框
//             pr.show();
//             pr.update(progress:double.parse(event.value), message: showMsg);
//             onChanged({"status":event.status,"value":event.value,"msg":"1"});
//             break;
//           case OtaStatus.INSTALLING: //安装中
//           //关闭弹出框
//             pr.hide();
//             break;
//           case OtaStatus.PERMISSION_NOT_GRANTED_ERROR: // 权限错误
//             print('更新失败，请稍后再试');
//             break;
//           default: // 其他问题
//             break;
//         }
//       },
//       onDone: (){
//             print("555");
//       }
//     );
//   } catch (e) {
//     print('Failed to make OTA update. Details: $e');
//     onChanged({"status":"","value":"","msg":"0"});
//   }
// }