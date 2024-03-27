import 'package:flutter/material.dart';

// customized text to show a title and a text with diferent styles

class CustomText extends StatelessWidget {
  final String title;
  final String text;
  final Color corTitle;
  final Color cor;
  final double fontSizeTitle;
  final double fontSize;
  const CustomText({
    required this.title,
    required this.text,
    this.corTitle = Colors.grey,
    this.cor = Colors.grey,
    this.fontSizeTitle = 14,
    this.fontSize = 14,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: fontSizeTitle,
          color: corTitle,
        ),
        children: [
          TextSpan(
            text: text,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: fontSize,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }
}
