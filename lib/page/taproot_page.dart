import 'dart:convert';

import 'package:caiary/data/userinfo.dart';
import 'package:caiary/page/feed_page.dart';
import 'package:caiary/page/home_page.dart';
import 'package:caiary/page/my_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:caiary/themes/colors.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/*
로그인후에는 이 페이지로 이동함.
네비게이션바를 표시하고 누른 버튼에 따른 탭을 이 위에 표시함.
 */

class TabRootPage extends StatefulWidget {
  final User user;

  TabRootPage(this.user);

  @override
  _TabRootPageState createState() => _TabRootPageState();
}
class _TabRootPageState extends State<TabRootPage> {
  int currentIndex = 0;
  Future<UserInfo> userInfo;
  String token;
  bool isLoading = false;
  Widget child = Container();
  int myID;

  @override
  void initState() {
    super.initState();
    userInfo = fetchUserInfo();
  }

  Future<UserInfo> fetchUserInfo() async {
    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      setState(() {
        token = pref.getString('_token');
      });
      isLoading = true;
      final response = await http.get(
        Uri.parse("https://caiary-server.herokuapp.com/users/me/"),
        headers: <String, String> {
          "Authorization": 'Bearer $token',
        },
      );
      print(token);
      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        myID = UserInfo.fromJson(json.decode(response.body)).id;
        return UserInfo.fromJson(json.decode(response.body));
      } else {
        print(response.statusCode);
        throw Exception('Failed to load post');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    switch(currentIndex){
      case 0 :
        child = HomePage(myID);
        break;

      case 1 :
        child = FeedPage(myID);
        break;

      case 2 :
        child = MyPage();
        break;
    }
    return Scaffold(
        body: SizedBox.expand(
          child : child
        ),
        bottomNavigationBar: SizedBox(
          height: MediaQuery.of(context).size.height/10,
          child: BottomNavigationBar(
            onTap: (int index) {
              setState(() {
                currentIndex = index;
              });
            },
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: usingColor.mainColor,
            unselectedItemColor: Colors.grey,
            currentIndex: currentIndex,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedFontSize: 0,
            unselectedFontSize: 0,
            iconSize: 23,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                label: ""
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.supervisor_account),
                  label: ""
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle),
                  label: ""
              ),
            ],
          ),
        )
    );
  }
}
