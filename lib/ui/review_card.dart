import 'dart:convert';
import 'dart:async';
import 'package:caiary/data/article.dart';
import 'package:caiary/data/userinfo.dart';
import 'package:caiary/themes/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class ReviewCard extends StatefulWidget {
  ReviewCard(
      {
        Key key,
        @required this.isMine,
        this.isLike,
        this.article,
        this.deletePressed,
        this.updatePressed,
        this.likePressed,
        this.myID

      }) : super(key: key);
  bool isMine;
  bool isLike;
  final Article article;
  final VoidCallback deletePressed;
  final VoidCallback updatePressed;
  final VoidCallback likePressed;
  final int myID;

  @override
  _ReviewCardState createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {

  DateTime _selectedDate = DateTime.now();
  String token;
  bool isLoading = false;
  Future<UserInfo> user;
  Future<Article> article;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = fetchUserInfo();
    article = getArticle();
  }

  Future<UserInfo> fetchUserInfo() async {
    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      setState(() {
        token = pref.getString('_token');
      });
      final response = await http.get(
        Uri.parse("https://caiary-server.herokuapp.com/users/profile/${widget.article.user}"),
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

  Future<Article> getArticle() async {
    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      setState(() {
        token = pref.getString('_token');
      });
      final response = await http.get(
        Uri.parse("https://caiary-server.herokuapp.com/articles/get_single_article/${widget.article.id}/"),
        headers: <String, String> {
          "Authorization": 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return Article.fromJson(json.decode(response.body));
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
    return Container(
      child: FutureBuilder<UserInfo>(
        future: user,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            return Container(
              width: 350,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left:14.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              child: ClipOval(
                                  child: Image.network(snapshot.data.profile_image_url,fit: BoxFit.fill,)
                              ),
                            ),
                            SizedBox(width: 5,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(snapshot.data.username,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400)),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.add_location,
                                      color: Colors.grey,
                                      size: 12,
                                    ),
                                    Text(widget.article.location,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.grey)),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                        widget.isMine
                            ?IconButton(
                            iconSize: 20,
                            icon: Icon(
                              Icons.more_horiz,
                            ),
                            color: usingColor.darkBrown,
                            onPressed: (){
                              showGeneralDialog(
                                barrierLabel: "Label",
                                barrierDismissible: true,
                                barrierColor: Colors.black.withOpacity(0.5),
                                transitionDuration: Duration(milliseconds: 300),
                                context: context,
                                pageBuilder: (context, anim1, anim2) {
                                  return Material(
                                    type: MaterialType.transparency,
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        height: 150,
                                        child: SizedBox.expand(
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  InkWell(
                                                      child: Text(
                                                        "삭제",
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.deepOrangeAccent,
                                                            fontFamily: 'ZR'
                                                        ),
                                                      ),
                                                      onTap: widget.deletePressed
                                                  ),
                                                  Container(
                                                    height: 0.8,
                                                    color: Colors.grey,
                                                  ),
                                                  InkWell(
                                                      child: Text(
                                                        "수정",
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.black,
                                                            fontFamily: 'ZR'
                                                        ),
                                                      ),
                                                      onTap: widget.updatePressed
                                                  ),
                                                  Container(
                                                    height: 0.8,
                                                    color: Colors.grey,
                                                  ),
                                                  InkWell(
                                                    child: Text(
                                                      "취소",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                          fontFamily: 'ZR'
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      Navigator.of(context).pop(true);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )
                                        ),
                                        margin: EdgeInsets.only(bottom: 50, left: 12, right: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                transitionBuilder: (context, anim1, anim2, child) {
                                  return SlideTransition(
                                    position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
                                    child: child,
                                  );
                                },
                              );
                            }
                        )
                            : SizedBox()
                      ],
                    ),
                  ),
                  SafeArea(
                    child: Stack(
                      children: [
                        isLoading
                            ? Center(
                            child: CircularProgressIndicator(
                              color: usingColor.mainColor,
                            )
                        )
                            :  Container(
                            child: FutureBuilder<Article>(
                              future: article,
                              builder: (context, snapshot) {
                                if(snapshot.hasData){
                                  return Column(
                                    children: [
                                      SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 15.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                                (widget.article.emotion == "good") ? Icons.sentiment_satisfied_alt_outlined : (widget.article.emotion == "soso") ? Icons.sentiment_neutral_outlined : Icons.sentiment_dissatisfied_outlined
                                            ),
                                            SizedBox(width: 6,),
                                            Text(
                                              (widget.article.emotion == "good") ? "기분 좋은 날" : (widget.article.emotion == "soso") ? "그저그런 날" : "우울한 날",
                                            )
                                          ],
                                        ),
                                      ),
                                      widget.article.menu == ""
                                          ? SizedBox()
                                          : Padding(
                                        padding: const EdgeInsets.only(left: 15.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.local_cafe_outlined),
                                            SizedBox(width: 6,),
                                            Text(
                                                widget.article.menu
                                            )
                                          ],
                                        ),
                                      ),
                                      widget.article.song.isEmpty
                                          ? SizedBox()
                                          : Padding(
                                        padding: const EdgeInsets.only(left: 15.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.music_note),
                                            SizedBox(width: 6,),
                                            Text(
                                                widget.article.song
                                            )
                                          ],
                                        ),
                                      ),
                                      widget.article.weather.isEmpty
                                          ? SizedBox()
                                          : Padding(
                                        padding: const EdgeInsets.only(left: 15.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                                (widget.article.weather == "Sunny") ? Icons.wb_sunny : (widget.article.weather == "Cloudy") ? Icons.wb_cloudy : (widget.article.weather == "Rain") ? Icons.beach_access : (widget.article.weather == "Windy") ? Icons.air : Icons.ac_unit
                                            ),
                                            SizedBox(width: 6,),
                                            Text(
                                                (widget.article.weather == "Sunny") ? "날씨 좋은 날" : (widget.article.weather == "Cloudy") ? "흐린 날" : (widget.article.weather == "Rain") ? "비오는 날" : (widget.article.weather == "Windy") ? "바람부는 날" : "눈오는 날"
                                            )
                                          ],
                                        ),
                                      ),
                                      widget.article.point==0
                                          ? SizedBox()
                                          : Padding(
                                        padding: const EdgeInsets.only(left: 15.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.star),
                                            SizedBox(width: 6,),
                                            Text(widget.article.point.toString(),style: TextStyle(color: Colors.deepOrange),),
                                            Text(" / 5")
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                      Stack(
                                        children: [
                                          Center(
                                            child: Container(
                                                width: 340,
                                                height: 260,
                                                child: Image.network(
                                                  widget.article.image,
                                                  fit: BoxFit.fill,
                                                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress){
                                                    if(loadingProgress == null){
                                                      return child;
                                                    }
                                                    return Center(
                                                      child: CircularProgressIndicator(
                                                        color: usingColor.mainColor,
                                                        value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes : null,
                                                      ),
                                                    );
                                                  },
                                                )
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment(0.8, -1.0),
                                            child: IconButton(
                                              onPressed: widget.likePressed,
                                              icon: Icon((widget.article.liked.contains(widget.myID))?Icons.favorite:Icons.favorite_border),
                                              color: usingColor.lightBrown,
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.only(left:15.0,right: 15.0),
                                        child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  maxHeight: 300.0
                                              ),
                                              child: Text(
                                                widget.article.content.isEmpty ? "" : widget.article.content,
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            )

                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Align(
                                        alignment: Alignment(-0.9, 0.0),
                                        child: Text(
                                          widget.article.created.split('T')[0],
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10,)
                                    ],
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
                  )
                ],
              ),
            );
          }
          else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return SizedBox();
        },
      ),
    );

  }
}
