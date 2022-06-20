import 'dart:convert';

import 'package:caiary/data/article.dart';
import 'package:caiary/page/review_page.dart';
import 'package:caiary/page/review_update_page.dart';
import 'package:caiary/page/search_page.dart';
import 'package:caiary/ui/review_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:caiary/themes/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;

/*
네비게이션탭 첫번째
홈페이지
 */


class HomePage extends StatefulWidget {

  final int myID;

  HomePage(this.myID);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  DateTime pickeddate;
  String token;
  bool isLoading = false;
  Future<List<Article>> article;
  Future<Article> _futureArticle;

  @override
  void initState() {
    super.initState();
    pickeddate = DateTime.now();
    article = fetchArticle(pickeddate.year, pickeddate.month);
  }

  Future<List<Article>> fetchArticle(int year, int month) async {
    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();
        setState(() {token = pref.getString('_token');});
        setState(() {isLoading = true;});
      final response = await http.get(
        Uri.parse("https://caiary-server.herokuapp.com/articles/get" + "?year=$year&month=$month"),
        headers: <String, String>{
          "Authorization": 'Bearer $token',
        },
      );
      print(year);
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
              articleList.add(Article.fromJson(data[i]));
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

  Future<Article> deleteArticle(String id) async {
    final http.Response response = await http.delete(
      Uri.parse('https://caiary-server.herokuapp.com/articles/delete/$id/'),
      headers: <String, String>{
        "Authorization": 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print("good");
      return Article.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to delete album.');
    }
  }

  Future<void> _fecthlike(int id) async {
    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      if(this.mounted) {
        setState(() {
          token = pref.getString('_token');
        });
      }

      final response = await http.post(
        Uri.parse("https://caiary-server.herokuapp.com/articles/$id/like/"),
        headers: <String, String> {
          "Authorization": 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        print("unlike -> like");
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
        backgroundColor: usingColor.mainColor,
        title: Text('Caiary',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'ZR',
              fontSize: 21,
            )),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              size: 30,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => SearchPage(widget.myID)));
            },
          )
        ],
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
                        future: article,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<Article> articleLists = snapshot.data;
                            return Column(
                              children: [
                                Container(
                                  width: 330,
                                  height: 45,
                                  child: GestureDetector(
                                    child: Column(
                                      children: [
                                        Container(
                                            width: 50,
                                            height: 20,
                                            color: usingColor.lightBrown,
                                            child: Center(
                                              child: Text(
                                                "Date",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17),),
                                            )),
                                        SizedBox(height: 3,),
                                        Text(
                                          '${pickeddate.year} - ${pickeddate
                                              .month}',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      DatePicker.showPicker(context,
                                          showTitleActions: true,
                                          pickerModel: CustomMonthPicker(
                                              minTime: DateTime(2020, 1, 1),
                                              maxTime: DateTime.now(),
                                              currentTime: pickeddate
                                          ),
                                          onChanged: (date) {
                                        if(this.mounted) {
                                          setState(() {
                                            pickeddate = DateTime(
                                                date.year, date.month);
                                          });
                                        }
                                          },
                                          onConfirm: (date) {
                                        if(this.mounted){
                                          setState(() {
                                            pickeddate = DateTime(
                                                date.year, date.month);
                                            article = fetchArticle(pickeddate.year, pickeddate.month);
                                          });
                                        }

                                          },
                                          locale: LocaleType.ko,

                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 10,),
                                Column(
                                  children: [
                                    articleLists.isEmpty
                                        ? Text("작성한 리뷰가 없어요!")
                                        : ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxHeight: 450.0
                                      ),
                                      child: ListView.builder(
                                        shrinkWrap : true,
                                        itemCount: articleLists.length,
                                        itemBuilder: (context, index) {
                                          final item = articleLists[index];
                                          return ReviewCard(
                                            isMine: true,
                                            isLike: false,
                                            article: item,
                                            deletePressed: () {
                                              _futureArticle = deleteArticle(item.id.toString());
                                              if(this.mounted) {
                                                setState(() {
                                                  Navigator.pop(context);
                                                  article = fetchArticle(pickeddate.year, pickeddate.month);
                                                  if(this.mounted) {
                                                    setState(() {});
                                                  }
                                                });
                                              }
                                            },
                                            updatePressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => ReviewUpdatePage(article:item))).then((value) {
                                                    setState(() {
                                                      Navigator.pop(context);
                                                      article = fetchArticle(pickeddate.year, pickeddate.month);
                                                      if(this.mounted) {
                                                        setState(() {});
                                                      }
                                                    });
                                                  });
                                            },
                                              likePressed: (){
                                                print("d");
                                                _fecthlike(item.id).then((value) {
                                                  article = fetchArticle(pickeddate.year, pickeddate.month);
                                                  setState(() {});
                                                });
                                              },
                                            myID : widget.myID
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
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(250, 0, 0, 20),
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          child: Container(
            width: 80,
            height: 80,
            child: ClipOval(
                child: Icon(
                  Icons.add,
                  size: 30,
                  color: usingColor.mainColor,
                )
            ),
          ),
          onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReviewPage()));
                article = fetchArticle(pickeddate.year, pickeddate.month);
                  if (this.mounted) {
                    setState(() {});
                  }
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class CustomMonthPicker extends DatePickerModel {
  CustomMonthPicker({DateTime currentTime, DateTime minTime, DateTime maxTime,
    LocaleType locale}) : super(locale: locale, minTime: minTime, maxTime:
  maxTime, currentTime: currentTime);

  @override
  List<int> layoutProportions() {
    return [1, 1, 0];
  }
}
