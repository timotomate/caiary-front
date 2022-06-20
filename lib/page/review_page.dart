import 'dart:io';
import 'package:caiary/data/article.dart';
import 'package:caiary/ui/my_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:caiary/themes/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';


/*
리뷰 페이지
* 사진 넣기
* 리뷰 작성
 */

class ReviewPage extends StatefulWidget {
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  TextEditingController controller = TextEditingController();
  TextEditingController location_controller = TextEditingController();
  TextEditingController menu_controller = TextEditingController();
  TextEditingController music_controller = TextEditingController();


  bool feeling_good;
  bool feeling_soso;
  bool feeling_bad;

  bool menu;
  bool weather;
  bool music;
  bool rating;

  bool sunny;
  bool cloudy;
  bool windy;
  bool rain;
  bool snow;

  double userRating=3.0;

  String token;
  bool isLoading = false;
  DateTime _selectedDate = DateTime.now();

  Article myArticle = new Article();
  final _picker = ImagePicker();
  XFile _image;

  bool check = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myArticle.location = "";
    myArticle.emotion = "";
    myArticle.weather="";
    myArticle.point=0;
    myArticle.menu="";
    myArticle.song="";
    myArticle.content="";

    feeling_good = true;
    feeling_soso = feeling_bad = false;
    menu = weather = music = rating = false;
    sunny = cloudy = windy = rain = snow = false;
  }

  Future<void> postRequest() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      token = pref.getString('_token');
      isLoading = true;
    });

    final filePath = _image.path;
    var formData = FormData.fromMap({
      'data' : '{ "emotion" : "${myArticle.emotion}", "location" : "${myArticle.location}", "menu" : "${myArticle.menu}", "weather" : "${myArticle.weather}", "song" : "${myArticle.song}", "point" : "${myArticle.point}", "content" : "${myArticle.content}"}',

      'image': await MultipartFile.fromFile(filePath)
    });
    try{
    var dio = Dio();
    var response = await dio.post(
        'https://caiary-server.herokuapp.com/articles/post/',
        data: formData,
        options: Options(
            headers: {"Authorization": 'Bearer $token'}
        )
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
    } else {
      print(response.statusCode);
    }
    }
    catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: usingColor.mainColor),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        title: Text(
          'Review',
          style: TextStyle(color: usingColor.mainColor),
          textAlign: TextAlign.center,
        ),
      ),
      body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: usingColor.mainColor,
                            ),
                            SizedBox(width: 13,),
                            InkWell(
                              child: Text(
                                DateFormat('yyyy년 MM월 dd일').format(_selectedDate),
                                style: TextStyle(
                                    fontSize: 18
                                ),
                              ),
                              onTap: () {
                                Future<DateTime> future = showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2018),
                                  lastDate: DateTime.now(),
                                  builder: (BuildContext context, Widget child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: usingColor.lightBrown, // header background color
                                          onPrimary: Colors.white, // header text color
                                          onSurface: Colors.black, // body text color
                                        ),
                                        textButtonTheme: TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            primary: usingColor.darkBrown, // button text color
                                          ),
                                        ),
                                      ),
                                      child: child,
                                    );
                                  },
                                );
                                future.then((date) {
                                  setState(() {
                                    if(date != null) {
                                      _selectedDate = date;
                                    }
                                    else {
                                      return null;
                                    }
                                  });
                                });
                              },
                            ),
                          ],
                        ),
                        IconButton(
                            color: usingColor.mainColor,
                            iconSize: 30,
                            icon: Icon(
                                (feeling_good == true) ? Icons.sentiment_satisfied_alt_outlined : (feeling_soso == true) ? Icons.sentiment_neutral_outlined : Icons.sentiment_dissatisfied_outlined
                            ),
                            onPressed: openAlertBox,
                          ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_location,
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
                                hintText: "카페 위치를 입력해보세요",
                              ),
                              controller: location_controller),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20,),
                    menu == true ?
                    Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_cafe,
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
                                    hintText: "무슨 커피를 마셨나요?",
                                  ),
                                  controller: menu_controller,),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20,)
                      ],
                    ):
                    SizedBox(),
                    music == true ?
                    Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.music_note,
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
                                    hintText: "어떤 노래를 듣고 있나요?",
                                  ),
                                  controller: music_controller,),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20,)
                      ],
                    ):
                    SizedBox(),
                    weather == true?
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('오늘의 날씨를 선택해주세요.',),
                          ],
                        ),
                        SizedBox(height: 5),
                            Container(
                              width: 300,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    color: sunny == true ? usingColor.darkBrown : usingColor.mainColor,
                                    iconSize: 35,
                                    icon: const Icon(Icons.wb_sunny),
                                    onPressed: () {
                                      setState(() {
                                        sunny = true;
                                        cloudy = rain = windy =  snow = false;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    color: cloudy == true ? usingColor.darkBrown : usingColor.mainColor,
                                    iconSize: 35,
                                    icon: const Icon(Icons.wb_cloudy),
                                    onPressed: () {
                                      setState(() {
                                        cloudy = true;
                                        sunny = rain = windy = snow = false;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    color: windy == true ? usingColor.darkBrown : usingColor.mainColor,
                                    iconSize: 35,
                                    icon: const Icon(Icons.air),
                                    onPressed: () {
                                      setState(() {
                                        windy = true;
                                        sunny = rain = cloudy = snow = false;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    color: rain == true ? usingColor.darkBrown : usingColor.mainColor,
                                    iconSize: 35,
                                    icon: const Icon(Icons.beach_access),
                                    onPressed: () {
                                      setState(() {
                                        rain = true;
                                        sunny = cloudy = windy = snow = false;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    color: snow == true ? usingColor.darkBrown : usingColor.mainColor,
                                    iconSize: 35,
                                    icon: const Icon(Icons.ac_unit),
                                    onPressed: () {
                                      setState(() {
                                        snow = true;
                                        sunny = cloudy = windy = rain = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                        SizedBox(height: 20,)
                      ],
                    ):
                    SizedBox(),
                    rating == true ?
                    Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('평가하시려면 별표를 탭하세요.'),
                              SizedBox(width: 80),
                              Row(
                                children: <Widget>[
                                  Text('${userRating}',
                                      style: TextStyle(color: usingColor.darkBrown)),
                                  Text('/5')
                                ],
                              ), //${userRating}
                            ]),
                        SizedBox(height: 5),
                        RatingBar.builder(
                          initialRating: 3,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: usingColor.darkBrown,
                          ),
                          onRatingUpdate: (rating) {
                            userRating = rating;
                            setState(() {});
                          },
                        ),
                        SizedBox(height: 20,)
                      ],
                    ):
                    SizedBox(),
                    Container(
                      width: 330,
                      height: 30,
                      child: RaisedButton(
                          child: Icon(
                            Icons.add
                          ),
                          color: usingColor.mainColor,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          ),
                          onPressed: openPlusBox
                      ),
                    ),
                    SizedBox(height: 20,),
                    InkWell(
                      child: Container(
                        height: 300,
                        width: 330,
                        decoration: BoxDecoration(
                            border: Border.all(color: usingColor.mainColor)
                        ),
                        child: _image == null
                              ? Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: usingColor.mainColor,
                          )
                              : Image.file(File(_image.path))
                      ),
                        onTap: _getImage,
                    ),
                    SizedBox(height: 20,),
                    Container(
                      width: 330,
                      child: new ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 300.0
                        ),
                        child: TextField(
                          maxLines: null,
                          maxLength: 300,
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
                            hintText: "이 날 갔던 카페는 어땠나요?",
                          ),
                          controller: controller,),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      width: 330,
                      height: 50,
                      child: RaisedButton(
                          child: Text(
                            '입력 완료'
                          ),
                          color: usingColor.mainColor,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          onPressed: () async {
                            if(check) {
                              myArticle.emotion = (feeling_good == true) ? "good" : (feeling_soso == true) ? "soso" : "bad";
                              myArticle.location = location_controller.text;
                              menu? myArticle.menu = menu_controller.text : "";
                              weather? myArticle.weather = sunny? "Sunny" : cloudy? "Cloudy" : rain? "Rain" : windy? "Windy" : "Snow" : "";
                              music? myArticle.song = music_controller.text : "";
                              rating? myArticle.point = userRating.toInt() : 0;
                              myArticle.content = controller.text;
                              await postRequest();
                              Navigator.pop(context);
                            }
                            else {
                              scaffoldKey.currentState.showSnackBar(
                                  SnackBar(duration: const Duration(milliseconds: 600),
                                    content: Text(
                                        "리뷰 사진을 넣어주세요!"
                                    ),
                                    backgroundColor: usingColor.lightBrown,
                                  )
                              );
                            }

                          }),
                    ),
                    SizedBox(height: 20,)
                  ],
                ),
              ),
            ),
          )
    );
  }
  openAlertBox() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.only(bottom: 10.0),
            content: Container(
              width: 300.0,
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                    decoration: BoxDecoration(
                      color: usingColor.mainColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32.0),
                          topRight: Radius.circular(32.0)),
                    ),
                    child: Text(
                      "오늘의 기분",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15.0, left: 30.0, right: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          color: feeling_good == true ? usingColor.darkBrown : usingColor.mainColor,
                          iconSize: 35,
                          icon: const Icon(Icons.sentiment_satisfied_alt_outlined),
                          onPressed: () {
                            setState(() {
                              feeling_good = true;
                              feeling_soso = feeling_bad = false;
                              Navigator.of(context).pop(true);
                            });
                          },
                        ),
                        IconButton(
                          color: feeling_soso == true ? usingColor.darkBrown : usingColor.mainColor,
                          iconSize: 35,
                          icon: const Icon(Icons.sentiment_neutral_outlined),
                          onPressed: () {
                            setState(() {
                              feeling_soso = true;
                              feeling_good = feeling_bad = false;
                              Navigator.of(context).pop(true);
                            });
                          },
                        ),
                        IconButton(
                          color: feeling_bad == true ? usingColor.darkBrown : usingColor.mainColor,
                          iconSize: 35,
                          icon: const Icon(Icons.sentiment_dissatisfied_outlined),
                          onPressed: () {
                            setState(() {
                              feeling_bad = true;
                              feeling_good = feeling_soso = false;
                              Navigator.of(context).pop(true);
                            });
                          },
                        ),
                      ],
                    )
                  ),
                ],
              ),
            ),
          );
        });
  }

  openPlusBox() {
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
                  height: 250,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                              width: 100,
                              height: 40,
                              child: MyButton(
                                text: '#주문한 메뉴',
                                isColor: menu? true: false,
                                onPressed: (){
                                  setState(() {
                                    menu = (menu)? false : true;
                                  });
                                },
                              ),
                            ),
                            Container(
                              width: 100,
                              height: 40,
                              child: MyButton(
                                text: '#현재 BGM',
                                isColor: music? true: false,
                                onPressed: (){
                                  setState(() {
                                    music = (music)? false : true;
                                  });
                                },
                              ),
                            ),
                            Container(
                              width: 100,
                              height: 40,
                              child: MyButton(
                                text: '#날씨',
                                isColor: weather? true: false,
                                onPressed: (){
                                  setState(() {
                                    weather = (weather)? false : true;
                                  });
                                },
                              ),
                            ),
                            Container(
                              width: 100,
                              height: 40,
                              child: MyButton(
                                text: '#평점',
                                isColor: rating? true: false,
                                onPressed: (){
                                  setState(() {
                                    rating = (rating)? false : true;
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 40,
                        child: MyButton(
                          text: '완료',
                          isColor: true,
                          onPressed: (){
                            //myArticle.image = Image.flie();
                            Navigator.of(context).pop(true);
                            _update();
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
            )
          );
        });
  }

  Future _getImage() async {
    XFile image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
    check = (_image!=null) ? true : false;
  }

  void _update() { setState(() {  }); }

}


