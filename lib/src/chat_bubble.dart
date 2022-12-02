import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum BubbleType {
  send,
  receiver,
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    Key? key,
    this.constraints,
    this.backgroundColor,
    this.child,
    this.decoration,
    this.margin,
    this.padding,
    required this.bubbleType,
  }) : super(key: key);
  final BoxConstraints? constraints;
  final Color? backgroundColor;
  final Widget? child;
  final BubbleType bubbleType;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final BoxDecoration? decoration;
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: constraints,
      margin: margin ?? EdgeInsets.only(right: 10.w, left: 10.w, bottom: 2.h),
      padding: padding ?? EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      alignment: Alignment.center,
      decoration: decoration ?? BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(bubbleType == BubbleType.send ? 8 : 1),
          topRight: Radius.circular(bubbleType == BubbleType.send ? 1 : 8),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: child,
    );
  }
}
