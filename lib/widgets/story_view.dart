import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:story_view/models/story_style_config.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../controller/story_controller.dart';
import '../models/story.dart';
import '../utils.dart';
import 'story_image.dart';
import 'story_video.dart';

/// Indicates where the progress indicators should be placed.
enum ProgressPosition { top, bottom, none }

/// This is used to specify the height of the progress indicator. Inline stories
/// should use [small]
enum IndicatorHeight { small, large }

/// This is a representation of a story item (or page).
class StoryItem {
  /// Specifies how long the page should be displayed. It should be a reasonable
  /// amount of time greater than 0 milliseconds.
  final Duration duration;

  /// Has this page been shown already? This is used to indicate that the page
  /// has been displayed. If some pages are supposed to be skipped in a story,
  /// mark them as shown `shown = true`.
  ///
  /// However, during initialization of the story view, all pages after the
  /// last unshown page will have their `shown` attribute altered to false. This
  /// is because the next item to be displayed is taken by the last unshown
  /// story item.
  bool shown;

  /// The page content
  final Widget view;
  final String? link;
  StoryItem(
    this.view, {
    required this.duration,
    this.shown = false,
    this.link,
  });

  /// Short hand to create text-only page.
  ///
  /// [title] is the text to be displayed on [backgroundColor]. The text color
  /// alternates between [Colors.black] and [Colors.white] depending on the
  /// calculated contrast. This is to ensure readability of text.
  ///
  /// Works for inline and full-page stories. See [StoryView.inline] for more on
  /// what inline/full-page means.
  static StoryItem text({
    required String title,
    required Color backgroundColor,
    Key? key,
    TextStyle? textStyle,
    bool shown = false,
    bool roundedTop = false,
    bool roundedBottom = false,
    Duration? duration,
  }) {
    double contrast = ContrastHelper.contrast([
      backgroundColor.red,
      backgroundColor.green,
      backgroundColor.blue,
    ], [
      255,
      255,
      255
    ] /** white text */);

    return StoryItem(
      Container(
        key: key,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(roundedTop ? 8 : 0),
            bottom: Radius.circular(roundedBottom ? 8 : 0),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        child: Center(
          child: Text(
            title,
            style: textStyle?.copyWith(
                  color: contrast > 1.8 ? Colors.white : Colors.black,
                ) ??
                TextStyle(
                  color: contrast > 1.8 ? Colors.white : Colors.black,
                  fontSize: 18,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        //color: backgroundColor,
      ),
      shown: shown,
      duration: duration ?? Duration(seconds: 3),
    );
  }

  /// Factory constructor for page images. [controller] should be same instance as
  /// one passed to the `StoryView`
  factory StoryItem.pageImage(
    Story story, {
    required StoryController controller,
    Key? key,
    BoxFit imageFit = BoxFit.fitWidth,
    String? caption,
    bool shown = false,
    Map<String, dynamic>? requestHeaders,
    Duration? duration,
    String? link,
  }) {
    return StoryItem(
      Container(
        key: key,
        color: Colors.black,
        child: Stack(
          children: <Widget>[
            StoryImage.url(
              story.url,
              controller: controller,
              fit: imageFit,
              requestHeaders: requestHeaders,
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    bottom: 24,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  color: caption != null ? Colors.black54 : Colors.transparent,
                  child: caption != null
                      ? Text(
                          caption,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : SizedBox(),
                ),
              ),
            ),
          ],
        ),
      ),
      shown: shown,
      duration: duration ?? Duration(seconds: 3),
    );
  }

  /// Shorthand for creating inline image. [controller] should be same instance as
  /// one passed to the `StoryView`
  factory StoryItem.inlineImage({
    required String url,
    Text? caption,
    required StoryController controller,
    Key? key,
    BoxFit imageFit = BoxFit.cover,
    Map<String, dynamic>? requestHeaders,
    bool shown = false,
    bool roundedTop = true,
    bool roundedBottom = false,
    Duration? duration,
  }) {
    return StoryItem(
      ClipRRect(
        key: key,
        child: Container(
          color: Colors.grey[100],
          child: Container(
            color: Colors.black,
            child: Stack(
              children: <Widget>[
                StoryImage.url(
                  url,
                  controller: controller,
                  fit: imageFit,
                  requestHeaders: requestHeaders,
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      child: caption == null ? SizedBox() : caption,
                      width: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(roundedTop ? 8 : 0),
          bottom: Radius.circular(roundedBottom ? 8 : 0),
        ),
      ),
      shown: shown,
      duration: duration ?? Duration(seconds: 3),
    );
  }

  /// Shorthand for creating page video. [controller] should be same instance as
  /// one passed to the `StoryView`
  factory StoryItem.pageVideo(
    Story story, {
    required StoryController controller,
    Key? key,
    Duration? duration,
    BoxFit imageFit = BoxFit.fitWidth,
    String? caption,
    bool shown = false,
    Map<String, dynamic>? requestHeaders,
  }) {
    return StoryItem(
        Container(
          key: key,
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              StoryVideo.url(
                story.url,
                controller: controller,
                requestHeaders: requestHeaders,
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 24),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    color:
                        caption != null ? Colors.black54 : Colors.transparent,
                    child: caption != null
                        ? Text(
                            caption,
                            style: TextStyle(fontSize: 15, color: Colors.white),
                            textAlign: TextAlign.center,
                          )
                        : SizedBox(),
                  ),
                ),
              )
            ],
          ),
        ),
        shown: shown,
        duration: duration ?? Duration(seconds: 10));
  }

  /// Shorthand for creating a story item from an image provider such as `AssetImage`
  /// or `NetworkImage`. However, the story continues to play while the image loads
  /// up.
  factory StoryItem.pageProviderImage(
    ImageProvider image, {
    Key? key,
    BoxFit imageFit = BoxFit.fitWidth,
    String? caption,
    bool shown = false,
    Duration? duration,
  }) {
    return StoryItem(
        Container(
          key: key,
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              Center(
                child: Image(
                  image: image,
                  height: double.infinity,
                  width: double.infinity,
                  fit: imageFit,
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(
                      bottom: 24,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    color:
                        caption != null ? Colors.black54 : Colors.transparent,
                    child: caption != null
                        ? Text(
                            caption,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : SizedBox(),
                  ),
                ),
              )
            ],
          ),
        ),
        shown: shown,
        duration: duration ?? Duration(seconds: 3));
  }

