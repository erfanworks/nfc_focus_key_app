import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String title;
  final Color textColor;
  final FontWeight? fontWeight;
  final double textSize;
  final bool fontPoppins;
  final double top;
  final double right;
  final double left;
  final double bottom;
  final TextAlign textAlign;
  final int maxLine;
  final double? textHeight;
  final double? letterSpacing;
  final FontStyle? fontStyle;
  final TextDecoration? decoration;
  final TextOverflow? overflow;

  const CustomText({
    super.key,
    required this.title,
    this.textColor = const Color(0xFF363636),
    this.fontWeight,
    this.textSize = 14,
    this.fontPoppins = false,
    this.top = 0,
    this.right = 0,
    this.left = 0,
    this.bottom = 0,
    this.textAlign = TextAlign.left,
    this.maxLine = 2,
    this.textHeight,
    this.letterSpacing,
    this.fontStyle = FontStyle.normal,
    this.decoration,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top, left: left, right: right, bottom: bottom),
      child: Text(
        title,
        textAlign: textAlign,
        maxLines: maxLine,
        overflow: overflow ?? TextOverflow.ellipsis,
        style: TextStyle(
          height: textHeight,
          fontFamily: 'Roboto',
          fontSize: textSize,
          fontWeight: fontWeight,
          color: textColor,
          letterSpacing: letterSpacing,
          fontStyle: fontStyle,
          decoration: decoration,
          decorationColor: textColor,
        ),
      ),
    );
  }
}