
import 'package:caiary/page/taproot_page.dart';
import 'package:caiary/ui/my_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:caiary/themes/colors.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/*
로그인페이지
- 앱 실행시 제일 먼저 뜨는 화면
- 전화번호 로그인, 회원가입 두가지 기능
 */

class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  static void updateToken(String token) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('_token', token);
  }

  Future<void> _loginButtonPressed() async {
    try {
      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      print('카카오계정으로 로그인 성공 ${token.accessToken}');
      User user = await UserApi.instance.me();

      final response = await http.post(
        Uri.parse("https://caiary-server.herokuapp.com/users/login/kakao/"),
        headers: <String, String> {
          "Authorization": 'Bearer ${token.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        updateToken(json.decode(response.body)['access_token']);
        print(json.decode(response.body)['access_token']);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TabRootPage(user)
            ));
        return LoginResponse.fromJson(json.decode(response.body));
      } else {
        print(response.statusCode);
        throw Exception('Failed to load post');
      }
    } catch (error) {
      print('카카오계정으로 로그인 실패 $error');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 80,),
                Stack(
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 2,),
                        Text(
                          'Caiary',
                          style: TextStyle(color: Colors.white,fontFamily: 'ZR',fontSize: 40),),
                      ],
                    ),
                    Text(
                      'Caiary',
                      style: TextStyle(color: usingColor.mainColor,fontFamily: 'ZR',fontSize: 40),),
                  ],
                ),
                SizedBox(height: 200,),
                MyButton(
                  widthSize: 295,
                  heightSize: 30,
                  isColor: true,
                  textSize: 18,
                  onPressed: _loginButtonPressed,
                  text: 'Sign in',
                ),
                SizedBox(height: 100,),
                Text(
                  'Copyright\u00a92022 Project.\nAll rights reserved',
                  style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.black
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginResponse {
  final bool success;
  final String email;
  final String access_token;

  LoginResponse({this.success, this.email, this.access_token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'],
      email: json['email'],
      access_token: json['access_token'],
    );
  }
}