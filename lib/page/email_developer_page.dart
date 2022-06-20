import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:caiary/themes/colors.dart';

class Email_Developer extends StatefulWidget {
  @override
  _Email_DeveloperState createState() => _Email_DeveloperState();
}

class _Email_DeveloperState extends State<Email_Developer> {
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
          title:Text('Email Developer',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'ZR',
                fontSize: 21,
              )),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Container(
                        width: 170,
                        height: 20,
                        color: usingColor.lightBrown,
                        child: Center(
                          child: Text(
                            'flutter developer',
                            style: TextStyle(color: Colors.white,fontSize: 17),),
                        )),
                    SizedBox(height: 10,),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('한예은',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                          Text('hye0403@naver.com')
                        ],
                      ),
                    SizedBox(height: 20,),
                    Container(
                        width: 170,
                        height: 20,
                        color: usingColor.lightBrown,
                        child: Center(
                          child: Text(
                            'server developer',
                            style: TextStyle(color: Colors.white,fontSize: 17),),
                        )),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('심문성',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                        Text('puterism@naver.com')
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('민성재',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                        Text('alstjdwo323@naver.com')
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
    );
  }
}
