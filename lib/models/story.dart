import 'package:flutter/material.dart';

import '../widgets/story_view.dart';

class Story {
  Story(
      {this.id,
      this.text,
      this.link,
      this.question,
      this.watched = false,
      this.liked = false,
      this.viewCount = 0,
      this.duration = const Duration(seconds: 10),
      this.userName,
      this.userImageUrl,
      required this.url,
      this.isVideo = false,
      this.answers = const [],
      this.results = const {},
      this.onAnswer});

  String? id;
  String? text;
  String? link;
  String? question;
  String? userImageUrl;
  String? userName;
  List<Answer> answers = [];
  Map<dynamic, int> results = {};
  bool watched = false;
  bool liked = false;
  int viewCount = 0;
  String url;
  bool isVideo;
  late Duration duration;
  Function? onAnswer;
  Function? onWatched;

  Widget view(controller) => isVideo
      ? StoryItem.pageVideo(this, controller: controller).view
      : StoryItem.pageImage(this, controller: controller).view;

  double valuePercentage(value) =>
      value / results.values.reduce((value, element) => value + element);
}

class Answer {
  late dynamic value;
  late String text;

  Answer({required this.value, required this.text});
}
