import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatLocationView extends StatelessWidget {
  ChatLocationView({
    Key? key,
    required this.description,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);
  final String description;
  final double latitude;
  final double longitude;
  final int zoom = 15;
  final _decoder = JsonDecoder();

  @override
  Widget build(BuildContext context) {
    var url;
    var name;
    var addr;
    try {
      var map = _decoder.convert(description);
      url = map['url'];
      name = map['name'];
      addr = map['addr'];
      return Container(
        width: 200.w,
        color: Colors.white,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Color(0xFF333333),
                          ),
                        ),
                        Text(
                          addr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ImageUtil.networkImage(
                    url: url,
                    height: 100.h,
                    fit: BoxFit.cover,
                    cacheWidth: (1.sw).toInt(),
                  ),
                )
              ],
            )
          ],
        ),
      );
    } catch (e) {}
    return Container();
  }
}
