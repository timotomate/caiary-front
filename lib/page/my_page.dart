import 'dart:convert';

import 'package:caiary/Data/userinfo.dart';
import 'package:caiary/page/email_developer_page.dart';
import 'package:caiary/page/my_follower_page.dart';
import 'package:caiary/ui/my_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:caiary/themes/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'my_following_page.dart';
import 'package:http/http.dart' as http;

/*
내정보 페이지.
네비게이션바 세번째버튼 탭
 */

class MyPage extends StatefulWidget {

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {

  Future<UserInfo> userInfo;
  String token;
  bool isLoading = false;

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
        print(json.decode(response.body));
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
    return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              elevation: 0.0,
              backgroundColor: usingColor.mainColor,
              title:Text('Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'ZR',
                    fontSize: 21,
                  )),
            ),
            body: SafeArea(
                  child: Stack(
                    children: [
                      isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: usingColor.mainColor,
                          )
                      )
                      : SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child : Container(
                                child: FutureBuilder<UserInfo>(
                                  future: userInfo,
                                  builder: (context, snapshot) {
                                    if(snapshot.hasData){
                                      return Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Column(
                                                children: [
                                                  Container(
                                                    width: 64,
                                                    height: 64,
                                                    child: ClipOval(
                                                        child: Image.network(snapshot.data.profile_image_url.toString(),fit: BoxFit.fill,)
                                                    ),
                                                  ),
                                                  SizedBox(height: 8,),
                                                  Text(snapshot.data.username.toString(),style: TextStyle(fontWeight:FontWeight.bold,fontFamily: 'ZR'),)
                                                ],
                                              ),
                                              InkWell(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      '팔로워',
                                                      style:TextStyle(fontSize: 13),
                                                    ),
                                                    SizedBox(height: 4,),
                                                    Text( snapshot.data.followers.length.toString(),
                                                      style:TextStyle(fontSize: 20,fontWeight: FontWeight.w400),
                                                    ),
                                                  ],
                                                ),
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(builder: (_) => MyFollowerPage(snapshot.data.followers, snapshot.data.id))
                                                  ).then((value) {
                                                    setState(() {
                                                      userInfo = fetchUserInfo();
                                                    });
                                                  });
                                                },
                                              ),
                                              InkWell(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      '팔로잉',
                                                      style:TextStyle(fontSize: 13),
                                                    ),
                                                    SizedBox(height: 4,),
                                                    Text( snapshot.data.followings.length.toString(),
                                                      style:TextStyle(fontSize: 20,fontWeight: FontWeight.w400),
                                                    ),
                                                  ],
                                                ),
                                                onTap: (){
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(builder: (_) => MyFollowingPage(snapshot.data.followings, snapshot.data.id))
                                                  ).then((value) {
                                                    setState(() {
                                                      print(snapshot.data.followings);
                                                      userInfo = fetchUserInfo();
                                                    });
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20,),
                                          MyButton(
                                              widthSize: 275,
                                              heightSize: 20,
                                              text: '로그아웃',
                                              onPressed: logoutAlertDialog
                                          ),
                                          MyButton(
                                              widthSize: 275,
                                              heightSize: 20,
                                              text: '개발자에게 이메일 보내기',
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    CupertinoPageRoute(
                                                        builder: (context) => Email_Developer()));
                                              }
                                          ),
                                        ],
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text("${snapshot.error}");
                                    }
                                    return SizedBox();
                                  },
                                )
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
    );
  }

  logoutAlertDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState){
                    return Container(
                      width: 300.0,
                      height: 100,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(),
                            Text('정말 로그아웃 하시겠어요?'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: 100,
                                  height: 40,
                                  child: MyButton(
                                    text: '네',
                                    isColor: true,
                                    onPressed: (){
                                      token = "";
                                      while(Navigator.canPop(context)) {
                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  height: 40,
                                  child: MyButton(
                                    text: '아니요',
                                    isColor: true,
                                    onPressed: (){
                                      Navigator.of(context).pop(true);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }
              )
          );
        });
  }
}
