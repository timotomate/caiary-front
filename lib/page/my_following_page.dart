import 'package:caiary/Data/userinfo.dart';
import 'package:caiary/page/follow_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:caiary/themes/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/*
내 팔로잉 확인 페이지
 */

class MyFollowingPage extends StatefulWidget {
  List<dynamic> followingList;
  final int myID;

  MyFollowingPage(this.followingList, this.myID);

  @override
  _MyFollowingPageState createState() => _MyFollowingPageState();
}

class _MyFollowingPageState extends State<MyFollowingPage> {
  String token;
  bool isLoading = false;
  Future<List<UserInfo>> waitingForOnlineList;
  List<dynamic> list;


  @override
  void initState() {
    super.initState();
    list = widget.followingList;
    waitingForOnlineList = _fetchUserInfo();
  }

  Future<List<UserInfo>> _fetchUserInfo() async {
    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      setState(() {token = pref.getString('_token');});
      var body = jsonEncode({"id_list": list});
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
        List<UserInfo> followings = [];
        Map<String, dynamic> map = json.decode(response.body);
        List<dynamic> data = map["data"];

        if(data.length>0){
          for(int i=0;i<data.length;i++){
            if(data[i]!=null){
              Map<String,dynamic> map=data[i];
              followings.add(UserInfo.fromJson(map));
            }
          }
        }
        print(jsonDecode(response.body));
        return followings;
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
          title:Text('My Following',
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
                                List<UserInfo> followings = snapshot.data;
                                return followings.isEmpty
                                    ? Center(child: Text("팔로잉하는 사람이 없어요!"))
                                    : Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  child: ListView.builder(
                                    itemCount: followings.length,
                                    itemBuilder: (context, index) {
                                      var item = followings[index];
                                      return ListTile(
                                          title:Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(width: 20),
                                              Container(
                                                width: 55.0,
                                                height: 55.0,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: NetworkImage(item.profile_image_url),
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius: BorderRadius.all( Radius.circular(50.0)),
                                                  border: Border.all(
                                                    color: usingColor.lightBrown,
                                                    width: 1.3,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 20),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(item.username,style: TextStyle(color: Colors.black,fontSize: 17),),
                                                ],
                                              )
                                            ],
                                          ),
                                          onTap: () async {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => Follow_Page(user: item,myID: widget.myID,id:item.id))).then((value) {
                                            //print(value);
                                          });
                                        },
                                      );
                                    },
                                  )
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