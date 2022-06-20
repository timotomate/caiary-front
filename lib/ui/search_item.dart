import 'package:caiary/Data/userinfo.dart';
import 'package:caiary/themes/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class SearchItem extends StatefulWidget {


  SearchItem(
      {
        Key key,
        this.user,
        this.onPressed

      }) : super(key: key);

  final UserInfo user;
  final VoidCallback onPressed;

  @override
  _SearchItemState createState() => _SearchItemState();
}

class _SearchItemState extends State<SearchItem> {
  @override
  Widget build(BuildContext context) {
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
                  image: NetworkImage(widget.user.profile_image_url),
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
                Text(widget.user.username,style: TextStyle(color: Colors.black,fontSize: 17),),
              ],
            )
          ],
        ),
          onTap: widget.onPressed
    );
  }
}
