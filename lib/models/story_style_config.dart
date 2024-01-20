import 'package:flutter/material.dart';

class StoryStyleConfig {
  final Color backgroundColor;
  final Color boxBackgroundColor;
  final Color valueColor;

  final double boxRadius;

  final TextStyle answerStyle;
  final TextStyle linkStyle;
  final TextStyle noStyle;
  final TextStyle percentageStyle;
  final TextStyle questionStyle;
  final TextStyle textStyle;
  final TextStyle yesStyle;

  final String linkText;
  final String noText;
  final String yesText;

  final Widget linkIcon;

  const StoryStyleConfig({
    this.textStyle = const TextStyle(color: Colors.white),
    this.yesStyle = const TextStyle(fontSize: 24, color: Colors.green),
    this.noStyle = const TextStyle(fontSize: 24, color: Colors.red),
    this.answerStyle = const TextStyle(
        fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
    this.questionStyle = const TextStyle(
        fontSize: 32, color: Colors.black, fontWeight: FontWeight.bold),
    this.percentageStyle = const TextStyle(
        fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
    this.linkStyle = const TextStyle(fontSize: 24, color: Colors.blue),
    this.linkIcon = const Icon(
      Icons.link,
      color: Colors.blue,
    ),
    this.valueColor = Colors.green,
    this.backgroundColor = Colors.grey,
    this.boxBackgroundColor = Colors.white,
    this.boxRadius = 8,
    this.yesText = 'YES',
    this.noText = 'NO',
    this.linkText = 'DISCOVER MORE',
  });
}
