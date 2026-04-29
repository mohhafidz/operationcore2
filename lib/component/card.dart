import 'package:flutter/material.dart';

class CardCustume extends StatelessWidget {
  CardCustume({
    super.key,
    required this.widget,
    this.width,
    required this.padding,
    this.height,
  });
  final Widget widget;
  final double? width;
  final double padding;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Color(0xff1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsetsDirectional.all(padding),
      child: widget,
    );
  }
}
