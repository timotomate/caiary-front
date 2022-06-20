import 'dart:convert';

import 'package:caiary/Data/userinfo.dart';
import 'package:caiary/page/follow_page.dart';
import 'package:caiary/ui/search_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:caiary/themes/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/*
내 팔로워 확인 페이지
 */

class MyFollowerPage extends StatefulWidget {
  final List<dynamic> followerList;
  final int myID;

  MyFollowerPage(this.followerList, this.myID);

  @override
  _MyFollowerPageState createState() => _MyFollowerPageState();
}

class _MyFollowerPageState extends State<MyFollowerPage> {
  String token;
  bool isLoading = false;
  Future<List<UserInfo>> waitingForOnlineList;

  @override
  void initState() {
    super.initState();
    waitingForOnlineList = _fetchUserInfo();
  }
  Future<List<UserInfo>> _fetchUserInfo() async {
    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      setState(() {token = pref.getString('_token');});
      var body = jsonEncode({"id_list": widget.followerList});
      setState(() {isLoading = true;});

      final response = await http.post(
        Uri.parse("https://caiary-server.herokuapp.com/users/list/"),
        headers: <String, String> {
          "Authorization": 'Bearer $token',
        },
        body: body
      );
      if (response.statusCode == 200) {
        setState(() {isLoading = false;});
        List<UserInfo> followers = [];
        Map<String, dynamic> map = json.decode(response.body);
        List<dynamic> data = map["data"];
        if(data.length>0){
          for(int i=0;i<data.length;i++){
            if(data[i]!=null){
              Map<String,dynamic> map=data[i];
              followers.add(UserInfo.fromJson(map));
            }
          }
        }
        return followers;
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
            onPressed: (){
              setState(() {
                Navigator.of(context).pop(true);
              });
            },
          ),
          title:Text('My Follower',
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
                    child: Column(
                      children: <Widget>[
                        Container(
                            child: FutureBuilder<List<UserInfo>>(
                              future: waitingForOnlineList,
                              builder: (context, snapshot) {
                                if(snapshot.hasData){
                                  List<UserInfo> followers = snapshot.data;
                                  return followers.isEmpty
                                      ? Center(child: Text("팔로워하는 사람이 없어요!"))
                                      : Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    child: ListView.builder(
                                      itemCount: followers.length,
                                      itemBuilder: (context, index) {
                                        final item = followers[index];
                                        return SearchItem(
                                            user: item,
                                          onPressed: (){
                                              setState(() {});
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => Follow_Page(user: item,myID: widget.myID,id: item.id))
                                                ).then((value) {
                                                  setState(() {
                                                  waitingForOnlineList = _fetchUserInfo();
                                              });
                                            });
                                          },
                                         );
                                      },
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text("${snapshot.error}");
                                }
                                return SizedBox();
                              },
                            )
                        ),

                      ],
                    ),
                ),
              )
            ],
          ),
        )
    );
  }
}