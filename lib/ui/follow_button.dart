import 'package:flutter/material.dart';
import 'package:caiary/themes/colors.dart';

class FollowButton extends StatefulWidget {

  FollowButton(
      {
        Key key,
        this.onPressed,
        this.buttonColor,
        this.textColor

      }) : super(key: key);

  final VoidCallback onPressed;
  Color buttonColor;
  Color textColor;

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: widget.onPressed,
      padding: EdgeInsets.only(left: 18,right: 18, top: 10,bottom: 10),
      color: widget.buttonColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(color: usingColor.mainColor)
      ),
      child: Container(
          width: 300,
          height: 20,
          child: Center(
              child: Text("Follow",
                  style: TextStyle(
                      color: widget.textColor,
                      fontSize: 15,
                      fontFamily: 'ZR'
                  ))
          )
      ),
    );
  }
}
