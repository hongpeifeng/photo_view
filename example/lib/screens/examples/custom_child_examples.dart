import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view_example/screens/app_bar.dart';

class CustomChildExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const ExampleAppBar(
            title: "Custom child Example",
            showGoBack: true,
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(20.0),
                  child: const Text(
                    "Example of usage with something different than a image",
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 20.0,
                  ),
                  height: 450.0,
                  child: ClipRect(
                    child: PhotoView.customChild(
                      child: Container(
                        decoration:
                            const BoxDecoration(color: Colors.lightGreenAccent),
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Text(
                              "Hello there, this is a text, that is a svg:",
                              style: TextStyle(fontSize: 12.0),
                              textAlign: TextAlign.center,
                            ),
//                            SvgPicture.asset(
//                              "assets/firefox.svg",
//                              height: 250.0,
//                            )
                          ],
                        ),
                      ),
                      initialScale: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
