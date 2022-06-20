import 'dart:convert';

import 'package:caiary/data/article.dart';
import 'package:caiary/ui/review_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:caiary/themes/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/*
피드 페이지.
네비게이션바 두번째버튼 탭
 */


class FeedPage extends StatefulWidget {
  final int myID;

  FeedPage(this.myID);

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {

  String token;
  bool isLoading = false;
  Future<List<Article>> waitingForOnlineList;

  @override
  void initState() {
    super.initState();
    waitingForOnlineList = fetchArticle();
  }

  Future<List<Article>> fetchArticle() async {
    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      setState(() {
        token = pref.getString('_token');
        isLoading = true;
      });

      final response = await http.get(
          Uri.parse("https://caiary-server.herokuapp.com/articles/get_all/"),
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

  Future<void> _fecthlike(int id) async {
    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      setState(() {
        token = pref.getString('_token');
      });
      final response = await http.post(
        Uri.parse("https://caiary-server.herokuapp.com/articles/$id/like/"),
        headers: <String, String> {
          "Authorization": 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        print("unlike -> like");
        print(json.decode(response.body));
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
          title:Text('Feed',
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
                    child: Container(
                        child: FutureBuilder<List<Article>>(
                          future: waitingForOnlineList,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<Article> articleLists = snapshot.data;
                              return Column(
                                children: [
                                  Column(
                                    children: [
                                      articleLists.isEmpty
                                          ? Text("작성한 리뷰가 없어요!")
                                          : ConstrainedBox(
                                        constraints: BoxConstraints(
                                            maxHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height/4,
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap : true,
                                          itemCount: articleLists.length,
                                          itemBuilder: (context, index) {
                                            final item = articleLists[index];
                                            return ReviewCard(
                                              isMine: false,
                                              isLike: false,
                                              article: item,
                                              likePressed: (){
                                                print("d");
                                                _fecthlike(item.id).then((value) {
                                                  waitingForOnlineList = fetchArticle();
                                                  setState(() {});
                                                });
                                              },
                                              myID: widget.myID,
                                            );
                                          },
                                        ),
                                      )
                                    ],
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