import 'package:flutter/material.dart';

class StoryStyleConfig {
  final TextStyle yesStyle;
  final TextStyle noStyle;
  final TextStyle answerStyle;
  final TextStyle questionStyle;
  final TextStyle linkStyle;
  final TextStyle percentageStyle;
  final Color valueColor;
  final Color backgroundColor;
  final Color boxBackgroundColor;
  final double boxRadius;
  final Widget linkIcon;
  final String yesText;
  final String noText;
  final String linkText;

  const StoryStyleConfig({
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
    this.linkText= 'DISCOVER MORE',
  });
}
