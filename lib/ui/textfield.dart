import 'package:flutter/material.dart';
import 'package:caiary/themes/colors.dart';

/*
텍스트필드 ui
 */

class MakeTextField extends StatelessWidget {
  final TextEditingController textEditingController;
  final Function(String) onSubmitted;
  final Function(String) onChanged;
  final String hintText;
  final double width;
  final double height;
  final TextStyle hintStyle;
  final double left;
  final TextInputType inputType;
  final int maxLength;
  final Color backgroundcolor;

  MakeTextField(
      {@required this.textEditingController,
        this.onSubmitted,
        this.onChanged,
        this.hintText = "",
        this.width = 220,
        this.height = 40,
        this.hintStyle = const TextStyle(fontSize: 12,color: Colors.white54),
        this.left = 20,
        this.inputType,
        this.maxLength,
        this.backgroundcolor
      });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: this.height,
      width: this.width,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
          color: this.backgroundcolor
      ),
      child: TextField(
        cursorColor: usingColor.mainColor,
        style: TextStyle(color: Colors.black,fontFamily: 'ZR'),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(left: this.left),
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
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: usingColor.mainColor, width: 1.0),
            borderRadius: const BorderRadius.all(
              const Radius.circular(10.0),
            ),
          ),
          hintText: this.hintText,
          hintStyle: this.hintStyle,
          fillColor: usingColor.mainColor,
        ),
        controller: textEditingController,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        keyboardType: inputType,
        maxLength: maxLength,),
    );
  }
}
