import 'package:flutter/material.dart';
import 'package:story_view/models/story_style_config.dart';

import '../models/story.dart';

class LikeButton extends StatefulWidget {
  final StoryStyleConfig styleConfig;
  final Story currentStory;
  final Function() onChange;
  const LikeButton(this.currentStory,{required this.onChange,this.styleConfig=const StoryStyleConfig(), });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        setState(() {
          widget.currentStory.liked = !widget.currentStory.liked;
        });
        widget.onChange();
      },
      icon: Icon(
        widget.styleConfig.likeIcon,
        color: widget.currentStory.liked
            ? widget.styleConfig.likeColor
            : widget.styleConfig.inactiveLikeColor,
      ),
    );
  }
}
