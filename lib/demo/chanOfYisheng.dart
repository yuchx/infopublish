import 'package:flutter/services.dart';

class VendorAPI {
  static const MethodChannel _channel = MethodChannel('com.example.custom_channel');
  // 调用 writeGpioValue 方法
  static Future<bool?> writeGpioValue(int gpio, String value) async {
    try {
      print("Calling writeGpioValue with gpio: $gpio, value: $value");
      final bool success = await _channel.invokeMethod('writeGpioValue', {
        'gpio': gpio,
        'value': value,
      });
      return success;
    } catch (e) {
      print("Error calling writeGpioValue: $e");
      return null;
    }
  }
  //获取GPIO的电平值
  static Future<String> getGpioValue(int gpio) async {
    try {
      final String testStr = await _channel.invokeMethod('getGpioValue',{
        'gpio':gpio
      });
      return testStr;
    } catch (e) {
      print("Error calling writeGpioValue: $e");
      return "无数据";
    }
  }
  static Future<String> getApiVersion() async {
    try {
      final String testStr = await _channel.invokeMethod('getApiVersion');
      return testStr;
    } catch (e) {
      print("Error calling writeGpioValue: $e");
      return "无数据";
    }
  }
  static Future<String> getSystemBrightness() async {
    try {
      final String testStr = await _channel.invokeMethod('getGpioValue');
      return testStr;
    } catch (e) {
      print("Error calling writeGpioValue: $e");
      return "无数据";
    }
  }
  //关闭背光--熄灭屏幕，只关背光，却不进入休眠，软件继续运行。
  static Future turnOffBacklight() async {
    try {
      await _channel.invokeMethod('turnOffBackLight');//关背光
      Future.delayed(Duration(seconds: 3), () async {
        await _channel.invokeMethod('turnOnBackLight');//3秒后开背光
      });
    } catch (e) {
      print("Error calling turnOffBackLight: $e");
    }
  }
}
//亮绿灯
Future<void> lightGreen() async {
  //控制侧边灯 GPIO 口：1是绿2是红3是蓝   值：1是关 0是开  开之前先把其余的关上，要不然会出现重合起来的颜色，显示会变得不准
  var gpioVal1 = await VendorAPI.getGpioValue(1);
  var gpioVal2 = await VendorAPI.getGpioValue(2);
  var gpioVal3 = await VendorAPI.getGpioValue(3);
  if(gpioVal3!="1"){
    bool? sucVAL1 = await VendorAPI.writeGpioValue(3, '1');//先把口3关闭
  }
  if(gpioVal2!="1"){
    bool? sucVAL2 = await VendorAPI.writeGpioValue(2, '1');//先把口2关闭
  }
  if(gpioVal1!="0"){
    bool? sucVAL3 = await VendorAPI.writeGpioValue(1, '0');//把口1打开
  }
}
//亮蓝灯
Future<void> lightBlue() async {
  //控制侧边灯 GPIO 口：1是绿2是红3是蓝   值：1是关 0是开  开之前先把其余的关上，要不然会出现重合起来的颜色，显示会变得不准
  var gpioVal1 = await VendorAPI.getGpioValue(1);
  var gpioVal2 = await VendorAPI.getGpioValue(2);
  var gpioVal3 = await VendorAPI.getGpioValue(3);
  if(gpioVal1!="1"){
    bool? sucVAL1 = await VendorAPI.writeGpioValue(1, '1');//先把口1关闭
  }
  if(gpioVal2!="1"){
    bool? sucVAL2 = await VendorAPI.writeGpioValue(2, '1');//先把口2关闭
  }
  if(gpioVal3!="0"){
    bool? sucVAL3 = await VendorAPI.writeGpioValue(3, '0');//把口3打开
  }
}

//亮红灯+绿灯=黄灯
Future<void> lightYellow() async {
  //控制侧边灯 GPIO 口：1是绿2是红3是蓝   值：1是关 0是开  开之前先把其余的关上，要不然会出现重合起来的颜色，显示会变得不准
  //高电平--1 低电平--0
  var gpioVal1 = await VendorAPI.getGpioValue(1);
  var gpioVal2 = await VendorAPI.getGpioValue(2);
  var gpioVal3 = await VendorAPI.getGpioValue(3);
  if(gpioVal1!="0"){
    bool? sucVAL1 = await VendorAPI.writeGpioValue(1, '0');//先把口1打开
  }
  if(gpioVal2!="0"){
    bool? sucVAL2 = await VendorAPI.writeGpioValue(2, '0');//先把口2打开
  }
  if(gpioVal3!="1"){
    bool? sucVAL3 = await VendorAPI.writeGpioValue(3, '1');//把口3关闭
  }

}
//3个灯都不亮
Future<void> lightNoColor() async {
  //控制侧边灯 GPIO 口：1是绿2是红3是蓝   值：1是关 0是开  开之前先把其余的关上，要不然会出现重合起来的颜色，显示会变得不准
  //高电平--1 低电平--0
  var gpioVal1 = await VendorAPI.getGpioValue(1);
  var gpioVal2 = await VendorAPI.getGpioValue(2);
  var gpioVal3 = await VendorAPI.getGpioValue(3);
  if(gpioVal1!="1"){
    bool? sucVAL1 = await VendorAPI.writeGpioValue(1, '1');//先把口1关闭
  }
  if(gpioVal2!="1"){
    bool? sucVAL2 = await VendorAPI.writeGpioValue(2, '1');//先把口2关闭
  }
  if(gpioVal3!="1"){
    bool? sucVAL3 = await VendorAPI.writeGpioValue(3, '1');//把口3关闭
  }

}