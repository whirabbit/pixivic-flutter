import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuple/tuple.dart';

import 'package:pixivic/provider/pic_page_model.dart';

class SelectModeBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<PicPageModel, Tuple2<bool, List>>(
      selector: (context, picPageModel) {
        // make list a Runtime constant list or selector won't rebuild when list change
        final list = List.unmodifiable(picPageModel.onSelectedList);
        Tuple2<bool, List> tuple = Tuple2(picPageModel.isInSelectMode(), list);
        print(tuple);
        return tuple;
      },
      builder: (context, tuple, _) {
        return AnimatedPositioned(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
          top: tuple.item1 ? 0 : ScreenUtil().setHeight(-50),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 350),
            height: ScreenUtil().setHeight(35),
            width: ScreenUtil().setWidth(324),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
              boxShadow: [
                BoxShadow(
                    blurRadius: 13,
                    offset: Offset(5, 5),
                    color: Color(0x73E5E5E5)),
              ],
            ),
            child: SafeArea(
                top: true,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: ScreenUtil().setWidth(8),
                          ),
                          InkWell(
                            onTap: () {
                              Provider.of<PicPageModel>(context, listen: false)
                                  .cleanSelectedList();
                            },
                            child: FaIcon(
                              FontAwesomeIcons.times,
                              color: Colors.orange,
                            ),
                          ),
                          SizedBox(
                            width: ScreenUtil().setWidth(10),
                          ),
                          Text(
                            tuple.item2.length.toString(),
                            style:
                                TextStyle(fontSize: 16, color: Colors.orange),
                          )
                        ],
                      ),
                      Text(
                        'Test Widget',
                        style: TextStyle(fontSize: 16, color: Colors.orange),
                      )
                    ])),
          ),
        );
      },
    );
  }
}