  /// Shorthand for creating an inline story item from an image provider such as `AssetImage`
  /// or `NetworkImage`. However, the story continues to play while the image loads
  /// up.
  factory StoryItem.inlineProviderImage(
    ImageProvider image, {
    Key? key,
    Text? caption,
    bool shown = false,
    bool roundedTop = true,
    bool roundedBottom = false,
    Duration? duration,
  }) {
    return StoryItem(
      Container(
        key: key,
        decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(roundedTop ? 8 : 0),
              bottom: Radius.circular(roundedBottom ? 8 : 0),
            ),
            image: DecorationImage(
              image: image,
              fit: BoxFit.cover,
            )),
        child: Container(
          margin: EdgeInsets.only(
            bottom: 16,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 8,
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              child: caption == null ? SizedBox() : caption,
              width: double.infinity,
            ),
          ),
        ),
      ),
      shown: shown,
      duration: duration ?? Duration(seconds: 3),
    );
  }
}

/// Widget to display stories just like Whatsapp and Instagram. Can also be used
/// inline/inside [ListView] or [Column] just like Google News app. Comes with
/// gestures to pause, forward and go to previous page.
class StoryView extends StatefulWidget {
  /// The pages to displayed.
  final List<Story> stories;

  /// Callback for when a full cycle of story is shown. This will be called
  /// each time the full story completes when [repeat] is set to `true`.
  final VoidCallback? onComplete;

  /// Callback for when a vertical swipe gesture is detected. If you do not
  /// want to listen to such event, do not provide it. For instance,
  /// for inline stories inside ListViews, it is preferrable to not to
  /// provide this callback so as to enable scroll events on the list view.
  final Function(Direction?)? onVerticalSwipeComplete;

