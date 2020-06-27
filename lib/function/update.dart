import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:ota_update/ota_update.dart';

class UpdateApp {
  void showUpdateDialog(BuildContext context, String version, String newFeature,
      String url) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('pixivic 新版本 $version'),
            content: Text(newFeature),
            actions: <Widget>[
              FlatButton(
                child: Text("暂不更新"),
                onPressed: () => Navigator.of(context).pop(), // 关闭对话框
              ),
              FlatButton(
                  child: Text("前往更新"),
                  onPressed: () async {
                    BotToast.showSimpleNotification(title: '开始下载,请留意状态栏下载进度');

                    Directory directoryBase =
                        await getExternalStorageDirectory();
                    final Directory apkDirFolder = Directory(
                        '${directoryBase.path}${Platform.pathSeparator}apk');
                    if (!await apkDirFolder.exists()) {
                      print('creating folder');
                      await apkDirFolder.create(recursive: true);
                    }

                    print(url);
                    downloadApkAndInstall(url, 'pixivic_$version.apk');
            
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }

  void downloadApkAndInstall(String url, String name) {
    try {
      OtaUpdate().execute(url, destinationFilename: name).listen(
        (OtaEvent event) {
          print('EVENT: ${event.status} : ${event.value}');
        },
      );
    } catch (e) {
      print('Failed to make OTA update. Details: $e');
      BotToast.showSimpleNotification(title: '下载更新包失败，请检查网络');
    }
  }
}
