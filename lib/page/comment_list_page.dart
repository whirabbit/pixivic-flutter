import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_screenutil/screenutil.dart';

import '../widget/papp_bar.dart';
import '../data/texts.dart';

class CommentListPage extends StatefulWidget {
  @override
  _CommentListPageState createState() => _CommentListPageState();
}

class _CommentListPageState extends State<CommentListPage> {
  TextZhCommentCell texts = TextZhCommentCell();
  ScreenUtil screen = ScreenUtil();

  @override
  void initState() { 
    _loadComments();
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomCommentBar(),
      appBar: PappBar(title: texts.comment,),
      body: ListView.builder(itemBuilder: null),
    );
  }

  _loadComments() async{
    Dio dio = Dio();
    Response response = await dio.get('');
  }

  Widget bottomCommentBar() {
    return Container(
      width: screen.setWidth(324),
      height: screen.setHeight(35),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField()
        ],
      ),
    );
  }



}