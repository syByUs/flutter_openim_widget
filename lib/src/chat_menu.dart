import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_openim_widget/flutter_openim_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatMenuInfo {
  Widget icon;
  String text;
  TextStyle? textStyle;
  Function()? onTap;
  bool enabled;

  ChatMenuInfo({
    required this.icon,
    required this.text,
    this.textStyle,
    this.onTap,
    this.enabled = true,
  });
}

class ChatMenuStyle {
  final EdgeInsets padding;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final Color background;
  final double radius;

  ChatMenuStyle({
    required this.crossAxisCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.background,
    required this.radius,
    required this.padding,
  });

  const ChatMenuStyle.base()
      : crossAxisCount = 5,
        mainAxisSpacing = 20,
        crossAxisSpacing = 20,
        background = const Color(0xFF333333),
        radius = 8,
        padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 10);
}

class ChatLongPressMenu extends StatelessWidget {
  final CustomPopupMenuController controller;
  final List<ChatMenuInfo> menus;
  final ChatMenuStyle menuStyle;

  const ChatLongPressMenu({
    Key? key,
    required this.controller,
    required this.menus,
    this.menuStyle = const ChatMenuStyle.base(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: menuStyle.padding,
      decoration: BoxDecoration(
        color: menuStyle.background,
        borderRadius: BorderRadius.circular(menuStyle.radius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _children(),
      ),
    );
  }

  List<Widget> _children() {
    var widgets = <Widget>[];
    menus.removeWhere((element) => !element.enabled);
    var rows = menus.length ~/ menuStyle.crossAxisCount;
    if (menus.length % menuStyle.crossAxisCount != 0) {
      rows++;
    }
    for (var i = 0; i < rows; i++) {
      var start = i * menuStyle.crossAxisCount;
      var end = (i + 1) * menuStyle.crossAxisCount;
      if (end > menus.length) {
        end = menus.length;
      }
      var subList = menus.sublist(start, end);
      widgets.add(Row(
        mainAxisSize: MainAxisSize.min,
        // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: subList
            .map((e) =>
            _menuItem(
              icon: e.icon,
              label: e.text,
              onTap: e.onTap,
              style: e.textStyle ??
                  TextStyle(fontSize: 12.sp, color: Color(0xFFFFFFFF)),
            ))
            .toList(),
      ));
    }
    return widgets;
  }

  Widget _menuItem({
    required Widget icon,
    required String label,
    TextStyle? style,
    Function()? onTap,
  }) =>
      GestureDetector(
        onTap: () {
          controller.hideMenu();
          if (null != onTap) onTap();
        },
        behavior: HitTestBehavior.translucent,
        child: Container(
          // width: 50.w,
          // constraints: BoxConstraints(maxWidth: 35.w, minWidth: 30.w),
          padding: EdgeInsets.symmetric(
            horizontal: menuStyle.crossAxisSpacing,
            vertical: menuStyle.mainAxisSpacing / 2,
          ),
          child: _ItemView(icon: icon, label: label, style: style),
        ),
      );
}

class _ItemView extends StatelessWidget {
  const _ItemView({
    Key? key,
    required this.icon,
    required this.label,
    this.style,
  }) : super(key: key);
  final Widget icon;
  final String label;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 20.w,
            child: icon,
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ],
      ),
    );
  }
}