  /// Callback for when a story is currently being shown.
  final ValueChanged<Story>? onStoryShow;

  /// Where the progress indicator should be placed.
  final ProgressPosition progressPosition;

  /// Should the story be repeated forever?
  final bool repeat;

  /// If you would like to display the story as full-page, then set this to
  /// `false`. But in case you would display this as part of a page (eg. in
  /// a [ListView] or [Column]) then set this to `true`.
  final bool inline;

  // Controls the playback of the stories
  final StoryController controller;

  // Indicator Color
  final Color? indicatorColor;
  // Indicator Foreground Color
  final Color? indicatorForegroundColor;
  final Widget? centerWidget;
  final StoryStyleConfig styleConfig;
  final bool showLike;
  final bool showClose;
  final Function? onLikeChange;

  StoryView({
    required this.stories,
    required this.controller,
    this.onComplete,
    this.onStoryShow,
    this.progressPosition = ProgressPosition.top,
    this.repeat = false,
    this.inline = false,
    this.onVerticalSwipeComplete,
    this.indicatorColor,
    this.indicatorForegroundColor,
    this.centerWidget,
    this.styleConfig = const StoryStyleConfig(),
    this.showLike = true,
    this.showClose = true,
    this.onLikeChange,
  });

  @override
  State<StatefulWidget> createState() {
    return StoryViewState();
  }
}

