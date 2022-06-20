import 'dart:convert';

import 'package:caiary/Data/userinfo.dart';
import 'package:caiary/ui/search_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:caiary/themes/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'follow_page.dart';

/*
홈페이지 오른쪽 위에
닉네임 검색하는 페이지
 */

class SearchPage extends StatefulWidget {
  final int myID;

  SearchPage(this.myID);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController controller = TextEditingController();
  Future<List<UserInfo>> userInfo;
  String token;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    userInfo = fetchUserInfo(controller.toString());
  }

  Future<List<UserInfo>> fetchUserInfo(String searchname) async {
    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      setState(() {
        token = pref.getString('_token');
      });
      isLoading = true;
      Map<String, String> queryParams = {
        'username': searchname
      };
      String queryString = Uri(queryParameters: queryParams).query;
      final response = await http.get(
        Uri.parse("https://caiary-server.herokuapp.com/users/search/"+"?"+queryString),
        headers: <String, String> {
          "Authorization": 'Bearer $token',
        },
      );
      print(token);
      if (response.statusCode == 200) {
        setState(() {isLoading = false;});
        List<UserInfo> searchList = [];
        Map<String, dynamic> map = json.decode(response.body);
        List<dynamic> data = map["data"];

        if(data.length>0){
          for(int i=0;i<data.length;i++){
            if(data[i]!=null){
              Map<String,dynamic> map=data[i];
              searchList.add(UserInfo.fromJson(map));
            }
          }
        }
        print(json.decode(response.body));
        return searchList;
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
              Navigator.of(context).pop(true);
            },
          ),
          title:Text('Search',
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
                        child: FutureBuilder<List<UserInfo>>(
                          future: userInfo,
                          builder: (context, snapshot) {
                            if(snapshot.hasData){
                              List<UserInfo> searchLists = snapshot.data;
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search,
                                        color: usingColor.mainColor,
                                        size: 28,
                                      ),
                                      SizedBox(width: 8,),
                                      Container(
                                        width: 300,
                                        child: new ConstrainedBox(
                                          constraints: BoxConstraints(
                                              maxHeight: 300.0
                                          ),
                                          child: TextField(
                                            maxLines: null,
                                            cursorColor: usingColor.mainColor,
                                            style: TextStyle(color: Colors.black,fontFamily: 'ZR'),
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.only(left: 10,top: 10),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(color: usingColor.mainColor, width: 1.0),
                                                borderRadius: const BorderRadius.all(
                                                  const Radius.circular(10.0),
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: usingColor.mainColor, width: 1.0),
                                                borderRadius: const BorderRadius.all(
                                                  const Radius.circular(10.0),
                                                ),
                                              ),
                                              fillColor: usingColor.mainColor,
                                              hintText: "닉네임을 검색해보세요.",
                                            ),
                                            controller: controller,
                                            onChanged: (text) {
                                              if(text != null && text != '') {
                                                userInfo = fetchUserInfo(text);
                                                fetchUserInfo(text).then((value) {
                                                  searchLists = value;
                                                  setState(() {});
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                  Column(
                                    children: [
                                      searchLists.isEmpty
                                       ? Text("찾는 닉네임이 없어요!")
                                          : Container(
                                              width: MediaQuery.of(context).size.width,
                                              height: MediaQuery.of(context).size.height,
                                              child: ListView.builder(
                                                  itemCount: searchLists.length,
                                                   itemBuilder: (context, index) {
                                                      final item = searchLists[index];
                                                      return SearchItem(
                                                        user: item,
                                                        onPressed: (){
                                                          Navigator.push(
                                                           context,
                                                           MaterialPageRoute(builder: (context) => Follow_Page(user: item,myID: widget.myID,id:item.id)));
                                                      },
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