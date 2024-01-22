import 'package:flutter/material.dart';
import 'package:story_view/models/story.dart';
import 'package:story_view/story_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: Home());
  }
}

class Home extends StatelessWidget {
  final StoryController controller = StoryController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delicious Ghanaian Meals"),
      ),
      body: Container(
        margin: const EdgeInsets.all(
          8,
        ),
        child: ListView(
          children: <Widget>[
            Container(
              height: 300,
              child: StoryView(
                controller: controller,
                stories: [
                  // StoryItem.inlineImage(
                  //   NetworkImage(
                  //       "https://image.ibb.co/gCZFbx/Banku-and-tilapia.jpg"),
                  //   caption: Text(
                  //     "Banku & Tilapia. The food to keep you charged whole day.\n#1 Local food.",
                  //     style: TextStyle(
                  //       color: Colors.white,
                  //       backgroundColor: Colors.black54,
                  //       fontSize: 17,
                  //     ),
                  //   ),
                  // ),
                  Story(
                    url:
                        "https://image.ibb.co/cU4WGx/Omotuo-Groundnut-Soup-braperucci-com-1.jpg",
                    text:
                        "Omotuo & Nkatekwan; You will love this meal if taken as supper.",
                  ),
                  Story(
                    url:
                        "https://media.giphy.com/media/5GoVLqeAOo6PK/giphy.gif",
                    text: "Hektas, sektas and skatad",
                  )
                ],
                onStoryShow: (s) {
                  print("Showing a story");
                },
                onComplete: () {
                  print("Completed a cycle");
                },
                progressPosition: ProgressPosition.bottom,
                repeat: false,
                inline: true,
              ),
            ),
            Material(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => MoreStories()));
                },
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.black54,
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(8))),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Text(
                        "View more stories",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MoreStories extends StatefulWidget {
  @override
  _MoreStoriesState createState() => _MoreStoriesState();
}

class _MoreStoriesState extends State<MoreStories> {
  final storyController = StoryController();

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("More"),
      ),
      body: StoryView(
        stories: [
          Story(
            text: "I guess you'd love to see more of our food. That's great.",
            url:
                "https://image.ibb.co/cU4WGx/Omotuo-Groundnut-Soup-braperucci-com-1.jpg",
            duration: const Duration(seconds: 3),
          ),
          Story(
            url: "https://media.giphy.com/media/5GoVLqeAOo6PK/giphy.gif",
            text: "Working with gifs",
            question: "You want more?",
            onAnswer: (value) {
              print(value);
            },
            results: {0: 70, 1: 30},
          ),
          Story(
              url: "https://media.giphy.com/media/XcA8krYsrEAYXKf4UQ/giphy.gif",
              text: "Hello, from the other side",
              link: "https://resmedia.it"),
          Story(
            url: "https://www.exit109.com/~dnn/clips/RW20seconds_1.mp4",
            isVideo: true,
            text: "Hello, from the other side2",
            question: "Which one?",
            onAnswer: (value) {
              print(value);
            },
            answers: [
              Answer(value: 0, text: "Risposta A"),
              Answer(value: 1, text: "Risposta B"),
              Answer(value: 2, text: "Risposta C")
            ],
            results: {0: 30, 1: 50, 2: 20},
          ),
        ],
        styleConfig: StoryStyleConfig(
          linkIcon: Transform.rotate(
              angle: -0.7,
              child: const Icon(
                Icons.link,
                color: Colors.blue,
              )),
        ),

        onStoryShow: (s) {
          print("Showing a story");
        },
        onComplete: () {
          print("Completed a cycle");
        },
        onLikeChange: (story, value){
          print(story);
          print(value);
        },
        progressPosition: ProgressPosition.top,
        repeat: false,
        controller: storyController,
      ),
    );
  }
}