class StoryViewState extends State<StoryView> with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _currentAnimation;
  Timer? _nextDebouncer;

  StreamSubscription<PlaybackState>? _playbackSubscription;

  VerticalDragInfo? verticalDragInfo;
  bool _showResults = false;

  Story? get _currentStory {
    return widget.stories.firstWhereOrNull((it) => !it.watched);
  }

  Widget get _currentView {
    var item = widget.stories.firstWhereOrNull((it) => !it.watched);
    item ??= widget.stories.last;
    widget.controller.currentStory.value = item;
    return item.view(widget.controller);
  }

  @override
  void initState() {
    super.initState();

    // All pages after the first unshown page should have their shown value as
    // false
    final firstPage = widget.stories.firstWhereOrNull((it) => !it.watched);
    if (firstPage == null) {
      widget.stories.forEach((it2) {
        it2.watched = false;
      });
    } else {
      final lastShownPos = widget.stories.indexOf(firstPage);
      widget.stories.sublist(lastShownPos).forEach((it) {
        it.watched = false;
      });
    }

    this._playbackSubscription =
        widget.controller.playbackNotifier.listen((playbackStatus) {
      switch (playbackStatus) {
        case PlaybackState.play:
          _removeNextHold();
          this._animationController?.forward();
          break;

        case PlaybackState.pause:
          _holdNext(); // then pause animation
          this._animationController?.stop(canceled: false);
          break;

        case PlaybackState.next:
          _removeNextHold();
          _goForward();
          break;

        case PlaybackState.previous:
          _removeNextHold();
          _goBack();
          break;
      }
    });

    _play();
  }

  @override
  void dispose() {
    _clearDebouncer();

    _animationController?.dispose();
    _playbackSubscription?.cancel();

    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _play() {
    _animationController?.dispose();
    // get the next playing page
    final storyItem = widget.stories.firstWhere((it) {
      return !it.watched;
    })!;

    if (widget.onStoryShow != null) {
      widget.onStoryShow!(storyItem);
    }

    _animationController =
        AnimationController(duration: storyItem.duration, vsync: this);

    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        storyItem.watched = true;
        if (widget.stories.last != storyItem) {
          _beginPlay();
        } else {
          // done playing
          _onComplete();
        }
      }
    });

    _currentAnimation =
        Tween(begin: 0.0, end: 1.0).animate(_animationController!);

    widget.controller.play();
  }

  void _beginPlay() {
    setState(() {
      _showResults = false;
    });
    _play();
  }

  void _onComplete() {
    if (widget.onComplete != null) {
      widget.controller.pause();
      widget.onComplete!();
    }

    if (widget.repeat) {
      widget.stories.forEach((it) {
        it.watched = false;
      });

      _beginPlay();
    }
  }

  void _goBack() {
    _animationController!.stop();

    if (this._currentStory == null) {
      widget.stories.last.watched = false;
    }

    if (this._currentStory == widget.stories.first) {
      _beginPlay();
    } else {
      this._currentStory!.watched = false;
      int lastPos = widget.stories.indexOf(this._currentStory!);
      final previous = widget.stories[lastPos - 1]!;

      previous.watched = false;

      _beginPlay();
    }
  }

  void _goForward() {
    if (this._currentStory != widget.stories.last) {
      _animationController!.stop();

      // get last showing
      final _last = this._currentStory;

      if (_last != null) {
        _last.watched = true;
        if (_last != widget.stories.last) {
          _beginPlay();
        }
      }
    } else {
      // this is the last page, progress animation should skip to end
      _animationController!
          .animateTo(1.0, duration: Duration(milliseconds: 10));
    }
  }

  void _clearDebouncer() {
    _nextDebouncer?.cancel();
    _nextDebouncer = null;
  }

  void _removeNextHold() {
    _nextDebouncer?.cancel();
    _nextDebouncer = null;
  }

  void _holdNext() {
    _nextDebouncer?.cancel();
    _nextDebouncer = Timer(Duration(milliseconds: 500), () {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          _currentView,
          Visibility(
            visible: widget.progressPosition != ProgressPosition.none,
            child: Align(
              alignment: widget.progressPosition == ProgressPosition.top
                  ? Alignment.topCenter
                  : Alignment.bottomCenter,
              child: SafeArea(
                bottom: widget.inline ? false : true,
                // we use SafeArea here for notched and bezeles phones
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: PageBar(
                    widget.stories
                        .map((it) => PageData(it.duration, it.watched))
                        .toList(),
                    this._currentAnimation,
                    key: UniqueKey(),
                    indicatorHeight: widget.inline
                        ? IndicatorHeight.small
                        : IndicatorHeight.large,
                    indicatorColor: widget.indicatorColor,
                    indicatorForegroundColor: widget.indicatorForegroundColor,
                  ),
                ),
              ),
            ),
          ),
          Align(
              alignment: Alignment.centerRight,
              heightFactor: 1,
              child: GestureDetector(
                onTapDown: (details) {
                  widget.controller.pause();
                },
                onTapCancel: () {
                  widget.controller.play();
                },
                onTapUp: (details) {
                  // if debounce timed out (not active) then continue anim
                  if (_nextDebouncer?.isActive == false) {
                    widget.controller.play();
                  } else {
                    widget.controller.next();
                  }
                },
                onVerticalDragStart: widget.onVerticalSwipeComplete == null
                    ? null
                    : (details) {
                        widget.controller.pause();
                      },
                onVerticalDragCancel: widget.onVerticalSwipeComplete == null
                    ? null
                    : () {
                        widget.controller.play();
                      },
                onVerticalDragUpdate: widget.onVerticalSwipeComplete == null
                    ? null
                    : (details) {
                        if (verticalDragInfo == null) {
                          verticalDragInfo = VerticalDragInfo();
                        }

                        verticalDragInfo!.update(details.primaryDelta!);

                        // TODO: provide callback interface for animation purposes
                      },
                onVerticalDragEnd: widget.onVerticalSwipeComplete == null
                    ? null
                    : (details) {
                        widget.controller.play();
                        // finish up drag cycle
                        if (!verticalDragInfo!.cancel &&
                            widget.onVerticalSwipeComplete != null) {
                          widget.onVerticalSwipeComplete!(
                              verticalDragInfo!.direction);
                        }

                        verticalDragInfo = null;
                      },
              )),
          Align(
            alignment: Alignment.centerLeft,
            heightFactor: 1,
            child: SizedBox(
                child: GestureDetector(onTap: () {
                  widget.controller.previous();
                }),
                width: 70),
          ),
          Positioned(
              top: 48,
              right: 12,
              child: Column(
                children: [
                  if (widget.showClose)
                    IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.clear,
                          color: Colors.white,
                        )),
                  if(widget.showLike)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentStory!.liked = !_currentStory!.liked;
                      });
                      widget.onLikeChange!(_currentStory!, _currentStory!.liked);
                    },
                    icon: Icon(
                      widget.styleConfig.likeIcon,
                      color: _currentStory!.liked
                          ? widget.styleConfig.likeColor
                          : widget.styleConfig.inactiveLikeColor,
                    ),
                  )
                ],
              )),
          if (_currentStory?.question != null && !_showResults)
            Padding(
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
                          _currentStory!.question!,
                          style: widget.styleConfig.questionStyle,
                        ),
                        _currentStory!.answers.isEmpty
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
                                      _currentStory!.onAnswer!(1);
                                      _currentStory!.results[1] =
                                          _currentStory!.results[1]! + 1;

                                      setState(() {
                                        _showResults = true;
                                      });
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
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
                                      _currentStory!.onAnswer!(0);
                                      _currentStory!.results[0] =
                                          _currentStory!.results[0]! + 1;

                                      setState(() {
                                        _showResults = true;
                                      });
                                    },
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: _currentStory!.answers
                                    .map((e) => MaterialButton(
                                          child: Text(
                                            e.text,
                                            style:
                                                widget.styleConfig.answerStyle,
                                          ),
                                          onPressed: () {
                                            _currentStory!.onAnswer!(e.value);
                                            _currentStory!.results[e.value] =
                                                _currentStory!
                                                        .results[e.value]! +
                                                    1;
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
            ),
          if (_showResults)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.styleConfig.boxBackgroundColor,
                    borderRadius:
                        BorderRadius.circular(widget.styleConfig.boxRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentStory!.question!,
                          style: widget.styleConfig.questionStyle,
                        ),
                        _currentStory!.answers.isEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Stack(
                                        children: [
                                          LinearProgressIndicator(
                                            value: 1 -
                                                _currentStory!.valuePercentage(
                                                    _currentStory!.results[1]),
                                            //borderRadius: BorderRadius.circular(6),
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
                                              top: 6,
                                              bottom: 6,
                                              child: Center(
                                                child: Text(
                                                  widget.styleConfig.yesText,
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
                                                  (_currentStory!.valuePercentage(
                                                                  _currentStory!
                                                                          .results[
                                                                      1]) *
                                                              100)
                                                          .toStringAsFixed(1) +
                                                      '%',
                                                  style: widget.styleConfig
                                                      .percentageStyle,
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
                                                _currentStory!.valuePercentage(
                                                    _currentStory!.results[0]),
                                            //borderRadius: BorderRadius.circular(6),
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
                                              top: 6,
                                              bottom: 6,
                                              child: Center(
                                                child: Text(
                                                  widget.styleConfig.noText,
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
                                                  (_currentStory!.valuePercentage(
                                                                  _currentStory!
                                                                          .results[
                                                                      0]) *
                                                              100)
                                                          .toStringAsFixed(1) +
                                                      '%',
                                                  style: widget.styleConfig
                                                      .percentageStyle),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ])
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: _currentStory!.answers
                                    .map((e) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 7.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            child: Stack(
                                              children: [
                                                LinearProgressIndicator(
                                                  value: 1 -
                                                      _currentStory!
                                                          .valuePercentage(
                                                              _currentStory!
                                                                      .results[
                                                                  e.value]),
                                                  backgroundColor: widget
                                                      .styleConfig.valueColor,
                                                  minHeight: 35,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
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
                                                            .styleConfig
                                                            .answerStyle,
                                                      ),
                                                    )),
                                                Positioned(
                                                    right: 8,
                                                    top: 6,
                                                    bottom: 6,
                                                    child: Center(
                                                      child: Text(
                                                        (_currentStory!.valuePercentage(
                                                                        _currentStory!.results[e
                                                                            .value]) *
                                                                    100)
                                                                .toStringAsFixed(
                                                                    1)
                                                                .toString() +
                                                            '%',
                                                        style: widget
                                                            .styleConfig
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
            ),
          if (_currentStory?.link != null)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.styleConfig.boxBackgroundColor,
                    borderRadius:
                        BorderRadius.circular(widget.styleConfig.boxRadius),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      launchUrlString(_currentStory!.link!,
                          mode: LaunchMode.externalApplication);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          widget.styleConfig.linkIcon,
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            widget.styleConfig.linkText,
                            style: widget.styleConfig.linkStyle,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_currentStory!.text != null)
            Positioned(
                bottom: 32,
                left: 8,
                right: 8,
                child: Text(
                  _currentStory!.text!,
                  //textAlign: TextAlign.center,
                  style: widget.styleConfig.textStyle,
                ))
        ],
      ),
    );
  }
}

/// Capsule holding the duration and shown property of each story. Passed down
/// to the pages bar to render the page indicators.
class PageData {
  Duration duration;
  bool shown;

  PageData(this.duration, this.shown);
}

/// Horizontal bar displaying a row of [StoryProgressIndicator] based on the
/// [pages] provided.
class PageBar extends StatefulWidget {
  final List<PageData> pages;
  final Animation<double>? animation;
  final IndicatorHeight indicatorHeight;
  final Color? indicatorColor;
  final Color? indicatorForegroundColor;

  PageBar(
    this.pages,
    this.animation, {
    this.indicatorHeight = IndicatorHeight.large,
    this.indicatorColor,
    this.indicatorForegroundColor,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PageBarState();
  }
}

class PageBarState extends State<PageBar> {
  double spacing = 4;

  @override
  void initState() {
    super.initState();

    int count = widget.pages.length;
    spacing = (count > 15) ? 1 : ((count > 10) ? 2 : 4);

    widget.animation!.addListener(() {
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  bool isPlaying(PageData page) {
    return widget.pages.firstWhereOrNull((it) => !it.shown) == page;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: widget.pages.map((it) {
        return Expanded(
          child: Container(
            padding: EdgeInsets.only(
                right: widget.pages.last == it ? 0 : this.spacing),
            child: StoryProgressIndicator(
              isPlaying(it) ? widget.animation!.value : (it.shown ? 1 : 0),
              indicatorHeight:
                  widget.indicatorHeight == IndicatorHeight.large ? 5 : 3,
              indicatorColor: widget.indicatorColor,
              indicatorForegroundColor: widget.indicatorForegroundColor,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Custom progress bar. Supposed to be lighter than the
/// original [ProgressIndicator], and rounded at the sides.
class StoryProgressIndicator extends StatelessWidget {
  /// From `0.0` to `1.0`, determines the progress of the indicator
  final double value;
  final double indicatorHeight;
  final Color? indicatorColor;
  final Color? indicatorForegroundColor;

  StoryProgressIndicator(
    this.value, {
    this.indicatorHeight = 5,
    this.indicatorColor,
    this.indicatorForegroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.fromHeight(
        this.indicatorHeight,
      ),
      foregroundPainter: IndicatorOval(
        this.indicatorForegroundColor ?? Colors.white.withOpacity(0.8),
        this.value,
      ),
      painter: IndicatorOval(
        this.indicatorColor ?? Colors.white.withOpacity(0.4),
        1.0,
      ),
    );
  }
}

class IndicatorOval extends CustomPainter {
  final Color color;
  final double widthFactor;

  IndicatorOval(this.color, this.widthFactor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = this.color;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width * this.widthFactor, size.height),
            Radius.circular(3)),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/// Concept source: https://stackoverflow.com/a/9733420
class ContrastHelper {
  static double luminance(int? r, int? g, int? b) {
    final a = [r, g, b].map((it) {
      double value = it!.toDouble() / 255.0;
      return value <= 0.03928
          ? value / 12.92
          : pow((value + 0.055) / 1.055, 2.4);
    }).toList();

    return a[0] * 0.2126 + a[1] * 0.7152 + a[2] * 0.0722;
  }

  static double contrast(rgb1, rgb2) {
    return luminance(rgb2[0], rgb2[1], rgb2[2]) /
        luminance(rgb1[0], rgb1[1], rgb1[2]);
  }
}
