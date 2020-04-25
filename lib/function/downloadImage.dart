import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:image_downloader/image_downloader.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:bot_toast/bot_toast.dart';

class DownloadImage {
  final String url;
  final ValueChanged<int> onProgressUpdate;
  final String platform;

  int progress;
  String imageId;
  String fileName;
  String path;
  int size;
  String mimeType;

  DownloadImage(this.url, this.platform, {this.onProgressUpdate}) {
    print('start download');
    ImageDownloader.callback(
        onProgressUpdate: (String imageId, int progressNow) {
      progress = progressNow;
      if (onProgressUpdate != null) onProgressUpdate(progress);
    });
    if(platform == 'ios')
      _iOSDownload();
    else if(platform == 'android') 
      _androidDownload();
  }

  _iOSDownload() async {
    BotToast.showSimpleNotification(title: '开始下载');
    imageId = await ImageDownloader.downloadImage(
      url,
      headers: {'Referer': 'https://app-api.pixiv.net'},
      destination: AndroidDestinationType.custom(directory: 'pixivic_images')
        ..inExternalFilesDir(),
    ).catchError((onError) {
      print(onError);
      BotToast.showSimpleNotification(title: '下载失败,请检查网络');
      ImageDownloader.cancel();
      return false;
    });
    ImageDownloader.cancel();
    if (imageId == null) {
      print('image dwonload error');
      return false;
    }

    fileName = await ImageDownloader.findName(imageId);
    path = await ImageDownloader.findPath(imageId);
    size = await ImageDownloader.findByteSize(imageId);
    mimeType = await ImageDownloader.findMimeType(imageId);
    print(fileName);
    print(path);
    print(size);
    print(mimeType);
    BotToast.showSimpleNotification(title: '下载完成');
    return true;
  }

  _androidDownload() async {
    final Directory directory = await getExternalStorageDirectory();
    final Directory directory2 = await getApplicationSupportDirectory();
    final Directory directory3 = await getApplicationDocumentsDirectory();
    final Directory directory4 = await getDownloadsDirectory();
    print(directory.path);
    print(directory2.path);
    print(directory3.path);
    print(directory4.path);
  //   final Directory picDirFolder =
  //       Directory('${directory.path}${Platform.pathSeparator}pixivic_images');
  //   // print(picDirFolder.path);
  //   if (!await picDirFolder.exists()) {
  //     print('creating folder');
  //     await picDirFolder.create(recursive: true);
  //   }
  //   final taskId = await FlutterDownloader.enqueue(
  //     url: url,
  //     savedDir: '${picDirFolder.path}',
  //     showNotification: true,
  //     openFileFromNotification: true,
  //     headers: {'Referer': 'https://app-api.pixiv.net'},
  //   ).catchError((onError) {
  //     print(onError);
  //     BotToast.showSimpleNotification(title: '下载失败,请检查网络');
  //     ImageDownloader.cancel();
  //     return false;
  //   });

  //   if(taskId == null) {
  //     BotToast.showSimpleNotification(title: '下载失败,请检查网络');
  //     return false;
  //   }
  //   BotToast.showSimpleNotification(title: '下载完成');
  //   return true;

  }
}
