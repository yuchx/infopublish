package com.tonle.webviewmeetfluttertemplate;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterShellArgs;

public class MyFlutterActivity extends FlutterActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //申请权限---检查当前设备的 Android 版本是否符合要求
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ContextCompat.checkSelfPermission(MyFlutterActivity.this, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(MyFlutterActivity.this, new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, 1);
            }
            if (ContextCompat.checkSelfPermission(MyFlutterActivity.this, Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(MyFlutterActivity.this, new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, 1);
            }
        }
    }


    @Override
    public FlutterShellArgs getFlutterShellArgs() {
        //重写的getFlutterShellArgs方法，本身自带的方法，FlutterShellArgs是Flutter引擎的一部分，它包含了Flutter应用程序的一些参数
        copyLibAndWrite(this, "hotlibapp.so");
        FlutterShellArgs supFA = super.getFlutterShellArgs();//获取 FlutterShellArgs 对象的引用，并将其存储在一个新的变量中供以后使用。这可用于访问和修改 Flutter 引擎的启动参数。
        File dir = this.getDir("libs", Activity.MODE_PRIVATE);//使用 getDir() 方法在应用程序的内部存储空间中创建一个名为 “libs” 的子目录。MODE_PRIVATE 表示所创建目录的访问权限仅限于当前应用程序
        String libPath = dir.getAbsolutePath() + File.separator + "hotlibapp.so";//getAbsolutePath获取目录的绝对路径
        File libFile = new File(libPath);
        if (libFile.exists()) {
            supFA.add("--aot-shared-library-name=" + libPath);   //如果有hotlibapp文件 ,配置进去,没有则作用默认的
        }
        return supFA;
    }

    // 作用:  在手机目录找 hotlibapp.so 文件 , 如果有则复制到 app libs 文件下, 没有则不做操作
    public static void copyLibAndWrite(Context context, String fileName) {
        try {

            String path = Environment.getExternalStorageDirectory().toString();//返回外部存储媒体主目录的 File 对象，将该 File 对象转换为字符串
            File destFile2 = new File(path + "/Download/TonlePlayer/TonlePlayer/" + fileName);//目录下下载的so文件的地址
            if (destFile2.exists()) {
                File dir = context.getDir("libs", Activity.MODE_PRIVATE);
                File destFile = new File(dir.getAbsolutePath() + File.separator + fileName);
                if (destFile.exists()) {
                    destFile.delete();
                }
                destFile.createNewFile();
                FileInputStream is = new FileInputStream(destFile2);
                FileOutputStream fos = new FileOutputStream(destFile);
                byte[] buffer = new byte[is.available()];
                int byteCount;
                while ((byteCount = is.read(buffer)) != -1) {
                    fos.write(buffer, 0, byteCount);
                }
                fos.flush();
                is.close();
                fos.close();
                destFile2.delete();   //复制完后删除这个文件
                //删除成功后修改当前APP的版本号，
            }
        } catch (IOException e) {
        }

    }
}
