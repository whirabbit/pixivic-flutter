import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:pixivic/provider/pic_page_model.dart';

class SelectModeBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<PicPageModel, bool>(
      selector: (context, picPageModel) => picPageModel.isInSelectMode(),
      builder: (context, isInSelectMode, _) {
        return AnimatedPositioned(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
          top: isInSelectMode ? 0 : ScreenUtil().setHeight(-50),
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
                          FaIcon(
                            FontAwesomeIcons.times,
                            color: Colors.orange,
                          ),
                          SizedBox(
                            width: ScreenUtil().setWidth(10),
                          ),
                          Text(
                            '2',
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
