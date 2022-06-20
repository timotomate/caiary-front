import 'package:flutter/material.dart';
import 'package:caiary/themes/colors.dart';

/*
* 버튼 Ui
* */

class MyButton extends StatelessWidget {
  final double widthSize;
  final double heightSize;
  final VoidCallback onPressed;
  final bool isColor;
  final String text;
  final Widget child;
  final double textSize;
  final double sidepadding;
  final double toppadding;
  final Color textcolor;
  final Color backgroundcolor;
  MyButton({
    this.text,
    this.widthSize = 320,
    this.heightSize = 40,
    this.isColor = false,
    this.textSize = 15,
    this.sidepadding = 18.0,
    this.toppadding = 10,
    @required this.onPressed,
    @required this.child,
    this.textcolor = Colors.black,
    this.backgroundcolor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: this.onPressed,
      padding: EdgeInsets.only(left: sidepadding,right: sidepadding, top: toppadding,bottom: toppadding),
      color: isColor ? usingColor.mainColor : backgroundcolor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(color: usingColor.mainColor)
      ),
      child: Container(
          width: widthSize,
          height: heightSize,
          child: Center(
              child: Text(text,
                  style: TextStyle(
                      color: isColor ? Colors.white : usingColor.mainColor,
                      fontSize: textSize,
                      fontFamily: 'ZR'
                  ))
          )
      ),
    );
  }
}
