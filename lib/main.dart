import 'package:caiary/page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

void main() {
  KakaoSdk.init(nativeAppKey: 'd39af0846803fe902a29840b09b7edc0');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caiary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'ZR',
      ),
      home: LoginPage(),
    );
  }
}