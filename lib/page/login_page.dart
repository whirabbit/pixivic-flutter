import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';

import 'package:pixivic/data/texts.dart';
import 'package:pixivic/data/common.dart';
import 'package:pixivic/function/identity.dart' as identity;
import 'package:pixivic/function/dio_client.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();

  LoginPage({this.widgetFrom});

  // 锁定loginPage所在的位置
  final String widgetFrom;
}

class LoginPageState extends State<LoginPage> {
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _userPasswordController = TextEditingController();
  TextEditingController _verificationController = TextEditingController();
  TextEditingController _userPasswordRepeatController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  ScrollController mainController = ScrollController();

  String verificationImage = '';
  String verificationCode;
  final String regexEmail =
      "^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*\$";

  TextZhLoginPage texts = TextZhLoginPage();

  // 需设定延时重置按钮
  bool loginOnLoading = false;
  bool registerOnLoading = false;
  bool modeIsLogin = true;
  BuildContext buildContext;

  @override
  void initState() {
    super.initState();
    if (tempVerificationCode != null) {
      verificationImage = tempVerificationImage;
      verificationCode = tempVerificationCode;
    } else {
      _getVerificationCode();
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _userPasswordController.dispose();
    _userPasswordRepeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    this.buildContext = context;
    return SingleChildScrollView(
      controller: mainController,
      child: Container(
        height: ScreenUtil().setHeight(576),
        padding: EdgeInsets.only(
            left: ScreenUtil().setWidth(30),
            top: modeIsLogin
                ? ScreenUtil().setHeight(40)
                : ScreenUtil().setHeight(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(8)),
              child: Text(
                texts.head,
                style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF515151)),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(8)),
              child: Text(
                modeIsLogin ? texts.welcomeLogin : texts.welcomeRegister,
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF515151)),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(13)),
              child: Text(
                modeIsLogin ? texts.tipLogin : texts.tipRegister,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF9E9E9E)),
              ),
            ),
            modeIsLogin
                ? inputCell(texts.userNameAndEmail, _userNameController, false)
                : inputCell(texts.userName, _userNameController, false),
            modeIsLogin
                ? Container()
                : inputCell(texts.email, _emailController, false),
            inputCell(texts.password, _userPasswordController, true),
            modeIsLogin
                ? Container()
                : inputCell(
                    texts.passwordRepeat, _userPasswordRepeatController, true),
            verificationCell(_verificationController),
            SizedBox(
              height: ScreenUtil().setHeight(38),
            ),
            Container(
              width: ScreenUtil().setWidth(255),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  modeIsLogin ? loginButton() : registerButton(),
                  forgetPasswordButton(),
                  modeButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget inputCell(
      String label, TextEditingController controller, bool isPassword,
      {num length = 245}) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(10)),
      width: ScreenUtil().setWidth(length),
      height: ScreenUtil().setHeight(40),
      child: TextField(
        decoration: InputDecoration(
          hintText: label,
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFF2994A))),
        ),
        cursorColor: Color(0xFFF2994A),
        controller: controller,
        obscureText: isPassword,
        onTap: () async {
          // Future.delayed(Duration(milliseconds: 250), () {
          //   double location = mainController.position.extentBefore +
          //       ScreenUtil().setHeight(100);
          //   mainController.position.animateTo(location,
          //       duration: Duration(milliseconds: 100),
          //       curve: Curves.easeInCirc);
          // });
        },
      ),
    );
  }

  Widget verificationCell(TextEditingController controller) {
    return Container(
      alignment: Alignment.topLeft,
      height: ScreenUtil().setHeight(40),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            child: inputCell(texts.verification, controller, false),
          ),
          Positioned(
            right: ScreenUtil().setWidth(46),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              constraints: BoxConstraints(
                  minWidth: ScreenUtil().setWidth(85),
                  minHeight: ScreenUtil().setHeight(40)),
              padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
              child: GestureDetector(
                  onTap: () {
                    _getVerificationCode();
                  },
                  child: verificationImage != ''
                      ? Image.memory(
                          base64Decode(verificationImage),
                          width: ScreenUtil().setWidth(70),
                        )
                      : Container()),
            ),
          ),
        ],
      ),
    );
  }

  Widget loginButton() {
    return loginOnLoading
        ? OutlineButton(
            onPressed: () {},
            borderSide: BorderSide(color: Colors.orange),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0),
            ),
            child: Text(
              texts.buttonLoginLoading,
              style: TextStyle(color: Colors.grey),
            ))
        : OutlineButton(
            onPressed: () async {
              setState(() {
                loginOnLoading = true;
                _getVerificationCode();
              });
              int loginResult = await identity.login(
                context,
                _userNameController.text,
                _userPasswordController.text,
                verificationCode,
                _verificationController.text,
                widgetFrom: widget.widgetFrom,
              );
              if (loginResult != 200) {
                _resetMode('login');
              }
            },
            borderSide: BorderSide(
              color: Colors.grey,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0),
            ),
            child: Text(
              texts.buttonLogin,
              style: TextStyle(color: Color(0xFF515151)),
            ));
  }

  Widget registerButton() {
    return registerOnLoading
        ? OutlineButton(
            onPressed: () {},
            borderSide: BorderSide(color: Colors.orange),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0),
            ),
            child: Text(
              texts.buttonRegisterLoading,
              style: TextStyle(color: Colors.grey),
            ))
        : OutlineButton(
            onPressed: () async {
              setState(() {
                registerOnLoading = true;
              });
              var check = await identity.checkRegisterInfo(
                  _userNameController.text,
                  _userPasswordController.text,
                  _userPasswordRepeatController.text,
                  _emailController.text);
              if (check == true) {
                _getVerificationCode();
                int registerResult = await identity.register(
                    _userNameController.text,
                    _userPasswordController.text,
                    _userPasswordRepeatController.text,
                    verificationCode,
                    _verificationController.text,
                    _emailController.text);
                if (registerResult != 200) {
                  _resetMode('register');
                } else {
                  _resetMode('afterRegister');
                }
              } else {
                BotToast.showSimpleNotification(title: check);
                _resetMode('register');
              }
            },
            borderSide: BorderSide(
              color: Colors.grey,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0),
            ),
            child: Text(
              texts.buttonRegister,
              style: TextStyle(color: Color(0xFF515151)),
            ));
  }

  // 注册、登陆的切换按钮
  Widget modeButton() {
    return Container(
      child: GestureDetector(
        onTap: () {
          setState(() {
            modeIsLogin = !modeIsLogin;
            _userPasswordController.text = '';
            _userPasswordController.text = '';
          });
        },
        child: Text(
          modeIsLogin ? texts.registerMode : texts.loginMode,
          style: TextStyle(color: Colors.blueAccent[200]),
        ),
      ),
    );
  }

  // 忘记密码按钮
  Widget forgetPasswordButton() {
    TextEditingController controller = TextEditingController();
    return Container(
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(25)),
      child: GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    title: Text(texts.forgetPasswordTitle),
                    content: TextField(
                      autofocus: true,
                      controller: controller,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              left: 15, bottom: 11, top: 11, right: 15),
                          hintText: texts.mailForForget),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text(texts.mailForForgetCancel),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text(texts.mailForForgetSubmit),
                        onPressed: () {
                          _submitMailForForget(controller.text);
                        },
                      ),
                    ],
                  ));
        },
        child: Text(
          texts.forgetPassword,
          style: TextStyle(color: Colors.blueAccent[200]),
        ),
      ),
    );
  }

  _getVerificationCode() async {
    try {
      Response response = await dioPixivic.get("/verificationCode");
      if (response.statusCode == 200) {
        setState(() {
          verificationCode = response.data['data']['vid'];
          verificationImage = response.data['data']['imageBase64'];
          tempVerificationImage = verificationImage;
          tempVerificationCode = verificationCode;
        });
        return true;
      } else {
        BotToast.showSimpleNotification(title: texts.errorGetVerificationCode);
        return false;
      }
    } catch (e) {
      BotToast.showSimpleNotification(title: texts.errorGetVerificationCode);
      return false;
    }
  }

  // 登录或注册失败后，重置当前页面
  _resetMode(String mode) {
    switch (mode) {
      case 'login':
        setState(() {
          loginOnLoading = false;
          // _userNameController.text = '';
          // _userPasswordController.text = '';
          _verificationController.text = '';
        });
        break;
      case 'register':
        setState(() {
          registerOnLoading = false;
          // _userNameController.text = '';
          _userPasswordController.text = '';
          _userPasswordRepeatController.text = '';
          // _emailController.text = '';
        });
        break;
      case 'afterRegister':
        setState(() {
          modeIsLogin = true;
          _userNameController.text = '';
          _userPasswordController.text = '';
          _userPasswordRepeatController.text = '';
          _emailController.text = '';
          _verificationController.text = '';
        });
        break;
      default:
        print('loginpage mode pramater error');
    }
  }

  _submitMailForForget(String mail) async {
    String url = '/users/emails/$mail/resetPasswordEmail';

    try {
      Response response = await dioPixivic.get(url);
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text(response.data['message']),
                actions: <Widget>[
                  FlatButton(
                    child: Text(texts.sure),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (response.statusCode == 200)
                        Navigator.of(context).pop();
                    },
                  )
                ],
              ));
    } catch (e) {
      return false;
    }
  }
}
