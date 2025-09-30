package com.tonle.webviewmeetfluttertemplate;
import android.content.pm.PackageManager;
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;


import android.hardware.display.DisplayManager;
import android.hardware.usb.UsbConstants;
import android.hardware.usb.UsbDeviceConnection;
import android.hardware.usb.UsbEndpoint;
import android.hardware.usb.UsbInterface;
import android.os.Build;
import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.HashMap;


import android.os.PowerManager;
import android.util.Log;
import android.view.Display;
import android.widget.Spinner;

import com.ys.rkapi.MyManager;


public class MainActivity extends MyFlutterActivity {
    private static final String CHANNEL = "com.example.custom_channel";

    private static final String usbCHANNEL = "myUsbBroReceiver";
    private static final String ACTION_USB_PERMISSION = "com.tonle.template.USB_PERMISSION";//自定义的权限字段
    private MethodChannel methodChannel;
    private UsbManager usbManager;
    private UsbDeviceConnection connection;
    private UsbBroadcastReceiver usbBroadcastReceiver;//监听USB插拔广播
    private IntentFilter filter;
    private MyManager manager;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        usbBroadcastReceiver = new UsbBroadcastReceiver();
        filter = new IntentFilter(ACTION_USB_PERMISSION);
        filter.addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED);
        filter.addAction(UsbManager.ACTION_USB_DEVICE_DETACHED);
        filter.addAction(UsbManager.ACTION_USB_ACCESSORY_ATTACHED);
        filter.addAction(UsbManager.ACTION_USB_ACCESSORY_DETACHED);
        filter.addAction(UsbManager.EXTRA_PERMISSION_GRANTED);
        filter.addAction(Intent.ACTION_MEDIA_MOUNTED);//表明sd对象是存在并具有读/写权限
        registerReceiver(usbBroadcastReceiver, filter);
        // 提前在create方法里初始化USB管理器（UsbManager）
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB_MR1) {
            usbManager = (UsbManager) getSystemService(Context.USB_SERVICE);
        }
        // 初始化 MyManager 对象
        manager = MyManager.getInstance(this);
        manager.bindAIDLService(this);//绑定服务，用于与底层服务通信。
        manager.upgradeRootPermissionForExport();

        Log.d("MainActivity","API Version = " + manager.getApiVersion());


        //申请权限---检查当前设备的 Android 版本是否符合要求(原热更新相关)
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//            if (ContextCompat.checkSelfPermission(MyFlutterActivity.this, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
//                ActivityCompat.requestPermissions(MyFlutterActivity.this, new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, 1);
//            }
//            if (ContextCompat.checkSelfPermission(MyFlutterActivity.this, Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
//                ActivityCompat.requestPermissions(MyFlutterActivity.this, new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, 1);
//            }
//        }
    }

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("getAndroidManifestVersion")) {
                        String version = getAndroidManifestVersion();
                        result.success(version);
                    }else if (call.method.equals("isScreenOn")) {
                        result.success(isScreenOn());
                    }else if (call.method.equals("writeGpioValue")) {
                        //控制侧边灯 GPIO 口：1是绿2是红3是蓝   值：1是关 0是开  开之前先把其余的关上，要不然会出现重合起来的颜色，显示会变得不准
                        Log.d("MainActivity", "Method: " + call.method + ", Arguments: " + call.arguments);
                        Integer gpio = call.argument("gpio");// 获取从 Flutter 传递的参数
                        String value = call.argument("value");
                        if (gpio != null && value != null) {
                            try {
                                // 调用厂商的 API 方法
                                if (manager.writeGpioValue(gpio, value)) {
                                    result.success(true);
                                } else {
                                    result.success(false);
                                }
                            } catch (Exception e) {
                                Log.e("MainActivity", "Error writing GPIO", e);
                                result.error("API_ERROR", "Failed to write GPIO", e.getMessage());
                            }
                        } else {
                            result.error("INVALID_ARGUMENT", "Invalid arguments for writeGpioValue", null);
                        }
                    }else if(call.method.equals("getGpioValue")){
                        //获取GPIO口的电平
                        Integer gpio = call.argument("gpio");// 获取从 Flutter 传递的参数
                        if (gpio != null) {
                            try {
                                // 调用厂商的 API 方法
                                result.success(manager.getGpioValue(gpio));
                            } catch (Exception e) {
                                Log.e("MainActivity", "Error get GPIO", e);
                                result.error("API_ERROR", "Failed to get GPIO", e.getMessage());
                            }
                        } else {
                            result.error("INVALID_ARGUMENT", "Invalid arguments for writeGpioValue", null);
                        }
                    }else if(call.method.equals("getApiVersion")){
                        try {
                            // 调用厂商的 API 方法
                            result.success(manager.getApiVersion());
                        } catch (Exception e) {
                            Log.e("MainActivity", "Error get ApiVersion", e);
                            result.error("API_ERROR", "Failed to get ApiVersion", e.getMessage());
                        }
                    }
                }
        );
        methodChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), usbCHANNEL);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        unregisterReceiver(usbBroadcastReceiver);
    }

    private class UsbBroadcastReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (UsbManager.ACTION_USB_DEVICE_ATTACHED.equals(action)) {

                System.out.println("1111111111111!");
                methodChannel.invokeMethod("usbAttached", null);
                String path = intent.getDataString();
                System.out.println("123212321!");
                System.out.println(path);
            } else if(ACTION_USB_PERMISSION.equals(action)){
            }
            else if (UsbManager.ACTION_USB_DEVICE_DETACHED.equals(action)) {
                methodChannel.invokeMethod("usbDetached", null);
            }
        }
    }

    //用来获取当前应用的版本号--原生写法
    private String getAndroidManifestVersion() {
        try {
            String versionName = getPackageManager().getPackageInfo(getPackageName(), 0).versionName;
            return versionName;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 判断屏幕是否点亮
    private boolean isScreenOn() {
        PowerManager powerManager = (PowerManager) getSystemService(POWER_SERVICE);

        // 判断设备是否处于交互状态
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
            DisplayManager displayManager = (DisplayManager) getSystemService(DISPLAY_SERVICE);
            for (Display display : displayManager.getDisplays()) {
                // 判断显示状态，排除屏幕关闭的情况
                if (display.getState() != Display.STATE_OFF) {
                    return true; // 屏幕亮起
                }
            }
        } else {
            // 在低版本上使用 isInteractive 判断交互状态--低版本先不考虑--
//            return powerManager.isInteractive();
        }

        return false;
    }


}

