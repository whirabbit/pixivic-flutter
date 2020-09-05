import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionModel with ChangeNotifier {
  /* 画集 model 处理两块内容，展示画集卡片的列表(Viewer)，以及打开画集后的列表(Collection)  */
  int currentViewerPage = 1;  
  int currentCollectionPage = 1;
  bool onVierwerEdit = false;
  bool onCollectionEdit = false;
  List viewerList = [];
  List collectionList = [];

  resetViewer() {
    currentViewerPage = 1;
    onVierwerEdit = false;
    viewerList = [];
  }

}
