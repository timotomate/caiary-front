import 'dart:convert';

import 'package:caiary/Data/userinfo.dart';
import 'package:caiary/data/article.dart';
import 'package:caiary/ui/follow_button.dart';
import 'package:caiary/ui/review_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:caiary/themes/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/*
상대방 프로필 페이지
 */

class Follow_Page extends StatefulWidget {

  Follow_Page(
      {
        Key key,
        this.user,
        this.myID,
        this.id

      }) : super(key: key);

  UserInfo user;
  final int myID;
  final int id;

  @override
  _Follow_PageState createState() => _Follow_PageState();
}

class _Follow_PageState extends State<Follow_Page> {

  Future<UserInfo> userInfo;
  String token;
  bool isLoading = false;
  Color buttonColor;
  Color textColor;
  UserInfo User;
  Future<List<Article>> waitingForOnlineList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    waitingForOnlineList = fetchArticle(widget.id);
    userInfo = fetchUserInfo();
    buttonColor = widget.user.followers.contains(widget.myID) ? usingColor.mainColor : Colors.white;
    textColor = widget.user.followers.contains(widget.myID) ? Colors.white : usingColor.mainColor;
  }


  Future<UserInfo> fetchUserInfo() async {
    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      setState(() {
        token = pref.getString('_token');
      });
      isLoading = true;
      final response = await http.get(
        Uri.parse("https://caiary-server.herokuapp.com/users/profile/${widget.user.id}"),
        headers: <String, String> {
          "Authorization": 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        return UserInfo.fromJson(json.decode(response.body));
      } else {
        print(response.statusCode);
        throw Exception('Failed to load post');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<UserInfo> _fecthfollow() async {
    try {
      final response = await http.post(
          Uri.parse("https://caiary-server.herokuapp.com/users/follow/${widget.user.id}/"),
          headers: <String, String> {
            "Authorization": 'Bearer $token',
          },
      );
      if (response.statusCode == 200) {
        return UserInfo.fromJson(json.decode(response.body));
      } else {
        print(response.statusCode);
        throw Exception('Failed to load post');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List<Article>> fetchArticle(int id) async {
    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      setState(() {
        token = pref.getString('_token');
        isLoading = true;
      });
      final response = await http.get(
        Uri.parse("https://caiary-server.herokuapp.com/articles/get_all/user_$id/"),
        headers: <String, String> {
          "Authorization": 'Bearer $token',
        },
      );
      print(token);
      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });

        List<Article> articleList = [];
        Map<String, dynamic> map = json.decode(response.body);
        List<dynamic> data = map["data"];

        if (data.length > 0) {
          for (int i = 0; i < data.length; i++) {
            if (data[i] != null) {
              Map<String, dynamic> map = data[i];
              articleList.add(Article.fromJson(map));
            }
          }
        }
        print(json.decode(response.body));
        return articleList;
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
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
                                children: <Widget>[
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
                                      Column(
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
                                      Column(
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
                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                  FollowButton(
                                    onPressed: () {
                                      setState(() {
                                        _fecthfollow().then((value) {
                                          userInfo = fetchUserInfo();
                                          setState(() {});
                                          buttonColor = snapshot.data.followers.contains(widget.myID) ? Colors.white : usingColor.mainColor;
                                          textColor = snapshot.data.followers.contains(widget.myID) ? usingColor.mainColor : Colors.white;
                                        });
                                      });
                                    },
                                    buttonColor: buttonColor,
                                    textColor: textColor
                                  ),
                                  SizedBox(height: 10,),
                                  Container(
                                      child: FutureBuilder<List<Article>>(
                                        future: waitingForOnlineList,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            List<Article> articleLists = snapshot.data;
                                            return Column(
                                                  children: [
                                                    articleLists.isEmpty
                                                        ? Column(
                                                          children: [
                                                            SizedBox(height: 30,),
                                                            Text("작성한 리뷰가 없어요!"),
                                                          ],
                                                        )
                                                        : ListView.builder(
                                                        physics: NeverScrollableScrollPhysics(),
                                                        shrinkWrap : true,
                                                        itemCount: articleLists.length,
                                                        itemBuilder: (context, index) {
                                                          final item = articleLists[index];
                                                          return ReviewCard(
                                                            isMine: false,
                                                            isLike: false,
                                                            article: item,
                                                          );
                                                        },
                                                      )
                                                  ],
                                                );
                                          } else if (snapshot.hasError) {
                                            return Text("${snapshot.error}");
                                          }
                                          return SizedBox();
                                        },
                                      )
                                  )
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
}
