import 'package:flutter/material.dart';
import 'package:pixivic/provider/collection_model.dart';

import 'package:provider/provider.dart';

import 'package:pixivic/page/pic_page.dart';
import 'package:pixivic/widget/papp_bar.dart';

class CollectionDetailPage extends StatelessWidget {
  final int collectionId;
  final String title;

  CollectionDetailPage(this.collectionId, this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PappBar(title: title),
      body: PicPage.collection(collectionId: collectionId.toString()),
    );
  }
}
