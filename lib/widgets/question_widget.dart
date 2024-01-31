import 'package:flutter/material.dart';
import 'package:story_view/models/story_style_config.dart';

import '../models/story.dart';

class QuestionWidget extends StatefulWidget {
  final Story story;
  final StoryStyleConfig styleConfig;
  const QuestionWidget(this.story,
      {this.styleConfig = const StoryStyleConfig()});

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  late bool _showResults = widget.story.userAnswer!=null??false;

  _QuestionWidgetState(){
  }
  @override
  Widget build(BuildContext context) {
    if (widget.story.question != null && !_showResults)
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.story.question!,
                    style: widget.styleConfig.questionStyle,
                  ),
                  widget.story.answers.isEmpty
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  widget.styleConfig.yesText,
                                  style: widget.styleConfig.yesStyle,
                                ),
                              ),
                              onTap: () {
                                widget.story.onAnswer!(1);
                                widget.story.results[1] =
                                    widget.story.results[1]! + 1;

                                setState(() {
                                  _showResults = true;
                                });
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Container(
                                color: Colors.grey,
                                width: 1,
                                height: 20,
                              ),
                            ),
                            InkWell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  widget.styleConfig.noText,
                                  style: widget.styleConfig.noStyle,
                                ),
                              ),
                              onTap: () {
                                widget.story.onAnswer!(0);
                                widget.story.results[0] =
                                    widget.story.results[0]! + 1;

                                setState(() {
                                  _showResults = true;
                                });
                              },
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: widget.story.answers
                              .map((e) => MaterialButton(
                                    child: Text(
                                      e.text,
                                      style: widget.styleConfig.answerStyle,
                                    ),
                                    onPressed: () {
                                      widget.story.onAnswer!(e.value);
                                      widget.story.results[e.value] =
                                          widget.story.results[e.value]! + 1;
                                      setState(() {
                                        _showResults = true;
                                      });
                                    },
                                  ))
                              .toList(),
                        ),
                ],
              ),
            ),
          ),
        ),
      );
    if (widget.story.question!=null && _showResults)
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: widget.styleConfig.boxBackgroundColor,
              borderRadius: BorderRadius.circular(widget.styleConfig.boxRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.story.question!,
                    style: widget.styleConfig.questionStyle,
                  ),
                  widget.story.answers.isEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Stack(
                                  children: [
                                    LinearProgressIndicator(
                                      value: 1 -
                                          widget.story.valuePercentage(
                                              widget.story.results[1]),
                                      //borderRadius: BorderRadius.circular(6),
                                      backgroundColor:
                                          widget.styleConfig.valueColor,
                                      minHeight: 35,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          widget.styleConfig.backgroundColor),
                                    ),
                                    Positioned(
                                        left: 8,
                                        top: 6,
                                        bottom: 6,
                                        child: Center(
                                          child: Text(
                                            widget.styleConfig.yesText,
                                            style:
                                                widget.styleConfig.answerStyle,
                                          ),
                                        )),
                                    Positioned(
                                        right: 8,
                                        top: 6,
                                        bottom: 6,
                                        child: Center(
                                          child: Text(
                                            (widget.story.valuePercentage(widget
                                                            .story.results[1]) *
                                                        100)
                                                    .toStringAsFixed(1) +
                                                '%',
                                            style: widget
                                                .styleConfig.percentageStyle,
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Stack(
                                  children: [
                                    LinearProgressIndicator(
                                      value: 1 -
                                          widget.story.valuePercentage(
                                              widget.story.results[0]),
                                      //borderRadius: BorderRadius.circular(6),
                                      backgroundColor:
                                          widget.styleConfig.valueColor,
                                      minHeight: 35,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          widget.styleConfig.backgroundColor),
                                    ),
                                    Positioned(
                                        left: 8,
                                        top: 6,
                                        bottom: 6,
                                        child: Center(
                                          child: Text(
                                            widget.styleConfig.noText,
                                            style:
                                                widget.styleConfig.answerStyle,
                                          ),
                                        )),
                                    Positioned(
                                      right: 8,
                                      top: 6,
                                      bottom: 6,
                                      child: Center(
                                        child: Text(
                                            (widget.story.valuePercentage(widget
                                                            .story.results[0]) *
                                                        100)
                                                    .toStringAsFixed(1) +
                                                '%',
                                            style: widget
                                                .styleConfig.percentageStyle),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ])
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: widget.story.answers
                              .map((e) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 7.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Stack(
                                        children: [
                                          LinearProgressIndicator(
                                            value: 1 -
                                                widget.story.valuePercentage(
                                                    widget.story
                                                        .results[e.value]),
                                            backgroundColor:
                                                widget.styleConfig.valueColor,
                                            minHeight: 35,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    widget.styleConfig
                                                        .backgroundColor),
                                          ),
                                          Positioned(
                                              left: 8,
                                              top: 4,
                                              bottom: 4,
                                              child: Center(
                                                child: Text(
                                                  e.text,
                                                  style: widget
                                                      .styleConfig.answerStyle,
                                                ),
                                              )),
                                          Positioned(
                                              right: 8,
                                              top: 6,
                                              bottom: 6,
                                              child: Center(
                                                child: Text(
                                                  (widget.story.valuePercentage(
                                                                  widget.story
                                                                          .results[
                                                                      e.value]) *
                                                              100)
                                                          .toStringAsFixed(1)
                                                          .toString() +
                                                      '%',
                                                  style: widget.styleConfig
                                                      .percentageStyle,
                                                ),
                                              )),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                ],
              ),
            ),
          ),
        ),
      );
    return SizedBox();
  }
}
